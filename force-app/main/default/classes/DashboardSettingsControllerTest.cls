@isTest
public class DashboardSettingsControllerTest {

    @TestSetup static void MakeData(){

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' limit 1]; 
        User u = new User(Alias = 'agreen', Email='agreen@verynew.com', 
            EmailEncodingKey='UTF-8', LastName='Green', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='agreen@verynew.com',
            Dashboard_Settings__c='Sales Dashboard');
        
        insert u;

    }

    @isTest static void runTests(){

        User usr = [select id, name from user where lastname='Green' and 
        Alias='agreen' and email='agreen@verynew.com' limit 1];
        
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', usr.id);

        DashboardSettingsController ctrl = new DashboardSettingsController();

        ctrl.save();
        
        Test.stopTest();
    }

}