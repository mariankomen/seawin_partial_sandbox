public class BillingCreditCardFeeExtension {
    
    public List<AcctSeed__Billing_Line__c> lines {get; set;}
    public List<Wrapper> wrap {get; set;}
    public acctseed__billing__c billing {get; set;}
    public string avId {get; set;}
    public integer sortorder {get; set;}
    public boolean IsAllowed {get; set;}
    public Boolean hasCreditCardFee {get; set;}
    public AcctSeed__Billing_Line__c existing_credit_card_fee {get; set;}

    public BillingCreditCardFeeExtension(ApexPages.StandardController std){

        IsAllowed = true;
		
        string billingId = std.getId();
        billing = new acctseed__billing__c();
        
        billing = [select id, name, gl_account_variable_1__c, AcctSeed__Status__c 
                    from acctseed__billing__c where 
                    id =:billingId Limit 1];

        //We need to check does billing aready has credit card fees. If do, then we need updated existing record
        List<AcctSeed__Billing_Line__c> card_fee_lines = [SELECT Id, 
                                                    Credit_Card_Fee__c,
                                                    Quantity__c,
                                                    Name, 
                                                    AcctSeed__Billing__c,
                                                    AcctSeed__Product__c,
                                                    AcctSeed__Product__r.Name,
                                                    AcctSeed__Product__r.productcode,
                                                    Item_Description__c,
                                                    AcctSeed__Rate__c
                                                    FROM AcctSeed__Billing_Line__c
                                                    WHERE AcctSeed__Billing__c=:billingId
                                                    AND Credit_Card_Fee__c=true];

        hasCreditCardFee = card_fee_lines.size() > 0 ? true : false;



        if(billing.AcctSeed__Status__c == 'Posted') isAllowed = false;

        // get a default credit card fees product

        List<Product2> CreditCardFeesProduct = [Select id, productcode, description, AcctSeed__Unit_Cost__c
                                                from product2
                                                where name like 'Credit Card Fee%' 
                                                and Credit_Card_Fee__c = true Limit 1];

        wrap = new List<Wrapper>{new Wrapper(new AcctSeed__Billing_Line__c(), null)};

        if(!CreditCardFeesProduct.isEmpty()){

            if(!hasCreditCardFee){
                Product2 product = CreditCardFeesProduct[0];
            
                for(wrapper w : wrap){
                    
                    w.line.product_info__c = product.id;
                    w.ProductCode = product.productcode;
                    w.line.Item_Description__c = product.Description;
                    w.line.AcctSeed__Rate__c = product.AcctSeed__Unit_Cost__c;
                }
            } else{
                //If already has credit card fees line
                AcctSeed__Billing_Line__c card_fee_line = card_fee_lines[0];
                existing_credit_card_fee = card_fee_lines[0];
                for(wrapper w : wrap){
                    
                    w.line.product_info__c = card_fee_line.AcctSeed__Product__c;
                    w.ProductCode = card_fee_line.AcctSeed__Product__r.productcode;
                    w.line.Item_Description__c = card_fee_line.Item_Description__c;
                    w.line.AcctSeed__Rate__c = card_fee_line.AcctSeed__Rate__c;
                }
            }
            

        }


        

        avId = [select id from AcctSeed__Accounting_Variable__c where name =:billing.gl_account_variable_1__c Limit 1][0].Id; 
    }
    
    public PageReference OnProductSelect(){
        
        String ProductId = ApexPages.currentPage().getParameters().get('productId');
        
        List<Product2> record = [select Id, ProductCode, Description, acctseed__unit_cost__c 
                            from product2 where
                            id =:productId Limit 1];
        if(!record.IsEmpty()){

            Product2 product = record[0];
            
            for(wrapper w : wrap){
                
                w.ProductCode = product.productcode;
                w.line.Item_Description__c = product.Description;
                w.line.AcctSeed__Rate__c = product.AcctSeed__Unit_Cost__c;
            }
        }
        
        return null;
    }
    
    public PageReference saveBillingLine(){
        
        if(!hasCreditCardFee){
            AcctSeed__Billing_Line__c billingLine = new AcctSeed__Billing_Line__c();
        
            for(Wrapper w : wrap){
                
                billingLine.AcctSeed__Billing__c = billing.Id;
                billingLine.AcctSeed__Date__c = Date.today();
                billingLine.AcctSeed__Product__c = w.line.product_info__c;
                billingLine.AcctSeed__GL_Account_Variable_1__c = avId;
                billingLine.Item_Description__c = w.line.Item_Description__c;
                billingLine.AcctSeed__Hours_Units__c = w.line.AcctSeed__Hours_Units__c;
                billingLine.AcctSeed__Rate__c = w.line.AcctSeed__Rate__c;
                
            }
            
            try{
                
                insert billingLine;
            }catch(Exception ex){
                
                system.debug(ex.getMessage());
            }
        }else {
            
            for(Wrapper w : wrap){
                
                existing_credit_card_fee.AcctSeed__Billing__c = billing.Id;
                existing_credit_card_fee.AcctSeed__Date__c = Date.today();
                existing_credit_card_fee.AcctSeed__Product__c = w.line.product_info__c;
                existing_credit_card_fee.AcctSeed__GL_Account_Variable_1__c = avId;
                existing_credit_card_fee.Item_Description__c = w.line.Item_Description__c;
                existing_credit_card_fee.AcctSeed__Hours_Units__c = w.line.AcctSeed__Hours_Units__c;
                existing_credit_card_fee.AcctSeed__Rate__c = w.line.AcctSeed__Rate__c;
                
            }
            try{
                
                update existing_credit_card_fee;
            }catch(Exception ex){
                
                system.debug(ex.getMessage());
            }
        }
        
        
        PageReference page = new PageReference('/' + billing.Id);
        page.setRedirect(true);
        
        return page;
    }
    
    public class Wrapper {
        public AcctSeed__Billing_Line__c line {get; set;}
        public string productcode {get; set;}
        
        public Wrapper(AcctSeed__Billing_Line__c l, string p){
            
            line = l;
            productcode = p;

        }
    }
}