public class DeleteLineItemExtension {

    private Id oppId {get; set;}
    private Id SOID {get; set;}
    private List<OpportunityLineItem> OLIData {get; set;}
    private List<Optional_Products_Opportunity__c> OOLIData {get; set;}
    private List<AcctSeedERP__Sales_Order_Line__c> SLIData {get; set;}
    public List<AcctSeed__Billing__c> BillingOpp {get; set;}
    public List<AcctSeed__Billing__c> BillingSO {get; set;}
    public String LineType {get; set;}
    public Boolean hasBillingLinesOLI {get; set;}
    public Boolean hasBillingLinesSOL {get; set;}
    // tabstyle
    public string strTabName{set;}
    public String getStrTabName(){ 
        if(lineType == 'oli' || LineType == 'ooli')
        { 
            return 'Opportunity';
        }
        else if(lineType == 'sli'){
            return 'AcctSeedERP__Sales_Order__c';
        }
        return null;
    }
    
    
    public DeleteLineItemExtension(){
        
        OppId = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'));
        SOID = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'));
        lineType = ApexPages.currentPage().getParameters().get('linesType');
        integer count = Integer.valueOf(ApexPages.currentPage().getParameters().get('count'));
        
        OLIData = new List<OpportunityLineItem>();
        OOLIData = new LIST<Optional_Products_Opportunity__c>();
        BillingOpp = new List<AcctSeed__Billing__c>();
        SLIData = new List<AcctSeedERP__Sales_Order_Line__c>();
        BillingSO = new List<AcctSeed__Billing__c>();
        
        set<Id> recordIds = new set<Id>();
        
        for(integer i = 0; i < count; i++){
            Id lineID = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'+i));
            recordIds.add(lineID);
        }
        
        hasBillingLinesOLI = false;
        hasBillingLinesSOL = false;
        if(lineType == 'oli'){
            List<AcctSeed__Billing_Line__c> billingLines_OLI = [SELECT Id, AcctSeed__Opportunity_Product_Id__c FROM AcctSeed__Billing_Line__c WHERE AcctSeed__Opportunity_Product_Id__c IN:recordIds];
            OLIData = [SELECT Id FROM OpportunityLineItem WHERE Id IN : recordIds AND OpportunityId =: OppId];
            if(!billingLines_OLI.isEmpty()){
                hasBillingLinesOLI = true;
            }
        }else if(lineType == 'ooli'){
            OOLIData = [SELECT Id FROM Optional_Products_Opportunity__c WHERE Id IN : recordIds AND Opportunity__c =: OppId];
        }else if(lineType == 'sli'){
            List<AcctSeed__Billing_Line__c> BillingLines = [SELECT id, AcctSeedERP__Sales_Order_Line__c FROM AcctSeed__Billing_Line__c WHERE AcctSeedERP__Sales_Order_Line__c IN:recordIds];
            SLIData = [SELECT Id FROM AcctSeedERP__Sales_Order_Line__c WHERE Id IN : recordIds AND AcctSeedERP__Sales_Order__c =: SOID];
            if(!BillingLines.isEmpty()){
                hasBillingLinesSOL = true;
            }

        }

    }
    
    public PageReference dmlOperation() {

        if(lineType == 'oli' && hasBillingLinesOLI == false){
            delete OLIData;
        }else if(lineType == 'ooli'){
            delete OOLIData;
        }else if(lineType == 'sli' && hasBillingLinesSOL == false){
            delete SLIData;
        }else{
            return null;
        }
        
        PageReference retURL;
        if(lineType == 'oli' || LineType == 'ooli'){
            retURL = new PageReference('/' + oppId);
        }else{
            retURL = new PageReference('/' + SOID);
        }
        
        retURL.setRedirect(true);
        return retURL;
    }
    
    public PageReference back(){
        PageReference page;
        
        if(lineType == 'oli' || LineType == 'oli'){
            page = new PageReference('/' + oppId);
            
        }else{
            
            page = new PageReference('/' + SOID);
        }
        
        page.setRedirect(true);
        return page;
    }
}