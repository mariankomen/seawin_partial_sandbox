public class OpportunityShipmentEditExtension {
   
    public string ShipmentID {get; set;}
    public string RetURL {get; set;}
    Public Boolean EditErrorMsgOpp {get; set;}
   
    public OpportunityShipmentEditExtension(ApexPages.StandardController std){
        
        ShipmentID = ApexPages.currentPage().getParameters().get('id');
        RetURL = ApexPages.currentPage().getParameters().get('retURL');
        EditErrorMsgOpp  = true;
    }
    
    public PageReference EditProcess(){
        
        Opportunity_Shipment__c shipment = [select id, Opportunity__c 
                                            from Opportunity_Shipment__c where id =: ShipmentID];
        
        LIST<AcctSeedERP__Sales_Order__c> SO = [select id from AcctSeedERP__Sales_Order__c
                                                where AcctSeedERP__Opportunity__c =: shipment.Opportunity__c limit 1];
        if(SO.isEmpty()){
            EditErrorMsgOpp = false;
            PageReference page = new PageReference('/'+ShipmentID+'/e?retURL=/apex/OpportunityPage?id='+shipment.Opportunity__c+'&nooverride=1');
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