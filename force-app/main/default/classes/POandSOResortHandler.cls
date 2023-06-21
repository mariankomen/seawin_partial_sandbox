public class POandSOResortHandler {
    
    public static void reSort(list<AcctSeedERP__Sales_Order_Line__c> slist, list<AcctSeedERP__Purchase_Order_Line__c> plist){
        
        if(!slist.IsEmpty()){
            
            set<id> soIds = new set<id>();
            
            for(AcctSeedERP__Sales_Order_Line__c sol : slist){
                
                soIds.add(sol.AcctSeedERP__Sales_Order__c);
                
            }
            
            if(!soIds.isEmpty()){
                
                // get all the associated lines and sort them by their appearance in the list
                list<AcctSeedERP__Sales_Order_Line__c> lines = [SELECT Id, SortOrder__c 
                 FROM AcctSeedERP__Sales_Order_Line__c 
                 where AcctSeedERP__Sales_Order__c =:soIds
                 order by sortorder__c,name,createddate asc];
                
                if(!lines.isEmpty()){
                    
                    Integer newsortnumber = 1;
                    
                    for(AcctSeedERP__Sales_Order_Line__c sl : lines){
                        
                        sl.sortorder__c = newsortnumber;
                        
                        newsortnumber++;
                        
                    }
                    
                    update lines;
                    
                }
            }
            
            
        }else if(!plist.IsEmpty()){
            
            set<id> poIds = new set<id>();
            
            for(AcctSeedERP__Purchase_Order_Line__c pol : plist){
                
                poIds.add(pol.AcctSeedERP__Purchase_Order__c);
                
            }
            
            if(!poIds.isEmpty()){
                
                // get all the associated lines and sort them by their appearance in the list
                list<AcctSeedERP__Purchase_Order_Line__c> lines = [SELECT Id, Sort_Order__c 
                 FROM AcctSeedERP__Purchase_Order_Line__c 
                 where AcctSeedERP__Purchase_Order__c =:poIds
                 order by sort_order__c,name,createddate asc];
                
                if(!lines.isEmpty()){
                    
                    Integer newsortnumber = 1;
                    
                    for(AcctSeedERP__Purchase_Order_Line__c pl : lines){
                        
                        pl.sort_order__c = newsortnumber;
                        
                        newsortnumber++;
                        
                    }
                    
                    update lines;
                    
                }
            }
        }
    }
}