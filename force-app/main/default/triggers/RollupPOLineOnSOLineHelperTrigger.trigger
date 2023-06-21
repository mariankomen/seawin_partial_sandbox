trigger RollupPOLineOnSOLineHelperTrigger on AcctSeedERP__Purchase_Order__c (after delete, after undelete) {
    if(Trigger.IsAfter){
        if(Trigger.IsDelete){
            // get the po lines for the purchase order if any
            list<AcctSeedERP__Purchase_Order_Line__c> polines = [select id, Sales_Order_Line__c,
                                                                 AcctSeedERP__Purchase_Order__c from
                                                                 AcctSeedERP__Purchase_Order_Line__c where
                                                                 AcctSeedERP__Purchase_Order__c =:Trigger.oldMap.keyset() and 
                                                                 isdeleted = true ALL ROWS];
            
            system.debug('The lines are.');
            system.debug(polines);
            
            if(!polines.isEmpty()){
                
                RollupPOLineOnSOLineHandler.rollup(polines, 
                                                   Trigger.OperationType, true);
            }
            
            
        }else if(Trigger.IsUndelete){
            
            // get the po lines for the purchase order if any
            list<AcctSeedERP__Purchase_Order_Line__c> polines = [select id, Sales_Order_Line__c,
                                                                 AcctSeedERP__Purchase_Order__c from
                                                                 AcctSeedERP__Purchase_Order_Line__c where
                                                                 AcctSeedERP__Purchase_Order__c =:Trigger.newMap.keyset()];
            system.debug('The lines are.');
            system.debug(polines);
            if(!polines.isEmpty()){
                
                RollupPOLineOnSOLineHandler.rollup(polines, 
                                                   Trigger.OperationType, false);
            }
        }
    }
}