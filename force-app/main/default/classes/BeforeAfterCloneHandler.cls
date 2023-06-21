public class BeforeAfterCloneHandler {
    public static void ProcessBefore(List<Opportunity> data){
        
        for(Opportunity opp : data){
            
            opp.Shipping_Term__c = null; 
            //opp.GL_Account_Variable_1__c = null;
            opp.RecordTypeId = null;
            //opp.Pricebook2Id = null;
        }
    }
    
    public static void ProcessAfter(List<Opportunity> data){
        
        Set<ID> OppIds = new Set<ID>();
        for(Opportunity opp : data){
            if(opp.Id != null){
                OppIds.add(opp.Id);
            }
        }
        if(OppIds.size() > 0){
            DeleteProducts(OppIds);
        }
    }
    
    @future
    public static void DeleteProducts(Set<ID> IDs){
        
        LIST<OpportunityLineItem> products = [select id, Size__c, Product2.Name, Item_Description__c, ProductCode 
                                              from OpportunityLineItem 
                                              where OpportunityId IN : IDs ];
        if(!products.isEmpty())
            delete products;
        
        List<Opportunity> opps = [select id, Name, Pricebook2Id
                                  from Opportunity
                                  where Id IN : IDs];
        
        for(Opportunity o: opps){
            o.Pricebook2Id = null;
            o.Run_Validation_Rule__c = true;
        }
        update opps;
    }
    
    //call this method, if opportunity is not cloned or type is not 'Template'
    public static void ProcessAfterNotClonedAndTemplate(List<Opportunity> data){
        System.debug('data is: ' + data);
        Set<ID> OppIds = new Set<ID>();
        for(Opportunity opp : data){
            if(opp.Id != null){
                OppIds.add(opp.Id);
            }
        }
        UpdateTheGL(OppIds);
    }
    
    @future
    public static void UpdateTheGL(Set<ID> IDs){
        System.debug('IDs: ' + IDs);
        List<Opportunity> opps = [select id, Name, AccountId, GL_Account_Variable_1__c
                                  from Opportunity
                                  where Id IN : IDs];
        
        set<id> accountIds = new set<id>();
        for(Opportunity opp : opps){
            if(opp.AccountId != null){
                accountIds.add(opp.AccountId);
            }
        }
        
        
        if(accountIds.size() > 0){
            map<id, id> AccountGLMap = new map<id, id>();
            
            for(Account acct : [select id, AcctSeed__GL_Account_Variable_1__c from Account where
                                id IN:accountIds]){
                                    
                                    AccountGLMap.put(acct.id, acct.AcctSeed__GL_Account_Variable_1__c);                  
                                }
            
            List<Opportunity> updatables = new List<Opportunity>();
            
            if(AccountGLMap.size() > 0){
                
                for(Opportunity opp : opps){
                    
                    if(opp.GL_Account_Variable_1__c == null){
                        
                        id Glid = AccountGLMap.get(opp.AccountId);
                        
                        opp.GL_Account_Variable_1__c = Glid;
                        opp.Run_Validation_Rule__c = true;
                        
                        updatables.add(opp);
                        
                    }
                }
                
            }
            
            if(!updatables.isEmpty()){
                
                update opps;
            }
        }
    }
}