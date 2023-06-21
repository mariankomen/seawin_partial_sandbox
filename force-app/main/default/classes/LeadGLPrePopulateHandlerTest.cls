@isTest
public class LeadGLPrePopulateHandlerTest {
    
    @isTest static void WithoutGLAccountVariable(){
        
        list<AcctSeed__Accounting_Variable__c> avList = new list<AcctSeed__Accounting_Variable__c>();
        
    	avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin China',AcctSeed__Type__c = 'GL Account Variable 1'));
        
        avList.add(new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1'));
        insert avList;
        
        User usr = new User(Firstname='FirstName', LastName='LastName', ProfileId = UserInfo.getProfileId(),
                            Email = 'random@email.com', Default_GL_Account_Variable__c = null,
                            Username = 'randmna@email.com', Alias='randmna', TimeZoneSidKey='America/Los_Angeles', 
                            LocaleSidKey='en_US', 
                            EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert usr;
        
        System.runAs(usr){
            Lead ld = new Lead(status='New', LastName='Test', Company='Test');
            insert ld;
        }
    }
    
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
            Lead ld = new Lead(status='New', LastName='Test', Company='Test');
            insert ld;
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
            Lead ld = new Lead(status='New', LastName='Test', Company='Test');
            insert ld;
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