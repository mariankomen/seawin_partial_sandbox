trigger RollupBillingReceivedPaySOTrigger on AcctSeed__Billing__c (after insert, after update, before delete) {
    
    //if(!Test.isRunningTest()){



        if(trigger.IsAfter){
            if(Trigger.IsInsert || Trigger.IsUpdate){
                RollupBillingReceivedPaySOHandler.rollup(Trigger.new);
                BillingBatchTrigger batch = new BillingBatchTrigger(Trigger.new);

                if(!Test.isRunningTest()){ Database.executeBatch(batch, 1);
                } else { Database.executeBatch(batch); }
                
            }
        }
    
        if(trigger.isBefore && Trigger.IsDelete){
            
            if(trigger.old[0].AcctSeedERP__Sales_Order__c != null){
                AcctSeedERP__Sales_Order__c so = [SELECT Id, Billing_Balances__c FROM AcctSeedERP__Sales_Order__c WHERE Id=:trigger.old[0].AcctSeedERP__Sales_Order__c];
                if(trigger.old[0].AcctSeed__Type__c == 'Invoice'){
                    so.Billing_Balances__c = so.Billing_Balances__c - trigger.old[0].AcctSeed__Balance__c;
                    update so;
                }
            }//Add logic for Opp
            if(trigger.old[0].AcctSeed__Opportunity__c != null){
                Opportunity op = [SELECT Id, Billing_Balances__c, Run_Validation_Rule__c FROM Opportunity WHERE Id=:trigger.old[0].AcctSeed__Opportunity__c];
                if(trigger.old[0].AcctSeed__Type__c == 'Invoice' ){
                    op.Run_Validation_Rule__c = true;
                    update op;
                    List<AcctSeed__Billing__c> bills = [SELECT Id, AcctSeed__Balance__c, AcctSeedERP__Sales_Order__c FROM AcctSeed__Billing__c WHERE AcctSeed__Type__c = 'Invoice' AND AcctSeed__Opportunity__c =: op.Id];
                    Decimal amount = 0.00;
                    for(AcctSeed__Billing__c b:bills){
                        amount+=b.AcctSeed__Balance__c;
                    }
                    system.debug('amount: '+amount);
                    system.debug('trigger.old[0].AcctSeed__Balance__c'+trigger.old[0].AcctSeed__Balance__c);
                    op.Billing_Balances__c = amount - trigger.old[0].AcctSeed__Balance__c;
                    update op;
                    //op.Run_Validation_Rule__c = false;
                    //update op;
                }
            }
        }
        // }
}