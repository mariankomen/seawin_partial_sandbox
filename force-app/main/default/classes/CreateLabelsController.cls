public with sharing class CreateLabelsController {
    public String recordId {get;set;}
    public List<IterableItem> wrappedLines {get;set;}
    public List<SelectOption> templates {get;set;}
    public List<String> templateContent {get;set;}

    public String shortSObjectName {get;set;}
    public CreateLabelsController() {


        templateContent = new List<String>();
        wrappedLines = new List<IterableItem>();
        templates = new List<SelectOption>();

        recordId = ApexPages.currentPage().getParameters().get('recordId'); //PO or SO Id.
        String SObjectType = String.valueOf(Id.valueOf(recordId).getSObjectType());
        
        system.debug('SObjectType: '+SObjectType);

        if(SObjectType == 'PO_Shipment__c'){
            createPOShipmentLinesWrapper();
            shortSObjectName = 'POSHIP';
        }else if(SObjectType == 'AcctSeedERP__Shipment__c'){
            createShipmentLinesWrapper();
            shortSObjectName = 'SHIP';
        }else if(SObjectType == 'AcctSeedERP__Sales_Order__c'){
            createSOLinesWrapper();
            shortSObjectName = 'SO';
        }else if(SObjectType == 'Product2'){
            createProductWrapper();
            shortSObjectName = 'PRODUCT';
        }else if(SObjectType == 'AcctSeedERP__Inventory_Balance__c'){
            createPOIMWrapper();
            shortSObjectName = 'POIM';
        }

        fetchProductLabelTemplate();
    }
    public void fetchProductLabelTemplate(){
        List<Product_Label_Template__c> templ = [SELECT Id, Name, Visualforce_Page__c FROM Product_Label_Template__c];
        for(Product_Label_Template__c t: templ){
            templates.add(new SelectOption(t.Visualforce_Page__c, t.Name));
        }
    }
    public void createPOIMWrapper(){
        List<AcctSeedERP__Purchase_Order_Inventory_Movement__c> poShipmentLines = [SELECT Id, AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__c,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.ProductCode,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Name,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Product_Label_Template__r.Visualforce_Page__c,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.Description__c,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.Size__c,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Unit_Price__c,
                                                                                    AcctSeedERP__Purchase_Order_Line__r.Total_Price__c,
                                                                                    AcctSeedERP__Quantity__c
                                                            FROM AcctSeedERP__Purchase_Order_Inventory_Movement__c
                                                            WHERE AcctSeedERP__Inventory_Balance__c =:recordId];
        for(AcctSeedERP__Purchase_Order_Inventory_Movement__c posl: poShipmentLines){
            wrappedLines.add(new IterableItem(
                posl.Id,
                posl.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__c,
                posl.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Name,
                posl.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.ProductCode,
                posl.AcctSeedERP__Purchase_Order_Line__r.Description__c,
                posl.AcctSeedERP__Purchase_Order_Line__r.Size__c,
                posl.AcctSeedERP__Quantity__c,
                posl.AcctSeedERP__Purchase_Order_Line__r.Total_Price__c,
                posl.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Product_Label_Template__r.Visualforce_Page__c
            ));
        } 
    }
    public void createProductWrapper(){
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
            wrappedLines.add(new IterableItem(
                posl.Id,
                posl.Id,
                posl.Name,
                posl.ProductCode,
                posl.Description,
                posl.Size__c,
                0,
                0,
                posl.Product_Label_Template__r.Visualforce_Page__c
            ));
        }
    }
    public void createShipmentLinesWrapper(){
        List<AcctSeedERP__Shipment_Line__c> poShipmentLines = [SELECT Id, AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__c,
                                                                            AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.ProductCode,
                                                                            AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Name,
                                                                            AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Product_Label_Template__r.Visualforce_Page__c,
                                                                            AcctSeedERP__Sales_Order_Line__r.Item_Description__c,
                                                                            AcctSeedERP__Sales_Order_Line__r.Size__c,
                                                                            AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Unit_Price__c,
                                                                            Quantity_Shipped__c
                                                            FROM AcctSeedERP__Shipment_Line__c
                                                            WHERE AcctSeedERP__Shipment__c =:recordId];
        for(AcctSeedERP__Shipment_Line__c posl: poShipmentLines){
            wrappedLines.add(new IterableItem(
                posl.Id,
                posl.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__c,
                posl.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Name,
                posl.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.ProductCode,
                posl.AcctSeedERP__Sales_Order_Line__r.Item_Description__c,
                posl.AcctSeedERP__Sales_Order_Line__r.Size__c,
                posl.Quantity_Shipped__c,
                posl.Quantity_Shipped__c * posl.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Unit_Price__c,
                posl.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Product_Label_Template__r.Visualforce_Page__c
            ));
        } 
    }
    public void createPOShipmentLinesWrapper(){
        List<PO_Shipment_Line__c> poShipmentLines = [SELECT Id, Product__c,
                                                            Product__r.ProductCode,
                                                            Product__r.Name,
                                                            Product__r.Product_Label_Template__r.Visualforce_Page__c,
                                                            Description__c,
                                                            Size__c,
                                                            Quantity_Shipped__c,
                                                            Total_Price__c
                                                            FROM PO_Shipment_Line__c
                                                            WHERE PO_Shipment__c =:recordId];
        for(PO_Shipment_Line__c posl: poShipmentLines){
            wrappedLines.add(new IterableItem(
                posl.Id,
                posl.Product__c,
                posl.Product__r.Name,
                posl.Product__r.ProductCode,
                posl.Description__c,
                posl.Size__c,
                posl.Quantity_Shipped__c,
                posl.Total_Price__c,
                posl.Product__r.Product_Label_Template__r.Visualforce_Page__c
            ));
        }                                                   
    }

    public void createSOLinesWrapper(){
        List<AcctSeedERP__Sales_Order_Line__c> lines = [SELECT Id, 
                                                            AcctSeedERP__Product__c, 
                                                            AcctSeedERP__Product__r.ProductCode, 
                                                            AcctSeedERP__Product__r.Name, 
                                                            AcctSeedERP__Product__r.Product_Label_Template__r.Visualforce_Page__c, 
                                                            Item_Description__c, 
                                                            Size__c, 
                                                            AcctSeedERP__Quantity_Ordered__c, 
                                                            AcctSeedERP__Total__c 
                                                            FROM AcctSeedERP__Sales_Order_Line__c
                                                            WHERE AcctSeedERP__Sales_Order__c=:recordId];
        for(AcctSeedERP__Sales_Order_Line__c sol: lines){
            wrappedLines.add(new IterableItem(
                sol.Id,
                sol.AcctSeedERP__Product__c,
                sol.AcctSeedERP__Product__r.Name,
                sol.AcctSeedERP__Product__r.ProductCode,
                sol.Item_Description__c,
                sol.Size__c,
                sol.AcctSeedERP__Quantity_Ordered__c,
                sol.AcctSeedERP__Total__c,
                sol.AcctSeedERP__Product__r.Product_Label_Template__r.Visualforce_Page__c
            ));
        }
    }
    public PageReference createLabelsAction(){
        List<IterableItem> selectedItems = new List<IterableItem>();
        Integer count3x4 = 0;
        Integer count6x4 = 0;
        for(IterableItem wrap: wrappedLines){
            if(wrap.selected == true){
                selectedItems.add(wrap);

                if(wrap.selectedTemplate.contains('4x3')){
                    count3x4 += 1;
                }else if(wrap.selectedTemplate.contains('6x4')){
                    count6x4 += 1;
                }
            }
        }
        
        system.debug('JSON.serialize(selectedItems): '+JSON.serialize(selectedItems));
        String responseData = JSON.serialize(selectedItems);
        responseData = responseData.replace('#','{{{RESH}}}');
        PageReference ref = null;
        if(count3x4 > 0 && count6x4 == 0){
            ref = new PageReference('/apex/ProductLabel3x4Pages?data='+responseData+'&shortSObjectName='+shortSObjectName);
        }else if(count6x4 > 0 && count3x4 == 0){
            ref = new PageReference('/apex/ProductLabel6x4Pages?data='+responseData+'&shortSObjectName='+shortSObjectName);
        }else if(count6x4 > 0 && count3x4 > 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'All templates must have single size (3x4 or 6x4).'));

        }

        return ref;
    }


    public void test(){
        system.debug(JSON.serialize(wrappedLines));
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
        public Boolean selected {get;set;}
        public String selectedTemplate {get;set;}
        public Integer copiesCount {get;set;}
        public IterableItem(String lineId, String productId, String productName, String productCode, String itemDescription, String itemSize, Decimal quantity, Decimal total, String selectedTemplate){
            this.lineId = lineId;
            this.productId = productId;
            this.productName = productName;
            this.productCode = productCode;
            this.itemDescription = itemDescription;
            this.itemSize = itemSize;
            this.quantity = quantity;
            this.total = total;
            this.selected = false;
            this.selectedTemplate = selectedTemplate;
            this.copiesCount = 1;

        }
    }
}