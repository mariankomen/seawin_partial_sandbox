public class AfterOLIUpdateBLIHandler {
    
    public static void updateBLI(LIST<OpportunityLineItem> oldData, LIST<OpportunityLineItem> newData){
        
        List<Id> oliIDs = new List<Id>();
        Integer i = 0;
        
        for(OpportunityLineItem oli : newData){
            if(oli.Size__c != oldData[i].Size__c || oli.Item_Description__c != oldData[i].Item_Description__c)
                oliIDs.add(oli.Id);
            i++;
        }
        
        List<AcctSeed__Billing_Line__c> bliList = [select id,AcctSeed__Opportunity_Product_Id__c,Size_Custom__c,Item_Description__c
                                                   from AcctSeed__Billing_Line__c
                                                   where AcctSeed__Opportunity_Product_Id__c in: oliIDs];
        System.debug('oldData: ' + oldData);
        System.debug('newData: ' + newData);
        System.debug('oliIDs: ' + oliIDs);
        System.debug('bliList1: ' + bliList);
       
        
        for(OpportunityLineItem oli : newData){
            for(AcctSeed__Billing_Line__c bli : bliList){
                if(bli.AcctSeed__Opportunity_Product_Id__c == oli.Id){
                    bli.Size_Custom__c = oli.Size__c;
                    bli.Item_Description__c = oli.Item_Description__c;
                }
            }   
        }
        System.debug('bliList2: ' + bliList);
        update bliList;
        
    }
}