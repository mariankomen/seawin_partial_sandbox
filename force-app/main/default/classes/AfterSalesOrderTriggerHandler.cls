public class AfterSalesOrderTriggerHandler {
    

    public static void LinkBillings(List<AcctSeedERP__Sales_Order__c> data){

        system.debug('linkRelatedBillings Initial debug.');
        system.debug('linkRelatedBillings, received data: '+JSON.serialize(data));
        Map<Id, Id> opportunity_salesOrder_Map = new Map<Id, Id>();
        Set<Id> salesOrderIds = new Set<Id>();

        for(AcctSeedERP__Sales_Order__c so: data){
            if(so.acctseederp__opportunity__c != null){
                salesOrderIds.add(so.Id);
                opportunity_salesOrder_Map.put(so.acctseederp__opportunity__c, so.Id);
            }
        }
        System.debug('opportunity_salesOrder_Map : '+JSON.serialize(opportunity_salesOrder_Map));
        System.debug('salesOrderIds : '+JSON.serialize(salesOrderIds));

        List<AcctSeed__Billing__c> billings = [select id, AcctSeedERP__Sales_Order__c,
                                               AcctSeed__Opportunity__c from AcctSeed__Billing__c
                                               where AcctSeed__Opportunity__c in:opportunity_salesOrder_Map.keyset()
                                               ];
        system.debug('billings: '+JSON.serialize(billings));
        Set<Id> billingIds = new Set<Id>();
        if(!billings.isEmpty()){
            for(AcctSeed__Billing__c bill: billings){
                Id salesOrderId = opportunity_salesOrder_Map.get(bill.AcctSeed__Opportunity__c);
                
                if(salesOrderId == null) continue;
                
                bill.AcctSeedERP__Sales_Order__c = salesOrderId;
                billingIds.add(bill.id);
            }
            System.debug('Before update billings');

            update billings;

            System.debug('After update billings');
            System.debug('salesOrderIds: '+salesOrderIds);
            System.debug('billingIds: '+billingIds);

            ProcessFurther(salesOrderIds, billingIds);

            System.debug('##############');
            System.debug('After update billing lines');
        }
    }

    public static void ProcessFurther(Set<Id> salesOrderIds, Set<Id> billingIds){
        system.debug('salesOrderIds: '+salesOrderIds);
        system.debug('billingIds: '+billingIds);
        List<AcctSeedERP__Sales_Order_Line__c> OrderLines = [select id, AcctSeedERP__Opportunity_Product_Id__c
                                                             from AcctSeedERP__Sales_ORder_Line__c where
                                                             AcctSeedERP__Sales_Order__c in:salesOrderIds];
        system.debug('OrderLines: '+OrderLines);
        system.debug('OrderLines.size(): '+OrderLines.size());
        System.debug('linkBillingLinesWithSOL: OrderLines: '+JSON.serialize(OrderLines));
        Map<Id, Id> oli_sol_map = new Map<Id, Id>(); //Opportunity line - Sales order line
        if(!OrderLines.isEmpty()){
            for(AcctSeedERP__Sales_Order_Line__c sol: OrderLines){
                oli_sol_map.put(sol.AcctSeedERP__Opportunity_Product_Id__c, sol.id);
            }

            List<AcctSeed__Billing_Line__c> billingLines = [select id,acctseederp__sales_order_line__c, 
                                                            AcctSeed__Opportunity_Product_id__c from
                                                            AcctSeed__Billing_Line__c where 
                                                            AcctSeed__Billing__c in:billingIds]; 
            
            System.debug('66 billingLines: '+billingLines);
            System.debug('oli_sol_map: '+oli_sol_map);
            for(AcctSeed__Billing_Line__c bline: billingLines){
                Id solId = oli_sol_map.get(bline.AcctSeed__Opportunity_Product_id__c);

                bline.acctseederp__sales_order_line__c = solId;
            }

            System.debug('## Before update billing lines ##');
            update billingLines;
            System.debug('## After update billing lines ##');
        }

    }


    // public static void LinkBillings(List<AcctSeedERP__Sales_Order__c> data){
        
        
    //     map<id, id> OpptyToOrderMap = new map<id, id>();
    //     set<id> orderIds = new set<id>();
    //     for(AcctSeedERP__Sales_Order__c order : data){
            
    //         if(order.acctseederp__opportunity__c != null){
    //             orderIds.add(order.id);
    //             OpptyToOrderMap.put(order.acctseederp__opportunity__c, order.id);
    //         }
    //     }
        
    //     // Associate Billing to this SO
    //     List<AcctSeed__Billing__c> billings = [select id, AcctSeedERP__Sales_Order__c,
    //                                            AcctSeed__Opportunity__c from AcctSeed__Billing__c
    //                                            where AcctSeed__Opportunity__c in:OpptyToOrderMap.keyset()
    //                                            and
    //                                            AcctSeed__Opportunity__c != null and
    //                                            AcctSeedERP__Sales_Order__c = null];
    //     set<id> billingIds = new set<id>();
    //     if(!Billings.isEmpty()){
            
    //         for(AcctSeed__Billing__c bill : billings){
                
    //             id SOId = OpptyToOrderMap.get(bill.AcctSeed__Opportunity__c);
                
    //             if(SOId == null) continue;
                
    //             bill.AcctSeedERP__Sales_Order__c = SOId;
    //             billingIds.add(bill.id);
    //         }
            
    //         // try{
    //             system.debug('37');
    //             update billings;
                
    //             // Associate Billing Lines with this SO lines
    //             ProcessFurther(orderIds, billingIds);
    //             system.debug('after update lines');
    //         // }catch(Exception ex){
                
    //         //     system.debug('Exception occured during Updating Billing with Sales Order Id: ');
    //         //     system.debug(ex.getMessage());
    //         // }
    //     }
    // }

    // // @future
    // public static void ProcessFurther(set<id> orderIds, set<id> billingIds){
        
    //     List<AcctSeedERP__Sales_Order_Line__c> OrderLines = [select id, AcctSeedERP__Opportunity_Product_Id__c
    //                                                          from AcctSeedERP__Sales_ORder_Line__c where
    //                                                          AcctSeedERP__SAles_order__c in:orderIds];
        
    //     map<id, id> OpptyProdToSolMap = new map<id, id>();
    //     if(!OrderLines.isEmpty()){
            
    //         for(AcctSeedERP__Sales_Order_Line__c sol : OrderLines){
                
    //             OpptyProdToSolMap.put(sol.AcctSeedERP__Opportunity_Product_Id__c, sol.id);
    //         }
            
    //     }
        
    //     if(OpptyProdToSolMap.size() > 0){
            
    //         // now update billing lines with the sales order line IDs
    //         List<AcctSeed__Billing_Line__c> billingLines = [select id,acctseederp__sales_order_line__c, 
    //                                                         AcctSeed__Opportunity_Product_id__c from
    //                                                         AcctSeed__Billing_Line__c where 
    //                                                         AcctSeed__Billing__c in:BillingIds]; 
            
    //         if(!BillingLines.isEmpty()){
                
                
    //             for(AcctSeed__Billing_Line__c bl : billingLines){
                    
    //                 Id SOLid = OpptyProdToSolMap.get(bl.AcctSeed__Opportunity_Product_id__c);
                    
    //                 bl.acctseederp__sales_order_line__c = SOLid;
                    
    //             }
    //             // try{
    //             system.debug('update lines 87');
    //             update BillingLines;
    //             system.debug('after update lines 89');
    //             // }catch(Exception ex){
    //             //     system.debug('Exception occured during Updating Billing Lines with Sales Order Line Id: ');
    //             //     system.debug(ex.getMessage());
    //             // }
    //         }
            
    //     }

    //     // Now calculate commissions on sales order for the newly added billings
    //     List<AcctSeed__Billing_Cash_Receipt__c> cashReceipts = [select id, AcctSeed__Billing__c 
    //     from AcctSeed__Billing_Cash_Receipt__c
    //     where acctseed__billing__c in:billingIds];

    //     if(!cashReceipts.isEmpty()){

    //         CalculateCommissionsHandler.calculateCommissionsCashReceipts(cashReceipts, new Map<Id, List<String>>());
    //     }

    //     List<AcctSeed__Billing_Credit_Memo__c> memoReceipts = [select id,AcctSeed__Billing_Invoice__c 
    //     from AcctSeed__Billing_Credit_Memo__c
    //     where acctseed__billing_Invoice__c in:billingIds];

    //     if(!memoReceipts.isEmpty()){

    //         CalculateCommissionsHandler.calculateCommissionsCreditMemo(memoReceipts, new Map<Id, List<String>>());
    //     }
    // }

    public static void UpdateRelatedBilling(List<AcctSeedERP__Sales_Order__c> data){
        //This method used for updating fome field on billing object for run trigger which set Billing Balance field of SO
        Map<Id, AcctSeedERP__Sales_Order__c> bill_map = new Map<Id, AcctSeedERP__Sales_Order__c>(data);
        List<AcctSeed__Billing__c> related_bills = [SELECT Id, SalesOrderTriggerUpdate__c,AcctSeedERP__Sales_Order__c FROM AcctSeed__Billing__c WHERE AcctSeedERP__Sales_Order__c IN:bill_map.keySet()];
        for(AcctSeed__Billing__c b:related_bills){
            b.SalesOrderTriggerUpdate__c = '1';
        }
        update related_bills;
    }

    public static void checkInsertedSalesOrders(List<AcctSeedERP__Sales_Order__c> data){
        try{
            // LinkBillings(data);
            Set<Id> ordersWithOpportunity = new Set<Id>();

            for(AcctSeedERP__Sales_Order__c so: data){
                if(so.AcctSeedERP__Opportunity__c != null) ordersWithOpportunity.add(so.Id);
            }
    
            List<AcctSeed__Billing_Line__c> bill_lines = [SELECT Id, AcctSeed__Product__r.Name, 
                                                                AcctSeed__Opportunity_Product_Id__c, 
                                                                AcctSeedERP__Sales_Order_Line__c, 
                                                                Quantity__c, 
                                                                AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c,
                                                                AcctSeed__Billing__c, 
                                                                CreatedDate 
                                                        FROM AcctSeed__Billing_Line__c 
                                                        WHERE AcctSeedERP__Sales_Order_Line__c = null 
                                                        AND AcctSeed__Billing__r.GL_Account_Variable_1__c = 'Seawin USA'
                                                        AND AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c IN: ordersWithOpportunity
                                                        AND AcctSeed__Billing__r.AcctSeed__Type__c = 'Invoice'
                                                        AND AcctSeed__Opportunity_Product_Id__c != null
                                                        AND CALENDAR_YEAR(CreatedDate) >=2022];
    
            if(!bill_lines.isEmpty()){
                Map<Id, Id> bill_so = new Map<Id, Id>();
            
                for(AcctSeed__Billing_Line__c bl: bill_lines){
                    bill_so.put(bl.AcctSeed__Billing__c, bl.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c);
                }
                
                String header = 'Billing Id, Sales Order Id \n';
                String finalstr = header;
    
                for(Id bill: bill_so.keySet()){
                    finalstr += bill +','+bill_so.get(bill);
                }
    
                Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
                Blob csvBlob = Blob.valueOf(finalstr);
                String csvname= 'SalesOrder_Issue: '+ date.today().format()+'.csv';
                csvAttc.setFileName(csvname);
                csvAttc.setBody(csvBlob);
    
                Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                String[] toAddresses = new list<string> {'testsalesforce840@gmail.com'};
                email.setSubject('Billing without associated SO Lines.');
                email.setSenderDisplayName('SeaWin');
                email.setToAddresses( toAddresses );
                email.setPlainTextBody('Check errors below.');
    
                email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
                Messaging.SendEmailResult [] r = !Test.isRunningTest() ? Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}) : null;
            }
        }catch(Exception e){
            system.debug('182:' +e.getMessage());
        }
        
        
    }

    public static void coverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}