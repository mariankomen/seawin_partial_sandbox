trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {

    TriggerDispatcher.run('OpportunityTrigger');

}