/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 08-08-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class SObjectSortController {

    public class SObjectSortControllerException extends Exception {}

    private static final Map<String, String> QUOTE_LINE_ITEMS_MAPPING = new Map<String, String>{
        'productApi' => 'Product2',
        'productName' => 'Product2.Name',
        'productImageUrl' => 'Product2.Product_Image_Short_URL__c',
        'quantity' => 'Quantity',
        'salesPrice' => 'UnitPrice',
        'description' => 'ITEM_DESCRIPTION__c',
        'size' => 'Size__c',
        'image' => 'Product_Image_Short_URL__c'
    };

    private static final Map<String, String> QUOTE_OPTIONAL_LINE_ITEMS_MAPPING = new Map<String, String>{
        'productApi' => 'Product__r',
        'productName' => 'Product__r.Name',
        'productImageUrl' => 'Product__r.Product_Image_Short_URL__c',
        'quantity' => 'Quantity__c',
        'salesPrice' => 'UnitPrice__c',
        'description' => 'Item_Description__c',
        'size' => 'Size__c',
        'image' => 'Product_Image_Short_URL__c'
    };

    private static final Map<String, String> OPPORTUNITY_LINE_ITEMS_MAPPING = new Map<String, String>{
        'productApi' => 'Product2',
        'productName' => 'Product2.Name',
        'productImageUrl' => 'Product2.Product_Image_Short_URL__c',
        'quantity' => 'Quantity',
        'salesPrice' => 'UnitPrice',
        'description' => 'Item_Description__c',
        'size' => 'Size__c',
        'image' => 'Product_Image_Short_URL__c'
    };

    private static final Map<String, String> OPPORTUNITY_OPTIONAL_LINE_ITEMS_MAPPING = new Map<String, String>{
        'productApi' => 'Product__r',
        'productName' => 'Product__r.Name',
        'productImageUrl' => 'Product__r.Product_Image_Short_URL__c',
        'quantity' => 'Quantity__c',
        'salesPrice' => 'UnitPrice__c',
        'description' => 'Item_Description__c',
        'size' => 'Size__c',
        'image' => 'Product_Image_Short_URL__c'
    };

    private static final Map<String, String> SALES_ORDER_LINE_ITEMS_MAPPING = new Map<String, String>{
        'productApi' => 'AcctSeedERP__Product__r',
        'productName' => 'AcctSeedERP__Product__r.Name',
        'productImageUrl' => 'AcctSeedERP__Product__r.Product_Image_Short_URL__c',
        'quantity' => 'AcctSeedERP__Quantity_Ordered__c',
        'salesPrice' => 'AcctSeedERP__Unit_Price__c',
        'description' => 'Item_Description__c',
        'size' => 'Size__c',
        'image' => 'Product_Image_Short_URL__c'
    };


    private static Map<String, Map<String,String>> SOBJECTS_MAPPING = new Map<String, Map<String, String>>{
        'QuoteLineItem' => QUOTE_LINE_ITEMS_MAPPING,
        'Optional_Products_Quote__c' => QUOTE_OPTIONAL_LINE_ITEMS_MAPPING,
        'OpportunityLineItem' => OPPORTUNITY_LINE_ITEMS_MAPPING,
        'Optional_Products_Opportunity__c' => OPPORTUNITY_OPTIONAL_LINE_ITEMS_MAPPING,
        'AcctSeedERP__Sales_Order_Line__c' => SALES_ORDER_LINE_ITEMS_MAPPING
    };


    @AuraEnabled
    public static String getLinesForSorting(String payload){
        try {
            PayloadWrapper payl = (PayloadWrapper)JSON.deserialize(payload, PayloadWrapper.class);
            Map<String, String> fieldsMapping = SOBJECTS_MAPPING.get(payl.sobjectName);
            List<String> fields = fieldsMapping.values();
            String queryFields = '';

            for(String field: fields){
                if(field != 'Product2' && field != 'Product__r' && field != 'AcctSeedERP__Product__r' && field != 'Product_Image_Short_URL__c'){
                    queryFields += ' ' + field + ',';
                }
            }
            system.debug(4);
            String query = 'SELECT Id, ' + queryFields +payl.sortOrderFieldApi;
            query += ' FROM ' + payl.sobjectName + ' WHERE ' + payl.parentSObjectFieldApi + ' = \'' + payl.parentRecordId + '\' ORDER BY ' + payl.sortOrderFieldApi;
            system.debug(query);
            List<SObject> records = Database.query(query);
            List<SortItem> sortItemsWrapperList = new List<SortItem>();
            system.debug(45);
            for(SObject sobj: records){
                system.debug(JSON.serialize(sobj));
                Map<String, Object> sobjSerialized = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sobj));
                Map<String, Object> sobjSerializedProduct = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(sobjSerialized.get(fieldsMapping.get('productApi'))));
                system.debug('sobjSerializedProduct: '+sobjSerializedProduct);
                sortItemsWrapperList.add(new SortItem(
                    (Id)sobj.get('Id'),
                    String.valueOf(sobjSerializedProduct.get('Name')),
                    (Decimal)sobj.get(fieldsMapping.get('quantity')),
                    (Decimal)sobj.get(fieldsMapping.get('salesPrice')),
                    String.valueOf(sobj.get(fieldsMapping.get('description'))),
                    String.valueOf(sobj.get(fieldsMapping.get('size'))),
                    String.valueOf(sobjSerializedProduct.get(fieldsMapping.get('image')))
                ));
            }
            system.debug('sortItemsWrapperList: '+JSON.serialize(sortItemsWrapperList));
            return JSON.serialize(sortItemsWrapperList);
        } catch (Exception e) {
            system.debug(e.getMessage());
            throw new SObjectSortControllerException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void handleSaveSorting(String linesJson, String payload){
        try {
            PayloadWrapper payl = (PayloadWrapper)JSON.deserialize(payload, PayloadWrapper.class);
            String query = 'SELECT Id, ' + payl.sortOrderFieldApi;
            query += ' FROM ' + payl.sobjectName + ' WHERE ' + payl.parentSObjectFieldApi + ' = \'' + payl.parentRecordId + '\' ORDER BY ' + payl.sortOrderFieldApi;
            Map<Id, SObject> recordsMap = new Map<Id, SObject>(Database.query(query));

            List<LinesSortWrapper> linesParsed = (List<LinesSortWrapper>)JSON.deserialize(linesJson, List<LinesSortWrapper>.class);

            for(LinesSortWrapper line: linesParsed){
                if(recordsMap.containsKey(line.lineId)){
                    recordsMap.get(line.lineId).put(payl.sortOrderFieldApi, line.sortOrder);
                }
            }

            update recordsMap.values();
        } catch (Exception e) {
            throw new SObjectSortControllerException(e.getMessage());
        }
    }

    public class LinesSortWrapper{
        public Id lineId {get;set;}
        public Integer sortOrder {get;set;}

        public LinesSortWrapper(Id lineId, Integer sortOrder){
            this.lineId = lineId;
            this.sortOrder = sortOrder;
        }
    }
    public class PayloadWrapper{
        public String sobjectName {get;set;}
        public String parentSObjectName {get;set;}
        public String parentRecordId {get;set;}
        public String parentSObjectFieldApi {get;set;}
        public String datatableFields {get;set;}
        public String sortOrderFieldApi {get;set;}
    }

    public class SortItem {
        public Id lineId {get;set;}
        public String productName {get;set;}
        public Decimal quantity {get;set;}
        public Decimal salesPrice {get;set;}
        public String description {get;set;}
        public String size {get;set;}
        public String imageUrl {get;set;}

        public SortItem(Id lineId, String productName, Decimal quantity, Decimal salesPrice, String description, String size, String imageUrl){
            this.lineId = lineId;
            this.productName = productName;
            this.quantity = quantity;
            this.salesPrice = salesPrice;
            this.description = description;
            this.size = size;
            this.imageUrl = imageUrl;
        }

    }
}