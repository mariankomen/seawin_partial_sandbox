public class OpportunityAttachmentEditExtension {

    private string oppId {private get; private set;}
    private opportunity opp {private get; private set;}
    private string parentId {private get; private set;}
    private string retUrl {private get; private set;}
    public string tabname{get; set;}
    Public Boolean SOExist {get; set;}
    
    public OpportunityAttachmentEditExtension(){
        
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