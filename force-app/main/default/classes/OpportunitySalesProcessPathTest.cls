@isTest
public class OpportunitySalesProcessPathTest {

    public static void createData(){
        
        // create GL Account Variable 1 needed by account
        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c(
            Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
        
        insert av;
        
        // Create opportunities
        
        List<Opportunity> opList = new List<Opportunity>();
        
        Opportunity op = new Opportunity(name='myOpportunity', price_level__c = null, stagename='Pre-Order',
                                         GL_Account_Variable_1__c = av.id,
                                         financial_clearance__c = true, approval_Package__c = true,
                                         signed_sales_order__c = true,
                                         CloseDate=date.today() + 60);
        
        opList.add(op);
        
        Opportunity opp = new Opportunity(name='myOpportunitySecond', price_level__c = null, stagename='Pre-Order',
                                         GL_Account_Variable_1__c = av.id,
                                         financial_clearance__c = false, 
                                         Financial_Clearance_Date__c = Date.today(), 
                                         approval_Package__c = false,
                                         submittal_approval_date__c = Date.today(),
                                         signed_sales_order__c = false,
                                         Contract_date__c = Date.today(),
                                         CloseDate=date.today() + 60);
        
        opList.add(opp);
        
        insert opList;
        
    }
    @isTest static void Checked(){

        Test.setMock(HttpCalloutMock.class, new MockWebServiceCallout());
        createData();
        
        Opportunity opp = [select id, StageName, recordtypeId, recordtype.name, Loss_Reason__c,
               Approval_Package__c, submittal_approval_date__c, Financial_Clearance__c, Financial_Clearance_Date__c,
               Signed_Sales_Order__c, Contract_Date__c,
               Quote_Submitted_Date__c from Opportunity limit 1];

        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('stageNameIs', 'Negotiation');
        
        ApexPages.StandardController std = new ApexPages.StandardController(opp);
        
        OpportunitySalesProcessPathExtension ospp = new OpportunitySalesProcessPathExtension(std);
        
        ospp.getrenderlist();
        ospp.changeStage();
        ospp.CheckUncheck();
        ospp.ReAssign();
        
        test.stopTest();

    }
    
    @isTest static void Unchecked(){

        Test.setMock(HttpCalloutMock.class, new MockWebServiceCallout());
        createData();

        Opportunity opp = [select id, StageName, recordtypeId, recordtype.name, Loss_Reason__c,Team_Engineer__c,Team_Estimator__c,Team_Take_off__c,
               Approval_Package__c, submittal_approval_date__c, Financial_Clearance__c, Financial_Clearance_Date__c,
               Signed_Sales_Order__c, Contract_Date__c,
               Quote_Submitted_Date__c from Opportunity where name = 'myOpportunitySecond' limit 1];
               
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('stageNameIs', 'Negotiation');
        
        ApexPages.StandardController std = new ApexPages.StandardController(opp);
        
        OpportunitySalesProcessPathExtension ospp = new OpportunitySalesProcessPathExtension(std);
        
        ospp.getrenderlist();
        ospp.changeStage();
        ospp.CheckUncheck();
        ospp.ReAssign();
        ospp.updateSubStage();

        Boolean testvar1 = ospp.isTeamTakeOff;
        Boolean testvar2 = ospp.isTeamEstimator;
        Boolean testvar3 = ospp.isTeamEngineer;
        // Boolean testvar4 = ospp.opportunityHasTeamTakeOff;
        // Boolean testvar5 = ospp.opportunityHasTeamEstimator;
        // Boolean testvar6 = ospp.opportunityHasTeamEngineer;

        ospp.setOpportunityTeamTakeOff();
        ospp.setOpportunityTeamEstimator();
        ospp.setOpportunityTeamEngineer();
        test.stopTest();

    }
    
}