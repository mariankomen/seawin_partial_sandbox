public with sharing class OpportunityAttachmentExtension 
{
    private Id attachmentParentID {get; set;}
    public Id attachID {get; set;}
    public Boolean fileCreated {get; set;}
    public string OppId {get; set;}
    public String selectedCountry {get; set;}
    public Boolean isExecuted{get; set;}
   
    
    
    public static Blob attachmentBody {get; set;} 
    public String attachmentName {get; set;}
    public List<Attachment_DDL_Short_Description__c> ddlShortDescription{get; set;}
       
    public Attachment attachment {
        get {
            if (attachment == null)
                attachment = new Attachment();
            return attachment;
        }
        set;
    }
    public OpportunityAttachmentExtension(){

        System.debug('param is: ' + ApexPages.currentPage().getparameters().get('parentname'));
        attachID = apexpages.currentpage().getparameters().get('AttId');
        isExecuted = false;
        OppId = apexpages.currentpage().getparameters().get('id');
        if(attachID == null)
            fileCreated = false;
        else
            fileCreated = true;
        
    }
    
    public List<SelectOption> getShortDescriptionOptions(){
        List<SelectOption> options = new List<Selectoption>();
        ddlShortDescription = new List<Attachment_DDL_Short_Description__c>();
        ddlShortDescription = Attachment_DDL_Short_Description__c.getall().values();
       
        options.add(new SelectOption('0', 'Please Select'));
        for(Attachment_DDL_Short_Description__c obj : ddlShortDescription){
            options.add(new selectOption(obj.Id, obj.Name));
        } 
        
        return options;
    }
    
    public PageReference upload_Process(){
        
        return null;
    }
    public PageReference done_Process(){
        
        return null;
    }
    public PageReference upload() {
        attachmentParentID = apexpages.currentpage().getparameters().get('id');
        attachment.OwnerId = UserInfo.getUserId();
    	attachment.ParentId = attachmentParentID;
    	attachment.IsPrivate = false;
        // added these two new lines
        attachment.name = attachmentName;
        attachment.body = attachmentBody;
        
        System.debug('attachmentParentID: ' + attachmentParentID);
        System.debug('OwnerId: ' + attachment.OwnerId);
        System.debug('ParentId: ' + attachment.ParentId);
        System.debug('IsPrivate: ' + attachment.IsPrivate);
        System.debug('name: ' + attachment.name);
        System.debug('body: ' + attachmentBody);
        System.debug('isExecuted: ' + isExecuted);
        
        if(isExecuted){
            attachment.Description = '<For Executed purpose>';
        }
       System.debug('Description: ' + attachment.Description);
        
    	try {
            insert attachment;
        }
    	catch (DMLException e) {
            System.debug('e is: '  + e.getMessage());
            System.debug('e cause is: ' + e.getCause());
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        	return null;
    	}
    	finally {
        	attachment = new Attachment(); 
    	}
    
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
        Opportunity op = [select id, name from Opportunity where id =: attachmentParentID limit 1];
        Attachment at = [select id, name, BodyLength from Attachment where ParentId =: op.Id
                         order by CreatedDate desc limit 1];
    
        PageReference page = new PageReference(
            '/apex/OpportunityAttachmentPage?id='+op.Id+'&parentname='+EncodingUtil.urlEncode(op.name, 'UTF-8')+'&pid='+op.Id+'&AttName='+EncodingUtil.urlEncode(at.Name, 'UTF-8')+'&AttId='+at.Id+'&retURL=/apex/OpportunityPage?id='+op.Id+'&sfdc.override=1'
        );
        page.setRedirect(true);
        return page;
    }
}