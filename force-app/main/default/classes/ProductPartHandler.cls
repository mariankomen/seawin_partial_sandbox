public class ProductPartHandler {
    
    public static void BeforeInsert(List<AcctSeed__Product_Part__c> data){

        for(AcctSeed__Product_Part__c pp : data){
            
            pp.AcctSeed__Product__c = pp.Kit_Product__c;
            pp.AcctSeed__Product_Part__c = pp.Kit_Children__c;
            
        }
    }    
}