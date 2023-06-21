public class DeleteSalesOrderCommissionsExtension {
    
    public Id commissionId {get; set;}
    
    public string communityUrl { get; set;}
    public string retURL {get; set;}
    
    public DeleteSalesOrderCommissionsExtension(ApexPages.StandardController std){
     
        commissionId = (Id)std.getId();
        communityUrl = UserInfo.getUserType() == 'PowerPartner' ? '/sales' : '';
        retURL = ApexPages.currentPage().getParameters().get('retURL');
    }
    
    public PageReference pageAction(){
        
        PageReference reference = null;
        
        List<AcctSeed__Account_Payable__c> payables = [select Id from AcctSeed__Account_Payable__c
                                                      where sales_order_commissions__c =:commissionId Limit 1];
        
        if(!payables.isEmpty()){
            // payable exists so cannot delete
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 
                                                       'Payable exists for this sales order commission,' + 
                                                       ' please first remove that and try again.'));
            
        }else{
            
            delete new Sales_Order_Commissions__c(id=commissionId);
            
            reference = new PageReference(communityUrl + retURL);
            reference.setRedirect(true);
        }
           
        return reference;
    }
}