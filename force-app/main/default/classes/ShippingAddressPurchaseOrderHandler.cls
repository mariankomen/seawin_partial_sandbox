public class ShippingAddressPurchaseOrderHandler {
    
    public static void Process(List<AcctSeedERP__Purchase_Order__c> od, List<AcctSeedERP__Purchase_Order__c> nd){
        
        // map<id, AcctSeed__Accounting_Variable__c> avMap = new map<id, AcctSeed__Accounting_Variable__c>([select id, Shipping_Company__c, Shipping_Contact__c, street__c, city__c, 
        //                                                                                                  state__c, postal_code__c, country__c
        //                                                   													from AcctSeed__Accounting_Variable__c]);
     
        map<id, AcctSeedERP__Purchase_Order__c> PurchaseOrderMap = new map<id, AcctSeedERP__Purchase_Order__c>();
        Integer i = 0;
        for(AcctSeedERP__Purchase_Order__c po : nd){
         	
            if(od.isEmpty() || po.AcctSeedERP__Type__c != od[i].AcctSeedERP__Type__c){
                
                PurchaseOrderMap.put(po.id, po);
            }
            
            i++;
        }
        
        if(PurchaseOrderMap.size() > 0){
            
            List<AcctSeedERP__Purchase_Order__c> orders = [select id, 
                                                          AcctSeedERP__Type__c,
                                                          Sales_Order__r.Shipping_Account__c,
                                                          Sales_Order__r.Shipping_Name__c,
                                                          Sales_Order__r.AcctSeedERP__Shipping_Street__c,
                                                          Sales_Order__r.AcctSeedERP__Shipping_City__c,
                                                          Sales_Order__r.AcctSeedERP__Shipping_State__c,
                                                          Sales_Order__r.AcctSeedERP__Shipping_PostalCode__c,
                                                          Sales_Order__r.AcctSeedERP__Shipping_Country__c,
                                                          GL_Account_Variable_1__r.Street__c,
                                                          GL_Account_Variable_1__r.City__c,
                                                          GL_Account_Variable_1__r.Shipping_Company__c,
                                                          GL_Account_Variable_1__r.Shipping_Contact__c,
                                                          GL_Account_Variable_1__r.State__c,
                                                          GL_Account_Variable_1__r.Postal_Code__c,
                                                          GL_Account_Variable_1__r.Country__c,
                                                          AcctSeedERP__Shipping_Street__c,
                                                          AcctSeedERP__Shipping_City__c,
                                                          AcctSeedERP__Shipping_State__c,
                                                          AcctSeedERP__Shipping_Postal_Code__c, 
                                                          AcctSeedERP__Shipping_Country__c,
                                                          AcctSeedERP__Shipping_Company__r.ShippingStreet,
                                                          AcctSeedERP__Shipping_Company__r.ShippingCity,
                                                          AcctSeedERP__Shipping_Company__r.ShippingState,
                                                          AcctSeedERP__Shipping_Company__r.ShippingPostalCode, 
                                                          AcctSeedERP__Shipping_Company__r.ShippingCountry
                                                          from AcctSeedERP__Purchase_Order__c
                                                          where id in:PurchaseOrderMap.keyset()];
            
            
            for(AcctSeedERP__Purchase_Order__c p : orders){
                
                p.AcctSeedERP__Shipping_Company__c = p.AcctSeedERP__Type__c == 'Standard' ? 
                p.GL_Account_Variable_1__r.Shipping_Company__c : p.Sales_Order__c != null ? p.Sales_Order__r.Shipping_Account__c : null;

                p.AcctSeedERP__Shipping_Contact__c = p.AcctSeedERP__Type__c == 'Standard' ? 
                p.GL_Account_Variable_1__r.Shipping_Contact__c : p.Sales_Order__c != null ? p.Sales_Order__r.Shipping_Name__c : null;

                p.AcctSeedERP__Shipping_Street__c = p.AcctSeedERP__Type__c == 'Standard' ? 
                    p.GL_Account_Variable_1__r.Street__c : p.Sales_Order__c != null ? 
                        p.Sales_Order__r.AcctSeedERP__Shipping_Street__c : p.AcctSeedERP__Shipping_Company__r.ShippingStreet;
                
                p.AcctSeedERP__Shipping_City__c = p.AcctSeedERP__Type__c == 'Standard' ? 
                    p.GL_Account_Variable_1__r.City__c : p.Sales_Order__c != null ? 
                        p.Sales_Order__r.AcctSeedERP__Shipping_City__c : p.AcctSeedERP__Shipping_Company__r.ShippingCity;
                
                p.AcctSeedERP__Shipping_State__c = p.AcctSeedERP__Type__c == 'Standard' ? 
                    p.GL_Account_Variable_1__r.State__c : p.Sales_Order__c != null ? 
                        p.Sales_Order__r.AcctSeedERP__Shipping_State__c : p.AcctSeedERP__Shipping_Company__r.ShippingState;
                
                p.AcctSeedERP__Shipping_Postal_Code__c = p.AcctSeedERP__Type__c == 'Standard' ? 
                    p.GL_Account_Variable_1__r.Postal_Code__c : p.Sales_Order__c != null ? 
                        p.Sales_Order__r.AcctSeedERP__Shipping_PostalCode__c : p.AcctSeedERP__Shipping_Company__r.ShippingPostalCode;
                
                p.AcctSeedERP__Shipping_Country__c = p.AcctSeedERP__Type__c == 'Standard' ? 
                    p.GL_Account_Variable_1__r.Country__c : p.Sales_Order__c != null ? 
                        p.Sales_Order__r.AcctSeedERP__Shipping_Country__c : p.AcctSeedERP__Shipping_Company__r.ShippingCountry;    
                        
                
            }
            
            if(!orders.isEmpty()) update orders;
        }
    }
}