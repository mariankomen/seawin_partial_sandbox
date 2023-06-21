public class CreateBillingFromOpportunityExtension {
	public Boolean isLines {get; set;}
    public Boolean AlreadyBilled {get; set;}
    
    public String billType {get; set;}
    public String depositbill {get; set;}
    public Decimal Amount {get{
        if(Amount == null){
            
            Amount = 0;
        }
        return Amount;
    } set;}
    
    public decimal deposit {get; set;}
    public boolean firstBilling {get; set;}
    
    public list<Wrapper> OLIWrapper {get; set;}
    public map<id, OpportunityLineItem> linesMap {get; set;}
    
    public AcctSeed__Billing__c billingTemp {get; set;} // temp record for date fields
    public Opportunity Opp {get; set;}
    
    public list<AcctSeed__Billing_Format__c> billingFormat {get; set;}
    
    private Id OppId {get; set;}
    
    Public AcctSeed__Ledger__c ledger {get; set;}
    
    public CreateBillingFromOpportunityExtension(ApexPages.StandardController std){
        
        ledger = [select id, name from AcctSeed__Ledger__c where 
                   Acctseed__type__c = 'Transactional' limit 1];
        
        firstBilling = false;
        billingTemp = new AcctSeed__Billing__c();
        Opp = new Opportunity();
        OLIWrapper = new list<Wrapper>();
        linesMap = new map<id, OpportunityLineItem>();
        billingTemp.AcctSeed__Date__c = Date.today();
        
        AlreadyBilled = false;
        
        
        // Accounting Period
        Date dates = Date.today();
        String acctperiodDate = dates.year() + '-0' + dates.month();
        
        // get the current accounting period which is open
        list<AcctSeed__Accounting_Period__c> acctPeriod = [SELECT AcctSeed__Status__c, Name, Id, AcctSeed__End_Date__c, 
                                                           AcctSeed__Start_Date__c 
                                                           FROM AcctSeed__Accounting_Period__c where 
                                                           Name =:acctperiodDate limit 1];
        
        
        billingTemp.AcctSeed__Accounting_Period__c = (!acctPeriod.IsEmpty()) ? acctPeriod[0].id : null;
        
        // get the so id
        OppId = (Id)std.getId();
        
        Opp = [SELECT Id, Name, AccountId, Account.Deposit__c, 
               Account.AcctSeed__Billing_Contact__c, Account.BillingStreet, 
               Account.BillingCity, Account.BillingState, Account.BillingPostalCode,
               Account.AcctSeed__Billing_Format__c,
               Account.BillingCountry, Account.Contact_Person__c,
               Account.AcctSeed__Billing_Days_Due__c,
               RecordType.Name,
               Shipping_City__c, Shipping_Country__c, 
               Shipping_PostalCode__c, Shipping_State__c, Shipping_Street__c, 
               GL_Account_Variable_1__c, Shipping_Name__c, Shipping_Account__c,
               Billing_Terms_Name__c, Billing_Deposit__c 
               FROM Opportunity where id =:OppId limit 1];
                
        deposit = Opp.Billing_Deposit__c != null ? Decimal.ValueOf(Opp.Billing_Deposit__c) : null;

        billingTemp.AcctSeed__Due_Date2__c = 
            (Opp.Account.AcctSeed__Billing_Days_Due__c != null) ? 
            Date.today() + (Integer)Opp.Account.AcctSeed__Billing_Days_Due__c : Date.today();
        
        // Default billing format
                
        billingTemp.AcctSeed__Billing_Format__c = Opp.Account.AcctSeed__Billing_Format__c;

        
        // check if this is first billing
        Integer firstbill = [select count() from AcctSeed__Billing__c where AcctSeed__Opportunity__c =: Opp.id];
        
        if(firstbill == 0){
            
           firstBilling = true;
            
        }
        
        // get the lines
        list<OpportunityLineItem> lines = [SELECT Id, OpportunityId, PricebookEntryId, 
                                                        Product2Id, Product2.name, ProductCode, Quantity, 
                                                        TotalPrice, UnitPrice, ListPrice, 
                                                        Item_Description__c, Size__c, 
                                                        AcctSeed__GL_Account_Variable_1__c, 
                                                        AcctSeed__GL_Account_Variable_2__c, 
                                                        AcctSeed__GL_Account_Variable_3__c, 
                                                        AcctSeed__GL_Account_Variable_4__c
                                                        
                                                        FROM OpportunityLineItem where 
                                                        OpportunityId =: OppId order by SortOrder,
                                                        Product2.name, createdDate asc];
        
        if(lines.IsEmpty()){
            
            isLines = false;
        }else{
            
            isLines = true;
            
            linesMap.putAll(lines);
            
            // make a map of the associated billing lines
            list<AcctSeed__Billing_Line__c> blines = new list<AcctSeed__Billing_Line__c>(
                [
                    SELECT Id, AcctSeed__Opportunity_Product_Id__c,
                    Name, AcctSeed__Total__c, 
                    AcctSeed__Product_Unit_Cost__c, 
                    AcctSeed__Hours_Units__c 
                    FROM AcctSeed__Billing_Line__c where 
                    AcctSeed__Opportunity_Product_Id__c in:linesMap.keyset() 
                    and AcctSeed__Billing__r.AcctSeed__Opportunity__c =:OppId
                    and AcctSeed__Billing__r.AcctSeed__Type__c = 'Invoice'
                ]           
            );
            map<id, String> blinesMap = new map<id, String>();
            if(!blines.IsEmpty()){
                // make a map with key as sol id and value as bol
                for(AcctSeed__Billing_Line__c bol: blines){
                    
                    // key = 'quantity:' + 'billedamount'
                    
                    String val = '';
                    Decimal Quantity = bol.AcctSeed__Hours_Units__c;
                    Decimal Total = bol.AcctSeed__Total__c;
                    
                    if(blinesMap.containsKey(bol.AcctSeed__Opportunity_Product_Id__c)){
                        
                        String[] valuesArray = blinesMap.get(bol.AcctSeed__Opportunity_Product_Id__c).split(':');
                        
                        Quantity += Decimal.valueOf(valuesArray[0]);
                        Total += Decimal.valueOf(valuesArray[1]);
                        
                        val = Quantity + ':' + Total;
                        
                        blinesMap.put(bol.AcctSeed__Opportunity_Product_Id__c, val);
                        
                    }else{
                        val = Quantity + ':' + Total;
                        blinesMap.put(bol.AcctSeed__Opportunity_Product_Id__c, val);
                    }
                    
                }
            }
            Integer billedItems = 0;
            for(Opportunitylineitem line : lines){
                // get the billing record for the current sol to fill billAmount and UnBilledAmount
                String bStr = blinesMap.get(line.id);
                String[] bstring = null;
                if(bStr != null){
                    bstring = blinesMap.get(line.id).split(':');
                }
                
                Decimal BilledAmount = 0;
                Decimal BilledAmount2 = 0;
                Decimal UnBilledAmount = 0;
                Decimal QuantityBilled = 0;
                Decimal BillAmount = 0;
                
                if(bstring != null){
                    BilledAmount = Decimal.valueOf(bstring[1]);
                    BilledAmount2 = Decimal.valueOf(bstring[1]) > line.TotalPrice ? 
                        line.TotalPrice : Decimal.valueOf(bstring[1]);
                    UnBilledAmount = 0;
                    QuantityBilled = (line.UnitPrice > 0) ? 
                        BilledAmount2 / line.UnitPrice : 
                    Decimal.valueOf(bstring[0]);
                    QuantityBilled = QuantityBilled.setScale(+6);
                    
                    // remove from linesMap if all has been billed for the sol
                    if(QuantityBilled != line.Quantity){
                        UnBilledAmount = line.TotalPrice - BilledAmount;
                    }else{
                        billedItems++;
                    } 
                }else{
                    UnBilledAmount = line.TotalPrice;
                }
                OLIWrapper.add(new Wrapper(line, QuantityBilled, 
                                           BilledAmount, UnBilledAmount, BillAmount));
            }
            
            if(billedItems == lines.size()){
                
                AlreadyBilled = true;
            }
        }
        
    }
    public PageReference createBilling(){

        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
        
        SavePoint sp = Database.setSavepoint();
        try{
            
            // construct accounting period  
            // Name = year-month
            Date enteredDate = billingTemp.AcctSeed__Date__c;
            String acctperiodDate = enteredDate.year() + ((enteredDate.month() < 10) ? '-0' : '-') + enteredDate.month();
            // get the current accounting period which is open
            list<AcctSeed__Accounting_Period__c> acctPeriod = [SELECT AcctSeed__Status__c, Name, Id, AcctSeed__End_Date__c, 
                                                               AcctSeed__Start_Date__c 
                                                               FROM AcctSeed__Accounting_Period__c where 
                                                               Name =:acctperiodDate and AcctSeed__Status__c = 'Open' limit 1];
            
            if(acctPeriod.IsEmpty()){
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'No Accounting Period has been set up for'+ 
                                                           ' this Billing Date or the Accounting Period status is closed.'+ 
                                                           ' Please first set up Accounting Period for this date in'+ 
                                                           ' Accounting Seed.'));
                return null;
            }
            
            billingFormat = [SELECT Id, name FROM AcctSeed__Billing_Format__c where 
                                   AcctSeed__Type__c = 'Billing'];
            
            // check if there is a sales order
            List<AcctSeedERP__Sales_Order__c> orders = [select id from AcctseedERP__sales_order__c
                                                       where AcctSeedERP__Opportunity__c =:Opp.id
                                                       order by createddate desc limit 1];
            map<string, id> SOLandOLIMap = new map<string, id>();
            if(!orders.isEmpty()){
                
                List<AcctSeedERP__Sales_Order_Line__c> OrderLines = [select id, AcctSeedERP__Opportunity_Product_Id__c
                                                                    from AcctseedERP__sales_order_line__c
                                                                    where AcctSeedERP__sales_order__c =:orders[0].id];
                
                for(AcctSeedERP__Sales_Order_Line__c sol : orderLines){
                    
                    SOLandOLIMap.put(sol.AcctSeedERP__Opportunity_Product_Id__c, sol.id);
                }
                
            }
            
            
            bill.AcctSeed__Status__c = 'Approved';
            bill.AcctSeed__PDF_Email_Status__c = 'Unsent';
            bill.AcctSeedERP__Sales_Order__c = !orders.isEmpty()?orders[0].id:null; 
            bill.AcctSeed__Date__c = billingTemp.AcctSeed__Date__c;
            bill.AcctSeed__Due_Date2__c = billingTemp.AcctSeed__Due_Date2__c;
            bill.AcctSeed__Opportunity__c = Opp.id;
            bill.AcctSeed__Customer__c = Opp.AccountId;
            bill.AcctSeed__Shipping_Contact__c = Opp.Shipping_Name__c;
            
            bill.AcctSeed__Shipping_City__c = Opp.Shipping_City__c;
            bill.AcctSeed__Shipping_Country__c = Opp.Shipping_Country__c;
            bill.AcctSeed__Shipping_PostalCode__c = Opp.Shipping_PostalCode__c;
            bill.AcctSeed__Shipping_State__c = Opp.Shipping_State__c;
            bill.AcctSeed__Shipping_Street__c = Opp.Shipping_Street__c;
            bill.AcctSeed__Billing_Terms_Name__c = opp.Billing_Terms_Name__c;
            
            bill.AcctSeed__Billing_Contact__c = (Opp.Account.AcctSeed__Billing_Contact__c != null)?
                Opp.Account.AcctSeed__Billing_Contact__c:Opp.Account.Contact_Person__c;
            bill.AcctSeed__Billing_Country__c = Opp.Account.BillingCountry;
            bill.AcctSeed__Billing_PostalCode__c = Opp.Account.BillingPostalCode;
            bill.AcctSeed__Billing_State__c = Opp.Account.BillingState;
            bill.AcctSeed__Billing_Street__c = Opp.Account.BillingStreet;
            bill.AcctSeed__Billing_City__c = Opp.Account.BillingCity;
            bill.AcctSeed__Accounting_Period__c = acctPeriod[0].id;
            bill.AcctSeed__Ledger__c = Ledger.id;
            bill.Shipping_Account__c = Opp.shipping_account__c;
            bill.Shipping_Name__c = Opp.Shipping_Name__c;
            bill.AcctSeed__Billing_Format__c = billingTemp.AcctSeed__Billing_Format__c;
            
            bill.Bill_Type__c = (billType == 'percent') ? 'Percent' : 
            ((billType == 'quantity') ? 'Quantity' : 'Amount');
                
                insert bill;
            
            list<AcctSeed__Billing_Line__c> lines = new list<AcctSeed__Billing_Line__c>();
            // now insert the billing lines
            for(Wrapper w : OLIWrapper){
                
                if(w.quantityBilled != w.oli.Quantity){
                    
                    Decimal quantity = (w.oli.UnitPrice == 0 && billType == 'quantity') ? 
                        w.billTypeVal : (w.oli.UnitPrice == 0 && billType != 'quantity') ? 
                        w.oli.Quantity - w.quantityBilled : w.BillAmountHidden/w.oli.UnitPrice;

                    quantity = quantity.setScale(+6);

                    if(quantity > 0 || Test.isRunningTest()){
                        AcctSeed__Billing_Line__c line = new AcctSeed__Billing_Line__c();
                        line.AcctSeed__Billing__c = bill.id;
                        line.AcctSeed__Date__c = date.today();
                        line.AcctSeed__GL_Account_Variable_1__c = w.oli.AcctSeed__GL_Account_Variable_1__c;
                        line.AcctSeed__GL_Account_Variable_2__c = w.oli.AcctSeed__GL_Account_Variable_2__c;
                        line.AcctSeed__GL_Account_Variable_3__c = w.oli.AcctSeed__GL_Account_Variable_3__c;
                        line.AcctSeed__GL_Account_Variable_4__c = w.oli.AcctSeed__GL_Account_Variable_4__c;
                        line.AcctSeed__Hours_Units__c = quantity;
                        line.AcctSeed__Opportunity_Product_Id__c = w.oli.id;
                        line.AcctSeed__Product__c = w.oli.Product2id;
                        line.AcctSeedERP__Sales_Order_Line__c = SOLandOLIMap.containsKey(w.oli.id)?
                            SOLandOLIMap.get(w.oli.id):null;
                        line.AcctSeed__Rate__c = w.oli.UnitPrice;
                        line.Item_Description__c = w.oli.Item_Description__c;
                        line.size_custom__c = w.oli.size__c;
                        
                        lines.add(line);
                    }
                    
                }
            }
            insert lines;
            
            PageReference page = new PageReference('/'+bill.id+'/e?retURL='+bill.id);
            page.setRedirect(true);
            
            return page;
            
        }catch(Exception ex){
            
            Database.rollback(sp);
            
            String errorMsg = ex.getMessage();

            string OnlyMsg = errorMsg.substringBetween(', ', ':');
            system.debug('ERROROROROROR: '+ex.getMessage());
            if(OnlyMsg != null){

                OnlyMsg = OnlyMsg.capitalize();

                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, OnlyMsg);
                ApexPages.addMessage(myMsg);
            }else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
                ApexPages.addMessage(myMsg);
            }
            
        }
        
        return null;
    }
    public class Wrapper{
        
        public OpportunityLineItem oli {get; set;}
        public Decimal quantityBilled {get; set;}
        public Decimal billedAmount {get; set;}
        public Decimal unbilledAmount {get; set;}
        public Decimal billTypeVal {get; set;}
        public Decimal BillAmount {get; set;}
        public Decimal BillAmountHidden {get; set;}
        public wrapper(OpportunityLineItem line, Decimal qb, Decimal bt, Decimal ut, Decimal btm){
            
            Decimal BillTypePart = line.TotalPrice > 0 || line.TotalPrice < 0 ? 
                ((ut / line.TotalPrice) * 100).setScale(5) : 0;
            BillTypePart = BillTypePart.stripTrailingZeros();
            
            oli = line;
            quantityBilled = qb;
            billedAmount = bt;
            unbilledAmount = ut;
            billTypeVal = (qb == line.Quantity) ? null : 
            (line.TotalPrice > 0 || line.TotalPrice < 0) ? Decimal.ValueOf(BillTypePart.toPlainString()) : 100;
            BillAmount = btm;
            BillAmountHidden = 0;
        }
    }
}