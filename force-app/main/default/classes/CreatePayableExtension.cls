public class CreatePayableExtension {
    public Boolean isLines {get; set;}
    public Boolean AlreadyPaid {get; set;}
    
    public String PayType {get; set;}
    public String depositbill {get; set;}
    public Decimal Amount {get{
        if(Amount == null){
            
            Amount = 0;
        }
        return Amount;
    } set;}
    
    public list<Wrapper> polWrapper {get; set;}
    public map<id, AcctSeedERP__Purchase_Order_Line__c> linesMap {get; set;}
    
    public AcctSeed__Account_Payable__c temp {get; set;} // temp record for date fields
    public AcctSeedERP__Purchase_Order__c poRecord {get; set;}
    
    public AcctSeed__Account_Payable_Line__c paylineTemp {get; set;}
    
    public CreatePayableExtension(ApexPages.StandardController std){
        
        paylineTemp = new AcctSeed__Account_Payable_Line__c();
        temp = new AcctSeed__Account_Payable__c();
        poRecord = new AcctSeedERP__Purchase_Order__c();
        polWrapper = new list<Wrapper>();
        linesMap = new map<id, AcctSeedERP__Purchase_Order_Line__c>();
        temp.AcctSeed__Date__c = Date.today(); // issue date
        // due date
        AlreadyPaid = false;
        
        // get the so id
        Id poId = (Id)std.getId();
        
        poRecord = [SELECT Id, Name, AcctSeedERP__Order_Date__c, 
                    AcctSeedERP__Purchase_Order_Format__c, 
                    AcctSeedERP__Shipping_City__c, 
                    AcctSeedERP__Shipping_Company__c, 
                    AcctSeedERP__Shipping_Company__r.AcctSeed__Default_Expense_Gl_Account__c,
                    AcctSeedERP__Vendor__r.AcctSeed__Account_Payable_Terms__c,
                    AcctSeedERP__Shipping_Contact__c, 
                    AcctSeedERP__Shipping_Country__c, 
                    AcctSeedERP__Shipping_Postal_Code__c, 
                    AcctSeedERP__Shipping_State__c, 
                    AcctSeedERP__Shipping_Street__c, 
                    AcctSeedERP__Status__c, AcctSeedERP__Type__c, 
                    AcctSeedERP__Vendor_City__c, AcctSeedERP__Vendor_Contact__c, 
                    AcctSeedERP__Vendor_Country__c, AcctSeedERP__Vendor_Postal_Code__c, 
                    AcctSeedERP__Vendor_State__c, AcctSeedERP__Vendor_Street__c, 
                    AcctSeedERP__Vendor__c,AcctSeedERP__Vendor__r.AcctSeed__Default_Expense_Gl_Account__c, 
                    AcctSeedERP__Ledger__c, Customer_s_ETA__c, 
                    Sales_Order__c, Shipped_Date__c, Expected_Delivery__c 
                    FROM AcctSeedERP__Purchase_Order__c where id =:poId limit 1];
            
        temp.AcctSeed__Due_Date__c = Date.today().addDays((Integer)((poRecord.AcctSeedERP__Vendor__r.AcctSeed__Account_Payable_Terms__c != null) ? poRecord.AcctSeedERP__Vendor__r.AcctSeed__Account_Payable_Terms__c: 0)); 
        
        //paylineTemp.AcctSeed__Expense_GL_Account__c = 
        //poRecord.AcctSeedERP__Vendor__r.AcctSeed__Default_Expense_Gl_Account__c;
        
        // get the lines
        list<AcctSeedERP__Purchase_Order_Line__c> lines = [SELECT Id, Name, AcctSeedERP__Purchase_Order__c, 
                                                           AcctSeedERP__GL_Account_Variable_1__c, 
                                                           AcctSeedERP__GL_Account_Variable_2__c, 
                                                           AcctSeedERP__GL_Account_Variable_3__c, 
                                                           AcctSeedERP__GL_Account_Variable_4__c, 
                                                           AcctSeedERP__Product__c,AcctSeedERP__Product__r.name, 
                                                           AcctSeedERP__Quantity_Unreceived__c, 
                                                           AcctSeedERP__Quantity__c, AcctSeedERP__Total__c, 
                                                           AcctSeedERP__Unit_Price__c, AcctSeedERP__Quantity_Received__c, 
                                                           Description__c, Sort_Order__c, Quantity_Received_Formula__c, 
                                                           Total_Price__c, Size__c, Quantity_Unreceived_Formula__c, 
                                                           Product_Code__c, Quantity_Formula__c, Sales_Order_Line__c, 
                                                           Purchase_Price__c, 
                                                           AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c FROM 
                                                           AcctSeedERP__Purchase_Order_Line__c where 
                                                           AcctSeedERP__Purchase_Order__c =: poId 
                                                           order by sort_order__c,AcctSeedERP__Product__r.name,
                                                           createddate asc];
        
        if(lines.IsEmpty()){
            
            isLines = false;
        }else{
            
            isLines = true;
            
            linesMap.putAll(lines);
            
            // make a map of the associated billing lines
            list<AcctSeed__Account_Payable_Line__c> plines = new list<AcctSeed__Account_Payable_Line__c>(
                [
                    SELECT Id, Name, AcctSeed__Account_Payable__c, AcctSeed__Amount__c, 
                    AcctSeed__Date__c, AcctSeed__Quantity__c, AcctSeedERP__Purchase_Order_Line__c 
                    FROM AcctSeed__Account_Payable_Line__c where 
                    AcctSeedERP__Purchase_Order_Line__c in:linesMap.keyset()
                    and AcctSeed__Account_Payable__r.AcctSeedERP__Purchase_Order__c =:poId
                    and AcctSeed__Account_Payable__r.AcctSeed__Type__c = 'Invoice'
                ]           
            );
            map<id, String> plinesMap = new map<id, String>();
            if(!plines.IsEmpty()){
                // make a map with key as sol id and value as bol
                for(AcctSeed__Account_Payable_Line__c apol: plines){
                    
                    // key = 'quantity:' + 'billedamount'
                    
                    String val = '';
                    Decimal Quantity = apol.AcctSeed__Quantity__c;
                    Decimal Total = apol.AcctSeed__Amount__c;
                    
                    if(plinesMap.containsKey(apol.AcctSeedERP__Purchase_Order_Line__c)){
                        
                        String[] valuesArray = plinesMap.get(apol.AcctSeedERP__Purchase_Order_Line__c).split(':');
                        
                        Quantity += Decimal.valueOf(valuesArray[0]);
                        Total += Decimal.valueOf(valuesArray[1]);
                        
                        val = Quantity + ':' + Total;
                        
                        plinesMap.put(apol.AcctSeedERP__Purchase_Order_Line__c, val);
                        
                    }else{
                        val = Quantity + ':' + Total;
                        plinesMap.put(apol.AcctSeedERP__Purchase_Order_Line__c, val);
                    }
                    
                }
            }
            Integer paidItems = 0;
            for(AcctSeedERP__Purchase_Order_Line__c line : lines){
                system.debug('The blinesMap size is: ' + plinesMap.size());
                // get the paying record for the current pol to fill paidAmount and UnpaidAmount
                String bStr = plinesMap.get(line.id);
                String[] bstring = null;
                if(bStr != null){
                    bstring = plinesMap.get(line.id).split(':');
                }
                
                Decimal PaidAmount = 0;
                Decimal UnPaidAmount = 0;
                Decimal QuantityBilled = 0;
                Decimal PayAmount = 0;
                
                if(bstring != null){
                    PaidAmount = Decimal.valueOf(bstring[1]);
                    UnPaidAmount = 0;
                    //QuantityBilled = Decimal.valueOf(bstring[0]);
                    QuantityBilled = (line.AcctSeedERP__Unit_Price__c > 0) ? 
                        PaidAmount / line.AcctSeedERP__Unit_Price__c : line.AcctSeedERP__Quantity__c;

                    if(QuantityBilled > line.AcctSeedERP__Quantity__c ||
                    PaidAmount >= line.AcctSeedERP__Total__c) QuantityBilled = line.AcctSeedERP__Quantity__c;
                        
                    QuantityBilled = QuantityBilled.setScale(+6);
                     
                    
                    // remove from linesMap if all has been billed for the sol
                    if(QuantityBilled < line.AcctSeedERP__Quantity__c){
                        UnPaidAmount = line.AcctSeedERP__Total__c - PaidAmount;
                    }else{
                        
                        paidItems++;
                    } 
                }else{
                    
                    UnPaidAmount = line.AcctSeedERP__Total__c;
                }
                polWrapper.add(new Wrapper(line, QuantityBilled, PaidAmount, UnPaidAmount, PayAmount, 0)); 
            }
            
            if(paidItems == lines.size()){
                
                AlreadyPaid = true;
            }
        }
        
    }
    public PageReference createPayable(){
        
        /*
if(paylineTemp.AcctSeed__Expense_GL_Account__c == null || paylineTemp.AcctSeed__Expense_GL_Account__r.acctseed__Bank__c == true){
if(paylineTemp.AcctSeed__Expense_GL_Account__c == null){
paylineTemp.AcctSeed__Expense_GL_Account__c.addError('Expense GL Account is required.');
}
return null;
}
*/
        
        AcctSeed__Account_Payable__c payable = new AcctSeed__Account_Payable__c();
        
        //list<AcctSeed__Billing_Format__c> format = [select id from AcctSeed__Billing_Format__c where Name = 'Default Billing Product' limit 1];
        
        SavePoint sp = Database.setSavepoint();
        try{
            
            // construct accounting period  
            // Name = year-month
            Date enteredDate = temp.AcctSeed__date__c;
            String acctperiodDate = enteredDate.year() + ((enteredDate.month() < 10) ? '-0' : '-') + enteredDate.month();
            // get the current accounting period which is open
            list<AcctSeed__Accounting_Period__c> acctPeriod = [SELECT AcctSeed__Status__c, Name, Id, AcctSeed__End_Date__c, 
                                                               AcctSeed__Start_Date__c 
                                                               FROM AcctSeed__Accounting_Period__c where 
                                                               Name =:acctperiodDate and AcctSeed__Status__c = 'Open' limit 1];
            
            if(acctPeriod.IsEmpty()){
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 
                                                           'No Accounting Period has been set up for this Issue/Payable Date'+ 
                                                           ' or the Accounting Period status is closed. Please first set up'+ 
                                                           ' Accounting Period for this date in Accounting Seed.'));
                return null;
            }
            
            
            payable.AcctSeed__Accounting_Period__c = (!acctPeriod.IsEmpty()) ? acctPeriod[0].id : null; 
            //payable.AcctSeed__Contact__c = poRecord.AcctSeedERP__Vendor_Contact__c; 
            payable.AcctSeed__Date__c  = temp.AcctSeed__date__c;
            payable.AcctSeed__Due_Date__c = temp.AcctSeed__Due_Date__c;
            payable.AcctSeed__Status__c = 'Approved';
            payable.AcctSeed__Vendor__c = poRecord.AcctSeedERP__Vendor__c;
            payable.AcctSeed__Ledger__c = poRecord.AcctSeedERP__Ledger__c;
            payable.AcctSeedERP__Purchase_Order__c = poRecord.id;
            
            payable.AcctSeed__Payee_Reference__c = poRecord.Name + ' - ' + System.Now().formatLong();
            
            payable.Pay_Type__c = (payType == 'percent') ? 'Percent' : 
            ((payType == 'quantity') ? 'Quantity' : 'Amount');  
                
                
                insert payable;

            list<AcctSeed__Account_Payable_Line__c> paylines = new list<AcctSeed__Account_Payable_Line__c>();
            // now insert the billing lines
            for(Wrapper w : polWrapper){
                
                if(w.quantityPaid != w.poLine.AcctSeedERP__Quantity__c){
                    
                   Decimal quantity = (w.poLine.AcctSeedERP__Unit_Price__c == 0) ? w.poLine.AcctSeedERP__Quantity__c : 
                    w.PayAmountHidden / w.poLine.AcctSeedERP__Unit_Price__c;

                    if(quantity == 0) quantity = w.poLine.AcctSeedERP__Quantity__c;

                    AcctSeed__Account_Payable_Line__c payline = new AcctSeed__Account_Payable_Line__c();
                    
                    payline.AcctSeed__Account_Payable__c = payable.id;
                    payline.AcctSeed__Amount__c = w.PayAmountHidden;
                    payline.AcctSeed__Date__c = date.today();
                    payline.AcctSeed__Expense_GL_Account__c = w.poLine.AcctSeedERP__Product__r.AcctSeed__Expense_GL_Account__c;
                    payline.AcctSeed__GL_Account_Variable_1__c = w.poLine.AcctSeedERP__GL_Account_Variable_1__c;
                    payline.AcctSeed__GL_Account_Variable_2__c = w.poLine.AcctSeedERP__GL_Account_Variable_2__c;
                    payline.AcctSeed__GL_Account_Variable_3__c = w.poLine.AcctSeedERP__GL_Account_Variable_3__c;
                    payline.AcctSeed__GL_Account_Variable_4__c = w.poLine.AcctSeedERP__GL_Account_Variable_4__c;
                    payline.AcctSeed__Product__c = w.poLine.AcctSeedERP__Product__c;
                    payline.AcctSeed__Quantity__c = quantity;
                    payline.AcctSeedERP__Purchase_Order_Line__c = w.poLine.id;
                    payline.Item_description__c = w.poline.Description__c;
                    
                    paylines.add(payline);
                    
                }              
            }
            insert paylines;
            
            PageReference page = new PageReference('/'+payable.id+'/e?retURL='+payable.id);
            page.setRedirect(true);
            
            return page;
        }catch(Exception ex){
            
            Database.rollback(sp);
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Fatal, 'A Database error has occured. Please try again.'));
            system.debug(ex.getMessage());
            
        }
        
        return null;
    }
    public class Wrapper{
        
        
        public AcctSeedERP__Purchase_Order_Line__c poLine {get; set;}
        public Decimal quantityPaid {get; set;}
        public Decimal paidAmount {get; set;}
        public Decimal unpaidAmount {get; set;}
        public Decimal payTypeVal {get; set;}
        public Decimal PayAmount {get; set;}
        public Decimal PayAmountHidden {get; set;}
        
        public wrapper(AcctSeedERP__Purchase_Order_Line__c line, Decimal qb, Decimal bt, 
                       Decimal ut, Decimal btm, decimal hiddenmount){
            
            poLine = line;
            quantityPaid = qb;
            paidAmount = bt;
            unpaidAmount = ut;
            payTypeVal = (qb == line.AcctSeedERP__Quantity__c) ? null : 100;
            payAmount = btm;
            payAmountHidden = hiddenmount;
        }
    }
    
}