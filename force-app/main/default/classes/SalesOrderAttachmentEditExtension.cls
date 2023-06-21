public class SalesOrderAttachmentEditExtension {
    private string soId {private get; private set;}
    private string parentId {private get; private set;}
    private string retUrl {private get; private set;}
    Public Boolean SOHasOpp {get; set;}
    
    public SalesOrderAttachmentEditExtension(){
        
        soId = ApexPages.currentPage().getParameters().get('id');
        retUrl = ApexPages.currentPage().getParameters().get('retURL');
        
        SOHasOpp = true;
    }
    
    public PageReference back(){
         
        PageReference page = new PageReference(RetURL);
        page.setRedirect(true);
        return page;
    }
    
}