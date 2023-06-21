public class DeleteSalesOrderLineExtensions {
    
    Private List<AcctSeedERP__Sales_Order_Line__c> SalesOrderLines {get; set;}
    Private static Id SOLId {get; set;}
    Private Id SOId {get; set;}
    
    Private Boolean LineExists {get{
        
        if(LineExists == null){
            
            LineExists = false;
        }
        
        return LineExists;
        
    } set;}
    
    public DeleteSalesOrderLineExtensions(ApexPages.StandardController std){
        
     	SOLId = (Id)std.getId();
        
        SalesOrderLines = new List<AcctSeedERP__Sales_Order_Line__c>(); 
        
        List<AcctSeed__Billing_Line__c> BillingLines = [select id, AcctSeedERP__Sales_Order_Line__c from 
                                                       AcctSeed__Billing_Line__c where AcctSeedERP__Sales_Order_Line__c =:
                                                       SOLId];
        SalesOrderLines = [select id, AcctSeedERP__Sales_Order__c from AcctSeedERP__Sales_Order_Line__c where
                                                           id =:SOLId];
        
        SOId = SalesOrderLines[0].AcctSeedERP__Sales_Order__c;
        
        if(!BillingLines.IsEmpty()){
            
            LineExists = True;
        }
    }
    
    public PageReference doDelete(){
        
        if(LineExists){
           ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
                                                       'The Sales Order Line Item cannot be deleted ' +
                                                       'because it has associated Billing Line Item.'));
        }else{
            
            // delete the line item
            if(!SalesOrderLines.IsEmpty()){
                
                delete SalesOrderLines;
                
                PageReference page = new PageReference('/' + SOId);
                Page.setRedirect(True);
                return Page;
            }
        }
        
        return null;
    }
    
    public PageReference GetBackToSalesOrder(){
        
        PageReference page = new PageReference('/' + SOId);
        Page.setRedirect(True);
        return Page;
    }
}