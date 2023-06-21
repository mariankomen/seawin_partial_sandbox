public class AccountCreateExtension {
    
    Private User Usr {get; set;}
    Public String glValue {get; set;}
    Public Account acct {get; set;}
    Public string retURL {get; set;}
    Public string isSelectScreen {get; set;}
    Public string salesrepid {get; set;}
    Public string ownerid {get; set;}

    // Initialize a list to hold any duplicate records
    private List<sObject> duplicateRecords;
    
    // Define variable that’s true if there are duplicate records
    public boolean hasDuplicateResult{get;set;}

    // Return duplicate records to the Visualforce page for display
    public List<sObject> getDuplicateRecords() {
        return this.duplicateRecords;
    }
    
    public AccountCreateExtension(ApexPages.StandardController std){

        retURL = ApexPages.currentPage().getParameters().get('retURL');
        isSelectScreen = ApexPages.currentPage().getParameters().get('isSelectScreen');
        ownerid = ApexPages.currentPage().getParameters().get('ownerid');
        salesrepid = ApexPages.currentPage().getParameters().get('salesrepid');

        // Initialize empty list of potential duplicate records
        this.duplicateRecords = new List<sObject>();
        this.hasDuplicateResult = false;

        acct = Test.isRunningTest() ? (Account)std.getRecord() : new Account();

        List<AcctSeed__Accounting_Variable__c> avrs = [Select id,name from AcctSeed__Accounting_Variable__c];

        map<string, id> avrsMap = new map<string, id>(); 

        if(!avrs.isEmpty()){
           
            for(AcctSeed__Accounting_Variable__c avr : avrs){

                avrsMap.put(avr.name, avr.id);
            }

        }

        Usr = [select id, Default_GL_Account_Variable__c from User where Id =: UserInfo.getUserId() Limit 1];
        
        List<String> PickListValues = new List<String>();
        
        if(Usr.Default_GL_Account_Variable__c != null){
            
            PickListValues.addAll(Usr.Default_GL_Account_Variable__c.Split(';'));
        }

        if(PickListValues.Size() == 1){
            glValue = PickListValues[0];
        }else{
            glValue = null;
        }

        if(isSelectScreen != null){

            acct.sales_rep_o__c = salesrepid;
            acct.ownerid = ownerid;

        }

        acct.AcctSeed__GL_Account_Variable_1__c = avrsMap.get(glValue);
    }

    public PageReference RedirectToSalesRepPage(){

        PageReference page = null;
        
        if(isSelectScreen == null){
            page = new PageReference('/apex/AccountSalesRepPage?retURL=/001/o');
            page.setRedirect(true);

        }

        return page;
    }

    public PageReference Save(){

        PageReference page = null;

        try{

            insert acct;

            page = new PageReference('/' + acct.id);
            page.setRedirect(true);

        }catch(Exception ex){

            DupeCheck(acct, ex);
        }

        return page;
    }

    public PageReference SaveAndNew(){
        
        PageReference page = null;

        try{

            insert acct;
            
            page = new PageReference('/apex/AccountCreatePage?retURL=/001/o&sfdc.override=1');
        	page.setRedirect(true);

        }catch(Exception ex){

            DupeCheck(acct, ex);
            
        }

        return page;
    }

    public PageReference Save_Alert(){

        PageReference page = null;

        Database.SaveResult saveResult = null;

        try{


            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            saveResult = Database.insert(acct, dml);

            page = new PageReference('/' + saveResult.id);
            page.setRedirect(true);

        }catch(Exception ex){

            ShowErrorMessage(ex);
        }

        return page;
    }

    public PageReference SaveAndNew_Alert(){
        
        PageReference page = null;

        Database.SaveResult saveResult = null;

        try{

            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = true;
            dml.DuplicateRuleHeader.runAsCurrentUser = true;
            saveResult = Database.insert(acct, dml);
            
            page = new PageReference('/apex/AccountCreatePage?retURL=/001/o&sfdc.override=1');
        	page.setRedirect(true);

        }catch(Exception ex){
            
            ShowErrorMessage(ex);
        }

        return page;
    }

    public void DupeCheck(Account acct, Exception ex){

        String errorMsg = ex.getMessage();

        errorMsg = errorMsg.substringBetween(', ', ':');

        if(errorMsg != null && errorMsg.contains('duplicate')){

            Database.SaveResult saveResult = Database.insert(acct, false);

            if (!saveResult.isSuccess()) {
                for (Database.Error error : saveResult.getErrors()) {
                    // If there are duplicates, an error occurs
                    // Process only duplicates and not other errors 
                    //   (e.g., validation errors)
                    if (error instanceof Database.DuplicateError) {
                        // Handle the duplicate error by first casting it as a 
                        //   DuplicateError class
                        // This lets you use methods of that class 
                        //  (e.g., getDuplicateResult())
                        Database.DuplicateError duplicateError = 
                                (Database.DuplicateError)error;
                        Datacloud.DuplicateResult duplicateResult = 
                                duplicateError.getDuplicateResult();
                        
                        // Display duplicate error message as defined in the duplicate rule
                        ApexPages.Message errorMessage = new ApexPages.Message(
                                ApexPages.Severity.ERROR, 'Duplicate Error: ' + 
                                duplicateResult.getErrorMessage());
                        ApexPages.addMessage(errorMessage);
                        
                        // Get duplicate records
                        this.duplicateRecords = new List<sObject>();
    
                        // Return only match results of matching rules that 
                        //  find duplicate records
                        Datacloud.MatchResult[] matchResults = 
                                duplicateResult.getMatchResults();
    
                        // Just grab first match result (which contains the 
                        //   duplicate record found and other match info)
                        Datacloud.MatchResult matchResult = matchResults[0];
    
                        Datacloud.MatchRecord[] matchRecords = matchResult.getMatchRecords();
    
                        // Add matched record to the duplicate records variable
                        for (Datacloud.MatchRecord matchRecord : matchRecords) {
                            System.debug('MatchRecord: ' + matchRecord.getRecord());
                            this.duplicateRecords.add(matchRecord.getRecord());
                        }
                        this.hasDuplicateResult = !this.duplicateRecords.isEmpty();
                    }
                }
            }

        }else if(errorMsg != null){

            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
            ApexPages.addMessage(myMsg);
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0));
            ApexPages.addMessage(myMsg);
        }

        system.debug(ex.getMessage());
        
    }

    public void ShowErrorMessage(Exception ex){

        String errorMsg = ex.getMessage();

        errorMsg = errorMsg.substringBetween(', ', ':');

        if(errorMsg != null){

            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
            ApexPages.addMessage(myMsg);
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDMLMessage(0));
            ApexPages.addMessage(myMsg);
        }

        system.debug(ex.getMessage());

    }
}