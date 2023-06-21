/*****************************************************************************************************
*   @class        : ShipmentCreditOrderLineTriggerHandler
*   @description  : public class used as Trigger handler
*   @trigger      : ShipmentLineCreditOrderTrigger
*   @author       : Marian Lyzhychka ©Peeklogic
*****************************************************************************************************/
public with sharing class ShipmentCreditOrderLineTriggerHandler {

    public static void beforeInsertExtension(List<Shipment_Line_Credit_Order__c> lines){

        Set<Id> credit_order_lines = new Set<Id>();
        for(Shipment_Line_Credit_Order__c l:lines){
            credit_order_lines.add(l.Credit_Order_Line__c);
        }

        Map<Id, Credit_Order_Line__c> co_lines = new Map<Id, Credit_Order_Line__c>([SELECT Id, 
                                                                                    Product__c 
                                                                                    FROM Credit_Order_Line__c 
                                                                                    WHERE Id IN:credit_order_lines]);
        for(Shipment_Line_Credit_Order__c l:lines){
            if(co_lines.containsKey(l.Credit_Order_Line__c)){
                l.Product__c = co_lines.get(l.Credit_Order_Line__c).Product__c;
            }
        }                                                                             
    }

}