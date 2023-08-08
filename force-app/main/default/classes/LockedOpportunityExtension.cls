public class LockedOpportunityExtension {
    
    Public Opportunity o {get; set;}
    Public Boolean Sent {get; set;}
    Public Boolean Rejected {get; set;}
    Public Boolean Billed {get; set;}
    Public Boolean Closed {get; set;}
    Public Boolean Specified {get; set;}
    Public Boolean AlreadySpecified {get; set;}
    public Boolean opportunityLinesHaveDifferentPriceLevel {get;set;}
    public LockedOpportunityExtension(ApexPages.StandardController std){

        o = [select id, name,Referral_Sales_Rep__c,Specified_Rep__c,Specified_del__c, Price_Level__c, Sent_for_Approval__c,Account.Status__c,TotalBills__c,
            StageName,TotalSalesOrderInOpp__c from opportunity where id =:std.getId() limit 1];
        
        opportunityLinesHaveDifferentPriceLevel = checkOpportunityLinesPriceLevel();
        Sent = o.Sent_for_Approval__c;
        Rejected = o.Account.Status__c == 'Rejected' ? true : false;
        Billed = o.TotalBills__c > 0 ? true : false;
        Closed = o.Account.Status__c != 'Rejected' && o.StageName == 'Closed Won' && o.TotalSalesOrderInOpp__c > 0;
		Specified = o.Referral_Sales_Rep__c != null && o.Specified_Rep__c == null && o.Specified_del__c == false;
        AlreadySpecified = o.Specified_Rep__c != null;
        String msg = '';

        // If Opportunity in Approval
        if(Sent){
            msg = 'Locked Opportunity, pending Approval.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, msg));
        }
        
        // If Account is rejected
        if(Rejected){
            msg = 'Opportunity is Locked. The Account is Rejected.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, msg));
        }
        
        // If Stage is Closed Won and there is SO
        if(Closed){
            msg = 'Opportunity is Locked, because the Stage is Closed Won and it has Sales Order(s).';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, msg));
        }
        
        // If there is billing
        if(Billed){
            msg = 'Sales Price or Quantity cannot be changed and Products can not be deleted,'; 
            msg += ' as Billing has already been created.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, msg));
        }
        if(Specified){
            msg = 'If the Project is Specified, check the specified checkbox.'; 
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, msg));
        }
        if(AlreadySpecified){
            msg = 'Specified Project.'; 
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, msg));
        }
        if(opportunityLinesHaveDifferentPriceLevel){
            msg = 'Need to reprice this opportunity. Price level does not match price level at the time of quoting.'; 
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Warning, msg));
        }
        
        
    }

    public Boolean checkOpportunityLinesPriceLevel(){
        List<OpportunityLineItem> OpportunityItemsList = [SELECT Id, Price_Level__c FROM OpportunityLineItem WHERE OpportunityId=:o.Id];
        Boolean linePriceLevelEqualOpportunityLevel = false;
        for(OpportunityLineItem oli: OpportunityItemsList){
            if(oli.Price_Level__c != o.Price_Level__c){
                linePriceLevelEqualOpportunityLevel = true;
                break;
            }
        }

        return linePriceLevelEqualOpportunityLevel;
    }
}