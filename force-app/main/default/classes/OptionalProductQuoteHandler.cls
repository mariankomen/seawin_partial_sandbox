public class OptionalProductQuoteHandler {
    
    public static Boolean executeVarQuote {
        get{
            if(executeVarQuote == null){
                executeVarQuote = true;
            } 
            return executeVarQuote;
        }      
        set;}
    
    public static void addProducts(LIST<Optional_Products_Quote__c> triggerData, TriggerOperation opType){
        
        if(executeVarQuote){
            // get the syncedQuoteId
            LIST<Opportunity> opp = [select Id from Opportunity where SyncedQuoteId=:triggerData[0].Quote__c LIMIT 1];
            
            if(opp.size() > 0){
                
                // delete all optional products from opportunity
                LIST<Optional_Products_Opportunity__c> optionalopp = [select id from Optional_Products_Opportunity__c 
                                                                      where opportunity__c =:opp[0].id and isdeleted=false];
                
                if(optionalopp.size() > 0){
                    OptionalProductOppHandler.executeVarOpp = false;
                    try{
                        
                       delete optionalopp; 
                    }catch(Exception ex){
                        
                        system.debug(ex.getMessage());
                    }
                }
                
                // select all optional products from quotes
                LIST<Optional_Products_Quote__c> opq = [SELECT Id, Name, Description__c, Discount__c, 
                                                        GL_Account_Variable_1__c, GL_Account_Variable_2__c, 
                                                        GL_Account_Variable_3__c, GL_Account_Variable_4__c, 
                                                        Item_Description__c, Quote__c, 
                                                        Product__c, Project__c, 
                                                        Quantity__c, Size_Error__c, Size__c, 
                                                        UnitPrice__c, TotalPrice__c, SubTotal__c,sortorder__c, 
                                                        PriceBookEntryId__c FROM 
                                                        Optional_Products_Quote__c where 
                                                        Quote__c=:triggerData[0].Quote__c
                                                       order by sortorder__c,name,createddate asc];
                
                LIST<Optional_Products_Opportunity__c> opoppMain = new LIST<Optional_Products_Opportunity__c>();
                
                for(Optional_Products_Quote__c qLoop : opq){
                    
                    Optional_Products_Opportunity__c opoppTemp = new Optional_Products_Opportunity__c();
                    
                    opoppTemp.Description__c = qLoop.Description__c;
                    opoppTemp.Discount__c = qLoop.Discount__c;
                    opoppTemp.GL_Account_Variable_1__c = qLoop.GL_Account_Variable_1__c;
                    opoppTemp.GL_Account_Variable_2__c = qLoop.GL_Account_Variable_2__c;
                    opoppTemp.GL_Account_Variable_3__c = qLoop.GL_Account_Variable_3__c;
                    opoppTemp.GL_Account_Variable_4__c = qLoop.GL_Account_Variable_4__c;
                    opoppTemp.Item_Description__c = qLoop.Item_Description__c;
                    opoppTemp.Product__c = qLoop.Product__c;
                    opoppTemp.Project__c = qLoop.Project__c;
                    opoppTemp.Quantity__c = qLoop.Quantity__c;
                    opoppTemp.Opportunity__c = opp[0].Id;
                    opoppTemp.Size_Error__c = qLoop.Size_Error__c;
                    opoppTemp.SortOrder__c = qLoop.SortOrder__c;
                    opoppTemp.Size__c = qLoop.Size__c;
                    opoppTemp.UnitPrice__c = qLoop.UnitPrice__c;
                    opoppTemp.PriceBookEntryId__c = qLoop.PriceBookEntryId__c;
                    
                    opoppMain.add(opoppTemp);
                }
                
                // insert Optional Products to Quotes
                if(opoppMain.size() > 0){
                    OptionalProductOppHandler.executeVarOpp = false;
                    insert opoppMain;
                }
            }
            // if the optional product has been deleted, resort the optional products, check opType
            if(opType == TriggerOperation.AFTER_DELETE){
                
                list<Optional_Products_Quote__c> oplines = [SELECT 
                                                            SortOrder__c 
                                                            FROM Optional_Products_Quote__c 
                                                            where Quote__c =:triggerData[0].Quote__c 
                                                            order by sortorder__c,name,createddate asc];
                
                // iterate over each and set the sorting number starting from one
                if(!oplines.IsEmpty()){
                    Integer sortnumber = 1;
                    for(Optional_Products_Quote__c optional : opLines){
                        optional.sortorder__c = sortnumber;
                        sortnumber++;
                    }
                    update opLines;
                }
            }
        }
    } 
}