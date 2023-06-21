public class NullifyTemporaryValues {
    
    public static void Nullify(List<sobject> data){
        
        for(sobject s : data){
         	
            if(s.getSobjectType().getDescribe().fields.getMap().keySet().contains(
                ('sales_rep_shadow__c'))) s.put('sales_rep_shadow__c', null);
            
            if(s.getSobjectType().getDescribe().fields.getMap().keySet().contains(
                ('owner_custom__c'))) s.put('owner_custom__c', null);
            
        }
    }
}