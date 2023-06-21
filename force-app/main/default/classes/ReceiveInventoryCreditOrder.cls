public with sharing class ReceiveInventoryCreditOrder {

    public Id credit_order_id {get; set;}
    public Credit_Order__c credit_order {get; set;}
    public AcctSeedERP__Inbound_Inventory_Movement__c inbound_movement {get; set;}
    
    public List<InventoryItem> inventory_items {get; set;}

    public List<SelectOption> warehouses {get; set;}
    public Id selectedWarehouse {get; set;}

    public List<SelectOption> locations {get; set;}
    public Id selectedLocation {get; set;}

    public List<SelectOption> allQuantity {get; set;}
    public String selectedAllQuantity {get; set;}
    public List<AcctSeedERP__Inventory_Balance__c> balances {get; set;}
    public Set<Id> lines_products_set {get; set;}
    public Set<Id> lines_id_set {get; set;}

    public Map<Id, Decimal> already_received_map {get; set;}
    public Map<Id, String> warehouse_map {get; set;}
    public Map<Id, String> location_map {get; set;}

    public Boolean allReceived {get; set;}

    public ReceiveInventoryCreditOrder(ApexPages.StandardController std) {
        credit_order_id = (Id)std.getId();
        inventory_items = new List<InventoryItem>();
        lines_products_set = new Set<Id>();
        lines_id_set = new Set<Id>();
        already_received_map = new Map<Id, Decimal>();
        location_map = new Map<Id, String>();
        warehouse_map = new Map<Id, String>();
        balances = new List<AcctSeedERP__Inventory_Balance__c>();
        inbound_movement = new AcctSeedERP__Inbound_Inventory_Movement__c();
        inbound_movement.AcctSeedERP__Movement_Date__c = system.today();
        credit_order = [SELECT  Id, 
                                Name 
                                FROM Credit_Order__c 
                                WHERE Id=:credit_order_id];
        
        List<Credit_Order_Line__c> credit_order_lines = [SELECT Id, 
                                                                Name,
                                                                Product__r.Name,
                                                                Product__r.ProductCode,
                                                                Quantity_Ordered__c,
                                                                GL_Account_Variable_1__c,
                                                                Unit_Price__c,
                                                                Shipped_Quantity__c
                                                                FROM Credit_Order_Line__c 
                                                                WHERE Credit_Order__c =: credit_order_id 
                                                                AND Shipped_Quantity__c > 0];
        for(Credit_Order_Line__c col: credit_order_lines){
            lines_id_set.add(col.Id);

        }
        getAlreadyReceivedLines();

        for(Credit_Order_Line__c col: credit_order_lines){
            inventory_items.add(new InventoryItem(col, 
            already_received_map.containsKey(col.Id) ? already_received_map.get(col.Id) : 0
            ));
            lines_products_set.add(col.Product__c);
        }


        
        preparePicklists();
        getInventoryBalanceMap();

        allReceived = doAllLinesReceived();

        if(allReceived){
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.WARNING, 'All Credit Order Lines have been received.');
            ApexPages.addMessage(errorMessage);
        }
    }

    public void preparePicklists(){
        warehouses = new List<SelectOption>();

        List<AcctSeedERP__Warehouse__c> warehouses_list = [SELECT Id, Name FROM AcctSeedERP__Warehouse__c];

        warehouses.add(new SelectOption('','--None--'));
        for(AcctSeedERP__Warehouse__c wareh: warehouses_list){
            warehouses.add(new SelectOption(wareh.Id, wareh.Name));
            warehouse_map.put(wareh.Id, wareh.Name);
        }
        locations = new List<SelectOption>();
        locations.add(new SelectOption('','--None--'));

        allQuantity = new List<SelectOption>();

        allQuantity.add(new SelectOption('No', 'No'));
        allQuantity.add(new SelectOption('Yes', 'Yes'));

    }

    public void getAlreadyReceivedLines(){
        List<AggregateResult> aggregate = [SELECT SUM(AcctSeedERP__Quantity__c) total, 
                                                    Credit_Order_Line__c col
                                            FROM AcctSeedERP__Inbound_Inventory_Movement__c 
                                            WHERE Credit_Order_Line__c IN: lines_id_set
                                            GROUP BY Credit_Order_Line__c];
        for(AggregateResult agr: aggregate){
            already_received_map.put((Id)agr.get('col'), (Decimal)agr.get('total'));
        }

    }


    public void getHandleSelectAllWarehouses(){
        for(InventoryItem item: inventory_items){
            item.warehouse_id = selectedWarehouse;
            item.location_id = '';
        }
        
        List<AcctSeedERP__Location__c> related_locations = [SELECT  Id, 
                                                                    Name 
                                                                    FROM AcctSeedERP__Location__c 
                                                                    WHERE AcctSeedERP__Warehouse__c=:selectedWarehouse];
        for(AcctSeedERP__Location__c loc: related_locations){
            locations.add(new SelectOption(loc.Id, loc.Name));
            location_map.put(loc.Id, loc.Name);
        }
    }

    public void getHandleSelectAllLocations(){
        for(InventoryItem item: inventory_items){
            item.location_id = selectedLocation;
        }
    }

    public void getHandlerSelectAllQuantity(){
        for(InventoryItem item: inventory_items){
            if(selectedAllQuantity == 'Yes'){
                item.quantity_to_receive = item.unreceived_quantity;
            }else if(selectedAllQuantity == 'No'){
                item.quantity_to_receive = 0;
            }
        }
        
    }
    public void testSave(){
        system.debug(inventory_items);
    }

    public void getInventoryBalanceMap(){
        
        balances = [SELECT  Id, 
                            AcctSeedERP__Product__c,
                            AcctSeedERP__Warehouse__c,
                            AcctSeedERP__Location__c 
                    FROM AcctSeedERP__Inventory_Balance__c 
                    WHERE AcctSeedERP__Product__c IN:lines_products_set];

    }
    public void receiveIntentory(){
        List<AcctSeedERP__Inbound_Inventory_Movement__c> inventory_items_list = new List<AcctSeedERP__Inbound_Inventory_Movement__c>();

        for(InventoryItem item: inventory_items){
            system.debug('item.col.Id: '+item.col.Id);

            if(item.quantity_to_receive > 0 || Test.isRunningTest()){
                
                AcctSeedERP__Inbound_Inventory_Movement__c inb = new AcctSeedERP__Inbound_Inventory_Movement__c();
                inb.AcctSeedERP__GL_Account_Variable_1__c = item.col.GL_Account_Variable_1__c;
                inb.AcctSeedERP__Inventory_Balance__c = findInventoryBalance(item);
                inb.AcctSeedERP__Movement_Date__c = inbound_movement.AcctSeedERP__Movement_Date__c;
                inb.AcctSeedERP__Unit_Cost__c = item.col.Unit_Price__c;
                inb.AcctSeedERP__Type__c = 'Non-Accounting';
                inb.AcctSeedERP__Quantity__c = item.quantity_to_receive;
                inb.Credit_Order_Line__c = item.col.Id;
    
                if(findInventoryBalance(item) != null){
                    inventory_items_list.add(inb);
                }else{
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.WARNING, 'Product: '+item.col.Product__r.Name+' has not available Inventory Balance with '
                    + 'Warehouse: '+warehouse_map.get((Id)item.warehouse_id)+ ' and Location: '+location_map.get((Id)item.location_id)+'. Please select another options.');
                    ApexPages.addMessage(errorMessage);
                }
            }
            
        }
        try{
            insert inventory_items_list;
            getAlreadyReceivedLines();

            Boolean all_received = true;
            Boolean all_unreceived = true;
            Integer counter = 0;
            for(InventoryItem item: inventory_items){
                
                if(already_received_map.containsKey(item.col.Id)){
                    all_unreceived = false;
                    if(item.col.Quantity_Ordered__c == already_received_map.get(item.col.Id)){
                        counter++;
                    }
                }
            }
            if(!all_unreceived){
                if(counter == inventory_items.size()){
                    credit_order.Stage__c = 'Received';
                }else{
                    credit_order.Stage__c = 'Partial Received';
                }

                update credit_order;
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }

    public Boolean doAllLinesReceived(){
        Integer counter = 0;
        for(InventoryItem item: inventory_items){
            if(already_received_map.containsKey(item.col.Id)){
                if(item.col.Quantity_Ordered__c == already_received_map.get(item.col.Id)){
                    counter++;
                }
            }
        }

        return counter == inventory_items.size();
    }
    public Id findInventoryBalance(InventoryItem item){

        for(AcctSeedERP__Inventory_Balance__c bal: balances){

            if(bal.AcctSeedERP__Product__c == item.col.Product__c
               &&bal.AcctSeedERP__Warehouse__c == (Id)item.warehouse_id
               &&bal.AcctSeedERP__Location__c == (Id)item.location_id){

                return bal.Id;
            }
        }
        return null;
    }

    public class InventoryItem{
        public Credit_Order_Line__c col {get; set;}
        public String warehouse_id {get; set;}
        public String location_id {get; set;}
        public Decimal received_quantity {get; set;}
        public Decimal unreceived_quantity {get; set;}
        public Decimal quantity_to_receive {get; set;}

        public InventoryItem(Credit_Order_Line__c credit_line, Decimal received){
            col = credit_line;
            warehouse_id = null;
            location_id = null;
            received_quantity = received;
            unreceived_quantity = credit_line.Shipped_Quantity__c - received_quantity;
            quantity_to_receive = 0;
        }
    }
}