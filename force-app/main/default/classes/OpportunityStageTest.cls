@isTest
public class OpportunityStageTest {
    
    @testSetup static void createData(){
    
        //TestUtility.CreateData();
        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c();
    	av.Name = 'Seawin China';
        av.AcctSeed__Type__c ='GL Account Variable 1';
        insert av;
        
        Account acct = new Account();
        //acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__GL_Account_Variable_1__c = av.Id;
        insert acct;
        
        Contact cont = new Contact();
        cont.LastName = 'myLastName';
        cont.AccountId = acct.Id;
        insert cont;
        
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        
        Id pricebookId = Test.getStandardPricebookId();
        
        sales_rep__c salesrep = new sales_rep__c();
        salesrep.User__c = Userinfo.getUserId();
        salesrep.Active__c = 'Yes';
        salesrep.Name = 'New User';
        salesrep.Price_Level_1_12__c = 1;
        salesrep.Price_Level_13_20__c = 2;
        salesrep.Price_Level_21_26__c = 3;
        salesrep.Price_Level_27_30__c = 4;
        insert salesrep;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'myOpportunity';
        opp.AccountId = acct.Id;
        opp.Type = 'Actual Order';
        opp.StageName = 'Closed Won';
        opp.CloseDate = system.today();
        opp.ContactPerson__c = cont.Id;
        opp.GL_Account_Variable_1__c = av.id;
        opp.RecordTypeId = RecordTypeIdOpportunity;
        opp.Pricebook2Id = pricebookId;
        //opp.IsApproved__c= false;
        opp.Sales_Rep_O__c = salesrep.id;
        insert opp;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'myOpportunity2';
        opp2.AccountId = acct.Id;
        opp2.Type = 'Actual Order';
        opp2.StageName = 'Closed Won';
        opp2.CloseDate = system.today();
        opp2.ContactPerson__c = cont.Id;
        opp2.GL_Account_Variable_1__c = av.id;
        opp2.RecordTypeId = RecordTypeIdOpportunity;
        opp2.Pricebook2Id = pricebookId;
        //opp.IsApproved__c= false;
        opp2.Sales_Rep_O__c = salesrep.id;
        insert opp2;
        
        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
        abf.Name = 'newPDF Format';
        abf.AcctSeed__Type__c = 'Purchase Order';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        insert abf;
        
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = av.Id;
        insert aegl;
        
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        ledger.Name = 'myLedger';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = abf.id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = abf.id;
        ledger.AcctSeed__Default_Bank_Account__c = aegl.id;
        ledger.AcctSeed__Default_Billing_Format__c = abf.id; 
        ledger.AcctSeed__Default_Purchase_Order_Format__c = abf.id;
        ledger.AcctSeed__Default_Packing_Slip_Format__c = abf.id;
        insert ledger;
        
        Id RecordTypeIdSO = Schema.SObjectType.AcctSeedERP__Sales_Order__c.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        
        AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c();
        salesorder.RecordTypeId = RecordTypeIdSO;
        salesorder.AcctSeedERP__Customer__c = acct.Id;
        ////salesorder.Contact__c = cont.Id;
        salesorder.AcctSeedERP__Opportunity__c = opp.Id;
        salesorder.AcctSeedERP__Status__c = 'Open';
       	salesorder.AcctSeedERP__Ledger__c = ledger.id;
        salesorder.GL_Account_Variable_1__c = av.id;
        salesorder.Stage__c = 'Production';
        salesorder.Sales_Rep_O__c = salesrep.id;
        //salesorder.Sales_Rep_O_2__c = salesrep.id;
        //salesorder.Financial_Clearance__c = true;
        //salesorder.Approval_Package__c = true;
        insert salesorder;
        
        AcctSeedERP__Sales_Order__c salesorder2 = new AcctSeedERP__Sales_Order__c();
        salesorder2.RecordTypeId = RecordTypeIdSO;
        salesorder2.AcctSeedERP__Customer__c = acct.Id;
        ////salesorder2.Contact__c = cont.Id;
        salesorder2.AcctSeedERP__Opportunity__c = opp2.Id;
        salesorder2.AcctSeedERP__Status__c = 'Open';
       	salesorder2.AcctSeedERP__Ledger__c = ledger.id;
        salesorder2.GL_Account_Variable_1__c = av.id;
        salesorder2.Stage__c = 'Production';
        salesorder2.Sales_Rep_O__c = salesrep.id;
        //salesorder2.Sales_Rep_O_2__c = salesrep.id;
        //salesorder2.Financial_Clearance__c = true;
        //salesorder2.Approval_Package__c = true;
        insert salesorder2;
        
    }
    
    @isTest static void StartProcess(){
        
        Opportunity op = [select id, Name
                         from Opportunity
                         where Name = 'myOpportunity'];
        
        Opportunity op2 = [select id, Name
                         from Opportunity
                         where Name = 'myOpportunity2'];
        
        AcctSeedERP__Sales_Order__c so = [select id, Name, AcctSeedERP__Opportunity__c
                                         from AcctSeedERP__Sales_Order__c
                                         where AcctSeedERP__Opportunity__c =: op.id];
        
        so.AcctSeedERP__Opportunity__c = op2.Id;
        update so;
        
        delete so;
        
        //OpportunityStageHandler opSTage = new OpportunityStageHandler();
        //op.CreateSO();
        
    }
    
}