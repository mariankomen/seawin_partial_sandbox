/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-03-2023
 * @last modified by  : Marian Lyzhychka
**/
@isTest
public with sharing class SalesRepTeamControllerTest {
    
    @TestSetup
    static void makeData(){
        Profile pf = [Select Id from profile where Name = 'System Administrator'];
        
        String orgId = UserInfo.getOrganizationId(); 
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId = Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName = orgId + dateString + RandomId; 
        
        User uu1 = new User(firstname = 'ABC', 
                            lastName = 'XYZ', 
                            email = uniqueName + '@test' + orgId + '.org', 
                            Username = uniqueName + '@test' + orgId + '.org', 
                            EmailEncodingKey = 'ISO-8859-1', 
                            Alias = uniqueName.substring(18, 23), 
                            TimeZoneSidKey = 'America/Los_Angeles', 
                            LocaleSidKey = 'en_US', 
                            LanguageLocaleKey = 'en_US', 
                            ProfileId = pf.Id
                           ); 
        
        insert uu1;
        
        Sales_rep__c sr = new Sales_rep__c();
        sr.Active__c = 'Yes';
        sr.Name = 'John Doe';
        sr.User__c = uu1.id;
        sr.Team__c = uu1.id;
        insert sr;
    }

    @isTest
    static void getSalesRepTeamMembersTest(){
        Sales_rep__c rep = [SELECT Id FROM Sales_rep__c LIMIT 1];
        SalesRepTeamController.getSalesRepTeamMembers(rep.Id);
    }
}