global class AddProductCustomExtension {
    
    @testVisible private Opportunity the_opp;
    
    @testVisible private string OppPriceBookId {
        
        get{
            return (Test.isRunningTest()) ? Test.getStandardPricebookId(): [select id from Pricebook2 where 
                                                                            isStandard = true limit 1][0].id;
        }
    }
    
    public Boolean AddProductPermission {get; set;}
    public Boolean showBack {get; set;}
    public boolean DropShipMessage {get; set;}
    public string query123{get; set; }
    //for sorting
    public String sortWith {get; set;}
    public string sortProcess {get;set;}
    public string sortField {get;set;}
    public boolean ProductNameSortUp {get; set;}
    public boolean ProductNameSortDown {get; set;}
    public boolean ProductCodeSortUp {get; set;}
    public boolean ProductCodeSortDown {get; set;}  
    public boolean SizeSortUp {get; set;}
    public boolean SizeSortDown {get; set;}
    public boolean UnitCostSortUp {get; set;}
    public boolean UnitCostSortDown {get; set;} 
    public String docURL {get; set;} 
    
    // map to store product image with product id
    public map<id, string> ProductsWithImage {get; set;}
    
    //user want to store another image for oli
    public map<id, string> OliAlternateImgURL {get; set;}
    
    public void alternateImages(){
        
        String prodID = Apexpages.currentPage().getParameters().get('prodID');
        String docId = Apexpages.currentPage().getParameters().get('docId');
        
        docURL = System.URL.getOrgDomainUrl().toExternalForm() + '/servlet/servlet.FileDownload?file='+docId;
        
        OliAlternateImgURL.put(prodID, docURL);
    }
    
    public boolean preventAddLines {get; set;}
    
    public Id agl {get; set;}
    
    public map<string, string> temp {get{
        
        temp = new map<string, string>();
        
        if(temp.isEmpty()){
            String type = 'Product2';
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType ProductSchema = schemaMap.get(type);
            Map<String, Schema.SObjectField> fieldMap = ProductSchema.getDescribe().fields.getMap();
            
            set<string> tempNames = new set<string>{'Name', 'ProductCode'}; // added this line
                
                //SearchValList.add(new SelectOption('all', 'All')); // commented out this one
                for (String fieldName: Test.isRunningTest() ? tempNames : fieldMap.keySet()) { // added ternary here
                    
                    String LabelIs = fieldMap.get(fieldName).getDescribe().getLabel();
                    String APIIs = fieldMap.get(fieldName).getDescribe().getName();
                    String doAdd = String.valueOf(fieldMap.get(fieldName).getDescribe().getType());
                    
                    //if(doAdd == 'double' || doAdd == 'percent'){
                    temp.put(fieldname, doAdd); 
                    
                    //}
                }
        }
        
        return temp;
    } set;}
    
    public map<id, list<decimal>> ibMap {get; set;}
    
    // for pagination
    public integer counter = 0;
    public integer list_size = 15; 
    public integer total_size;
    public String headerText {
        get{
            if(getTotalPages() > 0){
                headerText = 'Showing Page # '+getPageNumber()+' of '+getTotalPages()+'';
            }else{
                headerText = 'No Records Found.';
            }
            return headerText;
        } set;}
    
    public Boolean disablePrevious {
        get{
            if(counter > 0){
                return false;
            }else{
                return true;
            }
        } set;}
    public Boolean disableNext {
        get{
            if (counter + list_size < total_size) {
                return false; 
            }else {
                return true;
            }
        } set;}
    
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        nextRecords();
        return null;
    }
    
    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        nextRecords();
        return null;
    }
    
    public PageReference Next() { //user clicked next button
        counter += list_size;
        nextRecords();
        
        return null;
    }
    
    public PageReference End() {
        if (math.mod(total_size, list_size) > 0) {
            counter = total_size - math.mod(total_size, list_size);
        } else {
            counter = total_size - list_size;
        }
        nextRecords();
        return null;
    }
    
    public Integer getTotal_size() {
        return total_size;
    }
    
    public Integer getPageNumber() {
        return counter/list_size + 1;
    }
    
    public Integer getTotalPages() {
        if (math.mod(total_size, list_size) > 0) {
            return total_size/list_size + 1;
        } else {
            return (total_size/list_size);
        }
    }
    
    // ends
    public Product2 prod2 {get; set;}
    public Integer HighestSort {get; set;} 
    public String section {get{
        if(section == null){
            section = ApexPages.currentPage().getParameters().get('section');
        }
        return section;
    } set;}
    public String searchText {get; set;}
    public String selectedSearchVal {get; set;}
    public Id OppId {get; set;}
    public Id QuoteId {get; set;}
    public Id soId {get; set;}
    public Id poId {get; set;}
    public Id kitId {get; set;}
    public Boolean productAdded {
        get
        {
            if(productAdded != true){
                productAdded = false;
            }
            return productAdded;
        } 
        set;}
    
    // tabstyle
    public string strTabName{set;}
    
    public String getStrTabName(){ 
        if(section =='oli'){ return 'Opportunity';}else if(section == 'qli'){ return 'Quote';}
        else if(section == 'opo'){ return 'Opportunity';}else if(section == 'opq'){return 'Quote';}
        else if(section == 'sli'){return 'acctseederp__sales_order__c';}
        else if(section=='pli'){return 'acctseederp__purchase_order__c';}
        return null;
    } 
    public LIST<SelectOption> SearchValList {
        
        get{
            SearchValList = new LIST<SelectOption>();
            SearchValList.add(new SelectOption('', 'None'));
            
            String type = 'Product2';
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType productSchema = schemaMap.get(type);
            Map<String, Schema.SObjectField> fieldMap = productSchema.getDescribe().fields.getMap();
            
            // This list for test mode only
            set<string> tempFieldNames = new set<string>{'Name', 'ProductCode'};
                
                SearchValList.add(new SelectOption('all', 'All'));
            for (String fieldName: Test.isRunningTest() ? tempFieldNames : fieldMap.keySet()) {
                
                String LabelIs = fieldMap.get(fieldName).getDescribe().getLabel();
                String APIIs = fieldMap.get(fieldName).getDescribe().getName();
                String doAdd = String.valueOf(fieldMap.get(fieldName).getDescribe().getType());
                
                if(doAdd != 'REFERENCE' && doAdd != 'DATETIME' && doAdd != 'BOOLEAN'){
                    if(fieldName != 'Id' && fieldName !='Family' && fieldName !='Door_Type__c' && 
                       fieldName !='AcctSeed__Inventory_Type__c' && fieldName !='AcctSeedERP__Inventory_Asset__c' 
                       && fieldName !='ProductImageURL__c' && fieldName !='DisplayUrl' && fieldName != 'AcctSeed__Unit_Cost__c'){
                           
                           SearchValList.add(new SelectOption(APIIs, LabelIs));
                           
                       }
                }
            }
            return SearchValList;
        }
        set;
    }
    
    public PageReference IfIdEmpty(){
        
        String IsNull = ApexPages.currentPage().getParameters().get('id');
        
        if(IsNull == null){
            PageReference pg = new PageReference('/');
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }
    
    public Boolean CheckPermission(String ObjectName){
        
        String desireUserId = UserInfo.getUserId();
        
        User u = [select profileId from user where id =: desireUserId limit 1];
        String profileId = u.profileId;
        
        LIST<ObjectPermissions> ObjPermissionList = new LIST<ObjectPermissions>();
        
        ObjPermissionList = [SELECT Id, SObjectType, PermissionsCreate FROM ObjectPermissions WHERE 
                             SObjectType =:ObjectName and
                             parentid in 
                             (select id from permissionset where PermissionSet.Profile.Id=: profileId)
                             limit 1];
        
        return ObjPermissionList[0].PermissionsCreate;
        
    }
    
    public AddProductCustomExtension() {
        AddProductPermission = true;
        showBack = false;
        ProductNameSortUp = true;
        ProductNameSortDown = false;
        ProductCodeSortUp = true;
        ProductCodeSortDown = false;
        SizeSortUp = true;
        SizeSortDown = false;
        UnitCostSortUp = true;
        UnitCostSortDown = false;
        preventAddLines = false;
        sortWith = '';
        sortProcess = 'ASC';
        
        DropShipMessage = false;
        
        ProductsWithImage = new map<id, string>();
        OliAlternateImgURL = new map<id, string>();
        // selectedSearchVal = 'Name';
        selectedSearchVal = 'all';
        prod2 = new Product2();
        String ObjectError = '';
        
        Id urlID = ApexPages.currentPage().getParameters().get('id');
        if(section == 'oli' || section == 'opo'){
            
            AddProductPermission = this.CheckPermission(section == 'oli' ? 'Product2' : 
                                                        'Optional_Products_Opportunity__c');
            
            // Check Permission and show error message       
            if(!AddProductPermission){
                
                ObjectError = 'Insufficient Privileges, you are not allowed to make these changes. '; 
                ObjectError += 'Please contact your adminstrator.';
                
                showBack = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 
                                                           ObjectError));
            }
            
            OppId = urlID;
            // get the highest sort
            HighestSort = Integer.ValueOf([select max(sortorder__c) 
                                           from Optional_Products_Opportunity__c 
                                           where Opportunity__c =:OppId][0].get('expr0'));
            
            list<Opportunity> olist = [select GL_Account_Variable_1__c from Opportunity
                                       where id =:OppId limit 1];
            
            if(!olist.isEmpty()){
                
                agl = olist[0].GL_Account_Variable_1__c;
                
                
            }
            
        }
        
        else if(section == 'opq' || section == 'qli'){
            
            AddProductPermission = this.CheckPermission(section == 'qli' ? 'Product2' : 
                                                        'Optional_Products_Opportunity__c');
            
            // Check Permission and show error message       
            if(!AddProductPermission){
                
                ObjectError = 'Insufficient Privileges, you are not allowed to make these changes. '; 
                ObjectError += 'Please contact your adminstrator.';
                
                showBack = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 
                                                           ObjectError));
            }
            
            QuoteId = urlID;
            
            // get the highest sort
            
            HighestSort = Integer.ValueOf([select max(sortorder__c) 
                                           from Optional_Products_Quote__c 
                                           where Quote__c =:QuoteId][0].get('expr0'));
            
            Quote opId = [select opportunityId from quote where id=:quoteId limit 1];
            
            list<Opportunity> olist = [select GL_Account_Variable_1__c from Opportunity
                                       where id =:opId.opportunityId limit 1];
            
            if(!olist.isEmpty()){
                
                agl = olist[0].GL_Account_Variable_1__c;
                
                
            }
            
        }
        
        else if(section == 'sli'){
            
            AddProductPermission = this.CheckPermission('AcctSeedERP__Sales_Order_Line__c');
            
            // Check Permission and show error message       
            if(!AddProductPermission){
                ObjectError = 'Insufficient Privileges, you are not allowed to make these changes. '; 
                ObjectError += 'Please contact your adminstrator.';   
                showBack = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ObjectError));
            }
            soId = urlID;
            
            // check if the sales order has been closed 
            if(soId != null){
                
                AcctSeedERP__Sales_Order__c order = [select AcctSeedERP__Status__c from AcctSeedERP__Sales_Order__c
                                                     where id =:soId limit 1];
                
                if(order.AcctSeedERP__Status__c == 'Closed'){
                    preventAddLines = true;
                }
            }
            
            // get the highest sort
            HighestSort = Integer.ValueOf([select max(sortorder__c) 
                                           from AcctSeedErP__sales_order_line__c 
                                           where AcctSeedERP__Sales_order__c =:soId][0].get('expr0'));
            
            list<AcctSeedERP__Sales_Order__c> slist = [select GL_Account_Variable_1__c
                                                       from AcctSeedERP__Sales_Order__c where id =:soId limit 1];
            
            if(!slist.isEmpty()){
                
                agl = slist[0].GL_Account_Variable_1__c;
                
                
            }
        }
        
        else if(section == 'pli'){
            
            poId = urlID;
            
            // get the highest sort
            HighestSort = Integer.ValueOf([select max(sort_order__c) 
                                           from AcctSeedErP__Purchase_order_line__c 
                                           where AcctSeedERP__Purchase_order__c =:poId][0].get('expr0'));
            
            list<AcctSeedERP__Purchase_order__c> plist = [select GL_Account_Variable_1__c,AcctSeedERP__Type__c
                                                          from AcctSeedERP__Purchase_order__c where id =:poId limit 1];
            
            if(!plist.isEmpty()){
                
                agl = plist[0].GL_Account_Variable_1__c;
                
                if(plist[0].AcctSeedERP__Type__c == 'Drop Shipment'){
                    
                    DropShipMessage = true;
                }
            }
            
        }
        
    }
    
    public PageReference searchByCategories(){
        
        counter = 0;
        
        prods = New productSelection[]{};
            
            String searchTextCategory = prod2.Category__c + '%';
        String searchTextSubCategory = prod2.Sub_Category__c + '%';
        for(PriceBookEntry pbe : executePBEQuery()){
            prods.add(
                New productSelection(pbe)
            );
        }
        
        total_size = executePBEQuery(false).size();
        
        return null;
    }
    public PageReference CancelButton(){
        
        PageReference redirectPage = null;
        
        if(QuoteId != null){
            redirectPage = new PageReference('/' + QuoteId);
            
        }else if(OppId != null){
            redirectPage = new PageReference('/' + OppId);            
        }else if(soId != null){
            
            redirectPage = new PageReference('/' + soId);
        }else if(poId != null){
            redirectPage = new PageReference('/' + poId);
        }
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    public PageReference IfSingleProduct(){
        if(prods.size() == 1){
            
            PageReference pr = Page.customMultiLine;
            pr.setRedirect(false);
            return pr;
        }
        
        return null;
        
    }
    public PageReference searchByName(){
        
        counter = 0;
        
        prods = New productSelection[]{};
            
            List<PriceBookEntry> allProducts = executePBEQuery();
        
        for(PriceBookEntry pbe : allProducts){
            prods.add(
                New productSelection(pbe)
            );
        }
        total_size = executePBEQuery(false).size();
        
        return null;
    }
    public List<PriceBookEntry> executePBEQuery()
    {
        return executePBEQuery(true);
    }
    public List<PriceBookEntry> executePBEQuery(Boolean applyLimit)
    {
        List<string> ProductFieldsAPINames = new List<string>();
        String type = 'Product2';
        // get all product fields
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType ProductSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = ProductSchema.getDescribe().fields.getMap();
        
        set<string> tempNames = new set<string>{'Name', 'ProductCode'}; // added this line
            
            //SearchValList.add(new SelectOption('all', 'All')); // commented out this one
            for (String fieldName: Test.isRunningTest() ? tempNames : fieldMap.keySet()) { // added ternary here
                String APIIs = fieldMap.get(fieldName).getDescribe().getName(); 
                ProductFieldsAPINames.add(APIIs);
            }
        
        String queryStr = '';
        
        List<string> fieldString = ProductFieldsAPINames;
        
        system.debug('list of field api name:');
        system.debug(fieldString);
        
        /*List<String> fieldString = new List<String>{'Name','ProductImageURL__c', 'ProductCode','Category__c',
'Description', 'ExternalId', 
'QuantityUnitOfMeasure', 'StockKeepingUnit', 'Direction__c', 
'Series__c', 'Shape__c', 'Size__c', 'Sub_Category__c', 
'Glass_Thickness__c', 'Glass__c', 'Hardware_Finish__c','AcctSeed__Accounting_Type__c'};*/
        
        queryStr = 'Select Id,ProductCode,UnitPrice, ';
        
        integer z = 1;
        
        for(string sfield : ProductFieldsAPINames){
            
            queryStr += 'Product2.'+sfield;
            
            if(z < fieldString.size()){
                
                queryStr +=','; 
            }
            
            z++;
        }
        queryStr += ' From PriceBookEntry Where PriceBook2ID = :OppPriceBookId AND isActive = true ';
        /*
queryStr = 'Select Id, Product2.ProductCode, Product2.id, Product2.AcctSeed__Unit_Cost__c,'+ 
'Product2.Size__c, Product2.Allow_Custom_Image__c, Product2.Glass__c, Product2.Hardware_Finish__c,'+ 
'Product2.Glass_Thickness__c, UnitPrice, Product2.Name, Product2.ProductImageURL__c, ProductCode,'+
'Product2.Description, Product2.Category__c, Product2.Sub_Category__c,Product2.Allow_Product_Description_Change__c ' +
'From PriceBookEntry Where PriceBook2ID = :OppPriceBookId AND isActive = true ';
*/
        
        if(DropShipMessage){
            queryStr += ' AND Product2.AcctSeed__Inventory_Product__c = false ';
        }
        
        // non wildcard search first
        // runQuery(query string, wildcard, applylimit, fields)
        list<pricebookentry> results = runQuery(queryStr, false, applylimit, fieldString);
        
        if(results.size() > 0){
            
            return results;
        }else{
            
            // wildcard search if the non wild card does not return any results
            return runQuery(queryStr, true, applylimit, fieldString);            
        }
        
    }
    
    public list<pricebookentry> runQuery(String queryStr, Boolean wildcard, Boolean applylimit, List<String> fieldString){
        
        String fieldname = '';
        if(selectedSearchVal == 'all' || selectedSearchVal == null){
            fieldname = 'all';
        }else{
            fieldname = selectedSearchVal;
        }
        if(searchText != null) searchText = searchText.replaceAll('[|<>?":}{|"+\\)\\(*&^%$#@!\\]\\[;\\/,\\\\]', '');
        
        
        String searchTextCategory = prod2.Category__c;
        String searchTextSubCategory = prod2.Sub_Category__c;
        String searchInOrder = '%'+searchText + '%';   
        
        if(!String.isEmpty(searchText)){
            
            list<string> strlist = searchtext.split(' ');
            integer strcount = strlist.size();
            
            queryStr += ' AND ( ';
            
            if(fieldname == 'all'){
                
                Integer s = 1;
                
                for(string fieldstr : fieldString){ 
                    
                    Integer r = 1;
                    
                    string numTypeIs = temp.get(fieldstr.toLowerCase());
                    
                    if(numTypeIs != 'reference' && numTypeIs != 'id' && numTypeIs !='datetime' && 
                       numTypeIs != 'boolean' && numTypeIs != 'double' && numTypeIs != 'percent'
                      && numTypeIs != 'date'){
                           
                           queryStr += ' ( ';
                           
                           
                           
                           
                           
                           for(string searchstr : strlist){
                               
                               if(wildcard){
                                   queryStr += (numTypeIs != 'string') ? 
                                       'Product2.' + fieldstr + '= \'' +searchstr+'\'' :'Product2.' + fieldstr + ' LIKE \'%' +searchstr+'%\'';
                               }else{
                                   queryStr += (numTypeIs != 'string') ? 
                                       'Product2.' + fieldstr + '= \'' + searchstr+'\'' :'Product2.' + fieldstr + ' LIKE \'' +searchstr+'\'';
                               }
                               
                               query123 = queryStr;
                               System.debug('11111: ' + queryStr);
                               
                               if(r < strlist.size()){
                                   
                                   queryStr += ' AND ';
                               }
                               r++;
                           }
                           
                           queryStr += ' )';
                           
                           if(s < fieldString.size()){
                               
                               queryStr += ' OR ';
                           }
                       }
                    
                    s++;
                }
            }else{
                
                Integer t = 1;
                
                string numTypeField = temp.get(fieldname.toLowerCase());
                
                for(string searchstrf : strlist){
                    
                    if(wildcard){
                        
                        queryStr += (numTypeField != 'string') 
                            ? 'Product2.' + fieldname + '= \'' +searchstrf+'\'' :'Product2.' + fieldname + ' LIKE \'%' +searchstrf+'%\'';
                    }else{
                        queryStr += (numTypeField != 'string') 
                            ? 'Product2.' + fieldname + '= \'' +searchstrf+'\'' : 'Product2.' + fieldname + ' LIKE \'' +searchstrf+'\'';
                    }
                    if(t < strlist.size()){
                        
                        queryStr += ' AND ';
                    }
                    t++;
                }
            }
            queryStr += ' )';
        }else{
            queryStr += '';
        }
        
        queryStr += (String.isEmpty(searchTextCategory) ?     ''   : ' AND Product2.Category__c =:searchTextCategory ');
        queryStr += (String.isEmpty(searchTextSubCategory) ?   ''   : ' AND Product2.Sub_Category__c =:searchTextSubCategory ');
        if(applyLimit){
            queryStr += ((String.isEmpty(sortWith)) ? '' : 'order by '+sortField+' '+sortProcess+' NULLS LAST ');
        }
        
        queryStr += (!applyLimit ? '' : ' limit :list_size offset :counter ');
        
        List<PriceBookEntry> pbeRecords = new List<PriceBookEntry>();
        
        try{
            pbeRecords = (List<PriceBookEntry>)Database.query(queryStr);
        }catch(Exception ex){
            system.debug('Exception has occured...');
            system.debug(ex.getMessage());
        }
        
        if(!pbeRecords.isEmpty()){
            
            set<id> productIds = new set<id>();
            for(PriceBookEntry pberecord : pbeRecords){
                
                productIds.add(pberecord.Product2.id);
                
            }
            
            // get the Actual quantity, available quantity and allocated quantity
            ibMap = new map<id, list<decimal>>();
            list<decimal> strList = new list<decimal>();
            for(AcctSeedERP__Inventory_Balance__c invt : [select AcctSeedERP__Product__c, AcctSeedERP__Available_Quantity__c,
                                                          AcctSeedERP__Sales_Order_Quantity__c from
                                                          AcctSeedERP__Inventory_Balance__c where 
                                                          AcctSeedERP__Product__c in:productIds]){
                                                              
                                                              // 0 : actual quantity
                                                              // 1 : available quantity
                                                              // 2 : allocated quantity
                                                              
                                                              if(ibMap.containsKey(invt.AcctSeedERP__Product__c)){
                                                                  // product exists
                                                                  strList = new list<decimal>();
                                                                  list<decimal> StrValues = ibMap.get(invt.AcctSeedERP__Product__c);
                                                                  decimal actual = StrValues[0] + 
                                                                      (invt.AcctSeedERP__Available_Quantity__c + 
                                                                       invt.AcctSeedERP__Sales_Order_Quantity__c);
                                                                  decimal available = StrValues[1] + 
                                                                      invt.AcctSeedERP__Available_Quantity__c;
                                                                  decimal allocated = StrValues[2]
                                                                      + invt.AcctSeedERP__Sales_Order_Quantity__c;
                                                                  strList.add(actual);
                                                                  strList.add(available);
                                                                  strList.add(allocated);
                                                                  ibMap.put(invt.AcctSeedERP__Product__c,strList);
                                                                  
                                                              }else{
                                                                  // first entry
                                                                  strList = new list<decimal>();
                                                                  list<decimal> StrValues = ibMap.get(invt.AcctSeedERP__Product__c);
                                                                  Decimal actual = invt.AcctSeedERP__Available_Quantity__c + 
                                                                      invt.AcctSeedERP__Sales_Order_Quantity__c;
                                                                  decimal available = invt.AcctSeedERP__Available_Quantity__c;
                                                                  decimal allocated = invt.AcctSeedERP__Sales_Order_Quantity__c;
                                                                  strList.add(actual);
                                                                  strList.add(available);
                                                                  strList.add(allocated);
                                                                  ibMap.put(invt.AcctSeedERP__Product__c,strList);
                                                              }
                                                              
                                                          }
            
            // if for any product key does not exist, add a list with empty values
            for(Id pId : productIds){
                
                if(!ibMap.containsKey(pId)){
                    
                    list<Decimal> decimalList = new list<Decimal>{0, 0, 0};
                        
                        ibMap.put(pId, decimalList);
                }
                
            }
        }
        
        return pbeRecords;
    }
    public void setSort(String field, String process){
        
        sortProcess = process;
        sortField = field;
        
        SearchResult();
        
    }
    public void SearchResult() {
        counter = 0;
        
        prods = New productSelection[]{};
            
            String searchTextCategory = prod2.Category__c + '%';
        String searchTextSubCategory = prod2.Sub_Category__c + '%';
        for(PriceBookEntry pbe : executePBEQuery()){
            prods.add(
                New productSelection(pbe)
            );
        }
        
        total_size = executePBEQuery(false).size();
    }
    public void resetSort(String typeIs){
        
        if(typeIs == 'Product Name'){
            ProductCodeSortUp = true;
            ProductCodeSortDown = false;
            SizeSortUp = true;
            SizeSortDown = false;
            UnitCostSortUp = true;
            UnitCostSortDown = false;
        }else if(typeIs == 'Product Code'){
            ProductNameSortUp = true;
            ProductNameSortDown = false;
            SizeSortUp = true;
            SizeSortDown = false;
            UnitCostSortUp = true;
            UnitCostSortDown = false;
        }else if(typeIs == 'Size'){
            ProductCodeSortUp = true;
            ProductCodeSortDown = false;
            ProductNameSortUp = true;
            ProductNameSortDown = false;
            UnitCostSortUp = true;
            UnitCostSortDown = false;
            
        }else if(typeIs == 'Unit Cost'){
            ProductCodeSortUp = true;
            ProductCodeSortDown = false;
            ProductNameSortUp = true;
            ProductNameSortDown = false;
            SizeSortUp = true;
            SizeSortDown = false;
        }
    }
    public void checkSort(){        
        sortWith = ApexPages.currentPage().getParameters().get('sort');
        if(sortWith == 'Product Name'){
            
            if(ProductNameSortUp == true) sortProcess = 'ASC';
            
            if(sortProcess == 'DESC'){
                sortProcess = 'ASC';
                ProductNameSortUp = true;
                ProductNameSortDown = false;
                setSort('Product2.Name', 'ASC');  
            }else if(sortProcess == 'ASC'){
                sortProcess = 'DESC';
                ProductNameSortUp = false;
                ProductNameSortDown = true;
                setSort('Product2.Name', 'DESC'); 
            }
            resetSort('Product Name');            
        }else if(sortWith == 'Product Code'){
            
            if(ProductCodeSortUp == true) sortProcess = 'ASC';
            
            if(sortProcess == 'DESC'){
                sortProcess = 'ASC';
                ProductCodeSortUp = true;
                ProductCodeSortDown = false;
                setSort('ProductCode', 'ASC');  
            }else if(sortProcess == 'ASC'){
                sortProcess = 'DESC';
                ProductCodeSortUp = false;
                ProductCodeSortDown = true;
                setSort('ProductCode', 'DESC'); 
            }
            resetSort('Product Code');            
        }else if(sortWith == 'Size'){
            
            if(SizeSortUp == true) sortProcess = 'ASC';
            
            if(sortProcess == 'DESC'){
                sortProcess = 'ASC';
                SizeSortUp = true;
                SizeSortDown = false;
                setSort('Product2.Size__c', 'ASC');  
            }else if(sortProcess == 'ASC'){
                sortProcess = 'DESC';
                SizeSortUp = false;
                SizeSortDown = true;
                setSort('Product2.Size__c', 'DESC'); 
            }
            resetSort('Size');            
        }else if(sortWith == 'Unit Cost'){
            
            if(UnitCostSortUp == true) sortProcess = 'ASC';
            
            if(sortProcess == 'DESC'){
                sortProcess = 'ASC';
                UnitCostSortUp = true;
                UnitCostSortDown = false;
                setSort((section == 'sli') ? 'UnitPrice' : 'Product2.AcctSeed__Unit_Cost__c', 'ASC');  
            }else if(sortProcess == 'ASC'){
                sortProcess = 'DESC';
                UnitCostSortUp = false;
                UnitCostSortDown = true;
                setSort((section == 'sli') ? 'UnitPrice' : 'Product2.AcctSeed__Unit_Cost__c', 'DESC'); 
            }
            resetSort('Unit Cost');            
        }
    }
    
    public PageReference gotoCustomMultiLine() {
        
        for (productSelection ps : prods) {
            if(ps.isSelected) {
                productAdded = true;
                break;
            }else{
                productAdded = false;
            }
            
        }
        
        if(productAdded == false){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'No products have been selected.'));
            return null;
        }
        
        PageReference pr = Page.customMultiLine;
        //pr.getParameters().put('id', the_opp.id);
        //pr.getParameters().put('section', section);
        pr.setRedirect(false);
        return pr;
        
    }
    
    public void nextRecords(){
        
        prods = New productSelection[]{};
            
            String searchTextNew = searchText + '%';
        String fieldname = 'Product2.' + selectedSearchVal;
        
        List<PriceBookEntry> allProducts = executePBEQuery();
        
        for(PriceBookEntry pbe : allProducts){
            prods.add(
                New productSelection(pbe)
            );
        }
        total_size = executePBEQuery(false).size();
    }
    
    public productSelection[] prods {
        get {
            if(prods == null) {
                prods = New productSelection[]{};
                    
                    total_size = executePBEQuery(false).size();
                
                List<PriceBookEntry> allProducts = executePBEQuery();
                
                for(PriceBookEntry pbe : allProducts){
                    prods.add(
                        New productSelection(pbe)
                    );
                }
            }
            if (prods.isEmpty()) {
                apexPages.addMessage(New ApexPages.Message(ApexPages.Severity.FATAL, 'Unable to find active products'));
            }
            
            return prods;
        }
        set;
    }
    
    public acctseederp__purchase_order_line__c[] PLI {
        get {
            if (PLI == null && section == 'pli') {
                PLI = New acctseederp__purchase_order_line__c[]{};
                    
                    for (productSelection ps : prods) {
                        if(prods.size() == 1){
                            if(HighestSort != null) {
                                HighestSort++;
                            }else{
                                HighestSort = 1;
                            }
                            PLI.add(  
                                New acctseederp__purchase_order_line__c(
                                    acctseederp__purchase_order__c = poId,
                                    acctseederp__product__c = ps.pbe.Product2Id,
                                    // acctseederp__Unit_Price__c = ps.pbe.UnitPrice,
                                    acctseederp__Unit_Price__c = (ps.pbe.Product2.AcctSeed__Unit_Cost__c == null) ? 
                                    0.00 : ps.pbe.Product2.AcctSeed__Unit_Cost__c,
                                    Description__c = ps.pbe.Product2.Description,
                                    Size__c = ps.pbe.Product2.Size__c,
                                    Sort_Order__c = HighestSort,
                                    AcctSeedERP__GL_Account_Variable_1__c = agl,
                                    Allow_Product_Description_Change__c = ps.pbe.Product2.Allow_Product_Description_Change__c
                                )
                            );
                            // Add names to Id map to display on page
                            prodNames.put(ps.pbe.id, ps.pbe.Product2.Name);
                            
                            ProductsWithImage.put(ps.pbe.Product2Id ,String.IsBlank(ps.pbe.Product2.ProductImageURL__c) ?
                                                  'NA' : ps.pbe.Product2.ProductImageURL__c);
                        }else{
                            if(ps.isSelected) {
                                if(HighestSort != null) {
                                    HighestSort++;
                                }else{
                                    HighestSort = 1;
                                }
                                PLI.add(  
                                    New acctseederp__purchase_order_line__c(
                                        acctseederp__purchase_order__c = poId,
                                        acctseederp__product__c = ps.pbe.Product2Id,
                                        //acctseederp__Unit_Price__c = ps.pbe.UnitPrice,
                                        acctseederp__Unit_Price__c = (ps.pbe.Product2.AcctSeed__Unit_Cost__c == null) ? 0.00 : ps.pbe.Product2.AcctSeed__Unit_Cost__c,
                                        Description__c = ps.pbe.Product2.Description,
                                        Size__c = ps.pbe.Product2.Size__c,
                                        Sort_Order__c = HighestSort,
                                        AcctSeedERP__GL_Account_Variable_1__c = agl,
                                        Allow_Product_Description_Change__c = ps.pbe.Product2.Allow_Product_Description_Change__c
                                    )
                                );
                                // Add names to Id map to display on page
                                prodNames.put(ps.pbe.id, ps.pbe.Product2.Name);
                                ProductsWithImage.put(ps.pbe.Product2Id ,String.IsBlank(ps.pbe.Product2.ProductImageURL__c) ?
                                                      'NA' : ps.pbe.Product2.ProductImageURL__c);
                            }
                        }
                    }
            }
            return PLI;
            
        }
        set;
    }
    
    public acctseederp__sales_order_line__c[] SLI {
        get {
            if (SLI == null && section == 'sli') {
                SLI = New acctseederp__sales_order_line__c[]{};
                    for (productSelection ps : prods) {
                        if(prods.size() == 1){
                            if(HighestSort != null) {
                                HighestSort++;
                            }else{
                                HighestSort = 1;
                            }
                            
                            SLI.add(  
                                New acctseederp__sales_order_line__c(
                                    acctseederp__sales_order__c = soId,
                                    acctseederp__product__c = ps.pbe.Product2Id, 
                                    acctseederp__Unit_Price__c = ps.pbe.UnitPrice,
                                    acctseederp_Description__c = ps.pbe.Product2.Description,
                                    Item_Description__c = ps.pbe.Product2.Description,
                                    Size__c = ps.pbe.Product2.Size__c,
                                    SortOrder__c = HighestSort,
                                    AcctSeedERP__GL_Account_Variable_1__c = agl,
                                    Allow_Product_Description_Change__c = ps.pbe.Product2.Allow_Product_Description_Change__c
                                )
                            );
                            //Add names to Id map to display on page
                            prodNames.put(ps.pbe.id, ps.pbe.Product2.Name);
                            ProductsWithImage.put(ps.pbe.Product2Id ,String.IsBlank(ps.pbe.Product2.ProductImageURL__c) ?
                                                  'NA' : ps.pbe.Product2.ProductImageURL__c);
                        }else{
                            if(ps.isSelected) {
                                if(HighestSort != null) {
                                    HighestSort++;
                                }else{
                                    HighestSort = 1;
                                }
                                
                                SLI.add(  
                                    New acctseederp__sales_order_line__c(
                                        acctseederp__sales_order__c = soId,
                                        acctseederp__product__c = ps.pbe.Product2Id,
                                        acctseederp__Unit_Price__c = ps.pbe.UnitPrice,
                                        acctseederp_Description__c = ps.pbe.Product2.Description,
                                        Item_Description__c = ps.pbe.Product2.Description,
                                        Size__c = ps.pbe.Product2.Size__c,
                                        SortOrder__c = HighestSort,
                                        AcctSeedERP__GL_Account_Variable_1__c = agl,
                                        Allow_Product_Description_Change__c = ps.pbe.Product2.Allow_Product_Description_Change__c
                                    )
                                );
                                //Add names to Id map to display on page
                                prodNames.put(ps.pbe.id, ps.pbe.Product2.Name);
                                ProductsWithImage.put(ps.pbe.Product2Id ,String.IsBlank(ps.pbe.Product2.ProductImageURL__c) ?
                                                      'NA' : ps.pbe.Product2.ProductImageURL__c);
                            }
                        }
                    }
            }
            return SLI;
            
        }
        set;
    }
    
    public Optional_Products_Opportunity__c[] OP {
        get {
            if (OP == null && section == 'opo') {
                OP = New Optional_Products_Opportunity__c[]{};
                    
                    for (productSelection ps : prods) {
                        if(prods.size() == 1){
                            if(HighestSort != null) {
                                HighestSort++;
                            }else{
                                HighestSort = 1;
                            }
                            OP.add(  
                                New Optional_Products_Opportunity__c(
                                    Opportunity__c = OppId,
                                    UnitPrice__c = ps.pbe.UnitPrice,
                                    Product__c = ps.pbe.Product2Id,
                                    Item_Description__c = ps.pbe.Product2.Description,
                                    Size__c = ps.pbe.Product2.Size__c,
                                    sortorder__c = HighestSort,
                                    PriceBookEntryId__c = ps.pbe.id,
                                    GL_Account_Variable_1__c = agl,
                                    Allow_Product_Description_Change__c = ps.pbe.Product2.Allow_Product_Description_Change__c
                                )
                            );
                            //Add names to Id map to display on page
                            prodNames.put(ps.pbe.id, ps.pbe.Product2.Name);
                            ProductsWithImage.put(ps.pbe.Product2Id ,String.IsBlank(ps.pbe.Product2.ProductImageURL__c) ?
                                                  'NA' : ps.pbe.Product2.ProductImageURL__c);
                            
                        }else{
                            if(ps.isSelected) {
                                if(HighestSort != null) {
                                    HighestSort++;
                                }else{
                                    HighestSort = 1;
                                }
                                OP.add(  
                                    New Optional_Products_Opportunity__c(
                                        Opportunity__c = OppId,
                                        UnitPrice__c = ps.pbe.UnitPrice,
                                        Product__c = ps.pbe.Product2Id,
                                        Item_Description__c = ps.pbe.Product2.Description,
                                        Size__c = ps.pbe.Product2.Size__c,
                                        sortorder__c = HighestSort,
                                        PriceBookEntryId__c = ps.pbe.id,
                                        GL_Account_Variable_1__c = agl,
                                        Allow_Product_Description_Change__c = ps.pbe.Product2.Allow_Product_Description_Change__c
                                    )
                                );
                                //Add names to Id map to display on page
                                prodNames.put(ps.pbe.id, ps.pbe.Product2.Name);
                                ProductsWithImage.put(ps.pbe.Product2Id ,String.IsBlank(ps.pbe.Product2.ProductImageURL__c) ?
                                                      'NA' : ps.pbe.Product2.ProductImageURL__c);
                            }
                        }
                    }
            }
            return OP;
            
        }
        set;
    }
    
    public Optional_Products_Quote__c[] OPq {
        get {
            if (OPq == null && section == 'opq') {
                OPq = New Optional_Products_Quote__c[]{};
                    
                    for (productSelection ps : prods) {
                        if(prods.size() == 1){
                            if(HighestSort != null) {
                                HighestSort++;
                            }else{
                                HighestSort = 1;
                            }
                            OPq.add(
                                New Optional_Products_Quote__c(
                                    Quote__c = QuoteId,
                                    UnitPrice__c = ps.pbe.UnitPrice,
                                    Product__c = ps.pbe.Product2Id,
                                    Item_Description__c = ps.pbe.Product2.Description,
                                    Size__c = ps.pbe.Product2.Size__c,
                                    Sortorder__c = HighestSort, 
                                    PriceBookEntryId__c = ps.pbe.id,
                                    GL_Account_Variable_1__c = agl
                                ));
                            // Add names to Id map to display on page
                            prodNames.put(ps.pbe.id, ps.pbe.Product2.Name);
                            ProductsWithImage.put(ps.pbe.Product2Id ,String.IsBlank(ps.pbe.Product2.ProductImageURL__c) ?
                                                  'NA' : ps.pbe.Product2.ProductImageURL__c);
                        }else{
                            
                            if(ps.isSelected) {
                                if(HighestSort != null) {
                                    HighestSort++;
                                }else{
                                    HighestSort = 1;
                                }
                                OPq.add(
                                    New Optional_Products_Quote__c(
                                        Quote__c = QuoteId,
                                        UnitPrice__c = ps.pbe.UnitPrice,
                                        Product__c = ps.pbe.Product2Id,
                                        Item_Description__c = ps.pbe.Product2.Description,
                                        Size__c = ps.pbe.Product2.Size__c,
                                        Sortorder__c = HighestSort,
                                        PriceBookEntryId__c = ps.pbe.id,
                                        GL_Account_Variable_1__c = agl
                                    ));
                                // Add names to Id map to display on page
                                prodNames.put(ps.pbe.id, ps.pbe.Product2.Name);
                                ProductsWithImage.put(ps.pbe.Product2Id ,String.IsBlank(ps.pbe.Product2.ProductImageURL__c) ?
                                                      'NA' : ps.pbe.Product2.ProductImageURL__c);
                            }
                        }
                    }
            }
            return OPq;
        }
        set;
    }
    
    public QuoteLineItem[] Qli {
        get {
            if (Qli == null && section == 'qli') {
                Qli = New QuoteLineItem[]{};
                    
                    for (productSelection ps : prods) {
                        if(prods.size() == 1){
                            Qli.add(
                                New QuoteLineItem(
                                    QuoteId = QuoteId,
                                    UnitPrice = ps.pbe.UnitPrice,
                                    Product2Id = ps.pbe.Product2Id,
                                    PricebookEntryId = ps.pbe.Id,
                                    Item_Description__c = ps.pbe.Product2.Description,
                                    Size__c = ps.pbe.Product2.Size__c,
                                    Allow_Product_Description_Change__c = ps.pbe.Product2.Allow_Product_Description_Change__c
                                ));
                            //Add names to Id map to display on page
                            prodNames.put(ps.pbe.id, ps.pbe.Product2.Name); 
                            ProductsWithImage.put(ps.pbe.Product2Id ,String.IsBlank(ps.pbe.Product2.ProductImageURL__c) ?
                                                  'NA' : ps.pbe.Product2.ProductImageURL__c);
                        }else{
                            
                            if(ps.isSelected) {
                                Qli.add(
                                    New QuoteLineItem(
                                        QuoteId = QuoteId,
                                        UnitPrice = ps.pbe.UnitPrice,
                                        Product2Id = ps.pbe.Product2Id,
                                        PricebookEntryId = ps.pbe.Id,
                                        Item_Description__c = ps.pbe.Product2.Description,
                                        Size__c = ps.pbe.Product2.Size__c,
                                        Allow_Product_Description_Change__c = ps.pbe.Product2.Allow_Product_Description_Change__c
                                    ));
                                //Add names to Id map to display on page
                                prodNames.put(ps.pbe.id, ps.pbe.Product2.Name);
                                ProductsWithImage.put(ps.pbe.Product2Id ,String.IsBlank(ps.pbe.Product2.ProductImageURL__c) ?
                                                      'NA' : ps.pbe.Product2.ProductImageURL__c);
                            }
                        }
                    }
            }
            return Qli;
        }
        set;
    }
    
    public OpportunityLineItem[] Oli {
        get {
            if (Oli == null && section == 'oli') {
                Oli = New OpportunityLineItem[]{};
                    for (productSelection ps : prods) {
                        if(prods.size() == 1){
                            Oli.add(
                                New OpportunityLineItem(
                                    OpportunityId = OppId,
                                    UnitPrice = ps.pbe.UnitPrice,
                                    Product2Id = ps.pbe.Product2Id,
                                    Item_Description__c = ps.pbe.Product2.Description,
                                    Size__c = ps.pbe.Product2.Size__c,
                                    PricebookEntryId = ps.pbe.Id,
                                    AcctSeed__GL_Account_Variable_1__c = agl,
                                    Allow_Custom_Image__c = ps.pbe.Product2.Allow_Custom_Image__c,
                                    Allow_Product_Description_Change__c = ps.pbe.Product2.Allow_Product_Description_Change__c
                                ));
                            //Add names to Id map to display on page
                            prodNames.put(ps.pbe.id, ps.pbe.Product2.Name);
                            ProductsWithImage.put(ps.pbe.Product2Id ,String.IsBlank(ps.pbe.Product2.ProductImageURL__c) ?
                                                  'NA' : ps.pbe.Product2.ProductImageURL__c);
                        }
                        else{    
                            if(ps.isSelected) {
                                Oli.add(
                                    New OpportunityLineItem(
                                        OpportunityId = OppId,
                                        UnitPrice = ps.pbe.UnitPrice,
                                        Product2Id = ps.pbe.Product2Id,
                                        Item_Description__c = ps.pbe.Product2.Description,
                                        Size__c = ps.pbe.Product2.Size__c,
                                        PricebookEntryId = ps.pbe.Id,
                                        AcctSeed__GL_Account_Variable_1__c = agl,
                                        Allow_Custom_Image__c = ps.pbe.Product2.Allow_Custom_Image__c,
                                        Allow_Product_Description_Change__c = ps.pbe.Product2.Allow_Product_Description_Change__c
                                    ));
                                //Add names to Id map to display on page
                                prodNames.put(ps.pbe.id, ps.pbe.Product2.Name);
                                ProductsWithImage.put(ps.pbe.Product2Id ,String.IsBlank(ps.pbe.Product2.ProductImageURL__c) ?
                                                      'NA' : ps.pbe.Product2.ProductImageURL__c);
                            }
                        }
                    }
            }
            return Oli;
        }
        set;
    }
    
    
    
    public pageReference saveOP() {
        
        try {
            if(section == 'opo'){
                insert OP;
            }else if(section == 'opq'){
                insert OPq; 
            }else if(section == 'oli'){
                for(OpportunityLineItem ol : Oli){
                    if(!OliAlternateImgURL.isEmpty()){
                        if(OliAlternateImgURL.containsKey(ol.Product2Id)){
                            ol.AlternateImageURL__c = OliAlternateImgURL.get(ol.Product2Id);
                        }   
                    }
                }
                
                insert Oli;                
            }else if(section == 'qli'){
                insert Qli;                
            }else if(section == 'sli'){
                insert sli;                
            }else if(section == 'pli'){
                insert pli;                
            }
            
            return gotoParent();
        } catch (DMLException e) {
            return null;
        }
        
    }
    public pageReference saveMoreOP() {
        
        try {
            if(section == 'opo'){
                insert OP;
            }else if(section == 'opq'){
                insert OPq;
            }else if(section == 'oli'){
                for(OpportunityLineItem ol : Oli){
                    if(!OliAlternateImgURL.isEmpty()){
                        if(OliAlternateImgURL.containsKey(ol.Product2Id)){
                            ol.AlternateImageURL__c = OliAlternateImgURL.get(ol.Product2Id);
                        }   
                    }
                }
                insert Oli;                
            }else if(section == 'qli'){
                insert Qli;                
            }else if(section == 'sli'){
                insert sli;                
            }else if(section == 'pli'){
                insert pli;                
            }
            return gotoParentMore();
        } catch (DMLException e) {
            return null;
        }
        
    }
    
    public pageReference gotoParentMore() {
        if(section == 'oli' || section == 'opo'){
            
            PageReference pr = New PageReference('/apex/AddProductCustomVFPage?id=' + OppId + '&section=' + section);
            pr.setRedirect(true);
            return pr;
            
        }else if(section == 'qli' || section == 'opq'){
            
            PageReference pr = New PageReference('/apex/AddProductCustomVFPage?id=' + QuoteId + '&section=' + section);
            pr.setRedirect(true);
            return pr;           
        }else if(section == 'sli'){
            
            PageReference pr = New PageReference('/apex/AddProductCustomVFPage?id=' + soId + '&section=' + section);
            pr.setRedirect(true);
            return pr; 
        }else if(section == 'pli'){
            
            PageReference pr = New PageReference('/apex/AddProductCustomVFPage?id=' + poId + '&section=' + section);
            pr.setRedirect(true);
            return pr; 
        }
        
        return null;
        
    }
    public pageReference gotoParent() {
        if(section == 'oli' || section == 'opo'){
            
            PageReference pr = New PageReference('/'+ OppId);
            return pr;
            
        }else if(section == 'qli' || section == 'opq'){
            
            PageReference pr = New PageReference('/'+ QuoteId);
            return pr;           
        }else if(section == 'sli'){
            
            PageReference pr = New PageReference('/'+ soId);
            return pr; 
        }else if(section == 'pli'){
            
            PageReference pr = New PageReference('/'+ poId);
            return pr; 
        }
        
        return null;
        
    }
    
    public Map<ID, String> prodNames {
        get {
            
            if (prodNames == null) {
                prodNames = New Map<ID, String>();
            }
            
            return prodNames;
            
        }
        set;
    }
    
    public class productSelection{
        public boolean isSelected {get;set;}
        public PriceBookEntry pbe {get;set;}
        
        public productSelection(PricebookEntry pbe){
            this.pbe = pbe;
            isSelected = false;
        }
    } 
}