public without sharing class OpportunityLineItemAlternateImgExtension {
    public blob content {
        get; set;
    }
    public string contentType {
        get; set;
    }
    public string contentName {
        
        get; set;
    }
    public string prodId {get; set;}
    public OpportunityLineItemAlternateImgExtension(){
         
    }
    public PageReference upload(){
        
        string docId = null;
        
        if(content == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select an image.'));
            return null;
        }
        
        prodId = ApexPages.currentPage().getParameters().get('prodId');
       
		Folder foldr = [select id from Folder where name = 'Custom Images' limit 1];

		Document doc = new Document();
        doc.AuthorId = UserInfo.getUserId(); 
        doc.FolderId = foldr.Id;
        doc.Name = contentName;
        doc.Type = '.' + ContentType.split('/')[1];
        doc.ContentType = ContentType;
        doc.body = content;
 
        try {
			insert doc;
			docId = doc.id;
        }
        catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        } 
        finally {
           content = null;
           contentType = null;
           contentName = null;
            
        }
        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'File uploaded successfully'));
        PageReference page = new PageReference('/apex/OpportunityLineItemAlternateImagePage?prodId='+ prodId+'&docId='+docId);
        page.setRedirect(true);
        return page;
    }
}