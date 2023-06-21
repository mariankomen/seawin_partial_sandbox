public class AllowOppSharingHandler {
    
    public static List<SObject> opptShareCreate {get; set;}
    public static List<OpportunityTeamMember> oppTeamMemberList {get; set;}
    public static Boolean isInsert {get; set;}
    
    public static void AllowShareInternal(List<Opportunity> TriggerNew, Boolean isInsert){
        
        opptShareCreate = new List<SObject>();
        oppTeamMemberList = new List<OpportunityTeamMember>();
        
        Set<Id> OppIdSet = new Set<Id>();
        Set<Id> UserIdSet = new Set<Id>();
        
        // create a map
        Map<string, id> oppShareExists = new Map<string, id>();
        
        Organization org = [Select Id, DefaultOpportunityAccess from Organization];
        
        /*

        if(org.DefaultOpportunityAccess == 'None'){
            // get all the users in salesforce
            List<User> Users = [select Id, Name from User where UserType = 'Standard' and IsActive = true];
            for(Opportunity opp : TriggerNew){
                if(opp.Sales_Rep_O__c != null){
                    if(Users.size() > 0){
                        OppIdSet.Add(opp.Id);
                        for(User usr : Users){
                            if(usr.Id != opp.OwnerId){
                                UserIdSet.Add(usr.Id); // create the share object for users other than the owner
                            }
                        } 
                    }
                }
            }
            // check if share object is already there
            List<OpportunityShare> oppShareSoql = [select Id, OpportunityId, UserOrGroupId from OpportunityShare where OpportunityId in :OppIdSet and UserOrGroupId in :UserIdSet];
            if(oppShareSoql.Size() > 0){ 
                for(OpportunityShare os : oppShareSoql){
                    string key = os.OpportunityId + '-' + os.UserOrGroupId;
                    oppShareExists.put(key, os.OpportunityId);
                }
            }
            Boolean proceed = false;
            for(Id oppId : OppIdSet){
                for(Id usrID : UserIdSet){
                    if(oppShareExists.Size() > 0){
                        string key = oppId + '-' + usrID;
                        if(!oppShareExists.containsKey(key)){
                            proceed = true;   
                        }
                    }else{
                        	proceed = true;
                    }
                    if(proceed){
                        OpportunityTeamMember TeamMember = new OpportunityTeamMember();  
                        TeamMember.OpportunityId = oppId;  
                        TeamMember.UserId = usrID;  
                        TeamMember.TeamMemberRole = 'Sales Rep';
                        
                        oppTeamMemberList.Add(TeamMember);
                        
                        // create the share object
                        OpportunityShare oppS = new OpportunityShare();

                        oppS.put('OpportunityId', oppId);
                        oppS.put('UserOrGroupId', usrID);
                        oppS.put('OpportunityAccessLevel', 'Edit');
                        oppS.put('RowCause', 'Manual');
                        
                        opptShareCreate.Add(oppS);
                    }
                }    
            }
            
            if(oppTeamMemberList.size() > 0){
                insert oppTeamMemberList;
            }
            if(opptShareCreate.size() > 0){
                AllowShareCall();
            }
        }
        */
        
        // remove these lines after uncommenting the above code
        AllowShareExternal();
        AllowShareCall();
    }
    public static void AllowShareExternal(){
        /*
        // get all the opportunities where the SalesRep is not equal to Owner
        List<Opportunity> opp = [select Id, Sales_Rep_O__c, OwnerId from Opportunity];
        
        if(opp.Size() > 0){
            // insert OpportunitySharing object
            AllowShareInternal(opp, true);
        }
        */
    }
    public static void AllowShareCall(){
        /*
        insert opptShareCreate;
	*/
    }
}