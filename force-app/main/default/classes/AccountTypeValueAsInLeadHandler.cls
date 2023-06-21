public class AccountTypeValueAsInLeadHandler {
    
    public static void Populate(List<Account> data){
         
        for(Account acct : data){
            if(acct.Type == null && acct.TypeHelper__c != null){
                acct.Type = acct.TypeHelper__c;
            }
        }
    }
}