public class CreditOrderSalesProcessPathExtension {
    
    public Credit_Order__c So {public get; private set;}
    
    public map<string, integer> StagePositionMap {get; set;}
    public list<string> StageValuesList {public get; private set;}
    public integer ListLength {public get; private set;}
    
    private ApexPages.StandardController stdController;
    public String redirectUrl {public get; private set;}
    public boolean shouldRedirect {public get; private set;}
    public Decimal billingBalances {get;set;}
    public integer sizeOfMap {get; set;}
    public string communityUrl {
        
        get{
            String contactId = [select contactId from user where id =: UserInfo.getUserId() Limit 1][0].contactId;
            
            return contactId == null ? '' : '/sales';
        }
        
    }
    
    public String alertMessage {get; set;}
    public Boolean getrenderList(){
    	return StagePositionMap.containsKey(So.Stage__c);
	}
    public boolean hasClearanceStage {get; set;}
    
    public string CoId {get; set;}
    
    public CreditOrderSalesProcessPathExtension(ApexPages.StandardController std){
        
        this.stdController = stdController;
        
        So = new Credit_Order__c();
        StageValuesList = new list<string>();
        StagePositionMap = new map<string, integer>();
        sizeOfMap = 0;
		hasClearanceStage = false;
        
        shouldRedirect = false;
        
        CoId = (string)std.getId();
        
        So = [select id, Stage__c, Status__c
              from Credit_Order__c where id =:CoId limit 1];
        
        
            
        Schema.DescribeFieldResult fieldResult = Credit_Order__c.Stage__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        Integer i = 1;
        for( Schema.PicklistEntry pickListVal : ple){

            StageValuesList.add(pickListVal.getLabel());
            StagePositionMap.put(pickListVal.getLabel(), i);
            
            i++;
        }
        checkBillingMemoBalances();
        sizeOfMap = StagePositionMap.size();
    }

    public void checkBillingMemoBalances(){
        Decimal total = 0.00;
        List<AcctSeed__Billing__c> memos = [SELECT Id, AcctSeed__Balance__c, AcctSeed__Status__c FROM AcctSeed__Billing__c WHERE Credit_Order__c=:So.Id];
        Integer unpostedCount = 0;
        if(!memos.isEmpty()){
            for(AcctSeed__Billing__c bill:memos){
                if(bill.AcctSeed__Status__c == 'Posted'){
                    total += bill.AcctSeed__Balance__c;
                }else{
                    unpostedCount++;
                }
            }
        }
        
        billingBalances = unpostedCount == 0 ? total : 1; //1 is random value, it set > 0 because on frontend we check all posted billings
    }

    
    public PageReference changeStage(){
        
        string stageNameIs = ApexPages.currentPage().getParameters().get('stageNameIs'); 
        
        if(stageNameis != null && stageNameIs != So.Stage__c){
            
            So.Stage__c = stageNameIs;
            
            try{
                update so;

                shouldRedirect = true;
                redirectUrl = communityUrl + '/' + So.id;
            }catch(Exception e){
                alertMessage = e.getMessage();
                system.debug(e.getMessage());
            }
            
            
        }
        
        return null;
    }
}