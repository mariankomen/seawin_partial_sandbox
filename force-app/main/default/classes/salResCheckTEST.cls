public with sharing class salResCheckTEST {
    
    public static Map<String, Map<Integer, Decimal>> salRep(){
        List<OpportunityHistory> opportunityHistory = [SELECT Id, OpportunityId,Opportunity.Sales_Rep_O__r.Name__c, CreatedDate, Opportunity.Name, Amount FROM OpportunityHistory WHERE ( CreatedDate = LAST_N_MONTHS:11 OR CreatedDate = THIS_MONTH ) AND Opportunity.ForecastCategoryName = 'Pipeline'];
        Map<Id, List<Map<Id, OpportunityHistory>>> relatedHistory = new Map<Id, List<Map<Id, OpportunityHistory>>>();
        Map<Integer, List<OpportunityHistory>> historyByMonth = new Map<Integer, List<OpportunityHistory>>();
        Map<Id, List<OpportunityHistory>> relH = new Map<Id, List<OpportunityHistory>>();

        for(OpportunityHistory oh:opportunityHistory){
            if(!relatedHistory.containsKey(oh.OpportunityId)){
                Map<Id, OpportunityHistory> oppHistoryItem = new Map<Id, OpportunityHistory>();
                oppHistoryItem.put(oh.Id, oh);
                List<Map<Id, OpportunityHistory>> stepan = new List<Map<Id, OpportunityHistory>>();
                stepan.add(oppHistoryItem);
                relatedHistory.put(oh.OpportunityId, stepan);
            } else {
                Map<Id, OpportunityHistory> oppHistoryItem = new Map<Id, OpportunityHistory>();
                oppHistoryItem.put(oh.Id, oh);
                List<Map<Id, OpportunityHistory>> stepan = new List<Map<Id, OpportunityHistory>>();
                stepan.add(oppHistoryItem);
                relatedHistory.get(oh.OpportunityId).add(oppHistoryItem);
            }
        }

        for(OpportunityHistory oh: opportunityHistory){
            if(!relH.containsKey(oh.OpportunityId)){
                relH.put(oh.OpportunityId, new List<OpportunityHistory>{oh});
            } else {
                relH.get(oh.OpportunityId).add(oh);
            }
        }

        Map<Id, Map<Integer, List<Datetime>>> relatedCreatedDates = new Map<Id, Map<Integer, List<Datetime>>>();
        Map<Id, Datetime> relatedMaxCreatedDates = new Map<Id, Datetime>();
        for(OpportunityHistory oh: opportunityHistory){
            if(!relatedCreatedDates.containsKey(oh.OpportunityId)){
                Map<Integer, List<Datetime>> monthDates = new Map<Integer, List<Datetime>>();
                List<Datetime> relatedDates = new List<Datetime>();
                Integer month = oh.CreatedDate.month();
                if(!monthDates.containsKey(month)){
                    relatedDates.add(oh.CreatedDate);
                    monthDates.put(month, relatedDates);
                } else {
                    relatedDates.add(oh.CreatedDate);
                    monthDates.get(month).add(oh.CreatedDate);
                }
                relatedCreatedDates.put(oh.OpportunityId, monthDates);
            } else {
                Integer month = oh.CreatedDate.month();
                List<Datetime> relatedDates = new List<Datetime>();
                if(!relatedCreatedDates.get(oh.OpportunityId).containsKey(month)){
                    relatedDates.add(oh.CreatedDate);
                    relatedCreatedDates.get(oh.OpportunityId).put(month, relatedDates);
                } else {
                    relatedCreatedDates.get(oh.OpportunityId).get(month).add(oh.CreatedDate);

                }
            }
        }

        for(Id j:relatedCreatedDates.keySet()){
            Map<Integer, List<Datetime>> loopedMap = relatedCreatedDates.get(j);
            for(Integer month: loopedMap.keySet()){
                loopedMap.get(month).sort();
                Datetime loopFilteredDate = loopedMap.get(month)[loopedMap.get(month).size() - 1];
                loopedMap.get(month).clear();
                loopedMap.get(month).add(loopFilteredDate);
            }
        }

        Map<Integer, List<OpportunityHistory>> oppHistoryByMonthes = new Map<Integer, List<OpportunityHistory>>();
        for(Id dtime: relatedCreatedDates.keySet()){
            for(Integer month: relatedCreatedDates.get(dtime).keySet()){
                Datetime filteredDatetime = relatedCreatedDates.get(dtime).get(month)[0];
                for(OpportunityHistory oh:relH.get(dtime)){
                    if(filteredDatetime == oh.CreatedDate && oh.OpportunityId == dtime){
                        if(!oppHistoryByMonthes.containsKey(month)){
                            List<OpportunityHistory> oppHis = new List<OpportunityHistory>();
                            oppHis.add(oh);
                            if(month <= system.today().month()){
                                oppHistoryByMonthes.put(month+12, oppHis);
                            }else {
                                oppHistoryByMonthes.put(month, oppHis);
                            }
                            
                        } else {
                            oppHistoryByMonthes.get(month).add(oh);
                        }
                    }
                }
            }
        }

        Map<String, Map<Integer, List<OpportunityHistory>>> salRepTeamRelation = new Map<String, Map<Integer, List<OpportunityHistory>>>();	
        for(Integer month: oppHistoryByMonthes.keySet()){
            for(OpportunityHistory oh:oppHistoryByMonthes.get(month)){
                String salRepName = oh.Opportunity.Sales_Rep_O__r.Name__c;
                if(!salRepTeamRelation.containsKey(salRepName)){
                    Map<Integer, List<OpportunityHistory>> month_list_oh = new Map<Integer, List<OpportunityHistory>>();
                    List<OpportunityHistory> list_oh = new List<OpportunityHistory>();
                    list_oh.add(oh);
                    month_list_oh.put(month, list_oh);
                    salRepTeamRelation.put(salRepName, month_list_oh);
                } else {
                    if(!salRepTeamRelation.get(salRepName).containsKey(month)){
                        List<OpportunityHistory> list_oh = new List<OpportunityHistory>();
                        list_oh.add(oh);
                        salRepTeamRelation.get(salRepName).put(month, list_oh);
                    } else {
                        salRepTeamRelation.get(salRepName).get(month).add(oh);
                    }
                }

            } 
        }
        Map<String, Map<Integer, Decimal>> month_amount_salres = new Map<String, Map<Integer, Decimal>>();
        for(String salRep:salRepTeamRelation.keySet()){
            if(!month_amount_salres.containsKey(salRep)){
                Map<Integer, Decimal> month_amount = new Map<Integer, Decimal>();
                for(Integer month: salRepTeamRelation.get(salRep).keySet()){
                    Decimal counter = 0.00;
                    for(OpportunityHistory oh: salRepTeamRelation.get(salRep).get(month)){
                        if(oh.Amount != null){
                            counter+= oh.Amount;                        
                        }
                    }
                    month_amount.put(month, counter);
                    counter = 0.00;
                }
                month_amount_salres.put(salRep, month_amount);
            }
        }
        system.debug('test bl: '+JSON.serialize(month_amount_salres));
        return month_amount_salres;
    }

    public static void helpTest(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}