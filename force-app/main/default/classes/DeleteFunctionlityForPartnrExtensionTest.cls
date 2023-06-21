@isTest
public class DeleteFunctionlityForPartnrExtensionTest {
    
    
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
        
        // create contact
        Contact cont = new Contact();
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        cont.LeadSource = 'AAOHA 2020';
        cont.GL_Account_Variable_1__c = accVar.Id;
        insert cont;
        
        Case casee = new Case();
        casee.Subject = 'sub1';
        casee.Status = 'New';
        casee.Origin = 'Web';
        casee.ContactId = cont.id;
        insert casee;
    }
    
    @isTest static void StartProcess(){
        
        Account acc = [select id from account
                       where name = 'myAccount' limit 1];
        
        Contact con = [select id from Contact
                       where AccountId =: acc.Id limit 1];
        
        Case casee = [select id from Case
                     where contactid =: con.Id limit 1];
        
        test.startTest();
        
        PageReference pageRef = Page.DeleteFunctionalityForPartnerPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('object', 'case');
        ApexPages.currentPage().getParameters().put('id', casee.id);
        DeleteFunctionalityForPartnrExtension obj1 = new DeleteFunctionalityForPartnrExtension();
        obj1.deleteRecord();
        
        ApexPages.currentPage().getParameters().put('object', 'contact');
        ApexPages.currentPage().getParameters().put('id', con.id);
        DeleteFunctionalityForPartnrExtension obj2 = new DeleteFunctionalityForPartnrExtension();
        obj2.deleteRecord();
        
        ApexPages.currentPage().getParameters().put('object', 'account');
        ApexPages.currentPage().getParameters().put('id', acc.id);
        DeleteFunctionalityForPartnrExtension obj3 = new DeleteFunctionalityForPartnrExtension();
        obj3.deleteRecord();

        ApexPages.currentPage().getParameters().put('object', 'opportunity');
        ApexPages.currentPage().getParameters().put('id', acc.id);
        DeleteFunctionalityForPartnrExtension obj4 = new DeleteFunctionalityForPartnrExtension();
        obj4.deleteRecord();

        ApexPages.currentPage().getParameters().put('object', 'product');
        ApexPages.currentPage().getParameters().put('id', acc.id);
        DeleteFunctionalityForPartnrExtension obj5 = new DeleteFunctionalityForPartnrExtension();
        obj5.deleteRecord();

        ApexPages.currentPage().getParameters().put('object', 'quote');
        ApexPages.currentPage().getParameters().put('id', acc.id);
        DeleteFunctionalityForPartnrExtension obj6 = new DeleteFunctionalityForPartnrExtension();
        obj6.deleteRecord();
        
    }
    
}