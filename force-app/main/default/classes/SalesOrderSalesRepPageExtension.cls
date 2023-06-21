public class SalesOrderSalesRepPageExtension {
    
    public String selected {get; set;}
    public Map<String, User> optionValues {get; set;}
    public AcctSeedERP__Sales_Order__c so {get; set;}
    public String retURL {get; set;}
    public String soId{get; set;}
    public boolean OwnerMissing {get; set;}
    public string OppId {get; set;}
    public string acctId {get; set;}
    public string ctId {get; set;}

    public String ownerid {get; set;}
    public String salesrepid {get; set;}
    public string RecordType {get; set;}
    public string CustomButton {get; set;}
    public User usr {get{

        return [Select Id,Name,contactId from User where Id=:UserInfo.getUserId() Limit 1];
    }}
   

    public SalesOrderSalesRepPageExtension(){

        retURL = ApexPages.currentPage().getParameters().get('retURL');
        soId = ApexPages.currentPage().getParameters().get('soId');
        oppId = ApexPages.currentPage().getParameters().get('oppId');
        acctId = ApexPages.currentPage().getParameters().get('acctId');
        ctId = ApexPages.currentPage().getParameters().get('ctId');
        RecordType = ApexPages.currentPage().getParameters().get('RecordType');
        CustomButton = ApexPages.currentPage().getParameters().get('custombutton');

        Opportunity opp = new Opportunity();
        Account acct = new Account();
        so = new AcctSeedERP__Sales_Order__c(); 


        OwnerMissing = false;
        optionValues = new Map<String, User>();

        ownerid = null;
        salesrepid = null;
        string salesrepteam = null;

        if(!String.isEmpty(acctId)){

            acct = [Select Id, Name, OwnerId, Sales_Rep_O__c, Sales_Rep_O__r.Team__c From 
            Account Where Id =: acctId Limit 1];

            ownerid = acct.ownerid;
            salesrepid = acct.Sales_Rep_O__c;
            salesrepteam = acct.Sales_Rep_O__r.Team__c;
        }

        if(!String.isEmpty(oppId)){
            opp = [select Id, Name, OwnerId, Sales_Rep_O__c, Sales_Rep_O__r.Team__c from 
            opportunity where id =:oppId Limit 1];
            ownerid = opp.ownerid;
            salesrepid = opp.Sales_Rep_O__c;
            salesrepteam = opp.Sales_Rep_O__r.Team__c;
        }
            
        if(!String.isEmpty(soId)){
            so = [Select Id, Name, OwnerId, Sales_Rep_O__c, Sales_Rep_O__r.Team__c From 
            AcctSeedERP__Sales_Order__c Where Id =: soId Limit 1];

            ownerid = so.ownerid;
            salesrepid = so.Sales_Rep_O__c;
            salesrepteam = so.Sales_Rep_O__r.Team__c;
        }

        if(String.isEmpty(soId)){

            so.OwnerId = ownerid;
            so.Sales_Rep_O__c = salesrepid;
        }
            
        if(String.isNotEmpty(salesrepteam))
            optionValues = getAvailableUsersForTeam(salesrepteam);
            
        setSelected(so.OwnerId);

        so.sales_rep_shadow__c = so.sales_rep_o__c;
    }


    public Map<String, User> getOptionValues(){

        return optionValues;
    }


    public void setOptionValues(){

        Map<String, User> availableUsersList = new Map<String, User>();

        for(Sales_Rep__c rep : [Select Id, Name, Team__c From Sales_Rep__c Where Id =:so.sales_rep_shadow__c limit 1]){
            availableUsersList = getAvailableUsersForTeam(rep.Team__c);
        }
        
        this.optionValues = availableUsersList;
    }


    public Map<String, User> getAvailableUsersForTeam(String teamString){

        Set<String> userIds = getUserIdsInSetFromString(teamString);
        
        Map<String, User> availableUsersList = new Map<String, User>([Select Name From User 
        Where Id In : userIds and isactive = true order by Name asc]);

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


    public PageReference cancel(){
        string newRedirectPath = '';
        try
        {
            URL test = new URL(retURL);
            newRedirectPath = test.getPath();
        }
        catch(System.StringException e)
        {
            newRedirectPath = retURL;
        }
        
        PageReference page = new PageReference(newRedirectPath);
        page.setRedirect(true);

        return page;
    }
    

    public PageReference saveOverride(){

        if(String.isEmpty(selected)){
            OwnerMissing = true;
            return null;
        }

        PageReference page = null;
    
        if(String.isNotEmpty(soId)){

            if(String.isNotEmpty(selected)){
                so.OwnerId = (Id) selected;
                so.Owner_Custom__c = so.OwnerId;
            }
            so.Sales_Rep_O__c = so.sales_rep_shadow__c;

            page = new PageReference('/apex/SalesOrderPage?id='+so.id);

            try{
                update so;
                page.setRedirect(true);

            }catch(Exception ex){
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getdmlMessage(0));
                ApexPages.addMessage(msg);

                page = null;
            }
            
            
        }else{

            String url = '';

            if(CustomButton != null){

                    url = '/apex/createsalesorderscreenpage?id='+OppId+'&retURL='+retURL;
                    url += '&ownerid='+selected+'&salesrepid='+so.sales_rep_shadow__c;


            }else{

                url = '/apex/AddSalesOrder?retURL='+retURL;
                    url += '&ownerid='+selected+'&salesrepid='+so.sales_rep_shadow__c;
                
                if(String.isNotEmpty(acctId))
                    url += '&acctid='+acctId;
                
                if(String.isNotEmpty(oppId))
                    url += '&oppid='+oppId;
                
                if(String.isNotEmpty(ctId))
                    url += '&ctid='+ctId;

                if(String.isNotEmpty(RecordType))
                    url += '&RecordType='+RecordType;
            }

            page = new PageReference(url);
            page.setRedirect(true);

        }
               
        return page;
    }
    
}