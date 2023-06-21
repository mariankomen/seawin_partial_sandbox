@isTest
public class OpportunityTakeOffListViewCtrlTest {
    
    @TestSetup static void TestSetup(){
        
        
        AcctSeed__Accounting_Variable__c av = MakeData.MakeGL('Seawin USA');
        
        Account acct = new Account();
        
        acct.Name = 'Test';
        acct.Type = 'Architect';
        acct.AcctSeed__GL_Account_Variable_1__c = av.id;
        
        insert acct;
        
        Opportunity oppty = new Opportunity();
        
        oppty.Name = 'Test';
        oppty.CloseDate = Date.today() + 7;
        oppty.StageName = 'Take-off';
        oppty.LeadSource = 'Website';
        oppty.GL_Account_Variable_1__c = av.id;
        
        insert oppty;
        
    }
    
    @isTest static void runTest(){
     
		OpportunityTakeOffListViewCtrl ctrl = new OpportunityTakeOffListViewCtrl(); 
        
        System.assert(ctrl.setCon != null);
        
        ctrl.refreshPageSize();
        
        ctrl.Display();
        
        
    }
    
    @isTest static void AllSearch(){
        
        Opportunity oppty = [Select Id from Opportunity Limit 1];
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('alphabetClicked', 'clicked');

		OpportunityTakeOffListViewCtrl ctrl = new OpportunityTakeOffListViewCtrl();
        
        ctrl.SearchVar = 'All';
        
        ctrl.Display();

        ApexPages.CurrentPage().getParameters().put('oppId', oppty.id);
        ApexPages.CurrentPage().getParameters().put('teamId', UserInfo.getUserId());
        
        ctrl.UpdateTheTeamTakeOff();
        
        Test.stopTest();
        
    }
    
    @isTest static void OtherSearch(){
        
        Opportunity oppty = [Select Id from Opportunity Limit 1];
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('alphabetClicked', 'clicked');

		OpportunityTakeOffListViewCtrl ctrl = new OpportunityTakeOffListViewCtrl();
        
        ctrl.SearchVar = 'Other';
        
        ctrl.Display();
        
        Test.stopTest();
        
    }
    
    @isTest static void AlphabetSearch(){
        
        Opportunity oppty = [Select Id from Opportunity Limit 1];
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('alphabetClicked', 'clicked');

		OpportunityTakeOffListViewCtrl ctrl = new OpportunityTakeOffListViewCtrl();
        
        ctrl.SearchVar = 'T';
        
        ctrl.Display();
        
        Test.stopTest();
        
    }
}