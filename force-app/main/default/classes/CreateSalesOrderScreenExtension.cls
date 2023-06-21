public class CreateSalesOrderScreenExtension {
    public map<id, list<decimal>> ibMap { get; set; }

    public opportunity oppty {get; set;}
    public Boolean hasKits {get; set;}
    public Boolean showError {get{
        if(showError == null) showError = false;
        return showError;
    } set;}
    private List<AcctSeed__Ledger__c> ledgers {get; set;}
    
    public String selectedledger {get; set;}
    public Id selectedFormat {get; set;}
    
    public List<LInesWrapper> linesList {get; set;}
    
    public Id USArecordTypeId {get; set;}
    public Id ChinaRecordTypeId {get; set;}
    public string salesrepid {get; set;}
    public string ownerid {get; set;}
    public string validKeys {get; set;}
    public set<id> ProductIds {get; set;}

    public map<id, List<AcctSeed__Product_Part__c>> KitMap {get; set;}
    public List<AcctSeed__Product_Part__c> emptyList {get; set;}
    public List<childrenWrapper> childrens_data {get; set;}


    public List<SelectOption> getLedgerList() {
        
        ledgers = [select id, name from AcctSeed__Ledger__c];
        
        List<SelectOption> options = new List<SelectOption>();
        
        for(AcctSeed__Ledger__c l : ledgers){
            options.add(new SelectOption(l.id,l.name));
        }
        
        return options;
    }
    public Boolean hasSalesOrder {get; set;}

    public Id changedQuantityId {get; set;}

    /*****************************************************************************************************
    *   @method      : CreateSalesOrderScreenExtension
    *   @description : class constructor, check does opportunity has sales order
    *   @return      : constructor
    *   @author      : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public CreateSalesOrderScreenExtension(ApexPages.StandardController std){
        KitMap = new map<id, List<AcctSeed__Product_Part__c>>();
        emptyList = new List<Acctseed__Product_Part__c>();

        hasKits = false;
        ibMap = new Map<id, list<decimal>>();

        ledgers = [select id, name from AcctSeed__Ledger__c];
        ProductIds = new set<id>();
        Id OppId = std.getId();

        salesrepid = ApexPages.currentPage().getParameters().get('salesrepid');
        ownerid = ApexPages.currentPage().getParameters().get('ownerid');
        
        List<String> fieldsList = new List<String>{'Id', 'StageName', 'Account.Name', 'ContactPerson__c','ContactPerson__r.name','LeadSource',
            'Account.Acctseed__Billing_Contact__r.name', 'recordtype.name','recordtypeId',
            'Description', 'Note__c', 'deliver_by__c','Shipping_Term__c', 'Account.billingStreet', 
            'Account.billingCity', 'Account.billingState', 'account.billingPostalCode', 'submittal_submitted_date__c',
            'Account.billingcountry', 'shipping_street__c', 'shipping_city__c', 'shipping_state__c', 
            'shipping_postalcode__c', 'shipping_country__c', 'submittal_approval_date__c',
            'Contract_Date__c','Financial_Clearance_Date__c','PO_Number__c', 'PO_Date__c',
            'GL_Account_Variable_1__c', 'shipping_name__c', 'shipping_account__c', 'Project__c','sales_rep_o__c',
            'Manufacturer_Rep__c','OwnerId', 'Account.Manufacture_Representative__c','Price_Level__c', 'Sales_rep_o__r.name','Approve_Date__c', 'Referral_Sales_Rep__c',
            'Billing_Deposit__c', 'Billing_Terms_Name__c', 'Specified_Rep__c'
                };  
                 
        String fields = String.join(fieldsList, ',');
        
        list<AcctSeed__Billing_Format__c> formatIs = [select id from AcctSeed__Billing_Format__c where 
                                                      AcctSeed__Type__c = 'Sales Order' limit 1];
        
        if(!formatIs.isEmpty()){
            selectedFormat = formatIs[0].id;
        }
        
        oppty = Database.Query('Select ' + fields + ' From Opportunity where id=:OppId Limit 1');
        
        list<AcctSeedERP__Sales_Order__c> soExists = [select id, name from AcctSeedERP__Sales_Order__c 
                                                      where AcctSeedERP__Opportunity__c =:oppty.id];
        if(!soExists.IsEmpty()){
            hasSalesOrder = true;
        }        
    }
   

    /*****************************************************************************************************
    *   @method      : TryCreate
    *   @description : initial page method, get list of OLI and related childrens to him
    *   @return      : PageReference
    *   @author      : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public PageReference TryCreate(){
        
        if(oppty.StageName != 'Closed Won'){
            showError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Opportunity must be Closed Won.'));
            
            return null;
        }else{ 
            linesList = new list<linesWrapper>();
            //Get list of all opp line items related to current opportunity
            list<opportunitylineitem> lines = [SELECT Id, Product2Id, Product2.Name, ProductCode,
                                               Item_Description__c, Size__c, Quantity, TotalPrice,
                                               UnitPrice, SortOrder,
                                               product2.AcctSeed__Inventory_Type__c,
                                               product2.Allow_Custom_Image__c,
                                               product2.Kit_Available_Quantity__c,
                                               Allow_Product_Description_Change__c,
                                               product2.Allow_Product_Description_Change__c,
                                               AcctSeed__GL_Account_Variable_1__c, 
                                               AcctSeed__GL_Account_Variable_2__c, 
                                               AcctSeed__GL_Account_Variable_3__c, 
                                               AcctSeed__GL_Account_Variable_4__c, AlternateImageURL__c FROM OpportunityLineItem WHERE 
                                               OpportunityId = :oppty.Id 
                                               and product2.AcctSeed__Inventory_Type__c != 'Raw Material' 
                                               order by sortorder,name,createddate asc];
            
            //If opportunity dont have any OLI show error that we cant create so without products
            if(lines.size() == 0){
                showError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You cannot create a Sales Order from an '+'Opportunity without products.'));
                return null;
            }
            
            

            KitMap = new map<id, List<AcctSeed__Product_Part__c>>();
            ProductIds = new set<id>();

            List<AcctSeed__Product_Part__c> partsList = new List<AcctSeed__Product_Part__c>();

            // else continue to show the visualforce content for line items
            for(opportunitylineitem oli : lines){
                if(oli.product2.AcctSeed__Inventory_Type__c == 'Kit') hasKits = true;
                ProductIds.add(oli.product2Id);

                linesWrapper lw = new linesWrapper(oli, true); 
                linesList.add(lw);
            }

            // ibMap = InventoryCalculationHelper.Calculate(ProductIds);//dont use

            List<string> validProductIds = new List<String>();
            //Making map, ParentId - Children object => KitMap
            List<AcctSeed__Product_Part__c> childrens = [SELECT Id, Name, Kit_Product__c, 
                                                                Kit_Children__c,
                                                                Kit_Children__r.ProductCode,
                                                                Kit_Children__r.Description,
                                                                Kit_Children__r.Name,
                                                                Kit_Children__r.Allow_Product_Description_Change__c,
                                                                Kit_Children__r.Size__c,
                                                                AcctSeed__Quantity__c 
                                                                FROM AcctSeed__Product_Part__c 
                                                                where Kit_Product__c in:ProductIds];

            childrens_data = new List<childrenWrapper>();
            
            for(AcctSeed__Product_Part__c parts : childrens){

                childrens_data.add(new childrenWrapper(parts.Kit_Product__c, parts.Kit_Children__r.Id, parts.AcctSeed__Quantity__c));
                partsList = new List<AcctSeed__Product_Part__c>();
                
                if(KitMap.containsKey(parts.Kit_Product__c)){
                    partsList = KitMap.get(parts.Kit_Product__c);
                    partsList.add(parts);
                }else{
                    partsList.add(parts);
                    validProductIds.add(parts.Kit_Product__c);
                }

                KitMap.put(parts.Kit_Product__c, partsList);
            }
            system.debug('kitmap: '+JSON.serialize(KitMap));


            //Quaniny children = Quaniny children * Quantity parent, this loop count it
            for(linesWrapper lw:linesList){
                if(KitMap.containsKey(lw.oli.Product2.Id)){
                    for(AcctSeed__Product_Part__c pr: KitMap.get(lw.oli.Product2.Id)){
                        pr.AcctSeed__Quantity__c = lw.oli.Quantity * pr.AcctSeed__Quantity__c;
                    }
                }
            }

            if(!validProductIds.isEmpty())
                validKeys = String.join(validProductIds, ';');
        }
        system.debug('CREATE SO FROM PO JSON: '+JSON.serialize(linesList));
        return null;
    }
    
    /*****************************************************************************************************
    *   @method      : handleQuantity
    *   @description : non static method used to handling changes quantity of parent KIT
    *   @return      : void
    *   @author      : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void handleQuantity(){

        Decimal newQuantity = 1.00;
        //Need to find new quantity of parent
        for(linesWrapper lw:linesList){
            if(lw.oli.Product2Id == changedQuantityId){
                newQuantity = lw.oli.Quantity;
                lw.oli.TotalPrice = lw.oli.Quantity * lw.oli.UnitPrice;
            }
        }

        if(KitMap.containsKey(changedQuantityId)){
            for(AcctSeed__Product_Part__c child:KitMap.get(changedQuantityId)){
                    for(childrenWrapper cw: childrens_data){
                        if(child.Kit_Product__c == cw.parentId && child.Kit_Children__c == cw.childrenId){
                            child.AcctSeed__Quantity__c = newQuantity * cw.children_amount;
                        }
                    }
            }
        }

    }

    public PageReference create(){
        
        // get the gl variables
        map<string, id> NametoIdGLMap = new map<string, id>();
        for(AcctSeed__Accounting_Variable__c av: [select id,name from AcctSeed__Accounting_Variable__c]){
            
            NametoIdGLMap.put(av.name, av.id);
        }
        
        list<AcctSeedERP__Sales_Order_Line__c> slines = new list<AcctSeedERP__Sales_Order_Line__c>();
        // product, description, quantity,size,unitprice,sortorder
                                          
        
        // get the selected opportunity line items
        Integer sortSequence = 0;
        
        //Parents
        for(linesWrapper lw : linesList){
            if(lw.selected){
                sortSequence++;
                // add it to the the new sales order item list
                slines.add(new AcctSeedERP__Sales_Order_Line__c(
                    AcctSeedERP__Product__c = lw.oli.product2Id,
                    AcctSeedERP_Description__c = lw.oli.Item_Description__c,
                    Item_description__c = lw.oli.Item_Description__c,
                    AcctSeedERP__Quantity_Ordered__c = lw.oli.Quantity,
                    size__c = lw.oli.size__c,
                    AlternateImageURL__c = lw.oli.AlternateImageURL__c,
                    AcctSeedERP__Unit_Price__c = lw.oli.UnitPrice,
                    sortorder__c = sortSequence,
                    kit__c = lw.oli.product2.AcctSeed__Inventory_Type__c == 'Kit' ? true : false,
                    AcctSeedERP__Opportunity_Product_Id__c = lw.oli.id,
                    AcctSeedERP__GL_Account_Variable_1__c = oppty.GL_Account_Variable_1__c, 
                    AcctSeedERP__GL_Account_Variable_2__c = lw.oli.AcctSeed__GL_Account_Variable_2__c, 
                    AcctSeedERP__GL_Account_Variable_3__c = lw.oli.AcctSeed__GL_Account_Variable_3__c, 
                    AcctSeedERP__GL_Account_Variable_4__c = lw.oli.AcctSeed__GL_Account_Variable_4__c,
                    Allow_Product_Description_Change__c = lw.oli.Allow_Product_Description_Change__c
                ));

                if(KitMap.containsKey(lw.oli.Product2Id)){
                    for(AcctSeed__Product_Part__c child: KitMap.get(lw.oli.Product2Id)){
                        sortSequence++;
                        slines.add(new AcctSeedERP__Sales_Order_Line__c(
                            AcctSeedERP__Product__c = child.Kit_Children__c,
                            AcctSeedERP_Description__c = child.Kit_Children__r.Description,
                            Item_description__c = child.Kit_Children__r.Description,
                            AcctSeedERP__Quantity_Ordered__c = child.AcctSeed__Quantity__c,
                            size__c = child.Kit_Children__r.Size__c,
                            AcctSeedERP__Unit_Price__c = 0,
                            sortorder__c = sortSequence,
                            AcctSeedERP__GL_Account_Variable_1__c = oppty.GL_Account_Variable_1__c,
                            Kit_Children__c = true
                        ));
                    }
                }
                

                
            }
        }


        if(slines.IsEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No products have been selected.'));
            return null;
        }
 
        String recordtypeName = null;
        
        list<sales_rep__c> defaults = [select default_record_type__c 
                                                            from sales_rep__c where 
                                 id=:oppty.Sales_Rep_O__c and default_record_type__c != null limit 1];
        
        string recordtypeIdIs = null;
        
        if(!defaults.isEmpty()){
            
			recordtypeName = defaults[0].default_record_type__c;
  
            recordtypeIdIs = [select id from recordtype where sobjecttype='AcctSeedERP__Sales_Order__c' and 
                                    name =:recordtypeName limit 1][0].id; 
        }
        if(Defaults.isEmpty() || recordtypeIdIs == null){
            
            recordtypeIdIs = [select id from recordtype where sobjecttype = 'AcctSeedErP__sales_Order__c' and 
                             name =: oppty.recordtype.name limit 1][0].id;
            
        }





        // create the sales order
        AcctSeedERP__Sales_Order__c so = new AcctSeedERP__Sales_Order__c();
        
        so.Billing_Name__c = (oppty.account.acctseed__billing_contact__r.name == null)
            ?oppty.ContactPerson__c:oppty.account.acctseed__billing_contact__c;
        so.Billing_Account__c = oppty.accountId; 
        so.AcctSeedERP__Billing_City__c = oppty.account.billingcity;
        so.AcctSeedERP__Billing_Country__c = oppty.account.billingcountry;
        so.AcctSeedERP__Billing_PostalCode__c = oppty.account.billingpostalcode;
        so.AcctSeedERP__Billing_State__c = oppty.account.billingstate;
        so.AcctSeedERP__Billing_Street__c = oppty.account.billingstreet;
        so.AcctSeedERP__Customer__c = oppty.accountid;
        so.AcctSeedERP__Opportunity__c = oppty.id;
        so.Contact__c = oppty.ContactPerson__c;
        so.Sales_Rep_O__c = String.IsNotEmpty(salesrepid) ? salesrepid : oppty.sales_rep_o__c;
        so.ownerid = String.isNotEmpty(ownerid) ? ownerid : oppty.OwnerId;
        so.Referral_Sales_Rep__c = oppty.Referral_Sales_Rep__c;
        so.Specified_Rep__c = oppty.Specified_Rep__c;
        so.manufacturer_rep__c = oppty.manufacturer_rep__c;
        
        so.AcctSeedERP__Shipping_City__c = oppty.Shipping_City__c;
        so.AcctSeedERP__Shipping_Country__c = oppty.Shipping_Country__c;
        so.AcctSeedERP__Shipping_PostalCode__c = oppty.Shipping_PostalCode__c;
        so.AcctSeedERP__Shipping_State__c = oppty.Shipping_State__c;
        so.AcctSeedERP__Shipping_Street__c = oppty.Shipping_Street__c;
        
        so.Shipping_Account__c = oppty.Shipping_Account__c;
        so.Shipping_Name__c = oppty.Shipping_Name__c;

        so.Billing_Deposit__c = oppty.Billing_Deposit__c;
        so.Billing_Terms_Name__c = oppty.Billing_Terms_Name__c;
        
        so.Customer_s_ETA__c = oppty.deliver_by__c;
        so.Notes__c = oppty.Note__c;
        so.Shipping_Term__c = oppty.Shipping_Term__c;
        so.Special_Instruction__c = oppty.Description;
        so.AcctSeedERP__Ledger__c = selectedledger;
        so.Sales_Order_Format__c = (selectedFormat != null) ? selectedFormat : null;
        so.GL_Account_Variable_1__c = oppty.GL_Account_Variable_1__c;
        so.Project__c = oppty.Project__c;
        so.Price_Level__c = oppty.Price_Level__c;
        so.RecordTypeId = (recordtypeIdIs != null) ? recordTypeIdIs : null;
        so.Approval_Date__c = oppty.approve_date__c;
        so.PO_Date__c = oppty.PO_Date__c;
        so.PO_Number__c = oppty.PO_Number__c;
        so.LeadSource__c = oppty.LeadSource;
  
        // rollback if there is any error in one of the insertions
        Savepoint sp = Database.setSavepoint();

        PageReference page = null;
        
        try{
            
            insert so;

            for(AcctSeedERP__Sales_Order_Line__c sline : slines){
                
                sline.AcctSeedERP__Sales_Order__c = so.id;
                
            }
            
            // insert the sales order lines
            insert slines;
            
            AfterSalesOrderTriggerHandler.LinkBillings(new List<AcctSeedERP__Sales_Order__c>{so});

            page = new PageReference('/' + so.id);
            page.setRedirect(true);
            
        }catch(Exception ex){
            
            Database.rollback(sp);
            
            String errorMsg = ex.getMessage();

            errorMsg = errorMsg.substringBetween(', ', ':');

            if(errorMsg != null){

                errorMsg = errorMsg.capitalize();

                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
                ApexPages.addMessage(myMsg);
            }else{

                errorMsg = ex.getMessage();

                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
                ApexPages.addMessage(myMsg);
            }
        }

        return page;
               
    }
    
    public PageReference back(){
        
        PageReference page = new PageReference('/' + oppty.id);
        page.setRedirect(true);
        return page;
    }
    
    public class LinesWrapper{
        
        public Boolean selected {get; set;}
        public opportunitylineitem oli {get; set;}
        
        public linesWrapper(OpportunityLIneItem line, Boolean checked){
            
            oli = line;
            selected = checked;
        }
    }

    public class childrenWrapper{
        Id parentId {get; set;}
        Id childrenId {get; set;}
        Decimal children_amount {get; set;}

        public childrenWrapper(Id parId, Id chilId, Decimal amount){
            parentId = parId;
            childrenId = chilId;
            children_amount = amount;
        }
    }
}