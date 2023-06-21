public with sharing class TriggerHandler implements ITriggerHandler{
    
    public class TriggerHandlerException extends Exception{}

    public String triggerHelperName = '';
    public static Boolean TriggerDisabled = false;
    public ITriggerHelper triggerHelper;

    public TriggerHandler(String triggerHelperName){
        try{
            triggerHelper = (ITriggerHelper)Type.forName(triggerHelperName).newInstance();
        }catch(Exception e){
            throw new TriggerHandlerException('Can not create new instance of helper class. Please check metadata configurations.');
        }
    }

    public Boolean isDisabled(){
        return TriggerDisabled;
    }
     
    public void beforeInsert(List<sObject> newList) {
        if(triggerHelper != null) triggerHelper.beforeInsert(newList);
    }
     
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        if(triggerHelper != null) triggerHelper.afterInsert(newList, newMap);
    }
     
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        if(triggerHelper != null) triggerHelper.beforeUpdate(newList, newMap, oldList, oldMap);
    }
     
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        if(triggerHelper != null) triggerHelper.afterUpdate(newList, newMap, oldList, oldMap);
    }
     
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        if(triggerHelper != null) triggerHelper.beforeDelete(oldList, oldMap);
    }
     
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        if(triggerHelper != null) triggerHelper.afterDelete(oldList, oldMap);
    }
     
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
        if(triggerHelper != null) triggerHelper.afterUnDelete(newList, newMap);
    }

}