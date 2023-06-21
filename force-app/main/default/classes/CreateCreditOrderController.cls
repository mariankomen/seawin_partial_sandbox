public with sharing class CreateCreditOrderController {

    public Id soId {get; set;}

    public AcctSeedERP__Sales_Order__c sales_order {get; set;}
    public List<AcctSeedERP__Sales_Order_Line__c> so_lines {get; set;}
    public List<LinesWrapper> wrapper_lines {get; set;}
    public Boolean checkAllValues {get; set;}
    public Map<Id, Decimal> ordered_map {get; set;}
    public Map<Id, Decimal> shippedMap {get;set;}
    private List<AcctSeed__Ledger__c> ledgers {get; set;}
    public String selectedledger {get; set;}
    private Boolean hasSelectedLines { get{
        Integer counter = 0;
        for(LinesWrapper lw:wrapper_lines){
            if(lw.selected) counter++;
        }
        return counter > 0 ? true : false;
    } set;}



    public CreateCreditOrderController() {
        checkAllValues = true;
        wrapper_lines = new List<LinesWrapper>();
        ordered_map = new Map<Id, Decimal>();
        shippedMap = new Map<Id, Decimal>();
        soId = ApexPages.currentPage().getParameters().get('id');

        String so_soql = 'SELECT ' + getSOFields() + ' FROM AcctSeedERP__Sales_Order__c WHERE Id=:soId';
        String sol_soql = 'SELECT ' + getSOLFields() + ' FROM AcctSeedERP__Sales_Order_Line__c WHERE AcctSeedERP__Sales_Order__c=:soId ORDER BY SortOrder__c';

        sales_order = (AcctSeedERP__Sales_Order__c)Database.query(so_soql);
        so_lines = (List<AcctSeedERP__Sales_Order_Line__c>)Database.query(sol_soql);
        checkAlreadyOrderedQuantity();
        checkAlreadyShippedQuantity();

        for(AcctSeedERP__Sales_Order_Line__c line:so_lines){
            Decimal available = line.AcctSeedERP__Quantity_Ordered__c - ordered_map.get(line.Id);
            Boolean isFullyApplied = line.AcctSeedERP__Quantity_Ordered__c > ordered_map.get(line.Id) ? false : true; 
            wrapper_lines.add(new LinesWrapper(line, available, isFullyApplied, shippedMap.get(line.Id)));
        }
        system.debug(JSON.serialize(wrapper_lines));

    }

    /*****************************************************************************************************
    *   @method       : getLedgerList
    *   @description  : Method return list select options of Ledgers
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public List<SelectOption> getLedgerList() {
        
        ledgers = [select id, name from AcctSeed__Ledger__c];
        
        List<SelectOption> options = new List<SelectOption>();
        
        for(AcctSeed__Ledger__c l : ledgers){
            options.add(new SelectOption(l.id,l.name));
        }
        
        return options;
    }

    /*****************************************************************************************************
    *   @method       : processCheckChange
    *   @description  : Master select method
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void processCheckChange(){
        for(LinesWrapper lw:wrapper_lines){
            lw.selected = lw.isFullyApplied ? false : checkAllValues;
        }
    }

    public void checkAlreadyShippedQuantity(){
        List<AggregateResult> total_shipped_on_credit_order = [SELECT SUM(Need_to_Shipp_Quantity__c) quantity, 
                                                                Sales_Order_Line__c pr 
                                                                FROM Credit_Order_Line__c 
                                                                WHERE Sales_Order__c=:soId
                                                                GROUP BY Sales_Order_Line__c];
        for(AggregateResult agr: total_shipped_on_credit_order){
            shippedMap.put((Id)agr.get('pr'), (Decimal)agr.get('quantity'));
        }
        //Need to add all products to map, if product has not been credited, we set item with quantity 0
        for(AcctSeedERP__Sales_Order_Line__c sol:so_lines){
            if(!shippedMap.containsKey(sol.Id)){
                shippedMap.put(sol.Id, 0);
            }
        }
    }
    /*****************************************************************************************************
    *   @method       : checkAlreadyOrderedQuantity
    *   @description  : Method checks quantity of sol which already applied to credit order
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void checkAlreadyOrderedQuantity(){
        List<AggregateResult> total_on_credit_order = [SELECT SUM(Quantity_Ordered__c) quantity, 
                                                                Sales_Order_Line__c pr 
                                                                FROM Credit_Order_Line__c 
                                                                WHERE Sales_Order__c=:soId
                                                                GROUP BY Sales_Order_Line__c];
        for(AggregateResult agr: total_on_credit_order){
            ordered_map.put((Id)agr.get('pr'), (Decimal)agr.get('quantity'));
        }
        //Need to add all products to map, if product has not been credited, we set item with quantity 0
        for(AcctSeedERP__Sales_Order_Line__c sol:so_lines){
            if(!ordered_map.containsKey(sol.Id)){
                ordered_map.put(sol.Id, 0);
            }
        }

        // system.debug('ordered_map: '+JSON.serialize(ordered_map));
        
    }

    /*****************************************************************************************************
    *   @method       : checkAllApplied
    *   @description  : Method check does all lines are applied
    *   @return       : PageReference
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public Boolean checkAllApplied(){
        
        Integer counter = 0;
        for(AcctSeedERP__Sales_Order_Line__c sol: so_lines){
            if(sol.AcctSeedERP__Quantity_Ordered__c <= ordered_map.get(sol.Id)){
                counter++;
            }
        }
        return counter == so_lines.size() ? true : false;
    }

    /*****************************************************************************************************
    *   @method       : saveCreating
    *   @description  : Method which creates credit order lines of selected SOL's
    *   @return       : PageReference
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public PageReference saveCreating(){
        
        if(hasSelectedLines){
            Credit_Order__c credit_order = createCreditOrder();

            List<Credit_Order_Line__c> order_lines = new List<Credit_Order_Line__c>();

            for(LinesWrapper lw:wrapper_lines){
                if(lw.selected && lw.sol.AcctSeedERP__Quantity_Ordered__c > 0){
                    AcctSeedERP__Sales_Order_Line__c line = lw.sol;

                    Credit_Order_Line__c credit_line = new Credit_Order_Line__c();
                    credit_line.Alternate_Image_URL__c = line.AlternateImageURL__c;
                    credit_line.Comment__c = line.AcctSeedERP__Comment__c;
                    credit_line.Credit_Card_Fee__c = line.Credit_Card_Fee__c;
                    credit_line.Credit_Order__c = credit_order.Id;
                    credit_line.Description__c = line.AcctSeedERP_Description__c;
                    credit_line.GL_Account_Variable_1__c = line.AcctSeedERP__GL_Account_Variable_1__c;
                    credit_line.Product__c = line.AcctSeedERP__Product__c;
                    credit_line.Quantity_Ordered__c = lw.available_quantity;
                    credit_line.Size__c = line.Size__c;
                    credit_line.Sort_Order__c = line.SortOrder__c;
                    credit_line.Unit_Price__c = line.AcctSeedERP__Unit_Price__c;
                    credit_line.Sales_Order_Line__c = line.Id;
                    credit_line.Sales_Order__c = line.AcctSeedERP__Sales_Order__c;
                    credit_line.Need_to_Shipp_Quantity__c = lw.shippingQuantity;
        
                    order_lines.add(credit_line);
                }
                
            }
            insert order_lines;

            PageReference ref = new PageReference('/'+credit_order.Id);
            return ref;
        }else{
            system.debug('checkAllApplied(): '+checkAllApplied());
            if(checkAllApplied()){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL, 'All Sales Order Lines already have beed applied to Credit Order(s)'));     
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL, 'Credit Order must have at least 1 associated Credit Order Line.'));     
            }
                   

            PageReference ref = null;
            return ref;
        }
        
        
    }

    /*****************************************************************************************************
    *   @method       : createCreditOrder
    *   @description  : Method which inserts new Credit Order record
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public Credit_Order__c createCreditOrder(){
        Credit_Order__c order = new Credit_Order__c();
        order.Billing_Name__c = sales_order.Billing_Name__c;
        order.Billing_Account__c = sales_order.Billing_Account__c;
        order.Billing_City__c = sales_order.AcctSeedERP__Billing_City__c;
        order.Billing_Country__c = sales_order.AcctSeedERP__Billing_Country__c;
        order.Billing_PostalCode__c = sales_order.AcctSeedERP__Billing_PostalCode__c;
        order.Billing_State__c = sales_order.AcctSeedERP__Billing_State__c;
        order.Billing_Street__c = sales_order.AcctSeedERP__Billing_Street__c;
        order.Contact__c = sales_order.Contact__c;

        order.Shipping_City__c = sales_order.AcctSeedERP__Shipping_City__c;
        order.Shipping_Country__c = sales_order.AcctSeedERP__Shipping_Country__c;
        order.Shipping_State__c = sales_order.AcctSeedERP__Shipping_State__c;
        order.Shipping_Street__c = sales_order.AcctSeedERP__Shipping_Street__c;
        order.Shipping_PostalCode__c = sales_order.AcctSeedERP__Shipping_PostalCode__c;
        order.Status__c = 'Open';
        order.Stage__c = 'Initial';
        order.Price_Level__c = sales_order.Price_Level__c;
        order.Shipping_Account__c = sales_order.Shipping_Account__c;
        order.Shipping_Name__c = sales_order.Shipping_Name__c;

        order.Billing_Deposit__c = sales_order.Billing_Deposit__c;
        order.Billing_Terms_Name__c = sales_order.Billing_Terms_Name__c;

        order.Customer_s_ETA__c = sales_order.Customer_s_ETA__c;
        order.Note__c = sales_order.Notes__c;
        order.Shipping_Term__c = sales_order.Shipping_Term__c;
        order.Special_Instruction__c = sales_order.Special_Instruction__c;
        order.Project__c = sales_order.Project__c;
        order.Approval_Date__c = sales_order.Approval_Date__c;

        order.Customer__c = sales_order.AcctSeedERP__Customer__c;
        order.GL_Account_Variable_1__c = sales_order.GL_Account_Variable_1__c;
        order.Manufacturer_Rep__c = sales_order.Manufacturer_Rep__c;
        order.Opportunity__c = sales_order.AcctSeedERP__Opportunity__c;
        order.Referral_Rep__c = sales_order.Referral_Sales_Rep__c;
        order.Sales_Order__c = sales_order.Id;
        order.Sales_Rep_Team__c = sales_order.Sales_Rep_O__c;
        order.Specified_Rep__c = sales_order.Specified_Rep__c;
        order.Ledger__c = selectedledger;

        insert order;

        return order;
    }



    /*****************************************************************************************************
    *   @method       : getSOLFields
    *   @description  : Method return string of comma separated Sales Order Line object fields
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public String getSOLFields(){
        String fields = '';
        Schema.DescribeSObjectResult r = AcctSeedERP__Sales_Order_Line__c.sObjectType.getDescribe();

        for(String apiName : r.fields.getMap().keySet()){
            fields += apiName + ', ';
        }
        fields += 'AcctSeedERP__Product__r.Name, AcctSeedERP__Product__r.Allow_Product_Description_Change__c';
        //fields = fields.removeEnd(', ');
        return fields;
    }

    /*****************************************************************************************************
    *   @method       : getSOFields
    *   @description  : Method return string of comma separated Sales Order object fields
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public String getSOFields(){
        String fields = '';
        Schema.DescribeSObjectResult r = AcctSeedERP__Sales_Order__c.sObjectType.getDescribe();

        for(String apiName : r.fields.getMap().keySet()){
            fields += apiName + ', ';
        }
        // fields += 'AcctSeedERP__Product__r.Name, AcctSeedERP__Product__r.Allow_Product_Description_Change__c';
        fields = fields.removeEnd(', ');
        return fields;
    }



    /*****************************************************************************************************
    *   @method       : rerenderAction
    *   @description  : Simple method, used in rerender action onchange quantity of product
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void rerenderAction(){
        Integer i = 0;
    }

    public class LinesWrapper{
        public Boolean selected {get; set;}
        public AcctSeedERP__Sales_Order_Line__c sol {get; set;}
        public Decimal shippingQuantity {get;set;}
        public Decimal available_quantity {get; set;}
        public Boolean isFullyApplied {get; set;} // If quantity on col = sol
        public Decimal availableForShippingQuantity {get;set;}
        public LinesWrapper(AcctSeedERP__Sales_Order_Line__c sol_item, Decimal av_q, Boolean isFullyQ, Decimal totalShippedOnCO){
            selected = true;
            sol = sol_item;
            available_quantity = av_q;
            isFullyApplied = isFullyQ;
            shippingQuantity = 0;
            availableForShippingQuantity = sol.AcctSeedERP__Quantity_Shipped__c - totalShippedOnCO;
        }
    }

}