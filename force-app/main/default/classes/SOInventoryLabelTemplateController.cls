public class SOInventoryLabelTemplateController {
    
    Public List<Wrapper> wrapperList {get; set;}
    public String data {get; set;}
    public List<id> idsList {get; set;}
    public List<String> templateList {get; set;}
    
    public SOInventoryLabelTemplateController(){
        
        idsList = new List<id>();
        templateList = new List<String>();
        
        data = ApexPages.currentPage().getParameters().get('data');

        System.debug('data: ' + data);
        
        
        List<String> splitData = data.split(',');
        System.debug('splitData: ' + splitData);
        
        for(String s : splitData){
            idsList.add(s.split(':')[0]);
            templateList.add(s.split(':')[1]);
        } 
        
        wrapperList = new List<Wrapper>();
        
        List<AcctSeedERP__Sales_Order_Inventory_Movement__c> lines = 
            [select id, AcctSeedERP__Warehouse__c, AcctSeedERP__Sales_Order_Line__c,
             AcctSeedERP__Product__c,AcctSeedERP__Quantity__c,
             AcctSeedERP__Sales_Order_Line__r.Name,
             AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Series__c,
             AcctSeedERP__Sales_Order_Line__r.Size__c,
             AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.Name,
             AcctSeedERP__Sales_Order_Line__r.ProductCode__c,
             AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Glass__c,
             AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Glass_Thickness__c,
             AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Direction__c,
             AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.AcctSeedERP__Initial_Receive_Date__c,
             AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.Shipped_Date__c
             from AcctSeedERP__Sales_Order_Inventory_Movement__c 
             where id in: idsList ]; 
        
        System.debug('lines: ' + lines);
        if(!lines.isEmpty()){
            Integer i = 0;
            for(AcctSeedERP__Sales_Order_Inventory_Movement__c m : lines){
                System.debug('AcctSeedERP__Quantity__c: ' + m.AcctSeedERP__Quantity__c);
                List<Integer> iterations = new List<Integer>();
                for(Integer j = 1; j <= m.AcctSeedERP__Quantity__c; j++){
                    iterations.add(j);
                }
                
                wrapperList.add(new Wrapper(m, templateList[i], iterations));
                i++;
            }
        }
        
    }
    
    
    Public class Wrapper{
        
        public AcctSeedERP__Sales_Order_Inventory_Movement__c movement {get; set;}
        public String template {get; set;}
        public List<Integer> noOfIterations {get; set;}
        
        public Wrapper(AcctSeedERP__Sales_Order_Inventory_Movement__c m, String temp, List<Integer> Iterations){
            movement = m;
            template = temp;
            noOfIterations = Iterations;
        }
    }
    
}