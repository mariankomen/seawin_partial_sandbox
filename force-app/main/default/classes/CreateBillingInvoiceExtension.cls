public class CreateBillingInvoiceExtension {
    
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
    
    public list<Wrapper> solWrapper {get; set;}
    public map<id, AcctSeedERP__Sales_Order_Line__c> linesMap {get; set;}
    
    public AcctSeed__Billing__c billingTemp {get; set;} // temp record for date fields
    public AcctSeedERP__Sales_Order__c soRecord {get; set;}
    
    private Id soId {get; set;}
    
    public CreateBillingInvoiceExtension(ApexPages.StandardController std){
        
        firstBilling = false;
        billingTemp = new AcctSeed__Billing__c();
        soRecord = new AcctSeedERP__Sales_Order__c();
        solWrapper = new list<Wrapper>();
        linesMap = new map<id, AcctSeedERP__Sales_Order_Line__c>();
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
        soId = (Id)std.getId();
        
        soRecord = [SELECT Id, Name, AcctSeedERP__Billing_City__c, AcctSeedERP__Billing_Country__c, 
                    AcctSeedERP__Billing_PostalCode__c, AcctSeedERP__Billing_State__c, 
                    Balance__c, Shipping_Account__c, Shipping_Name__c, Billing_Name__c,
                    AcctSeedERP__Billing_Street__c, AcctSeedERP__Customer__c,
                    AcctSeedERP__Customer__r.AcctSeed__Billing_Contact__c, 
                    AcctSeedERP__Customer__r.AcctSeed__Billing_Days_Due__c, 
                    AcctSeedERP__Opportunity__c, AcctSeedERP__Shipping_City__c, Contact__c,
                    AcctSeedERP__Shipping_Country__c, AcctSeedERP__Shipping_PostalCode__c, 
                    AcctSeedERP__Shipping_State__c, AcctSeedERP__Shipping_Street__c, AcctSeedERP__Ledger__c,
                    Billing_Deposit__c,Billing_Terms_Name__c, 
                    AcctSeedERP__Total__c FROM AcctSeedERP__Sales_Order__c where id =:soId limit 1];

                    soRecord.Billing_Deposit__c = soRecord.Billing_Deposit__c == null ? '0' : soRecord.Billing_Deposit__c;
                    
                
                    deposit = Decimal.ValueOf(soRecord.Billing_Deposit__c); 
        
        billingTemp.AcctSeed__Due_Date2__c = 
            (soRecord.AcctSeedERP__Customer__r.AcctSeed__Billing_Days_Due__c != null) ? 
            Date.today() + (Integer)soRecord.AcctSeedERP__Customer__r.AcctSeed__Billing_Days_Due__c : Date.today();
        
        // check if this is first billing
        Integer firstbill = [select count() from AcctSeed__Billing__c where AcctSeedERP__Sales_Order__c =: soRecord.id];
        
        if(firstbill == 0){
            
           firstBilling = true;
            
        }
        
        // get the lines
        list<AcctSeedERP__Sales_Order_Line__c> lines = [SELECT Id, Name, AcctSeedERP__Sales_Order__c,
                                                        AcctSeedERP__Product__r.Name,
                                                        Item_Description__c,
                                                        AcctSeedERP__Comment__c, AcctSeedERP__GL_Account_Variable_1__c, 
                                                        AcctSeedERP__GL_Account_Variable_2__c, 
                                                        AcctSeedERP__GL_Account_Variable_3__c, 
                                                        AcctSeedERP__GL_Account_Variable_4__c, 
                                                        AcctSeedERP__Opportunity_Product_Id__c, 
                                                        AcctSeedERP__Product__c, 
                                                        AcctSeedERP__Purchase_Order_Line__c, 
                                                        AcctSeedERP__Quantity_Manufactured__c, 
                                                        AcctSeedERP__Quantity_Needed__c, 
                                                        AcctSeedERP__Quantity_Ordered_Manufacturing__c, 
                                                        AcctSeedERP__Quantity_Ordered_Supplier__c, 
                                                        AcctSeedERP__Quantity_Ordered__c, 
                                                        AcctSeedERP__Quantity_Received_Supplier__c, 
                                                        AcctSeedERP__Total__c, AcctSeedERP__Unit_Price__c, 
                                                        AcctSeedERP__Quantity_Allocated__c, 
                                                        AcctSeedERP__Quantity_Shipped__c, 
                                                        AcctSeedERP_Description__c, Size__c, 
                                                        SortOrder__c, ProductCode__c, IsAllocated__c, 
                                                        QuantityFormula__c, Quantity_Allocated_Formula__c, 
                                                        Quantity_Shipped_Formula__c, Total_Price__c, 
                                                        Sales_Price__c, Quantity_Needed_Formula__c, 
                                                        CreatedDate FROM AcctSeedERP__Sales_Order_Line__c where 
                                                        AcctSeedERP__Sales_Order__c =: soId order by SortOrder__c,
                                                        AcctSeedERP__Product__r.name, createdDate asc];
        
        if(lines.IsEmpty()){
            
            isLines = false;
        }else{
            
            isLines = true;
            
            linesMap.putAll(lines);
            
            // make a map of the associated billing lines
            list<AcctSeed__Billing_Line__c> blines = new list<AcctSeed__Billing_Line__c>(
                [
                    SELECT Id, AcctSeedERP__Sales_Order_Line__c,
                    Name, AcctSeed__Total__c, 
                    AcctSeed__Product_Unit_Cost__c, 
                    AcctSeed__Hours_Units__c 
                    FROM AcctSeed__Billing_Line__c where 
                    AcctSeedERP__Sales_Order_Line__c in:linesMap.keyset() 
                    and AcctSeed__Billing__r.AcctSeedERP__Sales_Order__c =:soId
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
                    
                    if(blinesMap.containsKey(bol.AcctSeedERP__Sales_Order_Line__c)){
                        
                        String[] valuesArray = blinesMap.get(bol.AcctSeedERP__Sales_Order_Line__c).split(':');
                        
                        Quantity += Decimal.valueOf(valuesArray[0]);
                        Total += Decimal.valueOf(valuesArray[1]);
                        
                        val = Quantity + ':' + Total;
                        
                        blinesMap.put(bol.AcctSeedERP__Sales_Order_Line__c, val);
                        
                    }else{
                        val = Quantity + ':' + Total;
                        blinesMap.put(bol.AcctSeedERP__Sales_Order_Line__c, val);
                    }
                    
                }
            }
            Integer billedItems = 0;
            for(AcctSeedERP__Sales_Order_Line__c line : lines){
                system.debug('The blinesMap size is: ' + blinesMap.size());
                // get the billing record for the current sol to fill billAmount and UnBilledAmount
                String bStr = blinesMap.get(line.id);
                String[] bstring = null;
                if(bStr != null){
                    bstring = blinesMap.get(line.id).split(':');
                }
                
                Decimal BilledAmount = 0;
                Decimal UnBilledAmount = 0;
                Decimal QuantityBilled = 0;
                Decimal BillAmount = 0;
                
                if(bstring != null){
                    BilledAmount = Decimal.valueOf(bstring[1]);
                    UnBilledAmount = 0;
                    // QuantityBilled = Decimal.valueOf(bstring[0]);
                    QuantityBilled = (line.AcctSeedERP__Unit_Price__c > 0) ? 
                        BilledAmount / line.AcctSeedERP__Unit_Price__c : 
                    Decimal.valueOf(bstring[0]);
                    QuantityBilled = QuantityBilled.setScale(+6);
                    
                    // remove from linesMap if all has been billed for the sol
                    if(QuantityBilled != line.AcctSeedERP__Quantity_Ordered__c){
                        UnBilledAmount = line.AcctSeedERP__Total__c - BilledAmount;
                    }else{
                        
                        billedItems++;
                    } 
                }else{
                    UnBilledAmount = line.AcctSeedERP__Total__c;
                }
                solWrapper.add(new Wrapper(line, line.AcctSeedERP__Quantity_Allocated__c, 
                                           QuantityBilled, BilledAmount, UnBilledAmount, BillAmount));
            }
            
            if(billedItems == lines.size()){
                
                AlreadyBilled = true;
            }
        }
        
    }
    public PageReference createBilling(){

        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
        
        list<AcctSeed__Billing_Format__c> format = [select id from AcctSeed__Billing_Format__c 
                                                    where Name = 'Default Billing Product' limit 1];
        
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
            
            // get the billing format
            list<AcctSeed__Billing_Format__c> billingFormat = [SELECT Id FROM AcctSeed__Billing_Format__c where 
                                   AcctSeed__Type__c = 'Billing' and AcctSeed__Visualforce_PDF_Page__c = 
                                   'BillingInvoicePDF' limit 1];
            
            
            bill.AcctSeed__Status__c = 'Approved';
            bill.AcctSeed__PDF_Email_Status__c = 'Unsent';
            bill.AcctSeed__Billing_Format__c = (format.size() > 0) ? format[0].id : null;
            bill.AcctSeedERP__Sales_Order__c = soRecord.id; 
            bill.AcctSeed__Date__c = billingTemp.AcctSeed__Date__c;
            bill.AcctSeed__Due_Date2__c = billingTemp.AcctSeed__Due_Date2__c;
            bill.AcctSeed__Opportunity__c = soRecord.AcctSeedERP__Opportunity__c;
            bill.AcctSeed__Customer__c = soRecord.AcctSeedERP__Customer__c;
            bill.AcctSeed__Shipping_Contact__c = soRecord.Contact__c;
            
            bill.AcctSeed__Shipping_City__c = soRecord.AcctSeedERP__Shipping_City__c;
            bill.AcctSeed__Shipping_Country__c = soRecord.AcctSeedERP__Shipping_Country__c;
            bill.AcctSeed__Shipping_PostalCode__c = soRecord.AcctSeedERP__Shipping_PostalCode__c;
            bill.AcctSeed__Shipping_State__c = soRecord.AcctSeedERP__Shipping_State__c;
            bill.AcctSeed__Shipping_Street__c = soRecord.AcctSeedERP__Shipping_Street__c;
            
            bill.AcctSeed__Billing_Contact__c = soRecord.Billing_Name__c;
            bill.AcctSeed__Billing_Country__c = soRecord.AcctSeedERP__Billing_Country__c;
            bill.AcctSeed__Billing_PostalCode__c = soRecord.AcctSeedERP__Billing_PostalCode__c;
            bill.AcctSeed__Billing_State__c = soRecord.AcctSeedERP__Billing_State__c;
            bill.AcctSeed__Billing_Street__c = soRecord.AcctSeedERP__Billing_Street__c;
            bill.AcctSeed__Billing_City__c = soRecord.AcctSeedERP__Billing_City__c;
            bill.AcctSeed__Accounting_Period__c = acctPeriod[0].id;
            bill.AcctSeed__Ledger__c = soRecord.AcctSeedERP__Ledger__c;
            bill.Shipping_Account__c = soRecord.shipping_account__c;
            bill.Shipping_Name__c = soRecord.Shipping_Name__c;
            bill.AcctSeed__Billing_Format__c = (!billingFormat.isEmpty())?billingFormat[0].id:null;
            
            bill.Bill_Type__c = null;
                
                insert bill;
            
            list<AcctSeed__Billing_Line__c> lines = new list<AcctSeed__Billing_Line__c>();
            // now insert the billing lines
            for(Wrapper w : solWrapper){
                
                if(w.quantityBilled != w.soLine.AcctSeedERP__Quantity_Ordered__c){
                    
                    AcctSeed__Billing_Line__c line = new AcctSeed__Billing_Line__c();
                    line.AcctSeed__Billing__c = bill.id;
                    line.AcctSeed__Date__c = date.today();
                    line.AcctSeed__GL_Account_Variable_1__c = w.soLine.AcctSeedERP__GL_Account_Variable_1__c;
                    line.AcctSeed__GL_Account_Variable_2__c = w.soLine.AcctSeedERP__GL_Account_Variable_2__c;
                    line.AcctSeed__GL_Account_Variable_3__c = w.soLine.AcctSeedERP__GL_Account_Variable_3__c;
                    line.AcctSeed__GL_Account_Variable_4__c = w.soLine.AcctSeedERP__GL_Account_Variable_4__c;
                    line.AcctSeed__Hours_Units__c = w.billTypeVal;
                    line.AcctSeed__Opportunity_Product_Id__c = w.soLine.AcctSeedERP__Opportunity_Product_Id__c;
                    line.AcctSeed__Product__c = w.soLine.AcctSeedERP__Product__c;
                    line.AcctSeedERP__Sales_Order_Line__c = w.soLine.id;
                    line.AcctSeed__Rate__c = w.soLine.AcctSeedERP__Unit_Price__c;
                    line.Item_Description__c = w.soLine.Item_Description__c;
                    
                    lines.add(line);
                }
            }
            insert lines;
            
            PageReference page = new PageReference('/'+bill.id+'/e?retURL='+bill.id);
            page.setRedirect(true);
            
            return page;
            
        }catch(Exception ex){
            
            Database.rollback(sp);
            system.debug(ex.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Errors occured. Probably the associated Sales order has been closed without all shipments or bills being closed. Please change the status of Sales order to Open and try again.'));
            
        }
        
        return null;
    }
    public class Wrapper{
        
        public AcctSeedERP__Sales_Order_Line__c soLine {get; set;}
        public Decimal quantityReceived {get; set;}
        public Decimal quantityBilled {get; set;}
        public Decimal billedAmount {get; set;}
        public Decimal unbilledAmount {get; set;}
        public Decimal billTypeVal {get; set;}
        public Decimal BillAmount {get; set;}
        public Decimal BillAmountHidden {get; set;}
        
        public wrapper(AcctSeedERP__Sales_Order_Line__c line, Decimal qr, Decimal qb, Decimal bt, Decimal ut, Decimal btm){
            
            soLine = line;
            quantityReceived = qr;
            quantityBilled = qb;
            billedAmount = bt;
            unbilledAmount = ut;
            billTypeVal = null;
            BillAmount = btm;
            BillAmountHidden = 0;
        }
    }
}