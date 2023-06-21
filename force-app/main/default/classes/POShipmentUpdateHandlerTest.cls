@isTest
public class POShipmentUpdateHandlerTest {
    
    @testSetup static void createData(){
        
        TestUtility.CreateData();
    }
	
    @isTest static void testShipment(){
        
        Opportunity oppty = [select id from opportunity where name = 'myOpportunity' limit 1];
        
        AcctseedErP__Sales_Order__c order = [select id from AcctSeedErP__Sales_Order__c where AcctSeedERP__opportunity__c =:
                                            oppty.id limit 1];
        
        AcctSeedERP__Shipment__c shipment = [select id from AcctSeedErP__Shipment__c where AcctSeedERP__Sales_Order__c =:
                                            order.id limit 1];
        
        PO_Shipment__c shipments = [select id, Comment__c from PO_Shipment__c 
                                            where Shipment__c =: shipment.id limit 1];
        shipments.Comment__c = 'Test Shipping Comment';
        
        update shipments;
    }
    @isTest static void testShipmentLines(){
        
        Opportunity oppty = [select id from opportunity where name = 'myOpportunity' limit 1];
        Opportunity oppty2 = [select id from opportunity where name = 'myOpportunity2' limit 1];
        
        AcctseedErP__Sales_Order__c order = [select id from AcctSeedErP__Sales_Order__c where AcctSeedERP__opportunity__c =:
                                            oppty.id limit 1];
        
        AcctSeedERP__Shipment__c shipment = [select id from AcctSeedErP__Shipment__c where AcctSeedERP__Sales_Order__c =:
                                            order.id limit 1];
        
        PO_Shipment__c shipments = [select id, Comment__c, sales_order__c from PO_Shipment__c 
                                            where Shipment__c =: shipment.id limit 1];
        shipments.sales_order__c = null;
        
        update shipments;
        
        shipments.sales_order__c = order.id;
        
        update shipments;
    }
    @isTest static void testNewShipment(){
        
        Opportunity oppty = [select id from opportunity where name = 'myOpportunity' limit 1];
        
        AcctseedErP__Sales_Order__c order = [select id from AcctSeedErP__Sales_Order__c where AcctSeedERP__opportunity__c =:
                                            oppty.id limit 1];
        AcctSeedErp__purchase_Order__c porder = [select id from AcctSeedErP__Purchase_Order__c where 
                                                 Sales_Order__c =:
                                            order.id Limit 1];
        
        PO_Shipment__c shipments = new PO_Shipment__c();
        
        shipments.Sales_Order__c = order.id;
        SHIPMENTS.Purchase_Order__c = porder.id;
        shipments.Status__c = 'Shipped';
        
        insert shipments;
 
    }
}