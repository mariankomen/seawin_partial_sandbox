public class InventryQtyAvailblHstryLblTmpltExtension {
    
    Public List<Wrapper> wrapperList {get; set;}
    public String data {get; set;}
    public List<id> idsList {get; set;}
    public List<String> templateList {get; set;}
    
    public InventryQtyAvailblHstryLblTmpltExtension(){
        
        idsList = new List<id>();
        templateList = new List<String>();
        data = ApexPages.currentPage().getParameters().get('data');
        List<String> splitData = data.split(',');
        
        for(String s : splitData){
            idsList.add(s.split(':')[0]);
            templateList.add(s.split(':')[1]);
        } 
        
        wrapperList = new List<Wrapper>();
        
        List<AcctSeedERP__Inventory_Balance_History__c> lines = 
            [select id, AcctSeedERP__Inventory_Balance__c,AcctSeedERP__Available_Quantity__c,
             AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Name,
             AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Size__c,
             AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Series__c,
             AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Glass__c,
             AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Glass_Thickness__c,
             AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.ProductCode,
             AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Direction__c,
             AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.Description                   
             from AcctSeedERP__Inventory_Balance_History__c 
             where id in: idsList ]; 
        
        if(!lines.isEmpty()){
            Integer i = 0;
            for(AcctSeedERP__Inventory_Balance_History__c m : lines){
                
                List<Integer> iterations = new List<Integer>();
                for(Integer j = 1; j <= m.AcctSeedERP__Available_Quantity__c; j++){
                    iterations.add(j);
                }
                
                wrapperList.add(new Wrapper(m, templateList[i], iterations));
                i++;
            }
        }
        
    }
    
    Public class Wrapper{
        
        public AcctSeedERP__Inventory_Balance_History__c movement {get; set;}
        public String template {get; set;}
        public List<Integer> noOfIterations {get; set;}
        
        public Wrapper(AcctSeedERP__Inventory_Balance_History__c m, String temp, List<Integer> Iterations){
            movement = m;
            template = temp;
            noOfIterations = Iterations;
        }
    }
}