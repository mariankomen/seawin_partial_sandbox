trigger ProductTrigger on Product2 (after insert, before insert) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            
            ProductHandler.process(Trigger.new);
        }
        
    }

    //перепиши це норм
    // if(Trigger.isBefore && Trigger.isInsert){
    //     Id glVarId = Trigger.new[0].AcctSeed__GL_Account_Variable_1__c;
    //     String productSKU = Trigger.new[0].Product_SKU__c;

    //     List<Product2> products = [SELECT Id FROM Product2 WHERE AcctSeed__GL_Account_Variable_1__c=:glVarId AND Product_SKU__c =: productSKU];
    //     if(products.size() > 0){
    //         Trigger.new[0].addError('Duplicated Product SKU');
    //     }
    // }
}