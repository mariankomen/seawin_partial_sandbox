public class TransactionHandler {
    
    public static void BeforeHandler(List<AcctSeed__Transaction__c> data){
      	
        set<id> GL_Accounts_Ids = new set<id>();
        
        for(AcctSeed__Transaction__c t : data){
            
            if(t.AcctSeed__GL_Account__c != null){
                
                GL_Accounts_Ids.add(t.AcctSeed__GL_Account__c);
            }
        }
        
        if(GL_Accounts_Ids.size() > 0){
            
            List<AcctSeed__GL_Account__c> GL_Accounts = [select id, GL_Account_Variable_1__c from
                                                       AcctSeed__GL_Account__c where id in:GL_Accounts_Ids];
            
            map<id, id> GL_Accounts_Map = new map<id, id>();
            
            for(AcctSeed__GL_Account__c gl : GL_Accounts){
                if(gl.GL_Account_Variable_1__c != null){
                    
                    GL_Accounts_Map.put(gl.id, gl.GL_Account_Variable_1__c);
                }
            }
            
            if(GL_Accounts_Map.size() > 0){
                
                for(AcctSeed__Transaction__c t : data){
            
                    if(t.AcctSeed__GL_Account__c != null){
                        
                        Id GL_Account_Variable_Id = GL_Accounts_Map.get(t.AcctSeed__GL_Account__c);
                        
                        if(GL_Account_Variable_Id == null) continue;
                        
                        t.AcctSeed__GL_Account_Variable_1__c = GL_Account_Variable_Id;
                    }
                }
            }
        }
    }
}