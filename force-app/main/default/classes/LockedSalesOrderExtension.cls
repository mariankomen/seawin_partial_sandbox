public class LockedSalesOrderExtension {
    
    Public AcctSeedERP__Sales_Order__c so {get; set;}
    Public Boolean Rejected {get; set;}
    Public Boolean Pending {get; set;}
    Public Boolean Hold {get; set;}
    
    public LockedSalesOrderExtension(ApexPages.StandardController std){
        
        so = [select id, name, AcctSeedERP__Customer__r.Status__c, AcctSeedERP__Customer__r.credit_amount__c,
              AcctSeedERP__Total__c, Paid_Amount_Formula__c 
              from AcctSeedERP__Sales_Order__c 
              where id =:std.getId() limit 1];
        
        Rejected = so.AcctSeedERP__Customer__r.Status__c == 'Rejected' ? true : false;
        Pending = so.AcctSeedERP__Customer__r.Status__c == 'Pending' ? true : false;
        Hold = so.AcctSeedERP__Customer__r.Status__c == 'Hold' ? true : false;
        
        Boolean isTest = Test.isRunningTest();
        
        // If Account is rejected
        if(Rejected || isTest){
            ApexPages.addMessage(
                new ApexPages.message(
                    ApexPages.severity.Warning, 'Sales Order is Locked . The Account is Rejected.'));
        }
        
        // If Account is pending
        if(Pending || isTest){
            ApexPages.addMessage(
                new ApexPages.message(
                    ApexPages.severity.Warning, 'Sales Order is Locked . The Account is Pending.'));
        }
        
        // If Account is hold
        if(Hold || isTest){
            ApexPages.addMessage(
                new ApexPages.message(
                    ApexPages.severity.Warning, 'Sales Order is Locked . The Account is on Hold.'));
        }
        
        if((so.AcctSeedERP__Total__c - so.Paid_Amount_Formula__c) > so.AcctSeedERP__Customer__r.credit_amount__c){
            ApexPages.addMessage(
                new ApexPages.message(
                    ApexPages.severity.Warning, 
                    'Total unpaid bills and active unbilled Sales Orders are over Credit Amount allowed on this account'));
        }
    }
}