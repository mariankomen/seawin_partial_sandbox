trigger DateSubmittedNewStartTrigger on Quote (after insert, after update) {
    if(Trigger.IsAfter){
        if(Trigger.IsInsert){
            
            DateSubmittedNewStartHandler.Process(new List<Quote>(), Trigger.new);
        }else if(Trigger.IsUpdate){
            
            DateSubmittedNewStartHandler.Process(Trigger.old, Trigger.new);
        }
    }
}