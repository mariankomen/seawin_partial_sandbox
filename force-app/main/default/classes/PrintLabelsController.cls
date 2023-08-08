/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-11-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class PrintLabelsController {
    
    public class PrintLabelsControllerException extends Exception {}

    
    @AuraEnabled
    public static string getRecordLines(String recordId){
        try {
            String sObjectType = String.valueOf(Id.valueOf(recordId).getSObjectType());
            String shortSObjectName = getSObjectShortName(recordId);
            List<IterableItem> recordLinesWrapper = new List<IterableItem>();
            List<TemplateWrapper> templates = getProductTemplates();

            if(sObjectType == 'PO_Shipment__c'){
                recordLinesWrapper = createPOShipmentLinesWrapper(recordId);
            }else if(sObjectType == 'AcctSeedERP__Shipment__c'){
                recordLinesWrapper = createShipmentLinesWrapper(recordId);
            }else if(sObjectType == 'AcctSeedERP__Sales_Order__c'){
                recordLinesWrapper = createSOLinesWrapper(recordId);
            }else if(sObjectType == 'Product2'){
                recordLinesWrapper = createProductWrapper(recordId);
            }else if(sObjectType == 'AcctSeedERP__Inventory_Balance__c'){
                recordLinesWrapper = createPOIMWrapper(recordId);
            }else{
                throw new PrintLabelsControllerException('Invalid SObject Type.');
            }

            for(IterableItem item: recordLinesWrapper){
                item.productTemplates = templates;
            }
            return JSON.serialize(recordLinesWrapper);
        } catch (Exception e) {
            throw new PrintLabelsControllerException(e.getMessage());
        }
    }

    private static String getSObjectShortName(String recordId){
        String sObjectType = String.valueOf(Id.valueOf(recordId).getSObjectType());
        String shortSObjectName;
        if(sObjectType == 'PO_Shipment__c'){
            shortSObjectName = 'POSHIP';
        }else if(sObjectType == 'AcctSeedERP__Shipment__c'){
            shortSObjectName = 'SHIP';
        }else if(sObjectType == 'AcctSeedERP__Sales_Order__c'){
            shortSObjectName = 'SO';
        }else if(sObjectType == 'Product2'){
            shortSObjectName = 'PRODUCT';
        }else if(sObjectType == 'AcctSeedERP__Inventory_Balance__c'){
            shortSObjectName = 'POIM';
        }else{
            throw new PrintLabelsControllerException('Invalid SObject Type.');
        }

        return shortSObjectName;
    }

    private static List<TemplateWrapper> getProductTemplates(){
        List<Product_Label_Template__c> templ = [SELECT Id, Name, Visualforce_Page__c FROM Product_Label_Template__c];

        List<TemplateWrapper> wrap = new List<TemplateWrapper>();
        for(Product_Label_Template__c template: templ){
            wrap.add(new TemplateWrapper(template.Name, template.Name));
        }

        return wrap;
    }
    private static List<IterableItem> createPOShipmentLinesWrapper(String recordId){
        List<IterableItem> recordLinesWrapper = new List<IterableItem>();

        List<PO_Shipment_Line__c> poShipmentLines = [SELECT Id, Product__c,
                                                            Product__r.ProductCode,
                                                            Product__r.Name,
                                                            Product__r.Product_Label_Template__r.Visualforce_Page__c,
                                                            Product__r.Product_Label_Template__r.Name,
                                                            Description__c,
                                                            Size__c,
                                                            Quantity_Shipped__c,
                                                            Total_Price__c
                                                            FROM PO_Shipment_Line__c
                                                            WHERE PO_Shipment__c =:recordId];
        for(PO_Shipment_Line__c posl: poShipmentLines){
            recordLinesWrapper.add(new IterableItem(
                posl.Id,
                posl.Product__c,
                posl.Product__r.Name,
                posl.Product__r.ProductCode,
                posl.Description__c,
                posl.Size__c,
                posl.Quantity_Shipped__c,
                posl.Total_Price__c,
                posl.Product__r.Product_Label_Template__r.Name
            ));
        }   
        return recordLinesWrapper;                                                
    }

    private static List<IterableItem> createShipmentLinesWrapper(String recordId){
        List<IterableItem> recordLinesWrapper = new List<IterableItem>();

        List<AcctSeedERP__Shipment_Line__c> poShipmentLines = [SELECT Id, AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__c,
                                                                            AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.ProductCode,
                                                                            AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Name,
                                                                            AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Product_Label_Template__r.Visualforce_Page__c,
                                                                            AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Product_Label_Template__r.Name,
                                                                            AcctSeedERP__Sales_Order_Line__r.Item_Description__c,
                                                                            AcctSeedERP__Sales_Order_Line__r.Size__c,
                                                                            AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Unit_Price__c,
                                                                            Quantity_Shipped__c
                                                            FROM AcctSeedERP__Shipment_Line__c
                                                            WHERE AcctSeedERP__Shipment__c =:recordId];
        for(AcctSeedERP__Shipment_Line__c posl: poShipmentLines){
            recordLinesWrapper.add(new IterableItem(
                posl.Id,
                posl.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__c,
                posl.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Name,
                posl.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.ProductCode,
                posl.AcctSeedERP__Sales_Order_Line__r.Item_Description__c,
                posl.AcctSeedERP__Sales_Order_Line__r.Size__c,
                posl.Quantity_Shipped__c,
                posl.Quantity_Shipped__c * posl.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Unit_Price__c,
                posl.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Product_Label_Template__r.Name
            ));
        } 

        return recordLinesWrapper;
    }

    private static List<IterableItem> createSOLinesWrapper(String recordId){
        List<IterableItem> recordLinesWrapper = new List<IterableItem>();

        List<AcctSeedERP__Sales_Order_Line__c> lines = [SELECT Id, 
                                                            AcctSeedERP__Product__c, 
                                                            AcctSeedERP__Product__r.ProductCode, 
                                                            AcctSeedERP__Product__r.Name, 
                                                            AcctSeedERP__Product__r.Product_Label_Template__r.Visualforce_Page__c, 
                                                            AcctSeedERP__Product__r.Product_Label_Template__r.Name, 
                                                            Item_Description__c, 
                                                            Size__c, 
                                                            AcctSeedERP__Quantity_Ordered__c, 
                                                            AcctSeedERP__Total__c 
                                                            FROM AcctSeedERP__Sales_Order_Line__c
                                                            WHERE AcctSeedERP__Sales_Order__c=:recordId
                                                            AND AcctSeedERP__Product__r.AcctSeed__Inventory_Product__c = true];
                                                            
        for(AcctSeedERP__Sales_Order_Line__c sol: lines){
            recordLinesWrapper.add(new IterableItem(
                sol.Id,
                sol.AcctSeedERP__Product__c,
                sol.AcctSeedERP__Product__r.Name,
                sol.AcctSeedERP__Product__r.ProductCode,
                sol.Item_Description__c,
                sol.Size__c,
                sol.AcctSeedERP__Quantity_Ordered__c,
                sol.AcctSeedERP__Total__c,
                sol.AcctSeedERP__Product__r.Product_Label_Template__r.Name
            ));
        }
        
        return recordLinesWrapper;
    }

    private static List<IterableItem> createProductWrapper(String recordId){
        List<IterableItem> recordLinesWrapper = new List<IterableItem>();

        List<Product2> products = [SELECT Id, 
                                        ProductCode, 
                                        Name, 
                                        Product_Label_Template__r.Visualforce_Page__c, 
                                        Description,
                                        Size__c,
                                        AcctSeed__Unit_Cost__c
                                        FROM Product2
                                        WHERE Id=:recordId];
        for(Product2 posl: products){
            recordLinesWrapper.add(new IterableItem(
                posl.Id,
                posl.Id,
                posl.Name,
                posl.ProductCode,
                posl.Description,
                posl.Size__c,
                0,
                0,
                posl.Product_Label_Template__r.Name
            ));
        }

        return recordLinesWrapper;
    }


    private static List<IterableItem> createPOIMWrapper(String recordId){
        List<IterableItem> recordLinesWrapper = new List<IterableItem>();

        List<AcctSeedERP__Purchase_Order_Inventory_Movement__c> poShipmentLines = [SELECT Id, AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__c,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.ProductCode,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Name,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Product_Label_Template__r.Name,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Product_Label_Template__r.Visualforce_Page__c,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.Description__c,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.Size__c,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Unit_Price__c,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.Total_Price__c,
                                                                                    AcctSeedERP__Quantity__c
                                                            FROM AcctSeedERP__Purchase_Order_Inventory_Movement__c
                                                            WHERE AcctSeedERP__Inventory_Balance__c =:recordId];
        for(AcctSeedERP__Purchase_Order_Inventory_Movement__c posl: poShipmentLines){
            recordLinesWrapper.add(new IterableItem(
                posl.Id,
                posl.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__c,
                posl.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Name,
                posl.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.ProductCode,
                posl.AcctSeedERP__Purchase_Order_Line__r.Description__c,
                posl.AcctSeedERP__Purchase_Order_Line__r.Size__c,
                posl.AcctSeedERP__Quantity__c,
                posl.AcctSeedERP__Purchase_Order_Line__r.Total_Price__c,
                posl.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Product_Label_Template__r.Name
            ));
        } 

        return recordLinesWrapper;
    }



    @AuraEnabled    
    public static List<String> getTemplateLabelsData(String data, String recordId){
        try{
            List<IterableItem> labelItems = (List<IterableItem>)JSON.deserialize(data, List<IterableItem>.class);
            String shortSObjectName = getSObjectShortName(recordId);
            List<String> listOfFiles = new  List<String>();
    
            for(IterableItem item: labelItems){
                // payload = String.escapeSingleQuotes(payload);
                RenderLabelItem renderItem = new RenderLabelItem(
                    item.lineId,
                    item.productId,
                    item.selectedTemplate
                );
                String payload = JSON.serialize(new List<RenderLabelItem>{renderItem});
                system.debug('payload: '+payload);
                Blob content = !Test.isRunningTest() ? new PageReference('/apex/ProductLabel3x4Pages?data='+payload+'&shortSObjectName='+shortSObjectName).getContent() : Blob.valueof('Some random String');
                for(Integer i = 0; i<item.copiesCount; i++){
                    listOfFiles.add(EncodingUtil.base64Encode(content));
                }
            }
    
            return listOfFiles;
        }catch(Exception e){
            throw new PrintLabelsControllerException(e.getMessage());
        }
        
    }

    public class RenderLabelItem{
        public String lineId {get;set;}
        public String productId {get;set;}
        public String selectedTemplate {get;set;}
        public Integer copiesCount {get;set;}

        public RenderLabelItem(String lineId, String productId, String selectedTemplate){
            this.lineId = lineId;
            this.productId = productId;
            this.selectedTemplate = selectedTemplate;
            this.copiesCount = 1;
        }
    }
    public class IterableItem{
        public String lineId {get;set;}
        public String productId {get;set;}
        public String productName {get;set;}
        public String productCode {get;set;}
        public String itemDescription {get;set;}
        public String itemSize {get;set;}
        public Decimal quantity {get;set;}
        public Decimal total {get;set;}
        public String selectedTemplate {get;set;}
        public Integer copiesCount {get;set;}
        public List<TemplateWrapper> productTemplates {get;set;}

        public IterableItem(String lineId, String productId, String productName, String productCode, String itemDescription, String itemSize, Decimal quantity, Decimal total, String selectedTemplate){
            this.lineId = lineId;
            this.productId = productId;
            this.productName = productName;
            this.productCode = productCode;
            this.itemDescription = itemDescription;
            this.itemSize = itemSize;
            this.quantity = quantity;
            this.total = total;
            this.selectedTemplate = selectedTemplate;
            this.copiesCount = Integer.valueOf(quantity);

        }
    }

    public class TemplateWrapper{
        public String label {get;set;}
        public String value {get;set;}

        public TemplateWrapper(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
}