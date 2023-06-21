@isTest
public class ShipmentUpdateHandlerTest {
    
    @testSetup static void createData(){
        
        TestUtility.CreateData();
    }
	
    @isTest static void testShipment(){
        
        Opportunity oppty = [select id from opportunity where name = 'myOpportunity' limit 1];
        
        AcctseedErP__Sales_Order__c order = [select id from AcctSeedErP__Sales_Order__c where AcctSeedERP__opportunity__c =:
                                            oppty.id limit 1];
        
        AcctseedERP__Shipment__c shipment = [select id, AcctSeederp__Shipping_Comment__c from AcctseedERP__Shipment__c 
                                            where AcctSeederp__Sales_Order__c =: order.id limit 1];
        shipment.AcctSeedERP__Shipping_Comment__c = 'Test Shipping Comment';
        
        update shipment;
    }
}