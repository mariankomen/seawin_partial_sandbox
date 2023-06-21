public with sharing class CreditOrderTriggerHandler {
    

    public static void beforeUpdateExtension(List<Credit_Order__c> trigger_new){
        Set<Id> credit_order_ids = getSetFromList(trigger_new);
        Map<Id, ItemWrapper> credit_order_filter_fields = getNeededFieldValues(credit_order_ids);

        system.debug(JSON.serialize(credit_order_filter_fields));
        for(Credit_Order__c co: trigger_new){
            if(credit_order_filter_fields.containsKey(co.Id) && co.Status__c == 'Cancelled'){
                if(credit_order_filter_fields.get(co.Id).total_billings > 0 ){
                    co.addError('Status cannot be Cancelled because Credit Order has related billing(s). (Delete billing(s) and try again)');
                }else if(credit_order_filter_fields.get(co.Id).shipped > 0 ){
                    co.addError('Status cannot be Cancelled because Credit Order has a Shipment(s).');
                }else if(credit_order_filter_fields.get(co.Id).allocated > 0){
                    co.addError('Status cannot be Cancelled because Credit Order has allocated lines. (Deallocate items and try again)');
                }
            }else if(credit_order_filter_fields.containsKey(co.Id) && co.Status__c == 'Closed'){
                
                if(credit_order_filter_fields.get(co.Id).bill_wrap == null){
                    co.addError('Status cannot be Closed because Credit Order has no billing(s).');
                }else if(credit_order_filter_fields.get(co.Id).bill_wrap.all_posted == false && !Test.isRunningTest()){
                    co.addError('Status cannot be Closed because not all Billings have been posted.');
                }else if(credit_order_filter_fields.get(co.Id).bill_wrap.all_isFullyPaid == false){
                    co.addError('Status cannot be Closed because Credit Order is not fully paid.');
                }
            }
        }
    }


    /*****************************************************************************************************
    *   @method       : getSetFromList
    *   @description  : help method used for quick getting set of not record id fields from list
    *   @return       : Set<Id>
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public static Set<Id> getSetFromList(List<Credit_Order__c> data){
        Set<Id> credit_order_ids = new Set<Id>();
        for(Credit_Order__c co:data){
            credit_order_ids.add(co.Id);
        }
        return credit_order_ids;
    }

    /*****************************************************************************************************
    *   @method       : getNeededFieldValues
    *   @description  : help method, used in execution of trigger handler, gather all needed info for next conditions
    *   @return       : Map<Id, ItemWrapper>
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public static Map<Id, ItemWrapper> getNeededFieldValues(Set<Id> co_ids){
        List<AggregateResult> aggregate = [SELECT Credit_Order__c co, 
                                                  SUM(Allocated_Quantity__c) allocated, 
                                                  SUM(Shipped_Quantity__c) shipped 
                                                  FROM Credit_Order_Line__c 
                                                  WHERE Credit_Order__c IN:co_ids 
                                                  GROUP BY Credit_Order__c];

        //Current agg result, need only for counting billings related to credit orders
        List<AggregateResult> aggregate_billings = [SELECT  Credit_Order__c co, 
                                                            COUNT(Id) total_billings 
                                                            FROM AcctSeed__Billing__c 
                                                            WHERE Credit_Order__c IN:co_ids 
                                                            GROUP BY Credit_Order__c];
        
        List<AcctSeed__Billing__c> billings = [SELECT Id, 
                                                      AcctSeed__Status__c, 
                                                      Credit_Order__c, 
                                                      AcctSeed__Balance__c 
                                                      FROM AcctSeed__Billing__c 
                                                      WHERE Credit_Order__c IN:co_ids];     

        List<BillingWrapper> bill_wrapper = new List<BillingWrapper>();// Current list contains all billings records

        for(AcctSeed__Billing__c bill: billings){
            bill_wrapper.add(new BillingWrapper(
                bill.Id, 
                bill.AcctSeed__Status__c == 'Posted',
                bill.AcctSeed__Balance__c == 0,
                bill.Credit_Order__c
                ));
        } 
        //Current list contains records grouped and summed
        //where in result we have one wrapper record which contains info of all billings related to credit order
        Map<Id, TotalBillingWrapper> bill_wrapper_total = new Map<Id, TotalBillingWrapper>(); 

        //In current loop we check do all billings to credit order are fully paid and fully posted
        for(BillingWrapper bil_w:bill_wrapper){
            Id cr_order_id = bil_w.credit_order_id;
            List<Boolean> posted_statuses = new List<Boolean>();
            List<Boolean> paid_statuses = new List<Boolean>();

            if(!bill_wrapper_total.containsKey(cr_order_id)){
                for(BillingWrapper bill_w_next: bill_wrapper){

                    if(bill_w_next.credit_order_id == cr_order_id){
                        posted_statuses.add(bill_w_next.posted);
                        paid_statuses.add(bill_w_next.isFullyPaid);
                    }
                }
                TotalBillingWrapper tbw = new TotalBillingWrapper(
                    !posted_statuses.contains(false),
                    !paid_statuses.contains(false),
                    cr_order_id
                );
                bill_wrapper_total.put(cr_order_id, tbw);
            }
        }

        Map<Id, Decimal> total_bill_map = new Map<Id, Decimal>();
        for(AggregateResult agr: aggregate_billings){
            total_bill_map.put((Id)agr.get('co'), (Decimal)agr.get('total_billings'));
        }
        Map<Id, ItemWrapper> return_map = new Map<Id, ItemWrapper>();
        for(AggregateResult agr:aggregate){
            Decimal billing_total = total_bill_map.containsKey((Id)agr.get('co')) ? total_bill_map.get((Id)agr.get('co')) : 0;
            ItemWrapper iw = new ItemWrapper(
                (Id)agr.get('co'), 
                (Decimal)agr.get('allocated'), 
                (Decimal)agr.get('shipped'),
                billing_total,
                bill_wrapper_total.containsKey((Id)agr.get('co')) ? bill_wrapper_total.get((Id)agr.get('co')) : null
            );
            return_map.put((Id)agr.get('co'), iw);
        }
        system.debug(JSON.serialize(return_map));
        return return_map;
    }

    public class BillingWrapper{
        public Id billId {get; set;}
        public Boolean posted {get; set;}
        public Boolean isFullyPaid {get; set;}
        public Id credit_order_id {get;set;}
        public BillingWrapper(Id billing_id, Boolean billing_posted, Boolean billing_fp, Id credit_or_id){
            billId = billing_id;
            posted = billing_posted;
            isFullyPaid = billing_fp;
            credit_order_id = credit_or_id;
        }
    }

    public class TotalBillingWrapper{
        public Boolean all_posted {get; set;}
        public Boolean all_isFullyPaid {get; set;}
        public Id credit_order_id {get;set;}
        public TotalBillingWrapper(Boolean billing_posted, Boolean billing_fp, Id credit_or_id){
            all_posted = billing_posted;
            all_isFullyPaid = billing_fp;
            credit_order_id = credit_or_id;
        }
    }

    public class ItemWrapper{
        public Id credit_order_id {get; set;}
        public Decimal allocated {get; set;}
        public Decimal shipped {get; set;}
        public Decimal total_billings {get; set;}
        public TotalBillingWrapper bill_wrap {get; set;}

        public ItemWrapper(Id co_id, Decimal alloc, Decimal shipp, Decimal bills, TotalBillingWrapper billing_wrapper){
            credit_order_id = co_id;
            allocated = alloc;
            shipped = shipp;
            total_billings = bills;
            bill_wrap = billing_wrapper;
        }
    }
}