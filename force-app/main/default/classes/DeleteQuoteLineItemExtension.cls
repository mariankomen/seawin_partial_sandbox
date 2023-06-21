public class DeleteQuoteLineItemExtension {
    
    public id quoteId {get; set;}
    public boolean hasDeletePermission {get; set;}
    public boolean PrivilegeError {get; set;}
    public boolean BillingError {get; set;}
    public QuoteLineItem qli {get; set;}
    public string retURL {get; set;}
    
    public DeleteQuoteLineItemExtension(ApexPages.standardcontroller std){
        
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        Id LineId = (id)std.getId();
        hasDeletePermission = true;
        PrivilegeError = false;
        BillingError = false;
        qli = new QuoteLineItem();
        
        qli = [select id, quoteId, Quote.Opportunity.TotalBills__c from QuoteLineItem where id =: LineId limit 1];
        
        String desireUserId = UserInfo.getUserId();
        User u = [select profileId from user where id =: desireUserId limit 1];
        String profileId = u.profileId;
        LIST<ObjectPermissions> ObjPermissionList = new LIST<ObjectPermissions>();
        LIST<ObjectPermissions> testt = [select id, SObjectType from ObjectPermissions];
        
        ObjPermissionList = [SELECT Id, SObjectType, PermissionsDelete FROM ObjectPermissions WHERE 
                             SobjectType = 'Product2' and
                             parentid in 
                             (select id from permissionset where PermissionSet.Profile.Id=: profileId) limit 1];
 
        if(!ObjPermissionList.isEmpty())
        {
            hasDeletePermission = ObjPermissionList[0].PermissionsDelete;
            System.debug('has 1: ' + hasDeletePermission);
        }
        
        
        quoteId = qli.quoteId;  
    }
    
    public PageReference PageAction(){
        
        PageReference page = new Pagereference(retURL); 
        page.setRedirect(true);
        
        PrivilegeError = HasDeletePermission ? false : true; 
        BillingError = qli.Quote.Opportunity.TotalBills__c > 0 ? true : false;
        
        if(!PrivilegeError && !BillingError){
            try{
                
                delete qli;  
            }catch(Exception ex){
                system.debug('Error message:');
                system.debug(ex.getMessage());
            }
            
            return page;
        }
        
        return null;
    }
    
    public PageReference back(){
        PageReference page = new Pagereference('/' + quoteId); 
        page.setRedirect(true);
        return page;
    }
}