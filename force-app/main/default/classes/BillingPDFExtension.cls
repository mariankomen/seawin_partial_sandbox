public class BillingPDFExtension {
    
    public string headerUrl {get; set;}
    public string footerUrl {get; set;}
    public string terms {get; set;}
    public Id billingId {get; set;}
    public List<AcctSeed__Billing_Line__c> billingLines {get; set;}
    public boolean firstbilling {get; set;}
    public decimal deposit {get; set;}
    
    /* Correct data */
    public Decimal correct_balance {get; set;}
    public Decimal correct_remaining_balance {get; set;}


    public AcctSeed__Billing__c bill {get; set;}
    public map<id, OpportunityLineItem> TotalMap {get; set;}
    
    public List<AcctSeed__Billing_Cash_Receipt__c> receipts{get;set;}
    public List<AcctSeed__Billing_Cash_Receipt__c> payments {get; set;}
    
    public BillingPDFExtension(ApexPages.StandardController std){

        billingId = apexpages.currentpage().getparameters().get('id') != null ? apexpages.currentpage().getparameters().get('id') : (Id)std.getId();
        
        terms = 'Not Applicable';
        
        firstbilling = false;
        deposit = 0.00;
        //billingId = (Id)std.getId();
        bill = new AcctSeed__Billing__c();
        TotalMap = new map<id, opportunityLineitem>();

        Map<Id, List<Id>> kit_relation = SalesOrderPDFController.getKitsRelation();

        bill = [select AcctSeedERP__Sales_Order__c,Acctseed__Opportunity__c, AcctSeed__Customer__c, Sub_Total__c,Total_Amount_Due__c,
                AcctSeed__Opportunity__r.Amount,
                AcctSeedERP__Sales_Order__r.AcctSeedERP__Total__c,
                AcctSeed__Discount_Amount__c,AcctSeed__Cash_Application_Adjustment_Amount__c,AcctSeed__Sales_Tax2__c,
                AcctSeedERP__Sales_Order__r.Paid_amount__c, GL_Variable_Company__c,
                AcctSeed__Balance__c,AcctSeed__Total__c,AcctSeed__Received_Amount__c,
                AcctSeedERP__Sales_Order__r.Gl_Account_Variable_1__r.name,
                AcctSeed__Customer__r.Name, AcctSeed__Customer__r.AcctSeed__Billing_Terms_Name__c,
                AcctSeedERP__Sales_Order__r.Billing_Terms_Name__c, 
                AcctSeed__Opportunity__r.Billing_Terms_Name__c,
                GL_Account_Variable_1__c, Billing_Deposit__c, AcctSeed__Type__c  
                from AcctSeed__Billing__c where id=:billingId];
        
        deposit = bill.Billing_Deposit__c != null ? Decimal.ValueOf(bill.Billing_Deposit__c) : 0.00;
        
        Id firstbill = null;
        
        if(bill.AcctSeedERP__Sales_Order__c == null){
            
            firstbill = [select id from AcctSeed__Billing__c 
                         where Acctseed__Opportunity__c =: bill.Acctseed__Opportunity__c 
                         order by CreatedDate asc limit 1][0].id;
        }else{
            
            firstbill = [select id from AcctSeed__Billing__c 
                         where AcctSeedERP__Sales_Order__c =: bill.AcctSeedERP__Sales_Order__c 
                         order by CreatedDate asc limit 1][0].id;
        }
        
        if(firstbill == billingId){
            // this is the first bill set firstbilling to true
            firstbilling = true;
        }
        
        
        billingLines = [SELECT Id, Name, AcctSeed__Billing__c, Percent_QT__c, acctseed__opportunity_product_id__c,
                        AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Total__c, Image__c,
                        AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Quantity_Ordered__c,
                        AcctSeedERP__Sales_Order_Line__r.AcctSeedERP__Unit_Price__c,
                        AcctSeed__Hours_Units__c, AcctSeed__Product__r.ProductImageURL__c,AcctSeed__Product__c,
                        AcctSeed__Product__r.Product_Image_Short_URL__c,
                        AcctSeed__Product__r.name,Total_Price__c, Quantity__c, Unit_Cost__c,
                        AcctSeed__Rate__c, AcctSeed__Total__c, Size__c, size_custom__c, acctSeed__Product__r.ProductCode,
                        Item_Description__c FROM AcctSeed__Billing_Line__c where AcctSeed__Billing__c =: billingId
                        and AcctSeed__Tax_Line__c = false and Credit_Card_Fee__c = false
                        order by createddate,name asc];

        if(bill.AcctSeedERP__Sales_Order__c == null && !BillingLInes.isEmpty()){
            
            map<id, AcctSeed__Billing_line__c> billingLineMap = new map<id, Acctseed__billing_line__c>();

            for(AcctSeed__Billing_Line__c l : billingLInes){
                
                billingLineMap.put(l.acctseed__opportunity_product_id__c, l);
            }
            
            

            if(billingLineMap.size() > 0){
                
                List<OpportunityLineItem> oLines = [select id, UnitPrice, TotalPrice, Quantity from
                                                    OpportunityLineItem where
                                                    id in:BillingLineMap.keyset()];
                
                if(!OLines.isEmpty()){
                    
                    for(OpportunityLineItem oli : OLines){
                        AcctSeed__Billing_Line__c ln = billingLineMap.get(oli.id);
                        
                        if(ln == null) continue;
                        
                        ln.AcctSeed__Rate__c = oli.UnitPrice;
                        ln.AcctSeed__Hours_Units__c = oli.Quantity;
                        
                        TotalMap.put(ln.id, oli);
                    }
                }
                // check if any billing line was missed due to absence of oli
                for(AcctSeed__Billing_Line__c lin : billingLines){
                    
                    if(!TotalMap.containsKey(lin.id)){
                        
                        TotalMap.put(lin.id, new OpportunityLineItem(UnitPrice=lin.AcctSeed__Rate__c, 
                                                                     TotalPrice=lin.AcctSeed__Total__c));
                        
                    }
                }
            }
            
        }else if(bill.AcctSeedERP__Sales_Order__c != null && !BillingLInes.isEmpty()){
            List<Id> list_product_ids = new List<Id>();
            map<id, AcctSeed__Billing_line__c> billingLineSOLMap = new map<id, Acctseed__billing_line__c>();

            for(AcctSeed__Billing_Line__c bl : billingLInes){
                list_product_ids.add(bl.AcctSeed__Product__c);
                billingLineSOLMap.put(bl.AcctSeedERP__Sales_Order_Line__c, bl);
            }

            Set<Id> kit_childrens_ids = new Set<Id>();
            for(Id kit_id:kit_relation.keySet()){
                kit_childrens_ids.addAll(kit_relation.get(kit_id));
            }

            List<AcctSeed__Billing_Line__c> filtered_list = new List<AcctSeed__Billing_Line__c>();
        
            for(AcctSeed__Billing_Line__c l:billingLines){
                if(kit_relation.keySet().contains(l.AcctSeed__Product__c)){ //its kit
                    filtered_list.add(l);
                    continue;
                } else if(kit_childrens_ids.contains(l.AcctSeed__Product__c)){
                    for(Id kit_prod:kit_relation.keySet()){
                        if(kit_relation.get(kit_prod).contains(l.AcctSeed__Product__c) && !list_product_ids.contains(kit_prod)){
                            filtered_list.add(l);
                        }
                    }
                } else {
                    filtered_list.add(l);
                }
            }
            billingLines.clear();
            billingLines.addAll(filtered_list);

            if(billingLineSOLMap.size() > 0){
                
                List<AcctSeedERP__Sales_Order_Line__c> sols = [select id, AcctSeedERP__Unit_Price__c, AcctSeedERP__Total__c, 
                                                               AcctSeedERP__Quantity_Ordered__c from
                                                               AcctSeedERP__Sales_Order_Line__c where
                                                               id in:billingLineSOLMap.keyset()];
                
                if(!sols.isEmpty()){
                    
                    for(AcctSeedERP__Sales_Order_Line__c sol : sols){
                        AcctSeed__Billing_Line__c ln = billingLineSOLMap.get(sol.id);
                        
                        if(ln == null) continue;
                        
                        ln.AcctSeed__Rate__c = sol.AcctSeedERP__Unit_Price__c;
                        ln.AcctSeed__Hours_Units__c = sol.AcctSeedERP__Quantity_Ordered__c;
                        
                        TotalMap.put(ln.id, new OpportunityLineItem(UnitPrice=sol.AcctSeedERP__Unit_Price__c, 
                                                                    TotalPrice=sol.AcctSeedERP__Total__c));
                    }
                }
                // check if any billing line was missed due to absence of oli
                for(AcctSeed__Billing_Line__c lin : billingLines){
                    
                    if(!TotalMap.containsKey(lin.id)){
                        
                        TotalMap.put(lin.id, new OpportunityLineItem(UnitPrice=lin.AcctSeed__Rate__c, 
                                                                     TotalPrice=lin.AcctSeed__Total__c));
                        
                    }
                }
            }
        }
        
        
        // PDF Logic
        List<AcctSeed__Accounting_Variable__c> glData = [Select Billing_Header__c, Billing_Footer__c, 
                                                         Billing_Terms__c From AcctSeed__Accounting_Variable__c 
                                                         Where Name = :bill.GL_Account_Variable_1__c];
        
        if(glData.size() > 0){
            headerUrl = getImageURL(glData[0].Billing_Header__c);
            footerUrl = getImageURL(glData[0].Billing_Footer__c);
            terms = getFilteredTerms(glData[0].Billing_Terms__c);
        }

        payments = [SELECT AcctSeed__Billing__c, CreatedDate, AcctSeed__Cash_Receipt__c, AcctSeed__Accounting_Period__c, AcctSeed__Adjustment_Amount__c, AcctSeed__Adjustment_GL_Account__c, AcctSeed__Applied_Amount__c, AcctSeed__Period_Applied__c, AcctSeed__Applied_Date__c, AcctSeed__Status__c, Name, Id FROM AcctSeed__Billing_Cash_Receipt__c WHERE AcctSeed__Billing__c =:billingId];

        if(!Test.isRunningTest()){
        receipts = [SELECT Id, Name, AcctSeed__Billing__r.Name,
                    AcctSeed__Billing__r.AcctSeed__Customer__r.name, 
                    AcctSeed__Cash_Receipt__r.Name,
                    AcctSeed__Cash_Receipt__r.AcctSeed__Receipt_Date__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Account__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Accounting_Period__r.name, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Accounting_Year__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Amount__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Balance__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Bank_Account__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Bank_Deposit__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Bank_Reconciliation__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Cleared_Date__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Credit_GL_Account__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Currency_Conversion_Rate__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__GL_Account_Variable_1__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__GL_Account_Variable_2__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__GL_Account_Variable_3__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__GL_Account_Variable_4__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Ledger_Amount__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Payment_Reference__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Project_Task__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Project__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Purpose__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Status__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Applied_Amount__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Number_of_Billing_Cash_Receipts__c, 
                    AcctSeed__Cash_Receipt__r.AcctSeed__Ledger__c,                                                          
                    AcctSeed__Cash_Receipt__r.Payment_Method__c,                                                          
                    AcctSeed__Accounting_Period__c, AcctSeed__Adjustment_Amount__c, AcctSeed__Adjustment_GL_Account__c, AcctSeed__Applied_Amount__c, AcctSeed__Period_Applied__c FROM AcctSeed__Billing_Cash_Receipt__c
                    where AcctSeed__Billing__c =:billingId];
        }
    }
    

    public string getImageURL(string url){
        
        try{
            String imageURL = '';
            Matcher imgMatcher = Pattern.compile('<img(.+?)>').matcher(url);
            if(imgMatcher.find()) {
                String imageTag = imgMatcher.group();
                imageURL= imageTag.substringBetween(' src="', '"');
            }
            return imageURL.unescapeHtml4();
        }
        catch(Exception e){
            return e.getMessage() + e.getLineNumber();
        }
    }
    
    
    public string getFilteredTerms(string terms){
        
        try{

            String BillingTerms = bill.AcctSeedERP__Sales_Order__c != null ? bill.AcctSeedERP__Sales_Order__r.Billing_Terms_Name__c :
            bill.AcctSeed__Opportunity__c != null ? bill.AcctSeed__Opportunity__r.Billing_Terms_Name__c :
            bill.AcctSeed__Customer__c != null ? bill.AcctSeed__Customer__r.AcctSeed__Billing_Terms_Name__c : null; 
            
            if(BillingTerms == null) 
                BillingTerms = 'Not Applicable';
            
            string patternValue = string.valueOf(BillingTerms);
            
            terms = terms.replaceAll('Billing_Terms_Name__c', patternValue);
            
            patternValue = string.valueOf(bill.AcctSeed__Customer__r.Name);
            if(bill.AcctSeed__Customer__c != null) terms = terms.replaceAll('Customer_Name__c', patternValue);
            
            patternValue = string.valueOf(bill.GL_Variable_Company__c);
            if(bill.GL_Variable_Company__c != null) terms = terms.replaceAll('Company_Name__c', patternValue);
            
            terms = terms.replaceAll('###', '');
            terms  = terms.unescapeHtml4();
            terms = terms.replaceAll('&39;', '\'');
            
            return terms;
        }
        catch(Exception e){
            return e.getMessage() + e.getLineNumber();
        }
        
    }
    
}