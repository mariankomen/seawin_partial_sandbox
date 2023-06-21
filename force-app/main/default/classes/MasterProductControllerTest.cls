@isTest
public with sharing class MasterProductControllerTest {
    
    @TestSetup
    static void makeData(){

        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'Seawin USA';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;

        AcctSeed__GL_Account__c aegl = new AcctSeed__GL_Account__c();
        aegl.name = 'glaccount';
        aegl.AcctSeed__Type__c = 'Expense';
        aegl.AcctSeed__Sub_Type_1__c = 'Facilities';
        aegl.AcctSeed__Sub_Type_2__c = 'Rent';
        aegl.AcctSeed__Bank__c = true;
        aegl.GL_Account_Variable_1__c = accVar.Id;
        insert aegl;

        Master_Product_Properties__c cus_sett = new Master_Product_Properties__c();
        cus_sett.Name = 'Primary';
        cus_sett.Picklist_Properties__c = 'Size__c;Hardware_Finish__c;Glass_Thickness__c;Allow_Product_Description_Change__c;Glass__c;Color__c;Wood_Color__c;Stone_Color__c;Direction__c;';
        insert cus_sett;

        Master_Product__c master = new Master_Product__c();
        master.Name = 'test';
        master.Expense_GL_Account__c = aegl.Id;
        master.Product_Code__c = 'testproductcode';
        insert master;
    }

    @isTest
    public static void fetchPicklistsValuesTest(){
        String response = MasterProductController.fetchPicklistsValues();
    }
    @isTest
    public static void fetchFieldsExceptSelectedPropertiesTest(){
        String response = MasterProductController.fetchFieldsExceptSelectedProperties();
    }
    @isTest
    public static void combineFieldWithTypeTest(){
        String response = MasterProductController.combineFieldWithType('Master_Product__c');
    }
    @isTest
    public static void compileMasterQueryTest(){
        String response = MasterProductController.compileMasterQuery('Master_Product__c');
    }
    @isTest
    public static void getAllPicklistFieldsWithOptionsTest(){
        String response = MasterProductController.getAllPicklistFieldsWithOptions('Master_Product__c');
    }
    @isTest
    public static void checkProductSKUAvailabilityTest(){
        String json_str = '[{"size":"","stone_color":"Black Galaxy","direction":"Bypass","name":"asdf asdf fasd ","product_description":"asdfsdfas","product_code":"vvvv","stockkeepingunit":"vvvv","Id":1,"dynamicIcon":"action:approval","rowId":1,"selling_cost":0},{"size":"","stone_color":"Carrara White","direction":"Bypass","name":"asdf asdf fasd ","product_description":"asdfsdfas","product_code":"asdvv","stockkeepingunit":"asdvv","Id":2,"dynamicIcon":"action:approval","rowId":2,"selling_cost":0},{"size":"","stone_color":"Black Galaxy","direction":"Center","name":"asdf asdf fasd ","product_description":"asdffa","product_code":"vvvvv","stockkeepingunit":"vvvvv","Id":3,"dynamicIcon":"action:approval","rowId":3,"selling_cost":0},{"size":"","stone_color":"Carrara White","direction":"Center","name":"asdf asdf fasd ","product_description":"asdffa","product_code":"asdvvv","stockkeepingunit":"asdvvv","Id":4,"dynamicIcon":"action:approval","rowId":4,"selling_cost":0}]';
        
        String response = MasterProductController.checkProductSKUAvailability(json_str);
    }
    @isTest
    public static void createProductsFromMasterProductTest(){
        String json_str = '[{"size":"","stone_color":"Black Galaxy","direction":"Bypass","name":"asdf asdf fasd ","product_description":"asdfsdfas","product_code":"vvvv","stockkeepingunit":"vvvddv","Id":1,"dynamicIcon":"action:approval","rowId":1,"selling_cost":0},{"size":"","stone_color":"Carrara White","direction":"Bypass","name":"asdf asdf fasd ","product_description":"asdfsdfas","product_code":"asdvv","stockkeepingunit":"asdfgsdfvv","Id":2,"dynamicIcon":"action:approval","rowId":2,"selling_cost":0},{"size":"","stone_color":"Black Galaxy","direction":"Center","name":"asdf asdf fasd ","product_description":"asdffa","product_code":"vvvvv","stockkeepingunit":"vvdhfghdfghdfghdvvv","Id":3,"dynamicIcon":"action:approval","rowId":3,"selling_cost":0},{"size":"","stone_color":"Carrara White","direction":"Center","name":"asdf asdf fasd ","product_description":"asdffa","product_code":"asdvvv","stockkeepingunit":"as23dvvv","Id":4,"dynamicIcon":"action:approval","rowId":4,"selling_cost":0}]';
        Master_Product__c master = [SELECT Id FROM Master_Product__c WHERE Name='test' LIMIT 1];

        String response = MasterProductController.createProductsFromMasterProduct(String.valueOf(master.Id), json_str);
    }
    
}