public class ClonePOHandler {
    
    public static void CreateLines(map<id, id> data){

        list<AcctSeedERP__Purchase_Order_Line__c> lines = [SELECT Id, AcctSeedERP__Purchase_Order__c, 
                                                           AcctSeedERP__GL_Account_Variable_1__c, 
                                                           AcctSeedERP__GL_Account_Variable_2__c, 
                                                           AcctSeedERP__GL_Account_Variable_3__c, 
                                                           AcctSeedERP__GL_Account_Variable_4__c, 
                                                           AcctSeedERP__Comment__c, 
                                                           AcctSeedERP__Product__c, 
                                                           AcctSeedERP__Project_Task__c, 
                                                           AcctSeedERP__Project__c, 
                                                           AcctSeedERP__Quantity_Unreceived__c, 
                                                           AcctSeedERP__Quantity__c, AcctSeedERP__Total__c, 
                                                           AcctSeedERP__Unit_Price__c, 
                                                           AcctSeedERP__Quantity_Received__c, 
                                                           Description__c, Sort_Order__c, 
                                                           Size__c, Sales_Order_Line__c,sales_order_Line__r.IsMaximum__c,
                                                           Sales_Order_Line__r.Quantity_Needed_Formula__c,
                                                           Sales_Order_Line__r.POL_Quantity__c
                                                           FROM AcctSeedERP__Purchase_Order_Line__c
                                                          where AcctSeedERP__Purchase_Order__c in:data.keySet()
                                                          order by Sort_Order__c,name,createddate asc];
        
        if(!lines.IsEmpty()){
            
            list<AcctSeedERP__Purchase_Order_Line__c> newLines = new list<AcctSeedERP__Purchase_Order_Line__c>();
            
            Integer sortorderNumber = 1;
            for(AcctSeedERP__Purchase_Order_Line__c pol : lines){
                
                Id CloneId = data.get(pol.AcctSeedERP__Purchase_Order__c);
                
                AcctSeedERP__Purchase_Order_Line__c newPol = new AcctSeedERP__Purchase_Order_Line__c();
				
                if(pol.Sales_Order_Line__c == null){
                    
                    newPol.AcctSeedERP__Quantity__c = pol.AcctSeedERP__Quantity__c;
                    newPol.Sales_Order_Line__c = null; 
                    
                }else{
                    if(pol.sales_order_Line__r.IsMaximum__c != 1){
                        
                        Decimal POLQuantity = (pol.Sales_Order_Line__r.POL_Quantity__c == 0 || 
                                       pol.Sales_Order_Line__r.POL_Quantity__c == null) ? 
                            pol.Sales_Order_Line__r.Quantity_Needed_Formula__c : 
                        pol.Sales_Order_Line__r.Quantity_Needed_Formula__c - pol.Sales_Order_Line__r.POL_Quantity__c;
                
                    	newPol.AcctSeedERP__Quantity__c = POLQuantity;
                    	newPol.Sales_Order_Line__c = pol.Sales_Order_Line__c; 
                    }else{
                        continue;
                    }
                }
                
               	newPol.AcctSeedERP__Purchase_Order__c = CloneId;
                newPol.AcctSeedERP__GL_Account_Variable_1__c = pol.AcctSeedERP__GL_Account_Variable_1__c; 
                newPol.AcctSeedERP__GL_Account_Variable_2__c = pol.AcctSeedERP__GL_Account_Variable_2__c; 
                newPol.AcctSeedERP__GL_Account_Variable_3__c = pol.AcctSeedERP__GL_Account_Variable_3__c; 
                newPol.AcctSeedERP__GL_Account_Variable_4__c = pol.AcctSeedERP__GL_Account_Variable_4__c; 
                newPol.AcctSeedERP__Comment__c = pol.AcctSeedERP__Comment__c; 
                newPol.AcctSeedERP__Product__c = pol.AcctSeedERP__Product__c;
                newPol.AcctSeedERP__Project_Task__c = pol.AcctSeedERP__Project_Task__c;
                newPol.AcctSeedERP__Project__c = pol.AcctSeedERP__Project__c; 
                // newPol.AcctSeedERP__Quantity_Unreceived__c = pol.AcctSeedERP__Quantity_Unreceived__c; 
                newPol.AcctSeedERP__Unit_Price__c = pol.AcctSeedERP__Unit_Price__c; 
                // newPol.AcctSeedERP__Quantity_Received__c = pol.AcctSeedERP__Quantity_Received__c; 
                newPol.Description__c = pol.Description__c; 
                // newPol.Sort_Order__c = pol.Sort_Order__c; 
                newPol.Sort_Order__c = sortorderNumber; 
                newPol.Size__c = pol.Size__c; 
                
                newLines.add(newPol);
                
                sortorderNumber++;
            }
            
            if(!newLines.IsEmpty()){
                
                try{
                    
                	insert newLines;
                    
                }catch(Exception ex){
                    
                    system.debug(ex.getMessage());
                    
                }
            }
        }
    }
}