public class OpportunityAccountChangeHandler {
    
    public static void ChangeAccountAddress(list<Opportunity> od, list<Opportunity> nd){
        
        // if account has changed
        // change the shipping address

        map<id, id> OppToAccountIdMap = new map<id,id>();
		map<id, Account> OppToAccountMap = new map<id, Account>();
        
        integer i = 0;
        for(opportunity o : nd){
            if(o.AccountId != od[i].AccountId){
                if(o.AccountId != null){
                    OppToAccountIdMap.put(o.id, o.AccountId);
                }
            }
            i++;
        }
        
        if(OppToAccountIdMap.size() > 0){
            
            // get the account billing address
            
            list<Account> accounts = [select id, AcctSeed__Shipping_Contact__c,AcctSeed__Billing_Terms_Name__c,Deposit__c,AcctSeed__Billing_Days_Due__c,
                                      ShippingStreet,Price_Level__c, AcctSeed__GL_Account_Variable_1__c, 
                                      ShippingCity, ShippingState, ShippingCountry, ShippingPostalCode, ShippingLatitude,
                                      ShippingLongitude from Account
                                     where id in:OppToAccountIdMap.values()];
            
            map<id, Account> AccountsMap = new map<id, Account>(accounts);
            
            if(!accounts.IsEmpty()){
                
                for(Id oppId : OppToAccountIdMap.keyset()){
                    
                    Id acctId = OppToAccountIdMap.get(oppId);
                    
                    Account acct = AccountsMap.get(acctId);
                    
                    OppToAccountMap.put(oppId, acct);
                    
                }
            }
            
            if(OppToAccountMap.size() > 0){
                for(Opportunity op : nd){
                    
                    Account acct = OppToAccountMap.get(op.id);

                    op.Shipping_Account__c = acct.id;
                    op.Shipping_Name__c = acct.AcctSeed__Shipping_Contact__c;
                    op.Price_Level__c = acct.Price_Level__c;
                    op.GL_Account_Variable_1__c = acct.AcctSeed__GL_Account_Variable_1__c;
                    
                    op.Billing_Terms_Name__c = acct.AcctSeed__Billing_Terms_Name__c;
                    op.Billing_Deposit__c = acct.Deposit__c;
                    op.Billing_Days_Due__c = acct.AcctSeed__Billing_Days_Due__c;
                    if(acct.ShippingStreet != null || acct.ShippingCity != null || 
                       acct.shippingstate != null || acct.shippingCountry != null || acct.shippingPostalCode != null){
                           
                        op.shipping_street__c = acct.ShippingStreet;
                    	op.shipping_city__c = acct.ShippingCity;
                    	op.shipping_state__c = acct.shippingstate;
                    	op.shipping_country__c = acct.shippingCountry;
                    	op.Shipping_PostalCode__c = acct.shippingPostalCode;
                           
                    }

                }
            }
        }
    }
}