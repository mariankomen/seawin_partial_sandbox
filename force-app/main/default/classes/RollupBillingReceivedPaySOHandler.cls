public class RollupBillingReceivedPaySOHandler {
     // This handler was discontinued on 9 April 2021, because now the rollup is done through declarative rollup summary tool
    public static void rollup(List<AcctSeed__Billing__c> data){
        
        /*

        set<id> soIds = new set<id>();
        for(AcctSeed__Billing__c bill : data){
                soIds.add(bill.AcctSeedERP__Sales_Order__c);
        }
        
        if(!soIds.IsEmpty()){
            
            // get the aggregate SUM of the received payment on all bills if any
            
            List<AcctSeed__Billing__c> AllBills = [select id, AcctSeed__Received_Amount__c, 
                                                   AcctSeed__Total__c,
                                                   AcctSeed__Credit_Memo_Applied_Amount__c,
                                                   AcctSeed__Balance__c,
                                                   AcctseedERP__Sales_Order__c
                                                   from AcctSeed__Billing__c
                                                   where AcctseedERP__Sales_Order__c in:soIds
                                                   and AcctSeed__Type__c = 'Invoice'];
            
            if(!AllBills.IsEmpty()){
                
                
                map<id, decimal> SO_Received_Amount_Map = new map<id, decimal>();
                map<id, decimal> SO_Applied_Amount_Map = new map<id, decimal>();
                
                for(AcctSeed__Billing__c b : AllBills){
                    
                    Id key = b.AcctseedERP__Sales_Order__c;
                    
                    Decimal ReceivedAmountTotal = b.AcctSeed__Balance__c == 0 && b.AcctSeed__Received_Amount__c == 0 ?
                            0:b.AcctSeed__Balance__c == 0 && b.AcctSeed__Received_Amount__c > b.AcctSeed__Total__c 
                                ? b.AcctSeed__Total__c : b.AcctSeed__Received_Amount__c;
                    
                    if(SO_Received_Amount_Map.containsKey(key) || SO_Applied_Amount_Map.containsKey(key)){
                        // add paid amount to map
                        decimal existingAmount = SO_Received_Amount_Map.get(key); 
                        Decimal NewAmount = existingAmount + ReceivedAmountTotal;
                        SO_Received_Amount_Map.put(key, NewAmount);
                        
                        // add credit amount to map
                        Decimal existingAAmount = SO_Applied_Amount_Map.get(key);
                        Decimal NewAAmount = existingAAmount + b.AcctSeed__Credit_Memo_Applied_Amount__c;    
                        SO_Applied_Amount_Map.put(key, NewAAmount);
                    }else{
                        SO_Received_Amount_Map.put(key, ReceivedAmountTotal);
                        SO_Applied_Amount_Map.put(key, b.AcctSeed__Credit_Memo_Applied_Amount__c);
                    }
                }
                
                if(SO_Received_Amount_Map.size() > 0){
                    
                    // get the sales orders to update
                    list<AcctSeedERP__Sales_Order__c> ss = new list<AcctSeedERP__Sales_Order__c>([select id, 
                    paid_amount__c,Applied_Amount__c
                    from AcctSeedERP__Sales_Order__c
                   where id in:SO_Received_Amount_Map.keyset()]);
                    
                    for(AcctSeedERP__Sales_Order__c so : ss){
                        
                        so.paid_amount__c = SO_Received_Amount_Map.get(so.id); 
                        so.Applied_Amount__c = SO_Applied_Amount_Map.get(so.id);      
                        
                    }
                    
                    if(!ss.isEmpty()) update ss;
                    
                }
            }
        }
        */
    }
}