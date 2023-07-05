/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-04-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class OpportunityDetailPageController {
    
    public class OpportunityDetailPageControllerException extends Exception {}

    /**
    * @description 
    * @author Marian Lyzhychka | 07-03-2023 
    * @return String 
    **/
    @AuraEnabled
    public static String getOpportunitySubStages(){
        try {
            Map<String, List<String>> dependendSubStageToStage = DependentPicklistExtension.getDependentPicklistValues(Opportunity.Sub_Stage__c);
            
            return JSON.serialize(dependendSubStageToStage);
        } catch (Exception e) {
            throw new OpportunityDetailPageControllerException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Marian Lyzhychka | 07-03-2023 
    * @param linesWrapperJson 
    * @return String 
    **/
    @AuraEnabled
    public static String createBilling(String linesWrapperJson){
        try {
            CreateBillingWrapper wrapper = (CreateBillingWrapper)JSON.deserialize(linesWrapperJSON, CreateBillingWrapper.class);
            system.debug(wrapper);
            Opportunity opp = [SELECT Id, Name, AccountId, Account.Deposit__c, 
                                Account.AcctSeed__Billing_Contact__c, Account.BillingStreet, 
                                Account.BillingCity, Account.BillingState, Account.BillingPostalCode,
                                Account.AcctSeed__Billing_Format__c,
                                Account.BillingCountry, Account.Contact_Person__c,
                                Account.AcctSeed__Billing_Days_Due__c,
                                RecordType.Name,
                                Shipping_City__c, Shipping_Country__c, 
                                Shipping_PostalCode__c, Shipping_State__c, Shipping_Street__c, 
                                GL_Account_Variable_1__c, Shipping_Name__c, Shipping_Account__c,
                                Billing_Terms_Name__c, Billing_Deposit__c 
                                FROM Opportunity WHERE id =:wrapper.recordId limit 1];

            Date enteredDate = wrapper.billingDate;
            String acctperiodDate = enteredDate.year() + ((enteredDate.month() < 10) ? '-0' : '-') + enteredDate.month();
            // get the current accounting period which is open
            list<AcctSeed__Accounting_Period__c> acctPeriod = [SELECT AcctSeed__Status__c, Name, Id, AcctSeed__End_Date__c, 
                                                                AcctSeed__Start_Date__c 
                                                                FROM AcctSeed__Accounting_Period__c where 
                                                                Name =:acctperiodDate and AcctSeed__Status__c = 'Open' limit 1];
            if(acctPeriod.IsEmpty()){

                String exceptionMessage = 'No Accounting Period has been set up for'+ 
                                                            ' this Billing Date or the Accounting Period status is closed.'+ 
                                                            ' Please first set up Accounting Period for this date in'+ 
                                                            ' Accounting Seed.';
                throw new OpportunityDetailPageControllerException(exceptionMessage);
            }

            List<AcctSeedERP__Sales_Order__c> salesOrders = [SELECT Id FROM AcctseedERP__sales_order__c
                                                       WHERE AcctSeedERP__Opportunity__c =:wrapper.recordId
                                                       ORDER BY CreatedDate desc limit 1];
            map<string, id> salesOrderLineRelatedToOpportunityLines = new map<string, id>();

            if(!salesOrders.isEmpty()){
                
                List<AcctSeedERP__Sales_Order_Line__c> salesOrderLines = [SELECT id, AcctSeedERP__Opportunity_Product_Id__c
                                                                    FROM AcctseedERP__sales_order_line__c
                                                                    WHERE AcctSeedERP__sales_order__c =:salesOrders[0].id];
                    
                for(AcctSeedERP__Sales_Order_Line__c sol : salesOrderLines){
                    
                    salesOrderLineRelatedToOpportunityLines.put(sol.AcctSeedERP__Opportunity_Product_Id__c, sol.Id);
                }
            }

            AcctSeed__Billing__c billing = new AcctSeed__Billing__c();
        
            billing.AcctSeed__Status__c = 'Approved';
            billing.AcctSeed__PDF_Email_Status__c = 'Unsent';
            billing.AcctSeedERP__Sales_Order__c = !salesOrders.isEmpty() ? salesOrders[0].Id : null; 
            billing.AcctSeed__Date__c = wrapper.billingDate;
            billing.AcctSeed__Due_Date2__c = wrapper.dueDate;
            billing.AcctSeed__Opportunity__c = Opp.id;
            billing.AcctSeed__Customer__c = Opp.AccountId;
            billing.AcctSeed__Shipping_Contact__c = Opp.Shipping_Name__c;
            
            billing.AcctSeed__Shipping_City__c = Opp.Shipping_City__c;
            billing.AcctSeed__Shipping_Country__c = Opp.Shipping_Country__c;
            billing.AcctSeed__Shipping_PostalCode__c = Opp.Shipping_PostalCode__c;
            billing.AcctSeed__Shipping_State__c = Opp.Shipping_State__c;
            billing.AcctSeed__Shipping_Street__c = Opp.Shipping_Street__c;
            billing.AcctSeed__Billing_Terms_Name__c = opp.Billing_Terms_Name__c;
            
            billing.AcctSeed__Billing_Contact__c = (Opp.Account.AcctSeed__Billing_Contact__c != null) ? Opp.Account.AcctSeed__Billing_Contact__c : Opp.Account.Contact_Person__c;
            billing.AcctSeed__Billing_Country__c = Opp.Account.BillingCountry;
            billing.AcctSeed__Billing_PostalCode__c = Opp.Account.BillingPostalCode;
            billing.AcctSeed__Billing_State__c = Opp.Account.BillingState;
            billing.AcctSeed__Billing_Street__c = Opp.Account.BillingStreet;
            billing.AcctSeed__Billing_City__c = Opp.Account.BillingCity;
            billing.AcctSeed__Accounting_Period__c = acctPeriod[0].id;
            billing.AcctSeed__Ledger__c = wrapper.ledger;
            billing.Shipping_Account__c = Opp.shipping_account__c;
            billing.Shipping_Name__c = Opp.Shipping_Name__c;
            billing.AcctSeed__Billing_Format__c = wrapper.billingFormatId;
            
                
            if(!Test.isRunningTest()){
                insert billing;
            } 


            //Inserting billing line items
            Set<Id> opportunityLinesItemsId = new Set<Id>();
            for(CreateBillingLinesWrapper lineWrapper: wrapper.lines){
                opportunityLinesItemsId.add(lineWrapper.lineId);
            }

            List<OpportunityLineItem> opportunityLineItems = [SELECT Id, AcctSeed__GL_Account_Variable_1__c, Product2Id, UnitPrice, Item_Description__c, size__c FROM OpportunityLineItem WHERE Id IN:opportunityLinesItemsId];
            Map<Id, OpportunityLineItem> opportunityLineItemsMap = new Map<Id, OpportunityLineItem>(opportunityLineItems);

            List<AcctSeed__Billing_Line__c> billingLineList = new List<AcctSeed__Billing_Line__c>();

            for(CreateBillingLinesWrapper lineWrapper: wrapper.lines){
                AcctSeed__Billing_Line__c line = new AcctSeed__Billing_Line__c();
                line.AcctSeed__Billing__c = billing.id;
                line.AcctSeed__Date__c = Date.today();
                line.AcctSeed__GL_Account_Variable_1__c = opportunityLineItemsMap.get(lineWrapper.lineId).AcctSeed__GL_Account_Variable_1__c;
                line.AcctSeed__Hours_Units__c = lineWrapper.quantity;
                line.AcctSeed__Opportunity_Product_Id__c = lineWrapper.lineId;
                line.AcctSeed__Product__c = opportunityLineItemsMap.get(lineWrapper.lineId).Product2id;
                line.AcctSeedERP__Sales_Order_Line__c = salesOrderLineRelatedToOpportunityLines.containsKey(lineWrapper.lineId) ? salesOrderLineRelatedToOpportunityLines.get(lineWrapper.lineId) : null;
                line.AcctSeed__Rate__c = opportunityLineItemsMap.get(lineWrapper.lineId).UnitPrice;
                line.Item_Description__c = opportunityLineItemsMap.get(lineWrapper.lineId).Item_Description__c;
                line.size_custom__c = opportunityLineItemsMap.get(lineWrapper.lineId).size__c;

                billingLineList.add(line);
            }

            if(!billingLineList.isEmpty() && !Test.isRunningTest()){
                insert billingLineList;
            }

            return billing.Id;
        } catch (Exception e) {
            throw new OpportunityDetailPageControllerException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Marian Lyzhychka | 07-03-2023 
    * @param type 
    * @param recordId 
    * @return String 
    **/
    @AuraEnabled
    public static String getPreparedLineForBilling(String type, String recordId){
        system.debug('type: '+type);
        system.debug('recordId: '+recordId);
        try {
            if(type == 'Opportunity'){
                String resp = prepareOpportunityForBilling(recordId);
                system.debug(resp);
                return resp;
            }else if(type == 'Sales Order'){
                return null;
            }

            return null;
        } catch (Exception e) {
            throw new OpportunityDetailPageControllerException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Marian Lyzhychka | 07-03-2023 
    * @param recordId 
    * @return String 
    **/
    private static String prepareOpportunityForBilling(String recordId){
        AcctSeed__Ledger__c ledger = [SELECT Id, Name FROM AcctSeed__Ledger__c WHERE Acctseed__type__c = 'Transactional' LIMIT 1];
        Date today = Date.today();
        String accountingPeriodDate = today.year() + '-0' + today.month();

        List<AcctSeed__Accounting_Period__c> acctPeriod = [SELECT AcctSeed__Status__c, Name, Id, AcctSeed__End_Date__c, AcctSeed__Start_Date__c FROM AcctSeed__Accounting_Period__c WHERE Name =:accountingPeriodDate limit 1];
        Id accountingPeriod = (!acctPeriod.IsEmpty()) ? acctPeriod[0].id : null;
        system.debug('1');
        Opportunity opp = [SELECT Id, Name, AccountId, Account.Deposit__c, Account.Name,
                            Account.AcctSeed__Billing_Contact__c, Account.BillingStreet, 
                            Account.BillingCity, Account.BillingState, Account.BillingPostalCode,
                            Account.AcctSeed__Billing_Format__c,
                            Account.BillingCountry, Account.Contact_Person__c,
                            Account.AcctSeed__Billing_Days_Due__c,
                            RecordType.Name,
                            Shipping_City__c, Shipping_Country__c, 
                            Shipping_PostalCode__c, Shipping_State__c, Shipping_Street__c, 
                            GL_Account_Variable_1__c, Shipping_Name__c, Shipping_Account__c,
                            Billing_Terms_Name__c, Billing_Deposit__c 
                            FROM Opportunity where id =:recordId limit 1];

        Decimal deposit = Opp.Billing_Deposit__c != null ? Decimal.ValueOf(Opp.Billing_Deposit__c) : null;
        Date dueDate2 = (Opp.Account.AcctSeed__Billing_Days_Due__c != null) ? Date.today() + (Integer)Opp.Account.AcctSeed__Billing_Days_Due__c : Date.today();
        Id billingFormat = Opp.Account.AcctSeed__Billing_Format__c;
        system.debug('2');
        Integer totalBillings = [select count() from AcctSeed__Billing__c where AcctSeed__Opportunity__c =: Opp.id];
        Boolean isFirstBilling = totalBillings == 0 ? true : false;

        List<OpportunityLineItem> opportunityLines = [SELECT Id, OpportunityId, PricebookEntryId, Product2Id, Product2.name, ProductCode, Quantity, 
                                                                                        TotalPrice, UnitPrice, ListPrice, 
                                                                                        Item_Description__c, Size__c, 
                                                                                        AcctSeed__GL_Account_Variable_1__c, 
                                                                                        AcctSeed__GL_Account_Variable_2__c, 
                                                                                        AcctSeed__GL_Account_Variable_3__c, 
                                                                                        AcctSeed__GL_Account_Variable_4__c
                                                                                        
                                                                                        FROM OpportunityLineItem where 
                                                                                        OpportunityId =: recordId order by SortOrder,
                                                                                        Product2.name, createdDate asc];
        BillingInitialWrapper responseWrapper = new BillingInitialWrapper(
            opp.AccountId,
            opp.Account.Name,
            deposit,
            accountingPeriod,
            ledger,
            billingFormat,
            Date.today(),
            dueDate2,
            new List<BillingLineWrapper>(),
            isFirstBilling
        );
        system.debug('3');
        if(opportunityLines.isEmpty()){
            return JSON.serialize(responseWrapper);
        }else{
            system.debug('4');
            Map<Id, OpportunityLineItem> opportunityLinesMap = new Map<Id, OpportunityLineItem>(opportunityLines);

            List<AcctSeed__Billing_Line__c> billingLines = [
                    SELECT Id, AcctSeed__Opportunity_Product_Id__c,
                    Name, AcctSeed__Total__c, 
                    AcctSeed__Product_Unit_Cost__c, 
                    AcctSeed__Hours_Units__c 
                    FROM AcctSeed__Billing_Line__c where 
                    AcctSeed__Opportunity_Product_Id__c in:opportunityLinesMap.keyset() 
                    and AcctSeed__Billing__r.AcctSeed__Opportunity__c =:recordId
                    and AcctSeed__Billing__r.AcctSeed__Type__c = 'Invoice'
            ];     
            
            Map<Id, Decimal> opportunityLinesWithBilledQuantity = new Map<Id, Decimal>();
            Map<Id, List<AcctSeed__Billing_Line__c>> opportunityLineWithBillingLines = new Map<Id, List<AcctSeed__Billing_Line__c>>();
            system.debug('5');
            for(AcctSeed__Billing_Line__c billingLine: billingLines){
                if(billingLine.AcctSeed__Opportunity_Product_Id__c != null){
                    if(!opportunityLineWithBillingLines.containsKey(billingLine.AcctSeed__Opportunity_Product_Id__c)){
                        opportunityLineWithBillingLines.put(billingLine.AcctSeed__Opportunity_Product_Id__c, new List<AcctSeed__Billing_Line__c>{billingLine});
                    }else{
                        opportunityLineWithBillingLines.get(billingLine.AcctSeed__Opportunity_Product_Id__c).add(billingLine);
                    }
                }
            }
            system.debug('6');
            for(Id opportunityLineId: opportunityLineWithBillingLines.keySet()){
                Decimal totalBilledQuantity = 0;
                for(AcctSeed__Billing_Line__c billingLine: opportunityLineWithBillingLines.get(opportunityLineId)){
                    totalBilledQuantity += billingLine.AcctSeed__Hours_Units__c;
                }

                opportunityLinesWithBilledQuantity.put(opportunityLineId, totalBilledQuantity);
            }
            system.debug('7');
            List<BillingLineWrapper> billingLinesInitialList = new List<BillingLineWrapper>();

            for(Id opportunityLineId: opportunityLinesMap.keySet()){
                billingLinesInitialList.add(new BillingLineWrapper(
                    opportunityLineId,
                    opportunityLinesMap.get(opportunityLineId).Product2.Name,
                    opportunityLinesMap.get(opportunityLineId).Quantity,
                    opportunityLinesWithBilledQuantity.containsKey(opportunityLineId) ? opportunityLinesWithBilledQuantity.get(opportunityLineId) : 0,
                    opportunityLinesMap.get(opportunityLineId).UnitPrice
                ));
            }

            responseWrapper.billingLines = billingLinesInitialList;
            system.debug('5');
            return JSON.serialize(responseWrapper);
            
        }
    }

    @AuraEnabled
    public static string getOpportunityStageValues(){
        try {
            List<OpportunityStage> opportunityStageList = [SELECT Id, DefaultProbability, MasterLabel, ForecastCategoryName FROM OpportunityStage];
            Map<String, OpportunityStageWrapper> opportunityStageMap = new Map<String, OpportunityStageWrapper>();

            for(OpportunityStage stage: opportunityStageList){
                opportunityStageMap.put(stage.MasterLabel, new OpportunityStageWrapper(
                    stage.DefaultProbability,
                    stage.ForecastCategoryName
                ));
            }

            return JSON.serialize(opportunityStageMap);
        } catch (Exception e) {
            throw new OpportunityDetailPageControllerException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string getOpportunityRecordTypes(){
        try {
            List<RecordType> recordTypeList = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType='Opportunity'];
            Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>(recordTypeList);

            return JSON.serialize(recordTypeMap);
        } catch (Exception e) {
            throw new OpportunityDetailPageControllerException(e.getMessage());
        }
    }

    public class OpportunityStageWrapper{
        public Decimal probability {get;set;}
        public String forecastCategoryName {get;set;}

        public OpportunityStageWrapper(Decimal probability, String forecastCategoryName){
            this.probability = probability;
            this.forecastCategoryName = forecastCategoryName;
        }
    }

    public class BillingInitialWrapper{
        public Id accountId {get;set;}
        public String accountName {get;set;}
        public Decimal deposit {get;set;}
        public Id accountingPeriod {get;set;}
        public AcctSeed__Ledger__c ledger {get;set;}
        public Id billingFormatId {get;set;}
        public Date billingDate {get;set;}
        public Date dueDate {get;set;}
        public List<BillingLineWrapper> billingLines {get;set;}
        public Boolean isFirstBilling {get;set;}

        public BillingInitialWrapper(Id accountId, String accountName, Decimal deposit, Id accountingPeriod, AcctSeed__Ledger__c ledger, Id billingFormatId,Date billingDate,Date dueDate,List<BillingLineWrapper> billingLines, Boolean isFirstBilling){
            this.accountId = accountId;
            this.accountName = accountName;
            this.deposit = deposit;
            this.accountingPeriod = accountingPeriod;
            this.ledger = ledger;
            this.billingFormatId = billingFormatId;
            this.billingDate = billingDate;
            this.dueDate = dueDate;
            this.billingLines = billingLines;
            this.isFirstBilling = isFirstBilling;
        }


    }

    public class BillingLineWrapper{
        public Id lineId {get;set;} //OLI || SOL
        public String productLineName {get;set;}
        public Decimal quantityOrdered {get;set;}
        public Decimal quantityBilled {get;set;}
        public Decimal unitPrice {get;set;}

        public Decimal quantityUnBilled {get;set;}
        public Decimal billedAmount {get;set;}
        public Boolean isLineFullyBilled {get;set;}
        public BillingLineWrapper(Id lineId, String productLineName, Decimal quantityOrdered, Decimal quantityBilled, Decimal unitPrice){
            this.lineId = lineId;
            this.productLineName = productLineName;
            this.quantityOrdered = quantityOrdered;
            this.quantityBilled = quantityBilled;
            this.unitPrice = unitPrice;

            this.quantityUnBilled = quantityOrdered - quantityBilled;
            this.billedAmount = quantityBilled * unitPrice;
            this.isLineFullyBilled = this.quantityOrdered == this.quantityBilled ? true : false;
        }
    }


    public class CreateBillingWrapper{
        public String recordId {get;set;}
        public Date billingDate {get;set;}
        public Date dueDate {get;set;}
        public String ledger {get;set;}
        public String billingFormatId {get;set;}
        public List<CreateBillingLinesWrapper> lines {get;set;}

        public CreateBillingWrapper(String recordId, Date billingDate, Date dueDate, String ledger, String billingFormatId, List<CreateBillingLinesWrapper> lines){
            this.recordId = recordId;
            this.billingDate = billingDate;
            this.dueDate = dueDate;
            this.ledger = ledger;
            this.billingFormatId = billingFormatId;
            this.lines = lines;
        }
    }
    public class CreateBillingLinesWrapper{
        public String lineId {get;set;}
        public Decimal quantity {get;set;}

        public CreateBillingLinesWrapper(String lineId, Decimal quantity){
            this.lineId = lineId;
            this.quantity = quantity;
        }
    }
}