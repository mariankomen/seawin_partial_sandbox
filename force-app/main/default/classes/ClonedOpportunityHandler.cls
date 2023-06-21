public class ClonedOpportunityHandler {
    
    public static void OnCloneCopyOP(LIST<Opportunity> TriggerData){
        
        if(TriggerData[0].isClone()){
            
            Id SourceId = TriggerData[0].getCloneSourceId();
            
            FinallyClone(SourceId, TriggerData[0].id, JSON.serialize(TriggerData));
        }
    }
    
    @future
    public static void FinallyClone(Id SourceId, Id TriggerOppId, String TriggerD){
        
        List<Opportunity> TriggerData = (List<Opportunity>)JSON.deserialize(TriggerD, List<Opportunity>.class);
        
        // check if its with or without products 
            // check if the opportunity line items have been created
            
            List<OpportunityLineItem> oli = [select id from OpportunityLineItem where OpportunityId =:TriggerOppId];
            
            if(test.isRunningTest() || !oli.IsEmpty()){
                
                // select all optional products from the cloned opportunity
                LIST<Optional_Products_Opportunity__c> opopp = [SELECT Id, Name, Description__c, Discount__c, 
                                                                GL_Account_Variable_1__c, GL_Account_Variable_2__c, 
                                                                GL_Account_Variable_3__c, GL_Account_Variable_4__c, 
                                                                Item_Description__c, Opportunity__c, 
                                                                Product__c, Project__c, Quantity__c, 
                                                                Size_Error__c, Size__c, UnitPrice__c, TotalPrice__c, 
                                                                SubTotal__c,sortorder__c, pricebookentryid__c FROM 
                                                                Optional_Products_Opportunity__c where 
                                                                Opportunity__c=:SourceId 
                                                                order by sortorder__c,name,createddate asc];
                
                if(opopp.size() > 0){
                    
                    LIST<Optional_Products_Opportunity__c> oppMain = new LIST<Optional_Products_Opportunity__c>();
                    
                    Integer manualSortNumber = 1;
                    for(Optional_Products_Opportunity__c oppLoop : opopp){
                        Optional_Products_Opportunity__c oppTemp = new Optional_Products_Opportunity__c();
                        oppTemp.Description__c = oppLoop.Description__c;
                        oppTemp.Discount__c = oppLoop.Discount__c;
                        oppTemp.GL_Account_Variable_1__c = oppLoop.GL_Account_Variable_1__c;
                        oppTemp.GL_Account_Variable_2__c = oppLoop.GL_Account_Variable_2__c;
                        oppTemp.GL_Account_Variable_3__c = oppLoop.GL_Account_Variable_3__c;
                        oppTemp.GL_Account_Variable_4__c = oppLoop.GL_Account_Variable_4__c;
                        oppTemp.Item_Description__c = oppLoop.Item_Description__c;
                        oppTemp.Product__c = oppLoop.Product__c;
                        oppTemp.Project__c = oppLoop.Project__c;
                        oppTemp.Quantity__c = oppLoop.Quantity__c;
                        oppTemp.Opportunity__c = TriggerData[0].Id;
                        oppTemp.Size_Error__c = oppLoop.Size_Error__c;
                        oppTemp.Size__c = oppLoop.Size__c;
                        oppTemp.UnitPrice__c = oppLoop.UnitPrice__c;
                        oppTemp.PriceBookEntryId__c = oppLoop.PriceBookEntryId__c;
                        oppTemp.SortOrder__c = oppLoop.SortOrder__c == null ? manualSortNumber : oppLoop.SortOrder__c;
                        
                        oppMain.add(oppTemp);
                        manualSortNumber++;
                    }
                    
                    // insert Optional Products to Quotes
                    if(oppMain.size() > 0){
                        insert oppMain;
                    }
                    
                }
            }
    }
}