public class EditAllOpportunityLineItemExtension {

    Private Id oppId {get; set;}
    Private static Id oliId {get; set;}    
    Private List<OpportunityLineItem> oli {get; set;}
    private Boolean EditProductPermission {get; set;}
    public Boolean showBack {get; set;}
    public String typeOfProduct {get; set;}
    
    public EditAllOpportunityLineItemExtension(ApexPages.StandardController std){
        EditProductPermission = true;
        showBack = false;
        oppId = ApexPages.currentPage().getParameters().get('oppId');
        typeOfProduct = ApexPages.currentPage().getParameters().get('recordType');
        
        String desireUserId = UserInfo.getUserId();
        User u = [select profileId, ContactId from user where id =: desireUserId limit 1];
        String profileId = u.profileId;
        LIST<ObjectPermissions> ObjPermissionList = new LIST<ObjectPermissions>();
        ObjPermissionList = [SELECT Id, SObjectType, PermissionsEdit FROM ObjectPermissions WHERE 
                             SobjectType = 'Product2' and
                             parentid in 
                             (select id from permissionset where PermissionSet.Profile.Id=: profileId) limit 1];
 
        if(!ObjPermissionList.isEmpty() && u.ContactId == null)
        {
            EditProductPermission = ObjPermissionList[0].PermissionsEdit;
            
        }       
            
    }
    
    public PageReference Edit(){
        
        if(!EditProductPermission){
            showBack = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient Privileges, You are not allowed to make these changes. Please contact your adminstrator.'));
            return null;
        }
        else{
            PageReference page = new PageReference('/apex/OpportunityEditAllPage?oppId=' + oppId + '&retURL=' + oppId + '&recordType=' +typeOfProduct);
            // PageReference page = new PageReference('/oppitm/multilineitem.jsp?oppId=' + oppId + '&retURL=' + oppId);
            page.setRedirect(true);
            return page;
        }
    }
    
    public PageReference CancelButton(){
        
        PageReference redirectPage = null;
        
        //if(soId != null){
            redirectPage = new PageReference('/' + oppId);
            redirectPage.setRedirect(true);
            return redirectPage;
    }
    
}