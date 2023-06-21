@isTest
public class POShipmentLineUpdateHandlerTest {
    
    @testSetup static void createData(){
        
        TestUtility.CreateData();
    }
	
    @isTest static void testShipment(){
        
        Opportunity oppty = [select id from opportunity where name = 'myOpportunity' limit 1];
        
        AcctseedErP__Sales_Order__c order = [select id from AcctSeedErP__Sales_Order__c where AcctSeedERP__opportunity__c =:
                                            oppty.id limit 1];
        
        PO_Shipment__c shipment = [select id from PO_Shipment__c 
                                            where Sales_Order__c =: order.id limit 1];
        
        po_Shipment_Line__c shipmentLine = [select id, Quantity_Shipped__c from 
                                                      po_Shipment_Line__c 
                                            where po_Shipment__c =: shipment.id limit 1];
        
        shipmentLine.Quantity_Shipped__c = 0.5;
        update shipmentLine;
        
    }
}