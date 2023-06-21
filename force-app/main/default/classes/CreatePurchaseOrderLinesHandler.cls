public class CreatePurchaseOrderLinesHandler {
    
    public static void CreatePurchaseOrderLine(){
        
        
    }
    /*
    public static boolean doRun {
        get{
            if(doRun == null){
                doRun = true;    
            }
            return doRun;
        } 
        set;
    }
    
    public static void DoCreate(list<AcctSeedERP__Purchase_Order__c> data){
        if(doRun != null && doRun){
            map<id, id> SalesIdToPurchaseIdMap = new map<id, id>();
            
            for(AcctSeedERP__Purchase_Order__c po : data){
                if(po.Sales_Order__c != null){
                    
                    SalesIdToPurchaseIdMap.put(po.Sales_Order__c, po.id);
                }
            }
            
            if(SalesIdToPurchaseIdMap.size() > 0){
                
                list<AcctSeedERP__Sales_Order_line__c> lines = [SELECT Id, Name, AcctSeedERP__Product__r.Name,
                                                                AcctSeedERP__Unit_Price__c,
                                                                AcctSeedERP__Product__r.Description,
                                                                AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c,
                                                                AcctSeedERP__Comment__c, AcctSeedERP__Product__c, 
                                                                AcctSeedERP_Description__c,SortOrder__c,
                                                                AcctSeedERP__Product__r.AcctSeed__Unit_Cost__c, size__c, 
                                                                Quantity_Allocated_formula__c,
                                                                Quantity_Shipped_Formula__c,AcctSeedERP__Quantity_Ordered__c,
                                                                AcctSeedERP__Quantity_Needed__c,
                                                                acctseederp__total__c, productcode__c,Quantity_Needed_Formula__c,
                                                                Available_Quantity__c,
                                                                AcctSeederp__GL_Account_Variable_1__c, 
                                                                AcctSeederp__GL_Account_Variable_2__c, 
                                                                AcctSeederp__GL_Account_Variable_3__c, 
                                                                AcctSeederp__GL_Account_Variable_4__c, POL_Quantity__c, 
                                                                QuantityFormula__c,
                                                                AcctSeedERP__Sales_Order__c,Item_Description__c
                                                                FROM AcctSeedERP__Sales_Order_Line__c 
                                                                WHERE AcctSeedERP__Sales_Order__c in:SalesIdToPurchaseIdMap.KeySet()
                                                                AND IsAllocated__c != 1 and isdeleted = false 
                                                                order by sortorder__c,name,createddate asc];
                                                                
                if(!lines.isEmpty()){
                    
                    list<AcctSeedERP__Purchase_Order_Line__c> pols = new list<AcctSeedERP__Purchase_Order_Line__c>();
                    
                    for(AcctSeedERP__Sales_Order_line__c sol : lines){
                        
                        if(sol.QuantityFormula__c != sol.POL_Quantity__c){
                            Id pId = SalesIdToPurchaseIdMap.get(sol.AcctSeedERP__Sales_Order__c);
                            
                            AcctSeedERP__Purchase_Order_Line__c pol = new AcctSeedERP__Purchase_Order_Line__c();
                            
                            pol.AcctSeedERP__Purchase_Order__c = pId;
                            pol.AcctSeedERP__Comment__c = sol.AcctSeedERP__Comment__c; 
                            pol.AcctSeedERP__GL_Account_Variable_1__c = sol.AcctSeedERP__GL_Account_Variable_1__c; 
                            pol.AcctSeedERP__GL_Account_Variable_2__c = sol.AcctSeedERP__GL_Account_Variable_2__c; 
                            pol.AcctSeedERP__GL_Account_Variable_3__c = sol.AcctSeedERP__GL_Account_Variable_3__c;
                            pol.AcctSeedERP__GL_Account_Variable_4__c = sol.AcctSeedERP__GL_Account_Variable_4__c;
                            pol.AcctSeedERP__Product__c = sol.AcctSeedERP__Product__c;  
                            pol.AcctSeedERP__Quantity__c = (sol.POL_Quantity__c != null || sol.POL_Quantity__c > 0) ? 
                                sol.AcctSeedERP__Quantity_Ordered__c - sol.POL_Quantity__c : sol.AcctSeedERP__Quantity_Ordered__c;
                            pol.AcctSeedERP__Unit_Price__c = sol.AcctSeedERP__Unit_Price__c; 
                            pol.Description__c = sol.Item_Description__c; 
                            pol.Sort_Order__c = sol.SortOrder__c;
                            pol.Sales_Order_Line__c  = sol.id;
                            pol.Size__c = sol.Size__c;
                            
                            pols.add(pol);
                        }
                    }
                    
                    if(!pols.isEmpty()){
                        
                        Savepoint sp = Database.setSavepoint();
                        
                        try{
                            
                            insert pols;
                            
                            map<id, id> SOidToPOidMap = new map<id, id>();
                            
                            for(AcctSeedERP__Purchase_Order_Line__c pol : pols){
                                
                                SOidToPOidMap.put(pol.Sales_Order_Line__c, pol.id);
                            }
                            
                            for(AcctSeedERP__Sales_Order_line__c sol : lines){
                                
                                id polId = SOidToPOidMap.get(sol.id);
                                sol.AcctSeedERP__Purchase_Order_Line__c = polId; 
                                
                            }
                            
                            update lines;
                            
                        }catch(Exception ex){
                            Database.rollback(sp);
                            system.debug(ex.getMessage());
                        }                  
                    }
                }
            }
        }
    }
    */
}