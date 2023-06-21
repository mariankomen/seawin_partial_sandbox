@isTest
public class ShipmentLineUpdateHandlerTest {
    
    @testSetup static void createData(){
        
        TestUtility.CreateData();
    }
	
    @isTest static void testShipment(){
        
        Opportunity oppty = [select id from opportunity where name = 'myOpportunity' limit 1];
        
        AcctseedErP__Sales_Order__c order = [select id from AcctSeedErP__Sales_Order__c where AcctSeedERP__opportunity__c =:
                                            oppty.id limit 1];
        
        AcctseedERP__Shipment__c shipment = [select id from AcctseedERP__Shipment__c 
                                            where AcctSeederp__Sales_Order__c =: order.id limit 1];
        
        AcctseedERP__Shipment_Line__c shipmentLine = [select id, AcctSeedErP__Quantity_Shipped__c from 
                                                      AcctseedERP__Shipment_Line__c 
                                            where AcctSeederp__Shipment__c =: shipment.id limit 1];
        
        shipmentLine.AcctSeedERP__Quantity_Shipped__c = 0.5;
        update shipmentLine;
        
    }
}