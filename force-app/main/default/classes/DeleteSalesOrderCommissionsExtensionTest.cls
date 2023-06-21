@isTest
public class DeleteSalesOrderCommissionsExtensionTest {
	
  @TestSetup
  static void MakeData() {
      
    AcctSeed__Accounting_Variable__c av = MakeData.MakeGL('Seawin USA');
      
    AcctSeed__GL_Account__c gl = MakeData.MakeGLAccount(true, av);
      
    AcctSeed__Billing_Format__c format = MakeData.MakePDFFormat('Sales Order');
      
    AcctSeed__Ledger__c ledger = MakeData.MakeLedger(gl, format);
      
    Date dt = date.today();

    AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
    ap.name =
      dt.year() +
      '-' +
      ((dt.month() < 10) ? '0' + dt.month() : String.ValueOf(dt.month()));
    system.debug(
      dt.year() +
      '-' +
      ((dt.month() < 9) ? Integer.ValueOf('0' + dt.month()) : dt.month())
    );
    ap.AcctSeed__Start_Date__c = Date.today() - (dt.day() - 1);
    ap.AcctSeed__End_Date__c = Date.today() + 28;
    ap.AcctSeed__Status__c = 'Open';
    insert ap;
      
    Account acct = new Account(name='myAccount', AcctSeed__GL_Account_Variable_1__c=av.id);
        
    insert acct;
      
    acctSeederp__sales_order__c order = new acctseederp__sales_order__c(acctseederp__customer__c=acct.id, 
                                                                            price_level__c = 'Level 3',
                                                                            acctseederp__ledger__c =ledger.id,
                                                                            GL_Account_Variable_1__c=av.id);
        
    insert order;
      
    List<Sales_Order_Commissions__c> commissionsList = new List<Sales_Order_Commissions__c>();
      
    Sales_Order_Commissions__c commissions = new Sales_Order_Commissions__c();
      
    commissions.Owner__c = UserInfo.getuserId();
    commissions.Sales_Order__c = order.id;
    commissions.Commission_Amount__c = 100;
      
    commissionsList.add(commissions);
      
    commissions = new Sales_Order_Commissions__c();
      
    commissions.Owner__c = UserInfo.getuserId();
    commissions.Sales_Order__c = order.id;
    commissions.Commission_Amount__c = 50;
      
    commissionsList.add(commissions);
      
    insert commissionsList;
      
    AcctSeed__Account_Payable__c payable = new AcctSeed__Account_Payable__c();
        
    payable.AcctSeed__Accounting_Period__c = ap.id;  
    payable.AcctSeed__Date__c  = date.today();
    payable.AcctSeed__Due_Date__c = date.today() + 7;
    payable.AcctSeed__Status__c = 'Approved';
    payable.AcctSeed__Vendor__c = acct.id;
    payable.AcctSeed__Ledger__c = ledger.id;
    payable.Sales_Order_Commissions__c = commissionsList[1].id;
    payable.AcctSeed__Payee_Reference__c = commissions.Name + ' - ' + System.Now().formatLong(); 
      
    insert payable;
      
  }
    
    @isTest static void WithoutPayable(){
        
        AcctSeedERP__Sales_Order__c order = [select id from AcctSeedERP__Sales_Order__c Limit 1];
        List<Sales_Order_Commissions__c> commissions = [Select id from Sales_Order_Commissions__c];
        
        Test.startTest();
        
        ApexPages.StandardController std = new ApexPages.StandardController(commissions[0]);
        
        ApexPages.currentPage().getParameters().put('retURL', '/apex/' + order.id);
        
        DeleteSalesOrderCommissionsExtension ext = new DeleteSalesOrderCommissionsExtension(std);
        
        ext.pageAction();
        
        Test.stopTest();
    	
    }
    
    @isTest static void WithPayable(){
        
        AcctSeedERP__Sales_Order__c order = [select id from AcctSeedERP__Sales_Order__c Limit 1];
        List<Sales_Order_Commissions__c> commissions = [Select id from Sales_Order_Commissions__c];
        
        Test.startTest();
        
        ApexPages.StandardController std = new ApexPages.StandardController(commissions[1]);
        
        ApexPages.currentPage().getParameters().put('retURL', '/apex/' + order.id);
        
        DeleteSalesOrderCommissionsExtension ext = new DeleteSalesOrderCommissionsExtension(std);
        
        ext.pageAction();
        
        Test.stopTest();
    	
    }
}