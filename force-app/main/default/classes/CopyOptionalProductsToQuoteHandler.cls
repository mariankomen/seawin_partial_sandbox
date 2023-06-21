public class CopyOptionalProductsToQuoteHandler {
    
    public static void moveOptionalProducts(LIST<Quote> TriggerData){
        
        // get the opportunity id from quote data
        
        Id OppId = TriggerData[0].OpportunityId;
        
        // get the opportunity optional products
        
        LIST<Optional_Products_Opportunity__c> Opt_Oppty_Prods = [SELECT Id, UnitPrice__c, Size__c, 
                                                                     Quantity__c, Product__c, Item_Description__c, 
                                                                     Discount__c, Description__c, sortorder__c, 
                                                                     Pricebookentryid__c,
                                                                  	 AlternateImageURL__c
                                                                     FROM Optional_Products_Opportunity__c 
                                                                     where Opportunity__c =:OppId
                                                                    order by sortorder__c,name,createddate asc];
        LIST<Optional_Products_Quote__c> Opt_Quote_Prods = new LIST<Optional_Products_Quote__c>();
        
        for(Optional_Products_Opportunity__c Opt_Oppty_Prod : Opt_Oppty_Prods){
            
            Optional_Products_Quote__c Opt_Quote_Prod = new Optional_Products_Quote__c();
            
            Opt_Quote_Prod.Quote__c = TriggerData[0].Id;
            Opt_Quote_Prod.UnitPrice__c = Opt_Oppty_Prod.UnitPrice__c;
            Opt_Quote_Prod.Size__c = Opt_Oppty_Prod.Size__c;
            Opt_Quote_Prod.Quantity__c = Opt_Oppty_Prod.Quantity__c;
            Opt_Quote_Prod.Product__c = Opt_Oppty_Prod.Product__c;
            Opt_Quote_Prod.Item_Description__c = Opt_Oppty_Prod.Item_Description__c;
            Opt_Quote_Prod.Discount__c = Opt_Oppty_Prod.Discount__c;
            Opt_Quote_Prod.SortOrder__c = Opt_Oppty_Prod.SortOrder__c;
            Opt_Quote_Prod.Description__c = Opt_Oppty_Prod.Description__c;
            Opt_Quote_Prod.PriceBookEntryId__c  = Opt_Oppty_Prod.Pricebookentryid__c;
            Opt_Quote_Prod.AlternateImageURL__c = Opt_Oppty_Prod.AlternateImageURL__c;
            
            Opt_Quote_Prods.add(Opt_Quote_Prod);

        }
        
        if(Opt_Quote_Prods.size() > 0){
            
            try{
                
                OptionalProductQuoteHandler.executeVarQuote = false;
                insert Opt_Quote_Prods;
            }catch(Exception ex){
                
                system.debug('Exception has occured...');
                system.debug(ex.getMessage());
            }
        }
        
    }

}