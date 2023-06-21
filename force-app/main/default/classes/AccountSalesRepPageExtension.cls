public class AccountSalesRepPageExtension {
    
    public String selected {get; set;}
    public Map<String, User> optionValues {get; set;}
    public Account acc {get; set;}
    public String retURL {get; set;}
    public String accId{get; set;}
    public boolean OwnerMissing {get; set;}
    public User usr {get{

        return [Select Id,Name,contactId from User where Id=:UserInfo.getUserId() Limit 1];
    }}
   

    public AccountSalesRepPageExtension(){

        retURL = ApexPages.currentPage().getParameters().get('retURL');
        accId = ApexPages.currentPage().getParameters().get('accId');

        OwnerMissing = false;

        List<Account> accts = new List<Account>();
        acc = new Account();

        accts = [Select Id, Name, OwnerId, Sales_Rep_O__c, sales_rep_shadow__c From Account Where Id =: accId];

        optionValues = new Map<String, User>();

        if(!accts.isEmpty()){

            acc = accts[0];

            acc.sales_rep_shadow__c = acc.Sales_Rep_O__c;

            //acc = [Select Id, Name, OwnerId, Sales_Rep_O__c From Account Where Id =: accId];

            for(Sales_Rep__c rep : [Select Id, Name, Team__c From Sales_Rep__c Where Id =:acc.sales_rep_shadow__c limit 1]){
                optionValues = getAvailableUsersForTeam(rep.Team__c);
            }
        
            setSelected(acc.OwnerId);

            
        }
    }

    public void setOptionValues(){

        Map<String, User> availableUsersList = new Map<String, User>();
        
        for(Sales_Rep__c rep : [Select Id, Name, Team__c From Sales_Rep__c Where Id =:acc.sales_rep_shadow__c limit 1]){
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

        if(acc.Name != null){

            if(String.isNotEmpty(selected)){
                acc.OwnerId = (Id) selected;
                acc.Owner_Custom__c = acc.OwnerId;
            }
            acc.Sales_Rep_O__c = acc.sales_rep_shadow__c;

            page = new PageReference('/apex/AccountPage?id='+acc.id);
            
            try{
                update acc;
                page.setRedirect(true);

            }catch(Exception ex){
                ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getdmlMessage(0));
                ApexPages.addMessage(msg);

                page = null;
            }
        }else{
            string url = 
            '/apex/AccountCreatePage?salesrepid='+acc.sales_rep_shadow__c+'&ownerid='+selected+'&retURL=/001/o';
            url += '&sfdc.override=1&isSelectScreen=str';
            page = new PageReference(url);

            page.setRedirect(true); 
            
        }
               
        return page;
    }
    
}