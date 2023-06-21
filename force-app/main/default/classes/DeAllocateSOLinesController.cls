public class DeAllocateSOLinesController {
    
    public String soName {get; set;}
    private Id soId {get; set;}
    private set<id> solIdSet {get; set;}
    public boolean showError {get; set;}
    
    public DeAllocateSOLinesController(){
        
        soId = ApexPages.currentPage().getParameters().get('id');
        soName = ApexPages.currentPage().getParameters().get('name');
        integer count = Integer.valueOf(ApexPages.currentPage().getParameters().get('count'));
        
        solIdSet = new set<Id>();
        showError = false;
        
        for(integer i = 0; i < count; i++){
            Id sub = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'+i));
            solIdSet.add(sub); 
        }       
    }
    
    public PageReference deleteInventoryMovements(){
        
        list<AcctSeedERP__Sales_Order_Inventory_Movement__c> solsim = new list<AcctSeedERP__Sales_Order_Inventory_Movement__c>();
        
        solsim = [select id from AcctSeedERP__Sales_Order_Inventory_Movement__c where
                 AcctSeedERP__Sales_order__c =:soName and AcctSeedERP__Sales_Order_Line__c in:solIdSet];
        
        if(!solsim.isEmpty()){
            
            try{
                // All or none
            	delete solsim;
				
                PageReference page = new pagereference('/'+soId);
                page.setRedirect(true);
                return page;
                
            }catch(Exception ex){
                if(ex.getMessage().containsAny('The quantity shipped')){
                    showError = true;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please delete the shipment before deallocating any products becuase the allocated products have already been shipped.'));
                }
            }
        }else{
            showError = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
                                                       'There are no products to de-allocate. There is no quantity allocated.'));
        }
        
        return null;
    }
    public PageReference DoRedirect(){
        
        PageReference page = new pagereference('/'+soId);
        page.setRedirect(true);
        return page;
    }
}