@isTest
public class PurchaseOrderAutoReceiveControllerTest {
    
    @TestSetup static void createData(){
        
        TestUtility.CreateData();
    }
    
    @isTEst static void runTest(){
        
        Opportunity op = [select id from opportunity where name = 'myOpportunity' limit 1];
        
        acctseederp__sales_order__c so = [select id from acctseederp__sales_order__c where acctseederp__opportunity__c
                                         =:op.id limit 1];
        
        acctseederp__purchase_order__c po = [select id from acctseederp__purchase_order__c where sales_order__c =: so.id
                                            limit 1];
        
     
        ApexPages.currentPage().getParameters().put('id', po.id);
        
       	PurchaseOrderAutoReceiveController atr = new PurchaseOrderAutoReceiveController();
        
        atr.PageAction();
        atr.back();
        
    }
}