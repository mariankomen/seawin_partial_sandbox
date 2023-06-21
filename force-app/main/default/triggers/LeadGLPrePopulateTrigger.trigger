trigger LeadGLPrePopulateTrigger on Lead (before insert) {
	if(Trigger.IsInsert && Trigger.IsBefore){
        
        LeadGLPrePopulateHandler.PrePopulate(Trigger.new);
        
    }
}