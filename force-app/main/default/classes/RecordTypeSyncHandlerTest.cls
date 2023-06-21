@isTest
public class RecordTypeSyncHandlerTest {
    
    @testSetup static void createData(){
        
        Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        Id RecordTypeIdQuote = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Seawin USA Hospitality').getRecordTypeId();
        
        // create GL Account Variable 1 needed by account
        AcctSeed__Accounting_Variable__c glav = new AcctSeed__Accounting_Variable__c(
            Name = 'Seawin USA',AcctSeed__Type__c = 'GL Account Variable 1');
        
        insert glav;
        
        // Create accounts
        
        Account acct = new Account(name='myAccount', AcctSeed__GL_Account_Variable_1__c=glav.id);
        
        insert acct;
        
        // Create Contacts
        
        List<Contact> contacts = new List<Contact>();
        
        Contact contct1 = new Contact(LastName='myContact1', LeadSource = 'AAOHA 2020');
        contacts.add(contct1);
        
        Contact contct2 = new Contact(LastName='myContact2', LeadSource = 'Customer Event');
        contacts.add(contct2);
        
        insert contacts;
        
        // Create opportunities
        
        Opportunity op = new Opportunity(name='myOpportunity', price_level__c = null, stagename='Closed Won',
                                         contactperson__c = contct1.id,
                                         GL_Account_Variable_1__c = glav.id,
                                         CloseDate=date.today() + 60, accountid=acct.id,
                                        recordtypeid=RecordTypeIdOpportunity);
        
        insert op;
        
        Quote q = new Quote();
        
        q.OpportunityId = op.id;
        q.name = 'myQuote';
        q.RecordTypeId = RecordTypeIdQuote;
        
        insert q;
        
    }
    
    @isTest static void SyncQuote(){
        
        opportunity op = [select id, recordtypeid, syncedQuoteid from opportunity
                         where name='myOpportunity' limit 1];
        
		Quote q = [select id, recordtypeid from quote where name='myQuote' limit 1];	
        
        
        op.SyncedQuoteId = q.id;
        
        update op;
        
        Id RecordTypeIdQuote = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Seawin China Hospitality').getRecordTypeId();
        
        q.recordtypeid = RecordTypeIdQuote;
        
        update q;
    }
    
    @isTest static void OpptyChange(){
        
        opportunity op = [select id, recordtypeid, syncedQuoteid from opportunity
                         where name='myOpportunity' limit 1];
        
		Quote q = [select id, recordtypeid from quote where name='myQuote' limit 1];	
        
        
        op.SyncedQuoteId = q.id;
        
        update op;
        
        Id RecordTypeIdOppty = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Seawin China OEM').getRecordTypeId();
        
        op.recordtypeid = RecordTypeIdOppty;
        
        update op;
    }

}