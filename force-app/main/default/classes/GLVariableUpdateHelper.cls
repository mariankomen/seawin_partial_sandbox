public class GLVariableUpdateHelper {
    
    public static void UpdateOPLines(list<Opportunity> olist){
        
        set<id> opIds = new set<id>();
        for(Opportunity o : olist){
            
            opIds.add(o.id);
        }
        
        list<Opportunity> oppties = [select id,GL_Account_Variable_1__c from Opportunity
                                     where id in:opIds];
        
        if(!oppties.isEmpty()){
            map<id, id> opptyGLVarMap = new map<id, id>();
            for(Opportunity opty : oppties){
                
             	opptyGLVarMap.put(opty.id, opty.GL_Account_Variable_1__c);
            }
            
            if(opptyGLVarMap.size() > 0){
                
                // get the lines for the opportunities
                list<opportunitylineitem> lines = [select AcctSeed__GL_Account_Variable_1__c, OpportunityId
                                                   from OpportunityLineItem where OpportunityId in:opIds];
                
                if(!lines.isEmpty()){
                    
                    for(OpportunityLineItem line : lines){
                        
                        Id GLVArId = opptyGLVarMap.get(line.OpportunityId);
                        
                        line.AcctSeed__GL_Account_Variable_1__c = GLVArId;
                        
                        
                    }
                }
                
                // get the optional lines
                list<optional_products_opportunity__c> oop = [select GL_Account_Variable_1__c,
                                                             Opportunity__c from optional_products_opportunity__c
                                                             where opportunity__c =:opIds];
                
                if(!oop.isEmpty()){
                    
                    for(optional_products_opportunity__c p : oop){
                        
                        Id GLVArId = opptyGLVarMap.get(p.Opportunity__c);
                        
                        p.GL_Account_Variable_1__c = GLVArId;
                        
                        
                    }
                }
                
                if(!lines.isEmpty() && !oop.isEmpty()){
                    
                    UpdateLines(JSON.serialize(lines), JSON.serialize(oop), '', '');
                }else if(!lines.isEmpty()){
                    
                    UpdateLines(JSON.serialize(lines), '', '', '');
                }else if(!oop.isEmpty()){
                    
                    UpdateLines('', JSON.serialize(oop), '', '');
                }
                
            }
        }
        
    }
    
    public static void UpdateSOLines(list<AcctseedERP__Sales_Order__c> slist){
        
        set<id> soIds = new set<id>();
        for(AcctseedERP__Sales_Order__c so : slist){
            
            soIds.add(so.id);
        }
        
        list<AcctseedERP__Sales_Order__c> sales = [select id,
                                                   Gl_Account_variable_1__c from AcctseedERP__Sales_Order__c
                                                   where id in:soIds];
        
        if(!sales.isEmpty()){
            map<id, string> SOGLVarMap = new map<id, string>();
            for(AcctseedERP__Sales_Order__c sale : sales){

                  SOGLVarMap.put(sale.id, sale.Gl_Account_variable_1__c);
            }
            
            if(SOGLVarMap.size() > 0){
                
                // get the lines for the opportunities
                list<AcctseedERP__Sales_Order_Line__c> slines = [select id, AcctSeedERP__GL_Account_Variable_1__c, 
                                                                 AcctseedERP__Sales_Order__c
                                                                 from AcctseedERP__Sales_Order_Line__c where 
                                                                 AcctseedERP__Sales_Order__c in:soIds];
                map<id, id> solToGLMap = new map<id, id>();
                if(!slines.isEmpty()){
                    
                    for(AcctseedERP__Sales_Order_Line__c sline : slines){
                        
                        Id GLVArId = SOGLVarMap.get(sline.AcctseedERP__Sales_Order__c);
                        
                        sline.AcctSeedERP__GL_Account_Variable_1__c = GLVArId;
                        
                        //solToGLMap.put(sline.id, GLVArId);
                        
                        
                    }
                    UpdateLines('', '', JSON.serialize(slines), '');
                    // uncomment if the po and po lines need to be updated
                    /*
                    list<Acctseederp__Purchase_order__c> pos = [select id,Sales_Order__c from Acctseederp__Purchase_order__c
                                                                where Sales_Order__c in:soIds];
                    
                    if(!pos.isEmpty()){

                        set<id> poIds = new set<id>();
                        for(Acctseederp__Purchase_order__c po : pos){
                            po.GL_Account_Variable_1__c = SOGLVarMap.get(po.Sales_Order__c);
                            poIds.add(po.id);
                        }
                        
                        update pos;
                        
                        list<Acctseederp__Purchase_order_Line__c> pols = [select Sales_Order_Line__c,
                                                                          AcctSeedERP__GL_Account_Variable_1__c from
                                                                          Acctseederp__Purchase_order_Line__c where 
                                                                          Acctseederp__Purchase_order__c in:poIds];
                        if(!pols.isEmpty()){
                            
                            
                            for(Acctseederp__Purchase_order_Line__c pol : pols){
                                
                                Id gId = solToGLMap.get(pol.Sales_Order_Line__c);
                                
                                pol.AcctSeedERP__GL_Account_Variable_1__c = gId;
                                
                            }
                            
                            //update pols;
                            
                            UpdateLines('', '', JSON.serialize(slines), '');
                            
                            // As there is already a future method running on po lines
                            update pols;
                            
                        }else{
                        
                        UpdateLines('', '', JSON.serialize(slines), '');
                    }
                        
                    }else{
                        
                        UpdateLines('', '', JSON.serialize(slines), '');
                    }
                    */
                }
            }
        }
        
    }
    
    @future
    public static void UpdateLines(String ol, string ool, string sl, string pl){
        
        if(ol.length() > 0 && ool.length() > 0){
            // update opportunity lines
            list<Opportunitylineitem> lines = 
                (list<Opportunitylineitem>)JSON.deserialize(ol, list<Opportunitylineitem>.class);
            
            update lines;
            
            // update optional opportunity lines
            list<Optional_Products_Opportunity__c> olines = 
                (list<Optional_Products_Opportunity__c>)JSON.deserialize(ool, list<Optional_Products_Opportunity__c>.class);
            
            update olines;
            
        }else if(ol.length() > 0){
            // update opportunity lines
            list<Opportunitylineitem> lines = 
                (list<Opportunitylineitem>)JSON.deserialize(ol, list<Opportunitylineitem>.class);
            
            update lines;
            
        }if(ool.length() > 0){
            
            // update optional opportunity lines
            list<Optional_Products_Opportunity__c> lines = 
                (list<Optional_Products_Opportunity__c>)JSON.deserialize(ool, list<Optional_Products_Opportunity__c>.class);
            
            update lines;
            
        }else if(sl.length() > 0){
            // update sales order lines
            list<AcctSeedERP__Sales_Order_Line__c> lines = 
                (list<AcctSeedERP__Sales_Order_Line__c>)JSON.deserialize(sl, list<AcctSeedERP__Sales_Order_Line__c>.class);
            update lines;
        }
    }
}