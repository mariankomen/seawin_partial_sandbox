public class ProductHandler {
    
    public static void process(List<Product2> data){ 
        
        map<id, product2> productMap = new map<id, product2>(data);
        
        String PriceBookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [SELECT id from Pricebook2 where isStandard=true][0].Id;
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        
        for(Product2 prod: data){
            
            Decimal unitcost = prod.AcctSeed__Unit_Cost__c != null ?
                prod.AcctSeed__Unit_Cost__c : 0;
            
            PriceBookEntry pbe = 
                new PriceBookEntry(Product2Id = prod.Id, Pricebook2Id = PriceBookId, IsActive = True, UnitPrice = unitcost, UseStandardPrice = false);
            
            if(!prod.isClone() && !Test.isRunningTest()) pbeList.add(pbe);
        }
        
        if(pbeList.size()>0){
            try{
                
                insert pbeList;
            }catch(Exception ex){
                
                system.debug(ex.getMessage());
            }
        }
    }
}