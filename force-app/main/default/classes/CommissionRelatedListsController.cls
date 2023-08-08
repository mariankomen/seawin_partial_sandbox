/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 08-04-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class CommissionRelatedListsController {
    
    private static final String UNSOPPORTED_SOBJECT_EXCEPTION = 'Unsupported sObject for creating commissions.';

    public class CommissionRelatedListsControllerException extends Exception {}

    /**
    * @description 
    * @author Marian Lyzhychka | 07-31-2023 
    * @param recordId //Opportunity || SalesOrder Id
    * @return string 
    **/
    @AuraEnabled
    public static string getAvailableCommissions(String recordId){
        try {
            List<Sales_Order_Commissions__c> commissions = [SELECT Id, Name,
                                                            Commission_Holder__c,
                                                            Role__c,
                                                            Invoice_Memo__c,
                                                            Billing_Payment__c,
                                                            Billing_Paid_Date__c,
                                                            Commission_Amount__c,
                                                            Total_Discount__c,
                                                            Holder_Name_System__c,
                                                            Billing_Credit_Memo__c,
                                                            Billing_Credit_Memo__r.Name,
                                                            Billing_Cash_Receipt__c,
                                                            Billing_Cash_Receipt__r.Name,
                                                            Commission_Paid__c,
                                                            Commission_Balance__c
                                                            FROM Sales_Order_Commissions__c
                                                            WHERE Opportunity__c =: recordId OR Sales_Order__c =: recordId ORDER BY CreatedDate];

            SObjectListWrapper wrap = new SObjectListWrapper(commissions, commissions.size());                                                
            return JSON.serialize(wrap);
        } catch (Exception e) {
            throw new CommissionRelatedListsControllerException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getAvailablePayables(String recordId){
        try {
            List<AcctSeed__Account_Payable__c> payables = [SELECT Id, Name,
                                                                Sales_Order_Commissions__c,
                                                                Sales_Order_Commissions__r.Name,
                                                                Sales_Order_Commissions__r.Holder_Name_System__c,
                                                                Role__c,
                                                                AcctSeed__Due_Date__c,
                                                                AcctSeed__Status__c,
                                                                AcctSeed__Payment_Status__c,
                                                                Paid_Date__c,
                                                                AcctSeed__Total__c,
                                                                AcctSeed__Balance__c
                                                                FROM AcctSeed__Account_Payable__c 
                                                                WHERE Opportunity__c=: recordId OR Sales_Order__c=:recordId ORDER BY CreatedDate];

            SObjectListWrapper wrap = new SObjectListWrapper(payables, payables.size());                                                
            return JSON.serialize(wrap);
        } catch (Exception e) {
            throw new CommissionRelatedListsControllerException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void updateExistingCommissions(Id recordId){
        try{
            List<AcctSeed__Billing_Cash_Receipt__c> cashReceipts = [SELECT id, AcctSeed__Billing__c from 
                AcctSeed__Billing_Cash_Receipt__c WHERE
                AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c =: recordId OR AcctSeed__Billing__r.AcctSeed__Opportunity__c =: recordId];

            List<AcctSeed__Billing_Credit_Memo__c> MemoReceipts = [SELECT id, AcctSeed__Billing_Invoice__c from 
                AcctSeed__Billing_Credit_Memo__c WHERE
                AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__c =: recordId OR AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__c =: recordId];

                if(cashReceipts.isEmpty() && MemoReceipts.isEmpty()){ // if nothing is found...
                    throw new CommissionRelatedListsControllerException('No payment exists for this Sales Order or Opportunity.');
                }else{
                    CalculateCommissionsHandler.updateExistingCommissions(recordId);
                }


        }catch(Exception e){
            throw new CommissionRelatedListsControllerException(e.getMessage());
        }
    }


    public class SObjectListWrapper{
        public List<SObject> sobjectList {get;set;}
        public Integer totalRecords {get;set;}

        public SObjectListWrapper(List<SObject> sobjectList, Integer totalRecords){
            this.sobjectList = sobjectList;
            this.totalRecords = totalRecords;
        }
    }

}