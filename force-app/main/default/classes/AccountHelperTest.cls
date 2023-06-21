@isTest
public with sharing class AccountHelperTest {
    
    @TestSetup
    static void makeData(){
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;

        
        
        list<AcctSeed__GL_Account__c> glList = new List<AcctSeed__GL_Account__c>();
        
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        
        gl.name = 'GL Account First';
        gl.AcctSeed__type__c = 'Balance Sheet';
        gl.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl.AcctSeed__Active__c = true;
        gl.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(gl);
        
        // ledger creation
        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(aegl);
        
        AcctSeed__GL_Account__c vch = new AcctSeed__GL_Account__c();
        vch.name = '2010-Vouchers Payable';
        vch.AcctSeed__Type__c = 'Balance Sheet';
        vch.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch.AcctSeed__Active__c = true;
        vch.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(vch);
        
        AcctSeed__GL_Account__c vch1 = new AcctSeed__GL_Account__c();
        vch1.name = '2010-Vouchers Payable1';
        vch1.AcctSeed__Type__c = 'Balance Sheet';
        vch1.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch1.AcctSeed__Active__c = true;
        vch1.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(vch1);
        
        AcctSeed__GL_Account__c vch2 = new AcctSeed__GL_Account__c();
        vch2.name = '2010-Vouchers Payable2';
        vch2.AcctSeed__Type__c = 'Balance Sheet';
        vch2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch2.AcctSeed__Active__c = true;
        vch2.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(vch2);
        
        AcctSeed__GL_Account__c vch3 = new AcctSeed__GL_Account__c();
        vch3.name = '2010-Vouchers Payable3';
        vch3.AcctSeed__Type__c = 'Balance Sheet';
        vch3.AcctSeed__Sub_Type_1__c = 'Liabilities';
        vch3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        vch3.AcctSeed__Active__c = true;
        vch3.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(vch3);
        
        AcctSeed__GL_Account__c gl1 = new AcctSeed__GL_Account__c();
        gl1.name = '2010-Vouchers Payable1';
        gl1.AcctSeed__Type__c = 'Balance Sheet';
        gl1.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl1.AcctSeed__Active__c = true;
        gl1.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(gl1);
        
        AcctSeed__GL_Account__c gl2 = new AcctSeed__GL_Account__c();
        gl2.name = '2010-Vouchers Payable2';
        gl2.AcctSeed__Type__c = 'Balance Sheet';
        gl2.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl2.AcctSeed__Active__c = true;
        gl2.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(gl2);
        
        AcctSeed__GL_Account__c gl3 = new AcctSeed__GL_Account__c();
        gl3.name = '2010-Vouchers Payable3';
        gl3.AcctSeed__Type__c = 'Balance Sheet';
        gl3.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl3.AcctSeed__Active__c = true;
        gl3.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(gl3);
        
        AcctSeed__GL_Account__c gl4 = new AcctSeed__GL_Account__c();
        gl4.name = '2010-Vouchers Payable4';
        gl4.AcctSeed__Type__c = 'Balance Sheet';
        gl4.AcctSeed__Sub_Type_1__c = 'Liabilities';
        gl4.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
        gl4.AcctSeed__Active__c = true;
        gl4.GL_Account_Variable_1__c = accVar.Id;
        
        glList.add(gl4);
        
        insert glList;

        AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();

        abf.Name = 'newPDF Format';
        abf.AcctSeed__Type__c = 'Purchase Order';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';

        insert abf;
        AcctSeed__Billing_Format__c bil_f = new AcctSeed__Billing_Format__c();

        bil_f.Name = 'newPDF Format';
        bil_f.AcctSeed__Type__c = 'Billing';
        bil_f.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        bil_f.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';

        insert bil_f;

        

        // ledger creation
        

        // Accounting Period
        Date dt = date.today();

        AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        ap.name =
        dt.year() +
        '-' +
        ((dt.month() < 10) ? '0' + dt.month() : String.ValueOf(dt.month()));
        ap.AcctSeed__Start_Date__c = Date.today() - (dt.day() - 1);
        ap.AcctSeed__End_Date__c = Date.today() + 28;
        ap.AcctSeed__Status__c = 'Open';
        insert ap;

        // create account
        Account acct = new Account();
        //acct.Sales_Rep_O__c = sr.id;
        acct.Name = 'myAccount';
        acct.Type = 'Designer';
        acct.AcctSeed__Accounting_Type__c = 'Customer';
        acct.AcctSeed__Billing_Format__c = bil_f.Id;
        acct.AcctSeed__GL_Account_Variable_1__c = accVar.Id;
        insert acct; 
    }

    @isTest
    public static void beforeInsertTest(){
        Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
          
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<Account> lstAccount = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM Account');

        AccountHelper.beforeInsert(lstAccount);
    }

    @isTest
    public static void afterInsertTest(){
        Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
          
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<Account> lstAccount = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM Account');
        Map<Id, Account> mapAccount = new Map<Id, Account>(lstAccount);
        AccountHelper.afterInsert(lstAccount, mapAccount);
    }

    @isTest
    public static void beforeUpdateTest(){
        Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
          
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<Account> lstAccount = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM Account');

        for(Account acc:lstAccount){
            acc.AcctSeed__Accounting_Type__c = 'Competitor';
        }
        update lstAccount;

        for(Account acc:lstAccount){
            acc.AcctSeed__Accounting_Type__c = 'Customer';
        }
        update lstAccount;
        // Map<Id, Account> mapAccount = new Map<Id, Account>(lstAccount);
        // AccountHelper.beforeUpdate(lstAccount, mapAccount, lstAccount, mapAccount);
    }
    @isTest
    public static void afterUpdateTest(){
        Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
          
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<Account> lstAccount = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM Account');
        Map<Id, Account> mapAccount = new Map<Id, Account>(lstAccount);
        AccountHelper.afterUpdate(lstAccount, mapAccount, lstAccount, mapAccount);
    }
    @isTest
    public static void beforeDeleteTest(){
        Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
          
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<Account> lstAccount = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM Account');
        Map<Id, Account> mapAccount = new Map<Id, Account>(lstAccount);
        AccountHelper.beforeDelete(lstAccount, mapAccount);
    }
    @isTest
    public static void afterDeleteTest(){
        Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
          
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<Account> lstAccount = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM Account');
        Map<Id, Account> mapAccount = new Map<Id, Account>(lstAccount);
        AccountHelper.afterDelete(lstAccount, mapAccount);
    }
    @isTest
    public static void afterUnDeleteTest(){
        Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
          
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<Account> lstAccount = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM Account');
        Map<Id, Account> mapAccount = new Map<Id, Account>(lstAccount);
        AccountHelper.afterUnDelete(lstAccount, mapAccount);
    }


    @isTest
    public static void automaticallyApproveRecordTest(){
        Map<String, Schema.SObjectField> fieldMap = Account.sObjectType.getDescribe().fields.getMap();
          
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
        List<Account> lstAccount = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM Account');
        Map<Id, Account> accountMap = new Map<Id, Account>(lstAccount);

        AccountHelper.automaticallyApproveRecord(accountMap.keySet());
        
    }







    @isTest
    public static void executeAllTriggersTest(){
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        acc.Name = 'test1111111';
        update acc;

        delete acc;
    }
}