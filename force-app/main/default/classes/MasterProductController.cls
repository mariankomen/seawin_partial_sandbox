public with sharing class MasterProductController {

    public static final List<String> exclude_fields = new List<String>{'LastReferencedDate',

                                                                        'LastViewedDate',
                                                                        'IsDeleted',
                                                                        'ExternalDataSourceId',
                                                                        'RecordTypeId',
                                                                        'SystemModstamp',
                                                                        'LastModifiedById',
                                                                        'LastModifiedDate',
                                                                        'CreatedById',
                                                                        'CreatedDate',
                                                                        'IsArchived'};

    @AuraEnabled
    public static String fetchPicklistsValues(){
        Master_Product_Properties__c selected_picklists = Master_Product_Properties__c.getInstance('Primary');
        List<String> selected_picklists_api = selected_picklists.Picklist_Properties__c.split(';');
        Map<String,String> label_api_map = CustomSettingsProdPropController.getPicklistTypeFieldsByLabel('Master_Product__c');


        List<FieldItem> fields = new List<FieldItem>();
        
        for(String field_api: selected_picklists_api){
            String field_type = combineFieldType(getFieldType('Master_Product__c', field_api));

            if(field_type == 'PICKLIST'){
                List<PicklistItem> picklist_values = new List<PicklistItem>();
                Map<String, String> label_value = getPicklistValues('Master_Product__c',field_api);
    
                for(String str: label_value.keySet()){
                    picklist_values.add(new PicklistItem(str, label_value.get(str)));
                }
                fields.add(new FieldItem(field_api, 
                                            label_api_map.get(field_api),
                                            field_type,
                                            picklist_values,
                                            true,
                                            false,
                                            false
                                        )
                            );
            }else if(field_type == 'CHECKBOX'){
                fields.add(new FieldItem(field_api, 
                                            label_api_map.get(field_api),
                                            field_type,
                                            new List<PicklistItem>(),
                                            false,
                                            true,
                                            false
                                        )
                            );
            }else if(field_type == 'TEXT'){
                fields.add(new FieldItem(field_api, 
                                        label_api_map.get(field_api),
                                        field_type,
                                        new List<PicklistItem>(),
                                        false,
                                        false,
                                        true
                                    )
                        );
            }
        }
        return JSON.serialize(fields);
    }

    
    
    @AuraEnabled
    public static String fetchFieldsExceptSelectedProperties(){
        Master_Product_Properties__c selected_picklists = Master_Product_Properties__c.getInstance('Primary');
        List<String> selected_picklists_api = selected_picklists.Picklist_Properties__c.split(';');

        List<String> available_form_fields = new List<String>();
        List<OptionWrapper> wrapper = new List<OptionWrapper>();

        Map<String, Schema.SObjectType> detail = Schema.getGlobalDescribe();
        Map<String,String> mapOfPicklistTypeFields = new  Map<String,String>();
        for(Schema.SObjectField fields :detail.get('Master_Product__c').getDescribe().fields.getMap().Values()) {
            if(!exclude_fields.contains(fields.getDescribe().getName()) && !selected_picklists_api.contains(fields.getDescribe().getName())) { 
                available_form_fields.add(fields.getDescribe().getName());

                wrapper.add(new OptionWrapper(fields.getDescribe().getLabel(), fields.getDescribe().getName()));
            }
        }
        return JSON.serialize(wrapper);
        // return JSON.serialize(available_form_fields);

    }
    public static Map<String, String> getPicklistValues(String ObjectApi_name,String Field_name){ 

        List<String> lstPickvals=new List<String>();
        Map<String, String> picklistMap = new Map<String, String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
            picklistMap.put(a.getLabel(), a.getValue());
        }
      
        return picklistMap;
    }

    public static String getFieldType(String objectName, String fieldName){

        SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
        DescribeSObjectResult d = r.getDescribe();
        return String.valueOf(d.fields
                            .getMap()
                            .get(fieldName)
                            .getDescribe()
                            .getType());
    }

    public static String combineFieldType(String field_type){
        if(field_type == 'PICKLIST'){
            return 'PICKLIST';
        }else if(field_type == 'BOOLEAN'){
            return 'CHECKBOX';
        }else{
            return 'TEXT';
        }
    }

    @AuraEnabled
    public static String combineFieldWithType(String sobject_api){
        SObjectType accountType = Schema.getGlobalDescribe().get(sobject_api);
        Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        Map<String, String> combined_map = new Map<String, String>();

        for(String field: mfields.keySet()){
            String type = combineFieldType(getFieldType(sobject_api, field));
            combined_map.put(field, type);
        }

        return JSON.serialize(combined_map);
    }

    public static String compileMasterQuery(String sobject_api){
        SObjectType accountType = Schema.getGlobalDescribe().get(sobject_api);
        Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        String soql = '';
        
        for(String field: mfields.keySet()){
            soql += field + ', ';
        }

        return soql.removeEnd(', ');

    }

    @AuraEnabled
    public static string getMasterProduct(String masterId){
        try {
            String query = 'SELECT ';
            query += compileMasterQuery('Master_Product__c');
            query += ' FROM Master_Product__c WHERE Id=:masterId LIMIT 1';

            Master_Product__c mast = (Master_Product__c)Database.query(query);
            return JSON.serialize(mast);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    


    @AuraEnabled
    public static string getAllPicklistFieldsWithOptions(String strObjectName){
        try {
            Map<String, Schema.SObjectType> detail = Schema.getGlobalDescribe();
            Map<String,String> mapOfPicklistTypeFields = new  Map<String,String>();
            for(Schema.SObjectField fields :detail.get(strObjectName).getDescribe().fields.getMap().Values()) {
                if(fields.getDescribe().getType() == Schema.DisplayType.PICKLIST) { 
                    mapOfPicklistTypeFields.put(fields.getDescribe().getName() , fields.getDescribe().getLabel());
                }
            }
            Map<String, Map<String, String>> fields_with_values = new Map<String, Map<String, String>>();

            for(String field: mapOfPicklistTypeFields.keySet()){
                Map<String, String> values = picklistValues(strObjectName, field);
                fields_with_values.put(field.toLowerCase(), values);
            }

            return JSON.serialize(fields_with_values);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Map<String, String> picklistValues(String objectName, String fieldName) {
        Map<String, String> values = new Map<String, String>{};

        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }

        return values;
    }

    @AuraEnabled
    public static String checkProductSKUAvailability(String predefined){
        try {
            List<ProductWrapper> front_products = (List<ProductWrapper>)JSON.deserialize(predefined, List<ProductWrapper>.class);

            system.debug('predefined: '+predefined);
            system.debug('front_products: '+JSON.serialize(front_products));
            List<String> predefined_skues = new List<String>();

            for(ProductWrapper pw: front_products){
                if(pw.stockkeepingunit != null){
                    predefined_skues.add(pw.stockkeepingunit);
                }
            }

            List<String> unavailable_skues = new List<String>();
            for(Product2 prod: [SELECT Id, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN:predefined_skues]){
                unavailable_skues.add(prod.StockKeepingUnit);
            }
            return JSON.serialize(unavailable_skues);
        } catch (Exception e) {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string createProductsFromMasterProduct(String masterId, String predefined){
        try {
            // Pricebook2 pricebook = [SELECT Id, Name, IsActive, IsStandard FROM Pricebook2 where IsActive = true and isstandard=true limit 1];
            List<ProductWrapper> front_products = (List<ProductWrapper>)JSON.deserialize(predefined, List<ProductWrapper>.class);
            String query = 'SELECT ' + compileMasterQuery('Master_Product__c') + '  FROM Master_Product__c WHERE Id=:masterId';
            Master_Product__c master_product = (Master_Product__c)Database.query(query);

            List<Product2> child_products = new List<Product2>();
            for(ProductWrapper pw: front_products){
                Product2 product = new Product2();

                product.IsActive = pw.isactive != null ? pw.isactive : master_product.isActive__c;
                product.Allow_Custom_Image__c = pw.allow_custom_imag != null ? pw.allow_custom_imag : master_product.Allow_Custom_Image__c;
                product.Allow_Product_Description_Change__c = pw.allow_product_description_change != null ? pw.allow_product_description_change : master_product.Allow_Product_Description_Change__c;
                product.Available_Quantity__c = pw.available_quantity != null ? pw.available_quantity : master_product.Available_Quantity__c;
                product.Sub_Category__c = pw.sub_category != null ? pw.sub_category : master_product.Sub_Category__c;
                product.Color__c = pw.color != null ? pw.color : master_product.Color__c;
                product.Commissionable_Product__c = pw.commissionable_product != null ? pw.commissionable_product : master_product.Commissionable_Product__c;
                product.Credit_Card_Fee__c = pw.credit_card_fee != null ? pw.credit_card_fee : master_product.Credit_Card_Fee__c;
                product.AcctSeedERP__Default_Vendor__c = pw.default_vendor != null ? pw.default_vendor : master_product.Default_Vendor__c;
                product.Direction__c = pw.direction != null ? pw.direction : master_product.Direction__c;
                product.Door_Type__c = pw.door_type != null ? pw.door_type : master_product.Door_Type__c;
                product.AcctSeed__Expense_GL_Account__c = master_product.Expense_GL_Account__c;
                product.Category__c = pw.category != null ? pw.category : master_product.Category__c;
                product.AcctSeed__GL_Account_Variable_1__c = pw.gl_account_variable_1 != null ? pw.gl_account_variable_1 : master_product.GL_Account_Variable_1__c;
                product.Glass__c = pw.glass != null ? pw.glass : master_product.Glass__c;
                product.Glass_Thickness__c = pw.glass_thickness != null ? pw.glass_thickness : master_product.Glass_Thickness__c;
                product.Glass_Treatment__c = pw.glass_treatment != null ? pw.glass_treatment : master_product.Glass_Treatment__c;
                product.Hardware_Finish__c = pw.hardware_finish != null ? pw.hardware_finish : master_product.Hardware_Finish__c;
                product.AcctSeedERP__Inventory_Asset__c = pw.inventory_asset != null ? pw.inventory_asset : master_product.Inventory_Asset__c;
                product.AcctSeed__Inventory_GL_Account__c = pw.inventory_gl_account != null ? pw.inventory_gl_account : master_product.Inventory_GL_Account__c;
                product.AcctSeed__Inventory_Product__c = pw.inventory_product != null ? pw.inventory_product : master_product.Inventory_Product__c;
                product.AcctSeed__Inventory_Type__c = pw.inventory_type != null ? pw.inventory_type : master_product.Inventory_Type__c;
                product.Kit_Available_Quantity__c = master_product.Kit_Available_Quantity__c;
                product.Last_Cost__c = pw.last_cost != null ? pw.last_cost : master_product.Last_Cost__c;
                product.AcctSeedERP__Lead_Time__c = pw.lead_time != null ? pw.lead_time : master_product.Lead_Time__c;
                product.Master_Product__c = master_product.Id;
                product.AcctSeedERP__Minimum_Order_Quantity__c = pw.minimum_order_quantity != null ? pw.minimum_order_quantity : master_product.Minimum_Order_Quantity__c;
                product.ProductCode = pw.product_code != null ? pw.product_code : master_product.Product_Code__c;
                product.Description = pw.product_description != null ? pw.product_description : master_product.Product_Description__c;
                product.Family = pw.family != null ? pw.family : master_product.Family__c;
                product.ProductImageURL__c = pw.productimageurl != null ? pw.productimageurl : master_product.ProductImageURL__c;
                product.Name = pw.name != null ? pw.name : master_product.Name;
                product.StockKeepingUnit = pw.stockkeepingunit != null ? pw.stockkeepingunit : master_product.StockKeepingUnit__c;
                product.QuantityUnitOfMeasure = pw.quantity_unit_of_measure != null ? pw.quantity_unit_of_measure : master_product.Quantity_Unit_Of_Measure__c;
                product.AcctSeed__Revenue_GL_Account__c = master_product.Revenue_GL_Account__c;
                product.AcctSeedERP__Safety_Stock_Quantity__c = pw.safety_stock_quantity != null ? pw.safety_stock_quantity : master_product.Safety_Stock_Quantity__c;
                product.AcctSeedERP__Sales_Order_Exclude__c = pw.sales_order_exclude != null ? pw.sales_order_exclude : master_product.Sales_Order_Exclude__c;
                product.AcctSeedERP__Serialized__c = pw.serialized != null ? pw.serialized : master_product.Serialized__c;
                product.Series__c = pw.series != null ? pw.series : master_product.Series__c;
                product.Shape__c = pw.shape != null ? pw.shape : master_product.Shape__c;
                product.Shippable_Product__c = pw.shippable_product != null ? pw.shippable_product : master_product.Shippable_Product__c;
                product.Size__c = pw.size != null ? pw.size : master_product.Size__c;
                product.Stone_Color__c = pw.stone_color != null ? pw.stone_color : master_product.Stone_Color__c;
                product.Complementary_Category__c = pw.complementary_category != null ? pw.complementary_category : master_product.Complementary_Category__c;
                product.AcctSeed__Tax_Code__c = master_product.Tax_Code__c;
                product.AcctSeed__Tax_Group__c = master_product.Tax_Group__c;
                product.AcctSeed__Tax_Rate__c = master_product.Tax_Rate__c;
                product.AcctSeed__Accounting_Type__c = master_product.Tax_Type__c;
                product.Technical_Specs_Id__c = master_product.Technical_Specs_Id__c;
                product.Type__c = pw.type != null ? pw.type : master_product.Type__c;
                product.AcctSeed__Unit_Cost__c = pw.unit_cost != null ? pw.unit_cost : master_product.Unit_Cost__c;
                product.UPC_Code__c = pw.upc_code != null ? pw.upc_code : master_product.UPC_Code__c;
                product.Wood_Color__c = pw.wood_color != null ? pw.wood_color : master_product.Wood_Color__c;
                product.Vendor__c = master_product.Vendor__c;

                child_products.add(product);
            }
            insert child_products;
            List<PricebookEntry> pb_entry = new List<PricebookEntry>();

            // SELECT Id, Name, Pricebook2Id, Product2Id, UnitPrice, ProductCode, IsActive FROM PricebookEntry
            // for(Product2 prod: child_products){
            //     PricebookEntry pb_e = new PricebookEntry();
            //     pb_e.Pricebook2Id = pricebook.Id;
            //     pb_e.Product2Id = prod.Id;
            //     pb_e.UnitPrice = 44;
            //     pb_e.IsActive = true;

            //     pb_entry.add(pb_e);
            // }
            // upsert pb_entry;

            system.debug(JSON.serialize(child_products));
            system.debug(JSON.serialize(master_product));

            return null;
        } catch (Exception e) {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static String getFieldsMap(String selectedSObject){
        map<string,SObjectField> fList = schema.getGlobalDescribe().get(selectedSObject).getDescribe().fields.getMap();
        Map<String, String> fields_map = new Map<String, String>();
        for(String field: fList.keySet()){
            fields_map.put(field, fList.get(field).getDescribe().getLabel());
        }

        return JSON.serialize(fields_map);
    }
    public class FieldItem{
        public String apiname {get; set;}
        public String label {get;set;}
        public String field_type {get; set;}
        public List<PicklistItem> picklist_values {get; set;}
        public Boolean isPicklist {get; set;}
        public Boolean isCheckbox {get; set;}
        public Boolean isText {get; set;}

        public FieldItem(String field_api, String field_label, String field_ty, List<PicklistItem> picklist_v, Boolean isPick, Boolean isCheck, Boolean isTex){
            apiname = field_api;
            label = field_label;
            field_type = field_ty;
            picklist_values = picklist_v;
            isPicklist = isPick;
            isCheckbox = isCheck;
            isText = isTex;
        }
    }


    public class PicklistItem{
        public String label {get; set;}
        public String value {get; set;}

        public PicklistItem(String l, String v){
            label = l;
            value = v;
        }
    }

    public class ProductWrapper{
        public Boolean allow_custom_imag {get; set;}
        public String selling_cost {get; set;}
        public Boolean allow_product_description_change {get; set;}
        public Decimal available_quantity {get; set;}
        public String category {get; set;}
        public String color {get; set;}
        public Boolean commissionable_product {get; set;}
        public String complementary_category {get; set;}
        public Boolean credit_card_fee {get; set;}
        public String default_vendor {get; set;}
        public String direction {get; set;}
        public String gl_account_variable_1 {get; set;}
        public String glass_thickness {get; set;}
        public String glass_treatment {get; set;}
        public String glass {get; set;}
        public String hardware_finish {get; set;}
        public Boolean inventory_asset {get; set;}
        public String inventory_gl_account {get; set;}
        public Boolean inventory_product {get; set;}
        public String inventory_type {get; set;}
        public Decimal last_cost {get; set;}
        public Decimal lead_time {get; set;}
        public Decimal minimum_order_quantity {get; set;}
        public String name {get; set;}
        public String productimageurl {get; set;}
        public String product_code {get; set;}
        public String product_description {get; set;}
        public String quantity_unit_of_measure {get; set;}
        public Decimal safety_stock_quantity {get; set;}
        public Boolean sales_order_exclude {get; set;}
        public Boolean serialized {get; set;}
        public String series {get; set;}
        public String shape {get; set;}
        public Boolean shippable_product {get; set;}
        public String size {get; set;}
        public String stockkeepingunit {get; set;}
        public String stone_color {get; set;}
        public String sub_category {get; set;}
        public String upc_code {get; set;}
        public Decimal unit_cost {get; set;}
        public String wood_color {get; set;}
        public Boolean isactive {get; set;}
        public String door_type {get; set;}
        public String family {get; set;}
        public String type {get; set;}
    }

    public class OptionWrapper{
        public String label {get; set;}
        public String value {get; set;}

        public OptionWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}