public class POGLVariableUpdateHandler {
    
    public static void changeIt(list<AcctSeedERP__Purchase_Order__c> oldData, list<AcctSeedERP__Purchase_Order__c> newData){
     
        set<id> poIds = new set<id>();
        map<id, id> POtoGlMap = new map<id,id>();
        Integer i = 0;
        for(AcctSeedERP__Purchase_Order__c po : newData){
            
            if(po.GL_Account_Variable_1__c != oldData[i].GL_Account_Variable_1__c){
                
                // the gl account variable has changed so get the ids
                poIds.add(po.id);
                POtoGlMap.put(po.id, po.GL_Account_Variable_1__c);
                
            }
            
            i++;
        }
        
        if(POtoGlMap.size() > 0){
            
            // get the lines for the po
            list<AcctSeedERP__Purchase_Order_Line__c> lines = [select id,AcctSeedERP__Purchase_Order__c,
                                                              AcctSeedErP__GL_Account_Variable_1__c
                                                              from AcctSeedERP__Purchase_Order_Line__c
                                                              where AcctSeedERP__Purchase_Order__c in:poIds
                                                              and Receive_Excluded_Formula__c = false];
            
            for(AcctSeedERP__Purchase_Order_Line__c line : lines){
                
                id gID = POtoGlMap.get(line.AcctSeedERP__Purchase_Order__c);
                
                if(gID == null) continue;
                
                line.AcctSeedERP__GL_Account_Variable_1__c = gID;
                
            }
            
            update lines;
        }
        
        
    }
}