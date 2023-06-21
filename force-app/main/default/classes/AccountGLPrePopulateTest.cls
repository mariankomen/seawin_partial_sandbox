@isTest
public class AccountGLPrePopulateTest {
    
    @isTest static void WithSingleGLAccountVariable(){
        
        AcctSeed__Accounting_Variable__c avr = new AcctSeed__Accounting_Variable__c(
            name='Seawin USA', AcctSeed__Type__c = 'GL Account Variable 1', AcctSeed__Active__c = True);
        insert avr;
        
        User usr = new User(Firstname='FirstName', LastName='LastName', ProfileId = UserInfo.getProfileId(),
                            Email = 'random@email.com', Default_GL_Account_Variable__c = avr.Name,
                            Username = 'rndmn@email.com', Alias='rndmn', TimeZoneSidKey='America/Los_Angeles', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert usr;
        
        System.runAs(usr){
            Account acct = new Account(name='myAccount', type='Other');
            insert acct;
        }
    }
    @isTest static void WithMultipleGLAccountVariable(){
        
        List<AcctSeed__Accounting_Variable__c> avrList = new List<AcctSeed__Accounting_Variable__c>();
        
        AcctSeed__Accounting_Variable__c avr = new AcctSeed__Accounting_Variable__c(
            name='Seawin USA', AcctSeed__Type__c = 'GL Account Variable 1', AcctSeed__Active__c = True);
        avrList.add(avr);
        AcctSeed__Accounting_Variable__c avr2 = new AcctSeed__Accounting_Variable__c(
            name='Seawin China', AcctSeed__Type__c = 'GL Account Variable 1', AcctSeed__Active__c = True);
        avrList.add(avr2);
        insert avrList;
        
        
        User usr = new User(Firstname='FirstName', LastName='LastName', ProfileId = UserInfo.getProfileId(),
                            Email = 'random@email.com', Default_GL_Account_Variable__c = format(avrList),
                            Username = 'randmnam@email.com', Alias='randmnam', TimeZoneSidKey='America/Los_Angeles', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert usr;
        
        System.runAs(usr){
            Account acct = new Account(name='myAccount', type='Other');
            insert acct;
        }
    }
    
    public static String format(List<AcctSeed__Accounting_Variable__c> variables){
        
        List<String> values = new List<String>();
        
        for(AcctSeed__Accounting_Variable__c avr : variables){
            values.add(avr.Name);
        }
        
        return String.join(values, ';');
    }
}