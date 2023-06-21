public class OLIDeleteExtension {
    
    public id opId {get; set;}
    public boolean showBillingMsg {get; set;}
    public boolean showApprovalMsg {get; set;}
    public OpportunityLineItem oli {get; set;}
    public string retURL {get; set;}
    public boolean hasDeletePermission {get; set;}
    public User usr{get; set;}
    
    public OLIDeleteExtension(ApexPages.standardcontroller std){
        
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        Id LineId = (id)std.getId();
        showBillingMsg = false;
        showApprovalMsg = false;
        hasDeletePermission = true;
        oli = new OpportunityLineItem();
        oli = [select id, opportunityid, Opportunity.Sent_For_Approval__c, Opportunity.TotalSalesOrderInOpp__c 
               from opportunitylineitem where id =: LineId limit 1];

        String desireUserId = UserInfo.getUserId();
        User u = [select profileId from user where id =: desireUserId limit 1];
        String profileId = u.profileId;
        LIST<ObjectPermissions> ObjPermissionList = new LIST<ObjectPermissions>();
        ObjPermissionList = [SELECT Id, SObjectType, PermissionsDelete FROM ObjectPermissions WHERE 
                             SobjectType = 'Product2' and
                             parentid in 
                             (select id from permissionset where PermissionSet.Profile.Id=: profileId) limit 1];

        usr = [select Profile.name, ContactId from User where  id =: UserInfo.getUserId() limit 1];
        
        if(!ObjPermissionList.isEmpty() &&  usr.ContactId == null)
        {
            hasDeletePermission = ObjPermissionList[0].PermissionsDelete;
        }       
		
        opId = oli.OpportunityId;
                
    }
    
    public PageReference PageAction(){
        
        PageReference page = new Pagereference(retURL); 
        page.setRedirect(true);
        
        
        
        List<AcctSeed__Billing_Line__c> billingLines = [SELECT Id FROM AcctSeed__Billing_Line__c WHERE AcctSeed__Billing__r.AcctSeed__Opportunity__c =: oli.opportunityid AND AcctSeed__Opportunity_Product_Id__c =: oli.Id];
        if(hasDeletePermission){
            if(oli.Opportunity.Sent_For_Approval__c && usr.Profile.name != 'System Administrator'){
                showApprovalMsg = true;
            }
            if(!showApprovalMsg){ // if the opportunity is not in approval
                
                if(!billingLines.isEmpty()){
                    showBillingMsg = true;
                }
                
                if(!showBillingMsg){ // if there is no billing proceed with deleting
                    if(oli.Opportunity.TotalSalesOrderInOpp__c == 0.0){
                        try{
                            delete oli;
                        }
                        catch(Exception ex){}  
                        return page;
                    }
                }
            }
        }
        return null;
    }
    
    public PageReference back(){
        PageReference page = new Pagereference('/'+opId); 
        page.setRedirect(true);
        return page;  
    }
}