public class OpportunitySalesRepPageExtension {
    
    public String selected {get; set;}
    public Map<String, User> optionValues {get; set;}
    public Opportunity opp {get; set;}
    public String retURL {get; set;}
    public String oppId{get; set;}
    public string proceed {get; set;}
    public string createproducts {get; set;}
    public string RecordType {get; set;}
    public string acctId {get; set;}
    public string glvar {get; set;}
    public boolean OwnerMissing {get; set;}
    public User usr {get{

        return [Select Id,Name,contactId from User where Id=:UserInfo.getUserId() Limit 1];
    }}
   

    public OpportunitySalesRepPageExtension(){

        retURL = ApexPages.currentPage().getParameters().get('retURL');
        acctId = ApexPages.currentPage().getParameters().get('id');
        oppId = ApexPages.currentPage().getParameters().get('oppId');
        proceed = ApexPages.currentPage().getParameters().get('continue');
        createproducts = ApexPages.currentPage().getParameters().get('createproducts');
        RecordType = ApexPages.currentPage().getParameters().get('RecordType');

        OwnerMissing = false;

        // get all record types for opportunity

        opp = new Opportunity();

        string owner = null;
        string salesrep = null;
        string recName = null;

        optionValues = new Map<String, User>();

        if(!String.isEmpty(oppId)){

            opp = [Select Id, Name, OwnerId, Sales_Rep_O__c From Opportunity Where Id =: oppId Limit 1];
            owner = opp.ownerId;
            salesrep = opp.Sales_Rep_O__c;

            
        }else{
            if(!String.isEmpty(acctId)){
                Account acct = [select id,name,ownerid,sales_rep_o__c,Sales_Rep_Record_Type__c,
                                acctseed__gl_account_variable_1__r.name 
                from Account where id=:acctId Limit 1];
                owner = acct.ownerId;
                salesrep = acct.Sales_Rep_O__c;
                opp.sales_rep_o__c = acct.Sales_Rep_O__c;
                glvar = acct.AcctSeed__GL_Account_Variable_1__c;

                recName = acct.Sales_Rep_Record_Type__c != null ?
                acct.Sales_Rep_Record_Type__c : acct.AcctSeed__GL_Account_Variable_1__r.name == 'Seawin USA' ? 'Seawin USA Hospitality' :
                'Seawin China Hospitality';

                // if GL Account Variable 1 is empty on related Account then take it from Contact, if Opp created from Contact

                if(String.isEmpty(glvar) && ((id)retURL.replace('/', '')).getSObjectType().getDescribe().getName() == 'Contact'){

                    List<Contact> cts = new List<Contact>();
                    cts = 
                    [select id, name, gl_account_variable_1__r.name from contact where id=:retURL.replace('/','') Limit 1];

                    if(!cts.isEmpty()){

                        if(cts[0].gl_account_variable_1__c != null){

                            glvar = cts[0].gl_account_variable_1__c;
                        }
                    }
                }else if(String.isEmpty(glvar) && ((id)retURL.replace('/', '')).getSObjectType().getDescribe().getName() == 'Account'){

                    // if GL Account Variable 1 is empty on related Account, take it from CreatedBy user if Opp created from Account
                    User usr = [select id, Default_GL_Account_Variable__c from user where id=:userinfo.getuserid() limit 1];

                    List<string> glList = usr.default_gl_account_variable__c.split(';');

                    if(glList.size() == 1){

                        List<AcctSeed__Accounting_Variable__c> avs = new List<AcctSeed__Accounting_Variable__c>();

                        avs = [Select Id from AcctSeed__Accounting_Variable__c where
                        name =:glList[0] Limit 1];

                        if(!avs.isEmpty()){

                            glvar = avs[0].id;
                        }
                    }

                }
            }else{

                if(((id)retURL.replace('/', '')).getSObjectType().getDescribe().getName() == 'Contact'){

                    Contact ct = [select id, name, gl_account_variable_1__r.name from contact where id=:retURL.replace('/','') Limit 1];

                    recName = ct.GL_Account_Variable_1__r.name == 'Seawin USA' ? 'Seawin USA Hospitality' :
                    'Seawin China Hospitality';

                    glvar = ct.GL_Account_Variable_1__c;
                }
            }

            if(String.isEmpty(RecordType))
            RecordType = 
                Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recName).getRecordTypeId();
        }

        if(!String.isEmpty(salesrep)){
            for(Sales_Rep__c rep : [Select Id, Name, Team__c From Sales_Rep__c Where Id =:salesrep limit 1]){
                optionValues = getAvailableUsersForTeam(rep.Team__c);
            }
        }
        
        if(!String.isEmpty(owner)) setSelected(owner);

        opp.sales_rep_shadow__c = opp.sales_rep_o__c;
    }

    public void setOptionValues(){

        Map<String, User> availableUsersList = new Map<String, User>();

        for(Sales_Rep__c rep : [Select Id, Name, Team__c From Sales_Rep__c Where Id =:opp.sales_rep_shadow__c limit 1]){
            availableUsersList = getAvailableUsersForTeam(rep.Team__c);
        }
        
        this.optionValues = availableUsersList;
    }

    public Map<String, User> getAvailableUsersForTeam(String teamString){

        Set<String> userIds = getUserIdsInSetFromString(teamString);
        
        Map<String, User> availableUsersList = new Map<String, User>([Select Name From User 
                                                                      Where Id In : userIds and 
                                                                      isactive = true order by Name asc]);

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

        if(oppId != null){

            Boolean ExceptionHasOccurred = false;

            if(String.isNotEmpty(selected) && proceed == null){
                opp.OwnerId = (Id) selected;
                opp.Owner_Custom__c = opp.OwnerId;
                
                try{
                    opp.Sales_Rep_O__c = opp.sales_rep_shadow__c;
                    update opp; 
                }catch(Exception ex){
                    ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getdmlMessage(0));
                    ApexPages.addMessage(msg);

                    ExceptionHasOccurred = true;
                }
            }
            if(ExceptionHasOccurred){

                page = null;

            }else{
                if(proceed == null){
                
                    page = new PageReference('/apex/OpportunityPage?id='+opp.id);
                }else{
                    proceed += '&ownerid='+selected+'&salesrepid='+opp.sales_rep_shadow__c+'&createproducts='+createproducts;
                    page = new PageReference(proceed);
                }
                page.setRedirect(true);
            }    
    }else{

        String url = '/apex/OpportunityCreatePage?acctId='+acctId+
        '&salesrepid='+opp.sales_rep_shadow__c+'&recordtypeId='+
        RecordType+'&retURL='+retURL;

        if(!String.isEmpty(selected))
            url+= '&ownerid='+selected;

        if(!String.isEmpty(glvar))
            url += '&gl='+glvar;

        page = new PageReference(url);
        page.setRedirect(true);
    }
                
        return page;
    }
    
}