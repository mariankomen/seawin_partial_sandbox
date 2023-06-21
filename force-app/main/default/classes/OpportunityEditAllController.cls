/*****************************************************************************************************
*   @class        : OpportunityEditAllController
*   @description  : Controller of edit all page for Opportunity products and optional products
*   @author       : Marian Lyzhychka ©Peeklogic
*****************************************************************************************************/
public with sharing class OpportunityEditAllController {

    public Id opportunityId {get; set;}
    public Boolean isOpportunityProduct {get; set;}
    public Boolean isOptionalProduct {get; set;}
    private String typeOfProduct {get; set;}
    public Opportunity opp {get; set;}

    public List<ItemWrapper> wrapper_lines {get; set;}
    public List<Optional_Products_Opportunity__c> opportunityOptionalItems {get; set;}
    public List<OpportunityLineItem> opportunityLineItems {get; set;}
    
    public String subTitle {get;set;}
    public Boolean errorOccuredDuringUpdate {get;set;}
    public OpportunityEditAllController() {
        errorOccuredDuringUpdate = false;
        wrapper_lines = new List<ItemWrapper>();
        opportunityOptionalItems = new List<Optional_Products_Opportunity__c>();
        opportunityLineItems = new List<OpportunityLineItem>();

        opportunityId = ApexPages.currentPage().getParameters().get('oppId');
        typeOfProduct = ApexPages.currentPage().getParameters().get('recordType');

        opp = [SELECT Id, Name, Price_Level__c FROM Opportunity WHERE Id=:opportunityId];
        subTitle = opp.Name + ' & (' + opp.Price_Level__c + ')';

        isOpportunityProduct = typeOfProduct == 'oli' ? true : false;
        isOptionalProduct = typeOfProduct == 'opo' ? true : false;

        if(isOpportunityProduct){
            fetchOpportunityLineItems();
            Boolean hasBilledLines = false;
            for(ItemWrapper iw: wrapper_lines){
                if(iw.hasRelatedBillLine){
                    hasBilledLines = true;
                }
            }
            if(hasBilledLines){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Quantity and Sales Price fields cannot be edited because Opportunity already has a Billing(s).'));
            }


        }else{
            fetchOpportunityOptionalItems();
        }
    }



    /*****************************************************************************************************
    *   @method       : fetchOpportunityLineItems
    *   @description  : Method fetch all Opportunity Line items
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void fetchOpportunityLineItems(){
        opportunityLineItems = [SELECT Id,
                                        Name,
                                        Quantity,
                                        UnitPrice,
                                        Size__c,
                                        Item_Description__c,
                                        Product2.Allow_Product_Description_Change__c,
                                        Product2.Name
                                    FROM OpportunityLineItem
                                    WHERE OpportunityId=:opportunityId
                                    ORDER BY SortOrder ];
        Set<Id> line_ids = new Set<Id>();
        for(OpportunityLineItem oli: opportunityLineItems){
            line_ids.add(oli.Id);
        }                            
        List<AcctSeed__Billing_Line__c> billed_lines = [SELECT Id, 
                                                            AcctSeed__Opportunity_Product_Id__c 
                                                            FROM AcctSeed__Billing_Line__c 
                                                            where AcctSeed__Opportunity_Product_Id__c IN: line_ids];
        Map<Id, Id> map_oli_bill = new Map<Id, Id>();
        for(AcctSeed__Billing_Line__c bl:billed_lines){
            map_oli_bill.put((Id)bl.AcctSeed__Opportunity_Product_Id__c, bl.Id);
        }


        for(OpportunityLineItem oli: opportunityLineItems){
            wrapper_lines.add(  new ItemWrapper(oli.Id, 
                                                oli.Product2.Name,
                                                oli.Quantity, 
                                                String.valueOf(oli.UnitPrice), 
                                                oli.Size__c, 
                                                oli.Item_Description__c, 
                                                oli.Product2.Allow_Product_Description_Change__c,
                                                map_oli_bill.containsKey(oli.Id)));
        }                                                    
    }
    /*****************************************************************************************************
    *   @method       : fetchOpportunityOptionalItems
    *   @description  : Method fetch all Opportunity optional items
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void fetchOpportunityOptionalItems(){
        opportunityOptionalItems = [SELECT Id,
                                        Name,
                                        Quantity__c,
                                        UnitPrice__c,
                                        Size__c,
                                        Item_Description__c,
                                        Product__r.Allow_Product_Description_Change__c,
                                        Product__r.Name
                                    FROM Optional_Products_Opportunity__c
                                    WHERE Opportunity__c=:opportunityId
                                    ORDER BY SortOrder__c ];
        
        for(Optional_Products_Opportunity__c opo: opportunityOptionalItems){
            wrapper_lines.add(new ItemWrapper(opo.Id, 
                                                opo.Product__r.Name, 
                                                opo.Quantity__c, 
                                                String.valueOf(opo.UnitPrice__c), 
                                                opo.Size__c, 
                                                opo.Item_Description__c,
                                                opo.Product__r.Allow_Product_Description_Change__c,
                                                false
                                                ));
        }                                                                    
        
    }

    /*****************************************************************************************************
    *   @method       : saveEdit
    *   @description  : method use onclick save button, depends on records(oli or opo) run different save functions
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public PageReference saveEdit(){
        if(isOpportunityProduct){
            saveProductEdit();
        }else{
            saveOptionalProductEdit();
        }

        PageReference ref = errorOccuredDuringUpdate ? null : new PageReference('/'+opportunityId);
        return ref;
    }

    /*****************************************************************************************************
    *   @method       : saveProductEdit
    *   @description  : used for saving OpportunityLineItems
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void saveProductEdit(){
        Map<Id, OpportunityLineItem> opportunityLineItemsMap = new Map<Id, OpportunityLineItem>(opportunityLineItems);
        List<OpportunityLineItem> updatableLines = new List<OpportunityLineItem>();

        for(ItemWrapper iw: wrapper_lines){
            iw.sales_price = iw.sales_price.replaceAll(' ', '');
            List<String> splittedCurrency = iw.sales_price.split('');
            Boolean minus_amount = false;
            if(splittedCurrency.contains('-')) minus_amount = true;

            if(opportunityLineItemsMap.containsKey(iw.recordId)){
                OpportunityLineItem oli = opportunityLineItemsMap.get(iw.recordId);
                oli.Quantity = iw.quantity;
                oli.UnitPrice = minus_amount ? Decimal.valueOf(iw.sales_price.replaceAll('[^0-9.]', '')) * (-1) : Decimal.valueOf(iw.sales_price.replaceAll('[^0-9.]', ''));
                oli.Size__c = iw.size;
                oli.Item_Description__c = iw.description;
                updatableLines.add(oli);
            }
        }
        try{
            update updatableLines;
            errorOccuredDuringUpdate = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Product lines were successfully saved.'));
        } catch(Exception e){
            errorOccuredDuringUpdate = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

    /*****************************************************************************************************
    *   @method       : saveOptionalProductEdit
    *   @description  : used for saving Optional_Products_Opportunity__c
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void saveOptionalProductEdit(){
        Map<Id, Optional_Products_Opportunity__c> opportunityOptionalItemsMap = new Map<Id, Optional_Products_Opportunity__c>(opportunityOptionalItems);
        List<Optional_Products_Opportunity__c> updatableOptionalLines = new List<Optional_Products_Opportunity__c>();

        for(ItemWrapper iw: wrapper_lines){
            iw.sales_price = iw.sales_price.replaceAll(' ', '');
            List<String> splittedCurrency = iw.sales_price.split('');
            Boolean minus_amount = false;
            if(splittedCurrency.contains('-')) minus_amount = true;

            if(opportunityOptionalItemsMap.containsKey(iw.recordId)){
                Optional_Products_Opportunity__c opo = opportunityOptionalItemsMap.get(iw.recordId);
                opo.Quantity__c = iw.quantity;
                opo.UnitPrice__c = minus_amount ? Decimal.valueOf(iw.sales_price.replaceAll('[^0-9.]', '')) * (-1) : Decimal.valueOf(iw.sales_price.replaceAll('[^0-9.]', ''));
                opo.Size__c = iw.size;
                opo.Item_Description__c = iw.description;
                updatableOptionalLines.add(opo);
            }
        }
        try{
            update updatableOptionalLines;
            errorOccuredDuringUpdate = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Optional Product lines were successfully saved.'));
        } catch(Exception e){
            errorOccuredDuringUpdate = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

    public PageReference back(){
        PageReference pr = new PageReference('/'+opportunityId);
        return pr;
    }

    public PageReference TrashIt(){
        String deletableId = typeOfProduct = ApexPages.currentPage().getParameters().get('deletableId');

        PageReference url = new PageReference('/apex/OpportunityEditAllPage?oppId='+opportunityId+'&recordType='+typeOfProduct+'retURL='+opportunityId);
        if(isOpportunityProduct){
            OpportunityLineItem item = [SELECT Id,Name FROM OpportunityLineItem WHERE Id=:deletableId];
            try{
                delete item;

            }catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            }
        }else{
            Optional_Products_Opportunity__c opo = [SELECT Id, Name FROM Optional_Products_Opportunity__c WHERE Id=:deletableId];

            try{
                delete opo;
            }catch(Exception e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            }
        }
        return url;
        

    }
    public class ItemWrapper{
        public Id recordId {get; set;}
        public String productName {get; set;}
        public Decimal quantity {get; set;}
        public String sales_price {get; set;}
        public String size {get; set;}
        public String description {get; set;}
        public Boolean allow_changes {get; set;}
        public Boolean hasRelatedBillLine {get; set;}
        public ItemWrapper(Id prodId, String prodName, Decimal quant, String price, String siz, String descript, Boolean allow_cha, Boolean hasBilled){
            recordId = prodId;
            productName = prodName;
            quantity = quant;
            sales_price = price;
            size = siz;
            description = descript;
            allow_changes = allow_cha;
            hasRelatedBillLine = hasBilled;
        }
    }

}