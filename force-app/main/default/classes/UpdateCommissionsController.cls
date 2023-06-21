public class UpdateCommissionsController {
    
    public AcctSeedERP__Sales_Order__c so {get; set;}
    public Opportunity opp {get; set;}
    public Boolean CommissionRateHasChanged {get; set;}
    
    public boolean SalesCommissionChanges {get; set;}
    public boolean ManufacturerCommissionChanges {get; set;}
    public boolean ReferralCommissionChanges {get; set;}
    public boolean SpecifiedCommissionChanges {get; set;}
    
    public Boolean salesOrderCommissions {get; set;}

    public string communityUrl {
        
        get{
            
            User usr = [select contactId from user where id =: userInfo.getUserId() limit 1];
            
            return usr.contactId == null ? '' : '/sales';
        }
    }
    
    public UpdateCommissionsController(){
        
        String soId = ApexPages.currentPage().getParameters().get('salesorderid');
        SalesCommissionChanges = true;
        ManufacturerCommissionChanges = true;
        ReferralCommissionChanges = true;
        SpecifiedCommissionChanges = true;

        
        if(String.valueOf(Id.valueOf(soId).getSObjectType()) == 'Opportunity'){
            salesOrderCommissions = false;
            opp = [select id, Name,
                        Commission_Rate_Sales_Rep__c,
                        Commission_Rate_Manufacturer_Rep__c,
                        Commission_Rate_Referral_Sales_Rep__c,
                        Commission_Rate_Specified_Rep__c
                        from Opportunity 
                        where Id =: soId Limit 1];

        }else if(String.valueOf(Id.valueOf(soId).getSObjectType()) == 'AcctSeedERP__Sales_Order__c'){
            salesOrderCommissions = true;
            so = [select id, Name,
                        Commission_Rate_Sales_Rep__c,
                        Commission_Rate_Manufacturer_Rep__c,
                        Commission_Rate_Referral_Sales_Rep__c,
                        Commission_Rate_Specified_Rep__c
                        from AcctSeedERP__Sales_Order__c 
                        where Id =: soId Limit 1];
        }
        
        
    }
    
    public PageReference PageAction(){
        
        Pagereference page = new PageReference(communityUrl + '/' + so.id);
        CalculateCommissionsHandler.updateExistingCommissions(so.Id);

        // if(salesOrderCommissions){
        //     CalculateCommissionsHandler.UpdateCommissions(so, SalesCommissionChanges, ManufacturerCommissionChanges, 
        //     ReferralCommissionChanges, SpecifiedCommissionChanges);

        //     CalculateCommissionsHandler.updateExistingCommissions(so.Id);
        //     page = new PageReference(communityUrl + '/' + so.id);
        // }else{
        //     CalculateCommissionsHandler.UpdateCommissionsOpportunity(opp, SalesCommissionChanges, ManufacturerCommissionChanges, 
        //     ReferralCommissionChanges, SpecifiedCommissionChanges);
        //     page = new PageReference(communityUrl + '/' + opp.id);
        // }
        
        
        
        page.setRedirect(true);
        return page;
    }
    
    public PageReference back(){
        
        PageReference page = new PageReference(communityURL + '/' + so.id);
        page.setRedirect(true);
        
        return page;
    }
}