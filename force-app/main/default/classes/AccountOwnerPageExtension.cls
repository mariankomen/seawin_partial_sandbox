public class AccountOwnerPageExtension {
    
    public String selected {get; set;}
    public Map<String, Sales_Rep__c> optionValues {get; set;}
    public Account acc {get; set;}
    public String retURL {get; set;}
    public String accId {get; set;}
    public User usr {get{

        return [Select Id,Name,contactId from User where Id=:UserInfo.getUserId() Limit 1];
    }}

    public Boolean SalesRepMissing {get; set;}
   

    public AccountOwnerPageExtension(){

        retURL = ApexPages.currentPage().getParameters().get('retURL');
        accId = ApexPages.currentPage().getParameters().get('accId');

        SalesRepMissing = false;

        acc = [Select Id, Name, OwnerId, Owner_Custom__c, Sales_Rep_O__c From Account Where Id =: accId];

        optionValues = new Map<String, Sales_Rep__c>();
        
        for(Sales_Rep__c rep : [Select Name, Team__c From Sales_Rep__c Where Active__c = 'Yes'  order by Name asc]){

            if(rep.Team__c != null && rep.Team__c.contains(acc.OwnerId)){
                optionValues.put(rep.Id, rep);
            }
        }
        acc.Owner_Custom__c = acc.OwnerId;
        setSelected(acc.Sales_Rep_O__c);
    }

    public void setOptionValues(){

        Map<String, Sales_Rep__c> availableRepsList = new Map<String, Sales_Rep__c>();
        
        for(Sales_Rep__c rep : [Select Name, Team__c From Sales_Rep__c Where Active__c = 'Yes'  order by Name asc]){

            if(rep.Team__c != null && rep.Team__c.contains(acc.Owner_Custom__c)){
                availableRepsList.put(rep.Id, rep);
            }
        }

        this.optionValues = availableRepsList;
    }


    public String getSelected(){

        return selected;
    }


    public void setSelected(string repId){

        this.selected = repId;
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
            SalesRepMissing = true;
            return null;
        }

        acc.OwnerId = acc.Owner_Custom__c;
        acc.Sales_Rep_O__c = (Id) selected;

        PageReference page = new PageReference('/apex/AccountPage?id='+acc.id);
        
        try{
            update acc;
            page.setRedirect(true);

        }catch(Exception ex){
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getdmlMessage(0));
            ApexPages.addMessage(msg);

            page = null;
        }
        
        return page;
    }
    
}