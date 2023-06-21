public class BillingLineResortHandler {
    
    public static void reSort(list<AcctSeed__Billing_Line__c> data){
        
        map<id, id> BillingMap = new map<id, id>();

        for(AcctSeed__Billing_Line__c d : data){
            
            BillingMap.put(d.AcctSeed__Billing__c, d.AcctSeed__Billing__c);
            
        }
        
        if(BillingMap.size() > 0){
            
            // query for lines except credit card fee and tax
            list<AcctSeed__Billing_Line__c> lines = [SELECT Id, Sort_Order__c, AcctSeed__Billing__c 
                                                     FROM AcctSeed__Billing_Line__c 
                                                     where AcctSeed__Billing__c in:BillingMap.KeySet()
                                                     and AcctSeed__Product__r.Credit_Card_Fee__c = false
                                                     and AcctSeed__Tax_Line__c = false
                                                     order by sort_order__c, name, createddate asc];
            
            // A separate query for credit card fee and tax, in order to add them to the end of the lines list
            List<Acctseed__Billing_Line__c> serviceLines = [SELECT Id, Sort_Order__c, AcctSeed__Billing__c 
                                                     FROM AcctSeed__Billing_Line__c 
                                                     where AcctSeed__Billing__c in:BillingMap.KeySet()
                                                     and (AcctSeed__Product__r.Credit_Card_Fee__c = true or
                                                          AcctSeed__Tax_Line__c = true)
                                                     order by sort_order__c, name, createddate asc];
            if(!serviceLines.isEmpty()) lines.addAll(serviceLines);
            
            if(!lines.isEmpty()){
                integer i = 1;
                for(AcctSeed__Billing_Line__c bil : lines){
                    
                    bil.sort_order__c = i;
                    
                    i++;
                    
                }
                
                update lines; 
            }
        }
    }
}