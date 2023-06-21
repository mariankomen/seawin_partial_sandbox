public with sharing class PackCreditOrderLinesController {

    public Id credit_order_id { get; set; }
    public AcctSeedERP__Shipment__c shipment { get; set; }
    public Credit_Order__c credit_order { get; set; }
    public List<Credit_Order_Line__c> credit_order_lines { get; set; }
    public List<PuckItemWrapper> puckWrapperList { get; set; }

    public Boolean visible { get; set; }
    
    public PackCreditOrderLinesController(ApexPages.StandardController stdController) {

        Id shipmentId = (Id)stdController.getId();
        puckWrapperList = new List<PuckItemWrapper>();
        shipment = [SELECT Id, Name, Credit_Order__c FROM AcctSeedERP__Shipment__c WHERE Id=:shipmentId];

        if(shipment.Credit_Order__c != null){
            credit_order = [SELECT Id, 
                                    Name, 
                                    Customer__c 
                                    FROM Credit_Order__c 
                                    WHERE Id=:shipment.Credit_Order__c];


            
            getRelatedLines();

        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'This functionality is not available for current Shipment, because can`t find related Credit Order record.'));
        }
    }

    /*****************************************************************************************************
    *   @method       : handleOpportunityChange
    *   @description  : 
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void getRelatedLines(){
        credit_order_lines = [SELECT Id,
                                    Name, 
                                    Product__r.Name,
                                    Product__r.ProductCode,
                                    Description__c,
                                    Quantity_Needed__c,
                                    Quantity_Ordered__c,
                                    Allocated_Quantity__c,
                                    Shipped_Quantity__c,
                                    Credit_Order__c,
                                    Sales_Order_Line__r.AcctSeedERP__Quantity_Allocated__c,
                                    Sales_Order_Line__r.Name,
                                    Sales_Order__c
                                    FROM Credit_Order_Line__c 
                                    WHERE Credit_Order__c =: credit_order.Id];

        if(!credit_order_lines.isEmpty()){
            for(Credit_Order_Line__c line:credit_order_lines){
                puckWrapperList.add(new PuckItemWrapper(line));
            }
        }
        
        visible = handleCheckAvailable(puckWrapperList);
    }

    public Boolean handleCheckAvailable(List<PuckItemWrapper> wrapper_list){
        Integer counter = 0;
        for(PuckItemWrapper piw:wrapper_list){
            if(piw.col.Allocated_Quantity__c == piw.col.Shipped_Quantity__c) counter++;
        }
        return counter != wrapper_list.size() ? true : false;
    }
    /*****************************************************************************************************
    *   @method       : handleSave
    *   @description  : gether all selected available to insert lines and insert Credit Order Shipment Lines
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void handleSave(){

        if(!puckWrapperList.isEmpty()){
            List<Shipment_Line_Credit_Order__c> shipment_lines = new List<Shipment_Line_Credit_Order__c>();
            for(PuckItemWrapper piw:puckWrapperList){
                if(piw.selected){
                    shipment_lines.add(createShipmentLine(piw.col));
                }
            }
            try{
                insert shipment_lines;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'The shipment lines have been saved'));
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            }
        }
        puckWrapperList.clear();
        getRelatedLines();
    }

    /*****************************************************************************************************
    *   @method       : createShipmentLine
    *   @description  : get in params Credit_Order_Line and create shipment lines by his field values
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public Shipment_Line_Credit_Order__c createShipmentLine(Credit_Order_Line__c col){

        Shipment_Line_Credit_Order__c credit_sh_line = new Shipment_Line_Credit_Order__c();

        credit_sh_line.Credit_Order__c = col.Credit_Order__c;
        credit_sh_line.Credit_Order_Line__c = col.Id;
        credit_sh_line.Description__c = col.Description__c;
        credit_sh_line.Product__c = col.Product__c;
        credit_sh_line.Sales_Order__c = col.Sales_Order__c;
        credit_sh_line.Shipment__c = shipment.Id;
        credit_sh_line.Quantity_Shipped__c = col.Allocated_Quantity__c != null ? col.Allocated_Quantity__c - col.Shipped_Quantity__c : col.Shipped_Quantity__c;

        return credit_sh_line;
    }


    public PageReference saveComplete(){
        PageReference ref = new PageReference('/'+shipment.Id);

        handleSave();

        return ref;
    }

    public void saveRefresh(){
        handleSave();
    }

    public class PuckItemWrapper{
        public Credit_Order_Line__c col {get; set;}
        public Boolean selected {get; set;}
        public Decimal availableQuantity {get; set;}

        public PuckItemWrapper(Credit_Order_Line__c line){
            col = line;
            selected = false;
            availableQuantity = col.Allocated_Quantity__c != null ? col.Allocated_Quantity__c - col.Shipped_Quantity__c : col.Shipped_Quantity__c;
        }
    }
}