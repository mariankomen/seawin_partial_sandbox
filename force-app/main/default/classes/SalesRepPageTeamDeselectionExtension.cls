public class SalesRepPageTeamDeselectionExtension {
    
    public String selected {get; set;}
    public Map<String, User> optionValues {get; set;}
    
    public Sales_Rep__c sr {get; set;}
    public String srId {get; set;}
    public String ownerId {get; set;}
    public boolean OwnerMissing {get; set;}
    public boolean SameSalesRepError {get; set;}
    public boolean DifferentGLError {get; set;}
    
    public boolean AccountsExist {get; set;}
    public boolean OpportunitiesExist {get; set;}
    public boolean SalesOrdersExist {get; set;}
    public boolean OnlyShowPageMessage {get; set;}
    
    public String salesRepPageIsFor {get; set;}
    public User usr {get{
        
        return [Select Id,Name,contactId from User where Id=:UserInfo.getUserId() Limit 1];
    }}
    
    List<Account> updatableAccts {get; set;}
    List<Opportunity> updatableOppts {get; set;}
    List<AcctSeedERP__Sales_Order__c> updatableSOs {get; set;}
    
    public SalesRepPageTeamDeselectionExtension(){

        OnlyShowPageMessage = false;
        
        salesRepPageIsFor = ApexPages.currentPage().getParameters().get('pageIsFor');
        
        srId = ApexPages.currentPage().getParameters().get('srId');
        
        OwnerMissing = false;
        SameSalesRepError = false;
        DifferentGLError = false;
        
        AccountsExist = true;
        OpportunitiesExist = true;
        SalesOrdersExist = true;
        
        List<Account> accts = new List<Account>();
        List<Sales_Rep__c> salesReps = new List<Sales_Rep__c>();
        
        updatableAccts = new List<Account>();
        updatableOppts = new List<Opportunity>();
        updatableSOs = new List<AcctSeedERP__Sales_Order__c>();
        
        sr = new Sales_Rep__c();
        
        salesReps = [select id, name, OwnerId, Sales_Rep_Shadow__c,GL_Account_Variable_to_Sales_Rep__r.Name, 
                     Team__c from Sales_Rep__c where Id =: srId Limit 1];
        
        optionValues = new Map<String, User>();
        
        if(!salesReps.isEmpty()){
            
            sr = salesReps[0];
        }
        
        // show error message on the screen if no records exist
        if(!RecordsExist('Account', sr.id)){
            
            AccountsExist = false;
        }
        
        if(!RecordsExist('Opportunity', sr.id)){
            
            OpportunitiesExist = false;
        }
        
        if(!RecordsExist('AcctSeedERP__Sales_Order__c', sr.id)){
            
            SalesOrdersExist = false;
        }
    }
    
    public void setOptionValues(){
        
        SameSalesRepError = false;
        DifferentGLError = false;
        
        Map<String, User> availableUsersList = new Map<String, User>();
        
        for(Sales_Rep__c rep : [Select Id, Name, Team__c From Sales_Rep__c Where Id =: sr.sales_rep_shadow__c limit 1]){
            availableUsersList = getAvailableUsersForTeam(rep.Team__c);
        }
        
        this.optionValues = availableUsersList;
        
    }
    
    
    public Map<String, User> getAvailableUsersForTeam(String teamString){
        
        Set<String> userIds = getUserIdsInSetFromString(teamString);
        
        Map<String, User> availableUsersList = new Map<String, User>([Select Name From User Where Id In : userIds 
                                                                      and isactive = true order by Name asc]);
        
        return availableUsersList;
    }
    
    
    public Set<String> getUserIdsInSetFromString(String teamUserString){
        
        Set<String> teamUserSet = new Set<String>();
        if(String.isNotEmpty(teamUserString)){
            List<String> teamUserList = teamUserString.split(';');
            for(String val : teamUserList){
                teamUserSet.add(val);
            }
        }
        
        return teamUserSet;
    }
    
    
    public String getSelected(){
        
        return selected;
    }
    
    
    public void setSelected(string ownerId){
        
        this.selected = ownerId;
    }
    
    
    public List<SelectOption> getAllOptionValues(){
        
        List<SelectOption> options = new List<SelectOption>();
        
        Set<String> objList = new Set<String>(optionValues.keySet());
        for(String s : objList){
            
            options.add(new SelectOption(s, optionValues.get(s).Name));
        }
        return options;
    }
    
    public static boolean RecordsExist(String objectName, String salesrepId){
        
        List<sobject> records = Database.query('Select id from ' + objectName + ' where Sales_Rep_o__c =:salesrepId Limit 1');
        
        return records.isEmpty() ? false : true;
    }
    
    public PageReference Save(){
        
        SameSalesRepError = false;
        DifferentGLError = false;
        
        Boolean Checkpoint = false;
        
        PageReference refernce = null;
        
        if(sr.Name != null){
            
            if(String.isNotEmpty(selected)){
                sr.OwnerId = (Id) selected;
                
            } 
            
            if(salesRepPageIsFor == 'acc'){
                
                Boolean FoundErrors = CheckIFAnyProblem(AccountsExist);

                if(FoundErrors) return null;
                
                updatableAccts = new List<Account>();
                List<Account> accts = [Select Id, Sales_Rep_O__c, OwnerId From Account 
                                       Where Sales_Rep_O__c =: srId];
                
                for(Account acc : accts){
                    acc.Sales_Rep_O__c = sr.Sales_Rep_Shadow__c;
                    acc.OwnerId = sr.OwnerId;
                    updatableAccts.add(acc);
                }
                
                sr.Sales_Rep_Shadow__c = null;
                setOptionValues();
                
                salesRepPageIsFor = 'opp';
            }else if(salesRepPageIsFor == 'opp'){
                
                Boolean FoundErrors = CheckIFAnyProblem(OpportunitiesExist);

                if(FoundErrors) return null;
                
                updatableOppts = new List<Opportunity>();
                List<Opportunity> oppts = [Select Id, Sales_Rep_O__c, OwnerId
                                           From Opportunity 
                                           Where Sales_Rep_O__c =: srId and StageName != 'Closed Won'
                                           and StageName != 'Closed Lost' and StageName != 'Not Qualified'];
                
                for(Opportunity opp : oppts){
                    
                    opp.Sales_Rep_O__c = sr.Sales_Rep_Shadow__c;
                    opp.Run_Validation_Rule__c = true;
                    
                    opp.OwnerId = sr.OwnerId;
                    updatableOppts.add(opp);
                    
                }
                
                sr.Sales_Rep_Shadow__c = null;
                setOptionValues();
                
                salesRepPageIsFor = 'so';
            }else if(salesRepPageIsFor == 'so'){
                
                Boolean FoundErrors = CheckIFAnyProblem(SalesOrdersExist);

                if(FoundErrors) return null;
                
                updatableSOs = new List<AcctSeedERP__Sales_Order__c>();
                List<AcctSeedERP__Sales_Order__c> SOs = [Select Id, Sales_Rep_O__c, OwnerId 
                                                         From AcctSeedERP__Sales_Order__c 
                                                         Where Sales_Rep_O__c =: srId and AcctSeedERP__Status__c = 'Open'];
                
                
                for(AcctSeedERP__Sales_Order__c so : SOs){
                    so.Sales_Rep_O__c = sr.Sales_Rep_Shadow__c;
                    so.OwnerId = sr.OwnerId;
                    updatableSOs.add(so);
                }
                
                List<sObject> sobjectList = new List<sObject>();
                
                sobjectList.addAll(updatableAccts);
                sobjectList.addAll(updatableOppts);
                sobjectList.addAll(updatableSOs);
                
                database.executeBatch(new UpdateBatchable(sobjectList, false), 10);
                
                sr.Active__c = 'No';
                
                sr.Sales_Rep_Shadow__c = null;
                
                try{
                    
                    update sr;
                    
                    refernce = new PageReference('/apex/OverrideSalesRepPage?id='+sr.id +'&sfdc.override=1');
                    refernce.setRedirect(true);
                    
                }catch(Exception ex){

                    OnlyShowPageMessage = true;
                    
                    ShowPageError(ex);
                }
                
            }
        }
        
        return refernce;
        
    }
    
    public Boolean CheckIFAnyProblem(Boolean proceed){
        
        if(String.isEmpty(selected) && proceed){
            OwnerMissing = true;
            return true;
        }
             
        if(sr.Sales_Rep_Shadow__c == sr.id){
            SameSalesRepError = true;
            return true;
        }
        
        Sales_Rep__c salesrepshadow = new Sales_Rep__c();
        
        if(sr.Sales_Rep_Shadow__c != null)
            salesrepshadow = [select id, GL_Account_Variable_to_Sales_Rep__r.Name from Sales_Rep__c
                              where id =:sr.Sales_Rep_Shadow__c Limit 1];
        
        Boolean ShowError = (sr.GL_Account_Variable_to_Sales_Rep__r.Name != 'Seawin China' &&
                             salesrepshadow.GL_Account_Variable_to_Sales_Rep__r.Name != 'Seawin Hong Kong') ||
            (sr.GL_Account_Variable_to_Sales_Rep__r.Name != 'Seawin Hong Kong' &&
             salesrepshadow.GL_Account_Variable_to_Sales_Rep__r.Name != 'Seawin China');
        
        if(ShowError && 
           salesrepshadow.GL_Account_Variable_to_Sales_Rep__r.Name!= null && 
           salesrepshadow.GL_Account_Variable_to_Sales_Rep__r.Name 
           != sr.GL_Account_Variable_to_Sales_Rep__r.Name){
               
               DifferentGLError = true;
               return true;
           }
        
        return false;
    }
    
    public PageReference ReturnToSalesRep(){
        
        PageReference reference = new PageReference('/' + sr.id);
        reference.setRedirect(true);
        return reference;
    }
    
    public void ShowPageError(Exception ex){
        
        String errorMsg = ex.getMessage();
        
        string OnlyMsg = errorMsg.substringBetween(', ', ':');
        
        if(OnlyMsg != null){
            
            OnlyMsg = OnlyMsg.capitalize();
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, OnlyMsg);
            ApexPages.addMessage(myMsg);
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
            ApexPages.addMessage(myMsg);
        }
    }
}