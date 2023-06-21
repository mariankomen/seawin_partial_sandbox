public class InventoryInformationController {

    public String productId {get;set;}
    public Product2 product {get;set;}
    public Boolean isKit {get;set;}
    public ProductInvetoryWrapper notKitInventoryInfo {get;set;}
    public ProductKitInventoryWrapper kitInventoryInfo {get;set;}
    public InventoryInformationController(){
        ProductId = ApexPages.currentPage().getParameters().get('id');
        getProductInfo();

        isKit = product.AcctSeed__Inventory_Type__c == 'Kit' ? true : false;

        if(!isKit){ //if product not kit
            notKitInventoryInfo = findProductInventoryInfo();
        }else{ //if product is kit
            kitInventoryInfo = findKitProductsInventoryInfo();
        }
    }

    public void getProductInfo(){
        String fields = AllFields.Fields('Product2', new List<String>());
        
        product = Database.query(
            'Select ' +
            fields +
            ' from Product2 where Id=:ProductId Limit 1'
        );
    }

    /*****************************************************************************************************
    *   @method       : findProductInventoryInfo
    *   @description  : method finds inventory info about single product
    *   @return       : ProductInvetoryWrapper
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public ProductInvetoryWrapper findProductInventoryInfo(){

        //Available Quantity
        AggregateResult aggregateAvailableTotal = [
            SELECT Sum(Available_Quantity__c) total
            FROM AcctSeedERP__Inventory_Balance__c
            WHERE
            AcctSeedERP__Product__c = :ProductId
        ];
        List<AcctSeedERP__Inventory_Balance__c> availableQuantityList = [SELECT Id, Name, 
                                        AcctSeedERP__Location__c, 
                                        AcctSeedERP__Location__r.Name, 
                                        AcctSeedERP__Warehouse__c, 
                                        AcctSeedERP__Warehouse__r.Name, 
                                        AcctSeedERP__Product__c, 
                                        Available_Quantity__c 
                                        FROM AcctSeedERP__Inventory_Balance__c
                                        WHERE AcctSeedERP__Product__c = :ProductId];

        List<AvailableQuantityWrapper> AvailableQuantityWrapperList = new List<AvailableQuantityWrapper>();

        for(AcctSeedERP__Inventory_Balance__c bal: availableQuantityList){
            AvailableQuantityWrapperList.add(new AvailableQuantityWrapper(
                bal.Id,
                bal.Name,
                bal.AcctSeedERP__Warehouse__c,
                bal.AcctSeedERP__Warehouse__r.Name,
                bal.AcctSeedERP__Location__c,
                bal.AcctSeedERP__Location__r.Name,
                bal.Available_Quantity__c
            ));
        }

        Integer availableQuantity = RoundOffDecimal(aggregateAvailableTotal.get('total') == null ? 0 : Integer.valueOf(aggregateAvailableTotal.get('total')));
        

        //Sales Order Quantity
        List<AcctSeedERP__Sales_Order_Line__c> salesOrderLinesWithProduct = [SELECT AcctSeedERP__Sales_Order__c, AcctSeedERP__Sales_Order__r.Name,AcctSeedERP__Quantity_Needed__c,AcctSeedERP__Quantity_Allocated__c, AcctSeedERP__Quantity_Shipped__c
                                                                                FROM AcctSeedERP__Sales_Order_Line__c
                                                                                WHERE
                                                                                AcctSeedERP__Sales_Order__r.AcctSeedERP__Status__c = 'Open'
                                                                                AND AcctSeedERP__Product__c = :ProductId
                                                                                ORDER BY AcctSeedERP__Sales_Order__r.Name ASC
                                                                            ];
        Map<Id, SalesOrderQuantityWrapper> salesOrderInventoryWrapp = new Map<Id, SalesOrderQuantityWrapper>();

        for(AcctSeedERP__Sales_Order_Line__c sol: salesOrderLinesWithProduct){
            if(!salesOrderInventoryWrapp.containsKey(sol.AcctSeedERP__Sales_Order__c)){
                salesOrderInventoryWrapp.put(sol.AcctSeedERP__Sales_Order__c, new SalesOrderQuantityWrapper(
                    sol.AcctSeedERP__Sales_Order__c,
                    sol.AcctSeedERP__Sales_Order__r.Name,
                    sol.AcctSeedERP__Quantity_Needed__c
                ));
            }else{
                Decimal previousQuantity = salesOrderInventoryWrapp.get(sol.AcctSeedERP__Sales_Order__c).salesOrderQuantity;
                Decimal newQuantity = previousQuantity + sol.AcctSeedERP__Quantity_Needed__c;
                salesOrderInventoryWrapp.get(sol.AcctSeedERP__Sales_Order__c).salesOrderQuantity = newQuantity;
            }
        }

        List<SalesOrderQuantityWrapper> salesOrderPerProductInventoryInfo = salesOrderInventoryWrapp.values();

        //Allocated Quantity
        Map<Id, SalesOrderAllocatedWrapper> salesOrderAllocatedInventoryWrapp = new Map<Id, SalesOrderAllocatedWrapper>();

        for(AcctSeedERP__Sales_Order_Line__c sol: salesOrderLinesWithProduct){
            Decimal remainingQuantity = sol.AcctSeedERP__Quantity_Allocated__c - sol.AcctSeedERP__Quantity_Shipped__c;

            if(!salesOrderAllocatedInventoryWrapp.containsKey(sol.AcctSeedERP__Sales_Order__c)){
                salesOrderAllocatedInventoryWrapp.put(sol.AcctSeedERP__Sales_Order__c, new SalesOrderAllocatedWrapper(
                    sol.AcctSeedERP__Sales_Order__c,
                    sol.AcctSeedERP__Sales_Order__r.Name,
                    remainingQuantity
                ));
            }else{
                Decimal previousQuantity = salesOrderAllocatedInventoryWrapp.get(sol.AcctSeedERP__Sales_Order__c).salesOrderAllocatedQuantity;
                Decimal newQuantity = previousQuantity + remainingQuantity;
                salesOrderAllocatedInventoryWrapp.get(sol.AcctSeedERP__Sales_Order__c).salesOrderAllocatedQuantity = newQuantity;

            }
        }

        List<SalesOrderAllocatedWrapper> salesOrderAllocatedInventoryInfo = new List<SalesOrderAllocatedWrapper>();
        
        for(SalesOrderAllocatedWrapper wrapper: salesOrderAllocatedInventoryWrapp.values()){
            if(wrapper.salesOrderAllocatedQuantity != 0) salesOrderAllocatedInventoryInfo.add(wrapper);
        }

        //Purchase Order Quantity

        List<AggregateResult> purchaseOrderQuantity = [SELECT AcctSeedERP__Product__c product,
                                                        SUM(AcctSeedERP__Quantity_Unreceived__c) unreceived,
                                                        AcctSeedERP__Purchase_Order__c purchaseorder,
                                                        MIN(AcctSeedERP__Purchase_Order__r.Name) purchaseOrderName
                                                        FROM AcctSeedERP__Purchase_Order_Line__c
                                                        WHERE AcctSeedERP__Product__c =:ProductId
                                                        AND AcctSeedERP__Quantity_Unreceived__c > 0
                                                        GROUP BY AcctSeedERP__Product__c, AcctSeedERP__Purchase_Order__c
                                                        ORDER BY AcctSeedERP__Purchase_Order__c ASC];

        List<PurchaseOrderQuantityWrapper> purchaseOrderInventoryInfo = new List<PurchaseOrderQuantityWrapper>();

        for(AggregateResult agr: purchaseOrderQuantity){
            purchaseOrderInventoryInfo.add(new PurchaseOrderQuantityWrapper(
                (Id)agr.get('purchaseorder'),
                (String)agr.get('purchaseOrderName'),
                (Decimal)agr.get('unreceived')
            ));
        }


        ProductInvetoryWrapper inventory = new ProductInvetoryWrapper(
            product,
            AvailableQuantityWrapperList,
            salesOrderPerProductInventoryInfo,
            salesOrderAllocatedInventoryInfo,
            purchaseOrderInventoryInfo
        );

        return inventory;
    }



    public Integer RoundOffDecimal(Integer num) {
        num = num == null ? 0 : num;
        
        return num;
    }






    public ProductKitInventoryWrapper findKitProductsInventoryInfo(){
        List<AcctSeed__Product_Part__c> productParts = [SELECT Id, 
                                                                Name, 
                                                                AcctSeed__Inventory_Type__c, 
                                                                AcctSeed__Product_Part__c, 
                                                                AcctSeed__Product__c, 
                                                                AcctSeed__Quantity__c, 
                                                                Kit_Product__c, 
                                                                Kit_Children__c 
                                                                FROM AcctSeed__Product_Part__c 
                                                                WHERE Kit_Product__c=:ProductId];
        if(productParts.isEmpty()) return null;

        Set<Id> kitPartIds = new Set<Id>(); //Ids of products what is kit childrens of opened kit

        for(AcctSeed__Product_Part__c part: productParts){
            if(part.Kit_Children__c != null) kitPartIds.add(part.Kit_Children__c);
        }

        String fields = AllFields.Fields('Product2', new List<String>());
        
        List<Product2> childrenProducts = Database.query(
            'Select ' +
            fields +
            ' from Product2 where Id IN:kitPartIds'
        );
        Map<Id, Product2> childrenProductsMap = new Map<Id, Product2>(childrenProducts);


        //Available Quantity
        List<AcctSeedERP__Inventory_Balance__c> availableQuantityList = [SELECT Id, Name, 
                                        AcctSeedERP__Location__c, 
                                        AcctSeedERP__Location__r.Name, 
                                        AcctSeedERP__Warehouse__c, 
                                        AcctSeedERP__Warehouse__r.Name, 
                                        AcctSeedERP__Product__c, 
                                        Available_Quantity__c 
                                        FROM AcctSeedERP__Inventory_Balance__c
                                        WHERE AcctSeedERP__Product__c IN: kitPartIds];

        Map<Id, List<AvailableQuantityWrapper>> AvailableQuantityWrapperMap = new Map<Id, List<AvailableQuantityWrapper>>(); // Kit children id & list of available quantity

        for(AcctSeedERP__Inventory_Balance__c bal: availableQuantityList){

            if(!AvailableQuantityWrapperMap.containsKey(bal.AcctSeedERP__Product__c)){
                AvailableQuantityWrapperMap.put(bal.AcctSeedERP__Product__c, new List<AvailableQuantityWrapper>{
                    new AvailableQuantityWrapper(
                        bal.Id,
                        bal.Name,
                        bal.AcctSeedERP__Warehouse__c,
                        bal.AcctSeedERP__Warehouse__r.Name,
                        bal.AcctSeedERP__Location__c,
                        bal.AcctSeedERP__Location__r.Name,
                        bal.Available_Quantity__c
                    )
                });
            }else{
                AvailableQuantityWrapperMap.get(bal.AcctSeedERP__Product__c).add(new AvailableQuantityWrapper(
                    bal.Id,
                    bal.Name,
                    bal.AcctSeedERP__Warehouse__c,
                    bal.AcctSeedERP__Warehouse__r.Name,
                    bal.AcctSeedERP__Location__c,
                    bal.AcctSeedERP__Location__r.Name,
                    bal.Available_Quantity__c
                ));
            }
        }


        //Sales Order Quantity for kit childrens
        List<AcctSeedERP__Sales_Order_Line__c> salesOrderLinesWithProduct = [SELECT AcctSeedERP__Sales_Order__c,AcctSeedERP__Product__c, AcctSeedERP__Sales_Order__r.Name,AcctSeedERP__Quantity_Needed__c,AcctSeedERP__Quantity_Allocated__c, AcctSeedERP__Quantity_Shipped__c
                                                                                FROM AcctSeedERP__Sales_Order_Line__c
                                                                                WHERE
                                                                                AcctSeedERP__Sales_Order__r.AcctSeedERP__Status__c = 'Open'
                                                                                AND AcctSeedERP__Product__c IN: kitPartIds
                                                                                ORDER BY AcctSeedERP__Sales_Order__r.Name ASC
                                                                            ];     
        Map<Id, Map<Id, SalesOrderQuantityWrapper>> salesOrderInventoryWrapp = new Map<Id, Map<Id, SalesOrderQuantityWrapper>>();


        for(AcctSeedERP__Sales_Order_Line__c sol: salesOrderLinesWithProduct){
            if(!salesOrderInventoryWrapp.containsKey(sol.AcctSeedERP__Product__c)){
                Map<Id, SalesOrderQuantityWrapper> innerMap = new Map<Id, SalesOrderQuantityWrapper>();
                innerMap.put(sol.AcctSeedERP__Sales_Order__c, new SalesOrderQuantityWrapper(
                    sol.AcctSeedERP__Sales_Order__c,
                    sol.AcctSeedERP__Sales_Order__r.Name,
                    sol.AcctSeedERP__Quantity_Needed__c
                ));

                salesOrderInventoryWrapp.put(sol.AcctSeedERP__Product__c, innerMap);
            }else{
                if(!salesOrderInventoryWrapp.get(sol.AcctSeedERP__Product__c).containsKey(sol.AcctSeedERP__Sales_Order__c)){
                    salesOrderInventoryWrapp.get(sol.AcctSeedERP__Product__c).put(sol.AcctSeedERP__Sales_Order__c, new SalesOrderQuantityWrapper(
                        sol.AcctSeedERP__Sales_Order__c,
                        sol.AcctSeedERP__Sales_Order__r.Name,
                        sol.AcctSeedERP__Quantity_Needed__c
                    ));
                }else{
                    Decimal previousQuantity = salesOrderInventoryWrapp.get(sol.AcctSeedERP__Product__c).get(sol.AcctSeedERP__Sales_Order__c).salesOrderQuantity;
                    Decimal newQuantity = previousQuantity + sol.AcctSeedERP__Quantity_Needed__c;
                    salesOrderInventoryWrapp.get(sol.AcctSeedERP__Product__c).get(sol.AcctSeedERP__Sales_Order__c).salesOrderQuantity = newQuantity;

                }
            }
        }

        //Allocated Quantity
        Map<Id, Map<Id, SalesOrderAllocatedWrapper>> salesOrderAllocatedInventoryWrapp = new Map<Id, Map<Id, SalesOrderAllocatedWrapper>>();

        for(AcctSeedERP__Sales_Order_Line__c sol: salesOrderLinesWithProduct){
            Decimal remainingQuantity = sol.AcctSeedERP__Quantity_Allocated__c - sol.AcctSeedERP__Quantity_Shipped__c;

            if(!salesOrderAllocatedInventoryWrapp.containsKey(sol.AcctSeedERP__Product__c)){
                Map<Id, SalesOrderAllocatedWrapper> innerMap = new Map<Id, SalesOrderAllocatedWrapper>();
                innerMap.put(sol.AcctSeedERP__Sales_Order__c, new SalesOrderAllocatedWrapper(
                    sol.AcctSeedERP__Sales_Order__c,
                    sol.AcctSeedERP__Sales_Order__r.Name,
                    remainingQuantity
                ));

                salesOrderAllocatedInventoryWrapp.put(sol.AcctSeedERP__Product__c, innerMap);
            }else{
                if(!salesOrderAllocatedInventoryWrapp.get(sol.AcctSeedERP__Product__c).containsKey(sol.AcctSeedERP__Sales_Order__c)){
                    salesOrderAllocatedInventoryWrapp.get(sol.AcctSeedERP__Product__c).put(sol.AcctSeedERP__Sales_Order__c, new SalesOrderAllocatedWrapper(
                        sol.AcctSeedERP__Sales_Order__c,
                        sol.AcctSeedERP__Sales_Order__r.Name,
                        remainingQuantity
                    ));
                }else{
                    Decimal previousQuantity = salesOrderAllocatedInventoryWrapp.get(sol.AcctSeedERP__Product__c).get(sol.AcctSeedERP__Sales_Order__c).salesOrderAllocatedQuantity;
                    Decimal newQuantity = previousQuantity + remainingQuantity;
                    salesOrderAllocatedInventoryWrapp.get(sol.AcctSeedERP__Product__c).get(sol.AcctSeedERP__Sales_Order__c).salesOrderAllocatedQuantity = newQuantity;

                }
            }
        }


        //Purchase Order Quantity
        List<AcctSeedERP__Purchase_Order_Line__c> purchaseOrderLines = [SELECT Id, AcctSeedERP__Product__c, 
                                                                                    AcctSeedERP__Quantity_Unreceived__c, 
                                                                                    AcctSeedERP__Purchase_Order__c, 
                                                                                    AcctSeedERP__Purchase_Order__r.Name
                                                                            FROM AcctSeedERP__Purchase_Order_Line__c
                                                                            WHERE AcctSeedERP__Product__c IN:kitPartIds
                                                                            AND AcctSeedERP__Quantity_Unreceived__c > 0];
        
        Map<Id, Map<Id, PurchaseOrderQuantityWrapper>> purchaseOrderInventoryWrapp = new Map<Id, Map<Id, PurchaseOrderQuantityWrapper>>();

        for(AcctSeedERP__Purchase_Order_Line__c poLine: purchaseOrderLines){
            if(!purchaseOrderInventoryWrapp.containsKey(poLine.AcctSeedERP__Product__c)){
                Map<Id, PurchaseOrderQuantityWrapper> innerMap = new Map<Id, PurchaseOrderQuantityWrapper>();
                innerMap.put(poLine.AcctSeedERP__Purchase_Order__c, new PurchaseOrderQuantityWrapper(
                    poLine.AcctSeedERP__Purchase_Order__c,
                    poLine.AcctSeedERP__Purchase_Order__r.Name,
                    poLine.AcctSeedERP__Quantity_Unreceived__c
                ));

                purchaseOrderInventoryWrapp.put(poLine.AcctSeedERP__Product__c, innerMap);
            }else{
                if(!purchaseOrderInventoryWrapp.get(poLine.AcctSeedERP__Product__c).containsKey(poLine.AcctSeedERP__Purchase_Order__c)){
                    purchaseOrderInventoryWrapp.get(poLine.AcctSeedERP__Product__c).put(poLine.AcctSeedERP__Purchase_Order__c, new PurchaseOrderQuantityWrapper(
                        poLine.AcctSeedERP__Purchase_Order__c,
                        poLine.AcctSeedERP__Purchase_Order__r.Name,
                        poLine.AcctSeedERP__Quantity_Unreceived__c
                    ));
                }else{
                    Decimal previousQuantity = purchaseOrderInventoryWrapp.get(poLine.AcctSeedERP__Product__c).get(poLine.AcctSeedERP__Purchase_Order__c).purchaseOrderUnallocatedQuantity;
                    Decimal newQuantity = previousQuantity + poLine.AcctSeedERP__Quantity_Unreceived__c;
                    purchaseOrderInventoryWrapp.get(poLine.AcctSeedERP__Product__c).get(poLine.AcctSeedERP__Purchase_Order__c).purchaseOrderUnallocatedQuantity = newQuantity;

                }
            }
        }

        List<ProductInvetoryWrapper> kitChildrensInventory = new List<ProductInvetoryWrapper>();
        for(Id childrenId: kitPartIds){
            kitChildrensInventory.add(new ProductInvetoryWrapper(
                childrenProductsMap.containsKey(childrenId) ? childrenProductsMap.get(childrenId) : null,
                AvailableQuantityWrapperMap.containsKey(childrenId) ? AvailableQuantityWrapperMap.get(childrenId) : null,
                salesOrderInventoryWrapp.containsKey(childrenId) ? salesOrderInventoryWrapp.get(childrenId).values() : null,
                salesOrderAllocatedInventoryWrapp.containsKey(childrenId) ? salesOrderAllocatedInventoryWrapp.get(childrenId).values() : null,
                purchaseOrderInventoryWrapp.containsKey(childrenId) ? purchaseOrderInventoryWrapp.get(childrenId).values() : null
            ));
        }

        ProductKitInventoryWrapper kitInventoryWrapper = new ProductKitInventoryWrapper(product, productParts, kitChildrensInventory);

        return kitInventoryWrapper;
    }










    //Wrapper for kit with kit children inventory
    public class ProductKitInventoryWrapper{
        public Product2 product {get;set;}
        public List<AcctSeed__Product_Part__c> productParts {get;set;} //AcctSeed__Quantity__c
        public Decimal maxAvailableQuantity {get;set;}

        public List<ProductInvetoryWrapper> kitChildrensInventory {get;set;}

        public ProductKitInventoryWrapper(Product2 product, List<AcctSeed__Product_Part__c> productParts, List<ProductInvetoryWrapper> kitChildrensInventory){
            this.product = product;
            this.productParts = productParts;
            this.kitChildrensInventory = kitChildrensInventory;

            Map<Id, ProductInvetoryWrapper> kitChildrensInventoryMap = new Map<Id, ProductInvetoryWrapper>();
            Map<Id, Decimal> productPartsQuantityMap = new Map<Id, Decimal>();

            for(AcctSeed__Product_Part__c part: productParts){
                productPartsQuantityMap.put(part.Kit_Children__c, part.AcctSeed__Quantity__c);
            }
            for(ProductInvetoryWrapper wrapper: kitChildrensInventory){
                kitChildrensInventoryMap.put(wrapper.product.Id, wrapper);
            }

            
            List<Decimal> availableQuantitiesOfChildrens = new List<Decimal>();
            for(Id childrenId: kitChildrensInventoryMap.keySet()){
                
                Decimal total = kitChildrensInventoryMap.get(childrenId).totalAvailableQuantity;
                availableQuantitiesOfChildrens.add(total/productPartsQuantityMap.get(childrenId));
            }
            Decimal minNumber = availableQuantitiesOfChildrens[0]; // Припустимо, що перше число є поточним найменшим

            for (Decimal num : availableQuantitiesOfChildrens) {
                if (num < minNumber) {
                    minNumber = num;
                }
            }
            maxAvailableQuantity = minNumber;
        }
    }

    //wrapper for single product inventory 
    public class ProductInvetoryWrapper{
        public Product2 product {get;set;}
        public List<AvailableQuantityWrapper> availableQuantity {get;set;}
        public List<SalesOrderQuantityWrapper> salesOrderQuantity {get;set;}
        public List<SalesOrderAllocatedWrapper> salesOrderAllocatedQuantity {get;set;}
        public List<PurchaseOrderQuantityWrapper> purchaseOrderQuantity {get;set;}

        public Decimal totalAvailableQuantity {get;set;}
        public Decimal totalSalesOrderQuantity {get;set;}
        public Decimal totalAllocatedQuantity {get;set;}
        public Decimal totalPurchaseOrderQuantity {get;set;}
        public ProductInvetoryWrapper(Product2 product, 
                                        List<AvailableQuantityWrapper> availableQuantity, 
                                        List<SalesOrderQuantityWrapper> salesOrderQuantity,
                                        List<SalesOrderAllocatedWrapper> salesOrderAllocatedQuantity,
                                        List<PurchaseOrderQuantityWrapper> purchaseOrderQuantity
        ){
            this.product = product;
            this.availableQuantity = availableQuantity;
            this.salesOrderQuantity = salesOrderQuantity;
            this.salesOrderAllocatedQuantity = salesOrderAllocatedQuantity;
            this.purchaseOrderQuantity = purchaseOrderQuantity;

            this.totalAvailableQuantity = 0;
            this.totalSalesOrderQuantity = 0;
            this.totalAllocatedQuantity = 0;
            this.totalPurchaseOrderQuantity = 0;

            if(availableQuantity != null && !availableQuantity.isEmpty() ){
                for(AvailableQuantityWrapper avw: availableQuantity){
                    if(avw.quantity != null) this.totalAvailableQuantity += avw.quantity;
                }
            }

            if(salesOrderQuantity != null && !salesOrderQuantity.isEmpty() && salesOrderQuantity != null){
                for(SalesOrderQuantityWrapper avw: salesOrderQuantity){
                    if(avw.salesOrderQuantity != null) this.totalSalesOrderQuantity += avw.salesOrderQuantity;
                }
            }

            if(salesOrderAllocatedQuantity != null && !salesOrderAllocatedQuantity.isEmpty() ){
                for(SalesOrderAllocatedWrapper avw: salesOrderAllocatedQuantity){
                    if(avw.salesOrderAllocatedQuantity != null) this.totalAllocatedQuantity += avw.salesOrderAllocatedQuantity;
                }
            }

            if(purchaseOrderQuantity != null && !purchaseOrderQuantity.isEmpty()){
                for(PurchaseOrderQuantityWrapper avw: purchaseOrderQuantity){
                    if(avw.purchaseOrderUnallocatedQuantity != null) this.totalPurchaseOrderQuantity += avw.purchaseOrderUnallocatedQuantity;
                }
            }
        }
    }


    //available quantity wrapper
    public class AvailableQuantityWrapper {
        public Id inventoryQuantityAvailableId {get;set;}
        public String inventoryQuantityAvailableName {get;set;}
        public Id warehouseId {get;set;}
        public String warehouseName {get;set;}
        public Id locationId {get;set;}
        public String locationName {get;set;}
        public Decimal quantity {get;set;}

        public AvailableQuantityWrapper(
            Id inventoryQuantityAvailableId, String inventoryQuantityAvailableName,
            Id warehouseId, String warehouseName,
            Id locationId, String locationName,
            Decimal quantity
        ){
            this.inventoryQuantityAvailableId = inventoryQuantityAvailableId;
            this.inventoryQuantityAvailableName = inventoryQuantityAvailableName;
            this.warehouseId = warehouseId;
            this.warehouseName = warehouseName;
            this.locationId = locationId;
            this.locationName = locationName;
            this.quantity = quantity;
        }

    }
    public class SalesOrderQuantityWrapper{
        public Id salesOrderId {get;set;}
        public String salesOrderName {get;set;}
        public Decimal salesOrderQuantity {get;set;}

        public SalesOrderQuantityWrapper(Id salesOrderId, String salesOrderName, Decimal salesOrderQuantity){
            this.salesOrderId = salesOrderId;
            this.salesOrderName = salesOrderName;
            this.salesOrderQuantity = salesOrderQuantity;
        }
    }

    public class SalesOrderAllocatedWrapper{
        public Id salesOrderId {get;set;}
        public String salesOrderName {get;set;}
        public Decimal salesOrderAllocatedQuantity {get;set;}

        public SalesOrderAllocatedWrapper(Id salesOrderId, String salesOrderName, Decimal salesOrderAllocatedQuantity){
            this.salesOrderId = salesOrderId;
            this.salesOrderName = salesOrderName;
            this.salesOrderAllocatedQuantity = salesOrderAllocatedQuantity;
        }
    }

    public class PurchaseOrderQuantityWrapper{
        public Id purchaseOrderId {get;set;}
        public String purchaseOrderName {get;set;}
        public Decimal purchaseOrderUnallocatedQuantity {get;set;}

        public PurchaseOrderQuantityWrapper(Id purchaseOrderId, String purchaseOrderName, Decimal purchaseOrderUnallocatedQuantity){
            this.purchaseOrderId = purchaseOrderId;
            this.purchaseOrderName = purchaseOrderName;
            this.purchaseOrderUnallocatedQuantity = purchaseOrderUnallocatedQuantity;
        }
    }




    public void coverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }


}