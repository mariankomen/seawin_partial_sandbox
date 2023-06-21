public class SalesOrderLineDescriptionHandler {
    
    public static void UpdateIt(List<AcctSeedERP__Sales_Order_Line__c> od, List<AcctSeedERP__Sales_Order_Line__c> nd){
        
        // check if the item description
        // populate a map with line id and description
        // get the billing line for the line id
        // compare the ids and update the description
        
        Integer i = 0;
        map<id, string> idAndDescription = new map<id, string>();
        for(AcctSeedERP__Sales_Order_Line__c sline : nd){
            
            // for item description
            if(sline.Item_description__c != od[i].item_description__c){
                idAndDescription.put(sline.id, sline.Item_description__c);
            } 
            i++;
        }

        if(idAndDescription.size() > 0 ){
            
            list<AcctSeed__Billing_Line__c> blines = [select item_Description__c, size__c,AcctSeedERP__Sales_Order_Line__c
                                                      from AcctSeed__Billing_Line__c
                                                     where AcctSeedERP__Sales_Order_Line__c in:idAndDescription.keyset()];
            
            if(!blines.IsEmpty()){
                
                list<AcctSeed__Billing_Line__c> Updatables = new list<AcctSeed__Billing_Line__c>();
                
                for(AcctSeed__Billing_Line__c bline : blines){
                
                    string description = idAndDescription.get(bline.AcctSeedERP__Sales_Order_Line__c);
                    
                    if(description == null) continue;
                    
                    bline.Item_Description__c = description;
                    
                    Updatables.add(bline);
            	}
                
                if(!Updatables.isEmpty()){
                    
                    update Updatables;
                }
            } 
        }
    }
}