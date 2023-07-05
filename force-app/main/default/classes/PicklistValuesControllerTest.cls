/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-04-2023
 * @last modified by  : Marian Lyzhychka
**/
@isTest
public class PicklistValuesControllerTest {

    @isTest static void runTest(){

        PicklistValuesController.getFieldDependencies('Product2', 'Category__c', 'Sub_Category__c');

    }
    @isTest static void runTest1(){

        PicklistValuesController.getFieldDependenciesWrap('Product2',
        'Sub_Category__c',
        'Complementary_Category__c');

    }
}