trigger ClonePOTrigger on AcctSeedERP__Purchase_Order__c (after insert) {
    if(Trigger.IsAfter && Trigger.IsInsert){
        
        map<id, id> SourceIdWithCloneIdMap = new map<id, id>();
        for(AcctSeedERP__Purchase_Order__c po : Trigger.new){
            
            if(po.IsClone()){

                SourceIdWithCloneIdMap.put(po.getCloneSourceId(), po.id);
            }
        }
        
        if(SourceIdWithCloneIdMap.size() > 0){
            
            ClonePOHandler.CreateLines(SourceIdWithCloneIdMap);
            
        }
    }
}