public class SalesOrderLineUpdateDeleteHandler {
    
    public static void UpdateCase(List<AcctSeedERP__Sales_Order_Line__c> data){
        
        map<id, AcctSeedERP__Sales_Order_Line__c> solMap = new map<id, AcctSeedERP__Sales_Order_Line__c>(data);
        
        List<AcctSeed__Billing_Line__c> billingLines = [select id, AcctSeed__Date__c, 
                                                        AcctSeed__GL_Account_Variable_1__c,
                                                        AcctSeed__GL_Account_Variable_2__c, 
                                                        AcctSeed__GL_Account_Variable_3__c,
                                                        AcctSeedERP__Sales_Order_Line__c,
                                                        AcctSeed__GL_Account_Variable_4__c, 
                                                        AcctSeed__Hours_Units__c,
                                                        AcctSeed__Product__c,AcctSeed__Rate__c,
                                                        Item_Description__c
                                                        from AcctSeed__Billing_Line__c where 
                                                        AcctSeedERP__Sales_Order_Line__c
                                                        in:solMap.KeySet() and 
                                                        AcctSeed__Billing__r.AcctSeed__Status__c != 'Posted'];
        
        if(!billingLines.IsEmpty()){
            
            for(AcctSeed__Billing_Line__c line : billingLines){
                
                AcctSeedERP__Sales_Order_Line__c soline = solMap.get(line.AcctSeedERP__Sales_Order_Line__c);
                
                line.Item_Description__c = soLine.Item_Description__c;                                                 
                
            }

            update billingLines;
        }
    }
}