public class SalesOrderContactChangeHandler {
    
    public static void runHandler(List<AcctSeedERP__Sales_Order__c> od, LIst<AcctSeedERP__Sales_Order__c> nd){
        
        set<id> contactIds = new set<id>();
        
        Integer i = 0;
        for(AcctSeedERP__Sales_Order__c s : nd){
            if(s.contact__c != od[i].contact__c){
                if(s.contact__c != null){
                    
                    contactIds.add(S.contact__c);
                }
            }
            i++;
        }
        
        if(contactIds.size() > 0){
            
            // get the contacts with lead source
            List<contact> contacts = [select id, leadsource from contact where id IN:contactIds];
            
            if(!contacts.isEmpty()){
                
                map<id, string> ContactToLeadMap = new map<id, string>();
                
                for(contact c : contacts){
                    if(c.LeadSource != null){
                        
                        ContactToLeadMap.put(c.id, c.LeadSource);
                        
                    }
                }
                
                if(ContactToLeadMap.size() > 0){
                    Integer j = 0;
                    for(AcctSeedERP__Sales_Order__c s : nd){
                        if(s.contact__c != od[j].contact__c){
                            if(s.contact__c != null){
                                String LeadSrce = ContactToLeadMap.get(s.contact__c);
                                
                                if(LeadSrce == null) continue;
                                
                                s.LeadSource__c = LeadSrce;
                            }
                        }
                        j++;
                    }
                }
            }
        }
    }
}