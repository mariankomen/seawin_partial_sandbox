public class CreateProjectExtension {
    
    public AcctSeed__project__c project {get; set;}
    
    public Id objectId {get; set;}
    public String retUrl {get; set;}
    
    public String redirectTo {get; set;}
    
    public String section {get; set;}
    
    public Boolean showSoAlert {get; set;}
    public Boolean showPoAlert {get; set;}
    public Boolean existsAlert {get; set;}
    public Boolean showAccount {get; set;}
    public Boolean showNothing {get; set;}
    
    public list<Opportunity> opty {get; set;}
    
    public String getStrTabName(){ 
        if(section =='Op'){ return 'Opportunity';}else if(section == 'Acct'){ return 'Account';}
        else if(section == 'Contct'){ return 'Contact';}
        else if(section == 'So'){ return 'AcctSeedERP__Sales_Order__c';}
        else if(section == 'Po'){ return 'AcctSeedERP__Purchase_Order__c';}else {
            
            return null; 
        }
    }
    
    public CreateProjectExtension(ApexPages.StandardController std){
        project = new AcctSeed__project__c();
        showSoAlert = false;
        showPoAlert = false;
        existsAlert = false;
        showAccount = true;
        showNothing = false;
        opty = new list<opportunity>();
        
        // if the id parameter is set
        retUrl = ApexPages.currentPage().getParameters().get('id');
        
        if(retUrl == null || retUrl == ''){
            //for account and contact
            retUrl = ApexPages.currentPage().getParameters().get('retURL');
            
        }
        
        if(retUrl == null || retUrl == ''){
            // for sales order page button
            retUrl = ApexPages.currentPage().getParameters().get('recordid');
        }
        
        try{
            
            objectId = (retUrl.indexOf('/') != -1) ? retUrl.remove('/') : retUrl; 
            
        }catch(Exception ex){
            
        }
        
        if(objectId != null){
            
            // get the object label by id
            String objName = objectName(objectId);
            
            DescribeSObjectResult dOp = SObjectType.Opportunity;
            String OpLabel = dOp.getLabel();
            
            DescribeSObjectResult dAcct = SObjectType.Account;
            String AcctLabel = dAcct.getLabel();
            
            DescribeSObjectResult dCt = SObjectType.Contact;
            String CtLabel = dCt.getLabel();
            
            DescribeSObjectResult dSo = SObjectType.AcctSeedERP__Sales_Order__c;
            String SoLabel = dSo.getLabel();
            
            DescribeSObjectResult dPo = SObjectType.AcctSeedERP__Purchase_Order__c;
            String PoLabel = dPo.getLabel();
            
            if(objName == OpLabel){
                
                // check if project exists for this opportunity

                if(ApexPages.currentPage().getParameters().get('project') != ''){
                    
                    String pID = ApexPages.currentPage().getParameters().get('project');
                    
                    list<AcctSeed__project__c> projectExists = [select id, name from AcctSeed__Project__c where
                                                            id=:pID limit 1];
                    
                    if(!projectExists.isEmpty()){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 
                                                               'A project exists for this opportunity. The project name is: ' +
                                                               projectExists[0].name + '. To assign a different project '+
                                         						'use the project field on opportunity.'));
                    	showNothing = true;
                        
                    }
                }
                
                // get info from opportunity
                opty = [select accountId, contactperson__c from opportunity where id =:objectId limit 1];
                
                if(!opty.IsEmpty()){
                    if(opty[0].accountId == null){
                        showAccount = false;
                        
                    }else{
                        project.AcctSeed__Account__c = opty[0].accountId;
                        
                    }
                    
                    project.Contact__c = opty[0].contactperson__c;                    
                    
                }
                section = 'Op';
            }else if(objName == AcctLabel){
                
                // get info from account
                list<Account> acct = [select contact_person__c from account where id =:objectId limit 1];
                
                if(!acct.IsEmpty()){
                    if(acct[0].contact_person__c != null){
                        project.Contact__c = acct[0].contact_person__c;                    
                    }
                }
                
                project.AcctSeed__Account__c = objectId; 
                section = 'Acct';
            }else if(objName == CtLabel){
                
                // get info from contact
                list<Contact> cntct = [select accountId from Contact where id =:objectId limit 1];
                
                if(!cntct.IsEmpty()){
                    if(cntct[0].accountId != null){
                        project.AcctSeed__Account__c = cntct[0].accountId;                    
                    }
                }
                
                project.Contact__c = objectId; 
                section = 'Contct';
            }else if(objName == SoLabel){
                showSoAlert = true;
                section = 'So';
                if(ApexPages.currentPage().getParameters().get('project') != ''){
                    
                    existsAlert = true;
                }
                
                if(ApexPages.currentPage().getParameters().get('contact') != ''){
                    project.Contact__c = ApexPages.currentPage().getParameters().get('contact');                   
                }
                if(ApexPages.currentPage().getParameters().get('account') != ''){
                    project.AcctSeed__Account__c = ApexPages.currentPage().getParameters().get('account');                    
                }else{
                    showAccount = false;
                }
            }else if(objName == PoLabel){
                showPoAlert = true;
                section = 'Po';
                
                list<AcctSeedERP__Purchase_order__c> po = [select id, sales_order__c, sales_order__r.AcctSeederp__customer__c,
                                                           sales_order__r.contact__c from
                                                           Acctseederp__purchase_order__c where id =:objectId];
                
                if(!po.isEmpty()){
                    if(po[0].sales_order__c != null){
                        if(po[0].sales_order__r.contact__c != null){
                            
                            project.contact__c = po[0].sales_order__r.contact__c; 
                        }
                        
                        
                        if(po[0].sales_order__r.AcctSeederp__customer__c == null){
                            showAccount = false;
                        }else{
                            
                            project.AcctSeed__account__c = po[0].sales_order__r.AcctSeederp__customer__c;
                        }
                    }else{
                        
                        if(ApexPages.currentPage().getParameters().get('contact') != ''){
                            project.Contact__c = ApexPages.currentPage().getParameters().get('contact');                   
                        }
                        
                        if(ApexPages.currentPage().getParameters().get('account') != ''){
                    		project.AcctSeed__account__c = ApexPages.currentPage().getParameters().get('account');                    
                        }else{
                            
                            showAccount = false;
                        }
                    }
                }
                
                if(ApexPages.currentPage().getParameters().get('project') != ''){
                    
                    existsAlert = true;
                }
            }
        }
        project.Project_Manager__c = UserInfo.getUserId();
        project.Project_Date__c = date.today();
        
        redirectTo = (retUrl.indexOf('/') != -1) ? retUrl : '/' + retUrl;
    }
    
    public static string objectName(Id objectId){
        
        Schema.SObjectType sobjectInfo = objectId.getSObjectType();
        String sobjectName = sobjectInfo.getDescribe().getLabel();
        
        return sobjectName;
    }
    
    public PageReference createRecord(){
        
        // check if there is no account and no contact provided
        if(Project.AcctSeed__Account__c == null && Project.Contact__c == null){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'Atleast an account or a contact is required for a project.'));
            return null;
        }
        Acctseed__project__c p = new Acctseed__project__c();
        
        p = ProcessProject();

        PageReference page = null;
        
        if(p == null){
            
            page = new PageReference(redirectTo);  
        }else{
            
            page = new PageReference('/' + p.id);  
        }
        
        page.setRedirect(true);
        
        return page;
    }
    
    public PageReference newRecord(){
        
        
        // check if there is no account and no contact provided
        if(Project.AcctSeed__Account__c == null && Project.Contact__c == null){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'Atleast an account or a contact is required for a project.'));
            return null;
        }
        Acctseed__project__c p = new Acctseed__project__c();
        
        ProcessProject();
        
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, Project.name + ' project has been created.'));
        
        project = new AcctSeed__Project__c();
        
        Project.name = null;
        Project.AcctSeed__Account__c = null;
        project.Contact__c = null;
        
        return null;
    }
    
    public Acctseed__project__c ProcessProject(){
        
        opty = new list<Opportunity>([select accountId, contactperson__c 
                                      from opportunity where id =:objectId limit 1]);
        
      Savepoint sp = Database.setSavepoint(); 
      try{
            
            insert project;
            
            // so
            list<AcctseedERP__Sales_order__c> slist = new list<AcctseedERP__Sales_order__c>();
            
            if(section == 'So'){
                
                slist = [select id, project__c from AcctseedERP__Sales_Order__c
                         where id =: ObjectId limit 1];
                
            }else if(section == 'Po'){
                
                // get the sales order id for this purchase order
                AcctSeederp__purchase_order__c po = [select project__c, Sales_order__c                                                         
                                                     from Acctseederp__purchase_order__c
                                                     where id =:objectId limit 1];
                po.Project__c = project.id;
                update po;
                
                if(po.Sales_order__c != null){
                    AcctSeederp__sales_order__c sale = [select project__c from AcctSeederp__sales_order__c
                                                        where id =:po.Sales_order__c limit 1];
                    
                    sale.Project__c = project.id;
                    
                    update sale;
                }
                
                
            }else if(section == 'Op'){
                slist = [select id, project__c from AcctseedERP__Sales_Order__c
                         where AcctSeedERP__opportunity__c =:objectId];
            }
            
            if(!slist.IsEmpty()){
                
                // so 
                set<id> soIds = new set<id>();
                
                string projectname = '';
                for(AcctSeedERP__Sales_Order__c so : slist){
                    
                    so.Project__c = project.id;
                    
                }
                
                update slist;
                
            }
           
           if(!opty.isEmpty()){
				
				opty[0].Project__c = project.id;
               opty[0].Run_Validation_Rule__c = true;
        		update opty;               
               
           }
            
            return project;

        }catch(Exception ex){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
       }
        return null;
    }
    
    public PageReference cancelRecord(){
        
        PageReference page = new PageReference('/a0k/o');
        
        if(objectId != null){
            page = new PageReference('/' + objectId);
        }
        page.setRedirect(true);
        
        return page;
    }
}