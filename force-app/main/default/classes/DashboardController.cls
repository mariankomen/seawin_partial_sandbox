public with sharing class DashboardController {

    public List<String> dashboardList {get; set;}

    public DashboardController() {

        dashboardList = new List<String>();

        User usr = [select Dashboard_Settings__c from User where Id =: UserInfo.getUserId()];
        if(usr != null && usr.Dashboard_Settings__c != null){

            dashboardList = usr.Dashboard_Settings__c.split(';');
        }
    }

}