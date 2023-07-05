/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-04-2023
 * @last modified by  : Marian Lyzhychka
**/
@isTest
public with sharing class ReusableLookupControllerTest {
    
    @TestSetup
    static void makeData(){
        AcctSeed__Accounting_Variable__c accVar = new AcctSeed__Accounting_Variable__c();
        accVar.Name = 'GL acc var1';
        accVar.AcctSeed__Type__c = 'GL Account Variable 1';
        insert accVar;
    }

    @isTest
    static void fetchRecordsTest(){
        String testStr = '{ "objectApiName":"AcctSeed__Accounting_Variable__c", "fieldApiName":"Name", "otherFieldApiName":"AcctSeed__Type__c", "searchString":"G", "selectedRecordId": null, "parentRecordId":null, "parentFieldApiName":null }';
        ReusableLookupController.SearchWrapper wrap = (ReusableLookupController.SearchWrapper)JSON.deserialize(testStr, ReusableLookupController.SearchWrapper.class);

        ReusableLookupController.fetchRecords(wrap);
    }
}