public class EditAllQuoteLineItemExtension {

    Private Id quoteId {get; set;}
    Private static Id qliId {get; set;}    
    Private List<QuoteLineItem> qli {get; set;}
    private Boolean EditProductPermission {get; set;}
    public Boolean showBack {get; set;}
    
    public EditAllQuoteLineItemExtension(ApexPages.StandardController std){
        EditProductPermission = true;
        showBack = false;
        quoteId = ApexPages.currentPage().getParameters().get('quoteId');
        
        String desireUserId = UserInfo.getUserId();
        User u = [select profileId from user where id =: desireUserId limit 1];
        String profileId = u.profileId;
        LIST<ObjectPermissions> ObjPermissionList = new LIST<ObjectPermissions>();
        ObjPermissionList = [SELECT Id, SObjectType, PermissionsEdit FROM ObjectPermissions WHERE 
                             SobjectType = 'Product2' and
                             parentid in 
                             (select id from permissionset where PermissionSet.Profile.Id=: profileId) limit 1];
 
        if(!ObjPermissionList.isEmpty())
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
            PageReference page = new PageReference('/quoteitm/multilineitem.jsp?quoteId=' + quoteId + '&retURL=' + quoteId);
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