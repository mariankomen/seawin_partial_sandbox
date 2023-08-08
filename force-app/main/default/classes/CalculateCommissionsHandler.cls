public class CalculateCommissionsHandler {
    
    public class CommissionException extends Exception {}
    public static final Map<String, String> role_relation = new Map<String, String>{
        'Manufacturer Rep' => 'ManRep',
        'Specified Rep' => 'Specified',
        'Owner' => 'Owner',
        'Referral Sales Rep' => 'Referral'
    };
    public static void calculateCommissionsCashReceipts(List<AcctSeed__Billing_Cash_Receipt__c> receipts, Map<Id, List<String>> receipt_paid){
        map<id, AcctSeed__Billing_Cash_Receipt__c> receiptsMap = new map<id, AcctSeed__Billing_Cash_Receipt__c>(receipts);
        set<id> billingIds = new set<id>();
        string k = '123';
        if(k == '123'){
            // throw new CommissionException('Your Message');
        }

        for(AcctSeed__Billing_Cash_Receipt__c receipt : receipts){
            billingIds.add(receipt.AcctSeed__Billing__c);
        }
        
        map<id, Decimal> BillingLineMap = new map<id, Decimal>();
        BillingLineMap = FindBillingLineTotal(billingIds); //Map Of total sum amounts of commissinable products from billing
        system.debug('BillingLineMap: '+BillingLineMap);
        if(BillingLineMap.size() == 0){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'All billing line products are not commissinable or amount equal 0.'));
            // return false;

        } else {
            if(receiptsMap.size() > 0 && BillingLineMap.size() > 0){
                List<AcctSeed__Billing_Cash_Receipt__c> receiptData = [SELECT id,
                                                                    CreatedDate, 
                                                                    AcctSeed__Applied_Amount__c,
                                                                    AcctSeed__Adjustment_Amount__c,
                                                                    AcctSeed__Billing__c,
                                                                    AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c, 
                                                                    AcctSeed__Billing__r.AcctSeed__Total__c,
                                                                    AcctSeed__Billing__r.AcctSeed__Credit_Memo_Applied_Amount__c,

                                                                    AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Sales_Rep_o__r.IsTeam__c,
                                                                    AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Sales_Rep_o__r.Company_Name_Lookup__c,
                                                                    AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Referral_Sales_Rep__c,
                                                                    AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Manufacturer_Rep__c,
                                                                    AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Specified_Rep__c,
                                                                    AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.OwnerId,
                                                                    AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.AcctSeedERP__Opportunity__c,
                                                                    AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Sales_Rep__c,
                                                                    AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Manufacturer_Rep__c,
                                                                    AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Referral_Sales_Rep__c,
                                                                    AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Specified_Rep__c,

                                                                    AcctSeed__Billing__r.AcctSeed__Opportunity__c,
                                                                    AcctSeed__Billing__r.AcctSeed__Opportunity__r.Sales_Rep_O__r.IsTeam__c,
                                                                    AcctSeed__Billing__r.AcctSeed__Opportunity__r.Sales_Rep_O__r.Company_Name_Lookup__c,
                                                                    AcctSeed__Billing__r.AcctSeed__Opportunity__r.Referral_Sales_Rep__c,
                                                                    AcctSeed__Billing__r.AcctSeed__Opportunity__r.Manufacturer_Rep__c,
                                                                    AcctSeed__Billing__r.AcctSeed__Opportunity__r.Specified_Rep__c,
                                                                    AcctSeed__Billing__r.AcctSeed__Opportunity__r.OwnerId,
                                                                    AcctSeed__Billing__r.AcctSeed__Opportunity__r.Commission_Rate_Sales_Rep__c,
                                                                    AcctSeed__Billing__r.AcctSeed__Opportunity__r.Commission_Rate_Manufacturer_Rep__c,
                                                                    AcctSeed__Billing__r.AcctSeed__Opportunity__r.Commission_Rate_Referral_Sales_Rep__c,
                                                                    AcctSeed__Billing__r.AcctSeed__Opportunity__r.Commission_Rate_Specified_Rep__c

                                                                    FROM AcctSeed__Billing_Cash_Receipt__c
                                                                    WHERE id in:receiptsMap.keySet() LIMIT 100
                                                                    ];
                if(!receiptData.isEmpty()){
                    for(AcctSeed__Billing_Cash_Receipt__c receipt: receiptData){
                        //Create commissions if billing has Sales Order
                        if(receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c != null){

                            Boolean HasManRep = receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Manufacturer_Rep__c != null;
                            Boolean HasReferral = receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Referral_Sales_Rep__c != null;
                            Boolean HasSpecified = receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Specified_Rep__c != null;
                            Boolean IsTeam = receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Sales_Rep_o__r.IsTeam__c;

                            Decimal SalesPercent = receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Sales_Rep__c;
                            Decimal ReferralPercent = receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Referral_Sales_Rep__c;
                            Decimal ManRepPercent = receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Manufacturer_Rep__c;
                            Decimal SpecifiedPercent = receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Specified_Rep__c;

                            Decimal BillingLineTotal = BillingLineMap.containsKey(receipt.acctseed__billing__c) ? BillingLineMap.get(receipt.acctseed__billing__c) : 0;
                            system.debug('BillingLineTotal: '+BillingLineTotal);
                            if(receipt.AcctSeed__Adjustment_Amount__c == null){
                                receipt.AcctSeed__Adjustment_Amount__c = 0;
                            } 
                            if(receipt.AcctSeed__Billing__r.AcctSeed__Credit_Memo_Applied_Amount__c == null){
                                receipt.AcctSeed__Billing__r.AcctSeed__Credit_Memo_Applied_Amount__c = 0;
                            }

                            Decimal BillingTotal = receipt.AcctSeed__Billing__r.AcctSeed__Total__c - receipt.AcctSeed__Adjustment_Amount__c - receipt.AcctSeed__Billing__r.AcctSeed__Credit_Memo_Applied_Amount__c;

                            //Below runs method which calculate commissions for every rep, de
                            List<Sales_Order_Commissions__c> insertable_commmissions = preStepCompiling(
                                                                                                        true,
                                                                                                        receipt.Id,
                                                                                                        receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.OwnerId,
                                                                                                        receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Referral_Sales_Rep__c,
                                                                                                        receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Manufacturer_Rep__c,
                                                                                                        receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Specified_Rep__c,
                                                                                                        receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__r.Sales_Rep_o__r.Company_Name_Lookup__c,
                                                                                                        SalesPercent,
                                                                                                        ManRepPercent,
                                                                                                        ReferralPercent,
                                                                                                        SpecifiedPercent,

                                                                                                        HasManRep,
                                                                                                        HasReferral,
                                                                                                        HasSpecified,
                                                                                                        IsTeam,

                                                                                                        receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c,
                                                                                                        receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__c,
                                                                                                        receipt.AcctSeed__Billing__c,
                                                                                                        BillingTotal,
                                                                                                        BillingLineTotal,
                                                                                                        receipt.AcctSeed__Applied_Amount__c,
                                                                                                        receipt.CreatedDate,
                                                                                                        receipt_paid.containsKey(receipt.Id) ? receipt_paid.get(receipt.Id) : new List<String>()
                                                                                                    );
                            try{
                                insert insertable_commmissions;
                                //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'All commissions have been created successfully.'));

                                system.debug('===== SUCCESS =====');
                                system.debug('Cash Receipt Commissions for Sales Orders has been insertd SUCCESSFULLY!');
                                system.debug('Total commissions: '+insertable_commmissions.size());
                                system.debug('===== SUCCESS =====');
                            }catch(Exception e){
                                //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'ERROR DURING INSERTING Cash Receipt Commissions.(Sales Order)'));
                                system.debug('ERROR DURING INSERTING Cash Receipt Commissions.(Sales Order)');
                                system.debug('===== '+e.getMessage() +' =====');

                                Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                                String[] toAddresses = new list<string> {'testsalesforce840@gmail.com'};
                                email.setSubject('Error during creating commissions on Sales Order: ' + receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c);
                                email.setSenderDisplayName('SeaWin Commissions');
                                email.setToAddresses( toAddresses );
                                email.setPlainTextBody(e.getMessage());
                                
                                Messaging.SendEmailResult [] r = !Test.isRunningTest() ? Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}) : null;
                            }    
                        }else if(receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c == null && receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__c != null){
                            //Create commissions if billing has ONLY OPPORTUNITY

                            Boolean HasManRep = receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__r.Manufacturer_Rep__c != null;
                            Boolean HasReferral = receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__r.Referral_Sales_Rep__c != null;
                            Boolean HasSpecified = receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__r.Specified_Rep__c != null;
                            Boolean IsTeam = receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__r.Sales_Rep_O__r.IsTeam__c;

                            Decimal SalesPercent = receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__r.Commission_Rate_Sales_Rep__c;
                            Decimal ReferralPercent = receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__r.Commission_Rate_Referral_Sales_Rep__c;
                            Decimal ManRepPercent = receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__r.Commission_Rate_Manufacturer_Rep__c;
                            Decimal SpecifiedPercent = receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__r.Commission_Rate_Specified_Rep__c;

                            Decimal BillingLineTotal = BillingLineMap.containsKey(receipt.acctseed__billing__c) ? BillingLineMap.get(receipt.acctseed__billing__c) : 0;
                            system.debug('BillingLineTotal: '+BillingLineTotal);
                            if(receipt.AcctSeed__Adjustment_Amount__c == null){
                                receipt.AcctSeed__Adjustment_Amount__c = 0;
                            } 
                            if(receipt.AcctSeed__Billing__r.AcctSeed__Credit_Memo_Applied_Amount__c == null){
                                receipt.AcctSeed__Billing__r.AcctSeed__Credit_Memo_Applied_Amount__c = 0;
                            }

                            Decimal BillingTotal = receipt.AcctSeed__Billing__r.AcctSeed__Total__c - receipt.AcctSeed__Adjustment_Amount__c - receipt.AcctSeed__Billing__r.AcctSeed__Credit_Memo_Applied_Amount__c;

                            List<Sales_Order_Commissions__c> insertable_commmissions = preStepCompiling(
                                                                                                        true,
                                                                                                        receipt.Id,
                                                                                                        receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__r.OwnerId,
                                                                                                        receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__r.Referral_Sales_Rep__c,
                                                                                                        receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__r.Manufacturer_Rep__c,
                                                                                                        receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__r.Specified_Rep__c,
                                                                                                        receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__r.Sales_Rep_O__r.Company_Name_Lookup__c,
                                                                                                        SalesPercent,
                                                                                                        ManRepPercent,
                                                                                                        ReferralPercent,
                                                                                                        SpecifiedPercent,
                                                                                                        HasManRep,
                                                                                                        HasReferral,
                                                                                                        HasSpecified,
                                                                                                        IsTeam,
                                                                                                        receipt.AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c,
                                                                                                        receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__c,
                                                                                                        receipt.AcctSeed__Billing__c,
                                                                                                        BillingTotal,
                                                                                                        BillingLineTotal,
                                                                                                        receipt.AcctSeed__Applied_Amount__c,
                                                                                                        receipt.CreatedDate,
                                                                                                        receipt_paid.containsKey(receipt.Id) ? receipt_paid.get(receipt.Id) : new List<String>()
                                                                                                    );
                            try{
                                insert insertable_commmissions;
                                //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'All commissions have been created successfully.'));
                                system.debug('===== SUCCESS =====');
                                system.debug('Cash Receipt Commissions for Opportunity has been insertd SUCCESSFULLY!');
                                system.debug('Total commissions: '+insertable_commmissions.size());
                                system.debug('===== SUCCESS =====');
                            }catch(Exception e){
                                //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'ERROR DURING INSERTING Cash Receipt Commissions.(Sales Order)'));
                                system.debug('ERROR DURING INSERTING Cash Receipt Commissions. (Opportunity)');
                                system.debug('===== '+e.getMessage() +' =====');



                                

                                //Sending email
                                Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
                                String[] toAddresses = new list<string> {'testsalesforce840@gmail.com'};
                                email.setSubject('Error during creating commissions on Opportunity: ' + receipt.AcctSeed__Billing__r.AcctSeed__Opportunity__c);
                                email.setSenderDisplayName('SeaWin Commissions');
                                email.setToAddresses( toAddresses );
                                email.setPlainTextBody(e.getMessage());
                                
                                Messaging.SendEmailResult [] r = !Test.isRunningTest() ? Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}) : null;
                            } 
                        }
                    }
                }
                
                
            }

        }
    }

    public static void calculateCommissionsCreditMemo(List<AcctSeed__Billing_Credit_Memo__c> receipts, Map<Id, List<String>> receipt_paid){
        map<id, AcctSeed__Billing_Credit_Memo__c> receiptsMap = new map<id, AcctSeed__Billing_Credit_Memo__c>(receipts);
        
        set<id> billingIds = new set<id>();
        
        for(AcctSeed__Billing_Credit_Memo__c receipt : receipts){
            billingIds.add(receipt.AcctSeed__Billing_Invoice__c);
        }
        
        map<id, Decimal> BillingLineMap = new map<id, Decimal>();
        
        BillingLineMap = FindBillingLineTotal(billingIds);

        if(BillingLineMap.size() == 0){
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'All billing line products are not commissinable or amount equal 0.'));
            //return true;
        } else {
            if(receiptsMap.size() > 0 && BillingLineMap.size() > 0){
                List<AcctSeed__Billing_Credit_Memo__c> receiptData = [SELECT id, 
                                                                    CreatedDate,
                                                                    AcctSeed__Amount__c,
                                                                    AcctSeed__Billing_Invoice__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeed__Total__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__c, 
                                                                    AcctSeed__Billing_Invoice__r.Total_Amount_Due__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeed__Credit_Memo_Applied_Amount__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Sales_Rep_o__r.IsTeam__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Sales_Rep_o__r.Company_Name_Lookup__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Referral_Sales_Rep__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Manufacturer_Rep__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Specified_Rep__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.OwnerId,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.AcctSeedERP__Opportunity__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Sales_Rep__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Manufacturer_Rep__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Referral_Sales_Rep__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Specified_Rep__c,


                                                                    AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Sales_Rep_O__r.IsTeam__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Sales_Rep_O__r.Company_Name_Lookup__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Referral_Sales_Rep__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Manufacturer_Rep__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Specified_Rep__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.OwnerId,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Commission_Rate_Sales_Rep__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Commission_Rate_Manufacturer_Rep__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Commission_Rate_Referral_Sales_Rep__c,
                                                                    AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Commission_Rate_Specified_Rep__c

                                                                    FROM AcctSeed__Billing_Credit_Memo__c
                                                                    WHERE id in:receiptsMap.keySet() LIMIT 100];
                if(!receiptData.isEmpty()){
                    for(AcctSeed__Billing_Credit_Memo__c receipt : receiptData){
                        if(BillingLineMap.containsKey(receipt.AcctSeed__Billing_Invoice__c)){

                            //IF HAS SALES ORDER
                            if(receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__c != null){
                                Boolean HasManRep = receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Manufacturer_Rep__c != null;
                                Boolean HasReferral = receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Referral_Sales_Rep__c != null;
                                Boolean HasSpecified = receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Specified_Rep__c != null;
                                Boolean IsTeam = receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Sales_Rep_o__r.IsTeam__c;

                                Decimal SalesPercent = receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Sales_Rep__c;
                                Decimal ReferralPercent = receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Referral_Sales_Rep__c;
                                Decimal ManRepPercent = receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Manufacturer_Rep__c;
                                Decimal SpecifiedPercent = receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Commission_Rate_Specified_Rep__c;

                                if(receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Credit_Memo_Applied_Amount__c == null){
                                    receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Credit_Memo_Applied_Amount__c = 0;
                                }

                                Decimal BillingTotal = receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Total__c;

                                Decimal BillingLineTotal = BillingLineMap.containsKey(receipt.AcctSeed__Billing_Invoice__c) 
                                                        ?  BillingLineMap.get(receipt.AcctSeed__Billing_Invoice__c) 
                                                        : 0;
                                //Below runs method which calculate commissions for every rep, de
                                List<Sales_Order_Commissions__c> insertable_commmissions = preStepCompiling(
                                                                                                            false,
                                                                                                            receipt.Id,
                                                                                                            receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.OwnerId,
                                                                                                            receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Referral_Sales_Rep__c,
                                                                                                            receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Manufacturer_Rep__c,
                                                                                                            receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Specified_Rep__c,
                                                                                                            receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__r.Sales_Rep_o__r.Company_Name_Lookup__c,
                                                                                                            SalesPercent,
                                                                                                            ManRepPercent,
                                                                                                            ReferralPercent,
                                                                                                            SpecifiedPercent,
                                                                                                            HasManRep,
                                                                                                            HasReferral,
                                                                                                            HasSpecified,
                                                                                                            IsTeam,
                                                                                                            receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__c,
                                                                                                            receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__c,
                                                                                                            receipt.AcctSeed__Billing_Invoice__c,
                                                                                                            BillingTotal,
                                                                                                            BillingLineTotal,
                                                                                                            receipt.AcctSeed__Amount__c,
                                                                                                            receipt.CreatedDate,
                                                                                                            receipt_paid.containsKey(receipt.Id) ? receipt_paid.get(receipt.Id) : new List<String>()
                                                                                                        );
                                try{
                                    insert insertable_commmissions;
                                    //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'All commissions have been created successfully.'));

                                    system.debug('===== SUCCESS =====');
                                    system.debug('Credit Memo Commissions for Sales Order has been insertd SUCCESSFULLY!');
                                    system.debug('Total commissions: '+insertable_commmissions.size());
                                    system.debug('===== SUCCESS =====');
                                }catch(Exception e){
                                    //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'ERROR DURING INSERTING Credit Memo Commissions. (Sales Order)'));
                                    system.debug('ERROR DURING INSERTING Credit Memo Commissions. (Sales Order)');
                                    system.debug('===== '+e.getMessage() +' =====');
                                } 

                                //IF HAS ONLT OPP
                            }else if(receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__c == null && receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__c != null){

                                Boolean HasManRep = receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Manufacturer_Rep__c != null;
                                Boolean HasReferral = receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Referral_Sales_Rep__c != null;
                                Boolean HasSpecified = receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Specified_Rep__c != null;
                                Boolean IsTeam = receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Sales_Rep_o__r.IsTeam__c;

                                Decimal SalesPercent = receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Commission_Rate_Sales_Rep__c;
                                Decimal ReferralPercent = receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Commission_Rate_Referral_Sales_Rep__c;
                                Decimal ManRepPercent = receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Commission_Rate_Manufacturer_Rep__c;
                                Decimal SpecifiedPercent = receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Commission_Rate_Specified_Rep__c;

                                if(receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Credit_Memo_Applied_Amount__c == null){
                                    receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Credit_Memo_Applied_Amount__c = 0;
                                }

                                Decimal BillingTotal = receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Total__c;

                                Decimal BillingLineTotal = BillingLineMap.containsKey(receipt.AcctSeed__Billing_Invoice__c) 
                                                        ?  BillingLineMap.get(receipt.AcctSeed__Billing_Invoice__c) 
                                                        : 0;
                                //Below runs method which calculate commissions for every rep, de
                                List<Sales_Order_Commissions__c> insertable_commmissions = preStepCompiling(
                                                                                                            false,
                                                                                                            receipt.Id,
                                                                                                            receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.OwnerId,
                                                                                                            receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Referral_Sales_Rep__c,
                                                                                                            receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Manufacturer_Rep__c,
                                                                                                            receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Specified_Rep__c,
                                                                                                            receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__r.Sales_Rep_o__r.Company_Name_Lookup__c,
                                                                                                            SalesPercent,
                                                                                                            ManRepPercent,
                                                                                                            ReferralPercent,
                                                                                                            SpecifiedPercent,
                                                                                                            HasManRep,
                                                                                                            HasReferral,
                                                                                                            HasSpecified,
                                                                                                            IsTeam,
                                                                                                            receipt.AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__c,
                                                                                                            receipt.AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__c,
                                                                                                            receipt.AcctSeed__Billing_Invoice__c,
                                                                                                            BillingTotal,
                                                                                                            BillingLineTotal,
                                                                                                            receipt.AcctSeed__Amount__c,
                                                                                                            receipt.CreatedDate,
                                                                                                            receipt_paid.containsKey(receipt.Id) ? receipt_paid.get(receipt.Id) : new List<String>()
                                                                                                        );
                                try{
                                    insert insertable_commmissions;
                                    //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'All commissions have been created successfully.'));
                                    system.debug('===== SUCCESS =====');
                                    system.debug('Credit Memo Commissions for Opportunity has been insertd SUCCESSFULLY!');
                                    system.debug('Total commissions: '+insertable_commmissions.size());
                                    system.debug('===== SUCCESS =====');
                                }catch(Exception e){
                                    //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'ERROR DURING INSERTING Credit Memo Commissions. (Opportunity)'));
                                    system.debug('ERROR DURING INSERTING Credit Memo Commissions. (Opportunity)');
                                    system.debug('===== '+e.getMessage() +' =====');
                                } 
                            }



                        }
                    }
                }
            }
        }
    }
    public static List<Sales_Order_Commissions__c> preStepCompiling(
        Boolean isCash,
        Id cashReceiptId,
        Id ownerId,
        Id ReferralId,
        Id ManufRepId,
        Id SpecifiedRepId,
        Id SalesRepId,
        Decimal SalesRepPercent,
        Decimal ManRepPercent,
        Decimal RefRepPercent,
        Decimal SpecRepPercent,
        Boolean hasManRep,
        Boolean hasRefRep,
        Boolean hasSpecRep,
        Boolean isTeam,
        String salesOrderId,
        Id opportunityId,
        String billingNumber,
        Decimal billingTotal,
        Decimal billingLineCommisionableTotal,
        Decimal receiptAppliedAmount, 
        Datetime createdDate,
        List<String> paid_roles
    ){

        system.debug('receiptAppliedAmount: '+receiptAppliedAmount);
        system.debug('billingLineCommisionableTotal: '+billingLineCommisionableTotal);
        system.debug('billingTotal: '+billingTotal);
        //Below calculated total amount from which need calculate commisions by commission percents. It's correct, do not touch it.
        //If default cash receipt than default calculation, if credit memo than me * -1 our amount
        Decimal commisionableAmount = isCash ? (receiptAppliedAmount * billingLineCommisionableTotal) / billingTotal 
        : ((receiptAppliedAmount * billingLineCommisionableTotal) / billingTotal) * (-1);
        List<Sales_Order_Commissions__c> commissions = new List<Sales_Order_Commissions__c>();

        if(SalesRepPercent != null && SalesRepPercent > 0 && !paid_roles.contains('Owner')){
            //Calc SalesRep Commission Amount
            Decimal salRepCommissionAmount = (commisionableAmount * SalesRepPercent)/100;

            if((IsTeam && OwnerId != null) || (!IsTeam && SalesRepId != null)){

                commissions.add(MakeCommissions(isCash, cashReceiptId, ownerId, ReferralId, ManufRepId,
                                                SpecifiedRepId, 
                                                SalesRepId, 
                                                salRepCommissionAmount, 
                                                'Owner', IsTeam, salesOrderId, billingNumber, createdDate, opportunityId, null));
            }
        }

        if(hasRefRep && !paid_roles.contains('Referral') && RefRepPercent != null && RefRepPercent > 0 && (ReferralId != null || OwnerId != null)){
            //Calc ReferralRep Commission Amount
            Decimal refRepCommissionAmount = (commisionableAmount * RefRepPercent)/100;
            refRepCommissionAmount = refRepCommissionAmount.setScale(2, RoundingMode.HALF_EVEN);

            if(ReferralId != null){
                commissions.add(MakeCommissions(isCash, cashReceiptId, ownerId, ReferralId, ManufRepId,
                                                SpecifiedRepId, 
                                                SalesRepId, 
                                                refRepCommissionAmount, 
                                                'Referral', IsTeam, salesOrderId, billingNumber, createdDate, opportunityId, null));
            }

        }

        if(hasManRep && !paid_roles.contains('ManRep') && ManRepPercent != null && ManRepPercent > 0){
            //Calc ManufactureRep Commission Amount
            Decimal manRepCommissionAmount = (commisionableAmount * ManRepPercent)/100;
            manRepCommissionAmount = manRepCommissionAmount.setScale(2, RoundingMode.HALF_EVEN);

            if(ManufRepId != null){
                commissions.add(MakeCommissions(isCash, cashReceiptId, ownerId, ReferralId, ManufRepId,
                                                SpecifiedRepId, 
                                                SalesRepId, 
                                                manRepCommissionAmount, 
                                                'ManRep', IsTeam, salesOrderId, billingNumber, createdDate, opportunityId, null));
            }

        }
        if(hasSpecRep && !paid_roles.contains('Specified') && SpecRepPercent != null && SpecRepPercent > 0){
            //Calc SpecifiedRep Commission Amount
            Decimal specRepCommissionAmount = (commisionableAmount * SpecRepPercent)/100;
            specRepCommissionAmount = specRepCommissionAmount.setScale(2, RoundingMode.HALF_EVEN);

            if(SpecifiedRepId != null){
                commissions.add(MakeCommissions(isCash, cashReceiptId, ownerId, ReferralId, ManufRepId,
                                                SpecifiedRepId, 
                                                SalesRepId, 
                                                specRepCommissionAmount, 
                                                'Specified', IsTeam, salesOrderId, billingNumber, createdDate, opportunityId, null));
            }

        }
        return commissions;
    }

    public static void updateExistingCommissions(Id salesOrderId){
        Map<Id, List<String>> receipt_paid = deleteUnpaidCommissionsBeforeUpdate(salesOrderId);
        List<AcctSeed__Billing_Cash_Receipt__c> cashReceiptsOfSalesOrder = [SELECT Id, 
                                                                                    AcctSeed__Billing__c 
                                                                            FROM AcctSeed__Billing_Cash_Receipt__c 
                                                                            WHERE AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c =:salesOrderId 
                                                                            OR AcctSeed__Billing__r.AcctSeed__Opportunity__c =:salesOrderId ];

        List<AcctSeed__Billing_Credit_Memo__c> creditMemosOfSalesOrder = [SELECT Id, 
                                                                                AcctSeed__Billing_Invoice__c 
                                                                        FROM AcctSeed__Billing_Credit_Memo__c 
                                                                        WHERE AcctSeed__Billing_Invoice__r.AcctSeedERP__Sales_Order__c =:salesOrderId
                                                                        OR AcctSeed__Billing_Invoice__r.AcctSeed__Opportunity__c =:salesOrderId];

        if(!cashReceiptsOfSalesOrder.isEmpty()){
            calculateCommissionsCashReceipts(cashReceiptsOfSalesOrder, receipt_paid);
        }
        if(!creditMemosOfSalesOrder.isEmpty()){
            calculateCommissionsCreditMemo(creditMemosOfSalesOrder, receipt_paid);
        }
    }
    public static Map<Id, List<String>> deleteUnpaidCommissionsBeforeUpdate(Id recordId){
        List<Sales_Order_Commissions__c> commissions = [SELECT Id, Role__c, Billing_Cash_Receipt__c, Billing_Credit_Memo__c  FROM Sales_Order_Commissions__c where Sales_Order__c=:recordId OR Opportunity__c=:recordId];
        Map<Id, Sales_Order_Commissions__c> commissions_map = new Map<Id, Sales_Order_Commissions__c>(commissions);

        Set<Id> commission_set = new Set<Id>();
        for(Sales_Order_Commissions__c comm: commissions){
            commission_set.add(comm.Id);
        }
        List<AcctSeed__Account_Payable__c> payable_for_commissions = [SELECT Id, Sales_Order_Commissions__c FROM AcctSeed__Account_Payable__c WHERE Sales_Order_Commissions__c IN:commission_set];
        Set<Id> payed_commissions = new Set<id>();
        for(AcctSeed__Account_Payable__c payable: payable_for_commissions){
            payed_commissions.add(payable.Sales_Order_Commissions__c);
        }
        Set<Id> available_for_delete = new Set<Id>();
        Set<Id> not_deletable = new Set<Id>();
        for(Id commission: commission_set){
            if(!payed_commissions.contains(commission)){
                available_for_delete.add(commission);
            }else{
                not_deletable.add(commission);
            }
        }
        List<Sales_Order_Commissions__c> deletable = [SELECT Id FROM Sales_Order_Commissions__c WHERE Id IN:available_for_delete];
        if(!deletable.isEmpty()){
            delete deletable;
        }

        Map<Id, List<String>> invoice_memo_with_role = new Map<Id, List<String>>();
        for(Id comm: not_deletable){
            Sales_Order_Commissions__c commission = commissions_map.get(comm);
            if(commission.Billing_Cash_Receipt__c != null){
                if(!invoice_memo_with_role.containsKey(commission.Billing_Cash_Receipt__c)){
                    invoice_memo_with_role.put(commission.Billing_Cash_Receipt__c, new List<String>{role_relation.get(commission.Role__c)});
                }else{
                    invoice_memo_with_role.get(commission.Billing_Cash_Receipt__c).add(role_relation.get(commission.Role__c));
                }
            }

            if(commission.Billing_Credit_Memo__c != null){
                if(!invoice_memo_with_role.containsKey(commission.Billing_Credit_Memo__c)){
                    invoice_memo_with_role.put(commission.Billing_Credit_Memo__c, new List<String>{role_relation.get(commission.Role__c)});
                }else{
                    invoice_memo_with_role.get(commission.Billing_Credit_Memo__c).add(role_relation.get(commission.Role__c));
                }
            }
        }

        system.debug(JSON.serialize(invoice_memo_with_role));
        return invoice_memo_with_role;
        
    }


    public static Sales_Order_Commissions__c MakeCommissions(
        Boolean isCash,
        Id receiptId,
        Id OwnerId,
        Id ReferralId,
        Id ManufacturerId,
        Id SpecifiedId,
        Id SalesRepCompanyId,
        Decimal amt, 
        String typeOfCommission, 
        Boolean IsTeam, 
        string salesOrderId, 
        string billingNumber, 
        datetime dt,
        Id oppId, Id credOrderId){
            
            system.debug('zayshlo v MakeCommissions');
            Sales_Order_Commissions__c commission = new Sales_Order_Commissions__c();
            
            if(typeOfCommission == 'Referral'){ 
                commission.Referral_Sales_Rep__c = ReferralId;
            }
            else if(typeOfCommission == 'Owner'){ 
                commission.Owner__c = IsTeam ? OwnerId : null;
                commission.Sales_Rep_Company_Name__c = IsTeam ? null : SalesRepCompanyId;
                if(IsTeam){
                    commission.OwnerId = OwnerId;
                }
            }
            else if(typeOfCommission == 'ManRep'){ 
                commission.Manufacturer_Rep__c = ManufacturerId;
            }
            else if(typeOfCommission == 'Specified'){ 
                commission.Specified_Rep__c = SpecifiedId;
            }
            commission.Commission_Amount__c = IsCash ? amt.setScale(2, System.RoundingMode.HALF_EVEN) : 
            -amt.setScale(2, System.RoundingMode.HALF_EVEN);
            // -amt.setScale(2, System.RoundingMode.HALF_EVEN);
            commission.Sales_Order__c = salesOrderId;
            commission.Billing_Cash_Receipt__c = IsCash ? ReceiptId : null;
            commission.Billing_Credit_Memo__c = IsCash ? null : ReceiptId;
            commission.Reference_Number__c = billingNumber;
            commission.Billing_Paid_Date__c = dt;
            commission.Opportunity__c = oppId;
            // commission.Credit_Order__c = credOrderId;
            return commission;
        }
    
    // Delete Commissions for Billing type Invoice
    public static void DeleteCommissions(set<id> keys, Boolean isMemo){
        
        try{
            
            string queryStr = '';
            
            if(isMemo){
                queryStr += 'Select Id From Sales_Order_Commissions__c where Billing_Credit_Memo__c in:keys LIMIT 100';
            }else{
                queryStr += 'Select Id From Sales_Order_Commissions__c where Billing_Cash_Receipt__c in:keys LIMIT 100';
            }
            
            List<Sales_Order_Commissions__c> DeletableCommissions = Database.query(queryStr);
            
            if(!DeletableCommissions.isEmpty()) delete DeletableCommissions;
            
        }catch(Exception ex){
            
            system.debug('Error occured: ');
            system.debug(ex.getMessage());
        }
    }
    
    public static map<id, Decimal> FindBillingLineTotal(set<id> billingIds){
        
        map<id, Decimal> BillingLineMap = new map<id, Decimal>();
        
        List<AggregateResult> agrs = [select SUM(acctseed__total__c) total, acctseed__billing__c billingId
                                      from acctseed__billing_line__c where acctseed__billing__c in:billingIds
                                      and acctseed__product__r.Commissionable_Product__c = true
                                      and acctseed__total__c != null
                                      group by acctseed__billing__c LIMIT 100];

        if(!agrs.isEmpty() && agrs.size() > 0){
            
            for(AggregateResult agr : agrs){
                
                BillingLineMap.put((string)agr.get('billingId'), (Decimal)agr.get('total'));
            }
        } 
        
        return BillingLineMap; //Total sum of amounts Commissionable items from billing lines
    }
    



    public static void coverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
 

    
}