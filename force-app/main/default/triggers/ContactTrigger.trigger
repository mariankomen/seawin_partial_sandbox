trigger ContactTrigger on Contact (before insert) {
    if(Trigger.IsBefore && Trigger.IsInsert){
        
        GLAssignContactHandler.ProcessIt(Trigger.new);
    }
}