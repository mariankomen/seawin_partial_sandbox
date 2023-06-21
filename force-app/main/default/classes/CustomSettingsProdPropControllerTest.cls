@isTest
public with sharing class CustomSettingsProdPropControllerTest {
   
    @TestSetup
    static void makeData(){
        Master_Product_Properties__c prop = new Master_Product_Properties__c();
        prop.Name = 'Primary';
        prop.Picklist_Properties__c = 'Size__c;Hardware_Finish__c;Glass_Thickness__c;Glass__c;Color__c;Wood_Color__c;Stone_Color__c;Direction__c;';

        insert prop;
    }


    @isTest
    public static void CustomSettingsProdPropControllerTestMeth(){
        CustomSettingsProdPropController sett = new CustomSettingsProdPropController();
        sett.saveConfiguration();
    }
}