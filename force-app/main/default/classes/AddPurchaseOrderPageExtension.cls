public class AddPurchaseOrderPageExtension {
    
    public AcctSeedERP__Purchase_Order__c po {get; set;}
    public String recTypName {get; set;}
    public AddPurchaseOrderPageExtension(ApexPages.StandardController std) {
        
        po = new AcctSeedERP__Purchase_Order__c();
        po = (AcctSeedERP__Purchase_Order__c)std.getRecord();
        
        String RecTypId = ApexPages.currentPage().getParameters().get('RecordType');
        String glAccVar1Id = ApexPages.currentPage().getParameters().get('glAccVar1Id');
        String soId = ApexPages.currentPage().getParameters().get('soId');
        String relatedOppId = ApexPages.currentPage().getParameters().get('relatedOppId');
        String shipngCompanyId = ApexPages.currentPage().getParameters().get('shipngCompanyId');
        String shipngContactId = ApexPages.currentPage().getParameters().get('shipngContactId');
        String projectId = ApexPages.currentPage().getParameters().get('projectId');

        system.debug('RecTypId: '+RecTypId);
        system.debug('glAccVar1Id: '+glAccVar1Id);
        system.debug('soId: '+soId);
        system.debug('relatedOppId: '+relatedOppId);
        system.debug('shipngCompanyId: '+shipngCompanyId);
        system.debug('shipngContactId: '+shipngContactId);
        system.debug('projectId: '+projectId);
        if(!Test.isRunningTest() && String.isNotEmpty(RecTypId)){  
            recTypName = Schema.getGlobalDescribe().get('AcctSeedERP__Purchase_Order__c').getDescribe().getRecordTypeInfosById().get(RecTypId).getName();
        }
        /*
        Schema.DescribeSObjectResult dsr = AcctSeedERP__Purchase_Order__c.SObjectType.getDescribe();
        Schema.RecordTypeInfo defaultRecordType;
        for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
            if(rti.isDefaultRecordTypeMapping()) {
                defaultRecordType = rti;
            }
        }
        
        recTypName = recTypName == null ? defaultRecordType.getName() : recTypName;
        RecTypId = RecTypId == null ? defaultRecordType.getRecordTypeId() : RecTypId;*/
        
        if(RecTypId != '') po.RecordTypeId = RecTypId;
        if(glAccVar1Id != null && glAccVar1Id != '') po.GL_Account_Variable_1__c = glAccVar1Id;
        if(soId != ''){
            po.Sales_Order__c = soId;
            po.AcctSeedERP__Purchase_Order_Format__c = 'a0G1I000001DqSdUAK';
        }
        if(relatedOppId != '') po.Opportunity_Readonly__c = relatedOppId;
        if(shipngCompanyId != '') po.AcctSeedERP__Shipping_Company__c = shipngCompanyId;
        if(shipngContactId != '') po.AcctSeedERP__Shipping_Contact__c = shipngContactId;
        if(projectId != '') po.Project__c = projectId;
        
        po.AcctSeedERP__Shipping_Street__c = ApexPages.currentPage().getParameters().get('shpngStreet');
        po.AcctSeedERP__Shipping_City__c = ApexPages.currentPage().getParameters().get('shipngCity');
        po.AcctSeedERP__Shipping_State__c = ApexPages.currentPage().getParameters().get('shipngStat');
        po.AcctSeedERP__Shipping_Postal_Code__c = ApexPages.currentPage().getParameters().get('shipngPostalCode');
        po.AcctSeedERP__Shipping_Country__c = ApexPages.currentPage().getParameters().get('shipngCountry');
        system.debug('end constructor');
    }
    
    public pagereference pageAction(){
        system.debug('pageAction');
        string GLName = null;
        string GLId = null;
        
        User usr = [select Default_GL_Account_Variable__c from User where Id =: userinfo.getUserId() Limit 1];
        
        if(usr.Default_GL_Account_Variable__c != null){
            if(usr.Default_GL_Account_Variable__c.indexOf(';') > -1){
                
                GLName = usr.Default_GL_Account_Variable__c.split(';')[0];
                
            }else{
                GLName = usr.Default_GL_Account_Variable__c;
            }
        }
        
        if(GLName != null){
            
            List<AcctSeed__Accounting_Variable__c> avrs = [select id from AcctSeed__Accounting_Variable__c where name =: GLName Limit 1];
            
            if(!avrs.isEmpty()){               
                GLId = avrs[0].id;
            }
        }
        
        string redirectUrl = '/apex/PurchaseOrderRecordTypePage?retURL=/a15/o&GLVariable1='+GLName+'&glAccVar1Id='+GLId;
        
        PageReference page = new PageReference(redirectUrl);
        page.setRedirect(true);
        
        return recTypName == null ? page : null;
    }
    
    public string getGLAccountVariableForUser(string userId){
        
        string GLId = null;
        string GLName = null;
        
        User usr = [select Default_GL_Account_Variable__c from User where Id =: userId Limit 1];
        
        if(usr.Default_GL_Account_Variable__c != null){
            if(usr.Default_GL_Account_Variable__c.indexOf(';') > -1){
                
                GLName = usr.Default_GL_Account_Variable__c.split(';')[0];
                
            }else{
                GLName = usr.Default_GL_Account_Variable__c;
            }
        }
        
        if(GLName != null){
            
            List<AcctSeed__Accounting_Variable__c> avrs = [select id from AcctSeed__Accounting_Variable__c where name =: GLName Limit 1];
            
            if(!avrs.isEmpty()){               
                GLId = avrs[0].id;
            }
        }
        
        return GLId;
    }
    
    @RemoteAction
    public static Account getAccount(String accountId){
        Account acc = new Account();
        
        List<Account> accountData = [Select Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, 
                                     ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry 
                                     From Account Where Id = :accountId];           
        if(accountData.size() > 0){
            return accountData[0];
        } 
        return acc;
    }
    
    @RemoteAction
    public static Contact getContact(String accountId){
        Contact contact = new Contact();
        List<Account> accountData = [Select Id, Contact_Person__c
                                     From Account Where Id = :accountId];
        if(accountData.size() > 0){
            Id contactPersonId = accountData[0].Contact_Person__c;
            List<Contact> contactData =  [select id,MailingStreet,MailingCity, MailingState, MailingCountry, MailingPostalCode
                                          from Contact where Id =: contactPersonId limit 1];
            if(contactData.size() > 0){
                return contactData[0];
            }    
        }
        return contact;
    }
    
    Public PageReference saveOverride(){
        
        po.AcctSeedERP__Vendor_Contact__c = po.Vendor_Contact_Custom__c;
        if(!Test.isRunningTest()){
            insert po;
        }
        PageReference page = new PageReference('/'+po.id);
        page.setRedirect(true);
        
        return page;
    }
}