public with sharing class DeAllocateCreditOrderController {

    private ApexPages.StandardSetController standardController;
    public List<Credit_Order_Line__c> selectedLines {get; set;}
    public Set<Id> selectedLines_ids {get; set;}
    public String retUrl {get; set;}
    public DeAllocateCreditOrderController(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
        selectedLines = new List<Credit_Order_Line__c>();
        selectedLines_ids = new Set<Id>();
        selectedLines = getLines((List<Credit_Order_Line__c>) standardController.getSelected());
        retUrl = ApexPages.currentPage().getParameters().get('retURL');
        system.debug(selectedLines.size());
        for(Credit_Order_Line__c line: selectedLines){
            if(line.Shipped_Quantity__c == 0){
                selectedLines_ids.add(line.Id);
            }
        }
    }


    public PageReference initialAction(){
        if(!selectedLines.isEmpty()){
            List<Credit_Order_Inventory_Movement__c> deletable = [SELECT Id FROM Credit_Order_Inventory_Movement__c WHERE Credit_Order_Line__c IN:selectedLines_ids];
            if(selectedLines_ids.size() < selectedLines.size()){
                ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Can not deallocate Credit Order Line(s) which were shipped.');
                ApexPages.addMessage(errorMessage);

                return null;
            }else{
                delete deletable;
                return new PageReference('/'+retUrl);
            }
        }else{
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.WARNING, 'You must select at least 1 line for de-allocating.');
            ApexPages.addMessage(errorMessage);

            return null;
        }
    }

    public List<Credit_Order_Line__c> getLines(List<Credit_Order_Line__c> lines){
        Set<Id> credit_order_line_ids = new Set<Id>();
        for(Credit_Order_Line__c l:lines){
            credit_order_line_ids.add(l.Id);
        }
        List<Credit_Order_Line__c> queried_data = [SELECT Id, 
                                                            Credit_Order__c,
                                                            Shipped_Quantity__c,
                                                            Quantity_Ordered__c
                                                            FROM Credit_Order_Line__c 
                                                            WHERE Id IN:credit_order_line_ids];
        return queried_data;                                                    
    }
}