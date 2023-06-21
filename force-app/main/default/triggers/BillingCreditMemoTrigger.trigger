trigger BillingCreditMemoTrigger on AcctSeed__Billing_Credit_Memo__c (after insert, before delete) {
    if(Trigger.IsAfter && Trigger.IsInsert){
        BillingCreditMemoHandler.UpdateOnSO(Trigger.new, True);
        
    }else if(Trigger.IsBefore && Trigger.IsDelete){
        BillingCreditMemoHandler.UpdateOnSO(Trigger.old, False);
        
    }
}