public class LockedAccountExtension {
    
    public Boolean hasMessage {get; set;}
    
    Public LockedAccountExtension(ApexPages.StandardController std){
        
        hasMessage = true;
        Account acc = [select id, name, Status__c, credit_amount__c
                       from Account where id =:std.getId() limit 1];
        
        LIST<AcctSeedERP__Sales_Order__c> soList = new List<AcctSeedERP__Sales_Order__c> ();
        
        soList = [select id, AcctSeedERP__Customer__r.credit_amount__c,
                  AcctSeedERP__Total__c, Paid_Amount_Formula__c
                  from AcctSeedERP__Sales_Order__c
                  where AcctSeedERP__Customer__c =: std.getId() ];
        
        Decimal soTotal = 0;
        Decimal soTotalpaidAmt = 0;
        
        if (soList.size() > 0){
            //so.AcctSeedERP__Total__c - so.Paid_Amount_Formula__c) > so.AcctSeedERP__Customer__r.credit_amount__c
            for(AcctSeedERP__Sales_Order__c sOrder : soList){
                soTotal = soTotal + sOrder.AcctSeedERP__Total__c;
                soTotalpaidAmt = soTotalpaidAmt + sOrder.Paid_Amount_Formula__c;
            }
        }
        
        if(acc.Status__c == 'Rejected'){
            hasMessage = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, 
                                                       'This Customer Account is Rejected. Contact ' +
                                                       'your sales manager before you do any changes!!!'));
        }else if(acc.Status__c == 'In Active'){
            hasMessage = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, 
                                                       'This Customer Account is In Active. Contact ' +
                                                       'your sales manager before you do any changes!!!'));
        }
        else if(acc.Status__c == 'Pending'){
            hasMessage = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, 
                                                       'This Customer Account is Pending. Contact ' +
                                                       'your sales manager before you do any changes!!!'));
        }
        else if(acc.Status__c == 'Hold'){
            hasMessage = false;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, 
                                                       'This Customer Account is on Hold. Contact ' +
                                                       'your sales manager before you do any changes!!!'));
        }
        
        else if (soList.size() > 0)
            if((soTotal - soTotalpaidAmt) > acc.credit_amount__c){
                hasMessage = false;
                ApexPages.addMessage(new ApexPages.message(
                    ApexPages.severity.Warning, 
                    'Total unpaid bills and active unbilled Sales Orders are over Credit Amount allowed on this account'));
            }
    }
    
}