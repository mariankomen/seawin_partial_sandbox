public class NewPurchaseOrdersController {
    
    public list<AcctSeedERP__Purchase_Order__c> purchases {get; set;}
    
    public NewPurchaseOrdersController(){
        
        purchases = new list<AcctSeedERP__Purchase_Order__c>();
        
        String totalCount = ApexPages.currentPage().getParameters().get('count');
        
        if(totalCount != null){
            
            integer count = Integer.valueOf(totalCount);
            
            set<Id> recordId = new set<Id>();
            
            for(integer i = 0; i < count; i++){
                Id sub = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'+i));
                recordId.add(sub);
            }
            
            
            purchases = [SELECT Id, Name, AcctSeedERP__Vendor__c, AcctSeedERP__Total__c, AcctSeedERP__Type__c, 
                         AcctSeedERP__Status__c, AcctSeedERP__Order_Date__c 
                         FROM AcctSeedERP__Purchase_Order__c where id in:recordId];
            
        }
    }
}