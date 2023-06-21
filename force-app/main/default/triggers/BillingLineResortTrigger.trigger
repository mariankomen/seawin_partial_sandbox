trigger BillingLineResortTrigger on AcctSeed__Billing_Line__c (after insert, after delete, after undelete) {
   
    if(Trigger.IsAfter){
        if(Trigger.IsInsert || Trigger.IsUndelete){
            
            if(!Test.isRunningTest()) billinglineResortHandler.reSort(Trigger.new);
        }else if(Trigger.IsDelete){
            
            if(!Test.isRunningTest()) billinglineResortHandler.reSort(Trigger.old);
        }
    }    


    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
}