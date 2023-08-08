/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-28-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class SalesOrderDetailPageController extends SalesOrderDetailPageService{
    
    
    @AuraEnabled
    public static string getLogginedUserProfile(){
        return getLogginedUserProfileService();
    }
    
    @AuraEnabled
    public static string getSalesOrderLines(String salesOrderId){
        return getSalesOrderLinesService(salesOrderId);
    }
    @AuraEnabled
    public static string getSalesOrder(String salesOrderId){
        return getSalesOrderService(salesOrderId);
    }

    @AuraEnabled
    public static string createBilling(String linesWrapperJson){
        return createBillingService(linesWrapperJson);
    }
    
}