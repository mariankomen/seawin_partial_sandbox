/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-28-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class CreatePurchaseOrderPageExtension {
    
    // Wrapper classes
    public list<ListSalesOrderLines> SalesOrderLinesListing {get; set;}
    public list<CreateDraft> Drafting {get; set;}
    
    // Sales Order
    public map<id, acctseederp__sales_order_line__c> lslmap {get; set;}
    private Id salesOrderId;
    public acctseederp__sales_order__c so {get; set;}
    
    public Integer totalitems {get; set;}
    
    // Sales Order Lines
    // private Set<Id> SalesOrderLineIds = new Set<Id>();
    private List<AcctSeedERP__Sales_Order_Line__c> SalesOrderLineItems = new List<AcctSeedERP__Sales_Order_Line__c>();
    
    public Integer SalesOrderLineItemsAllocated {get; set;}
    public Integer SalesOrderLineItemsCreated {get; set;}
    public Integer SalesOrderLineItemsMaximum {get; set;}
    
    public AcctSeed__Billing_Format__c PurchaseOrderFormat {get; set;}
    
    public Boolean visible {
        
        get{
            return this.visible;
        }
        set;
    }
    public boolean showdraft {get; set;}
    public boolean allcreated {get; set;}
    
    public CreatePurchaseOrderPageExtension(ApexPages.StandardController std) {
        SalesOrderLineItemsAllocated = 0;
        SalesOrderLineItemsCreated = 0;
        SalesOrderLineItemsMaximum = 0;
        allcreated = false;
        showdraft = false;
        visible = false;
        Drafting = new list<CreateDraft>();
        PurchaseOrderFormat = null;
        //salesOrderId = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'));
        salesOrderId = std.getId();
        // salesOrderId = 'a1HEa0000001Mo5MAE';
        // get the sales order
        so = [select id, acctseederp__ledger__c, name, customer_s_eta__c,  
              AcctSeedERP__shipping_street__c,GL_Account_Variable_1__c, 
              AcctSeedERP__shipping_city__c,project__c,RecordType.Name,
              AcctSeedERP__shipping_state__c,Shipping_Account__c, Shipping_Name__c, 
              AcctSeedERP__shipping_country__c,AcctseedERP__Opportunity__r.Shipping_Account__c,
              AcctSeedeRP__Opportunity__r.Shipping_Name__c,
              AcctSeedERP__shipping_postalcode__c,AcctSeedERP__opportunity__c,
              AcctSeedERP__Customer__c, Contact__c, AcctSeedERP__Customer__r.Contact_Person__c
              from acctseederp__sales_order__c where id =:salesOrderId];
        
        System.debug('so Is: ' + so);
        PurchaseOrderFormat = [SELECT Id, Name FROM AcctSeed__Billing_Format__c where name ='Default Purchase Order'];
        
        //fetching sales order line items of type PURCHASED and RAW MATERIAL
        totalitems = [SELECT count() FROM AcctSeedERP__Sales_Order_Line__c 
                      WHERE AcctSeedERP__Sales_Order__c =:salesOrderId AND
                      (AcctSeedERP__Product__r.AcctSeed__Inventory_Type__c = 'Purchased' OR
                       AcctSeedERP__Product__r.AcctSeed__Inventory_Type__c = 'Raw Material')
                     ];
        

        /* Get all SalesOrderLines from selected Sales Order */

        SalesOrderLineItems = [SELECT Id, Name, AcctSeedERP__Product__r.Name,AcctSeedERP__Unit_Price__c,
                               AcctSeedERP__Product__r.Description,AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c,
                               AcctSeedERP__Comment__c, AcctSeedERP__Product__c, AcctSeedERP_Description__c,SortOrder__c,
                               AcctSeedERP__Product__r.AcctSeed__Unit_Cost__c, size__c, Quantity_Allocated_formula__c,
                               Quantity_Shipped_Formula__c,AcctSeedERP__Quantity_Ordered__c,AcctSeedERP__Quantity_Needed__c,
                               acctseederp__total__c, productcode__c,Quantity_Needed_Formula__c,Available_Quantity__c,
                               Allow_Product_Description_Change__c,
                               AcctSeedERP__Product__r.Allow_Product_Description_Change__c,
                               AcctSeederp__GL_Account_Variable_1__c, AlternateImageURL__c,
                               AcctSeederp__GL_Account_Variable_2__c, 
                               AcctSeederp__GL_Account_Variable_3__c, 
                               AcctSeederp__GL_Account_Variable_4__c, POL_Quantity__c, QuantityFormula__c,
                               Kit_Children__c
                               FROM AcctSeedERP__Sales_Order_Line__c 
                               WHERE AcctSeedERP__Sales_Order__c =: salesOrderId
                               AND IsAllocated__c != 1 and isdeleted = false AND
                               (AcctSeedERP__Product__r.AcctSeed__Inventory_Type__c = 'Purchased' OR
                                AcctSeedERP__Product__r.AcctSeed__Inventory_Type__c = 'Raw Material')
                               order by sortorder__c,name,createddate asc];
        
        
        SalesOrderLineItemsAllocated = [SELECT count()
                                        FROM AcctSeedERP__Sales_Order_Line__c 
                                        WHERE AcctSeedERP__Sales_Order__c =: salesOrderId AND 
                                        IsAllocated__c = 1];
        
        SalesOrderLineItemsCreated = [SELECT count()
                                      FROM AcctSeedERP__Sales_Order_Line__c 
                                      WHERE AcctSeedERP__Sales_Order__c =: salesOrderId AND 
                                      (POL_Quantity__c != null and POL_Quantity__c != 0)];
        
        SalesOrderLineItemsMaximum = [SELECT count()
                                      FROM AcctSeedERP__Sales_Order_Line__c 
                                      WHERE AcctSeedERP__Sales_Order__c =: salesOrderId AND 
                                      IsMaximum__c = 1];
        
        system.debug('SalesOrderLineItemsSalesOrderLineItems: '+JSON.serialize(SalesOrderLineItems));
        
        if(totalitems == SalesOrderLineItemsMaximum){
            
            allcreated = true;
        }
        
        if(SalesOrderLineItems.size() > 0){
            system.debug('Size = ' + SalesOrderLineItems.size());
            SalesOrderLinesListing = new list<ListSalesOrderLines>();
            
            for(AcctSeedERP__Sales_Order_Line__c sol : SalesOrderLineItems){
                if(sol.AcctSeedERP__Quantity_Ordered__c != sol.POL_Quantity__c)
                    SalesOrderLinesListing.add(new ListSalesOrderLines(
                        sol, new Product2(Vendor__c = sol.AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c)));
                // sol.do_not_delete__c = sol.AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c;
                
            }
            
            
            visible = true; 
            
        }else{          
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'To create a purchase order:<br/>'+
                                                       '<ul><li>There must be sales order lines.</li>'+
                                                       '<li>The sales order lines must not be allocated.</li>'));
            
        }
    }
    /*******************************************************************
* 						Insert Purchase Orders to get their id     *
*******************************************************************/
    private Map<Id, AcctSeedERP__Purchase_Order__c> InsertPurchaseOrders() {
        
        // vendor key and purchase order
        Map<Id, AcctSeedERP__Purchase_Order__c> VendorKeyAndPurchaseOrder = new Map<Id, AcctSeedERP__Purchase_Order__c>();
        
        // purchase order
        list<AcctSeedERP__Purchase_Order__c> PurchaseOrderList = new list<AcctSeedERP__Purchase_Order__c>();
        
        for (CreateDraft d : Drafting) {
            
            String city = null;
            String street = null;
            string country = null;
            string postalcode = null;
            string state = null;
            string companyname = null;
            string contactname = null;
            
            if(d.PurchaseOrder.acctseederp__type__c == 'Standard'){
                // get the SeaWin company's details
                list<Account> org = [SELECT Id, Name, billingStreet, billingCity, 
                                     billingState, billingPostalCode, billingCountry, contact_person__c 
                                     FROM Account where id='0011I00000EYHFy' ]; // org default account
                if(!org.isEmpty()){
                    //companyname = org[0].id;
                    //contactname = org[0].contact_person__c;
                    city = org[0].billingcity;
                    street = org[0].billingStreet;
                    country = org[0].billingCountry;
                    postalcode = org[0].billingPostalCode;
                    state = org[0].billingState; 
                }                   
            }else if(d.PurchaseOrder.acctseederp__type__c == 'Drop Shipment'){
                // set what is on sales order
                //companyname = so.AcctSeedERP__Customer__c;
                //contactname = so.Contact__c;
                city = so.AcctSeedERP__Shipping_City__c;
                street = so.AcctSeedERP__Shipping_Street__c;
                country = so.AcctSeedERP__Shipping_Country__c;
                postalcode = so.AcctSeedERP__Shipping_PostalCode__c;
                state = so.AcctSeedERP__Shipping_State__c;
            }
            
            d.PurchaseOrder.AcctSeedERP__Shipping_Company__c = (so.shipping_Account__c != null)?so.shipping_Account__c:
            ((so.AcctSeedERP__Opportunity__r.Shipping_Account__c != null)?so.AcctSeedERP__Opportunity__r.Shipping_Account__c:null);
                
                d.PurchaseOrder.AcctSeedERP__Shipping_Contact__c = (so.shipping_Name__c != null)?so.shipping_Name__c:
            ((so.AcctSeedERP__Opportunity__r.shipping_Name__c != null)?so.AcctSeedERP__Opportunity__r.shipping_Name__c:null);
                
                
                // d.PurchaseOrder.AcctSeedERP__Type__c = // this is already set
                
                //Get record type from PO as SO have 
                RecordType recType = [select Id, Name, SobjectType 
                                      FROM RecordType 
                                      where Name =: so.RecordType.Name and SobjectType = 'AcctSeedERP__Purchase_Order__c'];
            
            // Assign SO record type matching to PO record type
            d.PurchaseOrder.RecordTypeId = recType.Id;
            d.PurchaseOrder.AcctSeedERP__Shipping_City__c = city;
            d.PurchaseOrder.AcctSeedERP__Shipping_Country__c = country;
            d.PurchaseOrder.AcctSeedERP__Shipping_Postal_Code__c = postalcode;
            d.PurchaseOrder.AcctSeedERP__Shipping_State__c = state;
            d.PurchaseOrder.AcctSeedERP__Shipping_Street__c = street;
            
            PurchaseOrderList.add(d.PurchaseOrder);
        }
        
        if(PurchaseOrderList.size() > 0) {
            
            // Insert has been put into do-while loop to avoid "Unable to Lock Row" exception that happens
            // sometimes not always
            
            Boolean PurchaseOrderExceptionOccured = true;
            
            do{
                try{
                    
                    insert PurchaseOrderList;
                    PurchaseOrderExceptionOccured = false;
                    
                }catch(Exception ex){
                    System.debug('ex is: ' + ex.getMessage());
                }                 
            }while(PurchaseOrderExceptionOccured);
            
            
            for(AcctSeedERP__Purchase_Order__c PurchaseOrderWithId : PurchaseOrderList){
                
                VendorKeyAndPurchaseOrder.put(PurchaseOrderWithId.AcctSeedERP__Vendor__c, PurchaseOrderWithId);
            }
        }
        
        return VendorKeyAndPurchaseOrder;
    }
    /*******************************************************************
* 						Make Temporary Purchase Orders		       *
*******************************************************************/
    private Map<Id, AcctSeedERP__Purchase_Order__c> MakePurchaseOrders() {
        
        Map<Id, AcctSeedERP__Purchase_Order__c> purchaseOrders = new Map<Id, AcctSeedERP__Purchase_Order__c>();
        

        //Allow product change field is here !! SalesOrderLinesListing
        for (ListSalesOrderLines wp : SalesOrderLinesListing) {
            if(wp.selected){
                if(!purchaseOrders.containsKey(wp.Product.Vendor__c)) {
                    id contactperson = null;
                    id accountperson = null;
                    // get the vendor's contact if it exists 
                    if(wp.Product.Vendor__c != null){
                        list<account> acctlist = [select id,contact_person__c 
                                                  from account where id=: wp.Product.Vendor__c limit 1];  
                        if(!acctlist.isempty()){
                            accountperson = acctlist[0].id;
                            contactperson = acctlist[0].contact_person__c;   
                        }
                    }
                    
                    purchaseOrders.put(wp.Product.Vendor__c,
                                       new AcctSeedERP__Purchase_Order__c(AcctSeedERP__Vendor__c = accountperson,
                                                                          AcctSeedERP__Vendor_Contact__c = contactperson,
                                                                          AcctSeedERP__Purchase_Order_Format__c = PurchaseOrderFormat.id,
                                                                          AcctSeedERP__Ledger__c = so.AcctSeedERP__Ledger__c,
                                                                          customer_s_eta__c = so.Customer_s_ETA__c,
                                                                          Sales_order__c = so.id,
                                                                          GL_Account_Variable_1__c = so.GL_Account_Variable_1__c,
                                                                          Opportunity_readonly__c = so.AcctSeedERP__opportunity__c,
                                                                          Project__c = so.Project__c));
                }
            }
        }
        
        return purchaseOrders;
    }
    
    /*******************************************************************
* 						Back Button							       *
*******************************************************************/
    public PageReference back() {        
        Schema.DescribeSObjectResult result = AcctSeedERP__Sales_Order__c.SObjectType.getDescribe();
        //result.getKeyPrefix();
        PageReference retPage = new PageReference('/' + salesOrderId);
        retPage.setRedirect(true);
        return retPage;
    }
    
    /*******************************************************************
* 						Create Draft                			   *
******************************************************************/
    public PageReference draft(){
        
        Boolean VendorError = false;
        for (ListSalesOrderLines wp : SalesOrderLinesListing) {
            if(wp.selected){
                if(wp.Product.Vendor__c == null) {
                    
                    if(!VendorError) VendorError = true;
                    wp.Product.Vendor__c.addError('Vendor cannot be empty.');
                    
                }
            }
        }
        
        if(VendorError){
            return null;
        }
        
        Drafting = new list<CreateDraft>();
        Map<Id, AcctSeedERP__Purchase_Order__c> allOrders = this.MakePurchaseOrders();
        
        lslmap = new map<id, acctseederp__sales_order_line__c>();
        
        map<acctseederp__purchase_order__c, list<powrapper>> orderLinesMap = 
            new map<acctseederp__purchase_order__c, list<powrapper>>(); 
        
        for(id keyIs : allOrders.keyset()){
            
            list<powrapper> lineslist = new list<powrapper>();
            acctseederp__purchase_order__c order = new acctseederp__purchase_order__c();
            
            // we are making a copy of sales order lines here so we can use them in this functionality, 
            // as objects are pass by reference, so by doing
            // this we are avoiding changing the sales order lines.
            system.debug('SalesOrderLinesListingSalesOrderLinesListingSalesOrderLinesListing: '+JSON.serialize(SalesOrderLinesListing));
            for(ListSalesOrderLines wp : SalesOrderLinesListing){
                if(wp.Product.Vendor__c == keyIs){
                    order = allOrders.get(wp.Product.Vendor__c);
                    if(wp.selected){
                        
                        AcctSeedERP__Sales_Order_Line__c newsol = new AcctSeedERP__Sales_Order_Line__c();
                        
                        Product2 prod = new Product2();
                        
                        prod.name = wp.SalesOrderLine.AcctSeedERP__Product__r.name;
                        prod.AcctSeed__Unit_Cost__c = wp.SalesOrderLine.AcctSeedERP__Product__r.AcctSeed__Unit_Cost__c;
                        prod.ProductCode = wp.SalesOrderLine.ProductCode__c;
                        Decimal POLQuantity = (wp.SalesOrderLine.POL_Quantity__c >= 
                                               wp.SalesOrderLine.Quantity_Allocated_Formula__c)?
                            wp.SalesOrderLine.QuantityFormula__c - wp.SalesOrderLine.POL_Quantity__c:
                        wp.SalesOrderLine.Quantity_Needed_Formula__c;
                        newsol.Id = wp.SalesOrderLine.id; 
                        newsol.AcctSeedERP__Comment__c = wp.SalesOrderLine.AcctSeedERP__Comment__c; 
                        newsol.AcctSeedERP__GL_Account_Variable_1__c = wp.SalesOrderLine.AcctSeedERP__GL_Account_Variable_1__c; 
                        newsol.AcctSeedERP__GL_Account_Variable_2__c = wp.SalesOrderLine.AcctSeedERP__GL_Account_Variable_2__c; 
                        newsol.AcctSeedERP__GL_Account_Variable_3__c = wp.SalesOrderLine.AcctSeedERP__GL_Account_Variable_3__c; 
                        newsol.AcctSeedERP__GL_Account_Variable_4__c = wp.SalesOrderLine.AcctSeedERP__GL_Account_Variable_4__c; 
                        newsol.AcctSeedERP__Product__c = wp.SalesOrderLine.AcctSeedERP__Product__c;  
                        newsol.AcctSeedERP__Unit_Price__c = wp.SalesOrderLine.AcctSeedERP__Unit_Price__c; 
                        newsol.AcctSeedERP__Quantity_Ordered__c = POLQuantity;
                        newsol.Allow_Product_Description_Change__c = wp.SalesOrderLine.AcctSeedERP__Product__r.Allow_Product_Description_Change__c;
                        // Line Added
                        newsol.AlternateImageURL__c = wp.SalesOrderLine.AlternateImageURL__c;
                        
                        
                        newsol.AcctSeedERP_Description__c = wp.SalesOrderLine.AcctSeedERP_Description__c; 
                        newsol.Size__c = wp.SalesOrderLine.Size__c; 
                        newsol.SortOrder__c = wp.SalesOrderLine.SortOrder__c;
                        
                        lslmap.put(wp.SalesOrderLine.id, wp.SalesOrderLine);
                        
                        lineslist.add(new powrapper(newsol, wp.SalesOrderLine.id, 
                                                    prod,wp.SalesOrderLine.Quantity_Shipped_Formula__c, 
                                                    wp.SalesOrderLine.Quantity_Allocated_Formula__c,
                                                    POLQuantity,wp.SalesOrderLine.Available_Quantity__c)); 
                    }
                }
                
            }

            orderLinesMap.put(order , lineslist);
        }
        
        Drafting = new list<CreateDraft>();
        
        if(!orderLinesMap.IsEmpty()){
            
            system.debug('orderLinesMap:: '+JSON.serialize(orderLinesMap));
            system.debug('allOrders.values(): '+JSON.serialize(allOrders.values()));
            // create list of CreateDraft
            for(AcctSeedERP__Purchase_Order__c pr : allOrders.values()){
                account acct = null;
                acct = [select name from account where id =: pr.AcctSeedERP__Vendor__c];
                
                // get the purchase order from the map along with the list of sales order lines
                list<powrapper> listIs = orderLinesMap.get(pr);
                
                if(listIs == null) continue;
                
                Drafting.add(new CreateDraft(pr, listIs, acct.name));
            }
            
            showdraft = true;
        }
        system.debug('Drafting::: '+JSON.serialize(Drafting));
        return null;
    }
    public PageReference create() {
        PageReference retPage = null;
        try{
            Boolean QuantityError = false;
            for(CreateDraft wpd: Drafting) {
                for(powrapper powl : wpd.plw){
                    if(powl.lsline.AcctSeedERP__Quantity_Ordered__c > powl.needed){
                        powl.lsline.AcctSeedERP__Quantity_Ordered__c.addError(
                            'Quantity can not be more than Quantity needed.');
                        if(!QuantityError) QuantityError = true;
                        // break;
                    }
                }
            }
            
            if(QuantityError){
                return null;
            }
            
            //create purchase orders;
            Map<Id, AcctSeedERP__Purchase_Order__c> purchaseOrderMap = this.InsertPurchaseOrders();
            
            List<AcctSeedERP__Purchase_Order__c> MapValues = purchaseOrderMap.values();
            
            if(purchaseOrderMap.size() == 1){
                retPage = new PageReference('/' + MapValues[0].id);
                retPage.setRedirect(true); 
                
            }else{
                
                String PurchaseOrderIdString = '';
                
                integer k = 0;
                for(AcctSeedERP__Purchase_Order__c orders : MapValues){
                    
                    PurchaseOrderIdString += '&id' + k + '=' + orders.id;
                    k++;
                    
                }
                
                retPage = new PageReference('/apex/NewPurchaseOrdersPage?sfdc.tabName=01r1I000000QsNf&count=' +purchaseOrderMap.size()+ '' + PurchaseOrderIdString);
                retPage.setRedirect(true);
            }
            if(purchaseOrderMap.size() > 0) {
                
                List <AcctSeedERP__Purchase_Order_Line__c> purchaseOrderLines = new List <AcctSeedERP__Purchase_Order_Line__c>();
                list<acctseederp__sales_order_line__c> SalesOrderLineListFORids
                    = new list<acctseederp__sales_order_line__c>();
                AcctSeedERP__Purchase_Order__c temPurchaseOrder = null;
                
                for(CreateDraft wpd: Drafting) {
                    account acct = null;
                    acct = [select id from account where name =:wpd.Vendor limit 1];
                    
                    if(acct != null){
                        temPurchaseOrder = purchaseOrderMap.get(acct.id);
                    }
                    Integer sortNumber = 1;
                    for(powrapper powr : wpd.plw){
                        
                        AcctSeedERP__Purchase_Order_Line__c pol = new AcctSeedERP__Purchase_Order_Line__c(AcctSeedERP__Comment__c = powr.lsline.AcctSeedERP__Comment__c,
                                                                                                          Description__c = powr.lsline.AcctSeedERP_Description__c,
                                                                                                          AcctSeedERP__Product__c = powr.lsline.AcctSeedERP__Product__c,
                                                                                                          AcctSeedERP__Quantity__c = powr.lsline.AcctSeedERP__Quantity_Ordered__c,
                                                                                                          AlternateImageURL__c = powr.lsline.AlternateImageURL__c,
                                                                                                          Sort_Order__c = sortNumber,
                                                                                                          AcctSeedERP__Unit_Price__c = powr.product.AcctSeed__Unit_Cost__c,
                                                                                                          AcctSeedERP__Purchase_Order__c = temPurchaseOrder.Id,
                                                                                                          size__c = powr.lsline.Size__c,
                                                                                                          AcctSeederp__GL_Account_Variable_1__c = wpd.PurchaseOrder.GL_Account_Variable_1__c, 
                                                                                                          AcctSeederp__GL_Account_Variable_2__c = powr.lsline.AcctSeederp__GL_Account_Variable_2__c, 
                                                                                                          AcctSeederp__GL_Account_Variable_3__c = powr.lsline.AcctSeederp__GL_Account_Variable_3__c, 
                                                                                                          AcctSeederp__GL_Account_Variable_4__c = powr.lsline.AcctSeederp__GL_Account_Variable_4__c,
                                                                                                          Sales_order_line__c = powr.lsline.id 
                                                                                                         );
                        purchaseOrderLines.add(pol);
                        acctseederp__sales_order_line__c lslinetemp = lslmap.get(powr.soid);
                        
                        if(lslinetemp == null) continue;
                        
                        SalesOrderLineListFORids.add(lslinetemp);
                        sortNumber++;
                    }
                }
                if(purchaseOrderLines.size() > 0){ 
                    
                    // Insert has been put into do-while loop to avoid "Unable to Lock Row" exception that happens
                    // sometimes not always
                    
                    insert purchaseOrderLines;
                    
                    // update sales order line
                    // get all the sales order lines from the list Drafting
                    list<acctseederp__sales_order_line__c> sl = new list<acctseederp__sales_order_line__c>();
                    map<id,acctseederp__sales_order_line__c> slMap = new map<id,acctseederp__sales_order_line__c>();
                    
                    for(Integer i=0; i<purchaseOrderLines.size(); i++){
                        
                        SalesOrderLineListFORids[i].AcctSeedERP__Purchase_Order_Line__c = purchaseOrderLines[i].Id;
                        
                        sl.add(SalesOrderLineListFORids[i]);
                        slMap.put(SalesOrderLineListFORids[i].id, SalesOrderLineListFORids[i]);
                    }
                    
                    //update selSalesOrderLineItems;  
                    updateSalesOrderLines(JSON.serialize(sl));                                      
                    
                }
            }
            
        }catch(Exception exc){
            String errorMsg = exc.getMessage();

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
        return retPage;
    }
    
    //updating purchase order line Id on sales order line
    //@future
    public static void updateSalesOrderLines(String paramList) {
        List<AcctSeedERP__Sales_Order_Line__c> salesOrderLineItems = (List<AcctSeedERP__Sales_Order_Line__c>)JSON.deserialize(paramList, List<AcctSeedERP__Sales_Order_Line__c>.class);
        update salesOrderLineItems;
        
    }
    
    public class ListSalesOrderLines{
        
        public acctseederp__sales_order_line__c SalesOrderLine {get; set;}
        public product2 Product {get;set;}
        public Boolean selected {get;set;}
        
        ListSalesOrderLines(acctseederp__sales_order_line__c s, product2 p){
            
            SalesOrderLine = s;
            Product = p;
            selected = (s.POL_Quantity__c == s.QuantityFormula__c) ? false : true;
        }
    }
    
    public class CreateDraft{
        
        public acctseederp__purchase_order__c PurchaseOrder {get; set;}
        public list<powrapper> plw {get; set;}
        public string Vendor {get; set;}
        
        CreateDraft(acctseederp__purchase_order__c p, list<powrapper> s, string v){
            
            PurchaseOrder = p;
            plw = s;
            Vendor = v;
        }
    }
    
    public class powrapper {
        
        public AcctSeedERP__Sales_Order_Line__c lsline {get; set;}
        public id soid {get; set;}
        public Product2 product {get; set;}
        public Decimal shipped {get; set;}
        public Decimal allocated {get; set;}
        public Decimal needed {get; set;}
        public Decimal stock {get; set;}
        
        powrapper(AcctSeedERP__Sales_Order_Line__c s, id sid, Product2 p, Decimal spd, Decimal all, Decimal ned, Decimal stk){
            
            lsline = s;
            soid = sid;
            product = p;
            shipped = spd;
            allocated = all;
            needed = ned;
            stock = stk;
        }
    }
}