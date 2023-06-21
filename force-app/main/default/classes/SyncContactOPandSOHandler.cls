public class SyncContactOPandSOHandler {
    // This is handler for Syncing single or both Contact Person  / Submitted Date between OP and SO
    public static void Opportunity_Update(list<Opportunity> od, list<Opportunity> nd)
    {
        Boolean UpdateGL = false;
        
        map<id, Opportunity> OpportunityMap = new map<id, opportunity>();
        
        if(!nd.isEmpty()){
            
            Integer i = 0;
            for(Opportunity o : nd){
                
                if(o.GL_Account_Variable_1__c != od[i].GL_Account_Variable_1__c){
                       
                       OpportunityMap.put(o.id, o);
                       UpdateGL = o.GL_Account_Variable_1__c != od[i].GL_Account_Variable_1__c ? true: false;   
                       
                   }
                i++;
            }
        }
        
        if(UpdateGL){
            
            list<AcctSeedERP__Sales_Order__c> Orders = [select id,
                                                                GL_Account_Variable_1__c,
                                                                AcctSeedERP__opportunity__c
                                                                from 
                                                                AcctSeedERP__Sales_Order__c
                                                                where AcctSeedERP__opportunity__c 
                                                                in:OpportunityMap.keyset()];
            
            if(!Orders.isEmpty()){
                
                for(AcctSeedERP__Sales_Order__c so : orders){
                    
                    Opportunity op = OpportunityMap.get(so.AcctSeedERP__opportunity__c);
                    
                    if(op == null) continue;

                    if(UpdateGL) so.GL_Account_Variable_1__c = op.GL_Account_Variable_1__c;

                }
                
                update Orders;
                
            }
        }
    }
    public static void SalesOrder_Update(list<AcctSeedERP__Sales_Order__c> od, 
                                         list<AcctSeedERP__Sales_Order__c> nd)
    {
        
       Boolean UpdateGL = false;
        
        map<id, AcctSeedERP__Sales_Order__c> OrderMap = new map<id, AcctSeedERP__Sales_Order__c>();
        
        if(!nd.isEmpty()){
            
            Integer i = 0;
            for(AcctSeedERP__Sales_Order__c so : nd){
                
                if(so.GL_Account_Variable_1__c != od[i].GL_Account_Variable_1__c){
                       
                       OrderMap.put(so.AcctSeedERP__Opportunity__c, so);
                       UpdateGL = so.GL_Account_Variable_1__c != od[i].GL_Account_Variable_1__c ? true: false;   
                       
                   }
                i++;
            }
        }
        
        if(UpdateGL){
            
            list<Opportunity> opptys = [select id, GL_Account_Variable_1__c
                                                                from 
                                                                Opportunity
                                                                where id
                                                                in:OrderMap.keyset()];
            
            if(!opptys.isEmpty()){
                
                for(Opportunity o : opptys){
                    
                    AcctSeedERP__Sales_Order__c so = OrderMap.get(o.id);
                    
                    if(so == null) continue;

                    if(UpdateGL) o.GL_Account_Variable_1__c = so.GL_Account_Variable_1__c;
                    
                    o.Run_Validation_Rule__c = true;

                }
                
                update opptys;
                
            }
        }
    }
}