public with sharing class CreateBillingFromCOController {

    public Id creditOrderId {get; set;}
    public AcctSeed__Billing__c billing {get; set;}
    public Credit_Order__c credit_order {get;set;}
    public Boolean firstBilling {get; set;}
    public List<LineWrapper> wrapper_lines {get; set;}
    public String selected_type {get; set;}
    public List<SelectOption> typeBillingOptions {get; set;}
    public Map<Id, LineWrapper> wrapper_map {get; set;}
    
    public String JsonMap{get{
        system.debug(JSON.serialize(wrapper_map));
        return JSON.serialize(wrapper_map);
    } set;} 

    public Map<Id, String> description_map {get; set;}
    public Map<Id, Decimal> billed_quantity_map {get; set;}

    public Boolean allIsPaid {get; set;}

    public CreateBillingFromCOController(ApexPages.StandardController std) {
        billing = new AcctSeed__Billing__c();
        wrapper_lines = new List<LineWrapper>();
        wrapper_map = new Map<Id, LineWrapper>();
        billed_quantity_map = new Map<Id, Decimal>();
        description_map = new Map<Id, String>();
        allIsPaid = false;
        creditOrderId = (Id)std.getId();
        typeBillingOptions = new List<SelectOption>();
        selected_type = 'Percent';

        credit_order = [SELECT Id, Name, Billing_City__c, Billing_Country__c, 
                    Billing_PostalCode__c, Billing_State__c, 
                    Shipping_Account__c, Shipping_Name__c,
                    Billing_Street__c, Customer__c,
                    Customer__r.AcctSeed__Billing_Contact__c, 
                    Customer__r.AcctSeed__Billing_Format__c,
                    Customer__r.AcctSeed__Billing_Days_Due__c, Billing_Name__c,
                    Opportunity__c, Shipping_City__c, Contact__c,
                    Shipping_Country__c, Shipping_PostalCode__c,
                    Shipping_Term__c, 
                    Shipping_State__c, Shipping_Street__c, Ledger__c,
                    Billing_Deposit__c, Billing_Terms_Name__c, 
                    Total_Amount__c FROM Credit_Order__c where id =:creditOrderId limit 1];

        getAlreadyBilledLines();
        prepareBilling();

        prepareBillingLines();
        
        typeBillingOptions.add(new SelectOption('Amount','Amount'));
        typeBillingOptions.add(new SelectOption('Percent','Percent'));
        typeBillingOptions.add(new SelectOption('Quantity','Quantity'));

        checkDoesAllPaid();
        if(allIsPaid){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Billing can not be created because all credit order lines has been billed.'));
        }
    }
    public void getAlreadyBilledLines(){
        List<AggregateResult> billed_quantities = [SELECT Credit_Order_Line__c col, 
                                                            SUM(AcctSeed__Hours_Units__c) quant
                                                            FROM AcctSeed__Billing_Line__c 
                                                            WHERE AcctSeed__Billing__r.Credit_Order__c=:creditOrderId
                                                            GROUP BY Credit_Order_Line__c];
        for(AggregateResult agr: billed_quantities){
            Id colId = (Id)agr.get('col');
            Decimal quantity = (Decimal)agr.get('quant');
            if(!billed_quantity_map.containsKey(colId)){
                billed_quantity_map.put(colId, quantity);
            }
        }
    }
    /*****************************************************************************************************
    *   @method       : prepareBilling
    *   @description  : Method set some required value of insertable Billing record on init
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void prepareBilling(){
        // Accounting Period
        Date dates = Date.today();
        String acctperiodDate = dates.year() + '-0' + dates.month();

        // get the current accounting period which is open
        list<AcctSeed__Accounting_Period__c> acctPeriod = [SELECT AcctSeed__Status__c, Name, Id, AcctSeed__End_Date__c, 
                                                        AcctSeed__Start_Date__c 
                                                        FROM AcctSeed__Accounting_Period__c where 
                                                        Name =:acctperiodDate limit 1];

        billing.AcctSeed__Date__c = Date.today();

        billing.AcctSeed__Accounting_Period__c = (!acctPeriod.IsEmpty()) ? acctPeriod[0].id : null;
        billing.AcctSeed__Due_Date2__c = 
            (credit_order.Customer__r.AcctSeed__Billing_Days_Due__c != null) ? 
            Date.today() + (Integer)credit_order.Customer__r.AcctSeed__Billing_Days_Due__c : Date.today();

        billing.AcctSeed__Billing_Format__c = credit_order.Customer__r.AcctSeed__Billing_Format__c;


        Integer firstbill = [select count() from AcctSeed__Billing__c where Credit_Order__c =: creditOrderId];

        firstBilling = firstbill == 0 ? true : false;
    }

    /*****************************************************************************************************
    *   @method       : prepareBillingLines
    *   @description  : Method creates wrappers for rendering
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void prepareBillingLines(){
        List<Credit_Order_Line__c> lines = [SELECT Id, 
                                                    Available_Quantity__c, 
                                                    Credit_Order__c,
                                                    GL_Account_Variable_1__c,
                                                    Product__c,
                                                    Product__r.Name,
                                                    Quantity_Ordered__c,
                                                    Alternate_Image_URL__c,
                                                    Size__c,
                                                    Total__c,
                                                    Unit_Price__c
                                                    FROM Credit_Order_Line__c 
                                                    WHERE Credit_Order__c=: creditOrderId ORDER BY Sort_Order__c ];
        system.debug('billed_quantity_map: '+JSON.serialize(billed_quantity_map));                                            
        for(Credit_Order_Line__c col:lines){

            // billed_quantity_map
            
            wrapper_lines.add(new LineWrapper(col,
                                                col.Product__r.Name, 
                                                col.Quantity_Ordered__c, 
                                                0,
                                                0,
                                                billed_quantity_map.containsKey(col.Id) ? billed_quantity_map.get(col.Id) : 0,
                                                col.Unit_Price__c,
                                                selected_type
                                                ));
        }
        for(LineWrapper lw:wrapper_lines){
            if(!wrapper_map.containsKey(lw.col.Id)){
                wrapper_map.put(lw.col.Id, lw);
            }
        }
        List<Credit_Order_Line__c> desc_lines = [SELECT Id, 
                                                    Description__c
                                                    FROM Credit_Order_Line__c 
                                                    WHERE Credit_Order__c=: creditOrderId ORDER BY Sort_Order__c ];
        for(Credit_Order_Line__c l:desc_lines){
            description_map.put(l.Id, l.Description__c);
        }
        
    }

    public void checkDoesAllPaid(){
        Integer counter = 0;
        for(LineWrapper lw:wrapper_lines){
            if(lw.billedQuantity == lw.orderedQuantity) counter++;
        }   
        allIsPaid = counter == wrapper_lines.size() ? true : false;
    }
    public void test(){
        system.debug(JSON.serialize(wrapper_lines));
    }

    /*****************************************************************************************************
    *   @method       : handleChangeType
    *   @description  : Change value of input depends on value selected type of pay. (Amount-Percent-Quan)
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void handleChangeType(){

        for(LineWrapper lw:wrapper_lines){
            
            if(selected_type == 'Amount'){
                lw.quantityToBill = (lw.unbilledQuantity * lw.unitPrice).setScale(2);
            }else if(selected_type == 'Percent'){
                lw.quantityToBill = ((lw.unbilledQuantity*100)/lw.orderedQuantity).setScale(2);
            }else if(selected_type == 'Quantity'){
                lw.quantityToBill = lw.unbilledQuantity.setScale(2);
            }
        }
    }


    public PageReference createBilling(){

        AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
        
        SavePoint sp = Database.setSavepoint();
        try{
            
            // construct accounting period  
            // Name = year-month
            Date enteredDate = billing.AcctSeed__Date__c;
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
            
            List<AcctSeed__Billing_Format__c> billingFormat = [SELECT Id, name FROM AcctSeed__Billing_Format__c where 
                                   AcctSeed__Type__c = 'Billing'];
            
            
            bill.AcctSeed__Status__c = 'Approved';
            bill.AcctSeed__PDF_Email_Status__c = 'Unsent';
            bill.Credit_Order__c = credit_order.id; 
            bill.AcctSeed__Date__c = billing.AcctSeed__Date__c;
            bill.AcctSeed__Due_Date2__c = billing.AcctSeed__Due_Date2__c;
            // bill.AcctSeed__Opportunity__c = credit_order.Opportunity__c;
            bill.AcctSeed__Customer__c = credit_order.Customer__c;
            bill.AcctSeed__Shipping_Contact__c = credit_order.Contact__c;
            
            bill.AcctSeed__Shipping_City__c = credit_order.Shipping_City__c;
            bill.AcctSeed__Shipping_Country__c = credit_order.Shipping_Country__c;
            bill.AcctSeed__Shipping_PostalCode__c = credit_order.Shipping_PostalCode__c;
            bill.AcctSeed__Shipping_State__c = credit_order.Shipping_State__c;
            bill.AcctSeed__Shipping_Street__c = credit_order.Shipping_Street__c;
            bill.AcctSeed__Billing_Terms_Name__c = credit_order.Shipping_Term__c;
            
            bill.AcctSeed__Billing_Contact__c = (credit_order.Billing_Name__c != null) ? credit_order.Billing_Name__c 
                                                                                       : credit_order.Customer__r.AcctSeed__Billing_Contact__c;

            bill.AcctSeed__Billing_Country__c = credit_order.Billing_Country__c;
            bill.AcctSeed__Billing_PostalCode__c = credit_order.Billing_PostalCode__c;
            bill.AcctSeed__Billing_State__c = credit_order.Billing_State__c;
            bill.AcctSeed__Billing_Street__c = credit_order.Billing_Street__c;
            bill.AcctSeed__Billing_City__c = credit_order.Billing_City__c;
            bill.AcctSeed__Accounting_Period__c = acctPeriod[0].id;
            bill.AcctSeed__Ledger__c = credit_order.Ledger__c;
            bill.Shipping_Account__c = credit_order.Shipping_Account__c;
            bill.Shipping_Name__c = credit_order.Shipping_Name__c;
            bill.AcctSeed__Billing_Format__c = billing.AcctSeed__Billing_Format__c;
            
            bill.Bill_Type__c = (selected_type == 'Percent') ? 'Percent' : 
                              ((selected_type == 'Quantity') ? 'Quantity' : 'Amount');
                
            insert bill;
            

            list<AcctSeed__Billing_Line__c> lines = new list<AcctSeed__Billing_Line__c>();
            // now insert the billing lines
            for(LineWrapper lw : wrapper_lines){
                
                if(lw.billedQuantity != lw.col.Quantity_Ordered__c && lw.quantityToBill > 0){
                    
                    Decimal quantity;
                    if(selected_type == 'Quantity'){
                        quantity = lw.quantityToBill;
                    }else if(selected_type == 'Percent'){
                        quantity = ((lw.quantityToBill*lw.orderedQuantity)/100).setScale(2);
                    }else if(selected_type == 'Amount'){
                        quantity = ((lw.orderedQuantity * lw.quantityToBill)/lw.totalPrice);
                    }


                    AcctSeed__Billing_Line__c line = new AcctSeed__Billing_Line__c();
                    line.AcctSeed__Billing__c = bill.id;
                    line.AcctSeed__Date__c = date.today();
                    line.AcctSeed__GL_Account_Variable_1__c = lw.col.GL_Account_Variable_1__c;
                    // line.AcctSeed__GL_Account_Variable_2__c = w.soLine.AcctSeedERP__GL_Account_Variable_2__c;
                    // line.AcctSeed__GL_Account_Variable_3__c = w.soLine.AcctSeedERP__GL_Account_Variable_3__c;
                    // line.AcctSeed__GL_Account_Variable_4__c = w.soLine.AcctSeedERP__GL_Account_Variable_4__c;
                    line.AcctSeed__Hours_Units__c = quantity;

                    line.AlternateImageURL__c = lw.col.Alternate_Image_URL__c;
                    //line.AcctSeed__Opportunity_Product_Id__c = w.soLine.AcctSeedERP__Opportunity_Product_Id__c;
                    line.AcctSeed__Product__c = lw.col.Product__c;
                    line.Credit_Order_Line__c = lw.col.id;
                    line.AcctSeed__Rate__c = lw.unitPrice*(-1);
                    line.Item_Description__c = description_map.get(lw.col.Id);
                    line.size_custom__c = lw.col.Size__c;
                    
                    lines.add(line);
                }
            }

            if(lines.size() > 0 ){
                insert lines;
                PageReference page = new PageReference('/'+bill.id+'/e?retURL='+bill.id);
                page.setRedirect(true);
                
                return page;
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 'All credit order lines has been already billed, and billing will not be created.'));
                Database.rollback(sp);
                PageReference page = new PageReference('/'+creditOrderId);
                page.setRedirect(true);
                return page;
            }
            
            
            
        }catch(Exception ex){
            
            Database.rollback(sp);
            system.debug('error 311: '+ex.getMessage());
            String errorMsg = ex.getMessage();

            string OnlyMsg = errorMsg.substringBetween(', ', ':');

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


    public class LineWrapper{
        public Credit_Order_Line__c col {get; set;}
        public String productName {get; set;}
        public Decimal orderedQuantity {get; set;}
        public Decimal allocatedQuantity {get; set;}
        public Decimal shippedQuantity {get; set;}
        public Decimal billedQuantity {get; set;}
        public Decimal unbilledQuantity {get; set;}
        public Decimal billedAmount {get; set;}
        public Decimal unbilledAmount {get; set;}
        public Decimal unitPrice {get; set;}
        public Decimal totalPrice {get; set;}
        public Decimal quantityToBill {get; set;} //Current field can be differen on Percent - Amount - Quantity
        public Decimal amountToBill {get; set;}
        public String selected_type {get; set;}
        public LineWrapper(Credit_Order_Line__c credit_line, String prName, Decimal orderedQ, Decimal allocatedQ, Decimal shippedQ, Decimal billedQ,  Decimal unitP, String selType){
            col = credit_line;
            productName = prName;
            orderedQuantity = orderedQ;
            allocatedQuantity = allocatedQ;
            shippedQuantity = shippedQ;
            billedQuantity = billedQ;
            unbilledQuantity = orderedQuantity - billedQuantity;
            unitPrice = unitP;
            billedAmount = (billedQuantity*unitPrice).setScale(2);
            totalPrice = (orderedQuantity*unitPrice).setScale(2);
            unbilledAmount = totalPrice-billedAmount;
            selected_type = selType;
            system.debug(selType);

            Decimal toBill = ((unbilledQuantity*100)/orderedQuantity).setScale(2);

            quantityToBill = toBill < 0 ? 0.00 : toBill;

            amountToBill = (unbilledQuantity * unitPrice).setScale(2);
        }
    }
}