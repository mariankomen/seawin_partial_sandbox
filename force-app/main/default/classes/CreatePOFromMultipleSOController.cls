public with sharing class CreatePOFromMultipleSOController {
    
    // Wrapper classes
    public list<ListSalesOrderLines> SalesOrderLinesListing {get; set;}
    public list<CreateDraft> Drafting {get; set;}
    
    //public map<string, AcctSeedERP__Sales_Order_Line__c> UniqueMap {get; set;}
    
    // Sales Order
    public map<id, acctseederp__sales_order_line__c> lslmap {get; set;}
    private Id salesOrderId;
    public acctseederp__sales_order__c so {get; set;}
    
    public String WarningMessage {get; set;}
    
    public Integer totalitems {get; set;}
    public Integer compatibleItems {get; set;}
    public Integer totalitemsAggr {get;set;}
    
    public set<Id> AllSalesOrderId {get; set;}
    
    public Boolean aggregateCheck {get{
        
        if(aggregateCheck == null){
            
            AggregateCheck = true;
        }
        return AggregateCheck;
        
    } set;}
    
    // Sales Order Lines
    // private Set<Id> SalesOrderLineIds = new Set<Id>();
    private List<AcctSeedERP__Sales_Order_Line__c> SalesOrderLineItems = new List<AcctSeedERP__Sales_Order_Line__c>();
    
    public AcctSeed__Billing_Format__c PurchaseOrderFormat {get; set;}
    
    public map<id, AcctSeedERP__Sales_Order_Line__c> linesMap {get; set;}
    
    public Boolean visible {
        
        get{
            
            return this.visible;
        }
        set;
    }
    public boolean showdraft {get; set;}
    
    public void WarningMessageShow(){
        
        totalitems = [SELECT count() FROM AcctSeedERP__Sales_Order_Line__c WHERE 
                      AcctSeedERP__Sales_Order__c =:AllSalesOrderId];
        // incompatible items
        compatibleItems = [SELECT count() FROM AcctSeedERP__Sales_Order_Line__c 
                           WHERE AcctSeedERP__Sales_Order__c in:AllSalesOrderId AND 
                           AcctSeedERP__Purchase_Order_Line__c = null
                           AND IsAllocated__c != 1];
        
        if(compatibleItems < totalitems){
            // Show the error as Info message
            Integer leftItems = totalitems - compatibleItems;
            WarningMessage = leftItems + ' item(s) were not added. Please make sure:<br/>'+
                '<ul><li>The sales order lines must not be associated with existing purchase order lines.</li>'+
                '<li>The sales order lines must not be allocated.</li>';
        }
    }
    
    public CreatePOFromMultipleSOController() {
        showdraft = false;
        visible = false;
        Drafting = new list<CreateDraft>();
        PurchaseOrderFormat = null;
        // salesOrderId = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'));
        // salesOrderId = std.getId();
        // get the sales order
        /* Get the id in the url of all selected sales orders Sales Orders */
        integer count = Integer.valueOf(ApexPages.currentPage().getParameters().get('count'));
        
        AllSalesOrderId = new set<Id>();
        
        for(integer i = 0; i < count; i++){
            Id sub = Id.ValueOf(ApexPages.currentPage().getParameters().get('id' + i));
            AllSalesOrderId.add(sub);
        }
        
        system.debug('All the selected sales orders are:');
        system.debug(AllSalesOrderId);
        system.debug(AllSalesOrderId.size());
        
        WarningMessageShow();
        PurchaseOrderFormat = [SELECT Id, Name FROM AcctSeed__Billing_Format__c where name ='Default Purchase Order'];
        
        
        fetchAggregate();
        //fetchAll();
        
    }
    public void fetchAll(){
        
        WarningMessageShow();
        
        SalesOrderLineItems.clear();
        
        SalesOrderLineItems = [SELECT Id, Name, AcctSeedERP__Product__r.Name,AcctSeedERP__Unit_Price__c,
                               AcctSeedERP__Product__r.Description,AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c,
                               AcctSeedERP__Comment__c, AcctSeedERP__Product__c, AcctSeedERP_Description__c,SortOrder__c,
                               AcctSeedERP__Product__r.AcctSeed__Unit_Cost__c, size__c, Quantity_Allocated_formula__c,
                               Quantity_Shipped_Formula__c,AcctSeedERP__Quantity_Ordered__c,AcctSeedERP__Quantity_Needed__c,
                               acctseederp__total__c, productcode__c,AcctSeedERP__Sales_Order__c,
                               AcctSeederp__GL_Account_Variable_1__c,AcctSeedERP__Sales_Order__r.customer_s_eta__c, 
                               AcctSeederp__GL_Account_Variable_2__c,AcctSeedERP__Sales_Order__r.AcctSeedERP__Ledger__c, 
                               AcctSeederp__GL_Account_Variable_3__c,Quantity_Needed_Formula__c, 
                               AcctSeederp__GL_Account_Variable_4__c,Available_Quantity__c
                               FROM AcctSeedERP__Sales_Order_Line__c 
                               WHERE AcctSeedERP__Sales_Order__c in:AllSalesOrderId AND 
                               AcctSeedERP__Purchase_Order_Line__c = null
                               AND IsAllocated__c != 1 order by AcctSeedERP__Product__r.Name asc];
        
        if(SalesOrderLineItems.size() > 0){
            
            system.debug('Size = ' + SalesOrderLineItems.size());
            SalesOrderLinesListing = new list<ListSalesOrderLines>();
            
            for(AcctSeedERP__Sales_Order_Line__c sol : SalesOrderLineItems){
                
                SalesOrderLinesListing.add(new ListSalesOrderLines(sol, new Product2(AcctSeedERP__Default_Vendor__c = sol.AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c)));
                // sol.do_not_delete__c = sol.AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c;
                
            }
            visible = true; 
            
        }else{          
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'To create a purchase order:<br/>'+
                                                       '<ul><li>The sales order lines must not be associated with existing purchase order lines.</li>'+
                                                       '<li>The sales order lines must not be allocated.</li>'));
            
        }
    }
    public void fetchAggregate(){
        WarningMessageShow();
        
        list<AcctSeedERP__Sales_Order_Line__c> lines = new list<AcctSeedERP__Sales_Order_Line__c>();
        
        
        lines = [SELECT Id, Name, AcctSeedERP__Product__r.Name, AcctSeedERP__Product__r.ProductCode,AcctSeedERP__Unit_Price__c,
                 AcctSeedERP__Product__r.Description,AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c,
                 AcctSeedERP__Comment__c, AcctSeedERP__Product__c, AcctSeedERP_Description__c,SortOrder__c,
                 AcctSeedERP__Product__r.AcctSeed__Unit_Cost__c, size__c, Quantity_Allocated_formula__c,
                 Quantity_Shipped_Formula__c,AcctSeedERP__Quantity_Ordered__c,AcctSeedERP__Quantity_Needed__c,
                 acctseederp__total__c, productcode__c,AcctSeedERP__Sales_Order__c,
                 AcctSeederp__GL_Account_Variable_1__c,AcctSeedERP__Sales_Order__r.customer_s_eta__c, 
                 AcctSeederp__GL_Account_Variable_2__c,AcctSeedERP__Sales_Order__r.AcctSeedERP__Ledger__c, 
                 AcctSeederp__GL_Account_Variable_3__c,Quantity_Needed_Formula__c,Available_Quantity__c, 
                 AcctSeederp__GL_Account_Variable_4__c
                 FROM AcctSeedERP__Sales_Order_Line__c 
                 WHERE AcctSeedERP__Sales_Order__c in:AllSalesOrderId AND AcctSeedERP__Purchase_Order_Line__c = null
                 AND IsAllocated__c != 1 
                 order by AcctSeedERP__Product__r.Name asc];
                 
        
        // group by size__c/item description/product code
        // UniqueMap contains one item for each products where productName/size/itemDescrption/productcode are same
        // and all other lines which are unique or do not have a match at all
        map<string, AcctSeedERP__Sales_Order_Line__c> UniqueMap = new map<string, AcctSeedERP__Sales_Order_Line__c>();
        
        for(AcctSeedERP__Sales_Order_Line__c item : lines){
            
            String key = ((item.AcctSeedERP__Product__r.Name != null) ? item.AcctSeedERP__Product__r.Name.deleteWhitespace() + '-':'') 
                    + ((item.Size__c != null) ? item.Size__c.deleteWhitespace() + '-':'') + 
                	((item.AcctSeedERP__Product__r.ProductCode != null) ? item.AcctSeedERP__Product__r.ProductCode.deleteWhitespace() + '-':'') 
                    + ((item.AcctSeedERP_Description__c != null) ? item.AcctSeedERP_Description__c.deleteWhitespace() : '');
            
            if(!UniqueMap.containsKey(key)){
                    UniqueMap.put(key, item);
            }
        }
        
        
        SalesOrderLinesListing = new list<ListSalesOrderLines>();
        if(lines.size() > 0){
            
            for(AcctSeedERP__Sales_Order_Line__c line : UniqueMap.values()){
                
                SalesOrderLinesListing.add(new ListSalesOrderLines(line, 
                                                                   new Product2(AcctSeedERP__Default_Vendor__c 
                                                                                = line.AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c)));
                
            }
            visible = true;
            
        }
    }
    /*******************************************************************
* 						Insert Purchase Orders to get their id     *
*******************************************************************/
    
    private Map<Id, AcctSeedERP__Purchase_Order__c> InsertPurchaseOrders() {
        
        // vendor key and purchase order
        Map<Id, AcctSeedERP__Purchase_Order__c> VendorKeyAndPurchaseOrder = new Map<Id, AcctSeedERP__Purchase_Order__c>();
        
        // purchase order
        list<AcctSeedERP__Purchase_Order__c> PurchaseOrderList = new list<AcctSeedERP__Purchase_Order__c>();
        
        for (CreateDraft d : Drafting) {
            
            String city = null;
            String street = null;
            string country = null;
            string postalcode = null;
            string state = null;
            string companyname = null;
            string contactname = null;
            
            list<Account> org = [SELECT Id, Name, billingStreet, billingCity, 
                                 billingState, billingPostalCode, billingCountry, contact_person__c 
                                 FROM Account where 
                                 id='0011I00000EYHFy'];// org default account
            
            if(Test.isRunningTest()){
                
                org = [SELECT Id, Name, billingStreet, billingCity, 
                                 billingState, billingPostalCode, billingCountry, contact_person__c 
                                 FROM Account Limit 1];
                
            }
            if(!org.isEmpty()){
  
                companyname = org[0].id;
                contactname = org[0].contact_person__c;
                city = org[0].billingcity;
                street = org[0].billingStreet;
                country = org[0].billingCountry;
                postalcode = org[0].billingPostalCode;
                state = org[0].billingState; 
            }
            
            d.PurchaseOrder.AcctSeedERP__Type__c = 'Standard';	// this is already set
            d.PurchaseOrder.AcctSeedERP__Shipping_City__c = city;
            d.PurchaseOrder.AcctSeedERP__Shipping_Company__c = companyname;
            d.PurchaseOrder.AcctSeedERP__Shipping_Contact__c = contactname;
            d.PurchaseOrder.AcctSeedERP__Shipping_Country__c = country;
            d.PurchaseOrder.AcctSeedERP__Shipping_Postal_Code__c = postalcode;
            d.PurchaseOrder.AcctSeedERP__Shipping_State__c = state;
            d.PurchaseOrder.AcctSeedERP__Shipping_Street__c = street;
            
            PurchaseOrderList.add(d.PurchaseOrder);
        }
        
        if(PurchaseOrderList.size() > 0) {
            insert PurchaseOrderList;
            
            for(AcctSeedERP__Purchase_Order__c PurchaseOrderWithId : PurchaseOrderList){
                VendorKeyAndPurchaseOrder.put(PurchaseOrderWithId.AcctSeedERP__Vendor__c, PurchaseOrderWithId);
            }
        }
        
        return VendorKeyAndPurchaseOrder;
    }
    
    private Map<Id, AcctSeedERP__Purchase_Order__c> MakePurchaseOrders() {
        
        Map<Id, AcctSeedERP__Purchase_Order__c> purchaseOrders = new Map<Id, AcctSeedERP__Purchase_Order__c>();
        
        for (ListSalesOrderLines wp : SalesOrderLinesListing) {
            if(wp.selected){
                if(!purchaseOrders.containsKey(wp.Product.AcctSeedERP__Default_Vendor__c)) {
                    id contactperson = null;
                    id accountperson = null;
                    // get the vendor's contact if it exists 
                    if(wp.Product.AcctSeedERP__Default_Vendor__c != null){
                        list<account> acctlist = [select id,contact_person__c 
                                                  from account where id=: wp.Product.AcctSeedERP__Default_Vendor__c limit 1];  
                        if(!acctlist.isempty()){
                            accountperson = acctlist[0].id;
                            contactperson = acctlist[0].contact_person__c;   
                        }
                    }
                    
                    purchaseOrders.put(wp.Product.AcctSeedERP__Default_Vendor__c,
                                       new AcctSeedERP__Purchase_Order__c(AcctSeedERP__Vendor__c = accountperson,
                                                                          AcctSeedERP__Vendor_Contact__c = contactperson,
                                                                          AcctSeedERP__Purchase_Order_Format__c = PurchaseOrderFormat.id,
                                                                          AcctSeedERP__Ledger__c = wp.SalesOrderLine.AcctSeedERP__Sales_Order__r.AcctSeedERP__Ledger__c,
                                                                          customer_s_eta__c = wp.SalesOrderLine.AcctSeedERP__Sales_Order__r.Customer_s_ETA__c
                                                                          //Sales_order__c = wp.SalesOrderLine.AcctSeedERP__Sales_Order__r.id
                                                                         ));
                }
            }
        }
        
        return purchaseOrders;
    }
    
    public PageReference back() {        
        Schema.DescribeSObjectResult result = AcctSeedERP__Sales_Order__c.SObjectType.getDescribe();
        PageReference retPage = new PageReference('/'+result.getKeyPrefix()+'?fcf=00B1I000005XY6w');
        retPage.setRedirect(true);
        return retPage;
    }
    
    public PageReference draft(){
        WarningMessageShow();
        Boolean VendorError = false;
        for (ListSalesOrderLines wp : SalesOrderLinesListing) {
            if(wp.selected){
                if(wp.Product.AcctSeedERP__Default_Vendor__c == null) {
                    
                    if(!VendorError) VendorError = true;
                    wp.Product.AcctSeedERP__Default_Vendor__c.addError('Vendor cannot be empty.');
                    
                }
            }
        }
        
        if(VendorError){
            return null;
        }
        
        Drafting = new list<CreateDraft>();
        Map<Id, AcctSeedERP__Purchase_Order__c> allOrders = this.MakePurchaseOrders();
        
        lslmap = new map<id, acctseederp__sales_order_line__c>();
        
        map<acctseederp__purchase_order__c, list<powrapper>> orderLinesMap = 
            new map<acctseederp__purchase_order__c, list<powrapper>>();
        
        for(id keyIs : allOrders.keyset()){
            
            list<powrapper> lineslist = new list<powrapper>();
            acctseederp__purchase_order__c order = new acctseederp__purchase_order__c();
            
            for(ListSalesOrderLines wp : SalesOrderLinesListing){
                if(wp.Product.AcctSeedERP__Default_Vendor__c == keyIs){
                    order = allOrders.get(wp.Product.AcctSeedERP__Default_Vendor__c);
                    if(wp.selected){
                        
                        AcctSeedERP__Sales_Order_Line__c newsol = new AcctSeedERP__Sales_Order_Line__c();
                        
                        Product2 prod = new Product2();
                        
                        prod.name = wp.SalesOrderLine.AcctSeedERP__Product__r.name;
                        prod.AcctSeed__Unit_Cost__c = wp.SalesOrderLine.AcctSeedERP__Product__r.AcctSeed__Unit_Cost__c;
                        prod.ProductCode = wp.SalesOrderLine.ProductCode__c;
                        
                        	//newsol.Id = wp.SalesOrderLine.id; 
                        	newsol.AcctSeedERP__Comment__c = wp.SalesOrderLine.AcctSeedERP__Comment__c; 
                            newsol.AcctSeedERP__GL_Account_Variable_1__c = wp.SalesOrderLine.AcctSeedERP__GL_Account_Variable_1__c; 
                            newsol.AcctSeedERP__GL_Account_Variable_2__c = wp.SalesOrderLine.AcctSeedERP__GL_Account_Variable_2__c; 
                            newsol.AcctSeedERP__GL_Account_Variable_3__c = wp.SalesOrderLine.AcctSeedERP__GL_Account_Variable_3__c; 
                            newsol.AcctSeedERP__GL_Account_Variable_4__c = wp.SalesOrderLine.AcctSeedERP__GL_Account_Variable_4__c; 
                            newsol.AcctSeedERP__Product__c = wp.SalesOrderLine.AcctSeedERP__Product__c;  
                            newsol.AcctSeedERP__Unit_Price__c = wp.SalesOrderLine.AcctSeedERP__Unit_Price__c; 
                            newsol.AcctSeedERP__Quantity_Ordered__c = wp.SalesOrderLine.AcctSeedERP__Quantity_Needed__c;
                            newsol.AcctSeedERP_Description__c = wp.SalesOrderLine.AcctSeedERP_Description__c; 
                            newsol.Size__c = wp.SalesOrderLine.Size__c; 
                            newsol.SortOrder__c = wp.SalesOrderLine.SortOrder__c;
                        
                        lslmap.put(wp.SalesOrderLine.id, wp.SalesOrderLine);
                        
                       
                       lineslist.add(new powrapper(newsol, wp.SalesOrderLine.id, prod,wp.SalesOrderLine.Quantity_Shipped_Formula__c, 
                                     wp.SalesOrderLine.Quantity_Allocated_Formula__c,
                                    wp.SalesOrderLine.Quantity_Needed_Formula__c, wp.SalesOrderLine.Available_Quantity__c)); 
                                    
                    }
                }
                
            }
            orderLinesMap.put(order , lineslist);
        }
        
        Drafting = new list<CreateDraft>();
        
        if(!orderLinesMap.IsEmpty()){
            
            // create list of CreateDraft
            for(AcctSeedERP__Purchase_Order__c pr : allOrders.values()){
                account acct = null;
                acct = [select name from account where id =: pr.AcctSeedERP__Vendor__c];
                
                // get the purchase order from the map along with the list of sales order lines
                list<powrapper> listIs = orderLinesMap.get(pr);
                
                if(listIs == null) continue;
                
                Drafting.add(new CreateDraft(pr, listIs, acct.name));
            }
            
            showdraft = true;
        }
        return null;
    }
    public PageReference create() {
        WarningMessageShow();
        PageReference retPage = null;
        try{
            Boolean QuantityError = false;
            for(CreateDraft wpd: Drafting) {
                for(powrapper powl : wpd.plw){
                    if(powl.lsline.AcctSeedERP__Quantity_Ordered__c > powl.needed){
                        powl.lsline.AcctSeedERP__Quantity_Ordered__c.addError(
                            'Quantity can not be more than Quantity needed.');
                        if(!QuantityError) QuantityError = true;
                        // break;
                    }
                }
            }
            
            if(QuantityError){
                return null;
            }
            
            //create purchase orders;
            Map<Id, AcctSeedERP__Purchase_Order__c> purchaseOrderMap = this.InsertPurchaseOrders();
            
            List<AcctSeedERP__Purchase_Order__c> MapValues = purchaseOrderMap.values();
            
            if(purchaseOrderMap.size() == 1){
                retPage = new PageReference('/' + MapValues[0].id);
                retPage.setRedirect(true); 
                
            }else{
                
                String PurchaseOrderIdString = '';
                
                integer k = 0;
                for(AcctSeedERP__Purchase_Order__c orders : MapValues){
                    
                    PurchaseOrderIdString += '&id' + k + '=' + orders.id;
                    k++;
                    
                }
                
                retPage = new PageReference('/apex/NewPurchaseOrdersPage?sfdc.tabName=01r1I000000QsNf&count=' +purchaseOrderMap.size()+ '' + PurchaseOrderIdString);
                retPage.setRedirect(true);
            }
            if(purchaseOrderMap.size() > 0) {
                
                List <AcctSeedERP__Purchase_Order_Line__c> purchaseOrderLines = new List <AcctSeedERP__Purchase_Order_Line__c>();
                list<acctseederp__sales_order_line__c> SalesOrderLineListFORids
                    = new list<acctseederp__sales_order_line__c>();
                AcctSeedERP__Purchase_Order__c temPurchaseOrder = null;
                
                for(CreateDraft wpd: Drafting) {
                    account acct = null;
                    acct = [select id from account where name =:wpd.Vendor limit 1];
                    
                    if(acct != null){
                        temPurchaseOrder = purchaseOrderMap.get(acct.id);
                    }
                    Integer sortNumber = 1;
                    for(powrapper powr : wpd.plw){

                        AcctSeedERP__Purchase_Order_Line__c pol = new AcctSeedERP__Purchase_Order_Line__c(AcctSeedERP__Comment__c = powr.lsline.AcctSeedERP__Comment__c,
                                                                                                          Description__c = powr.lsline.AcctSeedERP_Description__c,
                                                                                                          AcctSeedERP__Product__c = powr.lsline.AcctSeedERP__Product__c,
                                                                                                          AcctSeedERP__Quantity__c = powr.lsline.AcctSeedERP__Quantity_Ordered__c,
                                                                                                          Sort_Order__c = sortNumber,
                                                                                                          AcctSeedERP__Unit_Price__c = powr.product.AcctSeed__Unit_Cost__c,
                                                                                                          AcctSeedERP__Purchase_Order__c = temPurchaseOrder.Id,
                                                                                                          size__c = powr.lsline.Size__c,
                                                                                                          AcctSeederp__GL_Account_Variable_1__c = powr.lsline.AcctSeederp__GL_Account_Variable_1__c, 
                                                                                                          AcctSeederp__GL_Account_Variable_2__c = powr.lsline.AcctSeederp__GL_Account_Variable_2__c, 
                                                                                                          AcctSeederp__GL_Account_Variable_3__c = powr.lsline.AcctSeederp__GL_Account_Variable_3__c, 
                                                                                                          AcctSeederp__GL_Account_Variable_4__c = powr.lsline.AcctSeederp__GL_Account_Variable_4__c
                                                                                                         );
                        purchaseOrderLines.add(pol);
                        acctseederp__sales_order_line__c lslinetemp = lslmap.get(powr.soid);
                        
                        if(lslinetemp == null) continue;
                        
                        SalesOrderLineListFORids.add(lslinetemp);
                        sortNumber++;
                    }
                }
                if(purchaseOrderLines.size() > 0){                    
                    insert purchaseOrderLines; 
                    
                    // update sales order line
                    // get all the sales order lines from the list Drafting
                    list<acctseederp__sales_order_line__c> sl = new list<acctseederp__sales_order_line__c>();
                    map<id,acctseederp__sales_order_line__c> slMap = new map<id,acctseederp__sales_order_line__c>();
                    
                    for(Integer i=0; i<purchaseOrderLines.size(); i++){
                        
                        SalesOrderLineListFORids[i].AcctSeedERP__Purchase_Order_Line__c = purchaseOrderLines[i].Id;
                        
                        sl.add(SalesOrderLineListFORids[i]);
                        slMap.put(SalesOrderLineListFORids[i].id, SalesOrderLineListFORids[i]);
                    }
                    
                    //update selSalesOrderLineItems;  
                    updateSalesOrderLines(JSON.serialize(sl));                                      
                    
                }
            }
            
        }catch(Exception exc){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, exc.getMessage()));            
            system.debug(exc.getMessage());
        }
        return retPage;
    }
    
    //updating purchase order line Id on sales order line
    @future
    public static void updateSalesOrderLines(String paramList) {
        List<AcctSeedERP__Sales_Order_Line__c> salesOrderLineItems = (List<AcctSeedERP__Sales_Order_Line__c>)JSON.deserialize(paramList, List<AcctSeedERP__Sales_Order_Line__c>.class);
        update salesOrderLineItems;
        
    }
    
    public class ListSalesOrderLines{
        
        public acctseederp__sales_order_line__c SalesOrderLine {get; set;}
        public product2 Product {get;set;}
        public Boolean selected {get;set;}
        
        ListSalesOrderLines(acctseederp__sales_order_line__c s, product2 p){
            
            SalesOrderLine = s;
            Product = p;
            selected = true;
        }
    }
    public class CreateDraft{
        
        public acctseederp__purchase_order__c PurchaseOrder {get; set;}
        public list<powrapper> plw {get; set;}
        public string Vendor {get; set;}
        
        CreateDraft(acctseederp__purchase_order__c p, list<powrapper> s, string v){
            
            PurchaseOrder = p;
            plw = s;
            Vendor = v;
        }
    }
    
     public class powrapper {
        
        public AcctSeedERP__Sales_Order_Line__c lsline {get; set;}
        public id soid {get; set;}
        public Product2 product {get; set;}
        public Decimal shipped {get; set;}
        public Decimal allocated {get; set;}
        public Decimal needed {get; set;}
        public Decimal stock {get; set;}
        
        powrapper(AcctSeedERP__Sales_Order_Line__c s, id sid, Product2 p, Decimal spd, Decimal all, Decimal ned, Decimal stk){
            
            lsline = s;
            soid = sid;
            product = p;
            shipped = spd;
            allocated = all;
            needed = ned;
            stock = stk;
        }
    }
    
    public void aggregateExecute(){
        if(AggregateCheck){
            fetchAggregate();
        }else{
            fetchAll();
        }
    }
}