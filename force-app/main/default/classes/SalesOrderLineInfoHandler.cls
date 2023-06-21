public class SalesOrderLineInfoHandler {
    
    public static void UpdateInfo(List<AcctSeedERP__Sales_Order_Line__c> sol){
	/*
        for(AcctSeedERP__Sales_Order_Line__c so : sol){
            
            // get the opp product id and copy the fields to sol fields
            
            List<OpportunityLineItem> oli = [select ProductCode, Item_Description__c, Size__c, Quantity, UnitPrice, TotalPrice from OpportunityLineItem where Id =: so.AcctSeedERP__Opportunity_Product_Id__c];
            
            if(!oli.isEmpty()){
                
                // so.Product_Code__c = oli[0].ProductCode;
                so.Item_Description__c = oli[0].Item_Description__c;
                so.Size__c = oli[0].Size__c;
                so.Quantity__c = oli[0].Quantity;
                so.AcctSeedERP__Unit_Price__c = oli[0].UnitPrice;
                //so.Total_Price__c = oli[0].TotalPrice;
                
            }
        }
        */
    }
}