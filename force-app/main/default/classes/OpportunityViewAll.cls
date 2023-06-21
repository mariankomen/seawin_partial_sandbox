public with sharing class OpportunityViewAll {

    public List<LineWrapper> wrapperLines {get;set;}

    public Id recordId {get;set;}
    public Boolean isOptional {get;set;}
    public String viewingObjectLabel {get;set;}
    public String subTitle {get;set;}
    public OpportunityViewAll() {
        wrapperLines = new List<LineWrapper>();
        recordId = ApexPages.currentPage().getParameters().get('recordId');
        isOptional = Boolean.valueOf(ApexPages.currentPage().getParameters().get('optional'));

        String sobjType = String.valueOf(recordId.getSobjectType());
        system.debug(sobjType);

        subTitle = '';

        if(sobjType == 'AcctSeedERP__Sales_Order__c'){
            fetchSalesOrderProducts();
            viewingObjectLabel = 'Sales Order';
        }else if(sobjType == 'Opportunity' && isOptional == false){
            fetchOpportunityProducts();
            viewingObjectLabel = 'Opportunity';
        }else if(sobjType == 'Opportunity' && isOptional == true){
            fetchOpportunityOptionalProducts();
            viewingObjectLabel = 'Opportunity';
        }else if(sobjType == 'AcctSeedERP__Purchase_Order__c'){
            fetchPurchaseOrderProducts();
            viewingObjectLabel = 'Purchase Order';
        }


    }





    public void fetchOpportunityProducts(){
        subTitle = [SELECT Id, Name FROM Opportunity WHERE Id=:recordId].Name;
        List<OpportunityLineItem> opportunityLineItems = [SELECT Id,
                                        Name,
                                        Quantity,
                                        UnitPrice,
                                        Size__c,
                                        Image__c,
                                        Item_Description__c,
                                        Product2.Allow_Product_Description_Change__c,
                                        AlternateImageURL_Trunc__c,
                                        Product2.Product_Image_Short_URL__c,
                                        Product2.Name
                                FROM OpportunityLineItem
                                WHERE OpportunityId=:recordId
                                ORDER BY SortOrder ];

        for(OpportunityLineItem oli: opportunityLineItems){
            wrapperLines.add(new LineWrapper(oli.Product2.Name,
                                            oli.AlternateImageURL_Trunc__c != null ? oli.AlternateImageURL_Trunc__c : oli.Product2.Product_Image_Short_URL__c,
                                            oli.Quantity,
                                            oli.UnitPrice,
                                            oli.Size__c,
                                            oli.Item_Description__c
            ));
        }
    }
    public void fetchOpportunityOptionalProducts(){
        subTitle = [SELECT Id, Name FROM Opportunity WHERE Id=:recordId].Name;
        List<Optional_Products_Opportunity__c> opportunityOptionalProducts = [SELECT Id, 
                                                                                    Quantity__c, 
                                                                                    UnitPrice__c, 
                                                                                    Size__c, 
                                                                                    Item_Description__c,
                                                                                    AlternateImageURL_Trunc__c,
                                                                                    Product__r.Product_Image_Short_URL__c,
                                                                                    Product__r.Name
                                                                                    FROM Optional_Products_Opportunity__c
                                                                                WHERE Opportunity__c=: recordId
                                                                                ORDER BY SortOrder__c ];
        for(Optional_Products_Opportunity__c opopp: opportunityOptionalProducts){
            wrapperLines.add(new LineWrapper(opopp.Product__r.Name,
                                            opopp.AlternateImageURL_Trunc__c != null ? opopp.AlternateImageURL_Trunc__c : opopp.Product__r.Product_Image_Short_URL__c,
                                            opopp.Quantity__c,
                                            opopp.UnitPrice__c,
                                            opopp.Size__c,
                                            opopp.Item_Description__c
                            ));
        }
    }
    public void fetchSalesOrderProducts(){
        subTitle = [SELECT Id, Name FROM AcctSeedERP__Sales_Order__c WHERE Id=:recordId].Name;
        List<AcctSeedERP__Sales_Order_Line__c> salesOrderLines = [SELECT Id,
                                                                        AcctSeedERP__Quantity_Ordered__c,
                                                                        AcctSeedERP__Unit_Price__c,
                                                                        Size__c,
                                                                        AcctSeedERP_Description__c,
                                                                        AcctSeedERP__Product__r.Name,
                                                                        AlternateImageURL_Trunc__c,
                                                                        AcctSeedERP__Product__r.Product_Image_Short_URL__c
                                                                    FROM AcctSeedERP__Sales_Order_Line__c 
                                                                    WHERE AcctSeedERP__Sales_Order__c =: recordId 
                                                                    ORDER BY SortOrder__c];
        for(AcctSeedERP__Sales_Order_Line__c sol: salesOrderLines){
            wrapperLines.add(new LineWrapper(sol.AcctSeedERP__Product__r.Name,
                                            sol.AlternateImageURL_Trunc__c != null ? sol.AlternateImageURL_Trunc__c : sol.AcctSeedERP__Product__r.Product_Image_Short_URL__c,
                                            sol.AcctSeedERP__Quantity_Ordered__c,
                                            sol.AcctSeedERP__Unit_Price__c,
                                            sol.Size__c,
                                            sol.AcctSeedERP_Description__c
            ));
        }
    }


    public void fetchPurchaseOrderProducts(){
        subTitle = [SELECT Id, Name FROM AcctSeedERP__Purchase_Order__c WHERE Id=:recordId].Name;
        List<AcctSeedERP__Purchase_Order_Line__c> purchaseOrderLines = [SELECT Id, 
                                                                                AcctSeedERP__Quantity__c, 
                                                                                AcctSeedERP__Unit_Price__c, 
                                                                                Size__c,
                                                                                Description__c,
                                                                                AlternateImageURL_Trunc__c,
                                                                                AcctSeedERP__Product__r.Name,
                                                                                AcctSeedERP__Product__r.Product_Image_Short_URL__c
                                                                        FROM AcctSeedERP__Purchase_Order_Line__c
                                                                        WHERE AcctSeedERP__Purchase_Order__c=:recordId
                                                                        ORDER BY Sort_Order__c];
        for(AcctSeedERP__Purchase_Order_Line__c pol: purchaseOrderLines){
            wrapperLines.add(new LineWrapper(pol.AcctSeedERP__Product__r.Name,
                                                pol.AlternateImageURL_Trunc__c != null ? pol.AlternateImageURL_Trunc__c : pol.AcctSeedERP__Product__r.Product_Image_Short_URL__c,
                                                pol.AcctSeedERP__Quantity__c,
                                                pol.AcctSeedERP__Unit_Price__c,
                                                pol.Size__c,
                                                pol.Description__c
            ));
        }
    }


    public PageReference back(){
        PageReference pr = new PageReference('/'+recordId);
        return pr;
    }


    public class LineWrapper{
        public String productName { get; set;}
        public String productImageUrl { get; set;}
        public Decimal quantity { get; set;}
        public Decimal salesPrice { get; set;}
        public String size { get; set;}
        public String description { get; set;}

        public LineWrapper(String productName, String productImageUrl, Decimal quantity, Decimal salesPrice, String size, String description){
            this.productName = productName;
            this.productImageUrl = productImageUrl;
            this.quantity = quantity;
            this.salesPrice = salesPrice;
            this.size = size;
            this.description = description;
        }
    }
}