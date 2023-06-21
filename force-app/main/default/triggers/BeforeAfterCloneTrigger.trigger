trigger BeforeAfterCloneTrigger on Opportunity (before insert, after insert) {
//     if(trigger.isInsert){
//         if(trigger.isBefore){
//             for(Opportunity opp : Trigger.New) {   
//                 //System.debug('trigger.New before is: ' + Trigger.New);
//                 if(opp.isClone() && opp.Type == 'Template'){
//                     BeforeAfterCloneHandler.ProcessBefore(Trigger.New);
//                   //  System.debug('trigger.New 2 before is: ' + Trigger.New);
//                 }
//             }  
//         }
//         else if(trigger.isAfter){
            
//             //Insert new Opportunity_Dashboard__c record after insert Opportunity records
//             OpportunityDashboardHandler.createNewRecord(Trigger.New);
            

//             //Some logic
//             for(Opportunity opp : Trigger.New) {
                
//                 if(opp.isClone() && opp.Type == 'Template'){
// //                    BeforeAfterCloneHandler.ProcessAfter(Trigger.New);
//                     BeforeAfterCloneHandler.ProcessAfterNotClonedAndTemplate(Trigger.New);
//                     System.debug('after if');
//                 }
//                 else{
//                     System.debug('after else');
//                     BeforeAfterCloneHandler.ProcessAfterNotClonedAndTemplate(Trigger.New);
//                 }
//             }
//         }
//     }

    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
}