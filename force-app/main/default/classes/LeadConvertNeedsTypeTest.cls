@isTest
public class LeadConvertNeedsTypeTest {

    @testSetup static void createData(){
         
        Lead lead = new Lead();
        
        lead.Status = 'New';
        lead.LastName = 'test lead';
        lead.Company = 'test company 1';
        lead.Industry = 'Other';
        lead.LeadSource = 'Build Central';
        lead.Type__c = 'Designer';
        
        insert lead;
        
    }
    
    @isTest static void StartProcess(){
        
        Lead lead = [select id from Lead where LastName = 'test lead' limit 1 ];
        
        test.startTest();
        PageReference pageRef = Page.LeadConvertNeedsTypePage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', lead.id);
        
        ApexPages.StandardController std = new ApexPages.StandardController(lead);
        
        LeadConvertNeedsTypeExtenstion classObj = new LeadConvertNeedsTypeExtenstion(std);
        
        classObj.PageAction();
        classObj.back();
        
        lead.Type__c = null;
        update lead;
        
        LeadConvertNeedsTypeExtenstion classObj2 = new LeadConvertNeedsTypeExtenstion(std);
        
        
        test.stopTest();
    }
    
}