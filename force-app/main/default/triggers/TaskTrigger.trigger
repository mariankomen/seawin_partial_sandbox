trigger TaskTrigger on Task (before insert, after insert) {
    if(trigger.isBefore){

        if(trigger.isInsert){

            TaskHandler.BeforeInsert(Trigger.new);
        }
    }else if(trigger.isAfter){

        if(trigger.isInsert){

            TaskHandler.AfterInsert(Trigger.new);
        }
    }
}