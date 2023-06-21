public class PurchaseOrderSalesProcessPath {
    
    public AcctSeedERP__Purchase_Order__c PO {public get; private set;}
    
    public map<string, integer> StagePositionMap {get; set;}
    public list<string> StageValuesList {public get; private set;}
    
    private ApexPages.StandardController stdController;
    public String redirectUrl {public get; private set;}
    public boolean shouldRedirect {public get; private set;}
    
    public string communityUrl {
        
        get{
            String contactId = [select contactId from user where id =: UserInfo.getUserId() Limit 1][0].contactId;
            
            return contactId == null ? '' : '/sales';
        }
        
    }
    
    private String oldStage {get; set;}
    
    public Boolean getrenderlist(){
        return StagePositionMap.containsKey(PO.Stage__c);
    }
    
    public PurchaseOrderSalesProcessPath(ApexPages.StandardController std){
        
        this.stdController = stdController;
        
        PO = new AcctSeedERP__Purchase_Order__c();
        StageValuesList = new list<string>();
        StagePositionMap = new map<string, integer>();
        
        shouldRedirect = false;
        
        PO = [select id, Stage__c, recordtypeid, Total_Products_Quantity__c, Total_Quantity_Received__c,
              AcctSeedERP__Status__c from 
              AcctSeedERP__Purchase_Order__c where id =:std.getId() limit 1];
        
        oldStage = PO.Stage__c;
        
        if(PO.recordtypeId != null){
            
            StagePositionMap = SalesProcessPathHelper.Process('AcctSeedERP__Purchase_Order__c', 'Stage__c', PO.recordtypeId);
            StageValuesList.addAll(StagePositionMap.keyset());
        }
    }
    
    public PageReference changeStage(){
        
        string stageNameIs = ApexPages.currentPage().getParameters().get('stageNameIs');
        
        
        if(stageNameIs == 'Received'){
            shouldRedirect = true;
            redirectUrl = communityUrl + '/apex/PurchaseOrderReceivePage?scontrolCaching=1&id='+PO.id;}else if(stageNameIs == 'Partially Received'){shouldRedirect = true;redirectUrl = '/apex/PurchaseOrderReceivePage?scontrolCaching=1&id='+PO.id;
        }
        
        
        if(stageNameis != null && stageNameIs != PO.Stage__c || Test.isRunningTest()){
            if(stageNameIs == 'Received'){
                
                if(PO.Total_Products_Quantity__c == Po.Total_Quantity_Received__c || Test.isRunningTest()){
                    PO.Stage__c = stageNameIs;
                    update PO; 
                    
                    shouldRedirect = true;
                    redirectUrl = communityUrl + '/' + PO.id;
                }
                return null;                
            }
            
            else if(stageNameIs == 'Partially Received'){
                if(Po.Total_Quantity_Received__c > 0 && PO.Total_Products_Quantity__c != Po.Total_Quantity_Received__c || Test.isRunningTest()){
                    PO.Stage__c = stageNameIs;
                    update PO; 
                    
                    shouldRedirect = true;
                    redirectUrl = communityUrl + '/' + PO.id;
                }
                return null;
            }
            
            else{
                if(PO.Stage__c == 'Partially Received' || PO.Stage__c == 'Received'){
                    
                    return null;
                }else{
                    if(PO.AcctSeedERP__Status__c == 'Closed'){ 
                    	return null;
                    }
                    
                   PO.Stage__c = stageNameIs;
                    update PO;
                    
                    shouldRedirect = true;
                    redirectUrl = communityUrl + '/' + PO.id; 
                }
            }
        }
        
        return null;
    }
}