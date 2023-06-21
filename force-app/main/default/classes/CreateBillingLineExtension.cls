public class CreateBillingLineExtension {
    
    public AcctSeed__Billing_Line__c line {get; set;}
    public 	AcctSeed__Billing__c billing {get; set;}
    public boolean showError {get; set;}
    
    public CreateBillingLineExtension(ApexPages.StandardController std){
        showError = false;
        line =(AcctSeed__Billing_Line__c)std.getRecord();
        
        billing = new AcctSeed__Billing__c();
        
        billing = [select id, GL_Account_Variable_1__c,AcctSeed__Opportunity__c, AcctSeedERP__Sales_Order__c
                   from AcctSeed__Billing__c
                   where id =: line.AcctSeed__Billing__c limit 1];

        AcctSeed__Accounting_Variable__c GLaccVar = [select id, name
                                                     from AcctSeed__Accounting_Variable__c
                                                     where name =: billing.GL_Account_Variable_1__c limit 1];
        line.AcctSeed__GL_Account_Variable_1__c = GLaccVar.Id;
        
    }
    
    public PageReference Save(){
   
        insert line;
        
        return redirect();
    }
    
    public PageReference pageAction(){
   
        if(billing.AcctSeed__Opportunity__c != null || billing.AcctSeedERP__Sales_Order__c != null){
            showError = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
                                                       'More line items cannot be added as opportunity or sales order exists.'));
        }
        return null;
    }
    
    public PageReference SaveAndNew(){
        insert line;

        string url = Test.isRunningTest() ? '/' + line.id : Apexpages.CurrentPage().getUrl();

        PageReference page = new PageReference(url);
        page.setRedirect(true);
        
        return page;
        
    }
    
    public PageReference Cancel(){

        return redirect();
    }

    public PageReference redirect(){

        PageReference page = new PageReference('/' + billing.id);
        page.setRedirect(true);
        
        return page;
    }
    
}