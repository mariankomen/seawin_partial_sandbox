public class RecordTypeSyncHandler {
    
    public static void AfterUpdateQuote(List<Quote> od, list<quote> nd){
        
        
        map<id, string> quoteMap = new map<id, string>();
        Integer i = 0;
        for(Quote q : nd){
            
            if(q.RecordTypeId != od[i].RecordTypeId){
                if(q.Recordtypeid != null){
                    
                    string recName = 
                        Schema.getGlobalDescribe().get('Quote').getDescribe().getRecordTypeInfosById().get(q.Recordtypeid).getName();
                    
                    quoteMap.put(q.id, recName);
                }
            }
            i++;
        }
        
        if(QuoteMap.size() > 0){
            
            // checkout for synced opportunities
            List<Opportunity> SyncedOpportunities = [select id, recordtype.name, SyncedQuoteId from
                                                     Opportunity where SyncedQuoteId in: quoteMap.keyset()];
            
            if(!SyncedOpportunities.isEmpty()){
                
                // get the record type id for opportunity
                map<string, id> RecordTypeMap = new map<string, id>();
                
                for(recordtype rt : [select id,name from recordtype where name in:QuoteMap.values()
                                     and sobjecttype = 'Opportunity']){
                                         
                                         RecordTypeMap.put(rt.name, rt.id);
                                     }
                
                if(RecordTypeMap.size() > 0){
                    
                    List<Opportunity> UpdatableOpptys = new List<Opportunity>();
                    
                    for(Opportunity o :SyncedOpportunities){
                        
                        Opportunity oppty = new Opportunity();
                        String RecordTypeName = QuoteMap.get(o.syncedQuoteid);
                        Id RecordTypeId = RecordTypeMap.get(RecordTypeName);
                        
                        
                        
                        if(RecordTypeId == null) continue;
                        oppty.id = o.id;
                        oppty.recordtypeid = RecordTypeId;
                        
                        UpdatableOpptys.add(oppty);
                    }
                    
                    if(!UpdatableOpptys.IsEmpty()){
                        
                        try{
                            
                         update UpdatableOpptys;   
                        }catch(Exception ex){
                            
                            system.debug(ex.getMessage());
                        }
                    }
                }                
            }
        }
    }
    
    public static void AfterUpdateOpportunity(List<Opportunity> od, list<Opportunity> nd){
        
        Integer i = 0;
        
        map<id, string> OpportunityMap = new map<id, string>();
        
        for(Opportunity o : nd){
            if(o.RecordTypeId != od[i].RecordTypeId){
                if(o.RecordTypeId != null && o.SyncedQuoteId != null){
                    
                    string recName = 
                        Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosById().get(o.Recordtypeid).getName();
                    
                    OpportunityMap.put(o.SyncedQuoteId,recName);
                }
            }
            i++;
        }
        
        if(OpportunityMap.size() > 0){
            
            // get the synced Quotes
            
            List<Quote> SyncedQuotes = [select id, recordtype.name from quote 
                                        where id in:OpportunityMap.keyset()];
            
            if(!SyncedQuotes.isEmpty()){
                
                // get the record type id for quote
                map<string, id> RecordTypeMap = new map<string, id>();
                for(recordtype rt : [select id,name from recordtype where name in:OpportunityMap.values() and 
                                    sobjecttype = 'Quote']){
                    
                    RecordTypeMap.put(rt.name, rt.id);
                }
                
                if(RecordTypeMap.size() > 0){
                    
                    for(Quote q : SyncedQuotes){                        
                        string RecordTypeName = OpportunityMap.get(q.id);
                        id RecordTypeId = RecordTypeMap.get(RecordTypeName);
                        
                        if(RecordTypeId == null) continue;
                        q.recordtypeid = RecordTypeId; 
                    }
                    try{
                        Update SyncedQuotes;
                    }catch(Exception ex){
                        system.debug(ex.getMessage());
                    }
                }
            }
        }
    }
}