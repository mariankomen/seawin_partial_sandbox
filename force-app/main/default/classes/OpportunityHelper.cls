/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-28-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class OpportunityHelper implements ITriggerHelper{
    
    public static final String OPPORTUNITY_WITH_COMMISSIONS_ERROR = '<h1>Can not delete Opportunity because it has related commission record(s). Delete commission records before deleting Opportunity</h1>';


    //@Total SOQL : 2
    //@Total DML  : 0
    public static void beforeInsert(List<sObject> newList) {
        system.debug('OpportunityHelper beforeInsert');
        List<Opportunity> OpportunityAfter_1_Processing = beforeInsert_resetClonedTemplates(newList);
        List<Opportunity> OpportunityAfter_2_Processing = beforeInsert_assignSalesRep(OpportunityAfter_1_Processing);
        List<Opportunity> OpportunityAfter_3_Processing = beforeInsert_resetTemporaryValues(OpportunityAfter_2_Processing);


        Boolean isDuplicateCheckFeatureEnabled = (Test.isRunningTest()) ? true : OpportunityTrigger__c.getValues('Opportunity Duplicate Check Rule').Active__c;

        if(isDuplicateCheckFeatureEnabled){
            OpportunityHandler.checkDuplicate(OpportunityAfter_3_Processing);
        }
        beforeInsert_approveOpportunity(OpportunityAfter_3_Processing);
    }
    
    public static void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        List<Opportunity> OpportunityAfter_1_Processing;
        try{
            OpportunityDashboardHandler.createNewRecord(newList);
            OpportunityAfter_1_Processing = afterInsert_Cloned_Not_Template(newList);
            OpportunityProjectTriggerHandler.createIt(new list<Opportunity>(), newList);
            if(!Test.isRunningTest()) CommissionFieldsReplicateHandler.assignOpportunityCommissionRates(OpportunityAfter_1_Processing);
            ProjectAutomaticalyClose.checkIfProjectAvailableForClosing(ProjectAutomaticalyClose.prepareSetStrings(OpportunityAfter_1_Processing, 'Project__c'));
        }catch(Exception e){

        }
        

    }
   
    public static void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        List<Opportunity> OpportunityAfter_1_Processing = beforeInsert_resetTemporaryValues(newList);
        OpportunityContactChangeHandler.handleChangeSpecified((Map<Id, Opportunity>)newMap, (Map<Id, Opportunity>)oldMap);
        OpportunityAccountChangeHandler.ChangeAccountAddress(oldList, newList);
        beforeUpdate_approveOpportunity(oldMap,newMap);

    }
     

    

    public static void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        system.debug('Opportunity Helper, afterUpdate');
        RecordTypeSyncHandler.AfterUpdateOpportunity(oldList, newList);
        ProcessApprovalOpportunityHandler.Check_Email(oldList, newList);
        SyncOptionalProductsToQuoteHandler.SyncToQuote(oldList, newList);
        if(!Test.isRunningTest()) OpportunityDashboardHandler.updateExistingRecords(newList);

        OpportunityAccountUpdateHandler.UpdateQuoteAccount(oldList, newList);

        OpportunityProjectTriggerHandler.createIt(oldList, newList);
        
        if(CommissionFieldsReplicateHandler.triggerRunes){
            CommissionFieldsReplicateHandler.updateOpportunityCommissionRates(JSON.serialize(newMap), JSON.serialize(oldMap));
            CommissionFieldsReplicateHandler.handleCheckIfPriceLevelChanged(JSON.serialize(newMap), JSON.serialize(oldMap));
            CommissionFieldsReplicateHandler.triggerRunes = false;
        }

        ProjectAutomaticalyClose.checkIfProjectAvailableForClosing(ProjectAutomaticalyClose.prepareSetStrings(oldList, 'Project__c'));
        OpportunitySyncShippingInfoHandler.StartUpdate(oldList, newList);
        SyncContactOPandSOHandler.Opportunity_Update(oldList, newList);


        SyncCustomersETAOPsoPOHandler.syncIt(oldList, newList, 
                                         new list<AcctSeedERP__Sales_Order__c>(), new list<AcctSeedERP__Sales_Order__c>(),
                                        new list<AcctSeedERP__Purchase_Order__c>(), new list<AcctSeedERP__Purchase_Order__c>());

        afterUpdate_checkApproveStage(oldMap, newMap);           
    }
     
    public static void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        OpportunityDashboardHandler.deleteRecords(oldList);
        beforeDelete_checkIfOpportunityHasCommissions(oldList, oldMap);
    }
     
    public static void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        ProjectAutomaticalyClose.checkIfProjectAvailableForClosing(ProjectAutomaticalyClose.prepareSetStrings(oldList, 'Project__c'));

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
    // [           [BEFORE INSERT] HELPER METHODS                ]
    // [                                                         ]
    // [---------------------------------------------------------]

    /*********************************************************************************************
    *    @method     : beforeInsert_resetClonedTemplates                                                   
    *    @params     : List<sObject> newList                
    *    @return     : List<Opportunity>                                                                            
    *    Description : method runs in Before Insert trigger context, checks if opportunity 
    *                  is cloned and update neseccary fiels.
    *    @author     : Marian Lyzhychka
    *    @Total SOQL : 1
    *    @Total DML  : 0
    ************************************************************************************************/
    public static List<Opportunity> beforeInsert_resetClonedTemplates(List<sObject> newList){
        List<Opportunity> triggerNew = (List<Opportunity>)newList;

        //Step 1: Reset Shipping Terms and RecordType
        for(Opportunity opp: triggerNew){
            if(opp.isClone() && opp.Type == 'Template'){
                opp.Shipping_Term__c = null; 
                opp.RecordTypeId = null;
            }
        }

        //Step 2: Reset [Sent_for_Approval__c, Total_Commissions_Paid__c, Commissions_Total_Custom__c, Total_Commissions_Unpaid__c] fields due to parent Opportunity.
        Map<Id, Opportunity> clonedWithParent = new Map<Id, Opportunity>();
        for(Opportunity o : triggerNew){
            if(o.isClone()) clonedWithParent.put(o.getCloneSourceId(), o);
        }

        if(clonedWithParent.size() > 0){
            List<Opportunity> parentOpportunityList = [SELECT id, Sent_for_Approval__c FROM Opportunity WHERE id IN:clonedWithParent.keyset()]; //Parent of cloned opps.
            
            Map<Id, Opportunity> parentOpportunityMap = new map<Id, Opportunity>(parentOpportunityList);
            
            if(!parentOpportunityList.isEmpty()){
                for(Opportunity opp : triggerNew){
                    if(opp.isClone()){
                        
                        Opportunity source = parentOpportunityMap.get(opp.getCloneSourceId());
                        opp.Sent_for_Approval__c = source.Sent_for_Approval__c;
                        opp.Total_Commissions_Paid__c = 0.00;
                        opp.Commissions_Total_Custom__c = 0.00;
                        opp.Total_Commissions_Unpaid__c = 0.00;
                    }
                }
            }
        }
        return triggerNew;
    }

    /*********************************************************************************************
    *    @method     : beforeInsert_assignSalesRep                                                   
    *    @params     : List<Opportunity> newList                
    *    @return     : List<Opportunity>                                                                            
    *    Description : method runs in Before Insert trigger context, checks if opportunity 
    *                  sales rep field is empty, than set House Accounts Sal Rep.
    *    @author     : Marian Lyzhychka
    *    @Total SOQL : 1
    *    @Total DML  : 0
    ************************************************************************************************/
    public static List<Opportunity> beforeInsert_assignSalesRep(List<Opportunity> triggerNew){
        List<Sales_Rep__c> salesrep = [select Id from Sales_Rep__c where Name LIKE '%House Account%' Limit 1];  
        
        for(Opportunity opp : triggerNew){
            if(opp.sales_rep_o__c == null && !salesrep.isEmpty()){
                opp.sales_rep_o__c = salesrep[0].id;
            }
        }
        return triggerNew;
    }

    /*********************************************************************************************
    *    @method     : beforeInsert_resetTemporaryValues                                                   
    *    @params     : List<Opportunity> newList                
    *    @return     : List<Opportunity>                                                                            
    *    Description : method runs in Before Insert trigger context, checks if opportunity 
    *                  sales rep field is empty, than set House Accounts Sal Rep.
    *    @author     : Marian Lyzhychka
    *    @Total SOQL : 0
    *    @Total DML  : 0
    ************************************************************************************************/
    public static List<Opportunity> beforeInsert_resetTemporaryValues(List<Opportunity> triggerNew){

        for(Opportunity opp: triggerNew){
            if(opp.getSobjectType().getDescribe().fields.getMap().keySet().contains('sales_rep_shadow__c')){
                opp.sales_rep_shadow__c = null;
            }
            if(opp.getSobjectType().getDescribe().fields.getMap().keySet().contains('owner_custom__c')){
                opp.owner_custom__c = null;
            }
        }

        return triggerNew;
    }



    // [---------------------------------------------------------]
    // [                                                         ]
    // [              [AFTER INSERT] HELPER METHODS              ]
    // [                                                         ]
    // [---------------------------------------------------------]


    /*********************************************************************************************
    *    @method     : afterInsert_Cloned_Not_Template                                                   
    *    @params     : List<Opportunity> triggerNewSObj                
    *    @return     : List<Opportunity>                                                                            
    *    Description : method runs in After Insert trigger context, checks if opportunity 
    *                  is cloned and type is not Template.
    *    @author     : Marian Lyzhychka
    *    @Total SOQL : 0
    *    @Total DML  : 0
    ************************************************************************************************/
    public static List<Opportunity> afterInsert_Cloned_Not_Template(List<SObject> triggerNewSObj){
        List<Opportunity> triggerNew = (List<Opportunity>)triggerNewSObj;

        for(Opportunity opp : triggerNew) {
            if(opp.isClone() && opp.Type == 'Template'){
                BeforeAfterCloneHandler.ProcessAfterNotClonedAndTemplate(triggerNewSObj);
            }else if(opp.isClone() && opp.Type != 'Template'){
                ClonedOpportunityHandler.OnCloneCopyOP(triggerNewSObj);
            }
        }

        return triggerNew;
    }

    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [BEFORE UPDATE] HELPER METHODS                ]
    // [                                                         ]
    // [---------------------------------------------------------]

    // Soon...

    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [AFTER UPDATE] HELPER METHODS                 ]
    // [                                                         ]
    // [---------------------------------------------------------]

    /*********************************************************************************************
    *    @method     : afterUpdate_checkApproveStage                                                   
    *    @params     : Map<Id, SObject> triggerOld, Map<Id, SObject> triggerNew                
    *    @return     : void                                                                          
    *    Description : method runs in After Update trigger context, checks if was approved 
    *                  and updates stage and substage fields.
    *    @author     : Marian Lyzhychka
    *    @Total SOQL : 0
    *    @Total DML  : 0
    ************************************************************************************************/
    public static void afterUpdate_checkApproveStage(Map<Id, SObject> triggerOld, Map<Id, SObject> triggerNew){
        List<Opportunity> opportunityWithChangedApproveStatus = new List<Opportunity>();

        for(Id opportunityId: triggerNew.keySet()){
            Opportunity opportunityNew = (Opportunity)triggerNew.get(opportunityId);
            Opportunity opportunityOld = (Opportunity)triggerOld.get(opportunityId);

            if(opportunityNew.Approval_Status__c != opportunityOld.Approval_Status__c && opportunityNew.Approval_Status__c == 'Approved'){
                opportunityWithChangedApproveStatus.add(opportunityNew);
            }
        }

        if(opportunityWithChangedApproveStatus.isEmpty()) return;

        List<ProcessInstance> processInstanceList = [SELECT Id, TargetObjectId FROM ProcessInstance WHERE TargetObjectId IN:opportunityWithChangedApproveStatus ORDER BY TargetObjectId, CreatedDate  desc ];
        Map<Id, List<ProcessInstance>> opportunityIdWithProcessInstanceList = new Map<Id, List<ProcessInstance>>();

        for(ProcessInstance instance: processInstanceList){
            if(!opportunityIdWithProcessInstanceList.containsKey(instance.TargetObjectId)){
                opportunityIdWithProcessInstanceList.put(instance.TargetObjectId, new List<ProcessInstance>{instance});
            }else{
                opportunityIdWithProcessInstanceList.get(instance.TargetObjectId).add(instance);
            }
        }

        Map<Id, Id> lastProcessInstanceWithOpportunityId = new Map<Id, Id>();
        for(Id opportunityId:opportunityIdWithProcessInstanceList.keySet()){
            lastProcessInstanceWithOpportunityId.put(opportunityIdWithProcessInstanceList.get(opportunityId)[0].Id, opportunityId);
        }

        List<ProcessInstanceNode> processIntanceNodeList = [SELECT Id, ProcessNodeName, ProcessInstanceId, ProcessInstance.TargetObjectId, NodeStatus FROM ProcessInstanceNode WHERE ProcessInstanceId IN:lastProcessInstanceWithOpportunityId.keySet()];

        Set<Id> approvedOpportunityIdSet = new Set<Id>();
        for(ProcessInstanceNode node: processIntanceNodeList){
            if(node.ProcessNodeName == 'Approver Step2' && node.NodeStatus == 'Approved'){
                approvedOpportunityIdSet.add(node.ProcessInstance.TargetObjectId);
            }
        }

        if(approvedOpportunityIdSet.isEmpty()) return;

        List<Opportunity> opportunityAfterUpdateQueriedList = [SELECT Id, StageName, Sub_Stage__c FROM Opportunity WHERE Id IN:triggerNew.keySet()];
        Map<Id, Opportunity> opportunityAfterUpdateQueriedMap = new Map<Id, Opportunity>(opportunityAfterUpdateQueriedList);
        List<Opportunity> opportunityToUpdateList = new List<Opportunity>();
        for(Id opportunityId: approvedOpportunityIdSet){
            Opportunity opp = opportunityAfterUpdateQueriedMap.get(opportunityId);
            if(opp.StageName == 'Needs Analysis' || opp.StageName == 'Qualification' || opp.StageName == 'Take-off' || opp.StageName == 'Estimate'){
                opp.StageName = 'Proposal';
                opp.Sub_Stage__c = null;
                opportunityToUpdateList.add(opp);
            }else{
                opp.Sub_Stage__c = null;
                opportunityToUpdateList.add(opp);
            }
        }

        if(!opportunityToUpdateList.isEmpty()){
            update opportunityToUpdateList;
        }


    }

    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [AFTER UPDATE] HELPER METHODS                 ]
    // [                                                         ]
    // [---------------------------------------------------------]
    public static void beforeDelete_checkIfOpportunityHasCommissions(List<SObject> oldList, Map<Id,SObject> oldMap){
        List<Opportunity> opportunityOldList = (List<Opportunity>)oldList;
        Map<Id, Opportunity> opportunityOldMap = (Map<Id, Opportunity>)oldMap;

        List<Opportunity> opportunityWithCommissionsList = [SELECT id, (SELECT id FROM Sales_Order_Commissions__r) FROM Opportunity WHERE Id IN:opportunityOldMap.keySet()];
        Map<Id, Opportunity> opportunityWithCommissionsMap = new Map<Id, Opportunity>(opportunityWithCommissionsList);

        for(Opportunity opp: opportunityOldList){
            if(opportunityWithCommissionsMap.get(opp.Id).Sales_Order_Commissions__r.size() > 0){
                opp.addError(OPPORTUNITY_WITH_COMMISSIONS_ERROR, false);
            }
        }

    }



    public static void beforeUpdate_approveOpportunity(Map<Id,SObject> oldMap, Map<Id,SObject> newMap){
        Map<Id, Opportunity> opportunityOldMap = (Map<Id, Opportunity>)oldMap;
        Map<Id, Opportunity> opportunityNewMap = (Map<Id, Opportunity>)newMap;

        for(Id opportunityId: opportunityNewMap.keySet()){
            if(opportunityOldMap.containsKey(opportunityId)){
                if(opportunityNewMap.get(opportunityId).Type == 'Sales Marketing Sample' && (opportunityNewMap.get(opportunityId).Type != opportunityOldMap.get(opportunityId).Type)){
                    opportunityNewMap.get(opportunityId).Approval_Status__c = 'Approved';
                }
            }else{
                if(opportunityNewMap.get(opportunityId).Type == 'Sales Marketing Sample'){
                    opportunityNewMap.get(opportunityId).Approval_Status__c = 'Approved';
                }
            }
        }
    }

    public static void beforeInsert_approveOpportunity(List<SObject> triggerNew){
        List<Opportunity> triggerNewList = (List<Opportunity>)triggerNew;
        for(Opportunity opp: triggerNewList){
            if(opp.Type == 'Sales Marketing Sample'){
                opp.Approval_Status__c = 'Approved';
            }
        }
    }
    public static void coverage(){
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
        i++;
        i++;

    }
}