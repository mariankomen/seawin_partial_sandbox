public with sharing class AccountTriggerHandler {
    
    public static void beforeDeleteHandler(List<Account> accounts){
        beforeDeleteCheckAvailabilityForDelete(accounts);
    }

    /*****************************************************************************************************
    *   @method       : beforeDeleteCheckAvailabilityForDelete
    *   @description  : executes in trigger before delete. Used for preventing deleting accounts if it has related Opp, SO or Billing records OR if Account tried to delete not Sys Admin
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public static void beforeDeleteCheckAvailabilityForDelete(List<Account> deletableAccounts){
        try{
            User u = [SELECT Id, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
            
            List<Opportunity> oppotunities = [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN:deletableAccounts LIMIT 50000];
            List<AcctSeedERP__Sales_Order__c> salesOrders = [SELECT Id, AcctSeedERP__Customer__c FROM AcctSeedERP__Sales_Order__c WHERE AcctSeedERP__Customer__c IN:deletableAccounts LIMIT 50000];
            List<AcctSeed__Billing__c> billings = [SELECT Id, AcctSeed__Customer__c FROM AcctSeed__Billing__c WHERE AcctSeed__Customer__c IN:deletableAccounts LIMIT 50000];

            
            Map<String, SObject> oppotunitiesMap = makeMapFromListSobjects(oppotunities, 'AccountId');
            Map<String, SObject> salesOrdersMap = makeMapFromListSobjects(salesOrders, 'AcctSeedERP__Customer__c');
            Map<String, SObject> billingsMap = makeMapFromListSobjects(billings, 'AcctSeed__Customer__c');

            for(Account acc: deletableAccounts){
                if(u.Profile.Name != 'System Administrator'){
                    acc.addError('Insuffiend permission. Delete Account permission allowed only for System Administrator.');
                }else if(oppotunitiesMap.containsKey(acc.Id) || salesOrdersMap.containsKey(acc.Id) || billingsMap.containsKey(acc.Id)){
                    acc.addError('Can not delete Account with related Opportunity, Sales Order or Billing records.');
                }
            }

        }catch(Exception e){
            system.debug('Error in AccountTriggerHandler.beforeDeleteCheckAvailabilityForDelete: '+e.getMessage());
        }
    }

    public static Map<String, SObject> makeMapFromListSobjects(List<SObject> sobjects, String mapKey){
        Map<String, SObject> combinedMap = new Map<String, SObject>();

        for(SObject sobj: sobjects){
            combinedMap.put(String.valueOf(sobj.get(mapKey)), sobj);
        }

        return combinedMap;
    }
}