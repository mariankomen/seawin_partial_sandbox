public with sharing class AllocateCreditOrderLineController {

    public Id recordId {get; set;}
    public Credit_Order__c credit_order {get; set;}
    public List<Credit_Order_Line__c> credit_order_lines {get; set;}
    public List<LineWrapper> wrapper_lines {get; set;}
    public Map<Id, Id> inventory_relation {get; set;}

    public AllocateCreditOrderLineController() {
        recordId = Apexpages.currentpage().getparameters().get('id');
        wrapper_lines = new List<LineWrapper>();
        Set<Id> sol_ids = new Set<Id>();
        inventory_relation = new Map<Id,Id>();
        credit_order = [SELECT Id, 
                                Name, 
                                Ledger__c, 
                                Customer__c, 
                                Sales_Order__c, 
                                Customer_s_ETA__c 
                                FROM Credit_Order__c 
                                WHERE Id=:recordId];

        credit_order.Customer_s_ETA__c = system.today();
        //Customer_s_ETA__c this field use only for showing date picker, will be mapped later

        credit_order_lines = [SELECT Id,
                                    Name,
                                    Product__c, 
                                    Product__r.Name,
                                    Product__r.ProductCode,
                                    Description__c,
                                    Quantity_Needed__c,
                                    Quantity_Ordered__c,
                                    GL_Account_Variable_1__c,
                                    Allocated_Quantity__c,
                                    Sales_Order_Line__c,
                                    Sales_Order_Line__r.AcctSeedERP__Quantity_Allocated__c,
                                    Sales_Order_Line__r.Name,
                                    Unit_Price__c
                                    FROM Credit_Order_Line__c 
                                    WHERE Credit_Order__c =: credit_order.Id];

        for(Credit_Order_Line__c col: credit_order_lines){
            wrapper_lines.add(new LineWrapper(col));
            sol_ids.add(col.Sales_Order_Line__c);
        }
        prepareInventoryMap(sol_ids);
    }

    public void prepareInventoryMap(Set<id> sol_ids){
        List<AcctSeedERP__Sales_Order_Inventory_Movement__c> so_movements = [SELECT Id, 
                                                                                    AcctSeedERP__Inventory_Balance__c, 
                                                                                    AcctSeedERP__Sales_Order_Line__c 
                                                                                FROM AcctSeedERP__Sales_Order_Inventory_Movement__c 
                                                                                WHERE AcctSeedERP__Sales_Order_Line__c IN:sol_ids
                                                                            ];
        for(AcctSeedERP__Sales_Order_Inventory_Movement__c sim: so_movements){
            inventory_relation.put(sim.AcctSeedERP__Sales_Order_Line__c, sim.AcctSeedERP__Inventory_Balance__c);
        } 
    }
    public void main_save(){
        List<Credit_Order_Inventory_Movement__c> movements = new List<Credit_Order_Inventory_Movement__c>();

        for(LineWrapper lw:wrapper_lines){
            if(lw.allocate > 0){
                movements.add(inventory_move(lw.col, lw.allocate));
            }
        }
        insert movements;
    }

    public Credit_Order_Inventory_Movement__c inventory_move(Credit_Order_Line__c line, Decimal quan){
        Credit_Order_Inventory_Movement__c cim = new Credit_Order_Inventory_Movement__c();
        cim.Credit_Order_Line__c = line.Id;
        cim.GL_Account_Variable_1__c = line.GL_Account_Variable_1__c;
        cim.Inventory_Quantity_Available__c = inventory_relation.get(line.Sales_Order_Line__c);
        cim.Movement_Date__c = system.today();
        cim.ProductId__c = line.Product__c;
        cim.Quantity__c = quan;
        cim.Unit_Cost__c = line.Unit_Price__c;
        return cim;
    }


    public PageReference save_refresh(){
        main_save();
        return null;
    }
    public PageReference save_complete(){
        main_save();
        PageReference ref = new PageReference('/'+credit_order.Id);
        return ref;
    }
    public class LineWrapper{
        public Credit_Order_Line__c col {get;set;}
        public Decimal allocate {get;set;}
        public Decimal available {get;set;}

        public LineWrapper(Credit_Order_Line__c cred_line){
            col = cred_line;
            allocate = 0;
            available = col.Sales_Order_Line__r.AcctSeedERP__Quantity_Allocated__c - (col.Allocated_Quantity__c != null ? col.Allocated_Quantity__c : 0);
        }
    }
}