@isTest
public class OpportunityRecordTypeExtensionTest {

    @testSetup static void createData(){
        
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
        
        // create account
        Account acct = new Account();
        //acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct;
        
        RecordType recordTypes = new RecordType ();
        recordTypes.Name = 'rec Type 1';
       // insert recordTypes;
    }
    
    @isTest static void StartProcess(){
      
        Account acc = [select id from Account where name = 'myAccount' limit 1];
        
        test.startTest();
		        
        PageReference pageRef = Page.OpportunityRecordTypePage;
        Test.setCurrentPage(pageRef);
		
        ApexPages.currentPage().getParameters().put('GLVariable1', 'Seawin China');
        ApexPages.currentPage().getParameters().put('retURL', acc.id);
        ApexPages.currentPage().getParameters().put('accid', acc.id);
        
        OpportunityRecordTypeExtension obj1 = new OpportunityRecordTypeExtension();
        
        obj1.OnContinue();
        obj1.Cancel();
        
        ApexPages.currentPage().getParameters().put('GLVariable1', 'Seawin Hong Kong');
        ApexPages.currentPage().getParameters().put('OppID', '');
        OpportunityRecordTypeExtension obj2 = new OpportunityRecordTypeExtension();
        obj2.OnContinue();
         
    }
}