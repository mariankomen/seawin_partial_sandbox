public with sharing class AccountHelper implements ITriggerHelper{
    
    public static void beforeInsert(List<sObject> newList) {
        // List<OpportunityLineItem> OpportunityLinesAfter_1_Processing = beforeInsert_setPriceLevels(newList);
        AccountGLPrePopulateHandler.PrePopulate(newList);
        AccountTypeValueAsInLeadHandler.Populate(newList);
        AutoSalesRepAssignmentHandler.Assignment(newList);
        NullifyTemporaryValues.Nullify(newList);

    }
     
    public static void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
         
    }
     
    public static void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        AutoSalesRepAssignmentHandler.Assignment(newList);
        NullifyTemporaryValues.Nullify(newList);
    }
     
    public static void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        AccountBillingChangeHandler.AccountBillingChangeHandler(oldList, newList);
        ApprovalProcessTriggerHandler.CheckGL(oldList, newList);
        ApprovalProcessTriggerHandler.Check_Email(oldList, newList);

        afterUpdate_runApprovalProcessIfTypeChanged(oldMap, newMap);
    }
     
    public static void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        AccountTriggerHandler.beforeDeleteHandler(oldList);

    }
     
    public static void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
         
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
    // [           [AFTER UPDATE] HELPER METHODS                 ]
    // [                                                         ]
    // [---------------------------------------------------------]

    public static void afterUpdate_runApprovalProcessIfTypeChanged(Map<Id, SObject> oldMap, Map<Id, SObject> newMap ){
        Map<Id, Account> oldAccountMap = (Map<Id, Account>)oldMap;
        Map<Id, Account> newAccountMap = (Map<Id, Account>)newMap;

        Set<Id> accountIdToRunApprovalProcessSet = new Set<Id>();
        Set<Id> accountIdToRemoveApprovalProcessSet = new Set<Id>();

        for(Id accId: newAccountMap.keySet()){
            //Check does Accounting Type field was changed
            if(newAccountMap.get(accId).AcctSeed__Accounting_Type__c != oldAccountMap.get(accId).AcctSeed__Accounting_Type__c){
                if(newAccountMap.get(accId).AcctSeed__Accounting_Type__c == 'Customer' || newAccountMap.get(accId).AcctSeed__Accounting_Type__c == 'Customer and Vendor'){
                    if(newAccountMap.get(accId).Approval_Status__c == 'Not Approved' || newAccountMap.get(accId).Approval_Status__c == null){
                        accountIdToRunApprovalProcessSet.add(accId);
                    }
                }else{
                    if(newAccountMap.get(accId).Approval_Status__c != 'Approved'){
                        if((oldAccountMap.get(accId).AcctSeed__Accounting_Type__c == 'Customer' || oldAccountMap.get(accId).AcctSeed__Accounting_Type__c == 'Customer and Vendor')
                        && (newAccountMap.get(accId).AcctSeed__Accounting_Type__c != 'Customer' || newAccountMap.get(accId).AcctSeed__Accounting_Type__c != 'Customer and Vendor')){
                            accountIdToRemoveApprovalProcessSet.add(accId);
                        }   
                    }
                }
            }
        }

        if(!accountIdToRunApprovalProcessSet.isEmpty()){
            for(Id accountId: accountIdToRunApprovalProcessSet){
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(accountId);
    
                Approval.ProcessResult processResult = Approval.process(req);
            }
        }

        if(!accountIdToRemoveApprovalProcessSet.isEmpty()){
            automaticallyApproveRecord(accountIdToRemoveApprovalProcessSet);
        }
        

    }


    public static void automaticallyApproveRecord(Set<Id> accountIds){
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId IN: accountIds
        ];
        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        for(ProcessInstanceWorkitem workItem : workItems){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
            //Valid values are: Approve, Reject, or Removed. 
            //Only system administrators can specify Removed.
            req.setAction('Removed');
            req.setComments('Approval process has been automatically removed. Contact your Administrator if you have any questions.');
            requests.add(req);
        }
        Approval.ProcessResult[] processResults = Approval.process(requests);
    }
}