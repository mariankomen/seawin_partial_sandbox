public class GlVariablePopulateOnPayCashHandler {
    
    public static void populateGLVariable1(List<AcctSeed__AP_Disbursement__c> data){
        
        Map<id, id> PayableAndCashDisb_Map = new Map<id, id>();
        Map<id, String> CashDisbAndGlVar_Map = new Map<id, String>();

        for(AcctSeed__AP_Disbursement__c cash: data){
            PayableAndCashDisb_Map.put(cash.AcctSeed__Account_Payable__c, 
            cash.AcctSeed__Cash_Disbursement__c); 
        }

        List<AcctSeed__Account_Payable__c> payableList = new List<AcctSeed__Account_Payable__c>();

        if(PayableAndCashDisb_Map.size() > 0){

            payableList = [select id, name,
            Sales_Order__c, 
            Sales_Order__r.GL_Account_Variable_1__r.Id,
            AcctSeedERP__Purchase_Order__c,
            AcctSeedERP__Purchase_Order__r.GL_Account_Variable_1__r.Id,
            AcctSeed__Vendor__c,
            AcctSeed__Vendor__r.AcctSeed__GL_Account_Variable_1__r.Id,
            AcctSeed__Contact__c,
            AcctSeed__Contact__r.GL_Account_Variable_1__r.Id,
            AcctSeed__Employee__c,
            AcctSeed__Employee__r.Default_GL_Account_Variable__c                                                           
            from AcctSeed__Account_Payable__c
            where id in: PayableAndCashDisb_Map.keyset()];

        }
        
        if(!payableList.isEmpty()){


           list<AcctSeed__Accounting_Variable__c> GLvariables = [select id,name from AcctSeed__Accounting_Variable__c];

           map<string, id> GLVariablesMap = new map<string, id>();

           if(!GLvariables.isEmpty()){

                for(AcctSeed__Accounting_Variable__c glvariable : GLvariables){

                    GLVariablesMap.put(glvariable.name, glvariable.id);
                }
           }
        
            for(AcctSeed__Account_Payable__c pay : payableList){

                    Id CashDisbId = PayableAndCashDisb_Map.get(pay.id);

                    if(pay.AcctSeedERP__Purchase_Order__c != null){

                        CashDisbAndGlVar_Map.put(CashDisbId, 
                        pay.AcctSeedERP__Purchase_Order__r.GL_Account_Variable_1__r.Id);

                    }else if(pay.Sales_Order__c != null){

                        CashDisbAndGlVar_Map.put(CashDisbId, 
                        pay.Sales_Order__r.GL_Account_Variable_1__r.Id);

                    }else if(pay.AcctSeed__Vendor__c != null){

                        CashDisbAndGlVar_Map.put(CashDisbId, 
                        pay.AcctSeed__Vendor__r.AcctSeed__GL_Account_Variable_1__r.Id);

                    }else if(pay.AcctSeed__Contact__C != null){

                        CashDisbAndGlVar_Map.put(CashDisbId, 
                        pay.AcctSeed__Contact__r.GL_Account_Variable_1__r.Id);

                    }else if (pay.AcctSeed__Employee__c != null){

                        List<String> PickListValues = new List<String>();
                        system.debug(pay.AcctSeed__Employee__r.Default_GL_Account_Variable__c);
                        PickListValues.addAll(pay.AcctSeed__Employee__r.Default_GL_Account_Variable__c.Split(';'));
                        CashDisbAndGlVar_Map.put(CashDisbId, GLVariablesMap.get(PickListValues[0]));
                    }
            }
        } 

        List<AcctSeed__Cash_Disbursement__c> cashList = new List<AcctSeed__Cash_Disbursement__c>();
        
        if(CashDisbAndGlVar_Map.size() > 0){

            cashList = [select id, AcctSeed__GL_Account_Variable_1__c
                                                         from AcctSeed__Cash_Disbursement__c
                                                         where id in: CashDisbAndGlVar_Map.keyset()];

        }

        if(!cashList.isEmpty()){

            for(AcctSeed__Cash_Disbursement__c item : cashList){
                item.AcctSeed__GL_Account_Variable_1__c = CashDisbAndGlVar_Map.get(item.id);
            }
            
            update cashList;
        } 

    }
}