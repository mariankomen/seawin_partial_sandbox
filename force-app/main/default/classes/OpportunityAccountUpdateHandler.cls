public class OpportunityAccountUpdateHandler {
    
    public static void UpdateQuoteAccount(List<Opportunity> TriggerOld, List<Opportunity> TriggerNew){ 
        
        Map<Id, account> acctNameMap = new Map<Id, account>();
        map<id, id> OppToAccountIdMap = new map<id, id>();
        
        integer i = 0;
        for(Opportunity o : TriggerNew){
            if(o.AccountId != TriggerOld[i].AccountId){
                if(o.AccountId != null){
                	OppToAccountIdMap.put(o.Id, o.AccountId);
                }
            }
            i++;
        }
        
        // get the quotes 
        if(OppToAccountIdMap.size() > 0){
            
            // get account names for account id
            for(Account acct : [select Id, Name, AcctSeed__Billing_Contact__r.name,
                                BillingStreet, BillingCity, BillingPostalCode, billingCountry,
                                         BillingState,BillingLatitude,BillingLongitude
                                from Account where Id in :OppToAccountIdMap.values()]){     
                acctNameMap.put(acct.Id, acct); 
            }
            
            if(acctNameMap.size() > 0){
                List<Quote> quoteList = [select id, AccountId, BillingName,
                                         BillingStreet, BillingCity, BillingPostalCode, billingCountry,
                                         BillingState
                                         from Quote where OpportunityId in :OppToAccountIdMap.keyset()];
                if(quoteList.Size() > 0){
                    for(Quote qt : quoteList){ 
                        account acct = acctNameMap.get(qt.AccountId);
                        qt.BillingName = (acct.AcctSeed__Billing_Contact__r.name != null)?
                            acct.AcctSeed__Billing_Contact__r.name:null;
                        qt.BillingStreet = acct.BillingStreet; 
                        qt.BillingCity = acct.BillingCity;
                        qt.BillingPostalCode = acct.BillingPostalCode;
                        qt.billingCountry = acct.BillingCountry;
                        qt.BillingState = acct.BillingState;
                        qt.BillingLatitude = acct.BillingLatitude;
                        qt.BillingLongitude = acct.BillingLongitude;
                    }
                    update quoteList;
                }
                
            }
        }
    }
}