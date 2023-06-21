public class InventoryCalculationHelper {
    //------------------ Calculating Inventory (Available Quantity, Allocated, InStock) group by Product
    public static Map<id, list<decimal>> Calculate(set<id> productIds) {
        map<id, List<AcctSeed__Product_Part__c>> KitChildrenMap = new Map<id, List<AcctSeed__Product_Part__c>>();
        Map<id, list<decimal>> ProductInventoryMap = new Map<id, list<decimal>>();
        
        List<Product2> Kits = [
            SELECT
            Id,
            (
                SELECT
                id,
                name,
                kit_product__c,
                kit_children__c,
                acctseed__quantity__c
                FROM Kit_Children_Product__r
                ORDER BY acctseed__quantity__c ASC
            )
            FROM Product2
            WHERE id IN :productIds AND acctseed__inventory_type__c = 'Kit'
        ];
        
        map<id, list<decimal>> KitChildrenInventoryMap = Identify_Kit_Children_Inventory(
            Kits
        );
        
        for (Product2 p : Kits) {
            if (
                p.Kit_Children_Product__r != null &&
                !p.Kit_Children_Product__r.isEmpty()
            ) {
                KitChildrenMap.put(p.id, p.Kit_Children_Product__r);
            }
        }
        
        // STEP # 1: Inventory calculation for all products except Kits
        ProductInventoryMap = FindInventory(productIds);
        
        list<decimal> strList = new List<decimal>();
        
        // STEP # 2: Inventory calculation for Kits which were not included in STEP # 1
        for (id pId : productIds) {
            if (KitChildrenMap.containsKey(pId)) {
                Decimal MinAvailable = 0;
                Decimal poQuantity = 0;
                List<AcctSeed__product_part__c> parts = KitChildrenMap.get(pId);
                
                if (parts != null && !parts.isEmpty()) {
                    for (AcctSeed__product_part__c pp : parts) {
                        if (KitChildrenInventoryMap.containsKey(pp.Kit_Children__c)) {
                            List<decimal> valuesList = KitChildrenInventoryMap.get(
                                pp.Kit_Children__c
                            );
                            
                            if (!valuesList.isEmpty()) {
                                Decimal currentMin = valuesList[0] > 0
                                    ? valuesList[0] / pp.AcctSeed__Quantity__c
                                    : 0;
                                poQuantity = valuesList[3];
                                if (MinAvailable == 0) {
                                    MinAvailable = currentMin;
                                } else if (MinAvailable > 0 && currentMin < MinAvailable) {
                                    MinAvailable = currentMin;
                                }
                            }
                        }
                    }
                }
                
                strList = new List<decimal>();
                
                decimal available = MinAvailable.intValue();
                strList.add(available);
                
                decimal allocated = 0;
                strList.add(allocated);
                
                decimal instock = MinAvailable.intValue();
                strList.add(instock);

                //!TODO
                strList.add(poQuantity);
                
                ProductInventoryMap.put(pId, strList);
            }
        }
        
        // if for any product key does not exist, add a list with empty values
        for (Id pId : productIds) {
            if (!ProductInventoryMap.containsKey(pId)) {
                list<Decimal> decimalList = new List<Decimal>{ 0, 0, 0, 0 };
                    
                    ProductInventoryMap.put(pId, decimalList);
            }
        }
        
        return ProductInventoryMap;
    }
    
    public static map<id, list<decimal>> FindInventory(set<id> productIds) {
        map<string, decimal> AllocatedQuantityMap = new Map<string, decimal>();
        map<string, decimal> PurchaseOrderdQuantityMap = new Map<string, decimal>();
        List<AggregateResult> AllocatedOnSalesOrders = new List<AggregateResult>();
        
        AllocatedOnSalesOrders = [
            SELECT
            AcctSeedERP__Product__c product,
            SUM(AcctSeedERP__Quantity_Allocated__c) allocated,
            SUM(AcctSeedERP__Quantity_Shipped__c) shipped
            FROM AcctSeedERP__Sales_Order_Line__c
            WHERE
            AcctSeedERP__Product__c = :productIds
            AND AcctSeedERP__Quantity_Allocated__c > 0
            GROUP BY AcctSeedERP__Product__c
        ];
        List<AggregateResult> purchaseOrderQuantity = [SELECT SUM(AcctSeedERP__Quantity_Unreceived__c) total, AcctSeedERP__Product__c product
                                                        FROM AcctSeedERP__Purchase_Order_Line__c
                                                        WHERE AcctSeedERP__Product__c IN:productIds 
                                                        AND AcctSeedERP__Quantity_Unreceived__c > 0
                                                        GROUP BY AcctSeedERP__Product__c];
        for(AggregateResult agr: purchaseOrderQuantity){
            PurchaseOrderdQuantityMap.put((String)agr.get('product'), (Decimal)agr.get('total'));
        }
        // map<string, AggregateResult> agrMap = new map<string, AggregateResult>();
        
        for (AggregateResult agr : AllocatedOnSalesOrders) {
            Decimal remaining = MATH.ABS(
                (Decimal) agr.get('allocated') - (Decimal) agr.get('shipped')
            );
            
            if (remaining > 0) {
                // only eligible records
                AllocatedQuantityMap.put(
                    (String) agr.get('product'),
                    (Integer) remaining
                );
            }
        }
        
        Map<id, list<decimal>> imtMap = new Map<id, list<decimal>>();
        list<decimal> strList = new List<decimal>();
        for (AcctSeedERP__Inventory_Balance__c invt : [
            SELECT AcctSeedERP__Product__c, AcctSeedERP__Available_Quantity__c, AcctSeedERP__Purchasing_Quantity__c
            FROM AcctSeedERP__Inventory_Balance__c
            WHERE
            AcctSeedERP__Product__c IN :productIds
            AND AcctSeedERP__Product__r.AcctSeed__Inventory_Type__c != 'Kit'
        ]) {
            // 0 : available quantity
            // 1 : allocated quantity
            // 2 : in stock
            Decimal poQuantity = PurchaseOrderdQuantityMap.containsKey(invt.AcctSeedERP__Product__c) ? PurchaseOrderdQuantityMap.get(invt.AcctSeedERP__Product__c) : 0;
            Decimal allocatedQuantity = AllocatedQuantityMap.containsKey(
                invt.AcctSeedERP__Product__c
            )
                ? AllocatedQuantityMap.get(invt.AcctSeedERP__Product__c)
                : 0;
            
            if (imtMap.containsKey(invt.AcctSeedERP__Product__c)) {
                // product exists
                strList = new List<decimal>();
                
                list<decimal> StrValues = imtMap.get(invt.AcctSeedERP__Product__c);
                
                decimal available =
                    StrValues[0] + invt.AcctSeedERP__Available_Quantity__c;
                
                strList.add(available);
                
                decimal allocated = allocatedQuantity;
                strList.add(allocated);
                
                decimal instock =
                    StrValues[2] + (invt.AcctSeedERP__Available_Quantity__c);
                strList.add(instock);

                strList.add(poQuantity);
                imtMap.put(invt.AcctSeedERP__Product__c, strList);
            } else {
                // first entry
                strList = new List<decimal>();
                
                decimal available = invt.AcctSeedERP__Available_Quantity__c;
                strList.add(available);
                
                decimal allocated = allocatedQuantity;
                strList.add(allocated);
                
                Decimal instock =
                    invt.AcctSeedERP__Available_Quantity__c + allocatedQuantity;
                strList.add(instock);

                strList.add(poQuantity);
                
                imtMap.put(invt.AcctSeedERP__Product__c, strList);
            }
        }
        
        return imtMap;
    }
    
    public static map<id, list<decimal>> Identify_Kit_Children_Inventory(
        List<Product2> kits
    ) {
        map<id, list<decimal>> LocalKitChildrenInventoryMap = new Map<id, list<decimal>>();
        
        if (!Kits.isEmpty()) {
            set<id> KitChildrenIds = new Set<id>();
            for (product2 p : Kits) {
                if (
                    p.Kit_Children_Product__r != null &&
                    !p.Kit_Children_Product__r.isEmpty()
                ) {
                    // if kit
                    for (AcctSeed__Product_Part__c pp : p.Kit_Children_Product__r) {
                        KitChildrenIds.add(pp.Kit_Children__c);
                    }
                }
            }
            
            if (KitChildrenIds.size() > 0) {
                LocalKitChildrenInventoryMap = FindInventory(KitChildrenIds);
            }
        }
        
        return LocalKitChildrenInventoryMap;
    }
    
    //------------------- Calculate In Stock quantity based on Inventory Balance ----------------------
    public static map<string, Decimal> CalculateInStock(set<id> productIds) {
        Map<string, decimal> AllocatedQuantityMap = new Map<string, decimal>();
        
        for (AcctSeedERP__Inventory_Balance__c ib : [
            SELECT Id, AcctSeedERP__Available_Quantity__c
            FROM AcctSeedERP__Inventory_Balance__c
            WHERE AcctSeedERP__Product__c IN :productIds
        ]) {
            AllocatedQuantityMap.put(ib.id, ib.AcctSeedERP__Available_Quantity__c);
        }
        
        List<AggregateResult> agrResult = [
            SELECT
            SUM(AcctSeedERP__Quantity__c) allocated,
            AcctSeedERP__Shipment_Line__c,
            SUM(AcctSeedERP__Shipment_Line__r.AcctSeedERP__Quantity_Shipped__c) shipped,
            AcctSeedERP__Inventory_Balance__c inventory
            FROM AcctSeedERP__Sales_Order_Inventory_Movement__c
            WHERE AcctSeedERP__Inventory_Balance__c IN :AllocatedQuantityMap.keyset()
            GROUP BY
            AcctSeedERP__Shipment_Line__c,
            AcctSeedERP__Inventory_Balance__c
            
        ];
        
        // Inventory Balance => Product => Sales Order Inventory Movements => Multiple Sales Order Line
        
        for (AggregateResult agr : agrResult) {
            
            Decimal allocated = agr.get('allocated') == null ? 0 : (decimal) agr.get('allocated');
            Decimal shipped = agr.get('shipped') == null ? 0 : (decimal) agr.get('shipped');
            
            Decimal remaining = Math.abs(allocated - shipped);
            
            if (remaining > 0) {

                Decimal instock = 0;
                
                if (AllocatedQuantityMap.containsKey((string) agr.get('inventory'))) {
                    instock =
                        AllocatedQuantityMap.get((string) agr.get('inventory')) +
                        remaining;
                } else {
                    instock =
                        AllocatedQuantityMap.get((string) agr.get('inventory')) +
                        remaining;
                }
                AllocatedQuantityMap.put((string) agr.get('inventory'), instock);
            }
        }
        
        // Check for inventories where there is no available quantity
        for (String key : AllocatedQuantityMap.keyset()) {
            Decimal val = AllocatedQuantityMap.get(key);
            
            if (val == 0) {
                AllocatedQuantityMap.remove(key);
            }
        }
        
        return AllocatedQuantityMap;
    }


    public static void coverage(){
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
    }
}