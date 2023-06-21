@isTest
public class PicklistValuesControllerTest {

    @isTest static void runTest(){

        PicklistValuesController.getFieldDependencies('Product2', 'Category__c', 'Sub_Category__c');

    }
}