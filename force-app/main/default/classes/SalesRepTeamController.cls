/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 06-23-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class SalesRepTeamController {
    
    private static final String SALES_REP_NOT_EXIST_EXCEPTION = 'Can not find Sales Rep.';
    private static final String SALES_REP_MEMBERS_NOT_EXIST_EXCEPTION = 'Can not find members of Sales Rep.';

    public class SalesRepTeamControllerException extends Exception{}

    /**
    * @description 
    * @author Marian Lyzhychka | 06-23-2023 
    * @param salesRepId 
    **/
    @AuraEnabled
    public static String getSalesRepTeamMembers(String salesRepId){
        try{
            Sales_Rep__c salesRep = [SELECT Id, Name, Team__c FROM Sales_Rep__c WHERE Id =:salesRepId WITH SECURITY_ENFORCED LIMIT 1];
            if(salesRep == null){
                throw new SalesRepTeamControllerException(SALES_REP_NOT_EXIST_EXCEPTION);
            }else if(salesRep.Team__c == null || String.isEmpty(salesRep.Team__c)){
                throw new SalesRepTeamControllerException(SALES_REP_MEMBERS_NOT_EXIST_EXCEPTION);
            }

            List<SalesRepMemberWrapper> salesRepMembersList = new List<SalesRepMemberWrapper>();

            Set<Id> userIds = new Set<Id>();

            for(String userId : salesRep.Team__c.split(';')){
                userIds.add(userId);
            }

            List<User> availableUsersList = [SELECT Id, Name From User WHERE Id IN : userIds AND isactive = true ORDER BY Name ASC];

            for(User u: availableUsersList){
                salesRepMembersList.add(new SalesRepMemberWrapper(
                    u.Name,
                    u.Id
                ));
            }

            return JSON.serialize(salesRepMembersList);
        }catch(Exception e){
            throw new SalesRepTeamControllerException(e.getMessage());
        }
    }
    
    public class SalesRepMemberWrapper {
        public String userName {get;set;}
        public String userId {get;set;}

        public SalesRepMemberWrapper(String userName, String userId){
            this.userName = userName;
            this.userId = userId;
        }
    }
}