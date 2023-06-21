public class AfterContentDocumentLinkTriggerHandler {
    
    public static void AfterInsert(List<ContentDocumentLink> data){
        
        set<id> QuoteIds = new set<id>();
        set<id> ContentDocumentLinkIds = new set<id>();
        
        for(ContentDocumentLink c : data){
            if(String.ValueOf(c.LinkedEntityId.getsobjecttype()) == 'Quote'){
                
                QuoteIds.add(c.LinkedEntityId);
                ContentDocumentLinkIds.add(c.id);
            }
        }
        
        if(QuoteIds.size() > 0 && ContentDocumentLinkIds.size() > 0){
            
            List<Quote> quotes = [select id, name from quote where id in:QuoteIds];
            
            if(!Quotes.isEmpty()){
                
                map<id, quote> QuoteMap = new map<id, quote>(quotes);
                
                List<ContentDocumentLink> DocumentLinks = [select LinkedEntityId, ContentDocument.Title from
                                                           ContentDocumentLink where id in:ContentDocumentLinkIds];
                
                if(!DocumentLinks.IsEmpty()){
                    
                    for(ContentDocumentLink cl : DocumentLinks){
                        Quote q = QuoteMap.get(cl.LinkedEntityId);
                        if(q != null){   
                            if(!cl.ContentDocument.Title.contains(q.name +'_V')){
                                
                                QuoteMap.remove(cl.LinkedEntityId);
                            }
                        }
                    }
                    
                    if(QuoteMap.size() > 0){
                        
                        List<Quote> UpdatableQuotes = new List<Quote>();
                        
                        for(quote q : QuoteMap.values()){
                            
                            q.Status = 'Presented';
                            
                            UpdatableQuotes.add(q);
                        }
                        
                        update UpdatableQuotes;
                        
                    }
                }
            }
        }
    }
}