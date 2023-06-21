public class OLICustomFieldCopyToQLIHandler {
    
    public static void PopulateQLICustomFeilds(list<QuoteLineItem> data){
        
        try{

            set<Id> oliIds = new set<Id>();

            for(QuoteLineItem q : data){

                oliIds.add(q.OpportunityLineItemId);

            }

            if(oliIds.size() > 0){

                List<OpportunityLineItem> olis = [select id, Item_Description__c, size__c,AlternateImageURL__c
                                           from OpportunityLineItem
                                           where id =: oliIds];

                map<id, opportunitylineitem> oliMap = new map<id, opportunitylineitem>(olis);

                if(oliMap.size() > 0){

                    for(QuoteLineItem q : data){

                        q.item_description__c = oliMap.get(q.opportunitylineitemId).item_description__c;
                        q.size__c = oliMap.get(q.opportunitylineitemId).size__c;
                        q.AlternateImageURL__c = oliMap.get(q.opportunitylineitemId).AlternateImageURL__c;
        
                    }

                }
            }
            
        }catch (Exception e){
            System.debug('ex is: ' + e.getMessage());
        }
    }
}