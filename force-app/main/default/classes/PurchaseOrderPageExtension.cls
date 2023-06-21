public class PurchaseOrderPageExtension {
    public AcctSeedERP__Purchase_Order__c po {get; set;}
    public Boolean showChangeMessage {get; set;}
    public boolean ShowIntransitMessage {get; set;}
    public string ChangeMessage {get; set;}
    public String baseUrl {get; set;}
    
    public PurchaseOrderPageExtension(ApexPages.StandardController std) {
        
        po = new AcctSeedERP__Purchase_Order__c();
        showChangeMessage = false;
        ShowIntransitMessage = false;
        ChangeMessage = null;
        baseUrl = System.URL.getOrgDomainUrl().toExternalForm();
        
        list<string> fields = new list<string>{'Name', 'Status_Helper__c','AcctSeedERP__Status__c','AcctSeedERP__Vendor_Street__c',
        'Stage__c', 'In_Transit_Message_Show__c'}; 
            If(!Test.isRunningTest()) {std.addFields(fields);}
        
        po = (AcctSeedERP__Purchase_Order__c)std.getRecord();
        
        if(po.Status_Helper__c == 'Open' && po.AcctSeedERP__Status__c == 'Closed'){
            showChangeMessage = true;
            ChangeMessage = 'Status from Open was changed to Closed';
        }

        if(po.In_Transit_Message_Show__c){

            ShowIntransitMessage = true;
        }
    }
    public void hideChangeMessage(){
        showChangeMessage = false;
    }

    public void hideIntransitMessage(){
        showIntransitMessage = false;
    }
    public PageREference removeHelperValue(){
        try{
            po.Status_Helper__c = null;
            update po;
        }
        catch(Exception ex){
            system.debug(ex.getDMLMessage(0));
        }
        return null;
    }
    public PageReference MarkInTransit(){

        try{

            po.In_Transit_Message_Show__c = false;

            update po;
        }catch(Exception ex){

            system.debug(ex.getDMLMessage(0));
        }

        return null;
    }
}