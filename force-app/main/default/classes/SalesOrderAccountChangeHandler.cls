public class SalesOrderAccountChangeHandler {
    
    public static void ChangeAccountAddress(list<AcctSeedERP__Sales_Order__c> od, list<AcctSeedERP__Sales_Order__c> nd){
        
        // if account has changed
        // change the shipping address

        map<id, id> SOToAccountIdMap = new map<id,id>();
        map<id, id> SOToOpportunityIdMap = new map<id,id>();
		map<id, Account> SOToAccountMap = new map<id, Account>();
        map<id, Opportunity> SOToOpportunityMap = new map<id, Opportunity>();
        
        integer i = 0;
        for(AcctSeedERP__Sales_Order__c s : nd){
            if(s.AcctSeedERP__Customer__c != od[i].AcctSeedERP__Customer__c){
                if(s.AcctSeedERP__Customer__c != null){
                    SOToAccountIdMap.put(s.id, s.AcctSeedERP__Customer__c);
                }
                if(s.AcctSeedERP__Opportunity__c != null){
                    SOToOpportunityIdMap.put(s.id, s.AcctSeedERP__Opportunity__c);
                }
            }
            i++;
        }
        
        if(SOToAccountIdMap.size() > 0){
            
            // get the account billing address
            
            list<Account> accounts = [select id, AcctSeed__Billing_Contact__r.name, BillingStreet, BillingCity, BillingState,AcctSeed__Billing_Terms_Name__c,Deposit__c,AcctSeed__Billing_Days_Due__c,
                                     BillingCountry, BillingPostalCode, BillingLatitude, BillingLongitude,
                                      AcctSeed__GL_Account_Variable_1__c,price_level__c from Account
                                     where id in:SOToAccountIdMap.values()];
            
            list<Opportunity> opportunities = [Select id, accountId, contactperson__c from opportunity where accountId 
                                               in:SOToOpportunityIdMap.values()];
            
            map<id, Account> AccountsMap = new map<id, Account>(accounts);
            map<id, opportunity> OpportunityMap = new map<id, opportunity>(opportunities);
            
            if(!opportunities.isEmpty()){
                
                for(Id SoId : SOToAccountIdMap.keyset()){
                    
                    Id oppId = SOToOpportunityIdMap.get(SoId);
                    
                    Opportunity opp = OpportunityMap.get(oppId);
                    
                    SOToOpportunityMap.put(SoId, opp);
                    
                }
            }
            
            if(!accounts.IsEmpty()){
                
                for(Id SoId : SOToAccountIdMap.keyset()){
                    
                    Id acctId = SOToAccountIdMap.get(SoId);
                    
                    Account acct = AccountsMap.get(acctId);
                    
                    SOToAccountMap.put(SoId, acct);
                    
                }
            }
            
            if(SOToAccountMap.size() > 0){
                
                for(AcctSeedERP__Sales_Order__c so : nd){
                    
                    Account acct = SOToAccountMap.get(so.id);
                    
                    opportunity opp = null;
                    
                    if(SOToOpportunityMap.size() > 0){
                        
                        opp = SOToOpportunityMap.get(so.id);
                    }
                    // so.Price_Level__c = acct.Price_Level__c;
                    so.Billing_Terms_Name__c = acct.AcctSeed__Billing_Terms_Name__c;
                    so.Billing_Deposit__c = acct.Deposit__c;

                    so.GL_Account_Variable_1__c = acct.AcctSeed__GL_Account_Variable_1__c;
                    
                    so.Billing_Name__c = (acct.AcctSeed__Billing_Contact__c != null) ? acct.AcctSeed__Billing_Contact__c:
                    (opp != null) ? opp.ContactPerson__c:null;
                    so.Billing_Account__c = acct.id;
                    so.AcctSeedERP__Billing_street__c = acct.BillingStreet;
                    so.AcctSeedERP__billing_city__c = acct.BillingCity;
                    so.AcctSeedERP__billing_state__c = acct.BillingState;
                    so.AcctSeedERP__billing_country__c = acct.BillingCountry;
                    so.AcctSeedERP__billing_PostalCode__c = acct.BillingPostalCode;

                }
            }
        }
    }
}