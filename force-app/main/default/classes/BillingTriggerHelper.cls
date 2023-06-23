/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 06-22-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class BillingTriggerHelper implements ITriggerHelper{
    
    public static void beforeInsert(List<sObject> newList) {
        System.debug('BillingTriggerHelper - beforeInsert');
    }
     
    public static void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        List<AcctSeed__Billing__c> triggerNewList = (List<AcctSeed__Billing__c>)newList;

        BillingHandler.Billing_Contact_Assignment(newMap.Keyset());
        RollupBillingReceivedOpptyHandler.rollup(triggerNewList);
        RollupBillingReceivedPaySOHandler.rollup(triggerNewList);
        rollupBillingFields(triggerNewList);
        sendEmailNotification(JSON.serialize(newList));
    }
     
    public static void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        System.debug('BillingTriggerHelper - beforeUpdate');
    }
     
    public static void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        List<AcctSeed__Billing__c> triggerNewList = (List<AcctSeed__Billing__c>)newList;
        RollupBillingReceivedOpptyHandler.rollup(triggerNewList);
        RollupBillingReceivedPaySOHandler.rollup(triggerNewList);
        rollupBillingFields(triggerNewList);

    }
     
    public static void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        System.debug('BillingTriggerHelper - beforeDelete');
    }
     
    public static void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        List<AcctSeed__Billing__c> triggerOldList = (List<AcctSeed__Billing__c>)oldList;

        rollupBillingFieldsOnDelete(triggerOldList);
    }
    
    public static void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
        System.debug('BillingTriggerHelper - afterUnDelete');

    }


    /**
    * @description 
    * @author Marian Lyzhychka | 06-22-2023 
    * @param triggerNewList 
    **/
    private static void rollupBillingFields(List<AcctSeed__Billing__c> triggerNewList){
        BillingBatchTrigger batch = new BillingBatchTrigger(triggerNewList);

        if(!Test.isRunningTest()){ 
            Database.executeBatch(batch, 1);
        } else { 
            Database.executeBatch(batch); 
        }
    }


    /**
    * @description 
    * @author Marian Lyzhychka | 06-22-2023 
    * @param triggerNewList 
    **/
    private static void rollupBillingFieldsOnDelete(List<AcctSeed__Billing__c> triggerNewList){
        rollupBillingFields(triggerNewList);
    }


    /**
    * @description 
    * @author Marian Lyzhychka | 06-22-2023 
    * @param triggerNew 
    **/
    @future
    private static void sendEmailNotification(String triggerNew){
        List<AcctSeed__Billing__c> triggerNewList = (List<AcctSeed__Billing__c>)JSON.deserialize(triggerNew, List<AcctSeed__Billing__c>.class);
        Set<Id> salesOrdersId = new Set<Id>();
        Set<Id> opportunityId = new Set<Id>();
        Map<Id, String> parentWithBillingNameMap = new Map<Id, String>(); //Id - opportunity or sales order Id  || String - billing name
        List<EmailRecepientWrapper> ownerWithEmailData = new List<EmailRecepientWrapper>();

        for(AcctSeed__Billing__c billing: triggerNewList){
            if(billing.AcctSeedERP__Sales_Order__c != null){
                salesOrdersId.add(billing.AcctSeedERP__Sales_Order__c);
                parentWithBillingNameMap.put(billing.AcctSeedERP__Sales_Order__c, billing.Name);
            }else if(billing.AcctSeed__Opportunity__c != null){
                opportunityId.add(billing.AcctSeed__Opportunity__c);
                parentWithBillingNameMap.put(billing.AcctSeed__Opportunity__c, billing.Name);
            }
        }

        List<AcctSeedERP__Sales_Order__c> salesOrders = [SELECT Id, Name, Owner.Name, Owner.Email FROM AcctSeedERP__Sales_Order__c WHERE Id IN:salesOrdersId];
        List<Opportunity> opportunities = [SELECT Id, Name, Owner.Name, Owner.Email FROM Opportunity WHERE Id IN:opportunityId];

        for(AcctSeedERP__Sales_Order__c so: salesOrders){
            ownerWithEmailData.add(new EmailRecepientWrapper(
                so.Name,
                parentWithBillingNameMap.containsKey(so.Id) ? parentWithBillingNameMap.get(so.Id) : ' - ',
                so.Owner.Name,
                so.Owner.Email,
                so.Id
            ));
        }

        for(Opportunity opp: opportunities){
            ownerWithEmailData.add(new EmailRecepientWrapper(
                opp.Name,
                parentWithBillingNameMap.containsKey(opp.Id) ? parentWithBillingNameMap.get(opp.Id) : ' - ',
                opp.Owner.Name,
                opp.Owner.Email,
                opp.Id
            ));
        }

        if(ownerWithEmailData.isEmpty()){
            return;
        }


        sendEmail(ownerWithEmailData);
    }

    /**
    * @description 
    * @author Marian Lyzhychka | 06-22-2023 
    * @param emailDataWrapperList 
    **/
    public static void sendEmail(List<EmailRecepientWrapper> emailRecepientWrapperList){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        for(EmailRecepientWrapper wrap :emailRecepientWrapperList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            String body = 'Billing <b>' + wrap.billingName + '</b> for ';
            body += '<a href="' + baseUrl + wrap.recordId + '"> ' + wrap.recordName + '</a> has been created.';

            mail.setSubject('Billing Create Notification');
            mail.setToAddresses(new List<String>{wrap.userEmail});

            // mail.setTargetObjectId(wrap.billingId); 
            mail.setSaveAsActivity(true);

            mail.setHtmlBody(body); 
            mails.add(mail);

        }

        if(!Test.isRunningTest()){
            Messaging.sendEmail(mails);
        }

    }

    
    private class EmailRecepientWrapper{
        String recordName {get;set;} //Sales Order or Opportunity name
        String billingName {get;set;} 
        String userName {get;set;}
        String userEmail {get;set;}
        Id recordId {get;set;} //Sales Order or Opportunity Id
        
        private EmailRecepientWrapper(String recordName, String billingName, String userName, String userEmail, Id recordId){
            this.recordName = recordName;
            this.billingName = billingName;
            this.userName = userName;
            this.userEmail = userEmail;
            this.recordId = recordId;
        }
    }
}