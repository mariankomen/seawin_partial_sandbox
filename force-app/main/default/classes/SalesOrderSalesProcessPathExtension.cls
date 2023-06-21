public class SalesOrderSalesProcessPathExtension {
    
    public AcctSeedERP__Sales_Order__c So {public get; private set;}
    
    public map<string, integer> StagePositionMap {get; set;}
    public list<string> StageValuesList {public get; private set;}
    public integer ListLength {public get; private set;}
    
    private ApexPages.StandardController stdController;
    public String redirectUrl {public get; private set;}
    public boolean shouldRedirect {public get; private set;}
    
    public integer sizeOfMap {get; set;}
    public string communityUrl {
        
        get{
            String contactId = [select contactId from user where id =: UserInfo.getUserId() Limit 1][0].contactId;
            
            return contactId == null ? '' : '/sales';
        }
        
    }
    
    public Boolean getrenderList(){
    	return StagePositionMap.containsKey(So.Stage__c);
	}
public boolean hasClearanceStage {get; set;}
    
    public string SoId {get; set;}
    
    public SalesOrderSalesProcessPathExtension(ApexPages.StandardController std){
        
        this.stdController = stdController;
        
        So = new AcctSeedERP__Sales_Order__c();
        StageValuesList = new list<string>();
        StagePositionMap = new map<string, integer>();
        sizeOfMap = 0;
		hasClearanceStage = false;
        
        shouldRedirect = false;
        
        SoId = (string)std.getId();
        
        So = [select id, Stage__c, recordtypeId, recordtype.name,AcctSeedERP__Status__c
              from AcctSeedERP__Sales_Order__c where id =:SoId limit 1];
        
        if(So.RecordTypeId != null){
            
            StagePositionMap = SalesProcessPathHelper.Process('AcctSeedERP__Sales_Order__c', 'Stage__c', So.RecordTypeId);
            StageValuesList.addAll(StagePositionMap.keyset());
        }else{
            
            Schema.DescribeFieldResult fieldResult = AcctSeedERP__Sales_Order__c.Stage__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            Integer i = 1;
            for( Schema.PicklistEntry pickListVal : ple){

                StageValuesList.add(pickListVal.getLabel());
                StagePositionMap.put(pickListVal.getLabel(), i);
                
                i++;
            }
        }
        sizeOfMap = StagePositionMap.size();
    }
    public PageReference changeStage(){
        
        string stageNameIs = ApexPages.currentPage().getParameters().get('stageNameIs'); 
        
        if(stageNameis != null && stageNameIs != So.Stage__c){
            So.Stage__c = stageNameIs;
            
            if(stageNameIs == 'Received'){
                So.AcctSeedERP__Status__c = 'Closed';
            }
            
            update So;
            
            shouldRedirect = true;
            redirectUrl = communityUrl + '/' + So.id;
        }
        
        return null;
    }
}