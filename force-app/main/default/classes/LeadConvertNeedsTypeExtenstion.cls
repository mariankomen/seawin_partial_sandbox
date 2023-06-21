public class LeadConvertNeedsTypeExtenstion {
    
    public Lead lead{get; set;}
    public Id LeadId{get; set;}
    public Boolean showTypeErrorMessage{get; set;}
    
    public LeadConvertNeedsTypeExtenstion(ApexPages.StandardController std){
       
        showTypeErrorMessage = false;
        LeadId = (id)std.getId();
        
        lead = new Lead();
        lead = [select id, name, Type__c from Lead where id =: LeadId];
        
        if(lead.Type__c == null){
            showTypeErrorMessage = true;
        }
        System.debug('showTypeErrorMessage: ' + showTypeErrorMessage);        
    }
    
    public PageReference PageAction(){
       
        if(!showTypeErrorMessage){
             
            PageReference page = new Pagereference('/lead/leadconvert.jsp?retURL='+LeadId+'&nooverride=1&id='+LeadId); 
            page.setRedirect(true); 
            return page; 
        }
        return null;
    }
    
    public PageReference back(){
        
        PageReference page = new Pagereference('/'+LeadId); 
        page.setRedirect(true);
        return page;
    }  
}