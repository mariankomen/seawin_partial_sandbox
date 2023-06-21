//This trigger is used to get all attachments attached to a SO & then attach these attachments to the SO parent Opp
//So that SO are deleted but related attachments are saved from deletion
trigger BeforeDeleteSO on AcctSeedERP__Sales_Order__c (before delete) {

     if(Trigger.isBefore && Trigger.isDelete){
        
         BeforeDeleteSOHandler.AttachSOAttachmentToOpp(Trigger.old);
        
    }
}