public class TransferRelatedListProducts {

    private Id oppId {get; set;}
    private set<Id> idSet {get; set;}
    private List<OpportunityLineItem> olis {get; set;}
    private LIST<Optional_Products_Opportunity__c> data {get; set;}
    
    public TransferRelatedListProducts(){
        
        OppId = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'));
        integer count = Integer.valueOf(ApexPages.currentPage().getParameters().get('count'));
        
        idSet = new set<Id>();
        
        for(integer i = 0; i < count; i++){
            Id sub = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'+i));
            idSet.add(sub); 
        }
        
        olis = new List<OpportunityLineItem>();

        // fetch the selectedRecords data from their respective object
        
        data = [SELECT Id, Name, Description__c, Discount__c, 
                GL_Account_Variable_1__c, GL_Account_Variable_2__c, GL_Account_Variable_3__c, 
                GL_Account_Variable_4__c, Item_Description__c, Opportunity__c, 
                Product__c, Project__c, Quantity__c, Size_Error__c, Size__c, AlternateImageURL__c, 
                UnitPrice__c, TotalPrice__c, SubTotal__c, PriceBookEntryId__c FROM 
                Optional_Products_Opportunity__c where Id in :idSet and Opportunity__c =: OppId
                order by sortorder__c,name,createddate asc];
        
        if(data.Size() > 0){
            
            for(Optional_Products_Opportunity__c opos : data){
                
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.Description = opos.Description__c;
                oli.Item_Description__c = opos.Item_Description__c;
                oli.AcctSeed__Project__c = opos.Project__c;
                oli.AcctSeed__GL_Account_Variable_4__c = opos.GL_Account_Variable_4__c;
                oli.AcctSeed__GL_Account_Variable_3__c = opos.GL_Account_Variable_3__c;
                oli.AcctSeed__GL_Account_Variable_2__c = opos.GL_Account_Variable_2__c;
                oli.AcctSeed__GL_Account_Variable_1__c = opos.GL_Account_Variable_1__c;
                oli.Size_Error__c = opos.Size_Error__c;
                oli.Size__c = opos.Size__c;
                oli.UnitPrice = opos.UnitPrice__c;
                oli.Quantity = opos.Quantity__c;
                oli.Product2Id = opos.Product__c;
                oli.OpportunityId = opos.Opportunity__c;
                oli.AlternateImageURL__c = opos.AlternateImageURL__c;
                oli.PricebookEntryId = opos.PricebookEntryId__c;
                
                olis.Add(oli);
            }
        }
    }
    public PageReference dmlOperation() {
        if(olis.Size() > 0 && data.Size() > 0){     
              // insert to OpportunityLineItem
              insert olis;
              // remove from Optional_Products_Opportunity
              delete data;
            
             // Resort(); // this is already happening in the trigger OptionalProductOppTrigger
        }
        PageReference retURL = new PageReference('/' + oppId);
        retURL.setRedirect(true);
        return retURL;
    }
    
    public void resort(){
        
        list<Optional_Products_Opportunity__c> oplines = [SELECT Id, Name, Item_Description__c, Product__r.name, Quantity__c, 
                 Opportunity__c, UnitPrice__c, Size__c, SortOrder__c, TotalPrice__c 
                 FROM Optional_Products_Opportunity__c 
                 where Opportunity__c =: oppId order by sortorder__c,name,createddate asc];
        
        // iterate over each and set the sorting number starting from one
        if(!oplines.IsEmpty()){
            
            Integer sortnumber = 1;
            for(Optional_Products_Opportunity__c optional : opLines){
                
                optional.sortorder__c = sortnumber;
                sortnumber++;
            }
            
            update opLines;
            
        }
    }
}