trigger JournalEntryLineTrigger on AcctSeed__Journal_Entry_Line__c (before insert) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        
        JournalEntryLineHandler.BeforeHandler(Trigger.new);
    }
}