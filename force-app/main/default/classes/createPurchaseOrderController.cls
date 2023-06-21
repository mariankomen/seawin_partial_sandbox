public with sharing class createPurchaseOrderController {
    
    // Wrapper classes
    public list<ListSalesOrderLines> SalesOrderLinesListing {get; set;}
    public list<CreateDraft> Drafting {get; set;}
    
    // Sales Order
    private Id salesOrderId;
    public acctseederp__sales_order__c so {get; set;}
    
    public Integer totalitems {get; set;}
    
    // Sales Order Lines
    private Set<Id> SalesOrderLineIds = new Set<Id>();
    private List<AcctSeedERP__Sales_Order_Line__c> SalesOrderLineItems = new List<AcctSeedERP__Sales_Order_Line__c>();
    
    public AcctSeed__Billing_Format__c PurchaseOrderFormat {get; set;}
    
    public Boolean visible {
        
        get{
            
            return this.visible;
        }
        set;
    }
    public boolean showdraft {get; set;}
    public boolean showdraftError {get; set;}
    
    public createPurchaseOrderController() {
        showdraft = false;
        visible = false;
        Drafting = new list<CreateDraft>();
        PurchaseOrderFormat = null;
        salesOrderId = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'));
        
        // get the sales order
        so = [select id, acctseederp__ledger__c, name, customer_s_eta__c,  
              AcctSeedERP__shipping_street__c, 
              AcctSeedERP__shipping_city__c,
              AcctSeedERP__shipping_state__c, 
              AcctSeedERP__shipping_country__c, 
              AcctSeedERP__shipping_postalcode__c,
              AcctSeedERP__Customer__c, AcctSeedERP__Customer__r.Contact_Person__c
              from acctseederp__sales_order__c where id =:salesOrderId];
        
        PurchaseOrderFormat = [SELECT Id, Name FROM AcctSeed__Billing_Format__c where name ='Default Purchase Order'];
        
        integer count = Integer.valueOf(ApexPages.currentPage().getParameters().get('count'));
        
        //getting selected sales order line ids from url of page.
        for(integer i = 0; i < count; i++){
            Id sub = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'+i));
            SalesOrderLineIds.add(sub); 
        }
        
        //fetching sales order line items
        totalitems = [SELECT count() FROM AcctSeedERP__Sales_Order_Line__c WHERE Id IN :SalesOrderLineIds];
        SalesOrderLineItems = [SELECT Id, Name, AcctSeedERP__Product__r.Name,AcctSeedERP__Unit_Price__c,
                               AcctSeedERP__Product__r.Description,AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c,
                               AcctSeedERP__Comment__c, AcctSeedERP__Product__c, AcctSeedERP_Description__c,SortOrder__c,
                               AcctSeedERP__Product__r.AcctSeed__Unit_Cost__c, size__c, Quantity_Allocated_formula__c,
                               Quantity_Shipped_Formula__c,AcctSeedERP__Quantity_Ordered__c,AcctSeedERP__Quantity_Needed__c,
                               acctseederp__total__c, productcode__c,
                               AcctSeederp__GL_Account_Variable_1__c, 
                               AcctSeederp__GL_Account_Variable_2__c, 
                               AcctSeederp__GL_Account_Variable_3__c, 
                               AcctSeederp__GL_Account_Variable_4__c
                               FROM AcctSeedERP__Sales_Order_Line__c 
                               WHERE Id IN :SalesOrderLineIds AND AcctSeedERP__Purchase_Order_Line__c = null
                               AND ((AcctSeedERP__Product__r.AcctSeed__Inventory_Type__c = 'Raw Material' 
                                     AND AcctSeedERP__Product__r.AcctSeed__Inventory_Product__c = true) 
                                    OR AcctSeedERP__Product__r.AcctSeed__Inventory_Type__c = 'purchased')
                               AND IsAllocated__c != 1 order by sortorder__c,name,createddate asc];
        
        
        
        if(SalesOrderLineItems.size() > 0){

            if(SalesOrderLineItems.size() < totalitems){
                
                // Show the error as Info message
                Integer minusItems = totalitems - SalesOrderLineItems.size();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,minusItems + ' item(s) were not added. Please make sure:<br/>'+
                                                           '<ul><li>The sales order lines must not be associated with existing purchase order lines.</li>'+
                                                           '<li>The sales order lines must not be allocated.</li>'+
                                                           '<li>The products on the sales order lines must have:'+
                                                           '<ul><li>Inventory Product checkbox checked.</li>'+
                                                           '<li>Inventory Type value set to "Purchased" or "Raw material"</li></ul></li></ul>'));                
            }
            system.debug('Size = ' + SalesOrderLineItems.size());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 
                                                       'You must include a value for vendor for every line you want to create a purchase order.'));
            SalesOrderLinesListing = new list<ListSalesOrderLines>();
            
            for(AcctSeedERP__Sales_Order_Line__c sol : SalesOrderLineItems){
                
                SalesOrderLinesListing.add(new ListSalesOrderLines(sol, new Product2(AcctSeedERP__Default_Vendor__c = sol.AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c)));
                // sol.do_not_delete__c = sol.AcctSeedERP__Product__r.AcctSeedERP__Default_Vendor__c;
                
            }
            
            
            visible = true; 
            
        }else{          
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'To create a purchase order:<br/>'+
                                                       '<ul><li>The sales order lines must not be associated with existing purchase order lines.</li>'+
                                                       '<li>The sales order lines must not be allocated.</li>'+
                                                       '<li>The products on the sales order lines must have:'+
                                                       '<ul><li>Inventory Product checkbox checked.</li>'+
                                                       '<li>Inventory Type value set to "Purchased" or "Raw material"</li></ul></li></ul>'));
            
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
                    companyname = org[0].id;
                    contactname = org[0].contact_person__c;
                    city = org[0].billingcity;
                    street = org[0].billingStreet;
                    country = org[0].billingCountry;
                    postalcode = org[0].billingPostalCode;
                    state = org[0].billingState; 
                }                   
            }else if(d.PurchaseOrder.acctseederp__type__c == 'Drop Shipment'){
                // set what is on sales order
                companyname = so.AcctSeedERP__Customer__c;
                contactname = so.AcctSeedERP__Customer__r.Contact_Person__c;
                city = so.AcctSeedERP__Shipping_City__c;
                street = so.AcctSeedERP__Shipping_Street__c;
                country = so.AcctSeedERP__Shipping_Country__c;
                postalcode = so.AcctSeedERP__Shipping_PostalCode__c;
                state = so.AcctSeedERP__Shipping_State__c;
            }
            
            
            // d.PurchaseOrder.AcctSeedERP__Type__c = // this is already set
            d.PurchaseOrder.AcctSeedERP__Shipping_City__c = city;
            d.PurchaseOrder.AcctSeedERP__Shipping_Company__c = companyname;
            d.PurchaseOrder.AcctSeedERP__Shipping_Contact__c = contactname;
            d.PurchaseOrder.AcctSeedERP__Shipping_Country__c = country;
            d.PurchaseOrder.AcctSeedERP__Shipping_Postal_Code__c = postalcode;
            d.PurchaseOrder.AcctSeedERP__Shipping_State__c = state;
            d.PurchaseOrder.AcctSeedERP__Shipping_Street__c = street;
            
            PurchaseOrderList.add(d.PurchaseOrder);
        }
        
        if(PurchaseOrderList.size() > 0) {
            insert PurchaseOrderList;
            
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
        
        for (ListSalesOrderLines wp : SalesOrderLinesListing) {
            if(!purchaseOrders.containsKey(wp.Product.AcctSeedERP__Default_Vendor__c)) {
                id contactperson = null;
                id accountperson = null;
                // get the vendor's contact if it exists 
                if(wp.Product.AcctSeedERP__Default_Vendor__c != null){
                    list<account> acctlist = [select id,contact_person__c 
                                              from account where id=: wp.Product.AcctSeedERP__Default_Vendor__c limit 1];  
                    if(!acctlist.isempty()){
                        accountperson = acctlist[0].id;
                        contactperson = acctlist[0].contact_person__c;   
                    }
                }
                
                
                purchaseOrders.put(wp.Product.AcctSeedERP__Default_Vendor__c,
                                   new AcctSeedERP__Purchase_Order__c(AcctSeedERP__Vendor__c = accountperson,
                                                                      AcctSeedERP__Vendor_Contact__c = contactperson,
                                                                      AcctSeedERP__Purchase_Order_Format__c = PurchaseOrderFormat.id,
                                                                      AcctSeedERP__Ledger__c = so.AcctSeedERP__Ledger__c,
                                                                      customer_s_eta__c = so.Customer_s_ETA__c,
                                                                      Sales_order__c = so.id));
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
    public void draft(){
        Drafting = new list<CreateDraft>();
        Map<Id, AcctSeedERP__Purchase_Order__c> allOrders = this.MakePurchaseOrders();
        
        map<acctseederp__purchase_order__c, list<acctseederp__sales_order_line__c>> orderLinesMap = 
            new map<acctseederp__purchase_order__c, list<acctseederp__sales_order_line__c>>(); 
        
        for(id keyIs : allOrders.keyset()){
            
            list<acctseederp__sales_order_line__c> lineslist = new list<acctseederp__sales_order_line__c>();
            acctseederp__purchase_order__c order = new acctseederp__purchase_order__c();
            
            for(ListSalesOrderLines wp : SalesOrderLinesListing){
                if(wp.Product.AcctSeedERP__Default_Vendor__c == keyIs){
                    order = allOrders.get(wp.Product.AcctSeedERP__Default_Vendor__c);
                    
                    lineslist.add(wp.SalesOrderLine);
                }
                
            }
            orderLinesMap.put(order , lineslist.deepClone(true, true, true));
        }
        
        Drafting = new list<CreateDraft>();
        
        if(!orderLinesMap.IsEmpty()){
            
            // create list of CreateDraft
            for(AcctSeedERP__Purchase_Order__c pr : allOrders.values()){
                account acct = null;
                acct = [select name from account where id =: pr.AcctSeedERP__Vendor__c];
                
                // get the purchase order from the map along with the list of sales order lines
                list<acctseederp__sales_order_line__c> listIs = orderLinesMap.get(pr);
                
                if(listIs == null) continue;
                
                Drafting.add(new CreateDraft(pr, listIs, acct.name));
            }
            
            showdraft = true;
            
            showdraftError = true;
        }
    }
    public PageReference create() {
        PageReference retPage = null;
        try{
            Boolean QuantityError = false;
            for(CreateDraft wpd: Drafting) {
                for(acctseederp__sales_order_line__c sol : wpd.SalesOrderLineList){
                    if(sol.AcctSeedERP__Quantity_Ordered__c < sol.AcctSeedERP__Quantity_Needed__c){
                        sol.AcctSeedERP__Quantity_Ordered__c.addError(
                            'Quantity cannot be less than quantity needed');
                        if(!QuantityError) QuantityError = true;
                        // break;
                    }
                }
            }
            
            if(QuantityError){
                showdraftError = false;
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
                    for(acctseederp__sales_order_line__c sol : wpd.SalesOrderLineList){
                        
                        
                        AcctSeedERP__Purchase_Order_Line__c pol = new AcctSeedERP__Purchase_Order_Line__c(AcctSeedERP__Comment__c = sol.AcctSeedERP__Comment__c,
                                                                                                          Description__c = sol.AcctSeedERP_Description__c,
                                                                                                          AcctSeedERP__Product__c = sol.AcctSeedERP__Product__c,
                                                                                                          AcctSeedERP__Quantity__c = sol.AcctSeedERP__Quantity_Ordered__c,
                                                                                                          Sort_Order__c = sol.SortOrder__c,
                                                                                                          AcctSeedERP__Unit_Price__c = sol.AcctSeedERP__Product__r.AcctSeed__Unit_Cost__c,
                                                                                                          AcctSeedERP__Purchase_Order__c = temPurchaseOrder.Id,
                                                                                                          size__c = sol.Size__c,
                                                                                                          AcctSeederp__GL_Account_Variable_1__c = sol.AcctSeederp__GL_Account_Variable_1__c, 
                                                                                                          AcctSeederp__GL_Account_Variable_2__c = sol.AcctSeederp__GL_Account_Variable_2__c, 
                                                                                                          AcctSeederp__GL_Account_Variable_3__c = sol.AcctSeederp__GL_Account_Variable_3__c, 
                                                                                                          AcctSeederp__GL_Account_Variable_4__c = sol.AcctSeederp__GL_Account_Variable_4__c
                                                                                                         );
                        purchaseOrderLines.add(pol);
                        
                        SalesOrderLineListFORids.add(sol);
                        
                    }
                }
                if(purchaseOrderLines.size() > 0){                    
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
            showdraftError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, exc.getMessage()));            
            system.debug(exc.getMessage());
        }
        return retPage;
    }
    
    //updating purchase order line Id on sales order line
    @future
    public static void updateSalesOrderLines(String paramList) {
        List<AcctSeedERP__Sales_Order_Line__c> salesOrderLineItems = (List<AcctSeedERP__Sales_Order_Line__c>)JSON.deserialize(paramList, List<AcctSeedERP__Sales_Order_Line__c>.class);
        update salesOrderLineItems;
        
    }
    
    public class ListSalesOrderLines{
        
        public acctseederp__sales_order_line__c SalesOrderLine {get; set;}
        public product2 Product {get;set;}
        
        ListSalesOrderLines(acctseederp__sales_order_line__c s, product2 p){
            
            SalesOrderLine = s;
            Product = p;
        }
    }
    public class CreateDraft{
        
        public acctseederp__purchase_order__c PurchaseOrder {get; set;}
        public list<acctseederp__sales_order_line__c> SalesOrderLineList {get; set;}
        public string Vendor {get; set;}
        
        CreateDraft(acctseederp__purchase_order__c p, list<acctseederp__sales_order_line__c> s, string v){
            
            PurchaseOrder = p;
            SalesOrderLineList = s;
            Vendor = v;
        }
    }
}