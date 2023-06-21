public with sharing class SalesOrderAttachmentExtension 
{
    private Id attachmentParentID {get; set;}
    public Id attachID {get; set;}
    public Boolean fileCreated {get; set;}
    public string soId {get; set;}
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
    public SalesOrderAttachmentExtension(){
        attachID = apexpages.currentpage().getparameters().get('AttId');
        isExecuted = false;
        soId = apexpages.currentpage().getparameters().get('id');
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
        
        if(isExecuted){
            attachment.Description = '<For Executed purpose>';
        }
        
    	try {
            insert attachment;
        }
    	catch (DMLException e) {
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));
        	return null;
    	}
    	finally {
        	attachment = new Attachment(); 
    	}
    
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Attachment uploaded successfully'));
        AcctSeedERP__Sales_Order__c so = [select id, name from AcctSeedERP__Sales_Order__c where id =: attachmentParentID limit 1];
        Attachment at = [select id, name, BodyLength from Attachment where ParentId =: so.Id
                         order by CreatedDate desc limit 1];
    System.debug('at1: ' + at);
        PageReference page = new PageReference(
            '/apex/SalesOrderAttachmentPage?id='+so.Id+'&parentname='+so.Name+'&pid='+so.Id+'&AttName='+at.Name+'&AttId='+at.Id+'&retURL=/apex/SalesOrderPage?id='+so.Id+'&sfdc.override=1'
        );
        page.setRedirect(true);
        return page;
    }
    
}