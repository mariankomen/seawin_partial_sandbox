/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-24-2023
 * @last modified by  : Marian Lyzhychka
**/
public virtual class OpportunityDetailPageService {
    
    public class OpportunityDetailPageServiceException extends Exception {}
    
    private static final String CLOSED_WON_EXCEPTION = 'Opportunity must be Closed Won';
    private static final String HAS_SALES_ORDERS_EXCEPTION = 'Opportunity can not have more than 1 Sales Order.';
    private static final String NO_LINES_EXCEPTION = 'You cannot create a Sales Order from an Opportunity without products.';

    /**
    * @description 
    * @author Marian Lyzhychka | 07-13-2023 
    * @param recordId 
    * @return String 
    **/
    public static String getSObjectTypeService(String recordId){
        try{
            return String.valueOf(Id.valueOf(recordId).getSObjectType());
        }catch(Exception e){
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Marian Lyzhychka | 07-13-2023 
    * @return string 
    **/
    public static string getOpportunityStageValuesService(){
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
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Marian Lyzhychka | 07-13-2023 
    * @return string 
    **/
    public static string getOpportunityRecordTypesService(){
        try {
            List<RecordType> recordTypeList = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType='Opportunity'];
            Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>(recordTypeList);

            return JSON.serialize(recordTypeMap);
        } catch (Exception e) {
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Marian Lyzhychka | 07-13-2023 
    * @return String 
    **/
    public static String getOpportunitySubStagesService(){
        try {
            Map<String, List<String>> dependendSubStageToStage = DependentPicklistExtension.getDependentPicklistValues(Opportunity.Sub_Stage__c);
            
            return JSON.serialize(dependendSubStageToStage);
        } catch (Exception e) {
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Marian Lyzhychka | 07-13-2023 
    * @param opportunityId 
    * @return String 
    **/
    public static String getOpportunityAttachmentsService(String opportunityId){
        try{
            Map<Id, AcctSeedERP__Sales_Order__c> salesOrdersMap = new Map<Id, AcctSeedERP__Sales_Order__c>([SELECT Id FROM AcctSeedERP__Sales_Order__c WHERE AcctSeedERP__Opportunity__c=: opportunityId]);
            Set<Id> salesOrderSet = salesOrdersMap.keySet();
            Boolean opportunityHasSalesOrders = !salesOrdersMap.isEmpty();
    
            String query = 'SELECT Id, IsDeleted, ParentId, Name, ContentType, Description, LastModifiedDate, LastModifiedById, CreatedDate, CreatedById,CreatedBy.Name, OwnerId FROM Attachment WHERE';
            query += opportunityHasSalesOrders ? ' (parentId IN:salesOrderSet OR parentId =: opportunityId) ' : ' parentId =: opportunityId';
            query += ' ORDER BY CreatedDate DESC';
    
            List<Attachment> allAttachments = Database.query(query);
    
            List<Attachment> defaultAttachments = new List<Attachment>();
            List<Attachment> executedDocumentAttachments = new List<Attachment>();
    
            for(Attachment attach: allAttachments){
                if(attach.Description != null && attach.Description.Contains('<For Executed purpose>')){
                    executedDocumentAttachments.add(attach);    
                }else{
                    defaultAttachments.add(attach); 
                }  
            }
    
            OpportunityAttachmentsWrapper wrap = new OpportunityAttachmentsWrapper(
                defaultAttachments,
                executedDocumentAttachments
            );
    
            return JSON.serialize(wrap);
        }catch(Exception e){
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
        
    }

    public static String getAttachmentRecordService(String recordId){
        try{
            Attachment att = [SELECT Id, Name, Description FROM Attachment WHERE Id=:recordId];
            return JSON.serialize(att);
        }catch(Exception e){
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
    }
    public static void updateAttachmentRecordService(String record){
        try{
            Attachment att = (Attachment)JSON.deserialize(record, Attachment.class);
            update att;
        }catch(Exception e){
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
    }


    public static void transferExecutedDocumentsToAttachmetsService(String attachmentsJSON){
        try{
            List<Attachment> attachments = (List<Attachment>)JSON.deserialize(attachmentsJSON, List<Attachment>.class);
            for(Attachment att: attachments){
                String description = att.Description;
                att.Description = description.remove('<For Executed purpose>');
            }

            update attachments;
        }catch(Exception e){
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
    }

    public static void transferAttachmentsToExecutedDocumentsService(String attachmentsJSON){
        try{
            List<Attachment> attachments = (List<Attachment>)JSON.deserialize(attachmentsJSON, List<Attachment>.class);
            for(Attachment att: attachments){
                if(att.Description == null){
                    att.Description = '<For Executed purpose>';
                }else{
                    att.Description = att.Description+'<For Executed purpose>';
                }
            }

            update attachments;
        }catch(Exception e){
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
    }
    /**
    * @description 
    * @author Marian Lyzhychka | 07-13-2023 
    * @param accountId 
    * @return String 
    **/
    public static String getAccountService(String accountId){
        try {
            String fieldsStr = AllFields.Fields('Account', new List<String>());
            Account acc = Database.query('SELECT ' + fieldsStr + ' FROM Account where id=:accountId Limit 1');
            return JSON.serialize(acc);
        } catch (Exception e) {
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author Marian Lyzhychka | 07-13-2023 
    * @param opportunityId 
    * @return String 
    **/
    public static String getOpportunityService(String opportunityId){
        try {
            String fieldsStr = AllFields.Fields('Opportunity', new List<String>{'MasterRecordId', 'ParentId'});
            Opportunity opp = Database.query('SELECT ' + fieldsStr + ' FROM Opportunity where id=:opportunityId Limit 1');
            return JSON.serialize(opp);
        } catch (Exception e) {
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
    }


    /**
    * @description 
    * @author Marian Lyzhychka | 07-13-2023 
    * @param opportunityId 
    * @return string 
    **/
    public static string getOpportunityLineItemsService(String opportunityId){
        try {
            List<OpportunityLineItem> oliList = [SELECT Id, 
                                                    Product2.Name, 
                                                    Product2Id, 
                                                    Product2.Product_Image_Short_URL__c, 
                                                    Product2.ProductCode, 
                                                    Product2.RecordType.DeveloperName,
                                                    Product2.Available_Quantity__c,
                                                    Product2.Kit_Available_Quantity__c,
                                                    Item_Description__c, 
                                                    Size__c, 
                                                    Quantity, 
                                                    Available_Quantity__c, 
                                                    UnitPrice, 
                                                    TotalPrice 
                                                    FROM OpportunityLineItem 
                                                    WHERE OpportunityId=:opportunityId ORDER BY SortOrder ASC];
            RelatedListWrapper wrapper = new RelatedListWrapper(oliList, oliList.size());
            return JSON.serialize(wrapper);
        } catch (Exception e) {
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
    }


    public static string getOptionalOpportunityLinesService(String opportunityId){
        try{
            List<Optional_Products_Opportunity__c> optionalLines = [SELECT Id, 
                                                                        Product__r.Name,
                                                                        Product__c,
                                                                        Product__r.Product_Image_Short_URL__c, 
                                                                        Product__r.ProductCode, 
                                                                        Product__r.RecordType.DeveloperName,
                                                                        Product__r.Available_Quantity__c,
                                                                        Product__r.Kit_Available_Quantity__c,
                                                                        Item_Description__c,
                                                                        Size__c,
                                                                        Quantity__c,
                                                                        UnitPrice__c,
                                                                        TotalPrice__c,
                                                                        Opportunity__c
                                                                        FROM Optional_Products_Opportunity__c
                                                                        WHERE Opportunity__c =: opportunityId
                                                                        ORDER BY SortOrder__c ASC];
            RelatedListWrapper wrapper = new RelatedListWrapper(optionalLines, optionalLines.size());
            return JSON.serialize(wrapper);
        }catch(Exception e){
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
        

    }

    /**
    * @description 
    * @author Marian Lyzhychka | 07-03-2023 
    * @param type 
    * @param recordId 
    * @return String 
    **/
    public static String getPreparedLineForBillingService(String type, String recordId){
        try {
            if(type == 'Opportunity'){
                return prepareOpportunityForBilling(recordId);
            }else if(type == 'Sales Order'){
                return prepareSalesOrderForBilling(recordId);
            }

            return null;
        } catch (Exception e) {
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
    }

    private static String prepareSalesOrderForBilling(String recordId){
        AcctSeed__Ledger__c ledger = [SELECT Id, Name FROM AcctSeed__Ledger__c WHERE Acctseed__type__c = 'Transactional' LIMIT 1];
        Date today = Date.today();
        String accountingPeriodDate = today.year() + '-0' + today.month();

        List<AcctSeed__Accounting_Period__c> acctPeriod = [SELECT AcctSeed__Status__c, Name, Id, AcctSeed__End_Date__c, AcctSeed__Start_Date__c FROM AcctSeed__Accounting_Period__c WHERE Name =:accountingPeriodDate limit 1];
        Id accountingPeriod = (!acctPeriod.IsEmpty()) ? acctPeriod[0].id : null;
        system.debug('1');
        AcctSeedERP__Sales_Order__c opp = [SELECT Id, Name, AcctSeedERP__Customer__c, AcctSeedERP__Customer__r.Deposit__c, AcctSeedERP__Customer__r.Name,
        AcctSeedERP__Customer__r.AcctSeed__Billing_Contact__c, AcctSeedERP__Customer__r.BillingStreet, 
        AcctSeedERP__Customer__r.BillingCity, AcctSeedERP__Customer__r.BillingState, AcctSeedERP__Customer__r.BillingPostalCode,
        AcctSeedERP__Customer__r.AcctSeed__Billing_Format__c,
        AcctSeedERP__Customer__r.BillingCountry, AcctSeedERP__Customer__r.Contact_Person__c,
        AcctSeedERP__Customer__r.AcctSeed__Billing_Days_Due__c,
                            RecordType.Name,
                            AcctSeedERP__Shipping_City__c, AcctSeedERP__Shipping_Country__c, 
                            AcctSeedERP__Shipping_PostalCode__c, AcctSeedERP__Shipping_State__c, AcctSeedERP__Shipping_Street__c, 
                            GL_Account_Variable_1__c, Shipping_Name__c, Shipping_Account__c,
                            Billing_Terms_Name__c, Billing_Deposit__c 
                            FROM AcctSeedERP__Sales_Order__c WHERE id =:recordId limit 1];

        Decimal deposit = Opp.Billing_Deposit__c != null ? Decimal.ValueOf(Opp.Billing_Deposit__c) : null;
        Date dueDate2 = (Opp.AcctSeedERP__Customer__r.AcctSeed__Billing_Days_Due__c != null) ? Date.today() + (Integer)Opp.AcctSeedERP__Customer__r.AcctSeed__Billing_Days_Due__c : Date.today();
        Id billingFormat = Opp.AcctSeedERP__Customer__r.AcctSeed__Billing_Format__c;
        system.debug('2');
        Integer totalBillings = [select count() from AcctSeed__Billing__c where AcctSeedERP__Sales_Order__c =: Opp.id];
        Boolean isFirstBilling = totalBillings == 0 ? true : false;

        List<AcctSeedERP__Sales_Order_Line__c> opportunityLines = [SELECT Id, AcctSeedERP__Sales_Order__c, AcctSeedERP__Product__c,
                                                                                        AcctSeedERP__Product__r.name,
                                                                                        AcctSeedERP__Product__r.ProductCode,
                                                                                        AcctSeedERP__Quantity_Ordered__c, 
                                                                                        AcctSeedERP__Total__c,
                                                                                        Item_Description__c,
                                                                                        AcctSeedERP__Unit_Price__c,
                                                                                        Size__c,
                                                                                        AcctSeedERP__GL_Account_Variable_1__c
                                                                                        FROM AcctSeedERP__Sales_Order_Line__c where 
                                                                                        AcctSeedERP__Sales_Order__c =: recordId order by SortOrder__c,
                                                                                        AcctSeedERP__Product__r.name, createdDate asc];
        BillingInitialWrapper responseWrapper = new BillingInitialWrapper(
            opp.AcctSeedERP__Customer__c,
            opp.AcctSeedERP__Customer__r.Name,
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
            Map<Id, AcctSeedERP__Sales_Order_Line__c> opportunityLinesMap = new Map<Id, AcctSeedERP__Sales_Order_Line__c>(opportunityLines);

            List<AcctSeed__Billing_Line__c> billingLines = [
                    SELECT Id, AcctSeed__Opportunity_Product_Id__c,AcctSeedERP__Sales_Order_Line__c,
                    Name, AcctSeed__Total__c, 
                    AcctSeed__Product_Unit_Cost__c, 
                    AcctSeed__Hours_Units__c 
                    FROM AcctSeed__Billing_Line__c where 
                    AcctSeedERP__Sales_Order_Line__c in:opportunityLinesMap.keyset() 
                    and AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c =:recordId
                    and AcctSeed__Billing__r.AcctSeed__Type__c = 'Invoice'
            ];     
            system.debug('billingLines: '+billingLines.size());
            Map<Id, Decimal> opportunityLinesWithBilledQuantity = new Map<Id, Decimal>();
            Map<Id, List<AcctSeed__Billing_Line__c>> opportunityLineWithBillingLines = new Map<Id, List<AcctSeed__Billing_Line__c>>();
            system.debug('5');
            for(AcctSeed__Billing_Line__c billingLine: billingLines){
                if(billingLine.AcctSeedERP__Sales_Order_Line__c != null){
                    if(!opportunityLineWithBillingLines.containsKey(billingLine.AcctSeedERP__Sales_Order_Line__c)){
                        opportunityLineWithBillingLines.put(billingLine.AcctSeedERP__Sales_Order_Line__c, new List<AcctSeed__Billing_Line__c>{billingLine});
                    }else{
                        opportunityLineWithBillingLines.get(billingLine.AcctSeedERP__Sales_Order_Line__c).add(billingLine);
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
            system.debug('opportunityLinesWithBilledQuantity: '+opportunityLinesWithBilledQuantity);
            List<BillingLineWrapper> billingLinesInitialList = new List<BillingLineWrapper>();

            for(Id opportunityLineId: opportunityLinesMap.keySet()){
                billingLinesInitialList.add(new BillingLineWrapper(
                    opportunityLineId,
                    opportunityLinesMap.get(opportunityLineId).AcctSeedERP__Product__r.Name,
                    opportunityLinesMap.get(opportunityLineId).AcctSeedERP__Quantity_Ordered__c,
                    opportunityLinesWithBilledQuantity.containsKey(opportunityLineId) ? opportunityLinesWithBilledQuantity.get(opportunityLineId) : 0,
                    opportunityLinesMap.get(opportunityLineId).AcctSeedERP__Unit_Price__c
                ));
            }

            responseWrapper.billingLines = billingLinesInitialList;
            system.debug('5');
            system.debug(JSON.serialize(responseWrapper));
            return JSON.serialize(responseWrapper);
            
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


    /**
    * @description 
    * @author Marian Lyzhychka | 07-13-2023 
    * @param linesWrapperJson 
    * @return String 
    **/
    public static String createBillingService(String linesWrapperJson){
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
                throw new OpportunityDetailPageServiceException(exceptionMessage);
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
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
    }



    /**
    * @description 
    * @author Marian Lyzhychka | 07-13-2023 
    * @param idList 
    **/
    public static void deleteSObjectListService(String idList){
        try {
            List<Id> sobjectIdList = (List<Id>)JSON.deserialize(idList, List<Id>.class);
            system.debug(sobjectIdList);
            String sObjectTypeName = String.valueOf(sobjectIdList[0].getSobjectType());
            system.debug(sObjectTypeName);
            String query = 'SELECT Id FROM ' + sObjectTypeName + ' WHERE Id IN:sobjectIdList';
            List<SObject> items = Database.query(query);

            delete items;
        } catch (Exception e) {
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
    }


    /**
    * @description 
    * @author Marian Lyzhychka | 07-17-2023 
    * @param opportunityId 
    **/
    public static String getPredefinedSalesOrderDataService(String opportunityId){
        Opportunity opp = [SELECT Id, StageName, Account.Name, GL_Account_Variable_1__c, GL_Account_Variable_1__r.Name FROM Opportunity WHERE Id=:opportunityId];

        if(opp.StageName != 'Closed Won'){
            throw new OpportunityDetailPageServiceException(CLOSED_WON_EXCEPTION);
        }

        List<AcctSeedERP__Sales_Order__c> existingSalesOrders = [SELECT Id FROM AcctSeedERP__Sales_Order__c WHERE AcctSeedERP__Opportunity__c=:opportunityId];
        
        if(!existingSalesOrders.isEmpty()){
            throw new OpportunityDetailPageServiceException(HAS_SALES_ORDERS_EXCEPTION);
        }
        List<AcctSeed__Ledger__c> ledgers = [select id, name from AcctSeed__Ledger__c];

        List<SalesOrderLinePreWrapper> lines = getPredefinedSalesOrderLinesData(opp);

        CreateSalesOrderPreWrapper wrapper = new CreateSalesOrderPreWrapper(
            opp.AccountId,
            opp.Account.Name,
            opp.GL_Account_Variable_1__r,
            ledgers,
            lines
        );

        return JSON.serialize(wrapper);
    }

    

    /**
    * @description 
    * @author Marian Lyzhychka | 07-17-2023 
    * @param opp 
    * @return List<SalesOrderLinePreWrapper> 
    **/
    public static List<SalesOrderLinePreWrapper> getPredefinedSalesOrderLinesData(Opportunity opp){
        List<OpportunityLineItem> opportunityLineItems = [SELECT Id, Product2Id, Product2.Name, ProductCode,Product2.ProductCode,
                                               Item_Description__c, Size__c, Quantity, TotalPrice,
                                               UnitPrice, SortOrder,
                                               Product2.AcctSeed__Inventory_Type__c,
                                               Product2.Allow_Custom_Image__c,
                                               Product2.Kit_Available_Quantity__c,
                                               Allow_Product_Description_Change__c,
                                               Product2.Allow_Product_Description_Change__c,
                                               AcctSeed__GL_Account_Variable_1__c, 
                                               AcctSeed__GL_Account_Variable_2__c, 
                                               AcctSeed__GL_Account_Variable_3__c, 
                                               AcctSeed__GL_Account_Variable_4__c, AlternateImageURL__c FROM OpportunityLineItem WHERE 
                                               OpportunityId = :opp.Id
                                               and product2.AcctSeed__Inventory_Type__c != 'Raw Material' 
                                               order by sortorder,name,createddate asc];
        if(opportunityLineItems.isEmpty()){
            throw new OpportunityDetailPageServiceException(NO_LINES_EXCEPTION);
        }

        Set<Id> kitLinesSetId = new Set<Id>();
        for(OpportunityLineItem oli: opportunityLineItems){
            if(oli.Product2.AcctSeed__Inventory_Type__c == 'Kit'){
                kitLinesSetId.add(oli.Product2Id);
            }
        }

        Map<Id, List<AcctSeed__Product_Part__c>> kitWithRelatedChildrensMap = new Map<Id, List<AcctSeed__Product_Part__c>>();

        if(!kitLinesSetId.isEmpty()){
            List<AcctSeed__Product_Part__c> kitChildrensList = [SELECT Id, Name, Kit_Product__c, 
                                                                Kit_Children__c,
                                                                Kit_Children__r.ProductCode,
                                                                Kit_Children__r.Description,
                                                                Kit_Children__r.Name,
                                                                Kit_Children__r.Allow_Product_Description_Change__c,
                                                                Kit_Children__r.Size__c,
                                                                AcctSeed__Quantity__c 
                                                                FROM AcctSeed__Product_Part__c 
                                                                WHERE Kit_Product__c in:kitLinesSetId];
            for(AcctSeed__Product_Part__c children: kitChildrensList){
                if(!kitWithRelatedChildrensMap.containsKey(children.Kit_Product__c)){
                    kitWithRelatedChildrensMap.put(children.Kit_Product__c, new List<AcctSeed__Product_Part__c>{children});
                }else{
                    kitWithRelatedChildrensMap.get(children.Kit_Product__c).add(children);
                }
            }


        }

        List<SalesOrderLinePreWrapper> linesWrapper = new List<SalesOrderLinePreWrapper>();

        for(OpportunityLineItem oli: opportunityLineItems){
            SalesOrderLinePreWrapper lineWrapper = new SalesOrderLinePreWrapper(
                oli.Product2Id,
                oli.Product2.Name,
                oli.Product2.ProductCode,
                oli.Item_Description__c,
                oli.Size__c,
                oli.Quantity,
                oli.UnitPrice,
                oli.Product2.AcctSeed__Inventory_Type__c == 'Kit', //If true = kit || false - no
                new List<SalesOrderLineKitChildrenWrapper>(),
                oli.Product2.Allow_Product_Description_Change__c,
                oli.Id
            );
            if(lineWrapper.isKit){
                List<AcctSeed__Product_Part__c> childrens = kitWithRelatedChildrensMap.containsKey(oli.Product2Id) ? kitWithRelatedChildrensMap.get(oli.Product2Id) : new List<AcctSeed__Product_Part__c>();
                List<SalesOrderLineKitChildrenWrapper> childrensWrapper = new List<SalesOrderLineKitChildrenWrapper>();
                for(AcctSeed__Product_Part__c children: childrens){
                    childrensWrapper.add(new SalesOrderLineKitChildrenWrapper(
                        children.Kit_Children__c,
                        children.Kit_Children__r.Name,
                        children.Kit_Children__r.ProductCode,
                        children.Kit_Children__r.Description,
                        children.Kit_Children__r.Size__c,
                        oli.Quantity * children.AcctSeed__Quantity__c,
                        children.AcctSeed__Quantity__c,
                        children.Kit_Children__r.Allow_Product_Description_Change__c
                    ));
                }
                lineWrapper.kitChildrens = childrensWrapper;
            }

            linesWrapper.add(lineWrapper);
        }

        return linesWrapper;
    }


    public static Id createSalesOrderService(String payload, String opportunityId){
        try{
            CreateSalesOrderPreWrapper wrapper = (CreateSalesOrderPreWrapper)JSON.deserialize(payload, CreateSalesOrderPreWrapper.class);
            System.debug(wrapper);
    
            list<AcctSeed__Billing_Format__c> salesOrderFormats = [select id from AcctSeed__Billing_Format__c where 
                                                          AcctSeed__Type__c = 'Sales Order' limit 1];
    
    
            List<String> fieldsList = new List<String>{'Id', 'StageName', 'Account.Name', 'ContactPerson__c','ContactPerson__r.name','LeadSource',
                'Account.Acctseed__Billing_Contact__r.name', 'recordtype.name','recordtypeId',
                'Description', 'Note__c', 'deliver_by__c','Shipping_Term__c', 'Account.billingStreet', 
                'Account.billingCity', 'Account.billingState', 'account.billingPostalCode', 'submittal_submitted_date__c',
                'Account.billingcountry', 'shipping_street__c', 'shipping_city__c', 'shipping_state__c', 
                'shipping_postalcode__c', 'shipping_country__c', 'submittal_approval_date__c',
                'Contract_Date__c','Financial_Clearance_Date__c','PO_Number__c', 'PO_Date__c',
                'GL_Account_Variable_1__c', 'shipping_name__c', 'shipping_account__c', 'Project__c','sales_rep_o__c',
                'Manufacturer_Rep__c','OwnerId', 'Account.Manufacture_Representative__c','Price_Level__c', 'Sales_rep_o__r.name','Approve_Date__c', 'Referral_Sales_Rep__c',
                'Billing_Deposit__c', 'Billing_Terms_Name__c', 'Specified_Rep__c'
                    };  
                     
            String fields = String.join(fieldsList, ',');
            
            Opportunity oppty = Database.Query('Select ' + fields + ' From Opportunity where id=:opportunityId Limit 1');
    
    
            AcctSeedERP__Sales_Order__c so = new AcctSeedERP__Sales_Order__c();
            so.Billing_Name__c = (oppty.account.acctseed__billing_contact__r.name == null)
                ?oppty.ContactPerson__c:oppty.account.acctseed__billing_contact__c;
            so.Billing_Account__c = oppty.accountId; 
            so.AcctSeedERP__Billing_City__c = oppty.account.billingcity;
            so.AcctSeedERP__Billing_Country__c = oppty.account.billingcountry;
            so.AcctSeedERP__Billing_PostalCode__c = oppty.account.billingpostalcode;
            so.AcctSeedERP__Billing_State__c = oppty.account.billingstate;
            so.AcctSeedERP__Billing_Street__c = oppty.account.billingstreet;
            so.AcctSeedERP__Customer__c = oppty.accountid;
            so.AcctSeedERP__Opportunity__c = oppty.id;
            so.Contact__c = oppty.ContactPerson__c;
            so.Sales_Rep_O__c = oppty.sales_rep_o__c;
            so.ownerid = oppty.OwnerId;
            so.Referral_Sales_Rep__c = oppty.Referral_Sales_Rep__c;
            so.Specified_Rep__c = oppty.Specified_Rep__c;
            so.manufacturer_rep__c = oppty.manufacturer_rep__c;
            
            so.AcctSeedERP__Shipping_City__c = oppty.Shipping_City__c;
            so.AcctSeedERP__Shipping_Country__c = oppty.Shipping_Country__c;
            so.AcctSeedERP__Shipping_PostalCode__c = oppty.Shipping_PostalCode__c;
            so.AcctSeedERP__Shipping_State__c = oppty.Shipping_State__c;
            so.AcctSeedERP__Shipping_Street__c = oppty.Shipping_Street__c;
            
            so.Shipping_Account__c = oppty.Shipping_Account__c;
            so.Shipping_Name__c = oppty.Shipping_Name__c;
    
            so.Billing_Deposit__c = oppty.Billing_Deposit__c;
            so.Billing_Terms_Name__c = oppty.Billing_Terms_Name__c;
            
            so.Customer_s_ETA__c = oppty.deliver_by__c;
            so.Notes__c = oppty.Note__c;
            so.Shipping_Term__c = oppty.Shipping_Term__c;
            so.Special_Instruction__c = oppty.Description;
            so.AcctSeedERP__Ledger__c = wrapper.selectedLedgerId;
            so.Sales_Order_Format__c = salesOrderFormats.isEmpty() ? null : salesOrderFormats[0].Id;
            so.GL_Account_Variable_1__c = wrapper.selectedGlVarId;
            so.Project__c = oppty.Project__c;
            so.Price_Level__c = oppty.Price_Level__c;
            so.RecordTypeId = getSalesOrderRecordType(oppty.sales_rep_o__c, oppty.recordtype.name);
            so.Approval_Date__c = oppty.approve_date__c;
            so.PO_Date__c = oppty.PO_Date__c;
            so.PO_Number__c = oppty.PO_Number__c;
            so.LeadSource__c = oppty.LeadSource;
    
            insert so;
    
    
            List<AcctSeedERP__Sales_Order_Line__c> salesOrderLines = compileSalesOrderLines(wrapper.lines, opportunityId, so.Id);
    
            if(salesOrderLines.isEmpty()){
                throw new OpportunityDetailPageServiceException('Sales Order have not lines.');
            }   
            insert salesOrderLines;

            AfterSalesOrderTriggerHandler.LinkBillings(new List<AcctSeedERP__Sales_Order__c>{so});
            return so.Id;
        }catch(Exception e){
            system.debug('###################: '+e.getLineNumber());
            throw new OpportunityDetailPageServiceException(e.getMessage());
        }
        
    }

    private static List<AcctSeedERP__Sales_Order_Line__c> compileSalesOrderLines(List<SalesOrderLinePreWrapper> lines, String opportunityId, Id salesOrderId){
        List<OpportunityLineItem> opportunityLineItems = [SELECT Id, Product2Id, Product2.Name, ProductCode,Product2.ProductCode,
                                               Item_Description__c, Size__c, Quantity, TotalPrice,
                                               UnitPrice, SortOrder,
                                               Product2.AcctSeed__Inventory_Type__c,
                                               Product2.Allow_Custom_Image__c,
                                               Product2.Kit_Available_Quantity__c,
                                               Allow_Product_Description_Change__c,
                                               Product2.Allow_Product_Description_Change__c,
                                               AcctSeed__GL_Account_Variable_1__c, 
                                               AcctSeed__GL_Account_Variable_2__c, 
                                               AcctSeed__GL_Account_Variable_3__c, 
                                               AcctSeed__GL_Account_Variable_4__c, AlternateImageURL__c FROM OpportunityLineItem WHERE 
                                               OpportunityId = :opportunityId
                                               and product2.AcctSeed__Inventory_Type__c != 'Raw Material' 
                                               order by sortorder,name,createddate asc];
        Map<Id, OpportunityLineItem> opportunityLineItemsMap = new Map<Id, OpportunityLineItem>(opportunityLineItems);
        List<AcctSeedERP__Sales_Order_Line__c> salesOrderLines = new List<AcctSeedERP__Sales_Order_Line__c>();

        Integer sortOrder = 0;
        for(SalesOrderLinePreWrapper lineWrapper: lines){
            if(!lineWrapper.selected) continue;

            AcctSeedERP__Sales_Order_Line__c sol = new AcctSeedERP__Sales_Order_Line__c();
            sol.AcctSeedERP__Product__c = lineWrapper.productId;
            sol.AcctSeedERP_Description__c = lineWrapper.description;
            sol.Item_description__c = lineWrapper.description;
            sol.AcctSeedERP__Quantity_Ordered__c = lineWrapper.quantity;
            sol.Size__c = lineWrapper.size;
            sol.Size__c = opportunityLineItemsMap.get(lineWrapper.opportunityLineId).AlternateImageURL__c;
            sol.AcctSeedERP__Unit_Price__c = opportunityLineItemsMap.get(lineWrapper.opportunityLineId).UnitPrice;
            sol.sortorder__c = sortOrder;
            sol.kit__c = lineWrapper.isKit;
            sol.AcctSeedERP__Opportunity_Product_Id__c = lineWrapper.opportunityLineId;
            sol.AcctSeedERP__GL_Account_Variable_1__c = opportunityLineItemsMap.get(lineWrapper.opportunityLineId).AcctSeed__GL_Account_Variable_1__c;
            sol.AcctSeedERP__GL_Account_Variable_2__c = opportunityLineItemsMap.get(lineWrapper.opportunityLineId).AcctSeed__GL_Account_Variable_2__c;
            sol.AcctSeedERP__GL_Account_Variable_3__c = opportunityLineItemsMap.get(lineWrapper.opportunityLineId).AcctSeed__GL_Account_Variable_3__c;
            sol.AcctSeedERP__GL_Account_Variable_4__c = opportunityLineItemsMap.get(lineWrapper.opportunityLineId).AcctSeed__GL_Account_Variable_4__c;
            sol.Allow_Product_Description_Change__c = opportunityLineItemsMap.get(lineWrapper.opportunityLineId).Allow_Product_Description_Change__c;
            sol.AcctSeedERP__Sales_Order__c = salesOrderId;
            
            salesOrderLines.add(sol);

            sortOrder += 1;
            
            if(lineWrapper.isKit){
                for(SalesOrderLineKitChildrenWrapper children: lineWrapper.kitChildrens){
                    AcctSeedERP__Sales_Order_Line__c solChildren = new AcctSeedERP__Sales_Order_Line__c();
                    solChildren.AcctSeedERP__Product__c = children.productId;
                    solChildren.AcctSeedERP_Description__c = children.description;
                    solChildren.Item_description__c = children.description;
                    solChildren.AcctSeedERP__Quantity_Ordered__c = children.quantity;
                    solChildren.Size__c = children.size;
                    solChildren.AcctSeedERP__Unit_Price__c = 0;
                    solChildren.Sortorder__c = sortOrder;
                    solChildren.Kit_Children__c = true;
                    solChildren.AcctSeedERP__GL_Account_Variable_1__c = opportunityLineItemsMap.get(lineWrapper.opportunityLineId).AcctSeed__GL_Account_Variable_1__c;
                    solChildren.AcctSeedERP__Sales_Order__c = salesOrderId;
                    sortOrder += 1;

                    salesOrderLines.add(solChildren);
                }
            }
        }

        return salesOrderLines;

    }
    private static String getSalesOrderRecordType(Id salesRepId, String opportunityRecordTypeName){
        String recordtypeName = null;
        List<Sales_Rep__c> defaults = [SELECT default_record_type__c FROM Sales_Rep__c WHERE id=:salesRepId AND default_record_type__c != null LIMIT 1];
        
        String recordtypeIdIs = null;
        
        if(!defaults.isEmpty()){
			recordtypeName = defaults[0].default_record_type__c;
  
            recordtypeIdIs = [SELECT Id FROM RecordType WHERE sobjecttype='AcctSeedERP__Sales_Order__c' AND Name =:recordtypeName LIMIT 1][0].id; 
        }
        if(Defaults.isEmpty() || recordtypeIdIs == null){
            
            recordtypeIdIs = [SELECT id FROM RecordType WHERE sobjecttype = 'AcctSeedErP__sales_Order__c' AND name =: opportunityRecordTypeName LIMIT 1][0].id;
            
        }

        return recordtypeIdIs;
    }

    public class RelatedListWrapper{
        public List<SObject> sobjectList {get;set;}
        public Integer totalRecords {get;set;}

        public RelatedListWrapper(List<SObject> sobjectList, Integer totalRecords){
            this.sobjectList = sobjectList;
            this.totalRecords = totalRecords;
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
        public Boolean allowDescriptionChange {get;set;}
        
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

    public class OpportunityAttachmentsWrapper{
        public List<Attachment> defaultAttachments {get;set;}
        public List<Attachment> executedDocuments {get;set;}

        public OpportunityAttachmentsWrapper(List<Attachment> defaultAttachments, List<Attachment> executedDocuments){
            this.defaultAttachments = defaultAttachments;
            this.executedDocuments = executedDocuments;
        }
    }


    public class SalesOrderLinePreWrapper{
        public Id productId {get;set;}
        public String productName {get;set;}
        public String productCode {get;set;}
        public String description {get;set;}
        public String size {get;set;}
        public Decimal quantity {get;set;}
        public Decimal salesPrice {get;set;}
        public Boolean isKit {get;set;}
        public List<SalesOrderLineKitChildrenWrapper> kitChildrens {get;set;}
        public Boolean allowDescriptionChange {get;set;}
        public Id opportunityLineId {get;set;}
        public Boolean selected {get;set;}

        public SalesOrderLinePreWrapper(Id productId, String productName, String productCode, String description, String size, Decimal quantity, Decimal salesPrice, Boolean isKit, List<SalesOrderLineKitChildrenWrapper> kitChildrens, Boolean allowDescriptionChange, Id opportunityLineId){
            this.productId = productId;
            this.productName = productName;
            this.productCode = productCode;
            this.description = description;
            this.size = size;
            this.quantity = quantity;
            this.salesPrice = salesPrice;
            this.isKit = isKit;
            this.kitChildrens = kitChildrens;
            this.allowDescriptionChange = allowDescriptionChange;
            this.opportunityLineId = opportunityLineId;
            this.selected = true;
        }
    }

    public class SalesOrderLineKitChildrenWrapper{
        public Id productId {get;set;}
        public String productName {get;set;}
        public String productCode {get;set;}
        public String description {get;set;}
        public String size {get;set;}
        public Decimal quantity {get;set;}
        public Decimal kitQuantity {get;set;}
        public Boolean allowDescriptionChange {get;set;}

        public SalesOrderLineKitChildrenWrapper(Id productId, String productName, String productCode, String description, String size, Decimal quantity, Decimal kitQuantity, Boolean allowDescriptionChange){
            this.productId = productId;
            this.productName = productName;
            this.productCode = productCode;
            this.description = description;
            this.size = size;
            this.quantity = quantity;
            this.kitQuantity = kitQuantity;
            this.allowDescriptionChange = allowDescriptionChange;
        }
    }

    public class CreateSalesOrderPreWrapper{
        public Id customerId {get;set;}
        public String customerName {get;set;}
        public AcctSeed__Accounting_Variable__c glVariable {get;set;}
        public List<AcctSeed__Ledger__c> ledgers {get;set;}
        public List<SalesOrderLinePreWrapper> lines {get;set;}
        public String selectedGlVarId {get;set;}
        public String selectedLedgerId {get;set;}

        public CreateSalesOrderPreWrapper(Id customerId, String customerName, AcctSeed__Accounting_Variable__c glVariable, List<AcctSeed__Ledger__c> ledgers, List<SalesOrderLinePreWrapper> lines){
            this.customerId = customerId;
            this.customerName = customerName;
            this.glVariable = glVariable;
            this.ledgers = ledgers;
            this.lines = lines;
        }
    }
}