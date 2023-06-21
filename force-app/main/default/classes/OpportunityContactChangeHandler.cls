public class OpportunityContactChangeHandler {
    
    public static void runHandler(List<Opportunity> od, LIst<Opportunity> nd){
        
        set<id> contactIds = new set<id>();
        
        Integer i = 0;
        for(Opportunity o : nd){
            if(o.contactperson__c != od[i].contactperson__c){
                if(o.contactperson__c != null){
                    
                    contactIds.add(o.contactperson__c);
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
                    for(Opportunity o : nd){
                        
                        if(o.contactperson__c != od[j].contactperson__c){
                            if(o.contactperson__c != null){
                                String LeadSrce = ContactToLeadMap.get(o.ContactPerson__c);
                                
                                if(LeadSrce == null) continue;
                                
                                o.LeadSource = LeadSrce;
                            }
                        }
                        j++;
                    }
                }
            }
        }
    }


    public static void handleChangeSpecified(Map<Id, Opportunity> opportunities_new, Map<Id, Opportunity> opportunities_old){

        // for(Opportunity opp: opportunities){
        //     if(opp.Specified_Rep__c == null && opp.Referral_Sales_Rep__c == null) opp.Specified_del__c = false;
        // }

        for(Id opp: opportunities_new.keySet()){
            if(opportunities_new.get(opp).Specified_Rep__c == null 
            && opportunities_old.get(opp).Specified_Rep__c != null 
            && opportunities_new.get(opp).Referral_Sales_Rep__c == null){

                opportunities_new.get(opp).Specified_del__c = false;
            }
        }
    }
}