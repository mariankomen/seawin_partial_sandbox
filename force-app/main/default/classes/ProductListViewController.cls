/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 08-02-2023
 * @last modified by  : Marian Lyzhychka
**/
public without sharing class ProductListViewController {
    
    public class ProductListViewControllerException extends Exception{}
    private static final Set<String> HEADER_FILTER_SET = new Set<String>{'Name', 'ProductCode', 'Description', 'Size__c', 'Type__c', 'UPC_Code__c', 'AcctSeed__Inventory_Type__c'};

    /* SObject insert Errors */
    private static final String SALES_ORDER_CLOSED = 'Can not add product(s) to Sales Order as it Closed.';


    @AuraEnabled
    public static string fetchProducts(String filters, Integer pageSize, Integer pageNumber, String sortField, String sortDirection){
        try {
            ProductQueryFiltersWrapper filtersWrapper = (ProductQueryFiltersWrapper)JSON.deserialize(filters, ProductQueryFiltersWrapper.class);
            String fields = AllFields.Fields('Product2', new List<String>());

            String query = 'SELECT '+fields+'  FROM Product2 ';

            query += ' WHERE IsActive = ' + filtersWrapper.isAllActive;
            if(filtersWrapper.header_type == 'All' && !String.isEmpty(filtersWrapper.header_key)){
                query += ' AND (';
                for(String filter: HEADER_FILTER_SET){
                    query += filter + '= \'' + filtersWrapper.header_key + '\' OR ';
                }
                query = query.removeEnd(' OR ');
                query += ')';
            }else if(filtersWrapper.header_type == 'None'){

            }else if((filtersWrapper.header_type != 'All' && filtersWrapper.header_type != 'None') && !String.isBlank(filtersWrapper.header_key) && filtersWrapper.header_key != 'null'){
                query += ' AND ' + filtersWrapper.header_type + '= \'' + filtersWrapper.header_key + '\'';
            }


            if(!String.isBlank(filtersWrapper.family) && filtersWrapper.family != 'None'){
                query += ' AND Category__c = \'' + filtersWrapper.family + '\'';
            }else if(filtersWrapper.family == 'None'){
                query += ' AND Category__c = null';
            }

            if(!String.isBlank(filtersWrapper.category) && filtersWrapper.category != 'None'){
                query += ' AND Sub_Category__c = \'' + filtersWrapper.category + '\'';
            }else if(filtersWrapper.category == 'None'){
                query += ' AND Sub_Category__c = null';
            }

            if(!String.isBlank(filtersWrapper.subcategory) && filtersWrapper.subcategory != 'None'){
                query += ' AND Complementary_Category__c = \'' + filtersWrapper.subcategory + '\'';
            }else if(filtersWrapper.subcategory == 'None'){
                query += ' AND Complementary_Category__c = null';
            }
            
            Integer offset = (pageNumber - 1) * pageSize;
            String queryTotalWithoutLimit = query;
            query += ' LIMIT ' + pageSize + ' OFFSET ' + offset;
            Integer totalRecords = Database.query(queryTotalWithoutLimit).size();

            system.debug('query: '+query);
            List<Product2> products = Database.query(query);
            List<ProductWrapper> productWrapperList = new List<ProductWrapper>();

            for(Product2 p: products){
                productWrapperList.add(new ProductWrapper(p));
            }

            ResultWrapper result = new ResultWrapper(productWrapperList, totalRecords);
            return JSON.serialize(result);
        } catch (Exception e) {
            throw new ProductListViewControllerException(e.getMessage());
        }
    }




    


    /**
    * @description 
    * @author Marian Lyzhychka | 06-25-2023 
    * @return String 
    **/
    @AuraEnabled
    public static String getProductFieldsDependencies(){
        try {
            Map<String, List<PicklistValuesController.DependentPicklistOptionWrapper>> familyToCategoryDependencies = PicklistValuesController.getFieldDependenciesWrap('Product2',
                                                                                                'Category__c',
                                                                                                'Sub_Category__c');
            Map<String, List<PicklistValuesController.DependentPicklistOptionWrapper>> categoryToSubCategoryDependencies = PicklistValuesController.getFieldDependenciesWrap('Product2',
                                                                                                'Sub_Category__c',
                                                                                                'Complementary_Category__c');

            ProductFieldDependenciesWrapper wrapper = new ProductFieldDependenciesWrapper(familyToCategoryDependencies, categoryToSubCategoryDependencies);

            return JSON.serialize(wrapper);
        } catch (Exception e) {
            throw new ProductListViewControllerException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void updateEditedProductFields(String updatedDataJson){
        try {
            List<ProductPicklistUpdateWrapper> productFieldsWrapper = (List<ProductPicklistUpdateWrapper>)JSON.deserialize(updatedDataJson, List<ProductPicklistUpdateWrapper>.class);
            Set<String> productIdSet = new Set<String>();

            for(ProductPicklistUpdateWrapper productWR: productFieldsWrapper){
                productIdSet.add(productWR.productId);
            }

            Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT Id, Category__c, Sub_Category__c, Complementary_Category__c FROM Product2 WHERE Id IN:productIdSet]);
            List<Product2> productToUpdate = new List<Product2>();

            for(ProductPicklistUpdateWrapper productWR: productFieldsWrapper){
                if(productMap.containsKey(productWR.productId)){
                    Product2 product = productMap.get(productWR.productId);
                    product.Category__c = productWR.family;
                    product.Sub_Category__c = productWR.category;
                    product.Complementary_Category__c = productWR.subcategory;

                    productToUpdate.add(product);
                }
            }

            if(!productToUpdate.isEmpty()){
                update productToUpdate;
            }
        } catch (Exception e) {
            throw new ProductListViewControllerException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Marian Lyzhychka | 06-26-2023 
    * @param sobjectType 
    * @param recordId 
    * @param linesWrapper 
    **/
    @AuraEnabled
    public static void insertLinesController(String sobjectType, String recordId, String linesWrapper){
        try {
            List<InsertSObjectLineParamsWrapper> lines = (List<InsertSObjectLineParamsWrapper>)JSON.deserialize(linesWrapper, List<InsertSObjectLineParamsWrapper>.class);
            system.debug('123');
            system.debug('sobjectType: '+sobjectType);
            if(sobjectType == 'so'){
                insertSalesOrderLines(recordId, lines);
            }else if(sobjectType == 'opp'){
                insertOpportunityLineItems(recordId, lines);
            }else if(sobjectType == 'optionalopp'){
                insertOptionalOpportunityLineItems(recordId, lines);
            }else if(sobjectType == 'QuoteLineItem'){
                system.debug('QuoteLineItem');
                insertQuoteLineItems(recordId, lines);
                system.debug('QuoteLineItem end');
            }else if(sobjectType == 'OptionalProductQuote'){

            }
            system.debug('345');
        } catch (Exception e) {
            throw new ProductListViewControllerException(e.getMessage());
        }
    }
    private static void insertQuoteLineItems(String recordId, List<InsertSObjectLineParamsWrapper> linesWrapper){
        Set<Id> productsIds = new Set<Id>();
        for(InsertSObjectLineParamsWrapper wrap: linesWrapper){
            productsIds.add(wrap.productId);
        }
        Id priceBookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [select id, name from Pricebook2 where isStandard = true limit 1][0].id;
        Map<Id, PriceBookEntry> productsPriceMap = new Map<Id, PriceBookEntry>();

        for (PriceBookEntry pbe : [
            SELECT id, unitprice, product2id
            FROM pricebookentry
            WHERE product2id IN :productsIds
            and pricebook2Id=:priceBookId
        ]) {
            productsPriceMap.put(pbe.Product2Id, pbe);
        }

        List<QuoteLineItem> existingOptionalOpportunityLines = [SELECT Id, SortOrder FROM QuoteLineItem WHERE QuoteId =: recordId ORDER BY SortOrder DESC];
        Boolean needUpdateExistingSortOrder = false;
        Integer lastSortOrder;

        if(existingOptionalOpportunityLines.size() > 0 && existingOptionalOpportunityLines[0].SortOrder != null){
            lastSortOrder = Integer.valueOf(existingOptionalOpportunityLines[0].SortOrder + 1);
        }else if(existingOptionalOpportunityLines.size() > 0){
            lastSortOrder = 1;
            needUpdateExistingSortOrder = true;
        }else{
            lastSortOrder = 1;
        }


        if(needUpdateExistingSortOrder){
            for(QuoteLineItem sol: existingOptionalOpportunityLines){
                sol.SortOrder = lastSortOrder;
                lastSortOrder += 1;
            }
            update existingOptionalOpportunityLines;
        }

        List<QuoteLineItem> newOpportunityLineItemsList = new List<QuoteLineItem>();

        for(InsertSObjectLineParamsWrapper wrap: linesWrapper){
            QuoteLineItem oli = new QuoteLineItem();

            oli.QuoteId = recordId;
            oli.Product2Id = wrap.productId;
            oli.SortOrder = lastSortOrder;
            oli.Item_Description__c = wrap.description;
            oli.Allow_Product_Description_Change__c = wrap.allowDescriptionChange;
            oli.Size__c = wrap.size;
            oli.UnitPrice = wrap.salesPrice;
            oli.Quantity = wrap.quantity;
            oli.PriceBookEntryId = productsPriceMap.containsKey(wrap.productId) ? productsPriceMap.get(wrap.productId).id : null;

            newOpportunityLineItemsList.add(oli);
            lastSortOrder += 1;
        }

        if(!newOpportunityLineItemsList.isEmpty()){
            try{
                insert newOpportunityLineItemsList;
            }catch(Exception e){
                system.debug(e.getMessage());
                throw new ProductListViewControllerException(e.getMessage());
            }
        }
    }




    /**
    * @description 
    * @author Marian Lyzhychka | 08-01-2023 
    * @param recordId 
    * @param linesWrapper 
    **/
    private static void insertOptionalOpportunityLineItems(String recordId, List<InsertSObjectLineParamsWrapper> linesWrapper){
        Set<Id> productsIds = new Set<Id>();
        for(InsertSObjectLineParamsWrapper wrap: linesWrapper){
            productsIds.add(wrap.productId);
        }
        Id priceBookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [select id, name from Pricebook2 where isStandard = true limit 1][0].id;
        Map<Id, PriceBookEntry> productsPriceMap = new Map<Id, PriceBookEntry>();

        for (PriceBookEntry pbe : [
            SELECT id, unitprice, product2id
            FROM pricebookentry
            WHERE product2id IN :productsIds
            and pricebook2Id=:priceBookId
        ]) {
            productsPriceMap.put(pbe.Product2Id, pbe);
        }



        Opportunity opp = [SELECT Id, GL_Account_Variable_1__c FROM Opportunity WHERE Id =: recordId LIMIT 1];

        List<Optional_Products_Opportunity__c> existingOptionalOpportunityLines = [SELECT Id, SortOrder__c, Opportunity__c FROM Optional_Products_Opportunity__c WHERE Opportunity__c =: recordId ORDER BY sortorder__c DESC];
        Boolean needUpdateExistingSortOrder = false;
        Integer lastSortOrder;

        if(existingOptionalOpportunityLines.size() > 0 && existingOptionalOpportunityLines[0].SortOrder__c != null){
            lastSortOrder = Integer.valueOf(existingOptionalOpportunityLines[0].SortOrder__c + 1);
        }else if(existingOptionalOpportunityLines.size() > 0){
            lastSortOrder = 1;
            needUpdateExistingSortOrder = true;
        }else{
            lastSortOrder = 1;
        }


        if(needUpdateExistingSortOrder){
            for(Optional_Products_Opportunity__c sol: existingOptionalOpportunityLines){
                sol.SortOrder__c = lastSortOrder;
                lastSortOrder += 1;
            }
            update existingOptionalOpportunityLines;
        }

        List<Optional_Products_Opportunity__c> newOpportunityLineItemsList = new List<Optional_Products_Opportunity__c>();

        for(InsertSObjectLineParamsWrapper wrap: linesWrapper){
            Optional_Products_Opportunity__c oli = new Optional_Products_Opportunity__c();
            oli.Opportunity__c = recordId;
            oli.Product__c = wrap.productId;
            oli.SortOrder__c = lastSortOrder;
            oli.Item_Description__c = wrap.description;
            oli.GL_Account_Variable_1__c = opp.GL_Account_Variable_1__c;
            oli.Allow_Product_Description_Change__c = wrap.allowDescriptionChange;
            oli.Size__c = wrap.size;
            oli.UnitPrice__c = wrap.salesPrice;
            oli.Quantity__c = wrap.quantity;
            oli.PriceBookEntryId__c = productsPriceMap.containsKey(wrap.productId) ? productsPriceMap.get(wrap.productId).id : null;

            newOpportunityLineItemsList.add(oli);
            lastSortOrder += 1;
        }

        if(!newOpportunityLineItemsList.isEmpty()){
            try{
                insert newOpportunityLineItemsList;
            }catch(Exception e){
                system.debug(e.getMessage());
                throw new ProductListViewControllerException(e.getMessage());
            }
        }
    }


    private static void insertOpportunityLineItems(String recordId, List<InsertSObjectLineParamsWrapper> linesWrapper){
        Set<Id> productsIds = new Set<Id>();
        for(InsertSObjectLineParamsWrapper wrap: linesWrapper){
            productsIds.add(wrap.productId);
        }
        Id priceBookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [select id, name from Pricebook2 where isStandard = true limit 1][0].id;
        Map<Id, PriceBookEntry> productsPriceMap = new Map<Id, PriceBookEntry>();

        for (PriceBookEntry pbe : [
            SELECT id, unitprice, product2id
            FROM pricebookentry
            WHERE product2id IN :productsIds
            and pricebook2Id=:priceBookId
        ]) {
            productsPriceMap.put(pbe.Product2Id, pbe);
        }



        Opportunity opp = [SELECT Id, GL_Account_Variable_1__c FROM Opportunity WHERE Id =: recordId LIMIT 1];

        List<OpportunityLineItem> existingOpportunityLines = [SELECT Id, SortOrder, OpportunityId FROM OpportunityLineItem WHERE OpportunityId =: recordId ORDER BY SortOrder DESC];
        Boolean needUpdateExistingSortOrder = false;
        Integer lastSortOrder;

        if(existingOpportunityLines.size() > 0 && existingOpportunityLines[0].SortOrder != null){
            lastSortOrder = Integer.valueOf(existingOpportunityLines[0].SortOrder + 1);
        }else if(existingOpportunityLines.size() > 0){
            lastSortOrder = 1;
            needUpdateExistingSortOrder = true;
        }else{
            lastSortOrder = 1;
        }


        if(needUpdateExistingSortOrder){
            for(OpportunityLineItem sol: existingOpportunityLines){
                sol.SortOrder = lastSortOrder;
                lastSortOrder += 1;
            }
            update existingOpportunityLines;
        }

        List<OpportunityLineItem> newOpportunityLineItemsList = new List<OpportunityLineItem>();

        for(InsertSObjectLineParamsWrapper wrap: linesWrapper){
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = recordId;
            oli.Product2Id = wrap.productId;
            oli.SortOrder = lastSortOrder;
            oli.Item_Description__c = wrap.description;
            oli.AcctSeed__GL_Account_Variable_1__c = opp.GL_Account_Variable_1__c;
            oli.Allow_Product_Description_Change__c = wrap.allowDescriptionChange;
            oli.Size__c = wrap.size;
            oli.UnitPrice = wrap.salesPrice;
            oli.Quantity = wrap.quantity;
            oli.PricebookEntryId = productsPriceMap.containsKey(wrap.productId) ? productsPriceMap.get(wrap.productId).id : null;

            newOpportunityLineItemsList.add(oli);
            lastSortOrder += 1;
        }

        if(!newOpportunityLineItemsList.isEmpty()){
            try{
                insert newOpportunityLineItemsList;
            }catch(Exception e){
                system.debug(e.getMessage());
                throw new ProductListViewControllerException(e.getMessage());
            }
        }


    }
    private static void insertSalesOrderLines(String recordId, List<InsertSObjectLineParamsWrapper> linesWrapper){
        AcctSeedERP__Sales_Order__c salesOrder = [SELECT AcctSeedERP__Status__c, GL_Account_Variable_1__c FROM AcctSeedERP__Sales_Order__c WHERE id = :recordId LIMIT 1];
        if(salesOrder.AcctSeedERP__Status__c == 'Closed'){
            throw new ProductListViewControllerException(SALES_ORDER_CLOSED);
        }

        List<AcctSeedERP__Sales_Order_Line__c> existingSalesOrderLines = [SELECT Id, SortOrder__c, AcctSeedERP__Sales_Order__c 
                                                                          FROM AcctSeedERP__Sales_Order_Line__c 
                                                                          WHERE AcctSeedERP__Sales_Order__c=:salesOrder.Id ORDER BY SortOrder__c DESC];
        
        Boolean needUpdateExistingSortOrder = false;
        Integer lastSortOrder;
        
        if(existingSalesOrderLines.size() > 0 && existingSalesOrderLines[0].SortOrder__c != null){
            lastSortOrder = Integer.valueOf(existingSalesOrderLines[0].SortOrder__c + 1);
        }else if(existingSalesOrderLines.size() > 0){
            lastSortOrder = 1;
            needUpdateExistingSortOrder = true;
        }else{
            lastSortOrder = 1;
        }

        if(needUpdateExistingSortOrder){
            for(AcctSeedERP__Sales_Order_Line__c sol: existingSalesOrderLines){
                sol.SortOrder__c = lastSortOrder;
                lastSortOrder += 1;
            }

            update existingSalesOrderLines;
        }

        List<AcctSeedERP__Sales_Order_Line__c> salesOrderLines = new List<AcctSeedERP__Sales_Order_Line__c>();

        for(InsertSObjectLineParamsWrapper wrap: linesWrapper){
            AcctSeedERP__Sales_Order_Line__c line = new AcctSeedERP__Sales_Order_Line__c(
                acctseederp__sales_order__c = salesOrder.Id,
                acctseederp__product__c = wrap.productId,
                acctseederp__Unit_Price__c = wrap.salesPrice,
                AcctSeedERP__Quantity_Ordered__c = wrap.quantity,
                acctseederp_Description__c = wrap.description,
                Item_Description__c = wrap.description,
                Size__c = wrap.size,
                AcctSeedERP__GL_Account_Variable_1__c = salesOrder.GL_Account_Variable_1__c,
                Allow_Product_Description_Change__c = wrap.allowDescriptionChange,
                SortOrder__c = lastSortOrder
            );
            lastSortOrder += 1;

            salesOrderLines.add(line);
        }

        if(!salesOrderLines.isEmpty()){
            insert salesOrderLines;
        }
    }

    public class InsertSObjectLineParamsWrapper{
        public String productId {get;set;}
        public Decimal quantity {get;set;}
        public Decimal salesPrice {get;set;}
        public String description {get;set;}
        public String size {get;set;}
        public Boolean allowDescriptionChange {get;set;}

        public InsertSObjectLineParamsWrapper(String productId, Decimal quantity, Decimal salesPrice, String description, String size, Boolean allowDescriptionChange){
            this.productId = productId;
            this.quantity = quantity;
            this.salesPrice = salesPrice;
            this.description = description;
            this.size = size;
            this.allowDescriptionChange = allowDescriptionChange;
        }
    }

    public class ProductFieldDependenciesWrapper{
        public Map<String, List<PicklistValuesController.DependentPicklistOptionWrapper>> familyToCategory {get;set;}
        public Map<String, List<PicklistValuesController.DependentPicklistOptionWrapper>> categoryToSubCategory {get;set;}

        public ProductFieldDependenciesWrapper(Map<String, List<PicklistValuesController.DependentPicklistOptionWrapper>> familyToCategory, Map<String, List<PicklistValuesController.DependentPicklistOptionWrapper>> categoryToSubCategory){
            this.familyToCategory = familyToCategory;
            this.categoryToSubCategory = categoryToSubCategory;
        }

    }

    public class ProductQueryFiltersWrapper{
        public String header_type {get;set;}
        public String header_key {get;set;}
        public String family {get;set;}
        public String category {get;set;}
        public String subcategory {get;set;}
        public Boolean isAllActive {get;set;}
    }

    public class ResultWrapper{
        public List<ProductWrapper> data {get;set;}
        public Integer totalRecords {get;set;}

        public ResultWrapper(List<ProductWrapper> data, Integer totalRecords){
            this.data = data;
            this.totalRecords = totalRecords;
        }
    }

    public class ProductWrapper {
        @AuraEnabled
        public Product2 product {get;set;}

        public ProductWrapper(Product2 product){
            this.product = product;
        }
    }
    

    public class ProductPicklistUpdateWrapper{
        public String productId {get;set;}
        public String family {get;set;}
        public String category {get;set;}
        public String subcategory {get;set;}
    }
}