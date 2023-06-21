@isTest
public class SalesProcessPathHelperTest {
	
    @TestSetup static void MakeData(){
        
        
    }
    
    @isTest static void runTests(){
        
        Test.setMock(HttpCalloutMock.class, new MockWebServiceCallout());
        
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        
        Test.startTest();
        	SalesProcessPathHelper.Process('Opportunity', 'StageName', recordTypeId);
        Test.stopTest();
    }
}