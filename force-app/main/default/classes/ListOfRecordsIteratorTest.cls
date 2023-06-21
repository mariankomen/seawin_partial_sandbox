@isTest
public class ListOfRecordsIteratorTest {

    @isTest static void runTests(){
        
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < 200; i++){
            
            Account acct = new Account(name='myAccount'+i);
            accounts.add(acct);
        }
        
        insert accounts;
        
        Test.startTest();
        ListOfRecordsIterator iter = new ListOfRecordsIterator(accounts);
		
        iter.hasNext();
        iter.next();
        iter.next();
        iter.hasPrevious();
        iter.previous();
        
        
        
        
        Test.stopTest();

    }
    
}