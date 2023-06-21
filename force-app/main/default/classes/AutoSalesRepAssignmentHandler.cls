public class AutoSalesRepAssignmentHandler {
    
    public static void Assignment(List<sObject> data){
     	
    	List<Sales_Rep__c> salesrep = [select Id from Sales_Rep__c where Name LIKE '%House Account%' Limit 1];  
        
        for(sObject s : data){
            
            if(s.get('sales_rep_o__c') == null && !salesrep.isEmpty()){
                
                s.put('sales_rep_o__c', salesrep[0].id);
            }
        }
    }
}