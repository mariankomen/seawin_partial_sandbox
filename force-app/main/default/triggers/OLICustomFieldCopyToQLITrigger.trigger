trigger OLICustomFieldCopyToQLITrigger on QuoteLineItem (before insert) {
    
    if(trigger.isBefore && trigger.IsInsert){
        OLICustomFieldCopyToQLIHandler.PopulateQLICustomFeilds(trigger.new);
    }
}