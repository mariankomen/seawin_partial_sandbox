public class EditQuoteLineItemExtension {
 
    Private Id quoteId {get; set;}
    Private static Id qliId {get; set;}    
    Private List<QuoteLineItem> qli {get; set;}
    private Boolean EditProductPermission {get; set;}
    public Boolean showBack {get; set;}
    
    public EditQuoteLineItemExtension(ApexPages.StandardController std){
        EditProductPermission = true;
        qliId = (Id)std.getId();
        qli = [select id, quoteid from QuoteLineItem where id =: qliId];
        quoteId = qli[0].quoteid;
        
        String desireUserId = UserInfo.getUserId();
        User u = [select profileId from user where id =: desireUserId];
        String profileId = u.profileId;
        LIST<ObjectPermissions> ObjPermissionList = new LIST<ObjectPermissions>();
        ObjPermissionList = [SELECT Id, SObjectType, PermissionsEdit FROM ObjectPermissions WHERE parentid in 
                             (select id from permissionset where PermissionSet.Profile.Id=: profileId)];
 
        for(ObjectPermissions objPerm :ObjPermissionList){
            if(objPerm.SobjectType == 'Product2')
            {
                EditProductPermission = objPerm.PermissionsEdit;
             
            }
        }
    }
    
    public PageReference Edit(){
        
        if(!EditProductPermission){
            showBack = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient Privileges, You are not allowed to make these changes. Please contact your adminstrator.'));
            return null;
        }
        else{
            //string url;
            PageReference page = new PageReference('/'+qliId+'/e?nooverride=1&retURL='+quoteId);
            page.setRedirect(true);
            return page;
        }
    }
    
    public PageReference CancelButton(){
        
        PageReference redirectPage = null;
        
        //if(soId != null){
            redirectPage = new PageReference('/' + quoteId);
            redirectPage.setRedirect(true);
            return redirectPage;
    }
    
}