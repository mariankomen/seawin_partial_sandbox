public class NewPayablesController {
    
    public list<AcctSeed__Account_Payable__c> payables {get; set;}
    public string soId {get; set;}
    
    public NewPayablesController(){
        
        payables = new list<AcctSeed__Account_Payable__c>();
        
        String totalCount = ApexPages.currentPage().getParameters().get('count');
        soId = ApexPages.currentPage().getParameters().get('soId');
        
        if(totalCount != null){
            
            integer count = Integer.valueOf(totalCount);
            
            set<Id> recordIds = new set<Id>();
            
            for(integer i = 0; i < count; i++){
                Id sub = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'+i));
                recordIds.add(sub);
            }
            
            String fields = AllFields.Fields('AcctSeed__Account_Payable__c', new list<string>());
            payables = Database.query('select ' + fields + ' From AcctSeed__Account_Payable__c where id in: recordIds');
            
        }
    }
}