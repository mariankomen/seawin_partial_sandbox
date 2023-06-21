public class QuoteDeleteExtension {
    
    private string quoteId {private get; private set;}
    private Quote quote {private get; private set;}
    private string retUrl {private get; private set;}
    Public Boolean DeleteErrorMsgQuote {get; set;}
    
    public QuoteDeleteExtension(ApexPages.StandardController std){
        
        retUrl = ApexPages.currentPage().getParameters().get('retURL');
        quoteId = (string)std.getId();
        DeleteErrorMsgQuote = false;
    }
    
    public PageReference TryDelete(){
        
        
        quote = [select id, Opportunity_Sales_Orders__c from Quote where id =: quoteId limit 1];
        
        if(quote.Opportunity_Sales_Orders__c == 0){
            try{
                delete quote;
                PageReference page = new PageReference(retUrl);
                page.setRedirect(true);
                return page;
            }
            catch(Exception ex){
                
            }
        }
        DeleteErrorMsgQuote = true;
        return null;
    }
    
    public PageReference back(){
         
         PageReference page = new PageReference(RetURL);
         page.setRedirect(true);
         return page;
     }
}