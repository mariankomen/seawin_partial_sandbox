public class BeforeDeleteSOHandler {

    public static void AttachSOAttachmentToOpp(List<AcctSeedERP__Sales_Order__c> data){
        
        Map<id, id> soIDsWithOppIDs = new Map<id, id>();//Map <OppID, SOID>
        
        for(AcctSeedERP__Sales_Order__c so : data){
            if(so.AcctSeedERP__Opportunity__c != null){
                soIDsWithOppIDs.put(so.AcctSeedERP__Opportunity__c, so.Id); 
            } 
        } 
        
        if(!soIDsWithOppIDs.isEmpty()){
            
            LIST<Attachment> soAttachments = [select id, IsPrivate, Name, Description, Body, ParentId, ContentType, OwnerId
                                              from Attachment 
                                              where ParentId =: soIDsWithOppIDs.values()];
        
            LIST<Attachment> attList = new List<Attachment>();
        
            for(Attachment att : soAttachments){
                for (Id key : soIDsWithOppIDs.keySet()){
                    if(soIDsWithOppIDs.get(key) == att.ParentId){
                        //Since we can't change ParentId of attachments, we create new attachments having same fields data 
                        //as of SO attachments & reparent it to the parent Opp of SO 
                        Attachment at = new Attachment();
                        at.IsPrivate = att.IsPrivate;
                        at.Name = att.Name;
                        at.Description = att.Description;
                        at.Body = att.Body;
                        at.ParentId = key;
                        at.ContentType = att.ContentType;
                        at.OwnerId = att.OwnerId;
                        attList.add(at);
                    }
                }   
            }
        
            if(!attList.isEmpty()){
                try{
                    insert attList;
                }
                catch(Exception ex){
                    System.debug('Error occured during update is: ' + ex.getMessage());
                }
            }
        
        }
    }
}