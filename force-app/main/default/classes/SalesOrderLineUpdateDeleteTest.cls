@isTest
public class SalesOrderLineUpdateDeleteTest {
    
    @testSetup static void createData(){
        
        TestUtility.CreateData();
        
    }
    
    @isTest static void UpdateCase(){
        
        Opportunity opp = [select id from opportunity where name='myOpportunity' limit 1];
        
        Acctseederp__sales_order__c so = [select id from acctseederp__sales_order__c 
                                          where acctseederp__opportunity__c =:opp.id limit 1];
        
        // get the sales order lines list
        List<acctseederp__sales_order_line__c> solinelist = new list<acctseederp__sales_order_line__c>([select id,
                                                    AcctSeedERP__Unit_Price__c 
                                                    from acctseederp__sales_order_line__c 
                                                    where acctseederp__sales_order__c =: so.id]);
        
        
        solineList[0].AcctSeedERP__Unit_Price__c = 10;
        
        update solineList;
        
        
        
    }
}