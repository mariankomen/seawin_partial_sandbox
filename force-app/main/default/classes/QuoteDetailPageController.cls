/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 08-02-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class QuoteDetailPageController {
    
    public class QuoteDetailPageControllerException extends Exception {}

    @AuraEnabled
    public static String getQuoteLineItems(String quoteId){
        try {
            List<QuoteLineItem> oliList = [SELECT Id, 
                                                    Product2.Name, 
                                                    Product2Id, 
                                                    Product2.Product_Image_Short_URL__c, 
                                                    Product2.ProductCode, 
                                                    Product2.RecordType.DeveloperName,
                                                    Product2.Available_Quantity__c,
                                                    Product2.Kit_Available_Quantity__c,
                                                    ITEM_DESCRIPTION__c, 
                                                    Description,
                                                    Size__c, 
                                                    Quantity, 
                                                    UnitPrice, 
                                                    TotalPrice 
                                                    FROM QuoteLineItem 
                                                    WHERE QuoteId=:quoteId ORDER BY SortOrder ASC];
            RelatedListWrapper wrapper = new RelatedListWrapper(oliList, oliList.size());
            return JSON.serialize(wrapper);
        } catch (Exception e) {
            throw new QuoteDetailPageControllerException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getOptionalQuoteLineItems(String quoteId){
        try {
            List<Optional_Products_Quote__c> optional = [SELECT Id,
                                                            Name,
                                                            Product__c,
                                                            Product__r.Name,
                                                            Product__r.Product_Image_Short_URL__c,
                                                            Product__r.ProductCode,
                                                            Quantity__c,
                                                            Item_Description__c,
                                                            Size__c,
                                                            UnitPrice__c,
                                                            TotalPrice__c
                                                            FROM Optional_Products_Quote__c
                                                            WHERE Quote__c=:quoteId ORDER BY SortOrder__c ASC];
            RelatedListWrapper wrapper = new RelatedListWrapper(optional, optional.size());
            return JSON.serialize(wrapper);
        } catch (Exception e) {
            throw new QuoteDetailPageControllerException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getLogginedUserInfo(){
        try {
            User u = [SELECT Id, Name, Profile.Name, Transfer_to_Optional__c FROM User WHERE Id=:UserInfo.getUserId()];
            return JSON.serialize(u);
        } catch (Exception e) {
            throw new QuoteDetailPageControllerException(e.getMessage());
        }
    }

    public class RelatedListWrapper{
        public List<SObject> sobjectList {get;set;}
        public Integer totalRecords {get;set;}

        public RelatedListWrapper(List<SObject> sobjectList, Integer totalRecords){
            this.sobjectList = sobjectList;
            this.totalRecords = totalRecords;
        }
    }


}