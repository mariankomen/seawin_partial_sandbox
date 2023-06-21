public class SalesOrderLineFieldValueChangeHandler {
    
    public static void FieldValueChange(list<AcctSeedERP__Sales_Order_Line__c> oldData,
                                        list<AcctSeedERP__Sales_Order_Line__c> newData){
                                            
                                            map<id, AcctSeedERP__Sales_Order_Line__c> OpportunityLineMap = 
                                                new map<id, AcctSeedERP__Sales_Order_Line__c>();
                                            map<id, AcctSeedERP__Sales_Order_Line__c> BillingLineMap = 
                                                new map<id, AcctSeedERP__Sales_Order_Line__c>();
                                            
                                            integer i = 0;
                                            for(AcctSeedERP__Sales_Order_Line__c line : newData){   
                                                if(line.item_description__c != oldData[i].item_description__c ||
                                                   line.Size__c != oldData[i].size__c){
                                                       OpportunityLineMap.put(line.AcctSeedERP__Opportunity_Product_Id__c, 
                                                                              line);
                                                       BillingLineMap.put(line.id, line);
                                                   }
                                                i++;
                                            }
                                            
                                            if(OpportunityLineMap.size() > 0){
                                                list<OpportunityLineItem> opportunitys = [SELECT Id, Item_Description__c, 
                                                                                          Size__c 
                                                                                          FROM OpportunityLineItem 
                                                                                          where Id 
                                                                                          in:OpportunityLineMap.keyset()];
                                                if(!opportunitys.isEmpty()){
                                                    
                                                    for(OpportunityLineItem oli : opportunitys){
                                                        
                                                        AcctseedERP__Sales_Order_Line__c line = OpportunityLineMap.get(oli.id);
                                                        
                                                        oli.Size__c = line.Size__c;
                                                        oli.Item_Description__c = line.Item_Description__c;
                                                        
                                                    }
                                                    try{
                                                        update opportunitys;
                                                    }catch(Exception ext){
                                                        system.debug(ext.getMessage());
                                                    }
                                                    
                                                }
                                            }
                                            
                                            if(BillingLineMap.size() > 0){
                                                list<AcctSeed__Billing_Line__c> billings = [SELECT Id, Item_Description__c, 
                                                                                            Size__c, 
                                                                                            AcctSeedERP__Sales_Order_Line__c 
                                                                                            FROM AcctSeed__Billing_Line__c 
                                                                                            where 
                                                                                            AcctSeedERP__Sales_Order_Line__c 
                                                                                            in:BillingLineMap.keyset()];
                                                
                                                if(!billings.isEmpty()){
                                                    
                                                    for(AcctSeed__Billing_Line__c bol : billings){
                                                        
                                                        AcctseedERP__Sales_Order_Line__c sl = 
                                                            BillingLineMap.get(bol.AcctSeedERP__Sales_Order_Line__c);
                                                        
                                                        //bol.Size__c = sl.Size__c;
                                                        bol.Item_Description__c = sl.Item_Description__c;
                                                        
                                                    }
                                                    
                                                    try{
                                                        update billings;
                                                    }catch(Exception ext){
                                                        system.debug(ext.getMessage());
                                                    }
                                                }
                                            }
                                        }
}