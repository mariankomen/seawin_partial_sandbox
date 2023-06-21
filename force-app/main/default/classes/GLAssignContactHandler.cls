public class GLAssignContactHandler {
    
    public static void ProcessIt(List<Contact> data){
        
        map<id, contact> Have_Account_Map = new map<id, contact>();
        map<id, contact> No_Account_Map = new map<id, contact>();
        
        for(contact c : data){
            if(c.AccountId != null){
                Have_Account_Map.put(c.AccountId, c);
            }
            No_Account_Map.put(c.OwnerId, c);
        }

        List<AcctSeed__Accounting_Variable__c> avs = [select id,name from AcctSeed__Accounting_Variable__c];
        map<string, id> GL_Map = new map<string, id>();
        
        if(!avs.isEmpty()){
            
            for(AcctSeed__Accounting_Variable__c av : avs){
                
                GL_Map.put(av.name, av.id);
            }
            
        }
        
        if(GL_Map.size() > 0){
            
            List<User> users = [select id, default_gl_account_variable__c from user where id in:No_Account_Map.keyset()];
            
            map<id, string> User_GL_Map = new map<id, string>();
            
            if(!users.isEmpty()){
                
                for(User u : users){
                    if(u.default_gl_account_variable__c != null){
                        
                        String glav_name = u.default_gl_account_variable__c;
                        
                        if(u.default_gl_account_variable__c.indexOf(';') > -1){
                            
                            glav_name = u.default_gl_account_variable__c.split(';')[0];
                        }
                        
                        if(GL_Map.containsKey(glav_name)){
                            
                            User_GL_Map.put(u.id, GL_Map.get(glav_name));
                            
                        }
                    }
                }
            }
            
            if(Have_Account_Map.size() > 0){
                
                List<Account> accounts = [select id, acctseed__gl_account_variable_1__c
                                          from account where id in:Have_Account_Map.keyset()];
                
                map<id, account> Accounts_Map = new map<id, account>(accounts);
                
                if(Accounts_Map.size() > 0){
                    for(contact c : data){
                        if(c.accountid != null){
                            
                            Account acct = Accounts_Map.get(c.AccountId);
                            
                            if(acct == null) continue;
                            
                            if(acct.acctseed__gl_account_variable_1__c != null){
                                
                                c.GL_Account_Variable_1__c = acct.acctseed__gl_account_variable_1__c;
                                
                            }else{
                                
                                if(User_GL_Map.containsKey(c.OwnerId)){
                                    
                                    c.GL_Account_Variable_1__c = User_GL_Map.get(c.OwnerId);
                                }
                            }
                        }
                    }
                }
            }else if(No_Account_Map.size() > 0){
                
                if(User_GL_Map.size() > 0){
                    
                    for(contact c : data){
                        if(c.accountid == null){
                            if(User_GL_Map.containsKey(c.OwnerId)){
                                
                                c.GL_Account_Variable_1__c = User_GL_Map.get(c.OwnerId);
                            }
                    	}
                    }
                }
            }
            
        }
    }
}