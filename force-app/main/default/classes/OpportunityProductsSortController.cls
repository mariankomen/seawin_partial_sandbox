/*****************************************************************************************************
*   @class        : OpportunityProductsSortController
*   @description  : Controller of Sort page for Opportunity products and optional products
*   @author       : Marian Lyzhychka ©Peeklogic
*****************************************************************************************************/
public with sharing class OpportunityProductsSortController {

    public Id opportunityId {get; set;}
    public Boolean isOpportunityProduct {get; set;}
    public Boolean isOptionalProduct {get; set;}
    private String typeOfProduct {get; set;}

    public List<ItemWrapper> wrapper_lines {get; set;}
    public List<Optional_Products_Opportunity__c> opportunityOptionalItems {get; set;}
    public List<OpportunityLineItem> opportunityLineItems {get; set;}

    public String opportunityName {get; set;}
    public OpportunityProductsSortController() {

        wrapper_lines = new List<ItemWrapper>();
        opportunityOptionalItems = new List<Optional_Products_Opportunity__c>();
        opportunityLineItems = new List<OpportunityLineItem>();

        opportunityId = ApexPages.currentPage().getParameters().get('oppId');
        typeOfProduct = ApexPages.currentPage().getParameters().get('recordType');
        
        opportunityName = [SELECT Id, Name FROM Opportunity WHERE Id=:opportunityId].Name;

        isOpportunityProduct = typeOfProduct == 'oli' ? true : false;
        isOptionalProduct = typeOfProduct == 'opo' ? true : false;

        if(isOpportunityProduct){
            fetchOpportunityLineItems();
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
        for(OpportunityLineItem oli: opportunityLineItems){
            wrapper_lines.add(  new ItemWrapper(oli.Id, 
                                                oli.Product2.Name,
                                                oli.Quantity, 
                                                String.valueOf(oli.UnitPrice), 
                                                oli.Size__c, 
                                                oli.Item_Description__c, 
                                                oli.Product2.Allow_Product_Description_Change__c));
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
                                                opo.Product__r.Allow_Product_Description_Change__c));
        }                                                                    
        
    }

    @RemoteAction
    public static void executeSorting(String json_sort, String oppId, String recType){
        List<SortingWrapper> sortlist = (List<SortingWrapper>)JSON.deserialize(json_sort, List<SortingWrapper>.class);

        if(recType == 'oli'){
            saveSortingOLI(json_sort, oppId, sortlist);
        }else if(recType == 'opo'){
            saveSortingOPO(json_sort, oppId, sortlist);
        }
    }
    
    public static void saveSortingOLI(String json_sort, String oppId, List<SortingWrapper> sortlist){

        Map<Id, Integer> sortMap = new Map<Id, Integer>();
        for(SortingWrapper sw:sortList){
            sortMap.put(sw.solId, sw.sortNumber);
        }

        List<OpportunityLineItem> oli = [SELECT Id, SortOrder FROM OpportunityLineItem WHERE OpportunityId=:oppId];

        for(OpportunityLineItem ol: oli){
            ol.SortOrder = sortMap.get(ol.Id);
        }

        try{
            update oli;
            system.debug('UPDATED SUCCESSFULLY');
        }catch(Exception ex){
            system.debug('ERROR: '+ex.getMessage());
        }
    }
    public static void saveSortingOPO(String json_sort, String oppId, List<SortingWrapper> sortlist){

        Map<Id, Integer> sortMap = new Map<Id, Integer>();
        for(SortingWrapper sw:sortList){
            sortMap.put(sw.solId, sw.sortNumber);
        }

        List<Optional_Products_Opportunity__c> opo = [SELECT Id, SortOrder__c FROM Optional_Products_Opportunity__c WHERE Opportunity__c=:oppId];

        for(Optional_Products_Opportunity__c ol: opo){
            ol.SortOrder__c = sortMap.get(ol.Id);
        }

        try{
            update opo;
            system.debug('UPDATED SUCCESSFULLY');
        }catch(Exception ex){
            system.debug('ERROR: '+ex.getMessage());
        }
    }


    
    public PageReference back(){
        PageReference ref = new PageReference('/'+opportunityId);
        return ref;
    }
    public class SortingWrapper{
        public Id solId {get;set;}
        public Integer sortNumber {get;set;}

        public SortingWrapper(Id sId, Integer n){
            solId = sId;
            sortNumber = n;
        }
    }

    public class ItemWrapper{
        public Id recordId {get; set;}
        public String productName {get; set;}
        public Decimal quantity {get; set;}
        public String sales_price {get; set;}
        public String size {get; set;}
        public String description {get; set;}
        public Boolean allow_changes {get; set;}

        public ItemWrapper(Id prodId, String prodName, Decimal quant, String price, String siz, String descript, Boolean allow_cha){
            recordId = prodId;
            productName = prodName;
            quantity = quant;
            sales_price = price;
            size = siz;
            description = descript;
            allow_changes = allow_cha;
        }
    }
}