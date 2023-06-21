public class OpportunityShipmentDeleteExtension {

    public string ShipmentID {get; set;}
    public string RetURL {get; set;}
    Public Boolean DeleteErrorMsgShipment {get; set;}
   
    public OpportunityShipmentDeleteExtension(ApexPages.StandardController std){
        
        ShipmentID = ApexPages.currentPage().getParameters().get('id');
        RetURL = ApexPages.currentPage().getParameters().get('retURL');
        DeleteErrorMsgShipment  = true;
    }
    
    public PageReference DeleteProcess(){
        
        Opportunity_Shipment__c shipment = [select id, Opportunity__c 
                                            from Opportunity_Shipment__c where id =: ShipmentID];
        
        LIST<AcctSeedERP__Sales_Order__c> SO = [select id from AcctSeedERP__Sales_Order__c
                                                where AcctSeedERP__Opportunity__c =: shipment.Opportunity__c limit 1];
        if(SO.isEmpty()){
            DeleteErrorMsgShipment = false;
            delete shipment;
            PageReference page = new PageReference('/'+shipment.Opportunity__c);
            page.setRedirect(true);
            return page;
        }
         
        return null;
    }
    
    public PageReference back(){
      
         PageReference page = new PageReference(RetURL);
         page.setRedirect(true);
         return page;
     }
    
}