public with sharing class PurchaseOrderMessageController {

    private final AcctSeedERP__Purchase_Order__c purchaseOrder;
    public Boolean displayMessage {get; set;}

    public PurchaseOrderMessageController(ApexPages.StandardController stdController) {
        AcctSeedERP__Purchase_Order__c po = (AcctSeedERP__Purchase_Order__c)stdController.getRecord();
        purchaseOrder = [SELECT Id, Sales_Order__c FROM AcctSeedERP__Purchase_Order__c WHERE Id=:po.Id];
        displayMessage = false;
        if(purchaseOrder.Sales_Order__c != null){
            AcctSeedERP__Sales_Order__c salesOrder = [SELECT Id, Manufacturer_Rep__c FROM AcctSeedERP__Sales_Order__c WHERE Id=:purchaseOrder.Sales_Order__c];
            displayMessage = salesOrder.Manufacturer_Rep__c != null ? true : false;
        }
    }
}