public with sharing class DashboardSettingsController {

    public User usr { get; set; }
    public Map<String, String> allDashboards { get; set; }
    public SelectOption[] selectedDashboards { get; set; }
    public SelectOption[] availableDashboards { get; set; } 
    public String message { get; set; }
    

    public DashboardSettingsController() {

        allDashboards = new Map<String, String>();
        allDashboards.put('Billing Aging Manager Dashboard USA', 'Billing Aging Manager Dashboard USA');
        allDashboards.put('Hospitality Manager Dashboard USA', 'Hospitality Manager Dashboard USA');
        allDashboards.put('Wholesale Manager Dashboard USA', 'Wholesale Manager Dashboard USA');
        allDashboards.put('Online/Drop Shipment Manager Dashboard USA', 'Online/Drop Shipment Manager Dashboard USA');

        allDashboards.put('Billing Aging Manager Dashboard China', 'Billing Aging Manager Dashboard China');
        allDashboards.put('Hospitality Manager Dashboard China', 'Hospitality Manager Dashboard China');
        allDashboards.put('OEM Dashboard China', 'OEM Manager Dashboard China');

        allDashboards.put('Sales Dashboard', 'Sales Dashboard');
        allDashboards.put('Accounting Dashboard', 'Accounting Dashboard USA');
        allDashboards.put('Sales Support Dashboard', 'Sales Support Dashboard');

        allDashboards.put('Specified Dashboard', 'Specified Dashboard');

        selectedDashboards = new List<SelectOption>();
        availableDashboards = new List<SelectOption>();
        String userId = ApexPages.currentPage().getParameters().get('id');
        usr = [select Id, Name, Dashboard_Settings__c from User where Id =: userId];

        if(usr.Dashboard_Settings__c != null){
            List<String> dashboardList = usr.Dashboard_Settings__c.split(';');
            for(String dashboardName : dashboardList){
                selectedDashboards.add(new SelectOption(dashboardName, dashboardName));
            }
        }

        for(String dashboardKey : allDashboards.keySet()){

            if(usr.Dashboard_Settings__c != null && usr.Dashboard_Settings__c.contains(allDashboards.get(dashboardKey))){
            }
            else{
                availableDashboards.add(new SelectOption(dashboardKey, allDashboards.get(dashboardKey)));
            }
		}
    }


    public PageReference save() {

        PageReference page = new PageReference('/apex/DashboardSettingsListingPage');
        
        try{
            String dashboardString = null;
            Boolean first = true;
            for(SelectOption so : selectedDashboards ) {
                if (first) {
                    dashboardString = so.getValue();
                    first = false;
                }
                else{
                    dashboardString += ';' + so.getValue();
                }
            }

            usr.Dashboard_Settings__c = dashboardString;
            update usr;
            page.setRedirect(true);

        }catch(Exception ex){
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, ex.getdmlMessage(0));
            ApexPages.addMessage(msg);

            page = null;
        }
        
        return page;
    }

}