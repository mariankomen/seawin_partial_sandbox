public class OpportunityCreateExtension {
    
    public Opportunity opp {get; set;}
    public string acctId {get; set;}
    public string recordtypeid {get; set;}
    public string gl {get; set;}
    public string RecordTypeName {get; set;}
    
    public OpportunityCreateExtension(ApexPages.StandardController std){
        
        string ownerid = ApexPages.currentPage().getParameters().get('ownerid');
        string salesrepid = ApexPages.currentPage().getParameters().get('salesrepid');
        acctId = ApexPages.currentPage().getParameters().get('acctId');
        recordtypeid = ApexPages.currentPage().getParameters().get('recordtypeid');
        gl = ApexPages.currentPage().getParameters().get('gl');
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        retURL = retURL.replace('/', '');
        
        Id polymorphicId = (Id)retURL;
        
        opp = new Opportunity();
        Contact con = new Contact();
        
        String fieldsStr = AllFields.Fields('Account', new List<String>());
        
        Account acct = new Account();

        string defaultLeadSource = null;

        if(polymorphicId.getSObjectType().getDescribe().getName() == 'Contact'){
            con = [select id, LeadSource
                           from Contact
                           where id =: polymorphicId];
        }
        
        // If there is account
        if(!String.isEmpty(acctId)){
            
            acct = Database.query('select ' + fieldsStr + ' from Account where id=:acctId Limit 1');
            
            //opp.LeadSource = polymorphicId.getSObjectType().getDescribe().getName() == 'Contact' ? acct.Contact_Lead_Source__c;
            opp.Price_Level__c = acct.Price_Level__c;
            opp.accountId = acctId;
            opp.Shipping_Account__c = acctId;
            opp.Shipping_Name__c = acct.AcctSeed__Shipping_Contact__c;
            opp.Shipping_Street__c = acct.ShippingStreet;
            opp.Shipping_City__c = acct.ShippingCity;
            opp.Shipping_State__c = acct.ShippingState;
            opp.Shipping_PostalCode__c = acct.ShippingPostalCode;
            opp.Shipping_Country__c = acct.ShippingCountry;
            opp.Manufacturer_Rep__c = acct.Manufacture_Representative__c;
            opp.Billing_Terms_Name__c = acct.AcctSeed__Billing_Terms_Name__c;
            opp.Billing_Deposit__c = acct.Deposit__c;
            //opp.ContactPerson__c = polymorphicId.getSObjectType().getDescribe().getName() == 'Contact' ? 
            //polymorphicId : acct.Contact_Person__c;
            
        }
            
            
        // opp.LeadSource = polymorphicId.getSObjectType().getDescribe().getName() == 'Contact' ? 
        // con.LeadSource : acct.Contact_Lead_Source__c;
        opp.ContactPerson__c = polymorphicId.getSObjectType().getDescribe().getName() == 'Contact' ? 
        con.Id : acct.Contact_Person__c;
        
        RecordTypeName = Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(recordtypeid).getName();
        opp.RecordTypeId = recordtypeid;
        opp.Sales_Rep_O__c = salesrepid;
        opp.ownerid = ownerid;
        
        if(!String.isEmpty(gl))
            opp.GL_Account_Variable_1__c = gl;
        
    }
    
    public PageReference saveOverride(){
        
        Pagereference page = null;
        
        try{
            insert opp;
            
            page = new Pagereference('/'+opp.id);
            page.setRedirect(true);

        }catch(Exception ex){
            
            String errorMsg = ex.getMessage();

            if(!errorMsg.contains('Duplicate opportunity')){

                string OnlyMsg = errorMsg.substringBetween(', ', ':');

                if(OnlyMsg != null){

                    OnlyMsg = OnlyMsg.capitalize();

                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, OnlyMsg);
                    ApexPages.addMessage(myMsg);
                }else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
                    ApexPages.addMessage(myMsg);
                }
            }

            system.debug('Exception has occured: ');
            system.debug(ex.getMessage());
        }
        
        return page;
    }
}