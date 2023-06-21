public class BillingHandler {
    
    public static void Billing_Contact_Assignment(set<Id> IDs){

        map<id, AcctSeed__Billing__c> dataMap = new map<id, AcctSeed__Billing__c>([select id, AcctSeedERP__Sales_Order__c, AcctSeedERP__Sales_Order__r.Billing_Name__c,
        AcctSeedERP__Sales_Order__r.Contact__c, AcctSeed__Opportunity__c, AcctSeed__Opportunity__r.ContactPerson__c,
        AcctSeed__Opportunity__r.Shipping_Name__c, AcctSeed__Customer__c, AcctSeed__Customer__r.Contact_Person__c,
        AcctSeed__Billing_Contact__c,
        AcctSeed__Customer__r.AcctSeed__Billing_Contact__c from AcctSeed__Billing__c where Id in:IDs]);
        
        for(AcctSeed__Billing__c bill : dataMap.values()){
            
            if(bill.AcctSeed__Billing_Contact__c == null){
                
                // First look it on sales order
                Id contactId = bill.AcctSeedERP__Sales_Order__c != null && bill.AcctSeedERP__Sales_Order__r.Billing_Name__c != null ?
                    bill.AcctSeedERP__Sales_Order__r.Billing_Name__c : bill.AcctSeedERP__Sales_Order__c != null && 
                        bill.AcctSeedERP__Sales_Order__r.Contact__c != null ? bill.AcctSeedERP__Sales_Order__r.Contact__c : null;
                
                // If not found look it on opportunity
                contactId = contactId == null && bill.AcctSeed__Opportunity__c != null && bill.AcctSeed__Opportunity__r.ContactPerson__c != null ?
                       bill.AcctSeed__Opportunity__r.ContactPerson__c : contactId == null && bill.AcctSeed__Opportunity__c != null && 
                           bill.AcctSeed__Opportunity__r.Shipping_Name__c != null ? 
                           bill.AcctSeed__Opportunity__r.Shipping_Name__c : contactId;
                
                // If not look it on account
                contactId = contactId == null && bill.AcctSeed__Customer__c != null && 
                bill.AcctSeed__Customer__r.Contact_Person__c != null ?
                       bill.AcctSeed__Customer__r.Contact_Person__c : contactId == null && bill.AcctSeed__Customer__c != null && 
                           bill.AcctSeed__Customer__r.AcctSeed__Billing_Contact__c != null ? 
                           bill.AcctSeed__Customer__r.AcctSeed__Billing_Contact__c : contactId;
                
                bill.AcctSeed__Billing_Contact__c = contactId;

                dataMap.put(bill.id, bill);
            }else{
                dataMap.remove(bill.id);
            }
        }

        if(dataMap.size() > 0){

            try{

                update dataMap.values();
            }catch(Exception ex){

                system.debug('Exception has occurred.');
                system.debug(ex.getMessage());
            }
        }
    } 
}