public with sharing class SalesRepPageExtension {
    
    public Sales_Rep__c sr {get; set;}
    public List<String> leftSelected {get;set;}
    public List<String> rightSelected {get;set;}
    Map<String, User> leftValues {get; set;}
    Map<String, User> rightValues {get; set;}
    public String selectedUserNames {get; set;}
    public Set<String> inActiveUsers {get; set;}
    private Boolean teamCheckbxPrevValueIsChkd {get; set;}
    private String activeStatusInDB {get; set;}

    public string OldActiveValue {get; set;}
    
    //public List<SelectOption> SelectedValues {get; set;}
    //public List<SelectOption> UnSelectedValues {get; set;}
    
    public SalesRepPageExtension(ApexPages.StandardController std) {
        
        if(!Test.isRunningTest()){
            List<String> fieldNames = new List<String>{'Name', 'Team__c', 'IsTeam__c' ,'Active__c'};
                std.addFields(fieldNames);
        }
        sr = new Sales_Rep__c();
        sr = (Sales_Rep__c)std.getRecord();
        
        activeStatusInDB = sr.Active__c;
        OldActiveValue = sr.Active__c;
       
        Id srId = (Id)std.getId();
        
        leftSelected = new List<String>();
        rightSelected = new List<String>();
        leftValues = new Map<String, User>();
        rightValues = new Map<String, User>();
        
        if(srId != null){
            Set<String> teamIds = getTeamIdsInSetFromString(sr.Team__c);
            rightValues = new Map<String, User>([Select Name, IsActive From User Where (Id In : teamIds) AND 
                                                 (UserType = 'Standard' or usertype = 'PowerPartner') order by Name asc]);
            selectedUserNames = getUserNamesStringFromMap(rightValues);
            inActiveUsers = getInActiveUsersFromMap(rightValues);
            leftValues = getAvailableUsersForTeam(sr.Team__c);
        }
        else{
            leftValues = getAvailableUsersForTeam(null);
        }
    }
    
    public Map<String, User> getAvailableUsersForTeam(String teamString){
        System.debug('teamString: ' + teamString);
        Set<String> unAvailableUsers = new Set<String>();
        if(teamString != null){
            unAvailableUsers.addAll(getTeamIdsInSetFromString(teamString));
        }
        
        Map<String, User> availableUsersList = new Map<String, User>([Select Name From User Where 
                                                                      (Id Not In : unAvailableUsers) AND (UserType = 'Standard' or usertype = 'PowerPartner') 
                                                                      AND IsActive = true order by Name asc]);
        
        return availableUsersList;
    }
    
    
    public Set<String> getTeamIdsInSetFromString(String teamUserString){
        
        Set<String> teamUserSet = new Set<String>();
        if(String.isNotEmpty(teamUserString)){
            List<String> teamUserList = teamUserString.split(';');
            for(String val : teamUserList){
                teamUserSet.add(val);
            }
        }
        
        return teamUserSet;
    }
    
    
    public String getTeamIdsInStringFromSet(Set<String> teamUserSet){
        
        String teamString = '';
        for(String val : teamUserSet){
            teamString += ';' + val; 
        }
        if(teamString.length() > 1){
            teamString = teamString.substring(1);
        }
        
        return teamString;
    }
    
    
    public String getUserNamesStringFromMap(Map<String, User> teamUserMap){
        
        String userNameString = '';
        for(User usr : teamUserMap.values()){
            userNameString += ';' + usr.Name; 
        }
        if(userNameString.length() > 1){
            userNameString = userNameString.substring(1);
        }
        
        return userNameString;
    }
    
    
    public Set<String> getInActiveUsersFromMap(Map<String, User> teamUserMap){
        
        Set<String> inActiveUsers = new Set<String>();
        for(User usr : teamUserMap.values()){
            if(!usr.IsActive){
                inActiveUsers.add(usr.Id);
            } 
        }
        
        return inActiveUsers;
    }
    
    
    public Pagereference moveToSelected(){

        rightSelected.clear();
        for(String s : leftSelected){
			
            if(leftValues.containsKey(s)){
            	rightValues.put(s, leftValues.get(s));
            	leftValues.remove(s);
            }
        }
        
        return null;
    }
    
    
    public Pagereference moveToUnSelected(){   
        
        leftSelected.clear();
        for(String s : rightSelected){
            leftValues.put(s, rightValues.get(s));
            rightValues.remove(s);
        }
        
        return null;
    }
    
    
    public List<SelectOption> getUnSelectedValues(){
        
        List<SelectOption> options = new List<SelectOption>();
        Set<String> objList = new Set<String>(leftValues.keySet());
        System.debug('objList: ' + objList);
        for(String s : objList){
            options.add(new SelectOption(s, leftValues.get(s).Name));
        }
        
        options = sortSelectOptions(options);
        return options;
    }
    
    
    public List<SelectOption> getSelectedValues(){
        
        List<SelectOption> options = new List<SelectOption>();
        Set<String> objList = new Set<String>(rightValues.keySet());
        for(String s : objList){
            options.add(new SelectOption(s, rightValues.get(s).Name));
        }
        
        options = sortSelectOptions(options);

        return options;
    }
    
    
    public List<SelectOption> sortSelectOptions(List<SelectOption> sortingList) {
        
        for (Integer i = 0; i < sortingList.size(); i++) {
            for (Integer j = i; j > 0; j--) {
                if (sortingList[j-1].getLabel() > sortingList[j].getLabel()){
                    SelectOption temp = sortingList[j];
                    sortingList[j] = sortingList[j-1];
                    sortingList[j-1] = temp;
                }
            }
        }
        
        return sortingList;
    }
    
    public PageReference leftselectionMethod(){
        
        leftSelected = new List<string>();
        
        string leftpickedvalue = ApexPages.currentPage().getparameters().get('leftpickedvalue');
        
        leftSelected.addAll(leftpickedvalue.split(';'));
        
        moveToSelected();
        
        return null;
    }
    
    public PageReference rightselectionMethod(){
        
        rightSelected = new List<string>();
        
        string rightpickedvalue = ApexPages.currentPage().getparameters().get('rightpickedvalue');
        
        rightSelected.addAll(rightpickedvalue.split(';'));
        
        moveToUnSelected();
        
        return null;
    }
    
    
    public Pagereference saveOverride(){
        
        PageReference page;
        
        sr.Team__c = getTeamIdsInStringFromSet(rightValues.keySet());  
        
        sr.Name__c = sr.Name;

        String NewActiveValue = sr.Active__c;

        sr.Active__c = OldActiveValue == 'Yes' && NewActiveValue == 'No' ? OldActiveValue : NewActiveValue;
        
        if(sr.id == null) 
            insert sr;
        else 
            update sr;
        
        List<ApexPage> FunctionalityExists = 
            [select id,name from apexpage where name='SalesRepPageTeamDeselectionPage' Limit 1];

        if(!FunctionalityExists.isEmpty() && activeStatusInDB == 'Yes' && NewActiveValue == 'No') //If previous value in DB was Yes & updated/new value is No
            													//=> User or Team is made inactive
        {
            page = new PageReference('/apex/SalesRepPageTeamDeselectionPage?srId='+sr.id+'&pageIsFor=acc'); 
            page.setRedirect(true);
            return page;
        }
        
        string pageUrl = '/'+sr.id;
        page = new PageReference(pageUrl);
        page.setRedirect(true);
        
        return page;
    }
}