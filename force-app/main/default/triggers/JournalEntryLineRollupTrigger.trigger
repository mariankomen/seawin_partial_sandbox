trigger JournalEntryLineRollupTrigger on AcctSeed__Journal_Entry_Line__c (after insert, after update, after delete) {

    if(Trigger.isAfter){

        if(Trigger.isInsert || Trigger.isUpdate){

            JournalEntryLineRollupHandler.Rollup(Trigger.new, new List<AcctSeed__Recurring_Journal_Entry_Line__c>());
        }else if(Trigger.isDelete){

            JournalEntryLineRollupHandler.Rollup(Trigger.old, new List<AcctSeed__Recurring_Journal_Entry_Line__c>());
        }
    }
}