public class OptionalProductOppHandler {
    
    public static Boolean executeVarOpp {
        get{
            if(executeVarOpp == null){
                executeVarOpp = true;
            } 
            return executeVarOpp;
        }      
        set;}
    
    public static void addProducts(LIST<Optional_Products_Opportunity__c> triggerData, TriggerOperation opType ){
        
        if(executeVarOpp){
            // get the syncedQuoteId
            list<Opportunity> opps = [select SyncedQuoteId from Opportunity where Id=:triggerData[0].Opportunity__c];
            if(!opps.isEmpty()){
                
                Opportunity opp = opps[0];
                
                if(opp.SyncedQuoteId != null){
                    
                    // delete all optional products from quotes
                    LIST<Optional_Products_Quote__c> opq = [select id from Optional_Products_Quote__c 
                                                            where quote__c =:opp.SyncedQuoteId and isdeleted = false];
                    
                    if(opq.size() > 0){
                        OptionalProductQuoteHandler.executeVarQuote = false;
                        try{
                            
                            delete opq;
                        }catch(Exception ex){
                            
                            system.debug(ex.getMessage());
                        }
                    }
                    
                    // select all optional products from opportunity
                    LIST<Optional_Products_Opportunity__c> opopp = [SELECT Id, Name, Description__c, Discount__c, 
                                                                    GL_Account_Variable_1__c, GL_Account_Variable_2__c, 
                                                                    GL_Account_Variable_3__c, GL_Account_Variable_4__c, 
                                                                    Item_Description__c, Opportunity__c,
                                                                    Product__c, Project__c, Quantity__c, 
                                                                    Size_Error__c, SortOrder__c, Size__c, 
                                                                    UnitPrice__c, TotalPrice__c, 
                                                                    SubTotal__c, PriceBookEntryId__c FROM 
                                                                    Optional_Products_Opportunity__c where 
                                                                    Opportunity__c=:triggerData[0].Opportunity__c
                                                                    order by sortorder__c,name,createddate asc];
                    
                    LIST<Optional_Products_Quote__c> opqMain = new LIST<Optional_Products_Quote__c>();
                    
                    for(Optional_Products_Opportunity__c oppLoop : opopp){
                        Optional_Products_Quote__c opqTemp = new Optional_Products_Quote__c();
                        opqTemp.Description__c = oppLoop.Description__c;
                        opqTemp.Discount__c = oppLoop.Discount__c;
                        opqTemp.GL_Account_Variable_1__c = oppLoop.GL_Account_Variable_1__c;
                        opqTemp.GL_Account_Variable_2__c = oppLoop.GL_Account_Variable_2__c;
                        opqTemp.GL_Account_Variable_3__c = oppLoop.GL_Account_Variable_3__c;
                        opqTemp.GL_Account_Variable_4__c = oppLoop.GL_Account_Variable_4__c;
                        opqTemp.Item_Description__c = oppLoop.Item_Description__c;
                        opqTemp.Product__c = oppLoop.Product__c;
                        opqTemp.Project__c = oppLoop.Project__c;
                        opqTemp.Quantity__c = oppLoop.Quantity__c;
                        opqTemp.Quote__c = opp.SyncedQuoteId;
                        opqTemp.Size_Error__c = oppLoop.Size_Error__c;
                        opqTemp.SortOrder__c = oppLoop.SortOrder__c;
                        opqTemp.Size__c = oppLoop.Size__c;
                        opqTemp.UnitPrice__c = oppLoop.UnitPrice__c;
                        opqTemp.PriceBookEntryId__c = oppLoop.PriceBookEntryId__c;
                        
                        opqMain.add(opqTemp);
                    }
                    
                    // insert Optional Products to Quotes
                    if(opqMain.size() > 0){
                        OptionalProductQuoteHandler.executeVarQuote = false;
                        insert opqMain;
                    }
                }
            }
            // if the optional product has been deleted, resort the optional products, check opType
            if(opType == TriggerOperation.AFTER_DELETE){
                
                list<Optional_Products_Opportunity__c> oplines = [SELECT Id, Name, Item_Description__c, 
                                                                  Product__r.name, Quantity__c, 
                                                                  Opportunity__c, UnitPrice__c, Size__c, 
                                                                  SortOrder__c, TotalPrice__c 
                                                                  FROM Optional_Products_Opportunity__c 
                                                                  where Opportunity__c =:triggerData[0].Opportunity__c 
                                                                  order by sortorder__c,name,createddate asc];
                
                // iterate over each and set the sorting number starting from one
                if(!oplines.IsEmpty()){
                    Integer sortnumber = 1;
                    for(Optional_Products_Opportunity__c optional : opLines){
                        optional.sortorder__c = sortnumber;
                        sortnumber++;
                    }
                    update opLines;
                }
            }
        }
    } 
}