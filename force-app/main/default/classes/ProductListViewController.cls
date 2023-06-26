/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 06-26-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class ProductListViewController {
    
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
                
                if(!String.isBlank(filtersWrapper.category) && filtersWrapper.category != 'None'){
                    query += ' AND Sub_Category__c = \'' + filtersWrapper.category + '\'';

                    if(!String.isBlank(filtersWrapper.subcategory) && filtersWrapper.subcategory != 'null' && filtersWrapper.subcategory != 'None'){
                        query += ' AND Complementary_Category__c = \'' + filtersWrapper.subcategory + '\'';
                        
                    }
                }
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
            Map<String, List<String>> familyToCategoryDependencies = PicklistValuesController.getFieldDependencies('Product2',
                                                                                                'Category__c',
                                                                                                'Sub_Category__c');


            Map<String, List<String>> categoryToSubCategoryDependencies = PicklistValuesController.getFieldDependencies('Product2',
                                                                                                'Sub_Category__c',
                                                                                                'Complementary_Category__c');
            ProductFieldDependenciesWrapper wrapper = new ProductFieldDependenciesWrapper(familyToCategoryDependencies, categoryToSubCategoryDependencies);

            return JSON.serialize(wrapper);
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
            
            if(sobjectType == 'so'){
                insertSalesOrderLines(recordId, lines);
            }
        } catch (Exception e) {
            throw new ProductListViewControllerException(e.getMessage());
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
    }

    public class ProductFieldDependenciesWrapper{
        public Map<String, List<String>> familyToCategory {get;set;}
        public Map<String, List<String>> categoryToSubCategory {get;set;}

        public ProductFieldDependenciesWrapper(Map<String, List<String>> familyToCategory, Map<String, List<String>> categoryToSubCategory){
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
    
}