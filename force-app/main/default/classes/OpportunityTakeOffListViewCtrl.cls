public class OpportunityTakeOffListViewCtrl {


    public Integer size {get;set;} 
    public Integer noOfRecords {get; set;} 
    public List<SelectOption> paginationSizeOptions {get;set;}
    public List<Opportunity> updatibles {get; set;}

    public string selectedTeam {get; set;}
    public List<SelectOption> TeamTakeOffList { get;set; }

    public List<String> SerchAlphabet {get; set;}
    public String SearchVar { get; set;}
    public string clicked {get; set;}

    public PageReference UpdateTheTeamTakeOff(){

        string OppId = ApexPages.CurrentPage().getParameters().get('oppId');
        string TeamId = ApexPages.CurrentPage().getParameters().get('teamId');

        if(!String.IsNotEmpty(TeamId)) TeamId = null;

        Opportunity opp = [select id, Team_Take_Off__c from Opportunity where id=:OppId Limit 1];

        opp.Team_Take_Off__c = TeamId;
        opp.run_validation_rule__c = true;

        try{

            update opp;

        }catch(Exception ex){

            system.debug(ex.getMessage());
        }

        return null;
    }

    public PageReference save(){

        update updatibles;

        return null;
    }

    public OpportunityTakeOffListViewCtrl(){

        size=50;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5','5'));
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('20','20'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));

        selectedTeam = '';
        clicked = '';
        TeamTakeOffList = new List<SelectOption>();

        SerchAlphabet = new 
        List<string>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',
        'P','Q','R','S','T','U','V','W','X','Y','Z', 'Other', 'All'};

        SearchVar = 'All';

        set<string> profileNames = new set<string>();

        for(OpportunityTakeOffSettings__c setting : OpportunityTakeOffSettings__c.getall().values()){

            profileNames.add(setting.profile_name__c);
        }

        map<Id, Profile> ProfilesMap = new map<Id, Profile>([Select Id from Profile where Name Like:profileNames]);

        List<User> users = [select id,name,usertype from user where isactive=true and 
        (usertype='Standard' or usertype='PowerPartner') and ProfileId in:ProfilesMap.Keyset() 
        order by usertype,name asc];

        TeamTakeOffList.add(new SelectOption('', 'None'));

        for(User usr : users){

            TeamTakeOffList.add(new SelectOption(usr.id, usr.name));
        }

    }

    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {                
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [SELECT Id, Account.Name, Name, LeadSource, CreatedDate, Quote_Due__c,
                      Sent_to_TakeOff_Team__c, Team_Take_Off__c, Team_Take_Off__r.Name, 
                      Awarded_Owner__c, Price_Level__c, Amount, 
                      Sales_Rep_O__c, Owner_Custom__c FROM Opportunity
                      where StageName = 'Take-off' and GL_Account_Variable_1__r.Name = 'Seawin USA'
                      order by Name ASC]));
                setCon.setPageSize(size);  
                noOfRecords = setCon.getResultSize();
            }            
            return setCon;
        }
        set;
    }
     
    //Changes the size of pagination
    public PageReference refreshPageSize() {
         setCon.setPageSize(size);
         return null;
    }
 
    // Initialize setCon and return a list of record    
     
    public List<Opportunity> getOpportunities() {
    
        if(SearchVar == 'All' && clicked == 'clicked'){

            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [SELECT Id, Account.Name, Name, LeadSource, CreatedDate, Quote_Due__c,
                      Sent_to_TakeOff_Team__c, Team_Take_Off__c, Team_Take_Off__r.Name, 
                      Awarded_Owner__c, Price_Level__c, Amount, 
                      Sales_Rep_O__c, Owner_Custom__c FROM Opportunity
                      where StageName = 'Take-off' and GL_Account_Variable_1__r.Name = 'Seawin USA'
                      order by Name ASC]));

            setCon.setPageSize(size);  
            noOfRecords = setCon.getResultSize();
        }else if(SearchVar == 'Other' && clicked == 'clicked'){

            set<string> names = new set<string>{'a%', 'b%', 'c%', 'd%', 'e%', 'f%', 'g%', 'h%', 'i%', 'j%',
            'k%', 'l%', 'm%', 'n%', 'o%', 'p%', 'q%', 'r%', 's%', 't%', 'u%', 'v%', 'w%', 'x%', 'y%', 'z%'};
            
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [SELECT Id, Account.Name, Name, LeadSource, CreatedDate, Quote_Due__c,
                      Sent_to_TakeOff_Team__c, Team_Take_Off__c, Team_Take_Off__r.Name, 
                      Awarded_Owner__c, Price_Level__c, Amount, 
                      Sales_Rep_O__c, Owner_Custom__c FROM Opportunity
                      where StageName = 'Take-off' and GL_Account_Variable_1__r.Name = 'Seawin USA'
                      and (Not Name Like:names)
                      order by Name ASC]));

            setCon.setPageSize(size);  
            noOfRecords = setCon.getResultSize();
        }else if(clicked == 'clicked'){

            String NameStr = SearchVar + '%';

            setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                      [SELECT Id, Account.Name, Name, LeadSource, CreatedDate, Quote_Due__c,
                      Sent_to_TakeOff_Team__c, Team_Take_Off__c, Team_Take_Off__r.Name, 
                      Awarded_Owner__c, Price_Level__c, Amount, 
                      Sales_Rep_O__c, Owner_Custom__c FROM Opportunity
                      where StageName = 'Take-off' and GL_Account_Variable_1__r.Name = 'Seawin USA'
                      and Name Like :NameStr
                      order by Name ASC]));

            setCon.setPageSize(size);  
            noOfRecords = setCon.getResultSize();
        }

        updatibles = (List<Opportunity>) setCon.getRecords();
         return (List<Opportunity>) setCon.getRecords();
    }

    public PageReference Display(){
        clicked = '';
        clicked = ApexPages.currentPage().getParameters().get('alphabetClicked');
        getOpportunities();
        return null;
    }
}