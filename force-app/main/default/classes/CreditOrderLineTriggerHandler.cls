public with sharing class CreditOrderLineTriggerHandler {
    

    public static void beforeUpdateExtension(List<Credit_Order_Line__c> updatable){
        Set<Id> credit_order_ids = getSetFromListHepler(updatable);

        Map<Id, AcctSeed__Billing_Line__c> credit_line_bill = new Map<Id, AcctSeed__Billing_Line__c>();
        for(AcctSeed__Billing_Line__c bill_line: [SELECT Id, 
                                                         Credit_Order_Line__c 
                                                         FROM AcctSeed__Billing_Line__c 
                                                         WHERE Credit_Order_Line__c IN:credit_order_ids]){
            credit_line_bill.put(bill_line.Credit_Order_Line__c, bill_line);
        }

        for(Credit_Order_Line__c col:updatable){
            if(credit_line_bill.containsKey(col.Id)){
                col.addError('Credit Order Line can not be edited, bacause it associated with Billing Line.');
            }
        }
    }

    public static Set<Id> getSetFromListHepler(List<Credit_Order_Line__c> lines){
        Set<Id> set_ids = new Set<Id>();
        for(Credit_Order_Line__c l:lines){
            set_ids.add(l.Id);
        }

        return set_ids;
    }

}