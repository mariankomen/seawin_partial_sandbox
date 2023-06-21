public class ShowBillingAging{
    public User objUser = new User();
    public Boolean recordsFound{get;set;}
    public String reportId{get;set;}
    public List<String> lstRegion{get;set;}
    public Map<String, Decimal> mapBillingAgeToBalanceDue{get; set;}
    
    public ShowBillingAging(){
        //variable initialization
        lstRegion = new List<String>();    
        mapBillingAgeToBalanceDue = new Map<String, Decimal>(); 
        recordsFound = true;
        reportId = '';
        
        // Get user gl variable
        objUser = [select default_gl_account_variable__c from user where id =: userinfo.getUserId() limit 1];
        
        if(objUser != null && objUser.default_gl_account_variable__c != null){
            lstRegion = objUser.default_gl_account_variable__c.split(';');
        }
        System.debug('lstRegion................'+lstRegion);
        
        //Fetch Billing records based on Login user's GL Variable.
        if(!lstRegion.isEmpty()){
            for(AcctSeed__Billing__c objBilling : [select id,AcctSeed__Status__c,AcctSeed__Balance__c,GL_Account_Variable_1__c,AcctSeed__Age__c from AcctSeed__Billing__c where AcctSeed__Status__c = 'Posted' AND AcctSeed__Balance__c > 0 AND GL_Account_Variable_1__c IN : lstRegion]){
                if(mapBillingAgeToBalanceDue.containsKey(objBilling.AcctSeed__Age__c)){
                    Decimal oldAmount = mapBillingAgeToBalanceDue.get(objBilling.AcctSeed__Age__c);
                    mapBillingAgeToBalanceDue.put(objBilling.AcctSeed__Age__c, (oldAmount + objBilling.AcctSeed__Balance__c));
                }else{
                    mapBillingAgeToBalanceDue.put(objBilling.AcctSeed__Age__c, objBilling.AcctSeed__Balance__c);
                }
            }
        }
        System.debug('mapBillingAgeToBalanceDue..............'+mapBillingAgeToBalanceDue);
        if(mapBillingAgeToBalanceDue.size() == 0){
            recordsFound = false;
        }
        
        //Fetch the Billing Ageing report id
        for(Report objReport : [SELECT Id,DeveloperName FROM Report WHERE DeveloperName = 'Billing_Ageing' LIMIT 1]){
            reportId = objReport.Id;
        }
    }
}