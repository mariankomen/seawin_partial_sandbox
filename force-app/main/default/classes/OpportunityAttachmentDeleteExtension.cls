public class OpportunityAttachmentDeleteExtension {

    private string oppId {private get; private set;}
    private string parentId {private get; private set;}
    private string retUrl {private get; private set;}
    Public Boolean SOExist {get; set;}
    
    public OpportunityAttachmentDeleteExtension(){
        
        oppId = ApexPages.currentPage().getParameters().get('id');
        retUrl = ApexPages.currentPage().getParameters().get('retURL');
        
        SOExist = true;
    }
    
    public PageReference back(){
         
        PageReference page = new PageReference(RetURL);
        page.setRedirect(true);
        return page;
    }
    
}