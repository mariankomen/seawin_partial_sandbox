public with sharing class PayableTriggerHelper implements ITriggerHelper{
    public static void beforeInsert(List<sObject> newList) {
         
    }
     
    public static void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        rollupRelatedPurchaseOrders((List<AcctSeed__Account_Payable__c>)newList);
        rollupBillingReceivedAmount(newList);

    }
     
    public static void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {

    }
     
    public static void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
        rollupRelatedPurchaseOrders((List<AcctSeed__Account_Payable__c>)newList);
        rollupBillingReceivedAmount(newList);

    }
     
    public static void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
     
    public static void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        rollupBillingReceivedAmount(oldList);
    }
     
    public static void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
        rollupBillingReceivedAmount(newList);
    }

    /*********************************************************************************************
    *    @method     : rollupRelatedPurchaseOrders                                                   
    *    @params     : List<AcctSeed__Account_Payable__c> data                
    *    @return     : void                                                                            
    *    Description : method updates paid and applie amount of related purchase orders
    *    @author     : Marian Lyzhychka
    *    @Total SOQL : 1
    *    @Total DML  : 1
    ************************************************************************************************/
    public static void rollupBillingReceivedAmount(List<sObject> triggerData){
        List<AcctSeed__Account_Payable__c> payments = (List<AcctSeed__Account_Payable__c>)triggerData;
        Set<Id> billingIds = new Set<Id>();

        for(AcctSeed__Account_Payable__c payment: payments){
            if(payment.Billing__c != null){
                billingIds.add(payment.Billing__c);
            }
        }
        if(billingIds.isEmpty()) return;

        List<AcctSeed__Billing__c> billingsNeedToUpdate = [SELECT Id, Paid_Amount__c FROM AcctSeed__Billing__c WHERE Id IN: billingIds];
        List<AcctSeed__Account_Payable__c> relatedBillingPayables = [SELECT Id, Billing__c, AcctSeed__Total__c FROM AcctSeed__Account_Payable__c WHERE Billing__c IN: billingsNeedToUpdate];
        Map<Id, Decimal> billingWithPaidAmount = new Map<Id, Decimal>();

        for(AcctSeed__Account_Payable__c payable: relatedBillingPayables){
            if(!billingWithPaidAmount.containsKey(payable.Billing__c)){
                billingWithPaidAmount.put(payable.Billing__c, payable.AcctSeed__Total__c);
            }else{
                billingWithPaidAmount.put(payable.Billing__c, billingWithPaidAmount.get(payable.Billing__c) + payable.AcctSeed__Total__c);
            }
        }

        for(AcctSeed__Billing__c bill: billingsNeedToUpdate){
            bill.Paid_Amount__c = billingWithPaidAmount.containsKey(bill.Id) ? billingWithPaidAmount.get(bill.Id) : 0.00;
        }

        update billingsNeedToUpdate;
    }
    /*********************************************************************************************
    *    @method     : rollupRelatedPurchaseOrders                                                   
    *    @params     : List<AcctSeed__Account_Payable__c> data                
    *    @return     : void                                                                            
    *    Description : method updates paid and applie amount of related purchase orders
    *    @author     : Marian Lyzhychka
    *    @Total SOQL : 1
    *    @Total DML  : 1
    ************************************************************************************************/
    public static void rollupRelatedPurchaseOrders(List<AcctSeed__Account_Payable__c> data){

        
        set<id> poIds = new set<id>();
        for(AcctSeed__Account_Payable__c ap : data){
            
            poIds.add(ap.AcctSeedERP__Purchase_Order__c);
            
        }
        
        if(!poIds.IsEmpty()){
            
            // get the aggregate SUM of the received payment on all bills if any
            
            List<AcctSeed__Account_Payable__c> AllPayables = [select id, AcctSeed__Paid_Amount__c, AcctSeed__Total__c,
                                                              AcctSeed__Credit_Memo_Applied_Amount__c,
                                                              AcctSeed__Type__c,
                                                  AcctSeed__Balance__c,AcctseedERP__Purchase_Order__c
                                                  from AcctSeed__Account_Payable__c
                                                  where AcctseedERP__Purchase_Order__c in:poIds
                                                             and AcctSeed__Type__c = 'Invoice'];
            
            if(!AllPayables.IsEmpty()){
                
                
                map<id, decimal> PO_Paid_Amount_Map = new map<id, decimal>();
                map<id, decimal> PO_Applied_Amount_Map = new map<id, decimal>();
                
                for(AcctSeed__Account_Payable__c p : AllPayables){
                    
                    Id key = p.AcctseedERP__Purchase_Order__c;
                    
                    Decimal PaidAmount_Total = p.AcctSeed__Balance__c == 0 && p.AcctSeed__Paid_Amount__c == 0 ?
                            0:p.AcctSeed__Balance__c == 0 && p.AcctSeed__Paid_Amount__c > p.AcctSeed__Total__c 
                                ? p.AcctSeed__Total__c : p.AcctSeed__Paid_Amount__c;
                    
                    if(PO_Paid_Amount_Map.containsKey(key) || PO_Applied_Amount_Map.containsKey(key)){
                        
                        // add paid amount to map
                        decimal existingAmount = PO_Paid_Amount_Map.get(key); 
                        Decimal NewAmount = existingAmount + PaidAmount_Total;
                        PO_Paid_Amount_Map.put(key, NewAmount);
                        
                        // add credit amount to map
                        Decimal existingAAmount = PO_Applied_Amount_Map.get(key);
                        Decimal NewAAmount = existingAAmount + p.AcctSeed__Credit_Memo_Applied_Amount__c;    
                        PO_Applied_Amount_Map.put(key, NewAAmount);
                    }else{

                        PO_Paid_Amount_Map.put(key, PaidAmount_Total);
                        PO_Applied_Amount_Map.put(key, p.AcctSeed__Credit_Memo_Applied_Amount__c);
                    }
                }
                
                if(PO_Paid_Amount_Map.size() > 0){ // only checking paid amount map because credit memo can only be
                    // applied to a paid payable.
                    
                    // get the sales orders to update
                    list<AcctSeedERP__Purchase_Order__c> pos = [select id, paid_amount__c,Applied_Amount__c
                                                               from AcctSeedERP__Purchase_Order__c
                                                           where id in:PO_Paid_Amount_Map.keyset()];
                    
                    for(AcctSeedERP__Purchase_Order__c po : pos){

                        po.paid_amount__c = PO_Paid_Amount_Map.get(po.id); 
                        po.Applied_Amount__c = PO_Applied_Amount_Map.get(po.id);
                        
                    }
                    
                    update pos;
                    
                }
            }
        }
    }
}