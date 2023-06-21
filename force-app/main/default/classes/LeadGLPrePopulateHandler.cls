public class LeadGLPrePopulateHandler {
    
    public static void PrePopulate(List<Lead> data){
        
        string GLname = null;
        
        // Get the logged in user GL Account Variable
        User usr = [select Default_GL_Account_Variable__c from User where Id =: UserInfo.getUserId() Limit 1];
        
        if(usr.Default_GL_Account_Variable__c != null){
            if(usr.Default_GL_Account_Variable__c.indexOf(';') > -1){
                GLname = usr.Default_GL_Account_Variable__c.split(';')[0];
                
            }else{
                GLname = usr.Default_GL_Account_Variable__c;
            }
        }
        
        if(GLname != null){
            List<AcctSeed__Accounting_Variable__c> avrs = [select id from AcctSeed__Accounting_Variable__c 
                                                           where name =: GLname Limit 1];
            if(!avrs.isEmpty()){
                
                for(Lead ld : data){
                    if(ld.GL_Account_Variable_1__c == null){
                        ld.GL_Account_Variable_1__c = avrs[0].id;
                    }
                }
            }
        }
    }
}