public with sharing class AddSalesOrderPageExtension {

    public AcctSeedERP__Sales_Order__c so {get; set;}

    public String retURL {get; set;}
    public string OppId {get; set;}
    public string acctId {get; set;}
    public string ctId {get; set;}
    public string RecordTypeId {get; set;}

    public AddSalesOrderPageExtension(ApexPages.StandardController std) {

        String ownerid = ApexPages.currentPage().getParameters().get('ownerid');
        String salesrepid = ApexPages.currentPage().getParameters().get('salesrepid');

        retURL = ApexPages.currentPage().getParameters().get('retURL');
        oppId = ApexPages.currentPage().getParameters().get('oppId');
        acctId = ApexPages.currentPage().getParameters().get('acctId');
        ctId = ApexPages.currentPage().getParameters().get('ctId');
        RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');

        Opportunity opp = new Opportunity();
        Account acct = new Account();
        Contact ct = new Contact();
        so = new AcctSeedERP__Sales_Order__c();

        String fieldstr = 'name';

        if(!String.isEmpty(acctId)){

            fieldstr = AllFields.Fields('Account', new List<String>());
            acct = Database.query('Select ' + fieldstr + ' from Account where id=:acctId Limit 1');

            so.AcctSeedERP__Customer__c = acct.id;
            // so.Shipping_Term__c
            so.Contact__c = acct.Contact_Person__c;
            so.Shipping_Account__c = acct.id;
            so.Shipping_Name__c = acct.AcctSeed__Shipping_Contact__c;
            so.AcctSeedERP__Shipping_Street__c = acct.ShippingStreet;
            so.AcctSeedERP__Shipping_City__c = acct.ShippingCity;
            so.AcctSeedERP__Shipping_State__c = acct.ShippingState;
            so.AcctSeedERP__Shipping_PostalCode__c = acct.ShippingPostalCode;
            so.AcctSeedERP__Shipping_Country__c = acct.ShippingCountry;
            so.Billing_Account__c = acct.id;
            so.Billing_Name__c = acct.AcctSeed__Billing_Contact__c;
            so.AcctSeedERP__Billing_Street__c = acct.BillingStreet;
            so.AcctSeedERP__Billing_City__c = acct.BillingCity;
            so.AcctSeedERP__Billing_State__c = acct.BillingState;
            so.AcctSeedERP__Billing_PostalCode__c = acct.BillingPostalCode;
            so.AcctSeedERP__Billing_Country__c = acct.BillingCountry;
            so.GL_Account_Variable_1__c = acct.AcctSeed__GL_Account_Variable_1__c;
            so.Manufacturer_Rep__c = acct.Manufacture_Representative__c;
            // so.Project__c 
            so.Price_Level__c = acct.Price_Level__c;
        }

        if(!String.isEmpty(oppId)){
            fieldstr = AllFields.Fields('Opportunity', new List<String>());
            opp = Database.query('Select ' + fieldstr + ' from Opportunity where id=:oppId Limit 1');

            // so.AcctSeedERP__Customer__c =
            so.Shipping_Term__c = opp.Shipping_Term__c;
            so.Contact__c = opp.ContactPerson__c;
            so.Shipping_Account__c = opp.Shipping_Account__c;
            so.Shipping_Name__c = opp.Shipping_Name__c;
            so.AcctSeedERP__Shipping_Street__c = opp.Shipping_Street__c;
            so.AcctSeedERP__Shipping_City__c = opp.Shipping_City__c;
            so.AcctSeedERP__Shipping_State__c = opp.Shipping_State__c;
            so.AcctSeedERP__Shipping_PostalCode__c = opp.Shipping_PostalCode__c;
            so.AcctSeedERP__Shipping_Country__c = opp.Shipping_Country__c;
            so.LeadSource__c = opp.LeadSource;
            // so.Billing_Account__c = 
            // so.Billing_Name__c = 
            // so.AcctSeedERP__Billing_Street__c = 
            // so.AcctSeedERP__Billing_City__c = 
            // so.AcctSeedERP__Billing_State__c = 
            // so.AcctSeedERP__Billing_PostalCode__c = 
            // so.AcctSeedERP__Billing_Country__c
            so.GL_Account_Variable_1__c = opp.GL_Account_Variable_1__c;
            so.Project__c = opp.Project__c;
            so.Price_Level__c = opp.Price_Level__c;

        }

        if(!String.isEmpty(ctId)){

            fieldstr = AllFields.Fields('Contact', new List<String>());
            
ct = Database.query('Select ' + fieldstr + ' ,account.Manufacture_Representative__c from Contact where id=:ctId Limit 1');

            so.Contact__c = ct.id;
            so.GL_Account_Variable_1__c = so.GL_Account_Variable_1__c == null ? ct.GL_Account_Variable_1__c : 
            so.GL_Account_Variable_1__c;
            
            so.manufacturer_rep__c =  ct.account.Manufacture_Representative__c;
        
        }

        if(so.GL_Account_Variable_1__c == null) so.GL_Account_Variable_1__c = getGLAccountVariableForUser(userinfo.getuserid());
        so.RecordTypeId = RecordTypeId;
        so.Sales_Rep_O__c = salesrepid;
        so.ownerid = ownerid;

        AcctSeed__Ledger__c ledger = [Select id from AcctSeed__Ledger__c where name = 'Actual' Limit 1];

        so.AcctSeedERP__Ledger__c = ledger.id;

        //so = new AcctSeedERP__Sales_Order__c();
        //so = (AcctSeedERP__Sales_Order__c)std.getRecord();
        //so.GL_Account_Variable_1__c = getGLAccountVariableForUser(UserInfo.getUserId());
    }

    public PageReference RedirectToRecordTypeSelectScreen(){

        PageReference page = null;

        String url = '';

        if(String.isEmpty(RecordTypeId)){ 

            url = '/setup/ui/recordtypeselect.jsp?ent=01I1I000002AYXO&retURL='+retURL+'&save_new_url=';
            url += '/apex/SalesOrderSalesRepPage%3F';
            url += 'retURL='+retURL;

            page = new PageReference(url);
            page.setRedirect(true);

        }

        return page;
        
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
            
            List<AcctSeed__Accounting_Variable__c> avrs = [select id from AcctSeed__Accounting_Variable__c 
            where name =: GLName Limit 1];
            
            if(!avrs.isEmpty()){               
                GLId = avrs[0].id;
            }
        }

        return GLId;
    }


    @RemoteAction
    public static Account getAccount(String accountId){

        Account acc = new Account();
        List<Account> accountData = [Select Name, BillingStreet, BillingCity, BillingState, 
        BillingPostalCode, BillingCountry, ShippingStreet, ShippingCity, ShippingState, 
        ShippingPostalCode, ShippingCountry, (Select Id, Name From Contacts) From Account 
        Where Id = :accountId];
        
        if(accountData.size() > 0){
            return accountData[0];
        }

        return acc;
    }

    public PageReference saveOverride(){

        PageReference page = null;

        try{

            insert so;

            page = new PageReference('/' + so.id);

        }catch(Exception ex){

            system.debug(ex.getMessage());
            page = new PageReference(retURL);
       }

        page.setRedirect(true);

        return page;

    }
    
}