public class TransferRelatedListProductsQuote {
    
    private Id QuoteId {get; set;}
    private set<Id> idSet {get; set;}
    private List<QuoteLineItem> qlis {get; set;}
    private LIST<Optional_Products_Quote__c> data {get; set;}
    
    public TransferRelatedListProductsQuote(){
        
        QuoteId = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'));
        integer count = Integer.valueOf(ApexPages.currentPage().getParameters().get('count'));
        
        idSet = new set<Id>();
        
        for(integer i = 0; i < count; i++){
            Id sub = Id.ValueOf(ApexPages.currentPage().getParameters().get('id' + i));
            idSet.add(sub); 
        }
        
        qlis = new List<QuoteLineItem>();

        // fetch the selectedRecords data from their respective object
        
        data = [SELECT Id, Name, Description__c, Discount__c, Item_Description__c, 
                Quote__c, Product__c, Quantity__c, Size_Error__c, Size__c, UnitPrice__c, 
                TotalPrice__c, SubTotal__c, AlternateImageURL__c, PriceBookEntryId__c FROM Optional_Products_Quote__c 
                where Id in :idSet and Quote__c =: QuoteId
               order by sortorder__c,name,createddate asc];
        
        if(data.Size() > 0){
            
            for(Optional_Products_Quote__c opqs : data){
                
                QuoteLineItem qli = new QuoteLineItem();
                
                qli.Description = opqs.Description__c;
                qli.Item_Description__c = opqs.Item_Description__c;
                qli.Size_Error__c = opqs.Size_Error__c;
                qli.Size__c = opqs.Size__c;
                qli.UnitPrice = opqs.UnitPrice__c;
                qli.Quantity = opqs.Quantity__c;
                qli.Product2Id = opqs.Product__c;
                qli.QuoteId = opqs.Quote__c;
                qli.PricebookEntryId = opqs.PricebookEntryId__c;
                qli.AlternateImageURL__c = opqs.AlternateImageURL__c;
                qlis.Add(qli);
            }
        }
    }
    public PageReference dmlOperation() {
        if(qlis.Size() > 0 && data.Size() > 0){     
              // insert to OpportunityLineItem
              insert qlis;
              // remove from Optional_Products_Opportunity
              delete data;
        }
        PageReference retURL = new PageReference('/' + QuoteId);
        retURL.setRedirect(true);
        return retURL;
    }
}