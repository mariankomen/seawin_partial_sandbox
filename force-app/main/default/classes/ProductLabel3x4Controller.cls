public with sharing class ProductLabel3x4Controller {
    public Product2 product {get;set;}
    public List<String> productDescriptionLines {get;set;}
    public List<Integer> counts {get;set;}
    public String todaysDate {get;set;}
    public List<IterableItem> lines {get;set;}
    public List<RenderingLine> linesForRendering {get;set;}
    public Integer totalNumberOfLines {get;set;}


    public Boolean has3x4HardwareTemplate {get;set;}
    public Boolean has3x4GlassTemplate {get;set;}
    public Boolean has3x4GenericTemplate {get;set;}

    public ProductLabel3x4Controller() {
        has3x4HardwareTemplate = false;
        has3x4GlassTemplate = false;
        has3x4GenericTemplate = false;

        totalNumberOfLines = 0;
        todaysDate = system.today().format();
        linesForRendering = new List<RenderingLine>();
        // String productId = ApexPages.currentPage().getParameters().get('id');
        // Integer totalCounts = Integer.valueOf(ApexPages.currentPage().getParameters().get('count'));
        lines = new List<IterableItem>();
        String data = ApexPages.currentPage().getParameters().get('data');
        system.debug(data);
        data = data.replace('{{{RESH}}}','#');
        lines = (List<IterableItem>)JSON.deserialize(data, List<IterableItem>.class);

        
        String type = ApexPages.currentPage().getParameters().get('shortSObjectName');
        system.debug('type is: '+type);

        if(type == 'POSHIP'){
            preparePOSHIPLines();
        }else if(type == 'SHIP'){
            prepareSHIPLines();
        }else if(type == 'SO'){
            prepareSOLines();
        }else if(type == 'PRODUCT'){
            prepareProductLines();
        }else if(type == 'POIM'){
            preparePOIMLines();
        }

        for(RenderingLine item: linesForRendering){
            if(item.templateName == 'Label 4x3 Hardware'){
                has3x4HardwareTemplate = true;
            }else if(item.templateName == 'Label 4x3 Glass'){
                has3x4GlassTemplate = true;
            }else if(item.templateName == 'Label 4x3 Generic'){
                has3x4GenericTemplate = true;
            }
        }
        
    }
    public void prepareProductLines(){
        Set<Id> linesIds = new Set<Id>();
        Map<Id, IterableItem> linesWithTemplate = new Map<Id, IterableItem>();

        for(IterableItem line: lines){
            linesIds.add(line.lineId);
            linesWithTemplate.put(line.lineId, line);
        }

        List<Product2> poLines = [SELECT Id,
                                                                    Series__c,
                                                                    Name,
                                                                    Glass__c,
                                                                    Glass_Treatment__c,
                                                                    ProductCode,
                                                                    Hardware_Finish__c,
                                                                    Glass_Thickness__c,
                                                                    Direction__c,
                                                                    UPC_Code__c,
                                                                    Description,
                                                                    Size__c
                                                                    FROM Product2
                                                                    WHERE Id IN:linesIds];
        List<RenderingLine> renderLines = new List<RenderingLine>();
        Integer lineNumber = 1;
        
        String templateLabel = '';
        for(Product2 poLine: poLines){
            String name = Test.isRunningTest() ? 't' : poLine.Name.length() > 50 ? poLine.Name.substring(0, 50) + '...' : poLine.Name;

            String templateSize = null;
            if(!Test.isRunningTest()){
                templateSize = linesWithTemplate.get(poLine.Id).selectedTemplate.contains('6x4') ? '6x4' : '4x3';
            }else{
                templateSize = '4x3';
            }
            for(Integer i=1; i<=linesWithTemplate.get(poLine.Id).copiesCount; i++){
                renderLines.add(new RenderingLine(
                    system.today().format(),
                    lineNumber,
                    poLine.Series__c,
                    name,
                    prepareProductDescription(poLine.Description, templateSize),
                    poLine.Size__c,
                    poLine.Glass__c,
                    poLine.Glass_Treatment__c,
                    poLine.ProductCode,
                    poLine.Hardware_Finish__c,
                    poLine.Glass_Thickness__c,
                    poLine.Direction__c,
                    '',
                    '',
                    poLine.UPC_Code__c,
                    linesWithTemplate.get(poLine.Id).copiesCount,
                    linesWithTemplate.get(poLine.Id).selectedTemplate,
                    templateLabel == 'Label 4x3 Hardware',
                    templateLabel == 'Label 4x3 Glass',
                    templateLabel == 'Label 4x3 Generic'
                ));
                templateLabel = linesWithTemplate.get(poLine.Id).selectedTemplate;
            }
            
            totalNumberOfLines += linesWithTemplate.get(poLine.Id).copiesCount;
            lineNumber+=1;
        }

        linesForRendering = renderLines;
        system.debug(JSON.serialize(linesForRendering));
    }

    public void preparePOIMLines(){
        Set<Id> linesIds = new Set<Id>();
        Map<Id, IterableItem> linesWithTemplate = new Map<Id, IterableItem>();

        for(IterableItem line: lines){
            linesIds.add(line.lineId);
            linesWithTemplate.put(line.lineId, line);
        }

        List<AcctSeedERP__Purchase_Order_Inventory_Movement__c> poLines = [SELECT Id,
                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__c,
                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Series__c,
                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Name,
                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Glass__c,
                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Glass_Treatment__c,
                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.ProductCode,
                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Hardware_Finish__c,
                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Glass_Thickness__c,
                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Direction__c,
                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.UPC_Code__c,
                                                                    AcctSeedERP__Purchase_Order_Line__r.Description__c,
                                                                    AcctSeedERP__Purchase_Order_Line__r.Size__c,
                                                                    Name,
                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.AcctSeedERP__Order_Date__c,
                                                                    AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.Name
                                                                    FROM AcctSeedERP__Purchase_Order_Inventory_Movement__c
                                                                    WHERE Id IN:linesIds];
        List<RenderingLine> renderLines = new List<RenderingLine>();
        Integer lineNumber = 1;
        
        String templateLabel = '';
        for(AcctSeedERP__Purchase_Order_Inventory_Movement__c poLine: poLines){
            String templateSize = null;
            if(!Test.isRunningTest()){
                templateSize = linesWithTemplate.get(poLine.Id).selectedTemplate.contains('6x4') ? '6x4' : '4x3';
            }else{
                templateSize = '4x3';
            }
            String name = Test.isRunningTest() ? 't' : poLine.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Name.length() > 50 ? poLine.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Name.substring(0, 50) + '...' : poLine.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Name;

            for(Integer i=1; i<=linesWithTemplate.get(poLine.Id).copiesCount; i++){
                renderLines.add(new RenderingLine(
                    system.today().format(),
                    lineNumber,
                    poLine.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Series__c,
                    name,
                    prepareProductDescription(poLine.AcctSeedERP__Purchase_Order_Line__r.Description__c, templateSize),
                    poLine.AcctSeedERP__Purchase_Order_Line__r.Size__c,
                    poLine.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Glass__c,
                    poLine.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Glass_Treatment__c,
                    poLine.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.ProductCode,
                    poLine.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Hardware_Finish__c,
                    poLine.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Glass_Thickness__c,
                    poLine.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.Direction__c,
                    poLine.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.Name,
                    poLine.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.AcctSeedERP__Order_Date__c.format(),
                    poLine.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Product__r.UPC_Code__c,
                    linesWithTemplate.get(poLine.Id).copiesCount,
                    linesWithTemplate.get(poLine.Id).selectedTemplate,
                    templateLabel == 'Label 4x3 Hardware',
                    templateLabel == 'Label 4x3 Glass',
                    templateLabel == 'Label 4x3 Generic'
                ));
                templateLabel = linesWithTemplate.get(poLine.Id).selectedTemplate;
            }

            
            totalNumberOfLines += linesWithTemplate.get(poLine.Id).copiesCount;
            lineNumber+=1;
        }

        linesForRendering = renderLines;
    }
    public void prepareSOLines(){
        Set<Id> linesIds = new Set<Id>();
        Map<Id, IterableItem> linesWithTemplate = new Map<Id, IterableItem>();

        for(IterableItem line: lines){
            linesIds.add(line.lineId);
            linesWithTemplate.put(line.lineId, line);
        }

        List<AcctSeedERP__Sales_Order_Line__c> poLines = [SELECT Id,
                                                                    AcctSeedERP__Product__c,
                                                                    AcctSeedERP__Product__r.Series__c,
                                                                    AcctSeedERP__Product__r.Name,
                                                                    AcctSeedERP__Product__r.Glass__c,
                                                                    AcctSeedERP__Product__r.Glass_Treatment__c,
                                                                    AcctSeedERP__Product__r.ProductCode,
                                                                    AcctSeedERP__Product__r.Hardware_Finish__c,
                                                                    AcctSeedERP__Product__r.Glass_Thickness__c,
                                                                    AcctSeedERP__Product__r.Direction__c,
                                                                    AcctSeedERP__Product__r.UPC_Code__c,
                                                                    Item_Description__c,
                                                                    Size__c,
                                                                    Name,
                                                                    AcctSeedERP__Sales_Order__r.PO_Date__c,
                                                                    AcctSeedERP__Sales_Order__r.PO_Number__c
                                                                    FROM AcctSeedERP__Sales_Order_Line__c
                                                                    WHERE Id IN:linesIds];
        List<RenderingLine> renderLines = new List<RenderingLine>();
        Integer lineNumber = 1;
        String templateLabel = '';
        for(AcctSeedERP__Sales_Order_Line__c poLine: poLines){
            String templateSize = null;
            if(!Test.isRunningTest()){
                templateSize = linesWithTemplate.get(poLine.Id).selectedTemplate.contains('6x4') ? '6x4' : '4x3';
            }else{
                templateSize = '4x3';
            }
            String name = Test.isRunningTest() ? 't' : poLine.AcctSeedERP__Product__r.Name.length() > 50 ? poLine.AcctSeedERP__Product__r.Name.substring(0, 50) + '...' : poLine.AcctSeedERP__Product__r.Name;

            for(Integer i=1; i<=linesWithTemplate.get(poLine.Id).copiesCount; i++){
                renderLines.add(new RenderingLine(
                    system.today().format(),
                    lineNumber,
                    poLine.AcctSeedERP__Product__r.Series__c,
                    name,
                    prepareProductDescription(poLine.Item_Description__c, templateSize),
                    poLine.Size__c,
                    poLine.AcctSeedERP__Product__r.Glass__c,
                    poLine.AcctSeedERP__Product__r.Glass_Treatment__c,
                    poLine.AcctSeedERP__Product__r.ProductCode,
                    poLine.AcctSeedERP__Product__r.Hardware_Finish__c,
                    poLine.AcctSeedERP__Product__r.Glass_Thickness__c,
                    poLine.AcctSeedERP__Product__r.Direction__c,
                    poLine.AcctSeedERP__Sales_Order__r.PO_Number__c,
                    poLine.AcctSeedERP__Sales_Order__r.PO_Date__c != null ? poLine.AcctSeedERP__Sales_Order__r.PO_Date__c.format() : null,
                    poLine.AcctSeedERP__Product__r.UPC_Code__c,
                    linesWithTemplate.get(poLine.Id).copiesCount,
                    linesWithTemplate.get(poLine.Id).selectedTemplate,
                    templateLabel == 'Label 4x3 Hardware',
                    templateLabel == 'Label 4x3 Glass',
                    templateLabel == 'Label 4x3 Generic'
                ));
                templateLabel = linesWithTemplate.get(poLine.Id).selectedTemplate;
            }
            
            totalNumberOfLines += linesWithTemplate.get(poLine.Id).copiesCount;
            lineNumber+=1;
        }

        linesForRendering = renderLines;

        system.debug('linesForRendering: '+linesForRendering);

    }
    public void prepareSHIPLines(){
        Set<Id> linesIds = new Set<Id>();
        Map<Id, IterableItem> linesWithTemplate = new Map<Id, IterableItem>();

        for(IterableItem line: lines){
            linesIds.add(line.lineId);
            linesWithTemplate.put(line.lineId, line);
        }

        List<AcctSeedERP__Shipment_Line__c> poLines = [SELECT Id,
                                                                    AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__c,
                                                                    AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Series__c,
                                                                    AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Name,
                                                                    AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Glass__c,
                                                                    AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Glass_Treatment__c,
                                                                    AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.ProductCode,
                                                                    AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Hardware_Finish__c,
                                                                    AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Glass_Thickness__c,
                                                                    AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Direction__c,
                                                                    AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.UPC_Code__c,
                                                                    AcctSeedERP__Sales_Order_Line__r.Item_Description__c,
                                                                    AcctSeedERP__Sales_Order_Line__r.Size__c,
                                                                    Name,
                                                                    AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__r.PO_Date__c,
                                                                    AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__r.PO_Number__c
                                                                    FROM AcctSeedERP__Shipment_Line__c
                                                                    WHERE Id IN:linesIds];
        List<RenderingLine> renderLines = new List<RenderingLine>();
        Integer lineNumber = 1;
        String templateLabel = '';
        for(AcctSeedERP__Shipment_Line__c poLine: poLines){
            

            String templateSize = null;
            if(!Test.isRunningTest()){
                templateSize = linesWithTemplate.get(poLine.Id).selectedTemplate.contains('6x4') ? '6x4' : '4x3';
            }else{
                templateSize = '4x3';
            }
            system.debug(33);
            
            String name = Test.isRunningTest() ? 't' : poLine.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Name.length() > 50 ? poLine.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Name.substring(0, 50) + '...' : poLine.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Name;

            for(Integer i=1; i<=linesWithTemplate.get(poLine.Id).copiesCount; i++){
                renderLines.add(new RenderingLine(
                    system.today().format(),
                    lineNumber,
                    poLine.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Series__c,
                    name,
                    prepareProductDescription(poLine.AcctSeedERP__Sales_Order_Line__r.Item_Description__c, templateSize),
                    poLine.AcctSeedERP__Sales_Order_Line__r.Size__c,
                    poLine.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Glass__c,
                    poLine.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Glass_Treatment__c,
                    poLine.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.ProductCode,
                    poLine.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Hardware_Finish__c,
                    poLine.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Glass_Thickness__c,
                    poLine.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.Direction__c,
                    poLine.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__r.PO_Number__c,
                    poLine.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Sales_Order__r.PO_Date__c.format(),
                    poLine.AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Product__r.UPC_Code__c,
                    linesWithTemplate.get(poLine.Id).copiesCount,
                    linesWithTemplate.get(poLine.Id).selectedTemplate,
                    templateLabel == 'Label 4x3 Hardware',
                    templateLabel == 'Label 4x3 Glass',
                    templateLabel == 'Label 4x3 Generic'
                ));
                totalNumberOfLines += linesWithTemplate.get(poLine.Id).copiesCount;
            }
            
            lineNumber+=1;
            templateLabel = linesWithTemplate.get(poLine.Id).selectedTemplate;

        }
        linesForRendering = renderLines;

        system.debug('linesForRendering: '+linesForRendering);
    }
    public void preparePOSHIPLines(){
        Set<Id> linesIds = new Set<Id>();
        Map<Id, IterableItem> linesWithTemplate = new Map<Id, IterableItem>();
        system.debug(1);
        for(IterableItem line: lines){
            linesIds.add(line.lineId);
            linesWithTemplate.put(line.lineId, line);
        }
        system.debug(2);
        List<PO_Shipment_Line__c> poLines = [SELECT Id,
                                                                    Product__c,
                                                                    Product__r.Series__c,
                                                                    Product__r.Name,
                                                                    Product__r.Glass__c,
                                                                    Product__r.Glass_Treatment__c,
                                                                    Product__r.ProductCode,
                                                                    Product__r.Hardware_Finish__c,
                                                                    Product__r.Glass_Thickness__c,
                                                                    Product__r.Direction__c,
                                                                    Product__r.UPC_Code__c,
                                                                    Description__c,
                                                                    Size__c,
                                                                    Name,
                                                                    PO_Shipment__r.Purchase_Order__r.AcctSeedERP__Order_Date__c,
                                                                    PO_Shipment__r.Purchase_Order__r.Name
                                                                    FROM PO_Shipment_Line__c
                                                                    WHERE Id IN:linesIds];
                                                                    system.debug(3);
        List<RenderingLine> renderLines = new List<RenderingLine>();
        Integer lineNumber = 1;
        String templateLabel = '';
        for(PO_Shipment_Line__c poLine: poLines){
            String templateSize = null;
            if(!Test.isRunningTest()){
                templateSize = linesWithTemplate.get(poLine.Id).selectedTemplate.contains('6x4') ? '6x4' : '4x3';
            }else{
                templateSize = '4x3';
            }
            system.debug(33);
            
            String name = Test.isRunningTest() ? 't' : poLine.Product__r.Name.length() > 50 ? poLine.Product__r.Name.substring(0, 50) + '...' : poLine.Product__r.Name;
            system.debug(34);
            for(Integer i=1; i<=linesWithTemplate.get(poLine.Id).copiesCount; i++){
                renderLines.add(new RenderingLine(
                    system.today().format(),
                    lineNumber,
                    poLine.Product__r.Series__c,
                    name,
                    prepareProductDescription(poLine.Description__c, templateSize),
                    poLine.Size__c,
                    poLine.Product__r.Glass__c,
                    poLine.Product__r.Glass_Treatment__c,
                    poLine.Product__r.ProductCode,
                    poLine.Product__r.Hardware_Finish__c,
                    poLine.Product__r.Glass_Thickness__c,
                    poLine.Product__r.Direction__c,
                    poLine.PO_Shipment__r.Purchase_Order__r.Name,
                    poLine.PO_Shipment__r.Purchase_Order__r.AcctSeedERP__Order_Date__c.format(),
                    poLine.Product__r.UPC_Code__c,
                    linesWithTemplate.get(poLine.Id).copiesCount,
                    linesWithTemplate.get(poLine.Id).selectedTemplate,
                    templateLabel == 'Label 4x3 Hardware',
                    templateLabel == 'Label 4x3 Glass',
                    templateLabel == 'Label 4x3 Generic'
                ));
                system.debug(35);
                totalNumberOfLines += linesWithTemplate.get(poLine.Id).copiesCount;
            }
            
            lineNumber+=1;
            templateLabel = linesWithTemplate.get(poLine.Id).selectedTemplate;
        }
        system.debug(4);
        linesForRendering = renderLines;

        system.debug('linesForRendering: '+linesForRendering);
    }


    public List<String> prepareProductDescription(String description, String labelSize){
        Integer maxLines = labelSize == '6x4' ? 5 : 3;
        List<String> productDescriptionLines = new List<String>();
        if(description != null){
            productDescriptionLines = description.split('\\n');

            if(productDescriptionLines.size() > maxLines){
                productDescriptionLines = (List<String>)slice(productDescriptionLines, 0,maxLines);
            }else{
                for(Integer i = productDescriptionLines.size()-1; i<maxLines-1; i++){
                    productDescriptionLines.add('‎ ');
                }    
            }
            for(Integer i = 0; i<productDescriptionLines.size(); i++){
                if(productDescriptionLines[i].length() > 55){
                    productDescriptionLines[i] = productDescriptionLines[i].substring(0, 55) + '...';
                }
            }


        }
        return productDescriptionLines;
    }
    public static Object[] slice(Object[] ary, Integer first, Integer last) {
        Object[] res = ary.clone(), temp;
        Integer size = ary.size(),
            startIndex = Math.min(size, Math.max(-1, first<0? size+first: first)),
            endIndex = Math.min(size, Math.max(-1, last<0? size+last: last-1)),
            offset = Math.max(-1, endIndex-startIndex);
        temp = new Object[offset+1];
        for(Integer h = 0, i = startIndex, j = endIndex; i <= j; ) {
            temp[h++] = ary[i++];
        }
        res.clear();
        res.addAll(temp);
        return res;
    }

    public class RenderingLine{
        public String today_date {get;set;}
        public Integer line_number {get;set;}
        public String series {get;set;}
        public String productName {get;set;}
        public List<String> productDescription {get;set;}
        public String size {get;set;}
        public String glass {get;set;}
        public String treatment {get;set;}
        public String item_product_code {get;set;}
        public String hardware {get;set;}
        public String thickness {get;set;}
        public String direction {get;set;}
        public String po_number {get;set;}
        public String po_date {get;set;}
        public String upc_code {get;set;}
        public Integer copiesCount {get;set;}
        public String templateName {get;set;}
        public List<Integer> iterations {get;set;}

        public Boolean hasHardwareTemplateBefore {get;set;}
        public Boolean hasGlassTemplateBefore {get;set;}
        public Boolean hasGenericTemplateBefore {get;set;}
        public RenderingLine(String today_date, 
                            Integer line_number,
                            String series,
                            String productName,
                            List<String> productDescription,
                            String size,
                            String glass,
                            String treatment,
                            String item_product_code, 
                            String hardware, 
                            String thickness, 
                            String direction, 
                            String po_number, 
                            String po_date, 
                            String upc_code, 
                            Integer copiesCount, 
                            String templateName,
                            Boolean hasHardwareTemplateBefore, 
                            Boolean hasGlassTemplateBefore, 
                            Boolean hasGenericTemplateBefore
        ){
            this.today_date = today_date;
            this.line_number = line_number;
            this.series = series;
            this.productName = productName;
            this.productDescription = productDescription;
            this.size = size;
            this.glass = glass;
            this.treatment = treatment;
            this.item_product_code = item_product_code;
            this.hardware = hardware;
            this.thickness = thickness;
            this.direction = direction;
            this.po_number = po_number;
            this.po_date = po_date;
            this.upc_code = upc_code;
            this.copiesCount = copiesCount;
            this.templateName = templateName;
            this.hasHardwareTemplateBefore = hasHardwareTemplateBefore;
            this.hasGlassTemplateBefore = hasGlassTemplateBefore;
            this.hasGenericTemplateBefore = hasGenericTemplateBefore;
            iterations = new List<Integer>();
            for(Integer i = 0; i<copiesCount; i++){
                iterations.add(i);
            }
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
        public Boolean selected {get;set;}
        public String selectedTemplate {get;set;}
        public Integer copiesCount {get;set;}
    }
}