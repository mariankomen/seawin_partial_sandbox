public class LockedQuoteExtension {
    
    Public Quote q {get; set;}
    Public Boolean Rejected {get; set;}
    Public Boolean Pending {get; set;}
    Public Boolean Billed {get; set;}
    Public Boolean Closed {get; set;}
    
    public LockedQuoteExtension(ApexPages.StandardController std){

        q = [select id, name, IsSyncing,Account.Status__c,Opportunity.TotalBills__c,
            Opportunity.StageName,Opportunity.TotalSalesOrderInOpp__c from Quote where id =:std.getId() limit 1];
        
        Rejected = q.Account.Status__c == 'Rejected' ? true : false;
        Pending = q.Account.Status__c == 'Pending' ? true : false;
        Billed = q.Opportunity.TotalBills__c > 0 ? true : false;
        Closed = q.Account.Status__c != 'Rejected' && q.Opportunity.StageName == 'Closed Won' && 
            q.Opportunity.TotalSalesOrderInOpp__c > 0;
		
        String msg = '';
        // If Account is rejected
        if(Rejected){
            ApexPages.addMessage(
                new ApexPages.message(
                    ApexPages.severity.Warning, 
                    'Quote is Locked. The Account is Rejected.'));
        }
        
        // If Opportunity in Approval
        if(Pending){
            ApexPages.addMessage(
                new ApexPages.message(
                    ApexPages.severity.Warning, 
                    'Quote is Locked. The Account is Pending.'));
        }
        
                
        // If Stage is Closed Won and there is SO
        if(Closed){
            msg = 'Quote is Locked, because Opportunity Stage is Closed Won and has Sales Order(s).';
            ApexPages.addMessage(
                new ApexPages.message(
                    ApexPages.severity.Warning, 
                    msg));
        }

        // If there is billing
        if(Billed){
            msg = 'Sales Price or Quantity cannot be changed and Quote Line Items can not be deleted,'; 
            msg += ' as Billing has already been created.';
            ApexPages.addMessage(
                new ApexPages.message(
                    ApexPages.severity.Warning, 
                    msg));
        }
    }
}