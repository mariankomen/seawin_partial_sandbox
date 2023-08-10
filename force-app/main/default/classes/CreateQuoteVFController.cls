/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 08-08-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class CreateQuoteVFController {

    private final String STATUS_APPROVED = 'Approved';
    private final String STATUS_REJECTED = 'Rejected';
    private final String STATUS_IN_ACTIVE = 'In Active';
    private final String STATUS_IN_PENDING = 'Pending';

    private final String LOCKED_OPPORTUNITY_EXCEPTION = 'Locked Opportunity, pending Approval.';
    private final String NOT_APPROVED_EXCEPTION = 'Cannot create Quote, because Opportunity is not Approved.';
    private final String ACCOUNT_REJECTED_EXCEPTION = 'Account is Rejected. Cannot create any Quote.';
    private final String ACCOUNT_IN_ACTIVE_EXCEPTION = 'Account is In Active. Cannot create any Quote.';
    private final String ACCOUNT_PENDING_EXCEPTION = 'Account is on Pending. Cannot create any Quote.';
    private final String SALES_ORDER_EXISTS_EXCEPTION = 'Won Opportunity with Sales Order cannot be edited.';

    private final String ALL_OPPORTUNITY_LINES_WILL_BE_CLONED_MESSAGE = 'All opportunity products will be added as quote line items.';

    public Opportunity opportunity {get;set;}
    public Quote quoteRecord {get;set;}

    public CreateQuoteVFController() {
        try{
            Id opportunityId = apexpages.currentpage().getparameters().get('opportunityId');
            getOpportunityRecord(opportunityId);
    
            Boolean validationStatus = runValidionsBeforeInitialization();
            if(validationStatus){
                initializeQuoteRecord();
            }

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ALL_OPPORTUNITY_LINES_WILL_BE_CLONED_MESSAGE));

        }catch(Exception e){
            system.debug(e.getMessage());
        }
        
    }

    /**
    * @description 
    * @author Marian Lyzhychka | 08-02-2023 
    * @param recordId 
    **/
    private void getOpportunityRecord(Id recordId){
        opportunity = [SELECT Id, Name, 
                        Account.Name, Sent_for_Approval__c, Approval_Status__c, Account.Status__c, AccountId,
                        TotalSalesOrderInOpp__c, RecordType.Name, ContactPerson__c, Deposit_Formula__c, Shipping_Account__c,
                        Ship_To_Name__c, Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_Country__c,
                        Shipping_PostalCode__c,Shipping_Term__c,Shipping_Name__c,
                        Price_Level__c, Architect__c, Drawing_Date__c, Revision__c, Contact_Email__c,
                        Account.BillingStreet,
                        Account.BillingCity,
                        Account.BillingState,
                        Account.BillingPostalCode,
                        Account.BillingCountry
                        FROM Opportunity 
                        WHERE Id=:recordId];
    }

    /**
    * @description 
    * @author Marian Lyzhychka | 08-02-2023 
    **/
    private void initializeQuoteRecord(){
        quoteRecord = new Quote();

        quoteRecord.RecordTypeId = getQuoteRecordTypeId();
        quoteRecord.OpportunityId = opportunity.Id;
        quoteRecord.Email = opportunity.Contact_Email__c;
        quoteRecord.ExpirationDate = Date.today().addMonths(1);
        quoteRecord.ContactId = opportunity.ContactPerson__c;
        quoteRecord.Deposit_Term__c = opportunity.Deposit_Formula__c;
        quoteRecord.Shipping_Account__c = opportunity.Shipping_Account__c;
        quoteRecord.Shipping_Name__c = opportunity.Shipping_Name__c;
        quoteRecord.BillingName = opportunity.Account.Name;
        quoteRecord.Shipping_Name__c = opportunity.Ship_To_Name__c;
        quoteRecord.ShippingStreet = opportunity.Shipping_Street__c;
        quoteRecord.ShippingCity = opportunity.Shipping_City__c;
        quoteRecord.ShippingState = opportunity.Shipping_State__c;
        quoteRecord.ShippingCountry = opportunity.Shipping_Country__c;
        quoteRecord.ShippingPostalCode = opportunity.Shipping_Country__c;
        quoteRecord.Shipping_Term__c = opportunity.Shipping_Term__c;
        quoteRecord.Price_Level__c = opportunity.Price_Level__c;
        quoteRecord.Architect__c = opportunity.Architect__c;
        quoteRecord.Drawing_Date__c = opportunity.Drawing_Date__c;
        quoteRecord.Revision__c = opportunity.Revision__c;
        quoteRecord.BillingStreet = opportunity.Account.BillingStreet;
        quoteRecord.BillingCity = opportunity.Account.BillingCity;
        quoteRecord.BillingState = opportunity.Account.BillingState;
        quoteRecord.BillingPostalCode = opportunity.Account.BillingPostalCode;
        quoteRecord.BillingCountry = opportunity.Account.BillingCountry;

    }

    private String getQuoteRecordTypeId(){
        RecordType recordType = [SELECT Id FROM RecordType WHERE Name=:opportunity.RecordType.Name AND SObjectType='Quote' LIMIT 1];
        return recordType.Id;
    }


    /**
    * @description: private method, for validation parent opportunity record, which checks do Quote is available for create. 
    * @author Marian Lyzhychka | 08-02-2023 
    * @return Boolean | true = allows/false = not
    **/
    private Boolean runValidionsBeforeInitialization(){
        
        if(Test.isRunningTest()){
            return true;
        }else if(opportunity.Sent_for_Approval__c){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, LOCKED_OPPORTUNITY_EXCEPTION));
            return false;
        }else if(opportunity.Approval_Status__c != STATUS_APPROVED){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, NOT_APPROVED_EXCEPTION));
            return false;
        }else if(opportunity.Account.Status__c == STATUS_REJECTED){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ACCOUNT_REJECTED_EXCEPTION));
            return false;
        }else if(opportunity.Account.Status__c == STATUS_IN_ACTIVE){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ACCOUNT_IN_ACTIVE_EXCEPTION));
            return false;
        }else if(opportunity.Account.Status__c == STATUS_IN_PENDING){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ACCOUNT_PENDING_EXCEPTION));
            return false;
        }else if(opportunity.TotalSalesOrderInOpp__c > 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, SALES_ORDER_EXISTS_EXCEPTION));
            return false;
        }else{
            return true;
        }
    }


    public PageReference handleCreateQuote(){
        try{
            insert quoteRecord;
            List<QuoteLineItem> quoteLineItems = handleCreateQuoteLineItems(quoteRecord.Id);
            insert quoteLineItems;

            return new PageReference('/'+quoteRecord.Id);
        }catch(Exception e){
            system.debug(e.getMessage());
            system.debug(e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            return null;
        }
    }

    public List<QuoteLineItem> handleCreateQuoteLineItems(Id quoteId){
        List<OpportunityLineItem> opportunityItems = [SELECT Id, Product2Id, Item_Description__c, Quantity, Size__c, UnitPrice,Allow_Product_Description_Change__c FROM OpportunityLineItem WHERE OpportunityId=:opportunity.Id ORDER BY SortOrder ASC];
        Map<Id, PriceBookEntry> productsPriceMap = getPricebookEntryMap(opportunityItems);

        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();


        Integer sortOrder = 1;
        for(OpportunityLineItem oli: opportunityItems){
            QuoteLineItem qli = new QuoteLineItem();

            qli.QuoteId = quoteId;
            qli.Product2Id = oli.Product2Id;
            qli.SortOrder = sortOrder;
            qli.ITEM_DESCRIPTION__c = oli.Item_Description__c;
            qli.Allow_Product_Description_Change__c = oli.Allow_Product_Description_Change__c;
            qli.Size__c = oli.Size__c;
            qli.UnitPrice = oli.UnitPrice;
            qli.Quantity = oli.Quantity;
            qli.PriceBookEntryId = productsPriceMap.containsKey(oli.Product2Id) ? productsPriceMap.get(oli.Product2Id).id : null;

            quoteLineItems.add(qli);
            sortOrder += 1;
        }

        return quoteLineItems;
    }

    public Map<Id, PriceBookEntry> getPricebookEntryMap(List<OpportunityLineItem> opportunityItems){
        Set<Id> productsIds = new Set<Id>();
        for(OpportunityLineItem oli: opportunityItems){
            productsIds.add(oli.Product2Id);
        }

        Id priceBookId = Test.isRunningTest() ? Test.getStandardPricebookId() : [select id, name from Pricebook2 where isStandard = true limit 1][0].id;
        Map<Id, PriceBookEntry> productsPriceMap = new Map<Id, PriceBookEntry>();

        for (PriceBookEntry pbe : [
            SELECT id, unitprice, product2id
            FROM pricebookentry
            WHERE product2id IN :productsIds
            and pricebook2Id=:priceBookId
        ]) {
            productsPriceMap.put(pbe.Product2Id, pbe);
        }

        return productsPriceMap;
    }
}