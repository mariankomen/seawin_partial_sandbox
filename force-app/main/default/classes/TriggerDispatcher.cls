public with sharing class TriggerDispatcher {
    
    public static void run(String triggerClassName){
         
        Trigger_Manage_Controll__mdt metadataConfig = Trigger_Manage_Controll__mdt.getInstance(triggerClassName);
        if(metadataConfig == null) return;

        TriggerHandler handler = new TriggerHandler(metadataConfig.Trigger_Helper__c);

        if (handler.IsDisabled() || !metadataConfig.Is_Active__c){
            return;
        }

        switch on Trigger.operationType {
                
            when BEFORE_INSERT {
                
                if(metadataConfig.Before_Insert__c) handler.beforeInsert(trigger.new);
            }
            when AFTER_INSERT {
                if(metadataConfig.After_Insert__c) handler.afterInsert(trigger.new, trigger.newMap);
            }
            when BEFORE_UPDATE {
                if(metadataConfig.Before_Update__c) handler.beforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            }
            when AFTER_UPDATE {
                if(metadataConfig.After_Update__c) handler.afterUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            }
            when BEFORE_DELETE {
                if(metadataConfig.Before_Delete__c) handler.beforeDelete(trigger.old, trigger.oldMap);
            }
            when AFTER_DELETE {
                if(metadataConfig.After_Delete__c) handler.afterDelete(trigger.old, trigger.oldMap);
            }
            when AFTER_UNDELETE {
                if(metadataConfig.After_Undelete__c) handler.afterUnDelete(trigger.new, trigger.newMap);
            }
        }
    }

}