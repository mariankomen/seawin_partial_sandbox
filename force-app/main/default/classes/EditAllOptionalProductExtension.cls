public class EditAllOptionalProductExtension {
    
    public LIST<Optional_Products_Opportunity__c> optProdOppList {get; set;}
    public String OppID {get; set;}
    public String OppName{get; set;}

    public EditAllOptionalProductExtension(){
        
        OppID = ApexPages.currentPage().getParameters().get('oppId');
        optProdOppList = [select id, Quantity__c, UnitPrice__c, Size__c, Item_Description__c, Product__c,Opportunity__c
                          from Optional_Products_Opportunity__c 
                          where Opportunity__c =: OppID];
    }
    
    public pageReference saveOptionalProd() {
        
        try {
            update optProdOppList;
        }
        catch(Exception ex){
            System.debug('exception: ' + ex.getMessage());
            return null;
        }
        return gotoParent();
    }
    
    public pageReference gotoParent() {
        
        PageReference page = new PageReference('/'+OppID);
        page.setRedirect(true);
        return page;
        
    }
    
}