public class SalesOrderCopyProductsHandler {
    /*
    public static void updateLineItems(LIST<AcctSeedERP__Sales_Order__c> triggerData){
        
        // Delet all the previous sales order line items
        
        LIST<AcctSeedERP__Sales_Order_Line__c> solitemDelete = [select Id from AcctSeedERP__Sales_Order_Line__c where AcctSeedERP__Sales_Order__c=:triggerData[0].Id];
        
        if(solitemDelete.size() > 0){
            
            delete solitemDelete;
            
        }
        // get all opportunity line items
        LIST<OpportunityLineItem> oli = [select Id, Name, Quantity, Product2Id, TotalPrice, UnitPrice, ListPrice, Description from OpportunityLineItem where OpportunityId=:triggerData[0].AcctSeedERP__Opportunity__c];
        // get all sales order line items
        LIST<AcctSeedERP__Sales_Order_Line__c> solitem = new LIST<AcctSeedERP__Sales_Order_Line__c>();

        // iterate over the oli and populate the soli list
        for(OpportunityLineItem oLineItem : oli){
            
            AcctSeedERP__Sales_Order_Line__c soLineItem = new AcctSeedERP__Sales_Order_Line__c();
            
            soLineItem.AcctSeedERP__Sales_Order__c = triggerData[0].Id;
            // soLineItem.AcctSeedERP__Total__c = oLineItem.TotalPrice; // field is not writable
            soLineItem.AcctSeedERP__Unit_Price__c = oLineItem.UnitPrice;
            soLineItem.AcctSeedERP_Description__c = oLineItem.Description;
            soLineItem.AcctSeedERP__Opportunity_Product_Id__c = oLineItem.Id;
            soLineItem.AcctSeedERP__Quantity_Ordered__c = oLineItem.Quantity;
            soLineItem.AcctSeedERP__Product__c = oLineItem.Product2Id;
            
            solitem.add(soLineItem);
            
        }
        
        insert solitem;
    }
    */
}