@isTest
public class OpportunityHandlerTest {
    
    @TestSetup static void createData(){
         
        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c(Name = 'Seawin Factory', AcctSeed__Type__c = 'GL Account Variable 1');
        insert av;
             
        //create opportunity One
        Opportunity oppOne = new Opportunity();
        oppOne.Name = 'Test Opportunity One One One';
		oppOne.Shipping_City__c = 'Test City';
        oppOne.Shipping_PostalCode__c = 'Test PostalCode';
        oppOne.StageName = 'Test';
        oppOne.CloseDate = system.today();
        oppOne.GL_Account_Variable_1__c = av.id;
        insert oppOne;
        
        //create opportunity Two
        Opportunity oppTwo = new Opportunity();
        oppTwo.Name = 'Test Opportunity Two Two Two';
		oppTwo.Shipping_City__c = 'Test City';
        oppTwo.Shipping_PostalCode__c = 'Test PostalCode';
        oppTwo.StageName = 'Test';
        oppTwo.CloseDate = system.today();
        oppTwo.GL_Account_Variable_1__c = av.id;
        insert oppTwo;
    } 
    
    @isTest static void checkDuplicate(){
        
        Test.startTest();
        
        Opportunity opp = [Select Id from Opportunity Where Name='Test Opportunity One One One'];        
        opp.Name = 'Test Opportunity Two Two Two';             
        update opp;
                
        Test.stopTest();
    }

}