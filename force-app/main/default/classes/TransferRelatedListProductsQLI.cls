public class TransferRelatedListProductsQLI {
    
    private Id QuoteId {get; set;}
    private LIST<Optional_Products_Quote__c> qlis {get; set;}
    private List<QuoteLineItem> data {get; set;}
    
    public TransferRelatedListProductsQLI(){ 
        
        QuoteId = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'));
        integer count = Integer.valueOf(ApexPages.currentPage().getParameters().get('count'));
         
        set<Id> recordId = new set<Id>();
        
        for(integer i = 0; i < count; i++){
            Id sub = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'+i));
            recordId.add(sub);
        }
        
        qlis = new LIST<Optional_Products_Quote__c>(); 
        
        data = [SELECT Id, Description, Discount, Item_Description__c, QuoteId, Product2Id, Quantity, 
                Size_Error__c, Size__c, UnitPrice, TotalPrice, SubTotal, AlternateImageURL__c, PriceBookEntryId
                FROM QuoteLineItem where Id in :recordId and QuoteId=:QuoteId
               order by sortorder,LineNumber,createddate asc];

        if(data.Size() > 0){
            
            // get the max sortorder
            AggregateResult maxsort = [SELECT MAX(SortOrder__c) 
                 FROM Optional_Products_Quote__c 
                 where Quote__c =: QuoteId];
            
            Integer newsortnumber = (maxsort.get('expr0') == null) ? 1 : Integer.valueOf(maxsort.get('expr0')) + 1;
            
            for(QuoteLineItem qli : data){
                
                Optional_Products_Quote__c opqs = new Optional_Products_Quote__c();
                opqs.Description__c = qli.Description;
                opqs.Item_Description__c = qli.Item_Description__c;
                opqs.Size_Error__c = qli.Size_Error__c;
                opqs.Size__c = qli.Size__c;
                opqs.UnitPrice__c = qli.UnitPrice;
                opqs.Quantity__c = qli.Quantity;
                opqs.Product__c = qli.Product2Id;
                opqs.Quote__c = qli.QuoteId;
                opqs.sortorder__c = newsortnumber;
                opqs.PricebookEntryId__c = qli.PricebookEntryId;
                opqs.AlternateImageURL__c = qli.AlternateImageURL__c;
                qlis.Add(opqs);
                
                newsortnumber++;
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