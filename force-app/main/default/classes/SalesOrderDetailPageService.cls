/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-28-2023
 * @last modified by  : Marian Lyzhychka
**/
public virtual class SalesOrderDetailPageService {
    
    public class SalesOrderDetailPageServiceException extends Exception {}

    public static String getLogginedUserProfileService(){
        try{
            User u = [SELECT Id, Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];

            return u.Profile.Name;
        }catch(Exception e){
            throw new SalesOrderDetailPageServiceException(e.getMessage());
        }
        
    }

    public static String getSalesOrderService(String salesOrderId){
        try {
            String fieldsStr = AllFields.Fields('AcctSeedERP__Sales_Order__c', new List<String>());
            AcctSeedERP__Sales_Order__c salesOrder = Database.query('SELECT ' + fieldsStr + ' FROM AcctSeedERP__Sales_Order__c where id=:salesOrderId Limit 1');
            return JSON.serialize(salesOrder);
        } catch (Exception e) {
            throw new SalesOrderDetailPageServiceException(e.getMessage());
        }
    }

    public static String getSalesOrderLinesService(String salesOrderId){
        try{
            List<AcctSeedERP__Sales_Order_Line__c> lines = [SELECT Id, 
                                                                    AcctSeedERP__Product__c, 
                                                                    AcctSeedERP__Product__r.Name,
                                                                    Item_Description__c,
                                                                    Size__c,
                                                                    AcctSeedERP__Quantity_Ordered__c,
                                                                    AcctSeedERP__Product__r.RecordType.DeveloperName,
                                                                    AcctSeedERP__Product__r.Available_Quantity__c,
                                                                    AcctSeedERP__Product__r.Kit_Available_Quantity__c,
                                                                    AcctSeedERP__Product__r.Product_Image_Short_URL__c,
                                                                    AcctSeedERP__Quantity_Shipped__c,
                                                                    Sales_Price__c,
                                                                    AcctSeedERP__Total__c,
                                                                    AcctSeedERP__Quantity_Allocated__c
                                                            FROM AcctSeedERP__Sales_Order_Line__c
                                                            WHERE AcctSeedERP__Sales_Order__c =: salesOrderId
                                                            ORDER BY SortOrder__c ASC];
            
            SObjectListWrapper wrapper = new SObjectListWrapper(lines, lines.size());
            return JSON.serialize(wrapper);
        }catch(Exception e){
            throw new SalesOrderDetailPageServiceException(e.getMessage());
        }
        
    }

    public static String createBillingService(String linesWrapperJson){
        try {
            system.debug('linesWrapperJson: '+linesWrapperJson);
            CreateBillingWrapper wrapper = (CreateBillingWrapper)JSON.deserialize(linesWrapperJSON, CreateBillingWrapper.class);
            system.debug(wrapper);
            AcctSeedERP__Sales_Order__c opp = [SELECT Id, Name, AcctSeedERP__Billing_City__c, AcctSeedERP__Billing_Country__c, 
                                                AcctSeedERP__Billing_PostalCode__c, AcctSeedERP__Billing_State__c, 
                                                Balance__c, Shipping_Account__c, Shipping_Name__c,Recordtype.name,
                                                AcctSeedERP__Billing_Street__c, AcctSeedERP__Customer__c,
                                                AcctSeedERP__Customer__r.AcctSeed__Billing_Contact__c, 
                                                AcctSeedERP__Customer__r.AcctSeed__Billing_Format__c,
                                                AcctSeedERP__Customer__r.AcctSeed__Billing_Days_Due__c, billing_name__c,
                                                AcctSeedERP__Opportunity__c, AcctSeedERP__Shipping_City__c, Contact__c,
                                                AcctSeedERP__Shipping_Country__c, AcctSeedERP__Shipping_PostalCode__c, 
                                                AcctSeedERP__Shipping_State__c, AcctSeedERP__Shipping_Street__c, AcctSeedERP__Ledger__c,
                                                Billing_Deposit__c, Billing_Terms_Name__c, 
                                                AcctSeedERP__Total__c
                                                FROM AcctSeedERP__Sales_Order__c
                                                WHERE Id=:wrapper.recordId limit 1];

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
                throw new SalesOrderDetailPageServiceException(exceptionMessage);
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
            billing.AcctSeedERP__Sales_Order__c = opp.Id; 
            billing.AcctSeed__Date__c = wrapper.billingDate;
            billing.AcctSeed__Due_Date2__c = wrapper.dueDate;
            billing.AcctSeed__Opportunity__c = Opp.AcctSeedERP__Opportunity__c;
            billing.AcctSeed__Customer__c = Opp.AcctSeedERP__Customer__c;
            billing.AcctSeed__Shipping_Contact__c = Opp.Contact__c;
            
            billing.AcctSeed__Shipping_City__c = Opp.AcctSeedERP__Shipping_City__c;
            billing.AcctSeed__Shipping_Country__c = Opp.AcctSeedERP__Shipping_Country__c;
            billing.AcctSeed__Shipping_PostalCode__c = Opp.AcctSeedERP__Shipping_PostalCode__c;
            billing.AcctSeed__Shipping_State__c = Opp.AcctSeedERP__Shipping_State__c;
            billing.AcctSeed__Shipping_Street__c = Opp.AcctSeedERP__Shipping_Street__c;
            billing.AcctSeed__Billing_Terms_Name__c = opp.Billing_Terms_Name__c;

            billing.AcctSeed__Billing_Contact__c = (Opp.Billing_Name__c != null) ? Opp.Billing_Name__c : Opp.AcctSeedERP__Customer__r.AcctSeed__Billing_Contact__c;
            billing.AcctSeed__Billing_Country__c = Opp.AcctSeedERP__Billing_Country__c;
            billing.AcctSeed__Billing_PostalCode__c = Opp.AcctSeedERP__Billing_PostalCode__c;
            billing.AcctSeed__Billing_State__c = Opp.AcctSeedERP__Billing_State__c;
            billing.AcctSeed__Billing_Street__c = Opp.AcctSeedERP__Billing_Street__c;
            billing.AcctSeed__Billing_City__c = Opp.AcctSeedERP__Billing_City__c;
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

            // List<OpportunityLineItem> opportunityLineItems = [SELECT Id, AcctSeed__GL_Account_Variable_1__c, Product2Id, UnitPrice, Item_Description__c, size__c FROM OpportunityLineItem WHERE Id IN:opportunityLinesItemsId];
            // Map<Id, OpportunityLineItem> opportunityLineItemsMap = new Map<Id, OpportunityLineItem>(opportunityLineItems);
            List<AcctSeedERP__Sales_Order_Line__c> opportunityLineItems = [SELECT Id, AcctSeedERP__GL_Account_Variable_1__c,AcctSeedERP__Unit_Price__c, AcctSeedERP__Product__c, Item_Description__c, Size__c FROM AcctSeedERP__Sales_Order_Line__c WHERE Id IN:opportunityLinesItemsId];
            Map<Id, AcctSeedERP__Sales_Order_Line__c> opportunityLineItemsMap = new Map<Id, AcctSeedERP__Sales_Order_Line__c>(opportunityLineItems);

            List<AcctSeed__Billing_Line__c> billingLineList = new List<AcctSeed__Billing_Line__c>();

            for(CreateBillingLinesWrapper lineWrapper: wrapper.lines){
                AcctSeed__Billing_Line__c line = new AcctSeed__Billing_Line__c();
                line.AcctSeed__Billing__c = billing.id;
                line.AcctSeed__Date__c = Date.today();
                line.AcctSeed__GL_Account_Variable_1__c = opportunityLineItemsMap.get(lineWrapper.lineId).AcctSeedERP__GL_Account_Variable_1__c;
                line.AcctSeed__Hours_Units__c = lineWrapper.quantity;
                // line.AcctSeed__Opportunity_Product_Id__c = lineWrapper.lineId;
                line.AcctSeedERP__Sales_Order_Line__c = lineWrapper.lineId;
                line.AcctSeed__Product__c = opportunityLineItemsMap.get(lineWrapper.lineId).AcctSeedERP__Product__c;
                line.AcctSeedERP__Sales_Order_Line__c = salesOrderLineRelatedToOpportunityLines.containsKey(lineWrapper.lineId) ? salesOrderLineRelatedToOpportunityLines.get(lineWrapper.lineId) : null;
                line.AcctSeed__Rate__c = opportunityLineItemsMap.get(lineWrapper.lineId).AcctSeedERP__Unit_Price__c;
                line.Item_Description__c = opportunityLineItemsMap.get(lineWrapper.lineId).Item_Description__c;
                line.size_custom__c = opportunityLineItemsMap.get(lineWrapper.lineId).size__c;

                billingLineList.add(line);
            }

            if(!billingLineList.isEmpty() && !Test.isRunningTest()){
                insert billingLineList;
            }

            return billing.Id;
        } catch (Exception e) {
            system.debug(e.getLineNumber());
            throw new SalesOrderDetailPageServiceException(e.getMessage());
        }
    }


    public class SObjectListWrapper{
        public List<SObject> sobjectList {get;set;}
        public Integer totalRecords {get;set;}

        public SObjectListWrapper(List<SObject> sobjectList, Integer totalRecords){
            this.sobjectList = sobjectList;
            this.totalRecords = totalRecords;
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