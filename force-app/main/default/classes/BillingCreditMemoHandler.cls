public class BillingCreditMemoHandler {
    
    public static void UpdateOnSO(
        List<AcctSeed__Billing_Credit_Memo__c> data, Boolean isInsert){
            
            set<id> memoIds = new set<id>();
            
            if(!data.isEmpty()){
                for(Acctseed__Billing_Credit_Memo__c c : data){
                
                	memoIds.add(c.id);    
                
            	}
            }

            if(memoIds.size() > 0){
                
                List<AcctSeed__Billing_Credit_Memo__c> memos = [SELECT Id, 
                                                                AcctSeed__Amount__c,
                                                                AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__c 
                                                                FROM AcctSeed__Billing_Credit_Memo__c where id in:memoIds];
                
                map<id, decimal> soTotalCreditMemoMap = new map<id, decimal>();
                
                if(!memos.isEmpty()){
                    
                    for(AcctSeed__Billing_Credit_Memo__c c : memos){
                        if(soTotalCreditMemoMap.containsKey(c.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__c)){
                            
                            Decimal amt = soTotalCreditMemoMap.get(c.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__c);
                            amt = amt + c.AcctSeed__Amount__c; 
                            
                            soTotalCreditMemoMap.put(c.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__c, 
                                                     amt);
                            
                        }else{
                            soTotalCreditMemoMap.put(c.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__c, 
                                                     Math.abs(c.AcctSeed__Amount__c));
                        }
                    }
                }
                
                if(soTotalCreditMemoMap.size() > 0){
                    
                    // get the related sales orders and update the total credit amount on them
                    
                    List<AcctSeedERP__Sales_Order__c> orders = [select id, total_credit_memo__c from 
                                                               AcctSeedERP__Sales_Order__c 
                                                                where id in:soTotalCreditMemoMap.keyset()];
                    
                    if(!orders.isEmpty()){
                        
                        for(AcctSeedERP__Sales_Order__c o : orders){
                            
                            decimal amt = soTotalCreditMemoMap.get(o.id);
                            
                            if(o.total_credit_memo__c == null) o.total_credit_memo__c = 0;
                            
                            o.total_credit_memo__c = (isInsert) ? o.total_credit_memo__c + amt : o.total_credit_memo__c - amt;
                            
                        }
                        
                        update orders;
                    }
                }
            }
        }
}