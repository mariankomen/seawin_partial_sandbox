public with sharing class OpportunityLineItemHelper implements ITriggerHelper{
    
    public static void beforeInsert(List<sObject> newList) {
        List<OpportunityLineItem> OpportunityLinesAfter_1_Processing = beforeInsert_setPriceLevels(newList);
    }
     
    public static void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
         
    }
     
    public static void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        denieUpdatableAccessForBilledLines(oldMap, newMap);

        //We use beforeMethod here, because the logic need to be the same. After any update of line, we need to set Opportunity Price Level to line.
        List<OpportunityLineItem> OpportunityLinesAfter_1_Processing = beforeInsert_setPriceLevels(newList); 

    }
     
    public static void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        updateRelatedBillingLineItems(oldMap, newMap);
    }
     
    public static void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        beforeDelete_checkDoLinesHaveRelatedBillingLine(oldList, oldMap);
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
    // [           [BEFORE INSERT] HELPER METHODS                ]
    // [                                                         ]
    // [---------------------------------------------------------]

    /*********************************************************************************************
    *    @method     : beforeInsert_setPriceLevels                                                   
    *    @params     : List<SObject> triggerNew                
    *    @return     : void                                                                            
    *    Description : method runs in Before Insert trigger context, set Price Level depends on Opp 
    *    @author     : Marian Lyzhychka
    *    @Total SOQL : 1
    *    @Total DML  : 0
    ************************************************************************************************/
    public static List<OpportunityLineItem> beforeInsert_setPriceLevels(List<SObject> triggerNew){
        List<OpportunityLineItem> triggerNewItems = (List<OpportunityLineItem>)triggerNew;
        Map<Id, String> OpportunityWithPriceLevelMap = new Map<Id, String>();
        Set<Id> opportunityIdSet = new Set<Id>();

        for(OpportunityLineItem oli: triggerNewItems){
            if(oli.OpportunityId != null) opportunityIdSet.add(oli.OpportunityId);
        }

        List<Opportunity> OpportunitityList = [SELECT Id, Price_Level__c FROM Opportunity WHERE Id IN: opportunityIdSet];

        for(Opportunity opp: OpportunitityList){
            OpportunityWithPriceLevelMap.put(opp.Id, opp.Price_Level__c);
        }

        for(OpportunityLineItem oli: triggerNewItems){
            oli.Price_Level__c = OpportunityWithPriceLevelMap.containsKey(oli.OpportunityId) ? OpportunityWithPriceLevelMap.get(oli.OpportunityId) : null;
        }

        return triggerNewItems;
    }
    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [AFTER INSERT] HELPER METHODS                 ]
    // [                                                         ]
    // [---------------------------------------------------------]


    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [BEFORE UPDATE] HELPER METHODS                ]
    // [                                                         ]
    // [---------------------------------------------------------]

    /*********************************************************************************************
    *    @method     : denieUpdatableAccessForBilledLines                                                   
    *    @params     : Map<Id, SObject> triggerOldMap, Map<Id, SObject> triggerNewMap                  
    *    @return     : void                                                                            
    *    Description : method runs in Before Update trigger context, checks does opportunity line 
    *                  item UnitPrice or Quantity fields were changes, and do line is associated
    *                  with any billing line. If it is, denie acces for edit.
    *    @author     : Marian Lyzhychka
    *    @Total SOQL : 1
    *    @Total DML  : 0
    ************************************************************************************************/
    public static void denieUpdatableAccessForBilledLines(Map<Id, SObject> triggerOldMap, Map<Id, SObject> triggerNewMap){
        Map<Id, OpportunityLineItem> oldMap = (Map<Id, OpportunityLineItem>)triggerOldMap;
        Map<Id, OpportunityLineItem> newMap = (Map<Id, OpportunityLineItem>)triggerNewMap;

        List<AcctSeed__Billing_Line__c> relatedBillingLinesToOpportunityLines = [SELECT id, AcctSeed__Opportunity_Product_Id__c
                                                                                FROM AcctSeed__Billing_Line__c
                                                                                WHERE AcctSeed__Opportunity_Product_Id__c IN: triggerNewMap.keySet()];
        Map<Id, AcctSeed__Billing_Line__c>  opportunityLineWithBillingLineMap = new Map<Id, AcctSeed__Billing_Line__c>();

        for(AcctSeed__Billing_Line__c billingLine: relatedBillingLinesToOpportunityLines){
            opportunityLineWithBillingLineMap.put(billingLine.AcctSeed__Opportunity_Product_Id__c, billingLine);
        }

        for(Id opportunityLine: newMap.keySet()){
            if(newMap.get(opportunityLine).UnitPrice != oldMap.get(opportunityLine).UnitPrice || newMap.get(opportunityLine).Quantity != oldMap.get(opportunityLine).Quantity){
                if(opportunityLineWithBillingLineMap.containsKey(opportunityLine)){ //Opportunity line has related billing, and can not be edited.
                    newMap.get(opportunityLine).addError('Sales Price or Quantity cannot be changed, as billing has already been done.');
                }
            }
            
        }
    }


    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [AFTER UPDATE] HELPER METHODS                 ]
    // [                                                         ]
    // [---------------------------------------------------------]

    /*********************************************************************************************
    *    @method     : updateRelatedBillingLineItems                                                   
    *    @params     : Map<Id, SObject> triggerOldMap, Map<Id, SObject> triggerNewMap                  
    *    @return     : void                                                                            
    *    Description : method runs in After Update trigger context, checks does opportunity line 
    *                  item Size or Description fields were changes. If it is, than find related
    *                  Billing Line Items, and updates Size_Custom__c and Item_Description__c fields
    *    @author     : Marian Lyzhychka
    *    @Total SOQL : 1
    *    @Total DML  : 1
    ************************************************************************************************/
    public static void updateRelatedBillingLineItems(Map<Id, SObject> triggerOldMap, Map<Id, SObject> triggerNewMap){
        Map<Id, OpportunityLineItem> oldMap = (Map<Id, OpportunityLineItem>)triggerOldMap;
        Map<Id, OpportunityLineItem> newMap = (Map<Id, OpportunityLineItem>)triggerNewMap;
        Set<Id> opportunityLinesWithChanges = new Set<Id>(); // Opportunity lines where Size or Description were changed

        for(Id opporunityLineId: newMap.keySet()){
            if(newMap.get(opporunityLineId).Size__c != oldMap.get(opporunityLineId).Size__c || newMap.get(opporunityLineId).Item_Description__c != oldMap.get(opporunityLineId).Item_Description__c){
                opportunityLinesWithChanges.add(opporunityLineId);
            }
        }

        if(opportunityLinesWithChanges.isEmpty()) return;

        List<AcctSeed__Billing_Line__c> relatedBillingLinesToOpportunityLines = [SELECT id, 
                                                          AcctSeed__Opportunity_Product_Id__c, 
                                                          Size_Custom__c,Item_Description__c
                                                    FROM AcctSeed__Billing_Line__c
                                                    WHERE AcctSeed__Opportunity_Product_Id__c IN: opportunityLinesWithChanges];

        if(relatedBillingLinesToOpportunityLines.isEmpty()) return;

        for(AcctSeed__Billing_Line__c billingLine: relatedBillingLinesToOpportunityLines){
            if(!newMap.containsKey(billingLine.AcctSeed__Opportunity_Product_Id__c)) continue;

            billingLine.Size_Custom__c = newMap.get(billingLine.AcctSeed__Opportunity_Product_Id__c).Size__c;
            billingLine.Item_Description__c = newMap.get(billingLine.AcctSeed__Opportunity_Product_Id__c).Item_Description__c;
        }

        update relatedBillingLinesToOpportunityLines;
    }


    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [BEFORE DELETE] HELPER METHODS                ]
    // [                                                         ]
    // [---------------------------------------------------------]

    public static void beforeDelete_checkDoLinesHaveRelatedBillingLine(List<SObject> triggerOldList, Map<Id, SObject> triggerOldMap){
        List<OpportunityLineItem> oldList = (List<OpportunityLineItem>)triggerOldList;
        Map<Id, OpportunityLineItem> oldMap = (Map<Id, OpportunityLineItem>)triggerOldMap;

        List<AcctSeed__Billing_Line__c> relatedBillingLinesToOpportunityLines = [SELECT id, 
                                                          AcctSeed__Opportunity_Product_Id__c, 
                                                          Size_Custom__c,Item_Description__c
                                                    FROM AcctSeed__Billing_Line__c
                                                    WHERE AcctSeed__Opportunity_Product_Id__c IN: oldMap.keySet()];

        if(relatedBillingLinesToOpportunityLines.isEmpty()) return;
        Set<Id> opportunityLinesWithRelatedBillingLine = new Set<Id>();
        for(AcctSeed__Billing_Line__c billingLine: relatedBillingLinesToOpportunityLines){
            if(billingLine.AcctSeed__Opportunity_Product_Id__c != null){
                opportunityLinesWithRelatedBillingLine.add(billingLine.AcctSeed__Opportunity_Product_Id__c);
            }
        }

        if(opportunityLinesWithRelatedBillingLine.isEmpty()) return; //If current set is empty, than noone line is associated with billing.

        for(OpportunityLineItem line: oldList){
            if(opportunityLinesWithRelatedBillingLine.contains(line.Id)){
                line.addError('Can not delete Opportunity Line, as it associated with billing line. If you are attemping to transfer opportunity line to optional, delete related billing line.', false);
            }
        }
    }
    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [AFTER DELETE] HELPER METHODS                 ]
    // [                                                         ]
    // [---------------------------------------------------------]

    // [---------------------------------------------------------]
    // [                                                         ]
    // [           [AFTER UNDELETE] HELPER METHODS               ]
    // [                                                         ]
    // [---------------------------------------------------------]

    



    
}