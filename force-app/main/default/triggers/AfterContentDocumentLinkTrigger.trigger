trigger AfterContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        
        AfterContentDocumentLinkTriggerHandler.AfterInsert(Trigger.new);
    }
}