public class BillingDeleteExtension {
    
    Public string BillingId {get; set;}
    Public AcctSeed__Billing__c billing {get; set;}
    Public string RetURL {get; set;}
    Public String ErrorOccurred {get; set;}
    Public Boolean ErrorHasOccurred {get; set;}
    Public Boolean ErrorMsgClosedSO {get; set;}
    Public Boolean ErrorMsgBillingReceipt {get; set;}
    Public Boolean ErrorMsgBillingPosted {get; set;}
    public string tabname{get; set;}
    public string title{get; set;}
    
    //public string strTabName{get; set;}
    public string strTabName{get; set;}
    
    public BillingDeleteExtension(ApexPages.StandardController std){
        
        BillingId = ApexPages.currentPage().getParameters().get('delID');
        RetURL = ApexPages.currentPage().getParameters().get('retURL');
        
        if(RetURL.indexOf('?') > -1){
            System.debug(RetURL.split('\\?')[1]);
            
            String IDisThere = (RetURL.split('\\?')[1]).split('=')[0];
            if(IDisThere.IndexOf('id') > -1){

                Id objectId = (RetURL.split('\\?')[1]).split('=')[1].split('&')[0];
                tabname = ObjectId.getSObjectType().getDescribe().getName();
                title = ObjectId.getSObjectType().getDescribe().getLabel();
    
            }
            
        }else{
            tabname = 'AcctSeed__Billing__c';
            title = 'Billing';
        }
        
        ErrorMsgClosedSO = false;
        ErrorMsgBillingReceipt = false;
        ErrorMsgBillingPosted = false;
        strTabName = tabname;
        billing = [select id, AcctSeed__Status__c , AcctSeedERP__Sales_Order__c from 
                   AcctSeed__Billing__c where id =: BillingId limit 1];
              
    }
    
    public PageReference DeleteProcess(){

        PageReference page = new PageReference(RetURL);
        page.setRedirect(true);
        
        List<AcctSeedERP__Sales_Order__c> closedSO = [select id from AcctSeedERP__Sales_Order__c
                                                      where id =: billing.AcctSeedERP__Sales_Order__c and
                                                      AcctSeedERP__Status__c = 'Closed' Limit 1];
        
        LIST<AcctSeed__Billing_Cash_Receipt__c>  billingCashReceipt = [select id from AcctSeed__Billing_Cash_Receipt__c
                                                                       where AcctSeed__Billing__c =: billing.Id];
      
        if(closedSO.isEmpty()){ // no closed sales order
            if(billingCashReceipt.isEmpty()){ //no Billing cash receipt against billling
                if(billing.AcctSeed__Status__c != 'Posted'){ //Billing status is not posted
                    
                    try{
                        delete billing;
                       
                    }catch(Exception ex){

                        page = null;
                    }

                    return page;
                }else{
                    ErrorMsgBillingPosted = true;
                }
            }else{
                ErrorMsgBillingReceipt = true;
            }
        }
        
        else{
            
            ErrorMsgClosedSO = true;
        }
        
        return null;
    }
    
    public PageReference back(){
        
        if(tabname == 'AcctSeed__Billing__c')
        {
            RetURL = '/'+BillingId;
        }
        
        PageReference page = new PageReference(RetURL);
        System.debug('RetURL: ' + RetURL);
        page.setRedirect(true);
        return page;
    }

}