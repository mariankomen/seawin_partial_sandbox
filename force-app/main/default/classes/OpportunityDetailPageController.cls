/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-31-2023
 * @last modified by  : Marian Lyzhychka
**/
public without sharing class OpportunityDetailPageController extends OpportunityDetailPageService{
    
    public class OpportunityDetailPageControllerException extends Exception {}

    @AuraEnabled
    public static String getSobjectType(String recordId){
        return getSobjectTypeService(recordId);
    }

    @AuraEnabled
    public static String getOpportunitySubStages(){
        return getOpportunitySubStagesService();
    }

    @AuraEnabled
    public static string getOpportunity(String opportunityId){
        return getOpportunityService(opportunityId);
    }
    @AuraEnabled
    public static string getAccount(String accountId){
        return getAccountService(accountId);
    }

    @AuraEnabled
    public static String createBilling(String linesWrapperJson){
        return createBillingService(linesWrapperJson);
    }

    @AuraEnabled
    public static String getPreparedLineForBilling(String type, String recordId){
        return getPreparedLineForBillingService(type, recordId);
    }

    @AuraEnabled
    public static string getOpportunityStageValues(){
        return getOpportunityStageValuesService();
    }

    @AuraEnabled
    public static string getOpportunityRecordTypes(){
        return getOpportunityRecordTypesService();
    }

    @AuraEnabled
    public static string getOpportunityLineItems(String opportunityId){
        return getOpportunityLineItemsService(opportunityId);
    }

    @AuraEnabled
    public static string getOptionalOpportunityLines(String opportunityId){
        return getOptionalOpportunityLinesService(opportunityId);
    }
    @AuraEnabled
    public static void deleteSObjectList(String idList){
        deleteSObjectListService(idList);
    }

    @AuraEnabled
    public static string getOpportunityAttachments(String opportunityId){
        return getOpportunityAttachmentsService(opportunityId);
    }

    @AuraEnabled
    public static void transferExecutedDocumentsToAttachmets(String attachmentsJSON){
        transferExecutedDocumentsToAttachmetsService(attachmentsJSON);
    }

    @AuraEnabled
    public static void transferAttachmentsToExecutedDocuments(String attachmentsJSON){
        transferAttachmentsToExecutedDocumentsService(attachmentsJSON);
    }

    @AuraEnabled
    public static String getAttachmentRecord(String recordId){
        return getAttachmentRecordService(recordId);
    }

    @AuraEnabled
    public static void updateAttachmentRecord(String record){
        updateAttachmentRecordService(record);
    }
    
    @AuraEnabled
    public static String getPredefinedSalesOrderData(String opportunityId){
        return getPredefinedSalesOrderDataService(opportunityId);
    }

    @AuraEnabled
    public static Id createSalesOrder(String payload, String opportunityId){
        return createSalesOrderService(payload, opportunityId);
    }
}