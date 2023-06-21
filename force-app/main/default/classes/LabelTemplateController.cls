public class LabelTemplateController {
    
    Public List<Wrapper> wrapperList {get; set;}
    public String data {get; set;}
    public List<id> idsList {get; set;}
    public List<String> templateList {get; set;}
    
    public LabelTemplateController(){
        
        idsList = new List<id>();
        templateList = new List<String>();
        
        data = ApexPages.currentPage().getParameters().get('data');
        
        List<String> splitData = data.split(',');
        
        for(String s : splitData){
            idsList.add(s.split(':')[0]);//At index 0 we have id while at index 1 we have desired Template to be printed
            templateList.add(s.split(':')[1]);
        } 
        
        wrapperList = new List<Wrapper>();
        
        List<PO_Shipment_Line__c> lines = [select id, name, PO_Shipment__c,Product__c,
                                           Product_Code__c,Size__c,
                                           Total_Price__c,
                                           Quantity_Shipped__c,
                                           PO_Shipment__r.name,
                                           Purchase_Order__r.AcctSeedERP__Order_Date__c,
                                           Purchase_Order_Line__r.Quantity_Received_Formula__c,
                                           PO_Shipment__r.Date__c,
                                           PO_Shipment__r.Purchase_Order__r.name,
                                           PO_Shipment__r.Purchase_Order__r.Shipped_Date__c,
                                           Purchase_Order__r.AcctSeedERP__Initial_Receive_Date__c,
                                           Purchase_Order__r.Stage__c,
                                           Product__r.Name,
                                           Product__r.Series__c,
                                           Product__r.size__c,
                                           Product__r.Glass__c,
                                           Product__r.Direction__c,
                                           Product__r.Glass_Thickness__c,
                                           Product__r.Hardware_Finish__c,
                                           Product__r.ProductCode, LastModifiedDate
                                           from PO_Shipment_Line__c where id in: idsList ]; 
        
        String warehouseName = '';
        if(!lines.isEmpty()){
            Integer i = 0;
            for(PO_Shipment_Line__c l : lines){
                if(l.Purchase_Order_Line__r.Quantity_Received_Formula__c > 0 ){
                    AcctSeedERP__Purchase_Order_Inventory_Movement__c poInvMovemnt = [select id,AcctSeedERP__Warehouse__c 
                                                                                      from AcctSeedERP__Purchase_Order_Inventory_Movement__c
                                                                                      where AcctSeedERP__Purchase_Order_Line__c =: l.Purchase_Order_Line__r.Id limit 1];
                    warehouseName = poInvMovemnt.AcctSeedERP__Warehouse__c;
                }
                List<Integer> iterations = new List<Integer>();
                for(Integer j = 1; j <= l.Quantity_Shipped__c; j++){
                    iterations.add(j);
                }
                System.debug('wrapperList: ' + wrapperList);
                wrapperList.add(new Wrapper(l, templateList[i], warehouseName, iterations));
                i++;
            }
        }
    }
    
    Public class Wrapper{
        
        public PO_Shipment_Line__c line {get; set;}
        public String warehouseName {get; set;}
        public String template {get; set;}
        public List<Integer> noOfIterations {get; set;}
        
        public Wrapper(PO_Shipment_Line__c l, String temp, String wh, List<Integer> Iterations){
            line = l;
            template = temp;
            warehouseName = wh;
            noOfIterations = Iterations;
        }
    }
}