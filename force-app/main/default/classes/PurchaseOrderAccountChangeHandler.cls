public class PurchaseOrderAccountChangeHandler {
    
    public static void ChangeAccountAddress(list<AcctSeedERP__Purchase_Order__c> od, list<AcctSeedERP__Purchase_Order__c> nd){
        
        // if account has changed
        // change the shipping address
        
        map<id, id> POToAccountIdMap = new map<id,id>();
        map<id, Account> POToAccountMap = new map<id, Account>();
        
        integer i = 0;
        for(AcctSeedERP__Purchase_Order__c p : nd){
            if(p.AcctSeedERP__Vendor__c != od[i].AcctSeedERP__Vendor__c){
                if(p.AcctSeedERP__Vendor__c != null){
                    POToAccountIdMap.put(p.id, p.AcctSeedERP__Vendor__c);
                }
            }
            i++;
        }
        
        if(POToAccountIdMap.size() > 0){
            
            // get the account billing address
            
            list<Account> accounts = [select id, AcctSeed__Billing_Contact__r.name, BillingStreet, BillingCity, BillingState,
                                      BillingCountry, BillingPostalCode, BillingLatitude, BillingLongitude from Account
                                      where id in:POToAccountIdMap.values()];
            
            map<id, Account> AccountsMap = new map<id, Account>(accounts);
            
            if(!accounts.IsEmpty()){
                
                for(Id PoId : POToAccountIdMap.keyset()){
                    
                    Id acctId = POToAccountIdMap.get(PoId);
                    
                    Account acct = AccountsMap.get(acctId);
                    
                    POToAccountMap.put(PoId, acct);
                    
                }
            }
            
            if(POToAccountMap.size() > 0){
                /*
                for(AcctSeedERP__Purchase_Order__c po : nd){
                    
                    Account acct = POToAccountMap.get(po.id);
                    
                    po.AcctSeedERP__Vendor_street__c = acct.BillingStreet;
                    po.AcctSeedERP__Vendor_city__c = acct.BillingCity;
                    po.AcctSeedERP__Vendor_state__c = acct.BillingState;
                    po.AcctSeedERP__Vendor_country__c = acct.BillingCountry;
                    po.AcctSeedERP__Vendor_Postal_Code__c = acct.BillingPostalCode;
                }
                */
            }
        }
    }
}