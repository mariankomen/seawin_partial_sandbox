public class OpportunitySalesProcessPathExtension {
    
    public Opportunity Opp {public get; private set;}
    public boolean OmittedExceptionOccurred {get; set;}
    
    public map<string, integer> StagePositionMap {get; set;}
    public list<string> StageValuesList {public get; private set;}
    
    private ApexPages.StandardController stdController;
    public String redirectUrl {public get; private set;}
    public boolean shouldRedirect {public get; private set;}
    public Map<String, List<String>> dependendPicklistValues {get;set;}
    public String currentStage {get; set;}
    public String currentSubStage {get; set;}
    public string communityUrl {
        
        get{
            String contactId = [select contactId from user where id =: UserInfo.getUserId() Limit 1][0].contactId;
            
            return contactId == null ? '' : '/sales';
        }
        
    }
    
    public Decimal total_bill_balances {get;set;}
    private String oldStage {get; set;}
    public boolean hasClearanceStage {get; set;}
    


    public Boolean isTeamTakeOff {get{
        return [SELECT Id, Team_Take_off__c FROM User WHERE Id=:UserInfo.getUserId()].Team_Take_off__c;
    } set;}
    public Boolean isTeamEstimator {get{
        return [SELECT Id, Team_Estimator__c FROM User WHERE Id=:UserInfo.getUserId()].Team_Estimator__c;
    } set;}
    public Boolean isTeamEngineer {get{
        return [SELECT Id, Team_Engineer__c FROM User WHERE Id=:UserInfo.getUserId()].Team_Engineer__c;
    } set;}

    public Boolean opportunityHasTeamTakeOff{get{
        return Opp.Team_Take_off__c != null ? true : false;
    } set;}
    public Boolean opportunityHasTeamEstimator{get{
        return Opp.Team_Estimator__c != null ? true : false;
    } set;}
    public Boolean opportunityHasTeamEngineer{get{
        return Opp.Team_Engineer__c != null ? true : false;
    } set;}

    public String logginedUserProfile{get{
        String profileName = [SELECT Id, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()].Profile.Name;
        return profileName;
    } set;}
    public Boolean getrenderlist(){
        return StagePositionMap.containsKey(Opp.StageName);
    }
    
    

    public OpportunitySalesProcessPathExtension(ApexPages.StandardController std){
        dependendPicklistValues = DependentPicklistExtension.getDependentPicklistValues(Opportunity.Sub_Stage__c);
        List<String> picklistValues = DependentPicklistExtension.getOpportunityStages();
        total_bill_balances = 0.00;
        for(String pv: picklistValues){
            if(!dependendPicklistValues.containsKey(pv)){
                dependendPicklistValues.put(pv, new List<String>());
            }
        }





        this.stdController = stdController;
        
        Opp = new Opportunity();
        StageValuesList = new list<string>();
        StagePositionMap = new map<string, integer>();
        
        shouldRedirect = false;
        hasClearanceStage = false;
        OmittedExceptionOccurred = false;
        
        Opp = [select id, StageName, recordtypeId, recordtype.name, Loss_Reason__c,
               Approval_Package__c, submittal_approval_date__c, Financial_Clearance__c, Financial_Clearance_Date__c,
               Signed_Sales_Order__c, Contract_Date__c, approval_status__c,Sub_Stage__c,Team_Engineer__c,Team_Estimator__c,Team_Take_off__c,
               Quote_Submitted_Date__c from Opportunity where id =:std.getId() limit 1];

        currentStage = opp.StageName;
        oldStage = opp.StageName;
        currentSubStage = opp.Sub_Stage__c;
        if(Opp.recordtypeId != null){
            
            StagePositionMap = SalesProcessPathHelper.Process('Opportunity', 'StageName', Opp.recordtypeId);
            StageValuesList.addAll(StagePositionMap.keyset());
            
            if(StagePositionMap.containsKey('Pre-Order')) hasClearanceStage = true;
            
        }else{
            
            Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
            Integer i = 1;
            for( Schema.PicklistEntry pickListVal : ple){
                
                if(pickListVal.getLabel() == 'Pre-Order'){
                    
                    hasClearanceStage = true;
                }
                
                StageValuesList.add(pickListVal.getLabel());
                StagePositionMap.put(pickListVal.getLabel(), i);
                
                i++;
            }
        }


        List<AcctSeed__Billing__c> related_bills = [SELECT  Id, 
                                                                    Name,
                                                                    AcctSeed__Total__c,
                                                                    AcctSeed__Balance__c,
                                                                    AcctSeed__Opportunity__c
                                                            FROM AcctSeed__Billing__c
                                                            WHERE AcctSeed__Opportunity__c=:Opp.Id
                                                            ];
                
        Decimal total_bill = 0.00;
        for(AcctSeed__Billing__c bill:related_bills){
            total_bill_balances += bill.AcctSeed__Balance__c;
            total_bill += bill.AcctSeed__Total__c;
        }
    }
    public void CheckUncheck(){
        
        try{
            // Financial Clearance
            if(Opp.Financial_Clearance__c){
                if(Opp.Financial_Clearance_Date__c == null){
                	Opp.Financial_Clearance_Date__c = Date.Today();
                }
            }else{
                if(Opp.Financial_Clearance_Date__c != null){
                	Opp.Financial_Clearance_Date__c = null;
                }
            }
            
            // Approval Package
            if(Opp.Approval_Package__c){
                if(Opp.submittal_approval_date__c == null){
                	Opp.submittal_approval_date__c = Date.Today();
                }
            }else{
                if(Opp.submittal_approval_date__c != null){
                	Opp.submittal_approval_date__c = null;
                }
            }
            
            // Signed Sales Order
            if(Opp.Signed_Sales_Order__c){
                if(Opp.Contract_date__c == null){
                	Opp.Contract_date__c = Date.Today();
                }
            }else{
                if(Opp.Contract_date__c != null){
                	Opp.Contract_date__c = null;
                }
            }
            
          update Opp; 
            
          Opp = [select id, StageName, recordtypeId, recordtype.name, Loss_Reason__c, CloseDate,Closed_Date__c,
               Approval_Package__c, submittal_approval_date__c, Financial_Clearance__c, Financial_Clearance_Date__c,
               Signed_Sales_Order__c, Contract_Date__c,
               Quote_Submitted_Date__c from Opportunity where id =:Opp.Id limit 1];
            
        }catch(Exception ex){
            
            
        }
    }
    public PageReference changeStage(){
        
        string stageNameIs = ApexPages.currentPage().getParameters().get('stageNameIs'); 
        
        List<OpportunityStage> pipelineStages = [SELECT Id, ApiName, ForecastCategory, ForecastCategoryName, IsActive FROM OpportunityStage where ForecastCategory='Pipeline' and IsActive=true];
        List<String> stagesPip = new List<String>();

        for(OpportunityStage ops: pipelineStages){
            stagesPip.add(ops.ApiName);
        }
        if(stageNameis != null && stageNameIs != Opp.StageName){
            /*
            if(oldStage == 'Proposal' && stageNameis == 'Follow up'){
                if(opp.Quote_Submitted_Date__c == null){
                    
                    opp.Quote_Submitted_Date__c = Date.today(); 
                    
                } 
            }
            */
            try{
                List<String> closed_stages = new List<String>{'Closed Won', 'Closed Lost', 'Not Qualified'};
                if(closed_stages.contains(Opp.StageName)){
                    Opp.Closed_Date__c = null;
                }
                Opp.StageName = stageNameIs;
                Opp.Sub_Stage__c = '';
                
                update Opp;
                shouldRedirect = true;
                redirectUrl = communityUrl + '/' + Opp.id;
            }catch(Exception ex){
                
                system.debug('Error: '+ex.getMessage());
                
                string msg = ex.getMessage();
                
                if(msg.contains('Stage cannot be changed, because the billing has been done.')){
                    
                    OmittedExceptionOccurred = true;
                }
                
            }
        }
        
        return null;
    }

    
    public PageReference setOpportunityTeamTakeOff(){
        Opportunity opport = [SELECT Id, Sub_Stage__c,Team_Take_off__c FROM Opportunity WHERE Id=:Opp.Id];
        opport.Team_Take_off__c = UserInfo.getUserId();
        try{
            update opport;
        }catch(Exception e){
            system.debug('235line: '+e.getMessage());
        }
    
        return null;
    }
    public void setOpportunityTeamEstimator(){
        Opp.Team_Estimator__c = UserInfo.getUserId();
        update Opp;
    }
    public void setOpportunityTeamEngineer(){
        Opp.Team_Engineer__c = UserInfo.getUserId();
        update Opp;
    }

    public PageReference updateSubStage(){
        string newSubStage = ApexPages.currentPage().getParameters().get('newStage'); 

        Opportunity opp = [SELECT Id, Sub_Stage__c FROM Opportunity WHERE Id=:Opp.Id];
        opp.Sub_Stage__c = newSubStage;
        update opp;
        redirectUrl = communityUrl + '/' + Opp.id;
        system.debug(redirectUrl);
        return null;
    }
    public PageReference ReAssign(){
        
        OmittedExceptionOccurred = false;
        
        return null;
    }
}