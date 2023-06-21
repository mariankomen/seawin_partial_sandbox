public class SyncOptionalProductsToQuoteHandler {
    
    public static void SyncToQuote(List<Opportunity> od, List<Opportunity> nd){
        
        Integer i = 0;
        map<id, opportunity> OppMap = new map<id, opportunity>();
        set<id> SyncedQuoteIds = new set<id>();
        
        for(Opportunity o : nd){
            if(o.SyncedQuoteId != null && o.SyncedQuoteId != od[i].SyncedQuoteId){ // only run if changes
                
                OppMap.put(o.Id, o);
                SyncedQuoteIds.add(o.SyncedQuoteId);
            }
            i++;
        }
        
        if(OppMap.size() > 0){
            
            // delete all optional products from quotes
            LIST<Optional_Products_Quote__c> opq = [select id from Optional_Products_Quote__c 
                                                    where Quote__c =:SyncedQuoteIds 
                                                    and IsDeleted = false];
            
            if(opq.size() > 0){
                OptionalProductQuoteHandler.executeVarQuote = false;
                try{
                    
                    delete opq;
                }catch(Exception ex){
                    
                    system.debug(ex.getMessage());
                }
            }
            
            // select all optional products from opportunity
            LIST<Optional_Products_Opportunity__c> opos = [SELECT Id, Name, Description__c, Discount__c, 
                                                           GL_Account_Variable_1__c, GL_Account_Variable_2__c, 
                                                           GL_Account_Variable_3__c, GL_Account_Variable_4__c, 
                                                           Item_Description__c, Opportunity__c,
                                                           Product__c, Project__c, Quantity__c, 
                                                           Size_Error__c, SortOrder__c, Size__c, 
                                                           UnitPrice__c, TotalPrice__c,
                                                           alternateimageurl__c,
                                                           SubTotal__c, PriceBookEntryId__c FROM 
                                                           Optional_Products_Opportunity__c where 
                                                           Opportunity__c=:OppMap.KeySet()
                                                           order by sortorder__c,name,createddate asc];
            
            LIST<Optional_Products_Quote__c> opqList = new LIST<Optional_Products_Quote__c>();
            
            for(Optional_Products_Opportunity__c opo : opos){
                Optional_Products_Quote__c temp = new Optional_Products_Quote__c();
                Opportunity opp = OppMap.get(opo.Opportunity__c);
                
                temp.Description__c = opo.Description__c;
                temp.Discount__c = opo.Discount__c;
                temp.GL_Account_Variable_1__c = opo.GL_Account_Variable_1__c;
                temp.GL_Account_Variable_2__c = opo.GL_Account_Variable_2__c;
                temp.GL_Account_Variable_3__c = opo.GL_Account_Variable_3__c;
                temp.GL_Account_Variable_4__c = opo.GL_Account_Variable_4__c;
                temp.Item_Description__c = opo.Item_Description__c;
                temp.Product__c = opo.Product__c;
                temp.Project__c = opo.Project__c;
                temp.Quantity__c = opo.Quantity__c;
                temp.Quote__c = opp.SyncedQuoteId;
                temp.Size_Error__c = opo.Size_Error__c;
                temp.SortOrder__c = opo.SortOrder__c;
                temp.Size__c = opo.Size__c;
                temp.UnitPrice__c = opo.UnitPrice__c;
                temp.PriceBookEntryId__c = opo.PriceBookEntryId__c;
                temp.alternateimageurl__c = opo.alternateimageurl__c;
                
                opqList.add(temp);
            }
            
            // insert Optional Products to Quotes
            if(opqList.size() > 0){
                OptionalProductQuoteHandler.executeVarQuote = false;
                insert opqList;
            }
        }
    }
}