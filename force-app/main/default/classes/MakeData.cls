@isTest
public class MakeData {
    @isTest static void runTests(){
        
        
    }
    
    public static User MakeUser(string profilename){
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name =:profilename LIMIT 1];
        
        String orgId = UserInfo.getOrganizationId();  
        String dateString =   
        String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt +'@hello.com';
        
     	User usr = new User(LastName = 'tst',
                           FirstName='test',
                           Alias = 'hlo',
                           Email = 'test@sample.com',
                           Username = uniqueName,
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        
        insert usr;
        
        return usr;
        
    }
    
    public static AcctSeed__Accounting_Variable__c MakeGL(string business){
        
        AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c(Name=business, 
                                                                                   AcctSeed__Type__c='GL Account Variable 1');
        insert av;
        
        return av;
        
    }
    
    public static AcctSeed__GL_Account__c MakeGLAccount(Boolean BankTrue, 
                                                       AcctSeed__Accounting_Variable__c av){
        
        // ledger creation
        AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
        gl.name = 'glaccount';
        gl.AcctSeed__Type__c = 'Expense';
        gl.AcctSeed__Sub_Type_1__c = 'Facilities';
        gl.AcctSeed__Sub_Type_2__c = 'Rent';
        gl.AcctSeed__Bank__c = BankTrue;
        gl.GL_Account_Variable_1__c = av.id;
        
        
        insert gl;
        
        return gl;
    }
    
    public static AcctSeed__Billing_Format__c MakePDFFormat(string objectlabel){
   
        AcctSeed__Billing_Format__c pdfformat = new AcctSeed__Billing_Format__c();
        
        pdfformat.Name = 'Test PDF Format';
        pdfformat.AcctSeed__Type__c = objectlabel;
        pdfformat.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
        pdfformat.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        
        insert pdfformat;
		
        return pdfformat;
    }
    
    public static AcctSeed__Ledger__c MakeLedger(AcctSeed__GL_Account__c bankaccount, 
                                                 AcctSeed__Billing_Format__c pdfformat){
        
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        
        ledger.Name = 'myLedger';
        ledger.AcctSeed__Type__c = 'Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = pdfformat.id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = pdfformat.id;
        ledger.AcctSeed__Default_Bank_Account__c = bankaccount.id;
        ledger.AcctSeed__Default_Billing_Format__c = pdfformat.id; 
        ledger.AcctSeed__Default_Purchase_Order_Format__c = pdfformat.id;
        ledger.AcctSeed__Default_Packing_Slip_Format__c = pdfformat.id;
        
        
        insert ledger;
                                                     
        return ledger;
    }
}