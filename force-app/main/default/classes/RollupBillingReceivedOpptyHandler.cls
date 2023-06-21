public class RollupBillingReceivedOpptyHandler {
    // This handler was discontinued on 9 April 2021, because now the rollup is done through declarative rollup summary tool
    public static void rollup(List<AcctSeed__Billing__c> data){
        /*
        
        set<id> opIds = new set<id>();
        for(AcctSeed__Billing__c bill : data){
            
            if(bill.AcctSeed__Opportunity__c != null){
                opIds.add(bill.AcctSeed__Opportunity__c);
            }
            
        }
        
        if(!opIds.IsEmpty()){
            
            // get the aggregate SUM of the received payment on all bills if any
            
            List<AcctSeed__Billing__c> AllBills = [select id, AcctSeed__Received_Amount__c, AcctSeed__Total__c,
                                                   AcctSeed__Balance__c,Acctseed__Opportunity__c
                                                   from AcctSeed__Billing__c
                                                   where Acctseed__Opportunity__c in:opIds];
            
            if(!AllBills.IsEmpty()){
                
                
                map<id, decimal> OpptytoAmountMap = new map<id, decimal>();
                
                for(AcctSeed__Billing__c b : AllBills){
                    
                    Id key = b.Acctseed__Opportunity__c;
                    
                    Decimal ReceivedAmountTotal = (b.AcctSeed__Balance__c == 0)?
                        b.AcctSeed__Total__c:b.AcctSeed__Received_Amount__c;
                    
                    if(OpptytoAmountMap.containsKey(key)){
                        Decimal existsAmount = OpptytoAmountMap.get(key);
                        Decimal NewTotal = existsAmount + ReceivedAmountTotal;
                        
                        OpptytoAmountMap.put(key, NewTotal);
                    }else{
                        OpptytoAmountMap.put(key, ReceivedAmountTotal);
                    }
                }
                
                if(OpptytoAmountMap.size() > 0){
                    
                    UpdateOpportunities(JSON.serialize(OpptytoAmountMap));
                }
            }
        }
        */
    }
    /*
    @future
    public static void UpdateOpportunities(string AmountMap){
        
        map<id, decimal> OpptytoAmountMap = (map<id, decimal>)JSON.deserialize(AmountMap, map<id, decimal>.class);
        
        // get the sales orders to update
        list<Opportunity> ops = [select id, bill_paid_amount__c from Opportunity
                                 where id in:OpptytoAmountMap.keyset()];
        if(!ops.isEmpty()){
            for(Opportunity o : ops){
                
                decimal receivedAmount = OpptytoAmountMap.get(o.id);
                
                if(receivedAmount == null) {
                    receivedAmount = 0.00; }
                o.Run_Validation_Rule__c = true;
                o.bill_paid_amount__c = receivedAmount;      
                
            }
            
            update ops;
        }
    }*/
}