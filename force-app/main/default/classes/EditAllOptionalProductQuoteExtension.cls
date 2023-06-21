public class EditAllOptionalProductQuoteExtension {

    public LIST<Optional_Products_Quote__c> optProdQuoteList {get; set;}
    public String QuoteID {get; set;}

    public EditAllOptionalProductQuoteExtension(ApexPages.StandardController std){
        
        QuoteID = ApexPages.currentPage().getParameters().get('quoteId');
        optProdQuoteList = [select id, Quantity__c, UnitPrice__c, Size__c, Item_Description__c, Product__c, Quote__c
                            from Optional_Products_Quote__c 
                            where Quote__c =: QuoteID];
        System.debug('optProdQuoteList: ' + optProdQuoteList);
    }
    
    public pageReference saveOptionalProd() {
        
        try {
            update optProdQuoteList;
        }
        catch(Exception ex){
            System.debug('exception: ' + ex.getMessage());
            return null;
        }
        return gotoParent();
    }
    
    public pageReference gotoParent() {
        
        PageReference page = new PageReference('/'+QuoteID);
        page.setRedirect(true);
        return page;
        
    }
}