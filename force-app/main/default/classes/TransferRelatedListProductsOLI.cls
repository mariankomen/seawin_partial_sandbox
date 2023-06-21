public class TransferRelatedListProductsOLI {
    
    private Id oppId {get; set;}
    private LIST<Optional_Products_Opportunity__c> olis {get; set;}
    private List<OpportunityLineItem> data {get; set;}
    
    public TransferRelatedListProductsOLI(){
        
         OppId = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'));
         integer count = Integer.valueOf(ApexPages.currentPage().getParameters().get('count'));
        
         set<Id> recordId = new set<Id>();
        
        for(integer i = 0; i < count; i++){
            Id sub = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'+i));
            recordId.add(sub);
        }
        
        olis = new LIST<Optional_Products_Opportunity__c>(); 
        
        data = [SELECT Id, Name, Description, Discount, 
                AcctSeed__GL_Account_Variable_1__c, AcctSeed__GL_Account_Variable_2__c, 
                AcctSeed__GL_Account_Variable_3__c, AcctSeed__GL_Account_Variable_4__c, 
                Item_Description__c, OpportunityId, ProductCode, Product2Id, AcctSeed__Project__c, Quantity, 
                Size_Error__c, Size__c, UnitPrice, TotalPrice, SubTotal, AlternateImageURL__c, PriceBookEntryId
                FROM OpportunityLineItem where Id in :recordId and OpportunityId=:OppId
               order by sortorder,name,createddate asc];

        if(data.Size() > 0){
            
            // get the max sortorder
            AggregateResult maxsort = [SELECT MAX(SortOrder__c) 
                 FROM Optional_Products_Opportunity__c 
                 where Opportunity__c =: oppId];
            
            Integer newsortnumber = (maxsort.get('expr0') == null) ? 1 : Integer.valueOf(maxsort.get('expr0')) + 1;
            
            for(OpportunityLineItem oli : data){
                
                Optional_Products_Opportunity__c opos = new Optional_Products_Opportunity__c();
                opos.Description__c = oli.Description;
                opos.Item_Description__c = oli.Item_Description__c;
                opos.Project__c = oli.AcctSeed__Project__c;
                opos.GL_Account_Variable_4__c = oli.AcctSeed__GL_Account_Variable_4__c;
                opos.GL_Account_Variable_3__c = oli.AcctSeed__GL_Account_Variable_3__c;
                opos.GL_Account_Variable_2__c = oli.AcctSeed__GL_Account_Variable_2__c;
                opos.GL_Account_Variable_1__c = oli.AcctSeed__GL_Account_Variable_1__c;
                opos.Size_Error__c = oli.Size_Error__c;
                opos.Size__c = oli.Size__c;
                opos.UnitPrice__c = oli.UnitPrice;
                opos.Quantity__c = oli.Quantity;
                opos.Product__c = oli.Product2Id;
                opos.Opportunity__c = oli.OpportunityId;
                opos.sortorder__c = newsortnumber;
                opos.PricebookEntryId__c = oli.PricebookEntryId;
                opos.AlternateImageURL__c = oli.AlternateImageURL__c;
                
                olis.Add(opos);
                
                newsortnumber++;
            }
        }  
    }
    
    public PageReference dmlOperation() {
        
        if(olis.Size() > 0 && data.Size() > 0){     
              // insert to Optional_Products_Opportunity
              insert olis;
              // remove from OpportunityLineItem
              delete data;
        }
        
        PageReference retURL = new PageReference('/' + oppId);
      	retURL.setRedirect(true);
        
        return retURL;
         
    }
    
}