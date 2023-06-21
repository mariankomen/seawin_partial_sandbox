public with sharing class PurchaseOrderLineHandler {


    public static void beforeUpdateHandler(Map<Id, AcctSeedERP__Purchase_Order_Line__c> trigger_old, Map<Id, AcctSeedERP__Purchase_Order_Line__c> trigger_new){

        List<AcctSeed__Account_Payable_Line__c> payable_lines = [SELECT Id, 
                                                                        AcctSeedERP__Purchase_Order_Line__c 
                                                                FROM AcctSeed__Account_Payable_Line__c 
                                                                WHERE AcctSeedERP__Purchase_Order_Line__c IN: trigger_new.keySet()];

        Map<Id, Id> payable_pol = new Map<Id, Id>();
        for(AcctSeed__Account_Payable_Line__c apl: payable_lines){
            payable_pol.put(apl.AcctSeedERP__Purchase_Order_Line__c, apl.Id);
        }

        for(Id pol: trigger_new.keySet()){
            AcctSeedERP__Purchase_Order_Line__c old_pol = trigger_old.get(pol);
            AcctSeedERP__Purchase_Order_Line__c new_pol = trigger_new.get(pol);
            if((old_pol.AcctSeedERP__Unit_Price__c != new_pol.AcctSeedERP__Unit_Price__c
               || old_pol.AcctSeedERP__Quantity__c != new_pol.AcctSeedERP__Quantity__c) && payable_pol.containsKey(pol)){
                    trigger_new.get(pol).addError('Price or Quantity cannot be changed, because payable exists.	');
               }
            // AcctSeedERP__Unit_Price__c
        }
    }




    public static void UpdateFields(List<AcctSeedERP__Purchase_Order_Line__c> POLines){
        /*
        set<Id> poIds = new Set<Id>();
        for(AcctSeedERP__Purchase_Order_Line__c po : POLines){
            
            poIds.add(po.id);
            
        }
        //FinallyUpdate(poIds);
        //*/
    }
    /*
    @future
    public static void FinallyUpdate(set<Id> poIds){
        if(!poIds.IsEmpty()){
            
            // fetch the associated SOLines
            List<AcctSeedERP__Sales_Order_Line__c> solist = [select id, AcctSeedERP__Unit_Price__c, AcctSeedERP__Purchase_Order_Line__c, AcctSeedERP__Quantity_Ordered__c, AcctSeedERP_Description__c, AcctSeedERP__Total__c from AcctSeedERP__Sales_Order_Line__c where AcctSeedERP__Purchase_Order_Line__c in:poIds];
            map<Id, AcctSeedERP__Sales_Order_Line__c> SOLines = new map<Id, AcctSeedERP__Sales_Order_Line__c>();
            
            if(!solist.isEmpty()){
                
                for(AcctSeedERP__Sales_Order_Line__c sol : solist){
                    
                    SOLines.put(sol.AcctSeedERP__Purchase_Order_Line__c, sol);
                    
                }
                
                // get the polines
                
                List<AcctSeedERP__Purchase_Order_Line__c> pollist = [select id, AcctSeedERP__Unit_Price__c, AcctSeedERP__Quantity__c, AcctSeedERP__Total__c, Description__c from AcctSeedERP__Purchase_Order_Line__c where id in:poIds];
                
                if(!pollist.IsEmpty()){
                    for(AcctSeedERP__Purchase_Order_Line__c po : pollist){
                        
                        AcctSeedERP__Sales_Order_Line__c soline = SOLines.get(po.id);
                        
                        if(soline == null) continue;
                        
                        po.AcctSeedERP__Quantity__c = soline.AcctSeedERP__Quantity_Ordered__c;
                        po.AcctSeedERP__Unit_Price__c = soline.AcctSeedERP__Unit_Price__c;
                        po.Description__c = soline.AcctSeedERP_Description__c;
                        
                    }
                     	update pollist;   
                }
            }
        }
    }
*/
}