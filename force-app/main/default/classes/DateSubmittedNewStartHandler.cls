public class DateSubmittedNewStartHandler {
    
    public static void Process(List<Quote> od, List<Quote> nd){

        set<id> OppIds = new set<id>();

        map<id, quote> quoteMap = new map<id, quote>(nd);

        // verify that the field on Opportunity is null and get additional fields
        List<Quote> NewList = [select id, createddate, opportunityId, 
        opportunity.Newly_Submitted_Quote_First_Date__c from Quote
        where opportunity.Newly_Submitted_Quote_First_Date__c = null 
        and Id in:quoteMap.keyset()];

        if(!NewList.isEmpty()){

            if(!od.IsEmpty()){ // its quote update case

                Integer i = 0;
                for(Quote q : nd){

                    if(q.status != od[i].status && q.status == 'Presented'){ // only if its status update to Presented
                        OppIds.add(q.OpportunityId);
                    }

                    i++;
                }
            }else{ // its new quote insert case

                for(Quote q : nd){

                    OppIds.add(q.OpportunityId);
                }
            }

            if(!OppIds.isEmpty() && OppIds.size() > 0) UpdateOpportunities(OppIds);
        }
    }

    public static void UpdateOpportunities(set<Id> OppIds){

        List<Opportunity> Opportunities = [select id, Newly_Submitted_Quote_First_Date__c, 
        (select id, createddate from quotes where Status = 'Presented' order by createddate asc Limit 1) 
        from Opportunity where Id in:OppIds];

        if(!Opportunities.isEmpty()){

            List<Opportunity> OpportunitiesUpdatable = new List<Opportunity>();

            for(Opportunity o : Opportunities){

                if(o.Quotes != null && !o.Quotes.isEmpty()){

                    DateTime dt = o.Quotes[0].CreatedDate;
                    Date d = Date.newInstance(dt.year(), dt.month(), dt.day());

                    o.Newly_Submitted_Quote_First_Date__c = d;
                    OpportunitiesUpdatable.add(o);
                }

            }

            if(!OpportunitiesUpdatable.isEmpty()){

                try{
                    update Opportunities;
                }catch(Exception ex){
                    system.debug(ex.getDmlMessage(0));
                }
            }
        }
    }
}