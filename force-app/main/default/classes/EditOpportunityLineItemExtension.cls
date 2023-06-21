public class EditOpportunityLineItemExtension {
    
    Private Id oppId {get; set;}
    Private static Id oliId {get; set;}    
    Private List<OpportunityLineItem> oli {get; set;}
    public Boolean EditProductPermission {get; set;}
    public Boolean SOExists {get; set;}
    
    public string communityUrl {
        get{
            string contactId = [select id, contactId from User where id =: userinfo.getUserId() limit 1][0].contactId;
            return  contactId == null ? '' : '/sales/';
        }
    }
    
    public EditOpportunityLineItemExtension(ApexPages.StandardController std){
        EditProductPermission = true;
        oliId = (Id)std.getId();
        
    }
    
    public PageReference Edit(){
        
        oli = [select id, OpportunityId from OpportunityLineItem where id =: oliId];
        oppId = oli[0].OpportunityId;
        
        String desireUserId = UserInfo.getUserId();
        User u = [select profileId, ContactId from user where id =: desireUserId limit 1];
        String profileId = u.profileId;
        LIST<ObjectPermissions> ObjPermissionList = new LIST<ObjectPermissions>();
        LIST<ObjectPermissions> testt = [select id, SObjectType from ObjectPermissions];
        
        ObjPermissionList = [SELECT Id, SObjectType, PermissionsEdit FROM ObjectPermissions WHERE 
                             SobjectType = 'Product2' and
                             parentid in 
                             (select id from permissionset where PermissionSet.Profile.Id=: profileId) limit 1];
        
        if(!ObjPermissionList.isEmpty() && u.ContactId == null)
        {
            EditProductPermission = ObjPermissionList[0].PermissionsEdit;
            
        }
        SOExists = true;
        
        LIST<AcctSeedERP__Sales_Order__c> SO = [select id from AcctSeedERP__Sales_Order__c
                                                where AcctSeedERP__Opportunity__c =: oppId limit 1];
        
        if(EditProductPermission){
            if(SO.isEmpty()){
               // if([SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox)
                 //   page = new PageReference('/'+oliId+'/e?nooverride=1&retURL='+oppId);
                //else{
                   PageReference page = new PageReference('/'+oliId+'/e?nooverride=1&retURL='+communityUrl+oppId);
                //}
                page.setRedirect(true);
                SOExists = false;
                return page;
            }
        }
        
        return null;
    }
    
    public PageReference CancelButton(){
        
        PageReference redirectPage = null;
        
        //if(soId != null){
        redirectPage = new PageReference('/' + oppId);
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
}