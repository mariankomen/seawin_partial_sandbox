public class ProcessApprovalOpportunityHandler {
    
    // send email notification on approved
    public static void Check_Email(List<Opportunity> od, List<Opportunity> nd){
        
        Integer i = 0;
        set<id> OpportunityIds = new set<id>();
        
        for(Opportunity op : nd){
            if(op.approval_status__c != od[i].approval_status__c){
                if(op.approval_status__c == 'Approved' || 
                   op.approval_status__c == 'Rejected'){ // the account has just been sent to approval
                    OpportunityIds.add(op.id);
                }
            }
            i++;
        }
        
        if(!OpportunityIds.isEmpty()){
            
            Send_Email(OpportunityIds);
        } 
    }
    
    @future
    public static void Send_Email(set<id> OpportunityIds){
        
        Organization org = [select id,name from organization limit 1];
        
        map<id, opportunity> OpportunitiesMap = new map<id, opportunity>([select id,Name, 
                                                             approval_status__c from Opportunity
                                                             where id in:OpportunityIds]);
        
        List<ProcessInstance> Opportunities = [SELECT TargetObjectId,
                                          SubmittedBy.Email FROM 
                                          ProcessInstance WHERE TargetObjectId in:OpportunityIds];
        
        if(!Opportunities.isEmpty()){
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            for(ProcessInstance o : Opportunities){
                
                if(OpportunitiesMap.containsKey(o.TargetObjectId)){
                    
                    Opportunity opp = OpportunitiesMap.get(o.TargetObjectId);
                    
                    if(opp.approval_status__c == 'Approved' || 
                       opp.approval_status__c == 'Rejected'){ // the account has just been sent to approval
                           
                           Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                           
                           mail.setToAddresses(new List<String> {o.SubmittedBy.Email});
                           
                           // Specify the address used when the recipients reply to the email. 
                           mail.setReplyTo('no-reply@salesforce.com');
                           
                           // Specify the name used as the display name.
                           mail.setSenderDisplayName(Org.Name);
                           
                           // Specify the subject line for your email address.
                           mail.setSubject('Opportunity has been ' + 
                                           opp.approval_status__c.toLowerCase());
                           
                           // Specify the text content of the email.
                           mail.setPlainTextBody('The opportunity "'+opp.name+'" has been ' + 
                                                 opp.approval_status__c.toLowerCase() + '.');
                           
                           mails.add(mail);
                       }
                }
            }
            
            // Send the email you have created.
            if(!mails.isEmpty()) Messaging.sendEmail(mails);
            
        }
    }
}