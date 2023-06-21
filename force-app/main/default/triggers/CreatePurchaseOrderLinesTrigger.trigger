trigger CreatePurchaseOrderLinesTrigger on AcctSeedERP__Purchase_Order__c (after insert) {
    
    if(Trigger.IsAfter && Trigger.IsInsert){
        CreatePurchaseOrderLinesHandler.CreatePurchaseOrderLine();
		/*
        map<id, AcctSeedERP__Purchase_Order__c> NotClonedMap = 
            new map<id, AcctSeedERP__Purchase_Order__c>();
        
        for(AcctSeedERP__Purchase_Order__c po : Trigger.new){
            
            if(!po.IsClone()){ // if its not a cloned purchase order

                NotClonedMap.put(po.id, po);
            }
        }
        
        if(NotClonedMap.size() > 0){
            
            CreatePurchaseOrderLinesHandler.DoCreate(NotClonedMap.values());
            
        }
        */
    }
}