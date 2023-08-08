public class AccountBillingChangeHandler {
    
    public static void AccountBillingChangeHandler(list<Account> oldValues, list<Account> newValues){
        
        // only run the process if the account's billing has changed by comparing old and new values
        
        Integer i = 0;
        
        map<id, Account> ChangedMap = new map<id, Account>();
        set<id> AcctIds = new set<Id>();
        
        // updatables
        list<Quote> UpdateQuotes = new list<Quote>();
        list<AcctSeedERP__Sales_Order__c> UpdateSO = new list<AcctSeedERP__Sales_Order__c>();
        list<AcctSeed__Billing__c> UpdateBilling = new list<AcctSeed__Billing__c>();
        list<AcctSeedERP__Purchase_Order__c> UpdatePO = new list<AcctSeedERP__Purchase_Order__c>();
        
        for(Account acct : newValues){
            
            if(acct.BillingStreet != oldValues[i].BillingStreet ||
               acct.BillingCity != oldValues[i].BillingCity
               || acct.BillingState != oldValues[i].BillingState
               || acct.BillingPostalCode != oldValues[i].BillingPostalCode
               || acct.BillingCountry != oldValues[i].BillingCountry){
                   
                   // add the Account to ChangedMap
                   ChangedMap.put(acct.id, acct);
                   AcctIds.add(acct.id);
               }
            i++;
        } 
        
        if(!ChangedMap.IsEmpty()){
            // start the process
            // update the billing address on associated Quote, Sales Order, Billing and Purchase Order
            
            // get all the associated quotes for the account id
            list<Quote> quotes = [select AccountId, BillingStreet, BillingCity, 
                                  BillingState, BillingPostalCode, BillingCountry from Quote where AccountId in:AcctIds];
            
            if(!quotes.IsEmpty()){
                
                // iterate on every quote and create a list of named UpdateQuotes
                for(Quote qt : quotes){
                    
                    Account acctt = ChangedMap.get(qt.AccountId);
                    
                    if(acctt == null) continue;
                    
                    qt.BillingStreet = acctt.BillingStreet;
                    qt.BillingCity = acctt.BillingCity;
                    qt.BillingState = acctt.BillingState;
                    qt.BillingPostalCode = acctt.BillingPostalCode;
                    qt.BillingCountry = acctt.BillingCountry;
                    
                    UpdateQuotes.add(qt);
                }
            }
            
            // get all the associated Sales Order for the account by the account id
            list<AcctSeedERP__Sales_Order__c> salesorders = [select AcctSeedERP__Customer__c,
                                                             AcctSeedERP__Billing_Street__c,
                                                             AcctSeedERP__Billing_City__c,
                                                             AcctSeedERP__Billing_State__c,
                                                             AcctSeedERP__Billing_PostalCode__c,
                                                             AcctSeedERP__Billing_Country__c from AcctSeedERP__Sales_Order__c
                                                             where AcctSeedERP__Customer__c in: AcctIds];
            
            if(!salesorders.IsEmpty()){
                
                // iterate over the so and assign the new billign addresses
                for(AcctSeedERP__Sales_Order__c so : salesorders){
                    
                    Account acccttt = ChangedMap.get(so.AcctSeedERP__Customer__c);
                    
                    if(acccttt == null) continue;
                    
                    so.AcctSeedERP__Billing_Street__c = acccttt.BillingStreet;
                    so.AcctSeedERP__Billing_City__c = acccttt.BillingCity;
                    so.AcctSeedERP__Billing_State__c = acccttt.BillingState;
                    so.AcctSeedERP__Billing_PostalCode__c = acccttt.BillingPostalCode;
                    so.AcctSeedERP__Billing_Country__c = acccttt.BillingCountry;
                    
                    UpdateSO.add(so);
                    
                }
                
            }
            
            // get all the associated Billings for the account by the account id
            list<AcctSeed__Billing__c> billings = [select AcctSeed__Customer__c,
                                                   AcctSeed__Billing_Street__c,
                                                   AcctSeed__Billing_City__c,
                                                   AcctSeed__Billing_State__c,
                                                   AcctSeed__Billing_PostalCode__c,
                                                   AcctSeed__Billing_Country__c from AcctSeed__Billing__c
                                                   where AcctSeed__Customer__c in: AcctIds];
            
            if(!billings.IsEmpty()){
                
                // iterate over the so and assign the new billign addresses
                for(AcctSeed__Billing__c bill : billings){
                    
                    Account acccctttt = ChangedMap.get(bill.AcctSeed__Customer__c);
                    
                    if(acccctttt == null) continue;
                    
                    bill.AcctSeed__Billing_Street__c = acccctttt.BillingStreet;
                    bill.AcctSeed__Billing_City__c = acccctttt.BillingCity;
                    bill.AcctSeed__Billing_State__c = acccctttt.BillingState;
                    bill.AcctSeed__Billing_PostalCode__c = acccctttt.BillingPostalCode;
                    bill.AcctSeed__Billing_Country__c = acccctttt.BillingCountry;
                    
                    UpdateBilling.add(bill);
                    
                }
                
            }
            
            // get all the associated Billings for the account by the account id
            list<AcctSeedERP__Purchase_Order__c> purchases = [select AcctSeedERP__Vendor__c,
                                                   AcctSeedERP__Vendor_Street__c,
                                                   AcctSeedERP__Vendor_City__c,
                                                   AcctSeedERP__Vendor_State__c,
                                                   AcctSeedERP__Vendor_Postal_Code__c,
                                                   AcctSeedERP__Vendor_Country__c from AcctSeedERP__Purchase_Order__c
                                                   where AcctSeedERP__Vendor__c in: AcctIds];
            
            if(!purchases.IsEmpty()){
                
                // iterate over the so and assign the new billign addresses
                for(AcctSeedERP__Purchase_Order__c po : purchases){
                    
                    Account acccccttttt = ChangedMap.get(po.AcctSeedERP__Vendor__c);
                    
                    if(acccccttttt == null) continue;
                    
                    po.AcctSeedERP__Vendor_Street__c = acccccttttt.BillingStreet;
                    po.AcctSeedERP__Vendor_City__c = acccccttttt.BillingCity;
                    po.AcctSeedERP__Vendor_State__c = acccccttttt.BillingState;
                    po.AcctSeedERP__Vendor_Postal_Code__c = acccccttttt.BillingPostalCode;
                    po.AcctSeedERP__Vendor_Country__c = acccccttttt.BillingCountry;
                    
                    UpdatePO.add(po);
                    
                }
                
            }
            SavePoint sp = Database.setSavepoint();
            try{
                
                
                
                if(!UpdateQuotes.IsEmpty()){
                    
                    update UpdateQuotes;
                }
                
                if(!UpdateSO.IsEmpty()){
                    
                    update UpdateSO;
                }
                
                if(!UpdateBilling.IsEmpty()){
                    
                    update UpdateBilling;
                }
                if(!UpdatePO.IsEmpty()){
                    
                    update UpdatePO;
                }
            }catch(Exception ex){
                
                Database.rollback(sp);
                
                system.debug(ex.getMessage());
                
            }
        }
    }
}