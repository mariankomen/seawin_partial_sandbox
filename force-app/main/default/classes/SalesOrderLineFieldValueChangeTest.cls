@isTest
public class SalesOrderLineFieldValueChangeTest {
    
    @testSetup static void createSortOrderData(){
       
        TestUtility.CreateData();

    }
    
    @isTest static void SortOrder(){
        Opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
        
        acctseederp__sales_order__c so = [select id from acctseederp__sales_order__c 
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        
        // get the sales order lines list
        acctseederp__sales_order_line__c lines = [select id, size__c, Item_description__c from acctseederp__sales_order_line__c 
                                                    where acctseederp__sales_order__c =: so.id limit 1];
        
		lines.Size__c = '127';
        lines.Item_Description__c = 'This is test item description.';
        
        Test.startTest();
        
        	update lines;
        
        Test.stopTest();
    }

}