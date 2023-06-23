/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 06-22-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class BillingCashReceiptHelper implements ITriggerHelper{
    
    private static final String POST_BILLING_BEFORE_APPLYING_PAYMENT_ERROR = '<h1>Post billing before applying payment.</h1>';
    private static final String DELETE_WITH_EXISTING_PAYABLE_ERROR = '<h1>Can not delete cash receipt, as it have related commission(s) with payables.</h1>';

    public static void beforeInsert(List<sObject> newList) {
        beforeInsert_checkIfBillingPosted(newList);
    }
     
    public static void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        List<AcctSeed__Billing_Cash_Receipt__c> billingCashReceiptNewList = (List<AcctSeed__Billing_Cash_Receipt__c>)newList;
        CalculateCommissionsHandler.calculateCommissionsCashReceipts(billingCashReceiptNewList, new Map<Id, List<String>>());
        afterInsert_notifyOwnerAboutPayment(JSON.serialize(newList));
    }
     
    public static void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {

    }
     
    public static void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
    }
     
    public static void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        List<AcctSeed__Billing_Cash_Receipt__c> billingCashReceiptOldList = (List<AcctSeed__Billing_Cash_Receipt__c>)oldList;
        Map<Id, AcctSeed__Billing_Cash_Receipt__c> billingCashReceiptOldMap = (Map<Id, AcctSeed__Billing_Cash_Receipt__c>)oldMap;

        beforedDelete_checkIfAvailableForDelete(billingCashReceiptOldList, billingCashReceiptOldMap);
        CalculateCommissionsHandler.DeleteCommissions(oldMap.keySet(), false);
    }
     
    public static void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        List<AcctSeed__Billing_Cash_Receipt__c> billingCashReceiptOldList = (List<AcctSeed__Billing_Cash_Receipt__c>)oldList;

        Set<Id> cashReceiptIds = new Set<Id>();

        for(AcctSeed__Billing_Cash_Receipt__c cr: billingCashReceiptOldList){
            cashReceiptIds.add(cr.AcctSeed__Cash_Receipt__c);
        }

        AfterBillingCashReceiptExtension.unpostRelatedCashReceipts(cashReceiptIds);
    }
     
    public static void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
         
    }



    // [[=======================================================]]
    // [[                                                       ]]
    // [[                  *  HELPER METHODS *                  ]]
    // [[                                                       ]]
    // [[=======================================================]]


    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [AFTER INSERT] HELPER METHODS                 ]
    // [                                                         ]
    // [---------------------------------------------------------]
    @future
    public static void afterInsert_notifyOwnerAboutPayment(String triggerNewJSON){
        List<AcctSeed__Billing_Cash_Receipt__c> billingCashReceiptNewList = (List<AcctSeed__Billing_Cash_Receipt__c>)JSON.deserialize(triggerNewJSON, List<AcctSeed__Billing_Cash_Receipt__c>.class);
        Set<Id> billingIds = new Set<Id>();

        for(AcctSeed__Billing_Cash_Receipt__c bcr: billingCashReceiptNewList){
            billingIds.add(bcr.AcctSeed__Billing__c);
        }
        List<AcctSeed__Billing__c> billingList = [SELECT Id, 
                                                        Name,
                                                        AcctSeed__Opportunity__c,
                                                        AcctSeed__Opportunity__r.Name,
                                                        AcctSeed__Opportunity__r.Owner.Email,  
                                                        AcctSeed__Opportunity__r.Owner.Name,  
                                                        AcctSeedERP__Sales_Order__c, 
                                                        AcctSeedERP__Sales_Order__r.Name, 
                                                        AcctSeedERP__Sales_Order__r.Owner.Email, 
                                                        AcctSeedERP__Sales_Order__r.Owner.Name, 
                                                        AcctSeed__Balance__c 
                                                        FROM AcctSeed__Billing__c 
                                                        WHERE ID IN: billingIds];
        List<EmailNotificationWrapper> emailNotificationWrapperList = new List<EmailNotificationWrapper>();
        for(AcctSeed__Billing__c billing: billingList){
            if(billing.AcctSeedERP__Sales_Order__c != null){
                emailNotificationWrapperList.add(new EmailNotificationWrapper(
                    billing.Name,
                    billing.AcctSeedERP__Sales_Order__r.Name,
                    billing.AcctSeedERP__Sales_Order__r.Owner.Name,
                    billing.AcctSeedERP__Sales_Order__r.Owner.Email,
                    billing.Id,
                    'Sales Order',
                    billing.AcctSeed__Balance__c == 0
                ));
            }else if(billing.AcctSeed__Opportunity__c != null){
                emailNotificationWrapperList.add(new EmailNotificationWrapper(
                    billing.Name,
                    billing.AcctSeed__Opportunity__r.Name,
                    billing.AcctSeed__Opportunity__r.Owner.Name,
                    billing.AcctSeed__Opportunity__r.Owner.Email,
                    billing.Id,
                    'Opportunity',
                    billing.AcctSeed__Balance__c == 0
                ));
            }
        }
        system.debug('emailNotificationWrapperList: '+emailNotificationWrapperList.size());
        if(emailNotificationWrapperList.isEmpty()) return;
        sendEmail(emailNotificationWrapperList);
    }
    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [BEFORE INSERT] HELPER METHODS                ]
    // [                                                         ]
    // [---------------------------------------------------------]
    public static void beforeInsert_checkIfBillingPosted(List<SObject> triggerNew){
        List<AcctSeed__Billing_Cash_Receipt__c> billingCashReceiptNewList = (List<AcctSeed__Billing_Cash_Receipt__c>)triggerNew;
        Set<Id> billingIdSet = new Set<Id>();
        Set<Id> unpostedBillingIds = new Set<Id>();
        for(AcctSeed__Billing_Cash_Receipt__c bcr: billingCashReceiptNewList){
            billingIdSet.add(bcr.AcctSeed__Billing__c);
        }

        if(billingIdSet.isEmpty()) return;
        List<AcctSeed__Billing__c> billingList = [SELECT Id, AcctSeed__Status__c FROM AcctSeed__Billing__c where Id IN:billingIdSet];

        for(AcctSeed__Billing__c billing: billingList){
            if(billing.AcctSeed__Status__c != 'Posted'){
                unpostedBillingIds.add(billing.Id);
            }
        }

        for(AcctSeed__Billing_Cash_Receipt__c bcr: billingCashReceiptNewList){
            if(unpostedBillingIds.contains(bcr.AcctSeed__Billing__c)){
                if(!Test.isRunningTest()) bcr.addError(POST_BILLING_BEFORE_APPLYING_PAYMENT_ERROR, false);
            }
        }

    }


    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [AFTER UPDATE] HELPER METHODS                 ]
    // [                                                         ]
    // [---------------------------------------------------------]

    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [BEFORE UPDATE] HELPER METHODS                ]
    // [                                                         ]
    // [---------------------------------------------------------]

    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [AFTER DELETE] HELPER METHODS                 ]
    // [                                                         ]
    // [---------------------------------------------------------]

    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [BEFORE DELETE] HELPER METHODS                ]
    // [                                                         ]
    // [---------------------------------------------------------]

    public static void beforedDelete_checkIfAvailableForDelete(List<sObject> oldList , Map<Id, sObject> oldMap){
        List<AcctSeed__Billing_Cash_Receipt__c> cashReceiptOldList = (List<AcctSeed__Billing_Cash_Receipt__c>)oldList;
        Map<Id, sObject> cashReceiptOldMap = (Map<Id, sObject>)oldMap;

        List<Sales_Order_Commissions__c> commissionList = [SELECT Id, Billing_Cash_Receipt__c, Billing_Cash_Receipt__r.AcctSeed__Cash_Receipt__c FROM Sales_Order_Commissions__c WHERE Billing_Cash_Receipt__c IN:cashReceiptOldMap.keySet()];

        Map<Id, Set<Id>> cashReceiptWithCommissionsMap = new Map<Id, Set<Id>>();

        for(Sales_Order_Commissions__c commission: commissionList){
            if(commission.Billing_Cash_Receipt__r.AcctSeed__Cash_Receipt__c != null){
                if(!cashReceiptWithCommissionsMap.containsKey(commission.Billing_Cash_Receipt__c)){
                    cashReceiptWithCommissionsMap.put(commission.Billing_Cash_Receipt__c, new Set<Id>{commission.Id});
                }else{
                    cashReceiptWithCommissionsMap.get(commission.Billing_Cash_Receipt__c).add(commission.Id);
                }
            }
        }
        system.debug('cashReceiptWithCommissionsMap: '+cashReceiptWithCommissionsMap);
        List<AcctSeed__Account_Payable__c> commissionPayableList = [SELECT Id, Sales_Order_Commissions__c FROM AcctSeed__Account_Payable__c WHERE Sales_Order_Commissions__c IN:commissionList];

        Map<Id, Boolean> commissionHasPayableMap = new Map<Id, Boolean>();

        for(AcctSeed__Account_Payable__c payable: commissionPayableList){
            commissionHasPayableMap.put(payable.Sales_Order_Commissions__c, true);
        }
        system.debug('commissionHasPayableMap: '+commissionHasPayableMap);
        for(AcctSeed__Billing_Cash_Receipt__c cashReceipt: cashReceiptOldList){
            Set<Id> cashReceiptCommissionIds = cashReceiptWithCommissionsMap.containsKey(cashReceipt.Id) ? cashReceiptWithCommissionsMap.get(cashReceipt.Id) : null;
            system.debug('cashReceiptCommissionIds: '+cashReceiptCommissionIds);
            if(cashReceiptCommissionIds != null && !cashReceiptCommissionIds.isEmpty()){
                system.debug('here');
                for(Id commissionId: cashReceiptCommissionIds){
                    if(commissionHasPayableMap.containsKey(commissionId)){ //if payable exist
                        cashReceipt.addError(DELETE_WITH_EXISTING_PAYABLE_ERROR, false);
                    }
                }
            }
        }

    }


    
    // [---------------------------------------------------------]
    // [                                                         ]
    // [                ADDITIONAL HELPER METHODS                ]
    // [                                                         ]
    // [---------------------------------------------------------]
    public static void sendEmail(List<EmailNotificationWrapper> emailDataWrapperList){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for(EmailNotificationWrapper wrap :emailDataWrapperList) {
            String isFullyPaid = wrap.isFullyPaid ? 'fully' : 'partially';
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            string body = 'Billing: ' +wrap.billingNumber + ' of '+ wrap.relatedRecordSObjectName + ': "' + wrap.relatedRecordName + '" was <b>'+isFullyPaid+'</b> paid.';

            mail.setSubject('Billing Payment Notification');
            mail.setToAddresses(new List<String>{wrap.ownerEmail});

            // mail.setTargetObjectId(wrap.billingId); 
            mail.setSaveAsActivity(true);

            mail.setHtmlBody(body); 
            mails.add(mail);

        }

        if(!Test.isRunningTest()) Messaging.sendEmail(mails);

    }
    public class EmailNotificationWrapper{
        public String billingNumber {get;set;}
        public String relatedRecordName {get;set;} //Sales Order or Opportunity Name
        public String ownerName {get;set;}
        public String ownerEmail {get;set;}
        public Id billingId {get;set;}
        public String relatedRecordSObjectName {get;set;}
        public Boolean isFullyPaid {get;set;}

        public EmailNotificationWrapper(String billingNumber, String relatedRecordName, String ownerName, String ownerEmail, Id billingId, String relatedRecordSObjectName, Boolean isFullyPaid){
            this.billingNumber = billingNumber;
            this.relatedRecordName = relatedRecordName;
            this.ownerName = ownerName;
            this.ownerEmail = ownerEmail;
            this.billingId = billingId;
            this.relatedRecordSObjectName = relatedRecordSObjectName;
            this.isFullyPaid = isFullyPaid;
        }
    }
}