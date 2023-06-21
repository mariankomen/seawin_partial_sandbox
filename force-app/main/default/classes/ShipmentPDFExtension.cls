public class ShipmentPDFExtension {
    
    public string headerUrl {get; set;}
    public string footerUrl {get; set;}
    public Id shpId {get; set;}
    public AcctSeedERP__Sales_Order__c so {get; set;}
    
    public list<wrapper> shipmentWrap {get; set;}
    public Decimal total {get; set;}
    public AcctSeedERP__Shipment__c shipment {get; set;}
    
    
    public ShipmentPDFExtension(ApexPages.StandardController std){
        
        shpId = (Id)std.getId();
        
        shipment = [select Name, CreatedBy.name, CreatedDate,GL_Account_Variable_1__c, 
                    AcctSeedERP__Shipment_Date__c, AcctSeedERP__Shipping_Reference__c,
                    AcctSeedERP__Carrier__r.name,Carrier__r.name,AcctSeedERP__Sales_Order__c,AcctSeedERP__Sales_Order__r.Name,
                    tracking_number__c
                    from AcctSeedERP__Shipment__c where id=:shpId limit 1];
        so = new AcctSeedERP__Sales_Order__c();
        total = 0.00;
        
        // get the shipping lines and the associated sales order lines information
        
        List<AcctSeedERP__Shipment_Line__c> shpLines = [SELECT Id, Name, AcctSeedERP__Sales_Order_Line__c,
                                                        AcctSeedERP__Quantity_Shipped__c, Quantity_Shipped__c
                                                        FROM AcctSeedERP__Shipment_Line__c where
                                                        AcctSeedERP__Shipment__c =:shpId];
        
        if(!shpLines.IsEmpty()){
            
            // create a map of key:sales-order-line and value:shipment-line
            map<id, AcctSeedERP__Shipment_Line__c> shpMap = new map<id, AcctSeedERP__Shipment_Line__c>();
            for(AcctSeedERP__Shipment_Line__c line : shplines){
                shpMap.put(line.AcctSeedERP__Sales_Order_Line__c, line);
                
            }
            
            if(shpMap.size() > 0){
                // get the sales-order-lines in reqId
                
                list<AcctSeedERP__Sales_Order_line__c> slines = [select id, AcctSeedERP__Sales_Order__c, size__c,
                                                                 Sales_Price__c,
                                                                 Total_Price__c,AcctSeedERP__Quantity_Ordered__c,
                                                                 AcctSeedERP_Description__c, 
                                                                 AcctSeedERP__Product__r.Name,
                                                                 AcctSeedERP__Product__r.ProductCode,
                                                                 AcctSeedERP__PRoduct__r.ProductImageURL__c
                                                                 from AcctSeedERP__Sales_Order_line__c where 
                                                                 id in:shpMap.keyset()];
                
                if(!slines.isEmpty()){
                    
                    // create and populate the wrapper class list
                    shipmentWrap = new list<Wrapper>();
                    Integer k = 1;
                    
                    for(AcctSeedERP__Sales_Order_line__c sline : slines){
                        
                        // get the shipment line to get the quantity from map
                        AcctSeedERP__Shipment_Line__c shpl = shpMap.get(sline.id);
                        
                        if(shpl == null) continue;
                        
                        total += shpl.Quantity_Shipped__c * sline.Sales_Price__c; 
                        
                        shipmentWrap.add(new wrapper(sline, shpl));
                        
                        k++;
                    }
                    
                    // get the sales order details
                    if(shipment.AcctSeedERP__Sales_Order__c != null){
                        so = [SELECT Id, Name,Shipping_Account__c,Shipping_Account__r.name, 
                              AcctSeedERP__Billing_City__c, 
                              AcctSeedERP__Billing_Country__c, 
                              AcctSeedERP__Billing_PostalCode__c, 
                              AcctSeedERP__Billing_State__c, 
                              AcctSeedERP__Billing_Street__c, 
                              AcctSeedERP__Customer__r.name, 
                              AcctSeedERP__Opportunity__r.name, 
                              AcctSeedERP__Shipping_City__c, 
                              AcctSeedERP__Shipping_Country__c, 
                              AcctSeedERP__Shipping_PostalCode__c, 
                              AcctSeedERP__Shipping_State__c, 
                              AcctSeedERP__Shipping_Street__c, 
                              Contact__r.Name, Contact__r.Email, Contact__r.Phone FROM AcctSeedERP__Sales_Order__c
                              where id =: shipment.AcctSeedERP__Sales_Order__c limit 1];
                        
                        if(so.Shipping_Account__c != null){
                            
                            // get the shipping details
                            list<account> subCustomer = [SELECT Id, ShippingStreet, ShippingCity, 
                                                         ShippingState, ShippingPostalCode, 
                                                         ShippingCountry FROM Account
                                                         where id =:so.Shipping_Account__c limit 1];
                            
                            if(!subCustomer.IsEmpty()){
                                
                                so.AcctSeedERP__Shipping_Street__c = subCustomer[0].ShippingStreet;
                                so.AcctSeedERP__Shipping_city__c = subCustomer[0].ShippingCity;
                                so.AcctSeedERP__Shipping_state__c = subCustomer[0].ShippingState;
                                so.AcctSeedERP__Shipping_postalcode__c = subCustomer[0].ShippingPostalCode;
                                so.AcctSeedERP__Shipping_country__c = subCustomer[0].Shippingcountry;
                                
                            }
                        }
                    }
                }
                
            }
            
        }


        // PDF Logic
        List<AcctSeed__Accounting_Variable__c> glData = [Select Shipping_Header__c, Shipping_Footer__c, Shipping_Terms__c From AcctSeed__Accounting_Variable__c Where Name = :shipment.GL_Account_Variable_1__c];

        if(glData.size() > 0){
            headerUrl = getImageURL(glData[0].Shipping_Header__c);
            footerUrl = getImageURL(glData[0].Shipping_Footer__c);     
        }
    }


    public string getImageURL(string url){

        try{
            String imageURL = '';
            Matcher imgMatcher = Pattern.compile('<img(.+?)>').matcher(url);
            if(imgMatcher.find()) {
                String imageTag = imgMatcher.group();
                imageURL= imageTag.substringBetween(' src="', '"');
            }
            
            return imageURL.unescapeHtml4();
        }
        catch(Exception e){
            return e.getMessage() + e.getLineNumber();
        }
    }
    
    
    public class Wrapper {
        
        public AcctSeedERP__Sales_Order_Line__c line {get; set;}
        public AcctSeedERP__Shipment_Line__c sline {get; set;}
        
        public wrapper(AcctSeedERP__Sales_Order_Line__c l, AcctSeedERP__Shipment_Line__c sl){
            
            line = l;
            sline = sl;
            
        }
        
        
    }
    
}