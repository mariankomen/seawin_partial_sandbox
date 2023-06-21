public with sharing class DeleteCreditOrderLineController {
    

    private ApexPages.StandardController standardController;
    public Credit_Order_Line__c selectedLine {get; set;}
    public String retUrl {get; set;}

    public Boolean allocated_condition {get; set;}
    public Boolean shipped_condition {get; set;}
    public Boolean billed_condition {get; set;}

    public List<Credit_Order_Line__c> deletable {get; set;}
    public DeleteCreditOrderLineController(ApexPages.StandardController standardController) {
        this.standardController = standardController;
        Id recordId = (Id)standardController.getId();
        selectedLine = [SELECT Id, Credit_Order__c, Shipped_Quantity__c, Allocated_Quantity__c FROM Credit_Order_Line__c WHERE Id=:recordId];
        retUrl = String.valueOf(selectedLine.Credit_Order__c);
        deletable = new List<Credit_Order_Line__c>{selectedLine};
        // initialAction(new List<Credit_Order_Line__c>{selectedLine});
    }

    public void initialAction(){

        Set<Id> lines_set = CreditOrderLineTriggerHandler.getSetFromListHepler(deletable);
        
        List<AcctSeed__Billing_Line__c> related_billing_lines = [SELECT Id, Credit_Order_Line__c FROM AcctSeed__Billing_Line__c WHERE Credit_Order_Line__c IN:lines_set];
        Map<Id, AcctSeed__Billing_Line__c> cl_billing_line_map = new Map<Id, AcctSeed__Billing_Line__c>();
        for(AcctSeed__Billing_Line__c bl: related_billing_lines){
            cl_billing_line_map.put(bl.Credit_Order_Line__c, bl);
        }

        for(Credit_Order_Line__c col: deletable){

            if(cl_billing_line_map.containsKey(col.Id)){
                billed_condition = true;
            }else if(col.Shipped_Quantity__c > 0){
                shipped_condition = true;
            }else if(col.Allocated_Quantity__c > 0){
                allocated_condition = true;
            }else{
                try{
                    delete col;
                }catch(Exception e){
                    System.debug('Error at DeleteCreditOrderLineController: '+e.getMessage());
                }
            }

        }

    }
}