public with sharing class CommissionTriggerHandler {
    
    public static void afterInsertHandler(List<Sales_Order_Commissions__c> trigger_new){
        Set<Id> soIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();

        for(Sales_Order_Commissions__c com: trigger_new){
            soIds.add(com.Sales_Order__c);
            oppIds.add(com.Opportunity__c);
        }
        List<AcctSeedERP__Sales_Order__c> sales_orders = [SELECT Id, 
                                                                Total_Commissions_Paid__c,
                                                                Commissions_Total_Custom__c,
                                                                Total_Commissions_Unpaid__c
                                                         FROM AcctSeedERP__Sales_Order__c
                                                         WHERE Id IN:soIds];
        List<Opportunity> opportunities = [SELECT Id, 
                                                                Total_Commissions_Paid__c,
                                                                Commissions_Total_Custom__c,
                                                                Total_Commissions_Unpaid__c
                                                         FROM Opportunity
                                                         WHERE Id IN:oppIds];

        List<Sales_Order_Commissions__c> all_commissions = [SELECT Id, 
                                                                    Commission_Paid__c, 
                                                                    Commission_Amount__c, 
                                                                    Commission_Unpaid__c,
                                                                    Sales_Order__c,
                                                                    Opportunity__c 
                                                            FROM Sales_Order_Commissions__c 
                                                            WHERE (Sales_Order__c IN:soIds OR Opportunity__c IN:oppIds)];

        Map<Id, Decimal> commission_paid = new Map<Id, Decimal>();
        Map<Id, Decimal> commission_total = new Map<Id, Decimal>();
        Map<Id, Decimal> commission_unpaid = new Map<Id, Decimal>();

        for(Sales_Order_Commissions__c comm: all_commissions){
            if(comm.Sales_Order__c != null){
                if(!commission_paid.containsKey(comm.Sales_Order__c)){
                    commission_paid.put(comm.Sales_Order__c, comm.Commission_Paid__c);
                }else{
                    Decimal total_paid = commission_paid.get(comm.Sales_Order__c) + comm.Commission_Paid__c;
                    commission_paid.put(comm.Sales_Order__c, total_paid);
                }
    
                if(!commission_total.containsKey(comm.Sales_Order__c)){
                    commission_total.put(comm.Sales_Order__c, comm.Commission_Amount__c);
                }else{
                    Decimal total_amount = commission_total.get(comm.Sales_Order__c) + comm.Commission_Amount__c;
                    commission_total.put(comm.Sales_Order__c, total_amount);
                }
    
                if(!commission_unpaid.containsKey(comm.Sales_Order__c)){
                    commission_unpaid.put(comm.Sales_Order__c, comm.Commission_Unpaid__c);
                }else{
                    Decimal total_unpaid = commission_unpaid.get(comm.Sales_Order__c) + comm.Commission_Unpaid__c;
                    commission_unpaid.put(comm.Sales_Order__c, total_unpaid);
                }
            }
            

            if(comm.Opportunity__c != null){
                if(!commission_paid.containsKey(comm.Opportunity__c)){
                    commission_paid.put(comm.Opportunity__c, comm.Commission_Paid__c);
                }else{
                    Decimal total_paid = commission_paid.get(comm.Opportunity__c) + comm.Commission_Paid__c;
                    commission_paid.put(comm.Opportunity__c, total_paid);
                }
    
                if(!commission_total.containsKey(comm.Opportunity__c)){
                    commission_total.put(comm.Opportunity__c, comm.Commission_Amount__c);
                }else{
                    Decimal total_amount = commission_total.get(comm.Opportunity__c) + comm.Commission_Amount__c;
                    commission_total.put(comm.Opportunity__c, total_amount);
                }
    
                if(!commission_unpaid.containsKey(comm.Opportunity__c)){
                    commission_unpaid.put(comm.Opportunity__c, comm.Commission_Unpaid__c);
                }else{
                    Decimal total_unpaid = commission_unpaid.get(comm.Opportunity__c) + comm.Commission_Unpaid__c;
                    commission_unpaid.put(comm.Opportunity__c, total_unpaid);
                }
            }
        }


        for(AcctSeedERP__Sales_Order__c so:sales_orders){
            so.Total_Commissions_Paid__c = commission_paid.containsKey(so.Id) ? commission_paid.get(so.Id) : 0.00;
            so.Commissions_Total_Custom__c = commission_total.containsKey(so.Id) ? commission_total.get(so.Id) : 0.00;
            so.Total_Commissions_Unpaid__c = commission_unpaid.containsKey(so.Id) ? commission_unpaid.get(so.Id) : 0.00;
        }
        for(Opportunity opp:opportunities){
            opp.Total_Commissions_Paid__c = commission_paid.containsKey(opp.Id) ? commission_paid.get(opp.Id) : 0.00;
            opp.Commissions_Total_Custom__c = commission_total.containsKey(opp.Id) ? commission_total.get(opp.Id) : 0.00;
            opp.Total_Commissions_Unpaid__c = commission_unpaid.containsKey(opp.Id) ? commission_unpaid.get(opp.Id) : 0.00;
            opp.Run_Validation_Rule__c = true;
        }

        if(!Test.isRunningTest()){
            update sales_orders;
            update opportunities;
        }
        
        //Paid - Commission_Paid__c
        //Total - Commission_Amount__c
        //Unpdaid - Commission_Unpaid__c
    }
}