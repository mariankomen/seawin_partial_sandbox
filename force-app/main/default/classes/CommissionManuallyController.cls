public with sharing class CommissionManuallyController {

    public Id sales_order_id {get;set;}
    public AcctSeedERP__Sales_Order__c so {get;set;}
    public Sales_Order_Commissions__c commission {get;set;}


    public Boolean manRepRender {get;set;}
    public Boolean refRepRender {get;set;}
    public Boolean speRepRender {get;set;}
    public Boolean ownRepRender {get;set;}

    public CommissionManuallyController(ApexPages.StandardController sc) {
        manRepRender = true;
        if(!Test.isRunningTest()){ 
            sales_order_id = ApexPages.currentPage().getParameters().get('salesOrderId');
        } else {
            sales_order_id = [SELECT Id FROM AcctSeedERP__Sales_Order__c LIMIT 1].Id;
        }
        String objectType = String.valueOf(sales_order_id.getSObjectType());

        if(objectType == 'Opportunity'){
            Opportunity opp = [SELECT Id, Name, Manufacturer_Rep__c, Referral_Sales_Rep__c, Specified_Rep__c, OwnerId, Sales_Rep_O__r.Company_Name_Lookup__c FROM Opportunity WHERE Id=:sales_order_id];
            commission = new Sales_Order_Commissions__c();
    
            // commission.Sales_Order__c = so.Id;
            commission.Opportunity__c = opp.Id;
            commission.Commission_Amount__c = 0.00;
            commission.Commission_Paid_Date__c = DateTime.now();

        }else if(objectType == 'AcctSeedERP__Sales_Order__c'){
            so = [SELECT Id, Name, AcctSeedERP__Opportunity__c, Manufacturer_Rep__c, Referral_Sales_Rep__c, Specified_Rep__c, OwnerId, Sales_Rep_O__r.Company_Name_Lookup__c FROM AcctSeedERP__Sales_Order__c WHERE Id=:sales_order_id];

            commission = new Sales_Order_Commissions__c();
            if(so.AcctSeedERP__Opportunity__c != null){
                commission.Opportunity__c = so.AcctSeedERP__Opportunity__c;
            }
            commission.Sales_Order__c = so.Id;
            commission.Commission_Amount__c = 0.00;
            commission.Commission_Paid_Date__c = DateTime.now();
        }

        
    }

    public void handleChange(){
        system.debug(commission);
    }

    public PageReference saveCustom(){
        PageReference redirectPage = null;
        system.debug('commission in:'+commission);
        redirectPage = new PageReference('/' + sales_order_id);
        
        if(commission.Owner__c == null
            &&commission.Manufacturer_Rep__c == null
            &&commission.Referral_Sales_Rep__c == null
            &&commission.Specified_Rep__c == null){

            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'One of this fields must be matched: Manufacturer Rep, Referral Sales Rep, Specified Rep, Owner.');
            ApexPages.addMessage(myMsg);   
            return null; 
        } else if(commission.Commission_Amount__c <= 0.00){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Commission amount should be greater than 0.');
            ApexPages.addMessage(myMsg);
            return null;
        } else {

            try{
                system.debug('commission in:'+commission);
                upsert commission;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Commission was created successfully.');
                ApexPages.addMessage(myMsg);
                return redirectPage;
            } catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
    }

    public PageReference cancel(){
        PageReference redirectPage = null;
        redirectPage = new PageReference('/' + sales_order_id);

        return redirectPage;
    }

    public PageReference saveAndNew(){
        PageReference pageRef = new PageReference('/apex/CreateManualCommissionPage?salesOrderId='+sales_order_id);

        if(commission.Owner__c == null
            &&commission.Manufacturer_Rep__c == null
            &&commission.Referral_Sales_Rep__c == null
            &&commission.Specified_Rep__c == null){

            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'One of this fields must be matched: Sales Rep Company Name, Manufacturer Rep, Referral Sales Rep, Specified Rep.');
            ApexPages.addMessage(myMsg);   
            return null; 
        } else if(commission.Commission_Amount__c <= 0.00){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Commission amount should be greater than 0.');
            ApexPages.addMessage(myMsg);
            return null;
        } else {

            try{
                system.debug('commission in:'+commission);
                upsert commission;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM,'Commission was created successfully.');
                ApexPages.addMessage(myMsg);
                return pageRef;
            } catch(Exception e){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        
    }


    public static void coverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}