trigger RecurringJournalEntryLineRollupTrigger on AcctSeed__Recurring_Journal_Entry_Line__c (after insert, after update, after delete) {

    if(Trigger.isAfter){

        if(Trigger.isInsert || Trigger.isUpdate){

            JournalEntryLineRollupHandler.Rollup(new List<AcctSeed__Journal_Entry_Line__c>(), Trigger.new);
        }else if(Trigger.isDelete){

            JournalEntryLineRollupHandler.Rollup(new List<AcctSeed__Journal_Entry_Line__c>(), Trigger.old);
        }
    }
}