public class SyncCustomersETAOPsoPOHandler {
    
    public static void syncIt(list<Opportunity> oldOp, list<Opportunity> newOp,
                              list<AcctseedERP__Sales_Order__c> oldSo, list<AcctseedERP__Sales_Order__c> newSo,
                              list<AcctseedERP__Purchase_Order__c> oldPo, list<AcctseedERP__Purchase_Order__c> newPo){
                                  
                                  if(!newOp.IsEmpty() && !oldOp.IsEmpty()){
                                      // opportunity customer's eta has changed
                                      // find related so 
                                      // update customer's eta
                                      Integer i = 0;
                                      map<id, date> OpDateMap = new map<id, date>();
                                      
                                      for(opportunity o : newOp){
                                          
                                          if(o.deliver_by__c != oldOp[i].deliver_by__c){
                                              
                                              OpDateMap.put(o.id, o.deliver_by__c);
                                          }
                                          i++;
                                      }
                                      
                                      if(OpDateMap.size() > 0){
                                          
                                          // fetch all the related SO and update
                                          list<AcctSeedERP__Sales_Order__c> ss = [select AcctSeedERP__opportunity__c, 
                                                                                  Customer_s_eta__c from 
                                                                                  AcctSeedERP__Sales_Order__c
                                                                                  where AcctSeedERP__opportunity__c 
                                                                                  in:OpDateMap.keyset()]; 
                                          if(!ss.isEmpty()){
                                              
                                              for(AcctSeedERP__Sales_Order__c so : ss){
                                                  
                                                  Date cust = OpDateMap.get(so.AcctSeedERP__opportunity__c);
                                                  
                                                  so.Customer_s_eta__c = cust;
                                                  
                                              }
                                              
                                              update ss;
                                              
                                          }
                                      }
                                      
                                  }else if(!newSo.IsEmpty() && !oldSo.IsEmpty()){
                                      // sales order customer's eta has changed
                                      // find related op
                                      // find related po
                                      // update customer's eta
                                      Integer i = 0;
                                      map<id, date> OpDateMap = new map<id, date>();
                                      map<id, date> SoDateMap = new map<id, date>();
                                      
                                      for(AcctseedERP__Sales_Order__c s : newSo){
                                          
                                          if(s.customer_s_eta__c != oldSo[i].customer_s_eta__c){
                                              
                                              OpDateMap.put(s.AcctSeedERP__opportunity__c, s.customer_s_eta__c);
                                              SoDateMap.put(s.id, s.customer_s_eta__c);
                                          }
                                          i++;
                                      }
                                      
                                      if(OpDateMap.size() > 0){
                                          // fetch all the related Op
                                          list<Opportunity> ops = [select id, deliver_by__c from Opportunity
                                                                   where id in:OpDateMap.keyset()]; 
                                          if(!ops.isEmpty()){
                                              
                                              for(Opportunity op : ops){
                                                  
                                                  Date custd = OpDateMap.get(op.id);
                                                  
                                                  op.deliver_by__c = custd;
                                                  op.Run_Validation_Rule__c = true;
                                                  
                                              }
                                              
                                              update ops;
                                              
                                          }
                                      }
                                      
                                      if(SoDateMap.size() > 0){
                                          // fetch all the related po
                                          list<AcctSeedERP__Purchase_Order__c> pos = [select Sales_Order__c, 
                                                                                      Customer_s_eta__c from 
                                                                                      AcctSeedERP__Purchase_Order__c
                                                                                      where Sales_Order__c 
                                                                                      in:SoDateMap.keyset()]; 
                                          if(!pos.isEmpty()){
                                              
                                              for(AcctSeedERP__Purchase_Order__c po : pos){
                                                  
                                                  Date cstd = SoDateMap.get(po.Sales_Order__c);
                                                  
                                                  po.Customer_s_eta__c = cstd;
                                                  
                                              }
                                              
                                              update pos;
                                              
                                          }
                                      }
                                      
                                      
                                  }else if(!newPo.IsEmpty() && !oldPo.IsEmpty()){
                                      // purchase order customer's eta has changed
                                      // find related so
                                      // update customer's eta
                                      Integer i = 0;
                                      map<id, date> SoDateMap = new map<id, date>();
                                      
                                      for(AcctseedERP__Purchase_Order__c p : newPo){
                                          
                                          if(p.customer_s_eta__c != oldPo[i].customer_s_eta__c){
                                              SoDateMap.put(p.Sales_order__c, p.customer_s_eta__c);
                                          }
                                          i++;
                                      }
                                      
                                      if(SoDateMap.size() > 0){
                                          
                                          list<AggregateResult> agrs = [Select count(id) num, sales_order__c order from 
                                                                        AcctseedERP__Purchase_Order__c
                                                                        where Sales_Order__c in:
                                                                        SoDateMap.keyset() group by 
                                                                        Sales_Order__c];
                                          if(!agrs.IsEmpty()){
                                              for(AggregateResult agr : agrs){
                                                  
                                                  if((Integer)agr.get('num') > 1){
                                                      SoDateMap.remove((Id)agr.get('order'));
                                                      
                                                  }
                                              }
                                          }
                                          
                                          if(SoDateMap.size() > 0){
                                              
                                              // fetch all the related SO and update
                                              list<AcctSeedERP__Sales_Order__c> ss = [select AcctSeedERP__opportunity__c, 
                                                                                      Customer_s_eta__c from 
                                                                                      AcctSeedERP__Sales_Order__c
                                                                                      where id in:SoDateMap.keyset()]; 
                                              if(!ss.isEmpty()){
                                                  
                                                  for(AcctSeedERP__Sales_Order__c so : ss){
                                                      
                                                      Date cst = SoDateMap.get(so.id);
                                                      
                                                      so.Customer_s_eta__c = cst;
                                                      
                                                  }
                                                  
                                                  update ss;
                                                  
                                              }
                                              
                                          }
                                      }
                                  }        
                              }
}