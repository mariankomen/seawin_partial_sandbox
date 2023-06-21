public with sharing class CreatePaymentFromCreditMemo {
    public String billingId {get;set;}
    public AcctSeed__Account_Payable__c payable {get;set;}
    public AcctSeed__Billing__c billing {get;set;}
    public List<AcctSeed__Billing_Line__c> billingLines {get;set;}

    public CreatePaymentFromCreditMemo() {
        
        billingId = ApexPages.currentPage().getParameters().get('id');
        payable = new AcctSeed__Account_Payable__c();
        billing = [SELECT Id, Name, AcctSeed__Customer__c FROM AcctSeed__Billing__c WHERE Id=:billingId];
        billingLines = [SELECT Id, Name, AcctSeed__GL_Account_Variable_1__c, AcctSeed__Expense_GL_Account__c, AcctSeed__Hours_Units__c, AcctSeed__Total__c, AcctSeed__Product__c FROM AcctSeed__Billing_Line__c WHERE AcctSeed__Billing__c =:billing.Id];
        system.debug('billingId: '+billingId);
        predefinePayableFields();
    }

    public void predefinePayableFields(){
        String paymentRefference = 'Credit Memo & ' + billing.Name +' - '+ Datetime.now().format('MM/dd/yyyy hh:mm:ss z');
        payable.AcctSeed__Vendor__c = billing.AcctSeed__Customer__c;
        payable.OwnerId = UserInfo.getUserId();
        payable.AcctSeed__Payee_Reference__c = paymentRefference;
        payable.Billing__c = billingId;
        
    }

    public PageReference savePayable(){
        try{
            insert payable;
            List<AcctSeed__Account_Payable_Line__c> payableLines = createPayableLines(payable.Id);

            if(!payableLines.isEmpty()){
                insert payableLines;
            }
            PageReference ref = new PageReference('/'+payable.Id);
            return ref;
        }catch(Exception e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
            ApexPages.addMessage(myMsg);
            return null;
        }
        
    }

    public List<AcctSeed__Account_Payable_Line__c> createPayableLines(Id payableId){
        List<AcctSeed__Account_Payable_Line__c> payableLines = new List<AcctSeed__Account_Payable_Line__c>();

        for(AcctSeed__Billing_Line__c billingLine: billingLines){
            AcctSeed__Account_Payable_Line__c payableLine = new AcctSeed__Account_Payable_Line__c();
            payableLine.AcctSeed__Account_Payable__c = payableId;
            payableLine.AcctSeed__Amount__c = billingLine.AcctSeed__Total__c;
            payableLine.AcctSeed__Product__c = billingLine.AcctSeed__Product__c;
            payableLine.AcctSeed__Expense_GL_Account__c = billingLine.AcctSeed__Expense_GL_Account__c;
            payableLine.AcctSeed__GL_Account_Variable_1__c = billingLine.AcctSeed__GL_Account_Variable_1__c;
            payableLine.AcctSeed__Quantity__c = billingLine.AcctSeed__Hours_Units__c;

            payableLines.add(payableLine);
        }

        return payableLines;
    }

}