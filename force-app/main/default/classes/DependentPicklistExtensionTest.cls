@isTest
public with sharing class DependentPicklistExtensionTest {
    
    @isTest
    public static void test(){
        DependentPicklistExtension.getDependentPicklistValues(Opportunity.Sub_Stage__c);
        DependentPicklistExtension.getOpportunityStages();
        DependentPicklistExtension.getObjectPicklistMap(Product2.Sub_Category__c);
        // DependentPicklistExtension.getProductCategoriesPicklistMap();
    }
}