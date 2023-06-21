public class ListOfRecordsController {
    public Map<String, Set<String>> UserAndTeams_Map { get; set; }
    public Set<String> usersNames { get; set; }
    public Decimal summedupamount {get; set;}
    public Decimal current_total {get; set;}
    public List<Opportunity> allOpportunities { get; set; }

    public Date Only_Start_Date {get; set;}
    public Date Only_End_Date {get; set;}
    public DateTime Full_Start_Date {get; set;}
    public DateTime Full_End_Date {get; set;}
    
    public Id LoggedInUserId { get; set; }
    public string LoggedInUserName { get; set; }
    public string chart { get; set; }
    public string click { get; set; }
    public string duration { get; set; }
    public string str { get; set; }
    public string title { get; set; }
    public string dashboard { get; set; }
    public string amountQuery { get; set; }

    public boolean showNeglectedField { get; set; }
    public boolean showactivedate { get; set; }
    public boolean showState { get; set; }
    public Boolean isTest { get; set; }
    
    public boolean ShowSubmittedDate { get; set; }
    public boolean ShowClosedDate { get; set; }
    public boolean ShowCloseDate { get; set; }
    public boolean ShowLossReason { get; set; }
    
    public boolean ShowFC { get; set; }
    public boolean ShowProb { get; set; }
    public boolean ShowER { get; set; }
    public boolean ShowWon { get; set; }
    public boolean ShowModBy { get; set; }
    public boolean ShowModDate { get; set; }
    
    public boolean ShowOwner { get; set; }
    public boolean ShowAwardedOwner { get; set; }
    public boolean showDueDate { get; set; }
    
    public Date d { get; set; }
    public Date MonthStart { get; set; }
    public Date MonthEnd { get; set; }
    public Date LastYearMonthStart { get; set; }
    public Date LastYearMonthEnd { get; set; }
    public DateTime CMonthStart { get; set; }
    public DateTime CMonthEnd { get; set; }
    public DateTime CLastYearMonthStart { get; set; }
    public DateTime CLastYearMonthEnd { get; set; }
    
    public set<string> Active_SalesReps { get; set; }
    public set<string> All_SalesReps { get; set; }
    public set<string> Active_SalesReps_USA { get; set; }
    public set<string> All_SalesReps_USA { get; set; }
    public set<string> Active_SalesReps_CHK { get; set; }
    public set<string> All_SalesReps_CHK { get; set; }
    
    // For USA users
    public set<string> Active_Users_USA { get; set; }
    public set<string> All_Users_USA { get; set; }
    public set<string> Inside_Sales_Users_USA { get; set; }
    public set<string> Inside_Sales_Users_USA_Id { get; set; }
    
    // For China/Hong Kong users
    public set<string> Active_Users_CHK { get; set; }
    public set<string> All_Users_CHK { get; set; }
    public set<string> Inside_Sales_Users_CHK { get; set; }
    public set<string> Inside_Sales_Users_CHK_Id { get; set; }
    
    public string str2 { get; set; }
    public string str3 { get; set; }
    
    // ------------ New pagination code starts here
    public Integer size { get; set; }
    public ApexPages.StandardSetController Con { get; set; }
    public decimal TotalAmount {get; set;}
    public Integer getSerialNumber() {
        return con != null ? 100 * con.getPageNumber() - 100 : 0;
    }

    public String opp_dashb_query {get;set;}
    public List<Opportunity_Dashboard__c> opp_dashboards {get;set;}
    public List<SObject> list_opps_big {get;set;}
    public Boolean oppDashbShowStageField {get; set;}
    public String so_dashb_query {get;set;}
    public List<Sales_Order_Dashboard__c> so_dashboards {get;set;}


    public Boolean hasNext {
        get {
            return con != null ? con.getHasNext() : false;
        }
        set;
    }
    
    public Boolean hasPrevious {
        get {
            return con != null ? con.getHasPrevious() : false;
        }
        set;
    }
    
    public Integer pageSize {
        get {
            return con != null ? con.getPageSize() : 0;
        }
        set;
    }
    
    public Integer getTotalPages() {
        Decimal totalSize = Con != null ? this.Con.getResultSize() : 0;
        Decimal pageSize = Con != null ? this.Con.getPageSize() : 0;
        try{
            Decimal pages = totalSize / pageSize;
        
            return (Integer) pages.round(System.RoundingMode.CEILING);
        } catch(Exception e){
             return 1;
        }
        
    }
    
    public Integer pageNumber {
        get {
            return con != null ? con.getPageNumber() : 0;
        }
        set;
    }
    public void first() {
        this.con.first();
    }
    
    // returns the last page of records
    public void last() {
        this.con.last();
    }
    
    // returns the previous page of records
    public void previous() {
        this.con.previous();
    }
    
    // returns the next page of records
    public void next() {
        this.con.next();
    }
    
    //-----------------------Lists-----------------------
    
    public Boolean isOrders { get; set; }
    public string QueryOrders { get; set; }
    public List<AcctSeedERP__Sales_Order__c> getOrders() {

        List<AcctSeedERP__Sales_Order__c> ordersList = 
        new List<AcctSeedERP__Sales_Order__c>();

        if(isOrders && Con != null) ordersList = (List<AcctSeedERP__Sales_Order__c>) Con.getRecords();

        // for(AcctSeedERP__Sales_Order__c order : ordersList){

        //     summedupamount += order.AcctSeedERP__Total__c;

        // }

        return ordersList;
    }
    
    public Boolean isOpptys { get; set; }
    public string QueryOpportunities { get; set; }
    public map<id, integer> NeglectedDaysMap { get; set; }
    public List<Opportunity> getOpportunities() {
        // if total for one page uncomment next line
        List<Opportunity> opptyList = 
        new List<Opportunity>();

        if(isOpptys && Con != null) opptyList = (List<Opportunity>) Con.getRecords();

        if(allOpportunities != null){
            summedupamount = 0.00;

            if(!allOpportunities.isEmpty()){
                for(Opportunity oppty : allOpportunities){
                    if(oppty.Amount != null){
                        summedupamount += oppty.Amount;
                    }
                }
            } else {

            }
        }
            
        

        return opptyList;
    }
    
    public Boolean isAccounts { get; set; }
    public string QueryAccounts { get; set; }
    public List<Account> getAccounts() {
        return isAccounts && Con != null ? (List<Account>) Con.getRecords() : new List<Account>();
    }
    
    public Boolean isTasks { get; set; }
    public string QueryTasks { get; set; }
    public List<Task> getTasks() {
        return isTasks && Con != null ? (List<Task>) Con.getRecords() : new List<Task>();
    }
    
    public Boolean isBillings { get; set; }
    public string QueryBillings { get; set; }
    public List<AcctSeed__Billing__c> getBillings() {

        List<AcctSeed__Billing__c> billingList = 
        new List<AcctSeed__Billing__c>();

        if(isBillings && Con != null) billingList = (List<AcctSeed__Billing__c>) Con.getRecords();

        for(AcctSeed__Billing__c billing : billingList){

            //summedupamount += chart.contains('Billing_Aging') ? billing.AcctSeed__Balance__c : billing.AcctSeed__Total__c;

        }

        return billingList;
    }
    
    public Boolean isLeads { get; set; }
    public string QueryLeads { get; set; }
    public List<Lead> getLeads() {
        return isLeads && Con != null ? (List<Lead>) Con.getRecords() : new List<Lead>();
    }
    
    public void calculateTotalAmount(List<sObject> data, String totalFieldName){
        summedupamount = 0.00;
        for(sObject item: data){
            if(item.get(totalFieldName) != null){
                summedupamount += (Decimal)item.get(totalFieldName);
            }
        }
    }
    public void calculateTotalAmountCur(List<Opportunity_Dashboard__c> data, String totalFieldName){
        current_total = 0.00;
        system.debug('data: '+JSON.serialize(data));
        for(Opportunity_Dashboard__c item: data){

                try{
                    if(item.Opportunity__r != null && item.Opportunity__r.get(totalFieldName) != null){
                        current_total += (Decimal)item.Opportunity__r.get(totalFieldName);
                    }
                } catch(Exception e){
                    system.debug('error: '+e.getMessage());
                }
            
        }
    }

    public List<SObject> getlist_opps_big (){
        return list_opps_big;
    }
    public ListOfRecordsController() {
        this.BuildQuery();
        opp_dashb_query = 'SELECT Id, Name,Opportunity__r.Name, Opportunity_GL_Var_1__r.Name, Opportunity_GL_Var_1__c,Opportunity__r.AccountId, Opportunity__r.ExpectedRevenue,Opportunity__r.CreatedDate, Opportunity_Created_Date__c, Opportunity__r.LeadSource , Opportunity_Expected_Revenue__c, Opportunity__r.lastactivitydate, Opportunity__r.Newly_Submitted_Quote_First_Date__c , Opportunity__r.Closed_Date__c , Opportunity__r.StageName , Opportunity__r.Closedate , Opportunity__r.ForecastCategoryName , Opportunity__r.Awarded_Owner__c , Opportunity__r.Loss_Reason__c , Opportunity__r.Probability , Opportunity__r.IsWon , Opportunity__r.Price_Level__c , Opportunity__r.Sales_Rep_O__c , Opportunity__r.LastModifiedById , Opportunity__r.LastModifiedDate, Opportunity__r.Amount, Has_Activity_In_Last_Month__c, Inserting_Year__c, Inserting_Month__c,Opportunity_Neglected_Days__c,Opportunity__c, Opportunity_Lead_Source__c, Opportunity_StageName__c, Amount__c,Opportunity_Forecast_Category__c FROM Opportunity_Dashboard__c ';
        so_dashb_query = 'SELECT Id, OwnerId, IsDeleted, Name, Sales_Rep_Team__r.Name, Manufacturer_Rep__r.Name, Sales_Order__r.Name, Sales_Order__r.CreatedDate, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Applied_Amount__c, Approval_Date__c, Balance__c, Billed_Amount__c, Billing_Account__c, Billing_Amount_Due__c, Billing_Balances__c, Billing_City__c, Billing_Country__c, Billing_Days_Due__c, Billing_Deposit__c, Billing_Name__c, Billing_PostalCode__c, Billing_State__c, Billing_Street__c, Billing_Terms_Name__c, Commissions_Balance__c, Commissions_Paid_New__c, Commissions_Total_New__c, Commissions_Unpaid_New__c, Contact__c, Credit_Card_Fee_Sales_Order__c, Customer__c, Customer_s_ETA__c, Deposit__c, Estimated_Shipping_Date__c, GL_Account_Variable_1__c, GL_Address__c, Import_Information__c, LeadSource__c, Ledger__c, Manufacturer_Rep__c, Note__c, Opportunity__c, OtherAmountIsGreaterThanTotal__c, Owner_Custom__c, Paid_Amount__c, PO_Count__c, PO_Date__c, PO_Number__c, Price_Level__c, Project__c, Received_Amount__c, Referral_Sales_Rep__c, Returned_Order__c, Sales_Order_Format__c, Sales_Order__c, Sales_Rep_Team__c, Sales_Rep_Shadow__c, Salesrep_Is_Owner__c, Shipment_Count__c, Shipping_Account__c, Shipping_City__c, Shipping_Country__c, Shipping_Name__c, Shipping_PostalCode__c, Shipping_State__c, Shipping_Street__c, Shipping_Term__c, Special_Instruction__c, Specified_Rep__c, Stage__c, Status__c, Sum_of_Bills__c, Total_With_Fee__c, Total_Without_Fee__c, Total_Adjustment_Amount__c, Total_Credit_Memo__c, Total_Product_Received__c, Total_Products_Quantity__c, Total_Quantity_Shipped__c, Total_Sales_Tax__c, Visible_in_Dashboard__c, RecordTypeName__c, Inserting_Date__c, Inserting_Month__c, Inserting_Year__c, Month_Year__c FROM Sales_Order_Dashboard__c ';
        opp_dashboards = new List<Opportunity_Dashboard__c>();
        so_dashboards = new List<Sales_Order_Dashboard__c>();
        list_opps_big = new List<SObject>();
        
        
        summedupamount = 0.00;
        
        ShowState = false;
        size = 100;
        isOrders = false;
        isOpptys = false;
        isBillings = false;
        isLeads = false;
        isTasks = false;
        isAccounts = false;
        
        showNeglectedField = false;
        showactivedate = false;
        showSubmittedDate = false;
        ShowClosedDate = false;
        ShowCloseDate = false;
        ShowLossReason = false;
        isTest = Test.isRunningTest();
        
        ShowFC = false;
        showProb = false;
        ShowER = false;
        ShowWon = false;
        ShowModBy = false;
        ShowModDate = false;
        
        ShowOwner = false;
        showAwardedOwner = false;
        showDueDate = false;
        


        oppDashbShowStageField = false;




        TotalAmount = 0.00;
        
        d = date.today();
        
        NeglectedDaysMap = new Map<id, integer>();
        UserAndTeams_Map = new Map<String, Set<String>>();
        usersNames = new Set<String>();
        
        MonthStart = Date.newInstance(d.year(), d.month(), 1);
        MonthEnd = Date.newInstance(
            d.year(),
            d.month(),
            Date.daysInMonth(d.year(), d.month())
        );
        LastYearMonthStart = Date.newInstance(d.year() - 1, d.month(), 1);
        LastYearMonthEnd = Date.newInstance(
            d.year() - 1,
            d.month(),
            Date.daysInMonth(d.year() - 1, d.month())
        );
        
        CMonthStart = FindMonthStartDate(d.year(), d.month());
        CMonthEnd = FindMonthEndDate(d.year(), d.month());
        CLastYearMonthStart = FindMonthStartDate(d.year() - 1, d.month());
        CLastYearMonthEnd = FindMonthEndDate(d.year() - 1, d.month());
        
        LoggedInUserId = UserInfo.getUserId();
        LoggedInUserName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        
        chart = ApexPages.currentPage().getParameters().get('chart'); // chart name
        title = ApexPages.currentPage().getParameters().get('title'); // title to show on visualforce page
        click = ApexPages.currentPage().getParameters().get('click'); // chart,bar,legend
        duration = ApexPages.currentPage().getParameters().get('duration'); // TM, LYTM, LY, TY etc.
        str = ApexPages.currentPage().getParameters().get('str'); // leadsource, stagename etc.
        dashboard = ApexPages.currentPage().getParameters().get('dashboard'); // SD, SMD_USA, SMD_CHK
        
        //---------------For Last Twelve Months
        // find how many months have passed in this year
        Integer Months_Passed = d.month();
        
        // TM = Twelve Months
        
        Integer Common_Start_Year = (Months_Passed < 12) ? d.year() - 1 : d.year();
        Integer Common_Start_Month = d.month() < 12 ? d.month() + 1 : 1;
        
        Only_Start_Date = Date.newInstance(Common_Start_Year, Common_Start_Month, 1);
        Only_End_Date = Date.Today();
        
        //Full_Start_Date = DateTime.newInstance(Common_Start_Year, Common_Start_Month, 1, 0, 0, 0);
        
        String sdate_str = Common_Start_Year + '-'+ Common_Start_Month+'-01T00:00:00.000Z';
        Full_Start_Date = DateTime.ValueofGmt(sdate_str.replace('T', ' '));
        Full_End_Date = DateTime.now();
        
        // Graph title correction
        if (title == 'Newly Submitted Opportunities') {
            title = 'Newly Submitted Quotes';
        }
        
        All_SalesReps = new Set<string>();
        Active_SalesReps = new Set<string>();
        All_SalesReps_USA = new Set<string>();
        Active_SalesReps_USA = new Set<string>();
        All_SalesReps_CHK = new Set<string>();
        Active_SalesReps_CHK = new Set<string>();
        
        /* ---------------------------------- Common Sales Reps compilation -------------------------------- */
        // Becuase we are getting the all sales rep name containing record by GL Account Variable i.e Seawin USA/Seawin China or HK
        
        List<sales_rep__c> All_SalesReps_List = [
            SELECT name
            FROM sales_rep__c
            WHERE name != 'Murtaza Ashraf' AND name != 'Ashraf Murtaza'
        ];
        if (!All_SalesReps_List.isEmpty()) {
            for (Sales_rep__c all_sales : All_SalesReps_List) {
                All_SalesReps.add(all_sales.name);
            }
        }
        List<sales_rep__c> Active_Sales_Reps_List = [
            SELECT name
            FROM sales_rep__c
            WHERE
            Active__c = 'Yes'
            AND name != 'Murtaza Ashraf'
            AND name != 'Ashraf Murtaza'
        ];
        if (!Active_Sales_Reps_List.isEmpty()) {
            for (Sales_rep__c active_reps : Active_Sales_Reps_List) {
                Active_SalesReps.add(active_reps.name);
            }
        }
        
        List<sales_rep__c> All_SalesReps_List_USA = [
            SELECT name
            FROM sales_rep__c
            WHERE
            name != 'Murtaza Ashraf'
            AND name != 'Ashraf Murtaza'
        ];
        if (!All_SalesReps_List_USA.isEmpty()) {
            for (Sales_rep__c all_sales : All_SalesReps_List_USA) {
                All_SalesReps_USA.add(all_sales.name);
            }
        }
        List<sales_rep__c> Active_Sales_Reps_List_USA = [
            SELECT name
            FROM sales_rep__c
            WHERE
            Active__c = 'Yes'
            AND name != 'Murtaza Ashraf'
            AND name != 'Ashraf Murtaza'
        ];
        if (!Active_Sales_Reps_List_USA.isEmpty()) {
            for (Sales_rep__c active_reps : Active_Sales_Reps_List_USA) {
                Active_SalesReps_USA.add(active_reps.name);
            }
        }
        
        List<sales_rep__c> All_SalesReps_List_CHK = [
            SELECT name
            FROM sales_rep__c
            WHERE
            name != 'Murtaza Ashraf'
            AND name != 'Ashraf Murtaza'
        ];
        if (!All_SalesReps_List_CHK.isEmpty()) {
            for (Sales_rep__c all_sales : All_SalesReps_List_CHK) {
                All_SalesReps_CHK.add(all_sales.name);
            }
        }
        List<sales_rep__c> Active_Sales_Reps_List_CHK = [
            SELECT name
            FROM sales_rep__c
            WHERE
            Active__c = 'Yes'
            AND name != 'Murtaza Ashraf'
            AND name != 'Ashraf Murtaza'
        ];
        if (!Active_Sales_Reps_List_CHK.isEmpty()) {
            for (Sales_rep__c active_reps : Active_Sales_Reps_List_CHK) {
                Active_SalesReps_CHK.add(active_reps.name);
            }
        }
        
        // compilation ends
        
        if (dashboard == 'SMD_USA') {
            // For USA users
            
            All_Users_USA = new Set<string>();
            Active_Users_USA = new Set<string>();
            Inside_Sales_Users_USA = new Set<string>();
            Inside_Sales_Users_USA_Id = new Set<string>();
            
            /* ---------------------------------- USA Users and Sales Reps compilation -------------------------------- */
            
            // All users
            List<User> All_Users_USA_List = [
                SELECT name
                FROM user
                WHERE
                name != 'Murtaza Ashraf'
                AND name != 'Ashraf Murtaza'
                AND default_gl_account_variable__c INCLUDES ('Seawin USA')
            ];
            
            if (!All_Users_USA_List.isEmpty()) {
                for (User all_usrs : All_Users_USA_List) {
                    All_Users_USA.add(all_usrs.name);
                }
            }
            
            // Active users
            List<User> Active_Users_USA_List = [
                SELECT name
                FROM user
                WHERE
                isActive = TRUE
                AND name != 'Murtaza Ashraf'
                AND name != 'Ashraf Murtaza'
                AND default_gl_account_variable__c INCLUDES ('Seawin USA')
            ];
            
            if (!Active_Users_USA_List.isEmpty()) {
                for (User active_usr : Active_Users_USA_List) {
                    Active_Users_USA.add(active_usr.name);
                }
            }
            
            List<User> Inside_Sales_Users_List_USA = [
                SELECT id, name
                FROM user
                WHERE
                default_gl_account_variable__c INCLUDES ('Seawin USA')
                AND Profile.name LIKE '%Inside Sales%'
                AND name != 'Murtaza Ashraf'
                AND name != 'Ashraf Murtaza'
            ];
            
            if (!Inside_Sales_Users_List_USA.isEmpty()) {
                for (User inside_usrs_usa : Inside_Sales_Users_List_USA) {
                    Inside_Sales_Users_USA.add(inside_usrs_usa.name);
                    Inside_Sales_Users_USA_Id.add(inside_usrs_usa.id);
                }
            }
            
            if (isTest) {
                All_Users_USA.add('Murtaza Ashraf');
                Active_Users_USA.add('Murtaza Ashraf');
                Inside_Sales_Users_USA.add('Murtaza Ashraf');
            }
        }
        
        if (dashboard == 'SMD_CHK') {
            All_Users_CHK = new Set<string>();
            Active_Users_CHK = new Set<string>();
            Inside_Sales_Users_CHK = new Set<string>();
            Inside_Sales_Users_CHK_Id = new Set<string>();
            
            /* ---------------------------------- Seawin China/Hong Kong Users and Sales Reps compilation -------------------------------- */
            
            // All users
            List<User> All_Users_CHK_List = [
                SELECT name
                FROM user
                WHERE
                name != 'Murtaza Ashraf'
                AND name != 'Ashraf Murtaza'
                AND (default_gl_account_variable__c INCLUDES ('Seawin China')
                     OR default_gl_account_variable__c INCLUDES ('Seawin Hong Kong'))
            ];
            
            if (!All_Users_CHK_List.isEmpty()) {
                for (User all_usrs : All_Users_CHK_List) {
                    All_Users_CHK.add(all_usrs.name);
                }
            }
            
            // Active users
            List<User> Active_Users_CHK_List = [
                SELECT name
                FROM user
                WHERE
                isActive = TRUE
                AND name != 'Murtaza Ashraf'
                AND name != 'Ashraf Murtaza'
                AND (default_gl_account_variable__c INCLUDES ('Seawin China')
                     OR default_gl_account_variable__c INCLUDES ('Seawin Hong Kong'))
            ];
            
            if (!Active_Users_CHK_List.isEmpty()) {
                for (User active_usr : Active_Users_CHK_List) {
                    Active_Users_CHK.add(active_usr.name);
                }
            }
            
            List<User> Inside_Sales_Users_CHK_List = [
                SELECT id,name
                FROM user
                WHERE
                default_gl_account_variable__c INCLUDES (
                    'Seawin China',
                    'Seawin Hong Kong'
                )
                AND Profile.name LIKE '%Inside Sales%'
                AND name != 'Murtaza Ashraf'
                AND name != 'Ashraf Murtaza'
            ];
            
            if (!Inside_Sales_Users_CHK_List.isEmpty()) {
                for (User inside_users_CHK : Inside_Sales_Users_CHK_List) {
                    Inside_Sales_Users_CHK.add(inside_users_CHK.name);
                    Inside_Sales_Users_CHK_Id.add(inside_users_CHK.id);
                }
            }
            
            // Only valid for testing purposes
            if (isTest) {
                All_Users_CHK.add('Murtaza Ashraf');
                Active_Users_CHK.add('Murtaza Ashraf');
                Inside_Sales_Users_CHK.add('Murtaza Ashraf');
            }
        }
        
        if (isTest) {
            All_SalesReps.add('Murtaza Ashraf');
            Active_SalesReps.add('Murtaza Ashraf');
            All_SalesReps_USA.add('Murtaza Ashraf');
            Active_SalesReps_USA.add('Murtaza Ashraf');
            All_SalesReps_CHK.add('Murtaza Ashraf');
            Active_SalesReps_CHK.add('Murtaza Ashraf');
        }
        
        str2 = str;
        str3 = str;
        
        if (str == 'N/A' || str == 'NA') {
            str = '';
            str2 = 'NA';
            str3 = 'N/A';
        }
        
        if (dashboard == 'FD')
            this.Financial_Dashboard();
        if (dashboard == 'SD')
            this.Sales_Dashboard();
        if (dashboard == 'SMD_USA')
            this.Sales_Manager_Dashboard_USA();
        if (dashboard == 'SMD_CHK')
            this.Sales_Manager_Dashboard_CHK();
    }
    
    public void BuildQuery() {
        
        // Sales Orders
        String fields = AllFields.Fields(
            'AcctSeedERP__Sales_Order__c',
            new List<String>()
        );
        
        QueryOrders = 'SELECT ';
        QueryOrders += fields + ',AcctSeedERP__Opportunity__r.Leadsource';
        QueryOrders += ' FROM AcctSeedERP__Sales_Order__c where ';
        
        // Opportunities
        fields = AllFields.Fields('Opportunity', new List<String>());
        
        QueryOpportunities = 'SELECT ';
        QueryOpportunities += fields + ',Owner.Name';
        QueryOpportunities += ' FROM Opportunity where ';
        
        amountQuery = 'SELECT Id, Amount, Owner.Name,ExpectedRevenue  FROM Opportunity where ';
        // Accounts
        fields = AllFields.Fields('Account', new List<String>());
        
        QueryAccounts = 'SELECT ';
        QueryAccounts += fields;
        QueryAccounts += ' FROM Account where ';
        
        // Tasks
        fields = AllFields.Fields('Task', new List<String>());
        
        QueryTasks = 'SELECT ';
        QueryTasks += fields;
        QueryTasks += ' FROM Task where ';
        
        // Billings
        fields = AllFields.Fields('AcctSeed__Billing__c', new List<String>());
        
        QueryBillings = 'SELECT ';
        QueryBillings += fields;
        QueryBillings += ' FROM AcctSeed__Billing__c where ';
        
        // Leads
        fields = AllFields.Fields('Lead', new List<String>());
        
        QueryLeads = 'SELECT ';
        QueryLeads += fields + ',CreatedBy.name';
        QueryLeads += ' FROM Lead where ';
    }
    
    public string Build_Query_Helper() {
        user usr = [
            SELECT default_gl_account_variable__c
            FROM user
            WHERE id = :userinfo.getUserId()
            LIMIT 1
        ];
        
        string queryHelper = '';
        
        if (usr.default_gl_account_variable__c != null) {
            List<string> RegionList = usr.default_gl_account_variable__c.split(';');
            
            set<String> RegionSet = new Set<String>(REgionLIst);
            
            integer len = RegionSet.size();
            integer i = 1;
            
            if (len > 1) {
                queryHelper += ' ( ';
            }
            
            for (String str : RegionSet) {
                queryHelper +=
                    'GL_Account_Variable_1__c =\'' +
                    str +
                    '\'' +
                    ((i < len && len > 1) ? ' Or ' : '');
                
                i++;
            }
            
            if (len > 1) {
                queryHelper += ' ) ';
            }
            
            queryHelper += ' And ';
        }
        
        return queryHelper;
    }
    
    public void Financial_Dashboard() {
        String queryHelper = Build_Query_Helper();
        
        if (chart == 'Billing_Aging_FD') {
            isBillings = true;
            string Closed = 'Closed';
            string Posted = 'Posted';
            string CreditMemo = 'Credit Memo';
            
            String QueryStr = QueryBillings;
            QueryStr += ' AcctSeed__Status__c =:Posted and AcctSeed__Type__c !=:CreditMemo and ';
            QueryStr += queryHelper;
            
            if (click == 'chart') {
                QueryStr += ' AcctSeed__Age__c !=:Closed ';
            } else if (click == 'bar') {
                QueryStr += ' AcctSeed__Age__c = :str ';
            }
            QueryStr += ' order by AcctSeed__Age__c asc, AcctSeed__Balance__c desc ';
            
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }
    }
    
    public void Sales_Dashboard() {
        if (chart == 'Quota_YTD') {
            isOrders = true;
            String FullName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            
            DateTime YearStartDate = FindMonthStartDate(d.year(), 1);
            
            DateTime YearToDateDate = DateTime.now();
            
            String QueryStr = QueryOrders;
            QueryStr += ' CreatedDate >=: YearStartDate and CreatedDate <=: YearToDateDate';
            QueryStr += ' and Owner.name =:FullName ';
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Sales_By_Lead_Source_Last_12_Months') {
            isOrders = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = ApexPages.currentPage().getParameters().get('str');
            
            if(str == 'N/A' || str == 'NA'){
                
                str = '';
                str2 = 'N/A';
                str2 = 'NA';
            }
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SalesMonthStart = FindMonthStartDate(year, month);
            DateTime SalesMonthEnd = FindMonthEndDate(year, month);
            
            List<opportunity> oppsChildList = new List<opportunity>();
            
            // get all sales rep name who are related to the logged in user gl variable
            showActiveDate = true;
            
            //---------------
            
            string QueryStr = QueryOrders;
            QueryStr += ' ownerId = \'' + LoggedInUserId + '\'';
            
            if (click == 'chart') {
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
            } else if (click == 'bar') {
                QueryStr += str == '' ? ' and (AcctSeedERP__Opportunity__r.Leadsource = \'' + str + '\'' : 
                ' and AcctSeedERP__Opportunity__r.Leadsource = \'' + str + '\'';
                QueryStr += str == '' ? ' or AcctSeedERP__Opportunity__r.Leadsource = \'' + str2 + '\'' : '';
                QueryStr += str == '' ? ' or AcctSeedERP__Opportunity__r.Leadsource = \'' + str3 + '\')' : '';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <=:SalesMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += str == '' ? ' and (AcctSeedERP__Opportunity__r.Leadsource = \'' + str + '\'' : 
                ' and AcctSeedERP__Opportunity__r.Leadsource = \'' + str + '\'';
                QueryStr += str == '' ? ' or AcctSeedERP__Opportunity__r.Leadsource = \'' + str2 + '\'' : '';
                QueryStr += str == '' ? ' or AcctSeedERP__Opportunity__r.Leadsource = \'' + str3 + '\')' : '';
                
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
            } else if (click == 'left') {
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <:SalesMonthEnd ';
            }
            QueryStr += ' order by AcctSeedERP__Opportunity__r.Leadsource asc, CreatedDate desc';
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Monthly_Sales_Last_12_Months') {
            isOrders = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = ApexPages.currentPage().getParameters().get('str');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SalesMonthStart = FindMonthStartDate(year, month);
            DateTime SalesMonthEnd = FindMonthEndDate(year, month);
            
            system.debug('SalesMonthStart: '+SalesMonthStart);
            system.debug('SalesMonthEnd: '+SalesMonthEnd);
            system.debug('str: '+str);
            // get all sales rep name who are related to the logged in user gl variable
            showActiveDate = true;
            
            string QueryStr = QueryOrders;
            QueryStr += ' Owner.name != \'Murtaza Ashraf\' ';
            QueryStr += ' and OwnerId =:LoggedInUserId ';
            QueryStr += ' and AcctSeederp__total__c > 0 ';
            
            if (click == 'chart') {
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date ';
            } else if (click == 'bar') {
                QueryStr += ' and Sales_Rep_o__r.Name = \'' + str + '\'';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <=:SalesMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and Sales_Rep_o__r.Name = \'' + str + '\'';
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date ';
            }
            QueryStr += ' order by sales_rep_o__r.name asc, CreatedDate desc';
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Sales_Forecast_Pipeline_By_Lead_Source') {
            isOpptys = true;
            ShowCloseDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = ApexPages.currentPage().getParameters().get('str');
            
            if(str == 'N/A' || str == 'NA') {
                str = '';
                str2 = 'N/A';
                str3 = 'NA';
            }
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date ForecastMonthStart = Date.newInstance(year, month, 1);
            Date ForecastMonthEnd = Date.newInstance(
                year,
                month,
                Date.daysInMonth(year, month)
            );
            
            Date Pipeline_Start_Date = Date.newInstance(d.Year(), d.Month(), 1);
            Date Future_Date = Pipeline_Start_Date.addMonths(11);
            
            Date Pipeline_End_Date = Date.newInstance(
                Future_Date.year(),
                Future_Date.month(),
                Date.daysInMonth(Future_Date.year(), Future_Date.month())
            );
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' ForecastCategoryName = \'Pipeline\' ';
            QueryStr += ' and ownerId = \'' + LoggedInUserId + '\'';
            
            if (click == 'chart') {
                QueryStr += ' and CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date ';
            } else if (click == 'bar') {
                QueryStr += str == '' ? ' and (LeadSource = \'' + str + '\'' : ' and LeadSource = \'' + str + '\'';
                QueryStr += str == '' ? ' or LeadSource = \'' + str2 + '\'' : '';
                QueryStr += str == '' ? ' or LeadSource = \'' + str3 + '\')' : '';
                QueryStr += duration == 'Missed'
                    ? ' and CloseDate <:Pipeline_Start_Date '
                    : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += str == '' ? ' and (LeadSource = \'' + str + '\'' : ' and LeadSource = \'' + str + '\'';
                QueryStr += str == '' ? ' or LeadSource = \'' + str2 + '\'' : '';
                QueryStr += str == '' ? ' or LeadSource = \'' + str3 + '\')' : '';
                QueryStr += ' and CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date ';
            } else if (click == 'left') {
                QueryStr += duration == 'Missed'
                    ? ' and CloseDate <:Pipeline_Start_Date '
                    : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
            }
            
            QueryStr += ' order by Name,Probability desc NULLS LAST';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Sales_Forecast_Pipeline') {
            isOpptys = true;
            ShowCloseDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date ForecastMonthStart = Date.newInstance(year, month, 1);
            Date ForecastMonthEnd = Date.newInstance(
                year,
                month,
                Date.daysInMonth(year, month)
            );
            
            Date Pipeline_Start_Date = Date.newInstance(d.Year(), d.Month(), 1);
            Date Pipeline_End_Date = d.addMonths(11);
            Pipeline_End_Date = Date.newInstance(
                Pipeline_End_Date.year(),
                Pipeline_End_Date.month(),
                Date.daysInMonth(Pipeline_End_Date.year(), Pipeline_End_Date.month())
            );
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' ownerId =:LoggedInUserId ';
            QueryStr += ' and ForecastCategoryName = \'Pipeline\' ';
            
            if (click == 'chart') {
                QueryStr += ' and CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date ';
            } else if (click == 'legend') {
                QueryStr += ' and CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date';
            } else if (click == 'bar') {
                QueryStr += str == 'Missed'
                    ? ' and CloseDate <:Pipeline_Start_Date '
                    : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
            }
            
            QueryStr += ' order by Name,Probability asc NULLS LAST';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Sales_Pipeline_Last_12_Months') {
            /*****************************************************************************************************
            *   @dashboard name  : Sales Pipeline Last 12 Months
            *   @chart name      : Sales_Pipeline_Last_12_Months
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/

            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            String opportunity_dashboard_query = opp_dashb_query;
            opportunity_dashboard_query += ' WHERE Opportunity_Forecast_Category__c =\'Pipeline\' ';
            //opportunity_dashboard_query += ' AND Amount__c != null';
            opportunity_dashboard_query += ' AND Opportunity__r.ownerId =:LoggedInUserId ';
            String max_year;
            String max_month;

            if (click == 'chart'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-'); //Current date for ex if today if 3 March 2022 - here will be 3-2022
                max_year =  year_m[1];
                max_month = year_m[0];
            } else {
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);
            opp_dashboards = table_data;
            system.debug('table_data sales: '+JSON.serialize(table_data));
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');

            // isOpptys = true;
            // showCloseDate = true;
            // ShowClosedDate = true;
            // ShowER = true;
            // ShowProb = true;
            // ShowOwner = true;
            // ShowAwardedOwner = true;
            
            // String yearStr = ApexPages.currentPage().getParameters().get('year');
            // String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            // Integer year = 2020;
            // INteger month = 5;
            
            // if (yearStr != null && yearStr != '') {
            //     year = Integer.valueOf(yearStr);
            // }
            
            // if (monthStr != null && monthStr != '') {
            //     month = Integer.valueOf(monthStr);
            // }
            
            // // Monthly data
            
            // Date PointMonthStart = Date.newInstance(year, month, 1);
            // DateTime PointMonthEnd = FindMonthEndDate(year, month);
            // Date PointMonthEndClosed = Date.newInstance(year, month, 
            //                                             Date.daysInMonth(d.year(), d.month()));
            
            // String QueryStr = QueryOpportunities;
            // QueryStr += ' ownerId =:LoggedInUserId ';
            // QueryStr += ' and Amount != 0 and Amount != null ';
            
            // if (click == 'chart') {
            //     QueryStr += ' and ForecastCategoryName =\'Pipeline\' and createddate <=:Full_End_Date ';
            // } else if (click == 'legend') {
            //     QueryStr += ' and ForecastCategoryName =\'Pipeline\' and createddate <=:Full_End_Date ';
            // } else if (click == 'point') {
            //     QueryStr += ' and ForecastCategoryName =\'Pipeline\' and createddate <=:PointMonthEnd ';
            // }
            
            // QueryStr += ' order by Name';
            // calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            // Con = new ApexPages.StandardSetController(
            //     Database.getQueryLocator(QueryStr)
            // );
            // Con.setPageSize(size);
        } else if (chart == 'Newly_Submitted_Opportunities_Last_12_Months') {
            isOpptys = true;
            ShowSubmittedDate = true;
            ShowER = true;
            ShowProb = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date SubmittedMonthStart = Date.newInstance(year, month, 1);
            Date SubmittedMonthEnd = month == d.month() ? Date.today() : Date.newInstance(
                year,
                month,
                Date.daysInMonth(year, month)
            );
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            //string QueryStr = QueryOpportunities;
            string QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue, (Select Status From Quotes Order By CreatedDate Asc Limit 1) FROM Opportunity where ';
            
            QueryStr += ' (ForecastCategoryName = \'Pipeline\' ';
            QueryStr += ' OR StageName = \'Sleep\' ';
            QueryStr += ' OR StageName = \'Closed Won\' ';
            QueryStr += ' OR StageName = \'Closed Lost\') ';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';
            QueryStr += ' and ownerId = \'' + LoggedInUserId + '\'';
            
            if (click == 'chart') {
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            } else if (click == 'point') {
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'month-point') {
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            }
            
            QueryStr += ' order by Newly_Submitted_Quote_First_Date__c desc';
            
            //Changing the code start
            Set<Id> oppIds = new Set<Id>();
            List<Opportunity> allOppts = Database.query(QueryStr);
            for (Opportunity opp : allOppts) {
                for (Quote qt : opp.Quotes) {
                    if (qt.Status == 'Presented') {
                        oppIds.add(opp.Id);
                    }
                }
            }
            
            QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue FROM Opportunity where Id in :oppIds';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source') {
            isOpptys = true;
            ShowSubmittedDate = true;
            ShowER = true;
            ShowProb = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = ApexPages.currentPage().getParameters().get('str');
            
            if(str == 'N/A' || str == 'NA') {
                str = '';
                str2 = 'N/A';
                str3 = 'NA';
            }
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date SubmittedMonthStart = Date.newInstance(year, month, 1);
            Date SubmittedMonthEnd = month == d.month() ? date.today() : Date.newInstance(
                year,
                month,
                Date.daysInMonth(year, month)
            );
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            //string QueryStr = QueryOpportunities;
            string QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue, (Select Status From Quotes Order By CreatedDate Asc Limit 1) FROM Opportunity where ';
            
            QueryStr += ' (ForecastCategoryName = \'Pipeline\' ';
            QueryStr += ' OR StageName = \'Sleep\' ';
            QueryStr += ' OR StageName = \'Closed Won\' ';
            QueryStr += ' OR StageName = \'Closed Lost\') ';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';
            QueryStr += ' and ownerId = \'' + LoggedInUserId + '\'';
            
            if (click == 'chart') {
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            } else if (click == 'point') {
                QueryStr += str == '' ? ' and (LeadSource = \'' + str + '\'' : ' and LeadSource = \'' + str + '\'';
                QueryStr += str == '' ? ' or LeadSource = \'' + str2 + '\'' : '';
                QueryStr += str == '' ? ' or LeadSource = \'' + str3 + '\')' : '';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += str == '' ? ' and (LeadSource = \'' + str + '\'' : ' and LeadSource = \'' + str + '\'';
                QueryStr += str == '' ? ' or LeadSource = \'' + str2 + '\'' : '';
                QueryStr += str == '' ? ' or LeadSource = \'' + str3 + '\')' : '';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            }
            
            QueryStr += ' order by Newly_Submitted_Quote_First_Date__c desc';
            
            //Changing the code start
            Set<Id> oppIds = new Set<Id>();
            List<Opportunity> allOppts = Database.query(QueryStr);
            for (Opportunity opp : allOppts) {
                for (Quote qt : opp.Quotes) {
                    if (qt.Status == 'Presented') {
                        oppIds.add(opp.Id);
                    }
                }
            }
            
            QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue FROM Opportunity where Id in :oppIds';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Lost_Opportunities') {
            isOpptys = true;
            ShowClosedDate = true;
            ShowLossReason = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date LostOpptyMonthStart = Date.newInstance(year, month, 1);
            Date LostOpptyMonthEnd = month == d.month() ? date.today() : Date.newInstance(
                year,
                month,
                Date.daysInMonth(year, month)
            );
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' StageName = \'Closed Lost\' ';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';
            QueryStr += ' AND ownerId = \'' + LoggedInUserId + '\'';
            
            if (click == 'chart') {
                QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
            } else if (click == 'point') {
                QueryStr += ' and Closed_Date__c >=:LostOpptyMonthStart and Closed_Date__c <=:LostOpptyMonthEnd ';
            } else if (click == 'month-point') {
                QueryStr += ' and Closed_Date__c >=:LostOpptyMonthStart and Closed_Date__c <=:LostOpptyMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
            }
            
            QueryStr += ' order by Closed_Date__c desc';
            
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Lost_Opportunities_Loss_Reasons') {
            isOpptys = true;
            ShowClosedDate = true;
            ShowLossReason = true;
            String str = ApexPages.currentPage().getParameters().get('str');
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date LostOpptyMonthStart = Date.newInstance(year, month, 1);
            Date LostOpptyMonthEnd = month == d.month() ? date.today() : Date.newInstance(
                year,
                month,
                Date.daysInMonth(year, month)
            );
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' StageName = \'Closed Lost\' ';
            QueryStr += ' AND ownerId = \'' + LoggedInUserId + '\'';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';
            
            if (click == 'chart') {
                QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
            } else if (click == 'point') {
                if (str == 'N/A') {
                    QueryStr += ' and Loss_Reason__c =  null ';
                } else {
                    QueryStr += ' AND Loss_Reason__c = \'' + str + '\'';
                }
                QueryStr += ' and Closed_Date__c >=:LostOpptyMonthStart and Closed_Date__c <=:LostOpptyMonthEnd ';
            } else if (click == 'month-point') {
                if (str == 'N/A') {
                    QueryStr += ' and Loss_Reason__c =  null ';
                } else {
                    QueryStr += ' AND Loss_Reason__c = \'' + str + '\'';
                }
                QueryStr += ' and Closed_Date__c >=:LostOpptyMonthStart and Closed_Date__c <=:LostOpptyMonthEnd ';
            } else if (click == 'legend') {
                if (str == 'N/A') {
                    QueryStr += ' and Loss_Reason__c =  null ';
                } else {
                    QueryStr += ' AND Loss_Reason__c = \'' + str + '\'';
                }
                QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
            }
            
            QueryStr += ' order by Closed_Date__c desc';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'YourWinRate_SD') {
            isOpptys = true;
            showClosedDate = true;
            ShowWon = true;
            ShowProb = true;
            
            string GL_Variable = [
                SELECT Default_GL_Account_Variable__c
                FROM user
                WHERE id = :UserInfo.getUserId()
                LIMIT 1
            ][0]
                .Default_GL_Account_Variable__c;
            
            string recordtypename = GL_Variable == 'Seawin USA'
                ? 'Seawin USA Hospitality'
                : 'Seawin China Hospitality';
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            string HelperStr = ' ownerid =:LoggedInUserId and';
            HelperStr += ' RecordType.Name =:recordtypename and';
            HelperStr += ' (StageName = \'Closed Won\' or';
            HelperStr += ' StageName = \'Closed Lost\') ';
            HelperStr += ' and (not Name LIKE:ChangeOrder)';
            HelperStr += ' and (not Name LIKE:MockupOne)';
            HelperStr += ' and (not Name LIKE:MockupTwo)';
            HelperStr += ' and (not Name LIKE:MockupThree)';
            HelperStr += ' and (not Name LIKE:MockupFour)';
            HelperStr += ' order by name asc';
            
            string QueryStr = QueryOpportunities;
            
            if (click == 'bar' && str == 'Negotiation') {
                set<id> HistoryIds = new Set<id>();
                
                for (OpportunityHistory hstry : [
                    SELECT Id, OpportunityId, CreatedDate, StageName, Amount, CloseDate
                    FROM OpportunityHistory
                    WHERE
                    StageName = 'Negotiation'
                    AND Opportunity.RecordType.name = :recordtypename
                    AND Opportunity.ownerid = :LoggedInUserId
                ]) {
                    HistoryIds.add(hstry.OpportunityId);
                }
                QueryStr += ' id in:HistoryIds and';
            }
            
            QueryStr += HelperStr;
            
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Neglected_Opportunities') {
            /*****************************************************************************************************
            *   @dashboard name  : Neglected Opportunities
            *   @chart name      : Neglected_Opportunities
            *   @description     : Put data on list of records Page,depends on input params from front by url(Sales)
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            isOpptys = true;
            ShowModBy = true;
            ShowModDate = true;
            ShowER = true;
            ShowProb = true;
            showNeglectedField = true;

            
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = Apexpages.currentPage().getParameters().get('str');

            String duration_filter = '';

            if(str == '31 - 60 days'){
                duration_filter = ' AND Opportunity_Neglected_Days__c > 30 AND Opportunity_Neglected_Days__c < 61';
            }else if(str == '61 - 90 days'){
                duration_filter = ' AND Opportunity_Neglected_Days__c > 60 AND Opportunity_Neglected_Days__c < 91';
            }else if(str == '91 - 120 days'){
                duration_filter = ' AND Opportunity_Neglected_Days__c > 90 AND Opportunity_Neglected_Days__c < 121';
            }else if(str == 'Over 120 days'){
                duration_filter = ' AND Opportunity_Neglected_Days__c > 120';
            }

            String year_month = system.today().month() + '-' + system.today().year();



            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Month_Year__c =: year_month ';
            opportunity_dashboard_query += ' AND isNeglected__c = true ';
            opportunity_dashboard_query += ' AND Opportunity__r.ownerId =:LoggedInUserId and Parent_Opportunity__c = null ';

            if (click == 'chart') {
                opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name in:All_SalesReps_USA';
            } else if(click == 'legend' || click == 'point') {
                opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name = \'' + str + '\'';
            }
            if(click == 'bar'){
                opportunity_dashboard_query += duration_filter;
            }
            // bar chart


            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        } else if (chart == 'Active_Opportunities_By_Stage') {
            /*****************************************************************************************************
            *   @dashboard name  : Active Opportunities by Stage
            *   @chart name      : Active_Opportunities_By_Stage
            *   @description     : Put data on list of records Page,depends on input params from front by url(Sales)
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            isOpptys = true;
            ShowER = true;
            ShowProb = true;
            showCloseDate = true;
            User usr = SalesDashboardController.getUser();
        
            string recordtypename = usr.Default_GL_Account_Variable__c == 'Seawin USA' ? 'Seawin USA Hospitality' : 'Seawin China Hospitality';
            String year_month = system.today().month() + '-' + system.today().year();
            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Month_Year__c =: year_month ';
            opportunity_dashboard_query += ' AND Opportunity__r.ownerId = \''+UserInfo.getUserId()+'\'';
            // opportunity_dashboard_query += ' AND Has_Activity_In_Last_Month__c = true';
            opportunity_dashboard_query += ' AND Amount__c != NULL';
            

            if (click == 'chart') {
            }else{
                opportunity_dashboard_query += ' and Opportunity_StageName__c = \'' + duration + '\'';
            }
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;

            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        } else if (chart == 'Tasks_Completion') {
            isTasks = true;
            string DateStr = '';
            
            if (duration == 'ODT') {
                DateStr += ' ActivityDate <: d and';
                DateStr += ' ActivityDate != null and status = \'Open\'';
            } else if (duration == 'OTT') {
                DateStr += ' ActivityDate >: d and ';
                DateStr += ' ActivityDate != null and status = \'Open\'';
            } else if (duration == 'NDT') {
                DateStr += ' ActivityDate=null and status=\'Open\'';
            } else {
                DateStr += ' ((ActivityDate <: d and';
                DateStr += ' ActivityDate != null and status = \'Open\')';
                
                DateStr += ' or (ActivityDate >: d and ';
                DateStr += ' ActivityDate != null and status = \'Open\')';
                
                DateStr += ' or (ActivityDate=null and status=\'Open\'))';
            }
            
            DateStr += ' and ownerId =:LoggedInUserId';
            
            string QueryStr = QueryTasks;
            
            if (click == 'chart') {
                QueryStr += DateStr;
            } else if (click == 'legend' || click == 'bar') {
                QueryStr += DateStr;
            }
            
            QueryStr += ' order by activitydate desc';
            //calculateTotalAmount((List<Task>)Database.query(QueryStr), 'AcctSeed__Total__c');

            //allOpportunities = (List<Opportunity>)Database.query(QueryStr);
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }
    }
    
    public void Sales_Manager_Dashboard_USA() {
        if (chart == 'Billing_Aging_SMD') {
            isBillings = true;
            string Closed = 'Closed';
            string Posted = 'Posted';
            string CreditMemo = 'Credit Memo';
            
            String QueryStr = QueryBillings;
            QueryStr += ' AcctSeed__Status__c =:Posted and AcctSeed__Type__c !=:CreditMemo and ';
            QueryStr += ' Owner.name in:All_Users_USA and ';
            QueryStr += ' GL_Account_Variable_1__c =\'Seawin USA\' and ';
            
            if (click == 'chart') {
                QueryStr += ' AcctSeed__Age__c !=:Closed ';
            } else if (click == 'bar') {
                QueryStr += ' AcctSeed__Age__c =:str ';
            }

            QueryStr += ' order by AcctSeed__Age__c asc, AcctSeed__Balance__c desc ';
            //! Checked does contains Billing Aging
            calculateTotalAmount((List<AcctSeed__Billing__c>)Database.query(QueryStr), 'AcctSeed__Balance__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if(chart == 'New_Leads_SMD'){
            isLeads = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            Integer month = 5;
            
            if (yearStr != null && yearStr != '') {
                DateTime TD = Date.today();
                DateTime PrevDate = DateTime.newInstance(
                    TD.year() - 1,
                    TD.month(),
                    Date.daysInMonth(TD.year() - 1, TD.month())
                );
                
                String TodayYearShort = TD.format('YY');
                String PrevYearShort = PrevDate.format('YY');
                
                if (
                    Integer.ValueOf(yearStr) == TD.Year() ||
                    Integer.ValueOf(yearStr) == PrevDate.Year()
                ) {
                    Year = Integer.ValueOf(yearStr) == TD.Year()
                        ? TD.Year()
                        : PrevDate.Year();
                } else {
                    Year = (yearStr == TodayYearShort) ? TD.Year() : PrevDate.Year();
                }
            }
            
            Boolean JustYear = false;
            String DateStr = '';
            
            DateTime NewLeadsMonthStart;
            DateTime NewLeadsMonthEnd;
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
                
                NewLeadsMonthStart = FindMonthStartDate(year, month);
                NewLeadsMonthEnd = DateTime.now();
            } else {
                DateStr += (Year == d.year())
                    ? ' CreatedDate = THIS_YEAR'
                    : ' CreatedDate = LAST_YEAR ';
                JustYear = true;
            }
            
            string QueryStr = QueryLeads;
            QueryStr += ' status = \'New\' ';
            
            if (click == 'chart') {
                QueryStr += ' and owner.name in:Active_Users_USA ';
                QueryStr += ' and (CreatedDate = THIS_YEAR or CreatedDate = LAST_YEAR) ';
            } else if (click == 'legend') {
                QueryStr += ' and Owner.name in:Active_Users_USA and';
                QueryStr += (JustYear)
                    ? DateStr
                    : ' CreatedDate >=:NewLeadsMonthStart and CreatedDate <=:NewLeadsMonthEnd ';
            } else if (click == 'bar') {
                QueryStr += ' and Owner.Name =  \'' + str + '\' and ';
                QueryStr += (JustYear)
                    ? DateStr
                    : ' CreatedDate >=:NewLeadsMonthStart and CreatedDate <=:NewLeadsMonthEnd ';
            } else if (click == 'left') {
                QueryStr += ' and Owner.Name =  \'' + str + '\'';
            }
            
            QueryStr += ' order by Owner.Name asc,CreatedDate desc';
            //allOpportunities = (List<Opportunity>)Database.query(QueryStr);
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }else if (chart == 'Collection_Performance_SMD') {
            isBillings = true;
            string Closed = 'Closed';
            string Posted = 'Posted';
            string CreditMemo = 'Credit Memo';
            
            String QueryStr = QueryBillings;
            
            if (click == 'chart') {
                QueryStr += ' AcctSeed__Status__c =:Posted and ';
                QueryStr += ' AcctSeed__Age__c !=:Closed and ';
                QueryStr += ' AcctSeed__Type__c !=:CreditMemo and ';
                QueryStr += ' owner.name in:All_Users_USA and ';
                QueryStr += ' GL_Account_Variable_1__c =\'Seawin USA\' ';
                QueryStr += ' order by AcctSeed__Age__c asc, AcctSeed__Balance__c desc ';
            }
            //summedupamount += chart.contains('Billing_Aging') ? billing.AcctSeed__Balance__c : billing.AcctSeed__Total__c;
            //chart == Collection_Performance_SMD and not contain Billing_Aging, and we put AcctSeed__Balance__c field to calc method
            calculateTotalAmount((List<AcctSeed__Billing__c>)Database.query(QueryStr), 'AcctSeed__Balance__c');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Monthly_Sales_Last_12_Months_SMD_H') {
            


            isOrders = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            system.debug('recordTypeName: '+recordTypeName);
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SalesMonthStart = FindMonthStartDate(year, month);
            DateTime SalesMonthEnd = FindMonthEndDate(year, month);
            
            List<opportunity> oppsChildList = new List<opportunity>();
            
            // get all sales rep name who are related to the logged in user gl variable
            showActiveDate = true;
            
            string QueryStr = QueryOrders;
            
            QueryStr += ' AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
            if (click == 'chart') {
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
                // QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'bar') {
                QueryStr += ' and Sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <=:SalesMonthEnd ';
                // QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'legend') {
                QueryStr += ' and Sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
                // QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'left') {
                QueryStr += ' and Sales_rep_o__r.name in:All_SalesReps_USA ';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <:SalesMonthEnd ';
                // QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
            }
            if(recordTypeName != 'All'){
                QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
            }
            
            QueryStr += ' order by Sales_rep_o__r.name asc, CreatedDate desc';
            

            system.debug('Test voloduia: '+QueryStr);
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if(chart == 'Monthly_Sales_Last_12_Months_SMD_Ref'){
            isOrders = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SalesMonthStart = FindMonthStartDate(year, month);
            DateTime SalesMonthEnd = FindMonthEndDate(year, month);
            
            List<opportunity> oppsChildList = new List<opportunity>();
            
            // get all sales rep name who are related to the logged in user gl variable
            showActiveDate = true;
            
            string QueryStr = QueryOrders;
            QueryStr += ' GL_Account_Variable_1__r.Name = \'Seawin USA\' ';
            
            if (click == 'chart') {
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
                QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'bar') {
                QueryStr += ' and Referral_Sales_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <=:SalesMonthEnd ';
                QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'legend') {
                QueryStr += ' and Referral_Sales_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
                QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'left') {
                QueryStr += ' and Referral_Sales_Rep__r.name in:All_SalesReps_USA ';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <:SalesMonthEnd ';
                QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
            }
            QueryStr += ' order by Referral_Sales_Rep__r.name asc, CreatedDate desc';
            
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }else if(chart == 'Monthly_Sales_Last_12_Months_SMD_Man'){
            isOrders = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SalesMonthStart = FindMonthStartDate(year, month);
            DateTime SalesMonthEnd = FindMonthEndDate(year, month);
            
            List<opportunity> oppsChildList = new List<opportunity>();
            
            // get all sales rep name who are related to the logged in user gl variable
            showActiveDate = true;
            
            string QueryStr = QueryOrders;
            QueryStr += ' GL_Account_Variable_1__r.Name = \'Seawin USA\' ';
            
            if (click == 'chart') {
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
                QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'bar') {
                QueryStr += ' and Manufacturer_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <=:SalesMonthEnd ';
                QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'legend') {
                QueryStr += ' and Manufacturer_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
                QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'left') {
                QueryStr += ' and Manufacturer_Rep__r.name in:All_SalesReps_USA ';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <:SalesMonthEnd ';
                QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
            }
            QueryStr += ' order by Manufacturer_Rep__r.name asc, CreatedDate desc';
            
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }else if (chart == 'Current_Sales_Contest_YTD_SMD') {
            isOrders = true;
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');

            string QueryStr = QueryOrders;
            // QueryStr += ' RecordType.name = \'Seawin USA Hospitality\' ';
            // QueryStr += ' and GL_Account_Variable_1__r.Name = \'Seawin USA\' ';
            QueryStr += ' CreatedDate = THIS_YEAR ';
            QueryStr += ' and AcctSeederp__total__c > 0 ';
            
            if (click == 'chart') {
                queryStr += ' and Sales_rep_o__r.name in:Active_SalesReps_USA ';
            } else if (click == 'bar') {
                QueryStr += ' and Sales_rep_o__r.name = \'' + str + '\'';
            }
            if(recordTypeName != 'All'){
                QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
            }

            QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
            QueryStr += ' order by sales_rep_o__r.name asc, CreatedDate desc';
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');
            //allOpportunities = (List<Opportunity>)Database.query(QueryStr);
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } 
        else if (chart == 'Current_Sales_Contest_QTD_SMD') {
            isOrders = true;
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');

            string QueryStr = QueryOrders;
            // QueryStr += ' RecordType.name = \'Seawin USA Hospitality\' ';
            // QueryStr += ' and GL_Account_Variable_1__r.Name = \'Seawin USA\' ';
            QueryStr += ' CreatedDate = THIS_QUARTER ';
            QueryStr += ' and AcctSeederp__total__c > 0 ';
            
            if (click == 'chart') {
                queryStr += ' and Sales_rep_o__r.name in:Active_SalesReps_USA ';
            } else if (click == 'bar') {
                QueryStr += ' and Sales_rep_o__r.name = \'' + str + '\'';
            }
            if(recordTypeName != 'All'){
                QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
            }

            QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';

            QueryStr += ' order by sales_rep_o__r.name asc, CreatedDate desc';
            

            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } 
        else if (chart == 'Current_Sales_Contest_TM_SMD') {
            isOrders = true;
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');

            String QueryStr = ListOfRecordsControllerHelper.Current_Sales_Contest_TM_SMDQuery(QueryOrders, click, str, recordTypeName, Active_SalesReps_USA);
            // string QueryStr = QueryOrders;
            // QueryStr += ' RecordType.name = \'Seawin USA Hospitality\' ';
            // QueryStr += ' and GL_Account_Variable_1__r.Name = \'Seawin USA\' ';
            

            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Team_Quota_YTD_SMD') {
            isOrders = true;
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            DateTime YearStartDate = FindMonthStartDate(d.year(), 1);
            
            DateTime YearToDateDate = DateTime.now();
            
            String QueryStr = QueryOrders;
            QueryStr += ' CreatedDate >=: YearStartDate and CreatedDate <=: YearToDateDate';
            QueryStr += ' AND AcctSeedERP__Status__c != \'Cancelled\' ';

            // QueryStr += ' recordtype.name = \'Seawin USA Hospitality\' ';
            // QueryStr += ' and GL_Account_Variable_1__r.Name = \'Seawin USA\' ';
            QueryStr += ' and Sales_Rep_o__r.name in:All_SalesReps_USA ';
            if(recordTypeName != 'All'){
                QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
            }

            QueryStr += ' order by sales_rep_o__r.name asc, CreatedDate desc';

            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Team_Quota_Percent_SMD') {
            isOrders = true;
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            DateTime YearStartDate = FindMonthStartDate(d.year(), 1);
            
            DateTime YearToDateDate = DateTime.now();
            
            String srsQuery = 'select id, name, Monthly_Quota__c from sales_rep__c where ';
            
            if (click == 'chart') {
                srsQuery += ' name in:All_SalesReps_USA ';
            } else if (click == 'bar') {
                srsQuery += ' name = \'' + str + '\'';
            }
            
            List<Sales_rep__c> SalesRep = Database.Query(srsQuery);
            
            set<string> srNames = new Set<string>();
            
            if (!SalesRep.isEmpty()) {
                for (Sales_rep__c s : salesrep) {
                    if (s.Monthly_Quota__c != null && s.Monthly_Quota__c != 0) {
                        srNames.add(s.name);
                    }
                }
            }
            
            String QueryStr = QueryOrders;
            QueryStr += ' CreatedDate >=: YearStartDate and CreatedDate <=: YearToDateDate';
            // QueryStr += ' recordtype.name = \'Seawin USA Hospitality\' ';
            // QueryStr += ' and GL_Account_Variable_1__r.Name = \'Seawin USA\' ';
            QueryStr += ' and Sales_Rep_o__r.name in:srNames and ';
            QueryStr += ' acctseederp__total__c > 0 ';
            QueryStr += ' AND AcctSeedERP__Status__c != \'Cancelled\' ';

            if(recordTypeName != 'All'){
                QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
            }
            QueryStr += ' order by sales_rep_o__r.name asc, CreatedDate desc';
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Sales_Forecast_Pipeline_SMD') {
            isOpptys = true;
            ShowCloseDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');

            Integer year = 2020;
            INteger month = 5;
            Date d = date.today();
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            Date ForecastMonthStart = Date.newInstance(year, month, 1);
            Date ForecastMonthEnd = Date.newInstance(
                year,
                month,
                Date.daysInMonth(year, month)
            );
            system.debug('ForecastMonthStart: '+ForecastMonthStart);
            Date Pipeline_Start_Date = Date.newInstance(d.Year(), d.Month(), 1);
            Date Future_Date = Pipeline_Start_Date.addMonths(11);
            
            Date Pipeline_End_Date = Date.newInstance(
                Future_Date.year(),
                Future_Date.month(),
                Date.daysInMonth(Future_Date.year(), Future_Date.month())
            );

            String QueryStr = ListOfRecordsControllerHelper.Sales_Forecast_Pipeline_SMDQuery(yearStr, monthStr, recordTypeName, QueryOpportunities, click, str, duration, All_SalesReps_USA);

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            amountQuery += QueryStr.split('where')[1];
            calculateTotalAmount((List<Opportunity>)Database.query(amountQuery), 'ExpectedRevenue');

            Con.setPageSize(size);
        } else if (chart == 'Company_Total_Pipeline_SMD_USA') {
            /*****************************************************************************************************
            *   @dashboard name  : Company Total Pipeline Last 12 Months
            *   @chart name      : Company_Total_Pipeline_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/

            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            oppDashbShowStageField = true;
            
            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            String opportunity_dashboard_query = opp_dashb_query;
            opportunity_dashboard_query += ' WHERE Sales_Rep_Team__r.Name IN:All_SalesReps_USA';
            // opportunity_dashboard_query += ' AND  Opportunity_GL_Var_1__r.Name = \'Seawin USA\' ';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            //opportunity_dashboard_query += ' AND Amount__c != null';

            String max_year;
            String max_month;

            if (click == 'chart'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-'); //Current date for ex if today if 3 March 2022 - here will be 3-2022
                max_year =  year_m[1];
                max_month = year_m[0];
            } else {
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            
            if(recordTypeName != 'All'){
                opportunity_dashboard_query += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('Opportunity__r.recordtype.name', recordTypeName);
            }
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);
            opp_dashboards = table_data;

            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');

        } else if (chart == 'Sales_Reps_Total_Pipeline_SMD_USA') {
            /*****************************************************************************************************
            *   @dashboard name  : Pipeline Last 12 Months by Sales Rep / Team
            *   @chart name      : Sales_Reps_Total_Pipeline_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/

            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            oppDashbShowStageField = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = Apexpages.currentPage().getParameters().get('str');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-');
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE  Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            
            if(recordTypeName != 'All'){
                opportunity_dashboard_query += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('Opportunity__r.recordtype.name', recordTypeName);
            }
            if (click == 'chart') {
                opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name in:All_SalesReps_USA';
            } else if(click == 'legend' || click == 'point') {
                opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name = \'' + str + '\'';
            }
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');


        } else if (chart == 'Total_Pipeline_By_Lead_Source_SMD_USA') {
            /*****************************************************************************************************
            *   @dashboard name  : Pipeline Last 12 Months By Lead Source
            *   @chart name      : Total_Pipeline_By_Lead_Source_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            oppDashbShowStageField = true;

            String str = Apexpages.currentPage().getParameters().get('str');
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            if(str == 'N/A' || str == 'NA') {
                str = '';
                str2 = 'N/A';
                str3 = 'NA';
            }
            
            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();
            
            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-'); //Last available date
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            
            if (click == 'legend' || click == 'point') {
                opportunity_dashboard_query += str == '' ? ' and (Opportunity_Lead_Source__c = \'' + str + '\'' : ' and Opportunity_Lead_Source__c = \'' + str + '\'';
                opportunity_dashboard_query += str == '' ? ' or Opportunity_Lead_Source__c = \'' + str2 + '\'' : '';
                opportunity_dashboard_query += str == '' ? ' or Opportunity_Lead_Source__c = \'' + str3 + '\')' : '';
            } else if(click == 'chart'){
                //If chart than we show all lead sources without filtering by lead source
            }
            
            if(recordTypeName != 'All'){
                opportunity_dashboard_query += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('Opportunity__r.recordtype.name', recordTypeName);
            }
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');

            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');

        } else if (chart == 'Newly_Submitted_Quotes_SMD') {
            isOpptys = true;
            ShowSubmittedDate = true;
            ShowER = true;
            ShowProb = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date SubmittedMonthStart = Date.newInstance(year, month, 1);
            Date SubmittedMonthEnd = month == d.month() ? Date.today() : 
            Date.newInstance(year, month, Date.daysInMonth(year, month));
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' RecordType.name = \'Seawin USA Hospitality\' and ';
            QueryStr += ' GL_Account_Variable_1__r.name = \'Seawin USA\' ';
            QueryStr += ' AND (ForecastCategoryName = \'Pipeline\' ';
            QueryStr += ' OR StageName = \'Sleep\' ';
            QueryStr += ' OR StageName = \'Closed Won\' ';
            QueryStr += ' OR StageName = \'Closed Lost\') ';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';
            
            if (click == 'chart') {
                QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_USA ';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            } else if (click == 'point') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            }
            
            QueryStr += ' order by sales_rep_o__r.name, Newly_Submitted_Quote_First_Date__c desc';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Newly_Submitted_Opportunities_Last_12_Months_SMD') {
            isOpptys = true;
            ShowSubmittedDate = true;
            ShowER = true;
            ShowProb = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date SubmittedMonthStart = Date.newInstance(year, month, 1);
            Date SubmittedMonthEnd = month == d.month() ? Date.today() : 
            Date.newInstance(year, month, Date.daysInMonth(year, month));
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            //string QueryStr = QueryOpportunities;
            string QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue, (Select Status From Quotes Order By CreatedDate Asc Limit 1) FROM Opportunity where ';
            
            // QueryStr += ' RecordType.name = \'Seawin USA Hospitality\' and ';
            // QueryStr += ' GL_Account_Variable_1__r.name = \'Seawin USA\' ';
            QueryStr += '  Type != \'Template\' ';
            // QueryStr += ' OR StageName = \'Sleep\' ';
            // QueryStr += ' OR StageName = \'Closed Won\' ';
            // QueryStr += ' OR StageName = \'Closed Lost\') ';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';

            if(recordTypeName != 'All'){
                QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
            }
            if (click == 'chart') {
                QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_USA ';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            } else if (click == 'point') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'month-point') {
                QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_USA ';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            }
            
            QueryStr += ' order by sales_rep_o__r.name, Newly_Submitted_Quote_First_Date__c desc';
            
            //Changing the code start
            Set<Id> oppIds = new Set<Id>();
            List<Opportunity> allOppts = Database.query(QueryStr);
            for (Opportunity opp : allOppts) {
                for (Quote qt : opp.Quotes) {
                    if (qt.Status == 'Presented') {
                        oppIds.add(opp.Id);
                    }
                }
            }
            
            QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue FROM Opportunity where Id in :oppIds';
            
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source_SMD') {
            isOpptys = true;
            ShowSubmittedDate = true;
            ShowER = true;
            ShowProb = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = ApexPages.currentPage().getParameters().get('str');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            if(str == 'N/A' || str == 'NA') {
                str = '';
                str2 = 'N/A';
                str3 = 'NA';
            }
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date SubmittedMonthStart = Date.newInstance(year, month, 1);
            Date SubmittedMonthEnd = month == d.month() ? Date.today() : 
            Date.newInstance(year, month, Date.daysInMonth(year, month));
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            //string QueryStr = QueryOpportunities;
            string QueryStr = ListOfRecordsControllerHelper.Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source_SMDQuery();
            
            QueryStr += '  Type != \'Template\' ';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';
            QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_USA ';
            
            if (click == 'chart') {
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            } else if (click == 'point') {
                QueryStr += str == '' ? ' and (LeadSource = \'' + str + '\'' : ' and LeadSource = \'' + str + '\'';
                QueryStr += str == '' ? ' or LeadSource = \'' + str2 + '\'' : '';
                QueryStr += str == '' ? ' or LeadSource = \'' + str3 + '\')' : '';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += str == '' ? ' and (LeadSource = \'' + str + '\'' : ' and LeadSource = \'' + str + '\'';
                QueryStr += str == '' ? ' or LeadSource = \'' + str2 + '\'' : '';
                QueryStr += str == '' ? ' or LeadSource = \'' + str3 + '\')' : '';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            }
            if(recordTypeName != 'All'){
                QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
            }
            QueryStr += ' order by sales_rep_o__r.name, Newly_Submitted_Quote_First_Date__c desc';
            
            //Changing the code start
            Set<Id> oppIds = new Set<Id>();
            List<Opportunity> allOppts = Database.query(QueryStr);
            for (Opportunity opp : allOppts) {
                for (Quote qt : opp.Quotes) {
                    if (qt.Status == 'Presented') {
                        oppIds.add(opp.Id);
                    }
                }
            }
            
            QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue FROM Opportunity where Id in :oppIds';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Lost_Opportunities_SMD') {
            isOpptys = true;
            ShowClosedDate = true;
            ShowLossReason = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date LostOpptyMonthStart = Date.newInstance(year, month, 1);
            Date LostOpptyMonthEnd = month == d.month() ? Date.today() : 
            Date.newInstance(year, month, Date.daysInMonth(year, month));
            
            string QueryStr = ListOfRecordsControllerHelper.Lost_Opportunities_SMDQuery(QueryOpportunities,str,recordTypeName,click);
            //calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Loss_Reasons_SMD_USA') {
            String str = ApexPages.currentPage().getParameters().get('str');
            
            isOpptys = true;
            ShowClosedDate = true;
            ShowLossReason = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            


            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            Date LostOpptyMonthStart = Date.newInstance(year, month, 1);
            Date LostOpptyMonthEnd = month == d.month() ? Date.today() : 
            Date.newInstance(year, month, Date.daysInMonth(year, month));
            
            string QueryStr = ListOfRecordsControllerHelper.Loss_Reasons_SMD_USAQuery(QueryOpportunities, click, str, recordTypeName);
            

            amountQuery += QueryStr.split('where')[1];
            calculateTotalAmount((List<Opportunity>)Database.query(amountQuery), 'Amount');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Sales_By_Lead_Source_Last_12_Months_SMD_H') {
            isOrders = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = ApexPages.currentPage().getParameters().get('str');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            if(str == 'N/A' || str == 'NA') {
                str = '';
                str2 = 'N/A';
                str3 = 'NA';
            }
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SalesMonthStart = FindMonthStartDate(year, month);
            DateTime SalesMonthEnd = FindMonthEndDate(year, month);
            
            List<opportunity> oppsChildList = new List<opportunity>();
            
            // get all sales rep name who are related to the logged in user gl variable
            showActiveDate = true;
            
            //---------------
            
            string QueryStr = ListOfRecordsControllerHelper.Sales_By_Lead_Source_Last_12_Months_SMD_HQuery(QueryOrders, click, str, str2, str3, recordTypeName);
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            system.debug('hello: '+JSON.serialize(Database.query(QueryStr)));
            Con.setPageSize(size);
        } else if (chart == 'Sales_Forecast_Pipeline_By_Lead_Source_SMD') {
            isOpptys = true;
            ShowCloseDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = ApexPages.currentPage().getParameters().get('str');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            if(str == 'N/A' || str == 'NA') {
                str = '';
                str2 = 'N/A';
                str3 = 'NA';
            }
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date ForecastMonthStart = Date.newInstance(year, month, 1);
            Date ForecastMonthEnd = Date.newInstance(
                year,
                month,
                Date.daysInMonth(year, month)
            );
            
            Date Pipeline_Start_Date_Start_Date = Date.newInstance(d.Year(), d.Month(), 1);
            Date Future_Date = Pipeline_Start_Date_Start_Date.addMonths(11);
            
            Date Pipeline_Start_Date_End_Date = Date.newInstance(
                Future_Date.year(),
                Future_Date.month(),
                Date.daysInMonth(Future_Date.year(), Future_Date.month())
            );
            
            string QueryStr = ListOfRecordsControllerHelper.Sales_Forecast_Pipeline_By_Lead_Source_SMDQuery(QueryOpportunities, click, str, str2, str3, duration, recordTypeName);
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'ExpectedRevenue');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Active_Opportunities_By_Stage_SMD') {
            /*****************************************************************************************************
            *   @dashboard name  : Active Opportunities by Stage
            *   @chart name      : Active_Opportunities_By_Stage_SMD
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            isOpptys = true;
            ShowER = true;
            ShowProb = true;
            showCloseDate = true;
            
            String str = ApexPages.currentPage().getParameters().get('str');
            String year_month = system.today().month() + '-' + system.today().year();
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');


            String opportunity_dashboard_query = ListOfRecordsControllerHelper.Active_Opportunities_By_Stage_SMDQuery(opp_dashb_query, click, str, recordTypeName);

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);
            list_opps_big = table_data;
            // opp_dashboards = table_data;
            List<Opportunity> opps = new List<Opportunity>();
            for(Opportunity_Dashboard__c opd: table_data){
                opps.add((Opportunity)opd.Opportunity__r);
            }

            Con = new ApexPages.StandardSetController(
                opps
            );
            Con.setPageSize(size);


            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        } else if (chart == 'Neg_Win_Rate_SMD') {
            ShowClosedDate = true;
            ShowWon = true;
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            isOpptys = true;
            
            set<id> eligibleIds = new Set<id>();
            
            if (click == 'chart') {
                for (OpportunityHistory hstry : [
                    SELECT Id, OpportunityId, CreatedDate, StageName, Amount, CloseDate
                    FROM OpportunityHistory
                    WHERE
                    StageName = 'Negotiation'
                    AND Opportunity.RecordType.name = 'Seawin USA Hospitality'
                    AND Opportunity.GL_Account_Variable_1__r.name = 'Seawin USA'
                    AND Opportunity.sales_rep_o__r.name IN :Active_SalesReps_USA
                ]) {
                    eligibleIds.add(hstry.OpportunityId);
                }
            } else if (click == 'bar') {
                for (OpportunityHistory hstry : [
                    SELECT Id, OpportunityId, CreatedDate, StageName, Amount, CloseDate
                    FROM OpportunityHistory
                    WHERE
                    StageName = 'Negotiation'
                    AND Opportunity.RecordType.name = 'Seawin USA Hospitality'
                    AND Opportunity.GL_Account_Variable_1__r.name = 'Seawin USA'
                    AND Opportunity.sales_rep_o__r.name = :str
                ]) {
                    eligibleIds.add(hstry.OpportunityId);
                }
            }
            
            if (Test.isRunningTest()) {
                map<id, opportunity> testMap = new Map<id, opportunity>(
                    [
                        SELECT id
                        FROM opportunity
                        WHERE
                        sales_rep_o__r.name IN :Active_SalesReps_USA
                        AND (StageName = 'Closed Won'
                             OR StageName = 'Closed Lost')
                        LIMIT 5
                    ]
                );
                
                eligibleIds.AddAll(testMap.keyset());
            }
            
            if (eligibleIds.size() > 0) {
                string QueryStr = QueryOpportunities;
                QueryStr += ' RecordType.name = \'Seawin USA Hospitality\' and ';
                QueryStr += ' GL_Account_Variable_1__r.name = \'Seawin USA\' and ';
                QueryStr += ' id in:eligibleIds and ';
                QueryStr += ' (stagename = \'Closed Won\' or stagename = \'Closed Lost\') ';
                QueryStr += ' and (NOT Name LIKE:ChangeOrder) ';
                QueryStr += ' and (NOT Name LIKE:MockupOne) ';
                QueryStr += ' and (NOT Name LIKE:MockupTwo) ';
                QueryStr += ' and (NOT Name LIKE:MockupThree) ';
                QueryStr += ' and (NOT Name LIKE:MockupFour) ';
                
                if (click == 'chart') {
                    QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_USA ';
                } else if (click == 'bar') {
                    QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                }
                QueryStr += ' order by sales_rep_o__r.name asc, stagename desc, closed_date__c desc, Name';
                calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
                Con = new ApexPages.StandardSetController(
                    Database.getQueryLocator(QueryStr)
                );
                Con.setPageSize(size);
            }
        } else if (chart == 'Win_Rate_SMD') {
            ShowClosedDate = true;
            ShowWon = true;
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            isOpptys = true;
            string QueryStr = QueryOpportunities;
            QueryStr += ' RecordType.name = \'Seawin USA Hospitality\' and ';
            QueryStr += ' GL_Account_Variable_1__r.name = \'Seawin USA\' and ';
            QueryStr += ' (stagename = \'Closed Won\' or stagename = \'Closed Lost\') ';
            QueryStr += ' and (NOT Name LIKE:ChangeOrder) ';
            QueryStr += ' and (NOT Name LIKE:MockupOne) ';
            QueryStr += ' and (NOT Name LIKE:MockupTwo) ';
            QueryStr += ' and (NOT Name LIKE:MockupThree) ';
            QueryStr += ' and (NOT Name LIKE:MockupFour) ';
            
            if (click == 'chart') {
                QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_USA ';
            } else if (click == 'bar') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
            }
            QueryStr += ' order by sales_rep_o__r.name asc, stagename desc, closed_date__c desc, Name';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Activity_Graph_Last_12_Months_SMD_USA') {
            /*****************************************************************************************************
            *   @dashboard name  : Activity Graph Last 12 Months
            *   @chart name      : Activity_Graph_Last_12_Months_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            if (String.isNotEmpty(str)) {
                All_SalesReps_USA.clear();
                All_SalesReps_USA.add(str);
            }
            
            List<sales_rep__c> salesReps = [
                SELECT Id, Name, Team__c, inactive_date__c
                FROM sales_rep__c
                WHERE name IN :All_SalesReps_USA
            ];
            // enigma
            map<string, date> SalesRepDateMap = new Map<string, date>();
            
            //Team Logic Start
            set<String> userTeams = new Set<String>();
            
            for (Sales_Rep__c team : salesReps) {
                Set<String> users = UserData_From_Teams(team.Team__c);
                for (string usr : users) {
                    userTeams = new Set<String>();
                    userTeams.add(team.name);
                    
                    if (UserAndTeams_Map.containsKey(usr)) {
                        userTeams.addAll(UserAndTeams_Map.get(usr));
                    }
                    UserAndTeams_Map.put(usr, userTeams);
                }
            }
            
            isOpptys = true;
            showCloseDate = true;

            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = Apexpages.currentPage().getParameters().get('str');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-');
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = ListOfRecordsControllerHelper.Activity_Graph_Last_12_Months_SMD_USAQuery(opp_dashb_query, click, str, recordTypeName);
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;

            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        } else if (chart == 'Neglected_Opportunities_SMD') {
            /*****************************************************************************************************
            *   @dashboard name  : Neglected Opportunities
            *   @chart name      : Neglected_Opportunities_SMD
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            isOpptys = true;
            ShowModBy = true;
            ShowModDate = true;
            ShowER = true;
            ShowProb = true;
            showNeglectedField = true;

            
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = Apexpages.currentPage().getParameters().get('str');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-');
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = ListOfRecordsControllerHelper.Neglected_Opportunities_SMDQuery(opp_dashb_query, click, str, recordTypeName);
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        } else if (chart == 'TopTenAccounts_OD') {
            isOrders = true;
            
            string recordtype = 'Seawin USA Online/Drop Shipment';
            //string recordtype = 'Seawin USA Hospitality';
            
            Set<string> AccountIds = new Set<string>();
            
            List<AggregateResult> TopTen = [
                SELECT sum(acctseederp__total__c), acctseederp__customer__c id
                FROM acctseederp__sales_order__c
                WHERE
                recordtype.name = :recordtype
                AND GL_Account_Variable_1__r.name = 'Seawin USA'
                AND (CreatedDate = THIS_YEAR
                     OR CreatedDate = Last_Year)
                GROUP BY acctseederp__customer__c
                ORDER BY sum(acctseederp__total__c) DESC
                LIMIT 10
            ];
            
            if (!TopTen.isEmpty()) {
                for (aggregateResult a : TopTen) {
                    AccountIds.add((string) a.get('id'));
                }
                
                // get details of these accounts by a detailed soql query
                string QueryStr = QueryOrders;
                QueryStr += ' RecordType.name =:recordtype ';
                QueryStr += ' and GL_Account_Variable_1__r.name = \'Seawin USA\' ';
                QueryStr += ' and (CreatedDate = THIS_YEAR or CreatedDate = Last_Year) ';
                QueryStr += ' and AcctSeedERP__Customer__c in:AccountIds ';
                QueryStr += ' order by AcctSeedERP__Customer__r.name, AcctSeedERP__Total__c desc';
                calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');

                Con = new ApexPages.StandardSetController(
                    Database.getQueryLocator(QueryStr)
                );
                Con.setPageSize(size);
            }
        } else if (chart == 'TopTenShipped_OD') {
            String str = ApexPages.currentPage().getParameters().get('str');
            
            isOrders = true;
            showState = true;
            
            string recordtype = 'Seawin USA Online/Drop Shipment';
            //string recordtype = 'Seawin USA Hospitality';
            
            List<AggregateResult> Aggregates = [
                SELECT Count(id) ct, AcctSeedERP__Shipping_State__c state
                FROM AcctSeedERP__Sales_Order__c
                WHERE
                RecordType.Name = :recordtype
                AND GL_Account_Variable_1__r.name = 'Seawin USA'
                GROUP BY AcctSeedERP__Shipping_State__c
                ORDER BY Count(id) DESC
                LIMIT 10
            ];
            
            set<string> states = new Set<string>();
            
            if (!Aggregates.isEmpty()) {
                for (AggregateResult a : Aggregates) {
                    states.add((string) a.get('state'));
                }
                
                // get details of these accounts by a detailed soql query
                string QueryStr = QueryOrders;
                QueryStr += ' RecordType.name =:recordtype ';
                QueryStr += ' and GL_Account_Variable_1__r.name = \'Seawin USA\' ';
                
                if (click == 'chart') {
                    QueryStr += ' and AcctSeedERP__Shipping_State__c in:states ';
                } else if (click == 'bar') {
                    if (str == 'N/A') {
                        QueryStr += ' and AcctSeedERP__Shipping_State__c =  null ';
                    } else {
                        QueryStr += ' and AcctSeedERP__Shipping_State__c = \'' + str + '\'';
                    }
                }
                
                QueryStr += ' order by AcctSeedERP__Shipping_State__c asc';
                calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');

                Con = new ApexPages.StandardSetController(
                    Database.getQueryLocator(QueryStr)
                );
                Con.setPageSize(size);
            }
        } else if (chart == 'Monthly_Sales_Last_12_Months_SMD_WD') {
            // Online Dropship
            isOrders = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            string recordtype = 'Seawin USA Wholesale Distribution';
            //string recordtype = 'Seawin USA Hospitality';
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SalesMonthStart = FindMonthStartDate(year, month);
            DateTime SalesMonthEnd = FindMonthEndDate(year, month);
            
            // get all sales rep name who are related to the logged in user gl variable
            showActiveDate = true;
            
            string QueryStr = QueryOrders;
            QueryStr += ' RecordType.name =:recordtype ';
            QueryStr += ' and GL_Account_Variable_1__r.name = \'Seawin USA\' ';
            
            if (click == 'chart') {
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_USA ';
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
            } else if (click == 'bar') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <=:SalesMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
            } else if (click == 'left') {
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_USA ';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <=:SalesMonthEnd ';
            }
            QueryStr += ' order by sales_rep_o__r.name asc, CreatedDate desc';
            //allOpportunities = (List<Opportunity>)Database.query(QueryStr);
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'TopTenAccounts_WD') {
            isOrders = true;
            
            string recordtype = 'Seawin USA Wholesale Distribution';
            //string recordtype = 'Seawin USA Hospitality';
            
            Set<string> AccountIds = new Set<string>();
            
            List<AggregateResult> TopTen = [
                SELECT sum(acctseederp__total__c), acctseederp__customer__c id
                FROM acctseederp__sales_order__c
                WHERE
                recordtype.name = :recordtype
                AND GL_Account_Variable_1__r.name = 'Seawin USA'
                AND (CreatedDate = THIS_YEAR
                     OR CreatedDate = Last_Year)
                GROUP BY acctseederp__customer__c
                ORDER BY sum(acctseederp__total__c) DESC
                LIMIT 10
            ];
            
            if (!TopTen.isEmpty()) {
                for (aggregateResult a : TopTen) {
                    AccountIds.add((string) a.get('id'));
                }
                
                // get details of these accounts by a detailed soql query
                string QueryStr = QueryOrders;
                QueryStr += ' RecordType.name =:recordtype ';
                QueryStr += ' and GL_Account_Variable_1__r.name = \'Seawin USA\' ';
                QueryStr += ' and (CreatedDate = THIS_YEAR or CreatedDate = Last_Year) ';
                QueryStr += ' and AcctSeedERP__Customer__c in:AccountIds ';
                QueryStr += ' order by AcctSeedERP__Customer__r.name, AcctSeedERP__Total__c desc';
                calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');

                Con = new ApexPages.StandardSetController(
                    Database.getQueryLocator(QueryStr)
                );
                Con.setPageSize(size);
            }
        } else if (chart == 'TopTenShipped_WD') {
            String str = ApexPages.currentPage().getParameters().get('str');
            
            isOrders = true;
            showState = true;
            
            string recordtype = 'Seawin USA Wholesale Distribution';
            //string recordtype = 'Seawin USA Hospitality';
            
            List<AggregateResult> Aggregates = [
                SELECT Count(id) ct, AcctSeedERP__Shipping_State__c state
                FROM AcctSeedERP__Sales_Order__c
                WHERE
                RecordType.Name = :recordtype
                AND GL_Account_Variable_1__r.name = 'Seawin USA'
                GROUP BY AcctSeedERP__Shipping_State__c
                ORDER BY Count(id) DESC
                LIMIT 10
            ];
            
            set<string> states = new Set<string>();
            
            if (!Aggregates.isEmpty()) {
                for (AggregateResult a : Aggregates) {
                    states.add((string) a.get('state'));
                }
                
                // get details of these accounts by a detailed soql query
                string QueryStr = QueryOrders;
                QueryStr += ' RecordType.name =:recordtype ';
                
                if (click == 'chart') {
                    QueryStr += ' and AcctSeedERP__Shipping_State__c in:states ';
                } else if (click == 'bar') {
                    if (str == 'N/A') {
                        QueryStr += ' and AcctSeedERP__Shipping_State__c =  null ';
                    } else {
                        QueryStr += ' and AcctSeedERP__Shipping_State__c = \'' + str + '\'';
                    }
                }
                
                QueryStr += ' order by AcctSeedERP__Shipping_State__c asc';
                calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');

                Con = new ApexPages.StandardSetController(
                    Database.getQueryLocator(QueryStr)
                );
                Con.setPageSize(size);
            }
        }else if(chart == 'Company_PreOrder_Pipeline_SMD_USA'){
            
            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            String opportunity_dashboard_query = opp_dashb_query;
            opportunity_dashboard_query += ' WHERE Sales_Rep_Team__r.Name IN:All_SalesReps_USA';
            // opportunity_dashboard_query += ' AND  Opportunity_GL_Var_1__r.Name = \'Seawin USA\' ';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Opportunity_StageName__c =\'Pre-Order\' ';
            opportunity_dashboard_query += ' AND Amount__c != null';

            String max_year;
            String max_month;

            if (click == 'chart'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-'); //Current date for ex if today if 3 March 2022 - here will be 3-2022
                max_year =  year_m[1];
                max_month = year_m[0];
            } else {
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }
            
            if(recordTypeName != 'All'){
                opportunity_dashboard_query += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('Opportunity__r.recordtype.name', recordTypeName);
            }
            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);
            opp_dashboards = table_data;

            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        }else if(chart == 'Sales_Reps_PreOrder_Pipeline_SMD_USA'){
            //markkk
            /*****************************************************************************************************
            *   @dashboard name  : Pipeline Last 12 Months by Sales Rep / Team
            *   @chart name      : Sales_Reps_Total_Pipeline_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/

            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = Apexpages.currentPage().getParameters().get('str');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-');
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE  Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Opportunity_StageName__c =\'Pre-Order\' ';
            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';

            if(recordTypeName != 'All'){
                opportunity_dashboard_query += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('Opportunity__r.recordtype.name', recordTypeName);
            }
            if (click == 'chart') {
                opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name in:All_SalesReps_USA';
            } else if(click == 'legend' || click == 'point') {
                opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name = \'' + str + '\'';
            }
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        }else if(chart == 'PreOrder_Pipeline_By_Lead_Source_SMD_USA'){
            /*****************************************************************************************************
            *   @dashboard name  : Pipeline Last 12 Months By Lead Source
            *   @chart name      : PreOrder_Pipeline_By_Lead_Source_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String str = Apexpages.currentPage().getParameters().get('str');
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            if(str == 'N/A' || str == 'NA') {
                str = '';
                str2 = 'N/A';
                str3 = 'NA';
            }
            
            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();
            
            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); 
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-'); //Last available date
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = ListOfRecordsControllerHelper.PreOrder_Pipeline_By_Lead_Source_SMD_USAQuery(opp_dashb_query, recordTypeName, click, str,str2,str3);
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');

            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        }else if(chart == 'Company_Negotiation_Pipeline_SMD_USA'){
            
            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            String opportunity_dashboard_query = opp_dashb_query;
            opportunity_dashboard_query += ' WHERE Sales_Rep_Team__r.Name IN:All_SalesReps_USA';
            // opportunity_dashboard_query += ' AND  Opportunity_GL_Var_1__r.Name = \'Seawin USA\' ';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Opportunity_StageName__c =\'Negotiation\' ';
            opportunity_dashboard_query += ' AND Amount__c != null';

            String max_year;
            String max_month;

            if (click == 'chart'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-'); //Current date for ex if today if 3 March 2022 - here will be 3-2022
                max_year =  year_m[1];
                max_month = year_m[0];
            } else {
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            if(recordTypeName != 'All'){
                opportunity_dashboard_query += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('Opportunity__r.recordtype.name', recordTypeName);
            }

            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);
            opp_dashboards = table_data;

            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        }else if(chart == 'Sales_Reps_Negotiation_Pipeline_SMD_USA'){
            //markkk
            /*****************************************************************************************************
            *   @dashboard name  : Pipeline Last 12 Months by Sales Rep / Team
            *   @chart name      : Sales_Reps_Total_Pipeline_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/

            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = Apexpages.currentPage().getParameters().get('str');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-');
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE  Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Opportunity_StageName__c =\'Negotiation\' ';
            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';

            if(recordTypeName != 'All'){
                opportunity_dashboard_query += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('Opportunity__r.recordtype.name', recordTypeName);
            }
            if (click == 'chart') {
                opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name in:All_SalesReps_USA';
            } else if(click == 'legend' || click == 'point') {
                opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name = \'' + str + '\'';
            }
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        }else if(chart == 'Negotiation_Pipeline_By_Lead_Source_SMD_USA'){
            /*****************************************************************************************************
            *   @dashboard name  : Pipeline Last 12 Months By Lead Source
            *   @chart name      : PreOrder_Pipeline_By_Lead_Source_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String str = Apexpages.currentPage().getParameters().get('str');
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            if(str == 'N/A' || str == 'NA') {
                str = '';
                str2 = 'N/A';
                str3 = 'NA';
            }
            
            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();
            
            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-'); //Last available date
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = ListOfRecordsControllerHelper.Negotiation_Pipeline_By_Lead_Source_SMD_USAQuery(opp_dashb_query, str, str2, str3, recordTypeName, click);


            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');

            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        }else if(chart == 'Monthly_Sales_Last_12_Months_Spec_SMD_H'){
            /*****************************************************************************************************
            *   @dashboard name  : Pipeline Last 12 Months By Lead Source
            *   @chart name      : PreOrder_Pipeline_By_Lead_Source_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SalesMonthStart = FindMonthStartDate(year, month);
            DateTime SalesMonthEnd = FindMonthEndDate(year, month);

            String year_month = system.today().month() + '-' + system.today().year();
            system.debug('year_month: '+year_month);
            // get all sales rep name who are related to the logged in user gl variable
            showActiveDate = true;
            
            string QueryStr = ListOfRecordsControllerHelper.Monthly_Sales_Last_12_Months_Spec_SMD_HQuery(so_dashb_query, click, str, year, month);
            
            calculateTotalAmount((List<Sales_Order_Dashboard__c>)Database.query(QueryStr), 'Total_With_Fee__c');

            List<Sales_Order_Dashboard__c> table_data = (List<Sales_Order_Dashboard__c>)Database.query(QueryStr);

            system.debug('table_data soo: '+table_data);
            so_dashboards = table_data;
        }else if(chart == 'Spec_Pre_Order_Pipeline_SMD_USA'){
            //markkk

            /*****************************************************************************************************
            *   @dashboard name  : Pre-Orders Pipeline last 12 months by Specified Rep
            *   @chart name      : Sales_Reps_Total_Pipeline_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/

            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = Apexpages.currentPage().getParameters().get('str');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-');
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE  Opportunity_GL_Var_1__r.Name = \'Seawin USA\' ';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Opportunity_StageName__c =\'Pre-Order\' ';
            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';


            if (click == 'chart') {
                // opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name in:All_SalesReps_USA';
            } else if(click == 'legend' || click == 'point') {
                opportunity_dashboard_query += ' AND Specified_Rep__r.Name = \'' + str + '\'';
            }
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        }else if(chart == 'Sales_Forecast_Pre_Order_Pipeline_SMD'){
            isOpptys = true;
            ShowCloseDate = true;
            ShowER = true;
            ShowProb = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date ForecastMonthStart = Date.newInstance(year, month, 1);
            Date ForecastMonthEnd = Date.newInstance(
                year,
                month,
                Date.daysInMonth(year, month)
            );
            
            Date Pipeline_Start_Date = Date.newInstance(d.Year(), d.Month(), 1);
            Date Future_Date = Pipeline_Start_Date.addMonths(11);
            
            Date Pipeline_End_Date = Date.newInstance(
                Future_Date.year(),
                Future_Date.month(),
                Date.daysInMonth(Future_Date.year(), Future_Date.month())
            );
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' ForecastCategoryName = \'Pipeline\' and ';
            QueryStr += 'GL_Account_Variable_1__r.name = \'Seawin USA\' ';
            QueryStr += 'AND Specified_del__c = true ';
            QueryStr += 'AND Specified_Rep__c != null ';

            if (click == 'chart') {
                QueryStr += ' and CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date ';
            } else if (click == 'bar') {
                QueryStr += ' and Specified_Rep__r.name = \'' + str + '\'';
                QueryStr += duration == 'Missed'
                    ? ' and CloseDate <:Pipeline_Start_Date '
                    : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and Specified_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date ';
            } else if (click == 'left') {
                
                QueryStr += duration == 'Missed'
                    ? ' and CloseDate <:Pipeline_Start_Date '
                    : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
            }
            
            QueryStr += ' order by Name,Probability desc NULLS LAST';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'ExpectedRevenue');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }else if(chart == 'Monthly_Sales_Last_12_Months_Refferral_H'){
            /*****************************************************************************************************
            *   @dashboard name  : Pipeline Last 12 Months By Lead Source
            *   @chart name      : PreOrder_Pipeline_By_Lead_Source_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SalesMonthStart = FindMonthStartDate(year, month);
            DateTime SalesMonthEnd = FindMonthEndDate(year, month);

            String year_month = system.today().month() + '-' + system.today().year();
            system.debug('year_month: '+year_month);
            // get all sales rep name who are related to the logged in user gl variable
            showActiveDate = true;
            
            string QueryStr = so_dashb_query;
            QueryStr += ' WHERE GL_Account_Variable_1__r.Name = \'Seawin USA\' ';
            
            String str_year = String.valueOf(year);
            String str_month = String.valueOf(month);
            String year_month_inverced = str_year+'-'+str_month;

            if (click == 'chart') {
                QueryStr += ' and Month_Year__c =:year_month ';
                QueryStr += ' and Referral_Sales_Rep__c != null ';
                QueryStr += ' and Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'bar') {
                QueryStr += ' and Referral_Sales_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and Inserting_Month__c =:str_month and Inserting_Year__c =:str_year ';
                QueryStr += ' and Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'legend') {
                QueryStr += ' and Referral_Sales_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and Month_Year__c =:year_month_inverced ';
                QueryStr += ' and Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'left') {
                
                QueryStr += ' and Inserting_Month__c =:str_month and Inserting_Year__c =:year ';
                QueryStr += ' and Status__c != \'' + 'Cancelled' + '\'';
            }
            QueryStr += ' order by Referral_Sales_Rep__r.name asc, CreatedDate desc';
            
            calculateTotalAmount((List<Sales_Order_Dashboard__c>)Database.query(QueryStr), 'Total_With_Fee__c');

            List<Sales_Order_Dashboard__c> table_data = (List<Sales_Order_Dashboard__c>)Database.query(QueryStr);

            system.debug('table_data soo: '+table_data);
            so_dashboards = table_data;
        }else if(chart == 'Ref_Reps_Total_Pipeline_SMD_USA'){
            //markkk
            /*****************************************************************************************************
            *   @dashboard name  : Pre-Orders Pipeline last 12 months by Specified Rep
            *   @chart name      : Ref_Reps_Total_Pipeline_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/

            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = Apexpages.currentPage().getParameters().get('str');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-');
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE  Opportunity_GL_Var_1__r.Name = \'Seawin USA\' ';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Opportunity_StageName__c =\'Pre-Order\' ';
            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';


            if (click == 'chart') {
                opportunity_dashboard_query += ' AND Referral_Sales_Rep__c != null';
            } else if(click == 'legend' || click == 'point') {
                opportunity_dashboard_query += ' AND Referral_Sales_Rep__r.Name = \'' + str + '\'';
            }
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        }else if(chart == 'Sales_Forecast_Reff_Pipeline_SMD'){
            isOpptys = true;
            ShowCloseDate = true;
            ShowER = true;
            ShowProb = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date ForecastMonthStart = Date.newInstance(year, month, 1);
            Date ForecastMonthEnd = Date.newInstance(
                year,
                month,
                Date.daysInMonth(year, month)
            );
            
            Date Pipeline_Start_Date = Date.newInstance(d.Year(), d.Month(), 1);
            Date Future_Date = Pipeline_Start_Date.addMonths(11);
            
            Date Pipeline_End_Date = Date.newInstance(
                Future_Date.year(),
                Future_Date.month(),
                Date.daysInMonth(Future_Date.year(), Future_Date.month())
            );
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' ForecastCategoryName = \'Pipeline\' and ';
            QueryStr += 'GL_Account_Variable_1__r.name = \'Seawin USA\' ';
            QueryStr += 'AND Specified_del__c = true ';
            QueryStr += 'AND Referral_Sales_Rep__c != null ';

            if (click == 'chart') {
                QueryStr += ' and CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date ';
            } else if (click == 'bar') {
                QueryStr += ' and Referral_Sales_Rep__r.name = \'' + str + '\'';
                QueryStr += duration == 'Missed'
                    ? ' and CloseDate <:Pipeline_Start_Date '
                    : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and Referral_Sales_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date ';
            } else if (click == 'left') {
                
                QueryStr += duration == 'Missed'
                    ? ' and CloseDate <:Pipeline_Start_Date '
                    : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
            }
            
            QueryStr += ' order by Name,Probability desc NULLS LAST';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'ExpectedRevenue');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }else if(chart == 'Monthly_Sales_Last_12_Months_Manuf_H'){
            /*****************************************************************************************************
            *   @dashboard name  : Pipeline Last 12 Months By Lead Source
            *   @chart name      : PreOrder_Pipeline_By_Lead_Source_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SalesMonthStart = FindMonthStartDate(year, month);
            DateTime SalesMonthEnd = FindMonthEndDate(year, month);

            String year_month = system.today().month() + '-' + system.today().year();
            system.debug('year_month: '+year_month);
            // get all sales rep name who are related to the logged in user gl variable
            showActiveDate = true;
            
            string QueryStr = so_dashb_query;
            QueryStr += ' WHERE GL_Account_Variable_1__r.Name = \'Seawin USA\' ';
            
            String str_year = String.valueOf(year);
            String str_month = String.valueOf(month);
            String year_month_inverced = str_year+'-'+str_month;

            if (click == 'chart') {
                QueryStr += ' and Month_Year__c =:year_month ';
                QueryStr += ' and Manufacturer_Rep__c != null ';
                QueryStr += ' and Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'bar') {
                QueryStr += ' and Manufacturer_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and Inserting_Month__c =:str_month and Inserting_Year__c =:str_year ';
                QueryStr += ' and Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'legend') {
                QueryStr += ' and Manufacturer_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and Month_Year__c =:year_month_inverced ';
                QueryStr += ' and Status__c != \'' + 'Cancelled' + '\'';
            } else if (click == 'left') {
                
                QueryStr += ' and Inserting_Month__c =:str_month and Inserting_Year__c =:year ';
                QueryStr += ' and Status__c != \'' + 'Cancelled' + '\'';
            }
            QueryStr += ' order by Manufacturer_Rep__r.name asc, CreatedDate desc';
            
            calculateTotalAmount((List<Sales_Order_Dashboard__c>)Database.query(QueryStr), 'Total_With_Fee__c');

            List<Sales_Order_Dashboard__c> table_data = (List<Sales_Order_Dashboard__c>)Database.query(QueryStr);

            system.debug('table_data soo: '+table_data);
            so_dashboards = table_data;
        }else if(chart == 'Sales_Reps_Total_Pipeline_Manuf_USA'){

            //markkk
            /*****************************************************************************************************
            *   @dashboard name  : Pre-Orders Pipeline last 12 months by Specified Rep
            *   @chart name      : Sales_Reps_Total_Pipeline_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/

            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = Apexpages.currentPage().getParameters().get('str');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-');
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE  Opportunity_GL_Var_1__r.Name = \'Seawin USA\' ';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Opportunity_StageName__c =\'Pre-Order\' ';
            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';


            if (click == 'chart') {
                opportunity_dashboard_query += ' AND Manufacturer_Rep__c != null';
            } else if(click == 'legend' || click == 'point') {
                opportunity_dashboard_query += ' AND Manufacturer_Rep__r.Name = \'' + str + '\'';
            }
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');

        }else if(chart == 'Sales_Forecast_Pipeline_Manuf_SMD'){
            isOpptys = true;
            ShowCloseDate = true;
            ShowER = true;
            ShowProb = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date ForecastMonthStart = Date.newInstance(year, month, 1);
            Date ForecastMonthEnd = Date.newInstance(
                year,
                month,
                Date.daysInMonth(year, month)
            );
            
            Date Pipeline_Start_Date = Date.newInstance(d.Year(), d.Month(), 1);
            Date Future_Date = Pipeline_Start_Date.addMonths(11);
            
            Date Pipeline_End_Date = Date.newInstance(
                Future_Date.year(),
                Future_Date.month(),
                Date.daysInMonth(Future_Date.year(), Future_Date.month())
            );
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' ForecastCategoryName = \'Pipeline\' and ';
            QueryStr += 'GL_Account_Variable_1__r.name = \'Seawin USA\' ';
            QueryStr += 'AND Specified_del__c = true ';
            QueryStr += 'AND Manufacturer_Rep__c != null ';

            if (click == 'chart') {
                QueryStr += ' and CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date ';
            } else if (click == 'bar') {
                QueryStr += ' and Manufacturer_Rep__r.name = \'' + str + '\'';
                QueryStr += duration == 'Missed'
                    ? ' and CloseDate <:Pipeline_Start_Date '
                    : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and Manufacturer_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date ';
            } else if (click == 'left') {
                
                QueryStr += duration == 'Missed'
                    ? ' and CloseDate <:Pipeline_Start_Date '
                    : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
            }
            
            QueryStr += ' order by Name,Probability desc NULLS LAST';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'ExpectedRevenue');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }else if(chart == 'Company_Total_Pipeline_Specified_SMD_USA'){
            /*****************************************************************************************************
            *   @dashboard name  : Company Total Pipeline Last 12 Months
            *   @chart name      : Company_Total_Pipeline_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/

            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            String opportunity_dashboard_query = opp_dashb_query;
            opportunity_dashboard_query += ' WHERE Opportunity_GL_Var_1__r.Name = \'Seawin USA\' ';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Amount__c != null ';
            opportunity_dashboard_query += ' AND Specified__c =true ';
            opportunity_dashboard_query += ' AND Specified_Rep__c != null ';
             
            String max_year;
            String max_month;

            if (click == 'chart'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-'); //Current date for ex if today if 3 March 2022 - here will be 3-2022
                max_year =  year_m[1];
                max_month = year_m[0];
            } else {
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);
            opp_dashboards = table_data;

            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        }else if(chart == 'Pipeline_By_Specified_SMD_USA'){
             /*****************************************************************************************************
            *   @dashboard name  : Pre-Orders Pipeline last 12 months by Specified Rep
            *   @chart name      : Sales_Reps_Total_Pipeline_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/

            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = Apexpages.currentPage().getParameters().get('str');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-');
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE  Opportunity_GL_Var_1__r.Name = \'Seawin USA\' ';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            opportunity_dashboard_query += ' AND Amount__c != null ';
            opportunity_dashboard_query += ' AND Specified__c =true ';
            opportunity_dashboard_query += ' AND Specified_Rep__c != null ';

            if (click == 'chart') {
                // opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name in:All_SalesReps_USA';
            } else if(click == 'legend' || click == 'point') {
                opportunity_dashboard_query += ' AND Specified_Rep__r.Name = \'' + str + '\'';
            }
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        }else if(chart == 'Newly_Submitted_Opportunities_Last_12_Months_Specified'){
            isOpptys = true;
            ShowSubmittedDate = true;
            ShowER = true;
            ShowProb = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date SubmittedMonthStart = Date.newInstance(year, month, 1);
            Date SubmittedMonthEnd = month == d.month() ? Date.today() : 
            Date.newInstance(year, month, Date.daysInMonth(year, month));
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            //string QueryStr = QueryOpportunities;
            string QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue, (Select Status From Quotes Order By CreatedDate Asc Limit 1) FROM Opportunity where ';
            
            QueryStr += ' GL_Account_Variable_1__r.name = \'Seawin USA\' ';
            QueryStr += ' AND Type != \'Template\' ';
            QueryStr += ' AND Specified_del__c = true ';
            QueryStr += ' AND Specified_Rep__c != NULL ';
            // QueryStr += ' OR StageName = \'Sleep\' ';
            // QueryStr += ' OR StageName = \'Closed Won\' ';
            // QueryStr += ' OR StageName = \'Closed Lost\') ';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';

            if (click == 'chart') {
                // QueryStr += ' and Specified_Rep__r.name in:Active_SalesReps_USA ';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            } else if (click == 'point') {
                QueryStr += ' and Specified_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'month-point') {
                // QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_USA ';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and Specified_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            }
            
            QueryStr += ' order by sales_rep_o__r.name, Newly_Submitted_Quote_First_Date__c desc';
            
            //Changing the code start
            Set<Id> oppIds = new Set<Id>();
            List<Opportunity> allOppts = Database.query(QueryStr);
            for (Opportunity opp : allOppts) {
                for (Quote qt : opp.Quotes) {
                    if (qt.Status == 'Presented') {
                        oppIds.add(opp.Id);
                    }
                }
            }
            
            QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue FROM Opportunity where Id in :oppIds';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }else if(chart == 'Lost_Opportunities_Specified'){
            isOpptys = true;
            ShowClosedDate = true;
            ShowLossReason = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date LostOpptyMonthStart = Date.newInstance(year, month, 1);
            Date LostOpptyMonthEnd = month == d.month() ? Date.today() : 
            Date.newInstance(year, month, Date.daysInMonth(year, month));
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' GL_Account_Variable_1__r.Name = \'Seawin USA\' ';
            QueryStr += ' and StageName = \'Closed Lost\' ';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND Specified_del__c = true ';
            QueryStr += ' AND Specified_Rep__c != NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';
            
            if (click == 'chart') {
                
                QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
            } else if (click == 'point') {
                QueryStr += ' and Specified_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and Closed_Date__c >=:LostOpptyMonthStart and Closed_Date__c <=:LostOpptyMonthEnd ';
            } else if (click == 'month-point') {
                QueryStr += ' and Closed_Date__c >=:LostOpptyMonthStart and Closed_Date__c <=:LostOpptyMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and Specified_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
            }
            
            QueryStr += ' order by Specified_Rep__r.name asc, Closed_Date__c desc';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }else if(chart == 'Win_Rate_Specified'){
            ShowClosedDate = true;
            ShowWon = true;
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            isOpptys = true;
            string QueryStr = QueryOpportunities;
            
            QueryStr += ' GL_Account_Variable_1__r.name = \'Seawin USA\' and ';
            QueryStr += ' (stagename = \'Closed Won\' or stagename = \'Closed Lost\') ';
            QueryStr += ' and (NOT Name LIKE:ChangeOrder) ';
            QueryStr += ' and (NOT Name LIKE:MockupOne) ';
            QueryStr += ' and (NOT Name LIKE:MockupTwo) ';
            QueryStr += ' and (NOT Name LIKE:MockupThree) ';
            QueryStr += ' and (NOT Name LIKE:MockupFour) ';
            
            if (click == 'chart') {
                QueryStr += ' and Specified_Rep__c != null ';
                QueryStr += ' and Specified_del__c = true ';
            } else if (click == 'bar') {
                QueryStr += ' and Specified_Rep__r.name = \'' + str + '\'';
            }
            QueryStr += ' order by sales_rep_o__r.name asc, stagename desc, closed_date__c desc, Name';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if(chart == 'Company_Total_Pipeline_Referral_SMD_USA'){
            /*****************************************************************************************************
            *   @dashboard name  : Company Total Pipeline Last 12 Months
            *   @chart name      : Company_Total_Pipeline_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/

            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            String opportunity_dashboard_query = opp_dashb_query;
            opportunity_dashboard_query += ' WHERE Opportunity_GL_Var_1__r.Name = \'Seawin USA\' ';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Amount__c != null ';
            opportunity_dashboard_query += ' AND Referral_Sales_Rep__c != null ';
             
            String max_year;
            String max_month;

            if (click == 'chart'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-'); //Current date for ex if today if 3 March 2022 - here will be 3-2022
                max_year =  year_m[1];
                max_month = year_m[0];
            } else {
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);
            opp_dashboards = table_data;

            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');

        }else if(chart == 'Referral_Pipeline_Last_12_Month'){
            /*****************************************************************************************************
            *   @dashboard name  : Pre-Orders Pipeline last 12 months by Specified Rep
            *   @chart name      : Sales_Reps_Total_Pipeline_SMD_USA
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/

            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = Apexpages.currentPage().getParameters().get('str');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-');
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE  Opportunity_GL_Var_1__r.Name = \'Seawin USA\' ';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            opportunity_dashboard_query += ' AND Amount__c != null ';
            opportunity_dashboard_query += ' AND Referral_Sales_Rep__c != null ';

            if (click == 'chart') {
                opportunity_dashboard_query += ' AND Referral_Sales_Rep__c != null';
            } else if(click == 'legend' || click == 'point') {
                opportunity_dashboard_query += ' AND Referral_Sales_Rep__r.Name = \'' + str + '\'';
            }
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        }else if(chart == 'Newly_Submitted_Referral_Opportunities_Last_12_Month'){
            isOpptys = true;
            ShowSubmittedDate = true;
            ShowER = true;
            ShowProb = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date SubmittedMonthStart = Date.newInstance(year, month, 1);
            Date SubmittedMonthEnd = month == d.month() ? Date.today() : 
            Date.newInstance(year, month, Date.daysInMonth(year, month));
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            //string QueryStr = QueryOpportunities;
            string QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue, (Select Status From Quotes Order By CreatedDate Asc Limit 1) FROM Opportunity where ';
            
            QueryStr += ' GL_Account_Variable_1__r.name = \'Seawin USA\' ';
            QueryStr += ' AND Type != \'Template\' ';
            QueryStr += ' AND Referral_Sales_Rep__c != NULL ';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';

        //     WHERE GL_Account_Variable_1__r.Name = 'Seawin USA'
        //     AND Newly_Submitted_Quote_First_Date__c >= :Only_Start_Date
        //     AND Newly_Submitted_Quote_First_Date__c <= :Only_End_Date
        //     AND Parent_Opportunity__c = NULL
        //     AND Specified_Rep__c != null
        //     AND Specified_del__c = true
        //     AND Type != 'Template'
        //     AND (NOT Name LIKE :ChangeOrder)
        //     AND (NOT Name LIKE :MockupOne)
        //     AND (NOT Name LIKE :MockupTwo)
        //     AND (NOT Name LIKE :MockupThree)
        //     AND (NOT Name LIKE :MockupFour)
        //     ORDER BY Newly_Submitted_Quote_First_Date__c ASC
        // ];
            if (click == 'chart') {
                // QueryStr += ' and Specified_Rep__r.name in:Active_SalesReps_USA ';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            } else if (click == 'point') {
                QueryStr += ' and Referral_Sales_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'month-point') {
                // QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_USA ';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and Referral_Sales_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            }
            
            QueryStr += ' order by Referral_Sales_Rep__r.name, Newly_Submitted_Quote_First_Date__c desc';
            
            //Changing the code start
            Set<Id> oppIds = new Set<Id>();
            List<Opportunity> allOppts = Database.query(QueryStr);
            for (Opportunity opp : allOppts) {
                for (Quote qt : opp.Quotes) {
                    if (qt.Status == 'Presented') {
                        oppIds.add(opp.Id);
                    }
                }
            }
            
            QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue FROM Opportunity where Id in :oppIds';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }else if(chart == 'Lost_Opportunities_Referrall'){
            isOpptys = true;
            ShowClosedDate = true;
            ShowLossReason = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date LostOpptyMonthStart = Date.newInstance(year, month, 1);
            Date LostOpptyMonthEnd = month == d.month() ? Date.today() : 
            Date.newInstance(year, month, Date.daysInMonth(year, month));
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' GL_Account_Variable_1__r.Name = \'Seawin USA\' ';
            QueryStr += ' and StageName = \'Closed Lost\' ';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND Referral_Sales_Rep__c != NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';
            
            if (click == 'chart') {
                
                QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
            } else if (click == 'point') {
                QueryStr += ' and Referral_Sales_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and Closed_Date__c >=:LostOpptyMonthStart and Closed_Date__c <=:LostOpptyMonthEnd ';
            } else if (click == 'month-point') {
                QueryStr += ' and Closed_Date__c >=:LostOpptyMonthStart and Closed_Date__c <=:LostOpptyMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and Referral_Sales_Rep__r.name = \'' + str + '\'';
                QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
            }
            
            QueryStr += ' order by Referral_Sales_Rep__r.name asc, Closed_Date__c desc';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }else if(chart == 'Win_Rate_Referrall'){
            ShowClosedDate = true;
            ShowWon = true;
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            isOpptys = true;
            string QueryStr = QueryOpportunities;
            
            QueryStr += ' GL_Account_Variable_1__r.name = \'Seawin USA\' and ';
            QueryStr += ' (stagename = \'Closed Won\' or stagename = \'Closed Lost\') ';
            QueryStr += ' and (NOT Name LIKE:ChangeOrder) ';
            QueryStr += ' and (NOT Name LIKE:MockupOne) ';
            QueryStr += ' and (NOT Name LIKE:MockupTwo) ';
            QueryStr += ' and (NOT Name LIKE:MockupThree) ';
            QueryStr += ' and (NOT Name LIKE:MockupFour) ';
            
            if (click == 'chart') {
                QueryStr += ' and Referral_Sales_Rep__c != null ';
            } else if (click == 'bar') {
                QueryStr += ' and Referral_Sales_Rep__r.name = \'' + str + '\'';
            }
            QueryStr += ' order by sales_rep_o__r.name asc, stagename desc, closed_date__c desc, Name';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }else if(chart == 'Company_PreOrder_Pipeline_SMD_USA_Sales'){
            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            String opportunity_dashboard_query = opp_dashb_query;
            opportunity_dashboard_query += ' WHERE Sales_Rep_Team__r.Name IN:All_SalesReps_USA';
            opportunity_dashboard_query += ' AND  Opportunity_GL_Var_1__r.Name = \'Seawin USA\' ';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Opportunity_StageName__c =\'Pre-Order\' ';
            opportunity_dashboard_query += ' AND Amount__c != null';
            opportunity_dashboard_query += ' AND Opportunity__r.ownerId = \''+UserInfo.getUserId()+'\'';

            String max_year;
            String max_month;

            if (click == 'chart'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-'); //Current date for ex if today if 3 March 2022 - here will be 3-2022
                max_year =  year_m[1];
                max_month = year_m[0];
            } else {
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);
            opp_dashboards = table_data;

            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        }else if(chart == 'Company_Negotiation_Pipeline_SMD_USA_Sales'){
            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            String opportunity_dashboard_query = opp_dashb_query;
            opportunity_dashboard_query += ' WHERE Sales_Rep_Team__r.Name IN:All_SalesReps_USA';
            opportunity_dashboard_query += ' AND  Opportunity_GL_Var_1__r.Name = \'Seawin USA\' ';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Opportunity_StageName__c =\'Negotiation\' ';
            opportunity_dashboard_query += ' AND Amount__c != null';
            opportunity_dashboard_query += ' AND Opportunity__r.ownerId = \''+UserInfo.getUserId()+'\'';
            
            String max_year;
            String max_month;

            if (click == 'chart'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-'); //Current date for ex if today if 3 March 2022 - here will be 3-2022
                max_year =  year_m[1];
                max_month = year_m[0];
            } else {
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);
            opp_dashboards = table_data;

            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        }else if(chart == 'Tasks_Completion_SMD'){
            isTasks = true;

            String QueryStr = ListOfRecordsControllerHelper.Tasks_Completion_SMDQuery(duration, QueryTasks, Active_Users_USA, str, click);
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            
            Con.setPageSize(size);
        }else if(chart == 'New_Customers_Last_12_Months_by_Type_SMD'){
            isAccounts = true;
            
            String Customer = 'Customer';
            String CustomerAndVendor = 'Customer And Vendor';
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SubmittedMonthStart = FindMonthStartDate(year, month);
            DateTime SubmittedMonthEnd = FindMonthEndDate(year, month);
            
            string QueryStr = QueryAccounts;
            QueryStr += ' (AcctSeed__Accounting_Type__c =:Customer or AcctSeed__Accounting_Type__c =:CustomerAndVendor) ';
            QueryStr += ' and AcctSeed__GL_Account_Variable_1__r.name = \'Seawin USA\' ';
            
            if (click == 'point') {
                QueryStr += ' and createddate >= :SubmittedMonthStart AND createddate <= :SubmittedMonthEnd ';
                QueryStr += ' and Type =  \'' + str + '\'';
            }
            QueryStr += ' order by Type asc';
            //calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');
            

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }else if(chart == 'MonthlySalesLast12MonthBySalesRepTeam'){
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            isOrders = true;

            String QueryStr = ListOfRecordsControllerHelper.MonthlySalesLast12MonthBySalesRepTeamQuery(str, QueryOrders, click, yearStr, monthStr, recordTypeName);

            showActiveDate = true;
            
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);



        }else if(chart == 'MonthlySalesLast12MonthsbyOwner'){
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            isOrders = true;

            String QueryStr = ListOfRecordsControllerHelper.MonthlySalesLast12MonthByOwnerQuery(str, QueryOrders, click, yearStr, monthStr, recordTypeName);

            showActiveDate = true;
            
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }else if(chart == 'Monthly_Sales_Last_12_Month_by_Lead_Source'){
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String recordTypeName = ApexPages.currentPage().getParameters().get('recordType');
            isOrders = true;

            String QueryStr = ListOfRecordsControllerHelper.MonthlySalesLast12MonthByLeadSourceQuery(str, QueryOrders, click, yearStr, monthStr, recordTypeName);

            showActiveDate = true;
            
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        }





        // 9.11 todo here
    }
    

    public void Sales_Manager_Dashboard_CHK() {
        if (chart == 'Billing_Aging_SMD_CHK') {
            isBillings = true;
            string Closed = 'Closed';
            string Posted = 'Posted';
            string CreditMemo = 'Credit Memo';
            
            String QueryStr = QueryBillings;
            QueryStr += ' AcctSeed__Status__c =:Posted and AcctSeed__Type__c !=:CreditMemo and ';
            QueryStr += ' Owner.name in:All_Users_CHK and ';
            QueryStr += ' (GL_Account_Variable_1__c =\'Seawin China\' or GL_Account_Variable_1__c =\'Seawin Hong Kong\') and';
            
            if (click == 'chart') {
                QueryStr += ' AcctSeed__Age__c !=:Closed ';
            } else if (click == 'bar') {
                QueryStr += ' AcctSeed__Age__c =:str ';
            }
            QueryStr += ' order by AcctSeed__Age__c asc, AcctSeed__Balance__c desc ';
            
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Collection_Performance_SMD_CHK') {
            isBillings = true;
            string Closed = 'Closed';
            string Posted = 'Posted';
            string CreditMemo = 'Credit Memo';
            
            String QueryStr = QueryBillings;
            
            if (click == 'chart') {
                QueryStr += ' AcctSeed__Status__c =:Posted and ';
                QueryStr += ' AcctSeed__Age__c !=:Closed and ';
                QueryStr += ' AcctSeed__Type__c !=:CreditMemo and ';
                QueryStr += ' owner.name in:All_Users_CHK and ';
                QueryStr += ' (GL_Account_Variable_1__c =\'Seawin China\' or GL_Account_Variable_1__c =\'Seawin Hong Kong\') ';
                QueryStr += ' order by AcctSeed__Age__c asc, AcctSeed__Balance__c desc ';
            }
            
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Monthly_Sales_Last_12_Months_SMD_CHK') {
            isOrders = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SalesMonthStart = FindMonthStartDate(year, month);
            DateTime SalesMonthEnd = FindMonthEndDate(year, month);
            
            List<opportunity> oppsChildList = new List<opportunity>();
            
            // get all sales rep name who are related to the logged in user gl variable
            showActiveDate = true;
            
            //---------------
            
            string QueryStr = QueryOrders;
            QueryStr += ' RecordType.name = \'Seawin China Hospitality\' and ';
            QueryStr += '(GL_Account_Variable_1__r.name = \'Seawin China\' or GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
            
            if (click == 'chart') {
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
            } else if (click == 'bar') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <=:SalesMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
            } else if (click == 'left') {
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <:SalesMonthEnd ';
            }
            
            QueryStr += ' order by sales_rep_o__r.name asc, CreatedDate desc';
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Current_Sales_Contest_YTD_SMD_CHK') {
            isOrders = true;
            
            string QueryStr = QueryOrders;
            QueryStr += ' RecordType.name = \'Seawin China Hospitality\' and ';
            QueryStr += ' (GL_Account_Variable_1__r.name = \'Seawin China\' or GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
            QueryStr += ' and CreatedDate = THIS_YEAR ';
            QueryStr += ' and AcctSeederp__total__c > 0 ';
            
            if (click == 'chart') {
                queryStr += ' and Sales_rep_o__r.name in:Active_SalesReps_CHK ';
            } else if (click == 'bar') {
                QueryStr += ' and Sales_rep_o__r.name = \'' + str + '\'';
            }
            QueryStr += ' order by sales_rep_o__r.name asc, CreatedDate desc';
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Current_Sales_Contest_QTD_SMD_CHK') {
            isOrders = true;
            
            string QueryStr = QueryOrders;
            QueryStr += ' RecordType.name = \'Seawin China Hospitality\' and ';
            QueryStr += ' (GL_Account_Variable_1__r.name = \'Seawin China\' or GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
            QueryStr += ' and CreatedDate = THIS_QUARTER ';
            QueryStr += ' and AcctSeederp__total__c > 0 ';
            
            if (click == 'chart') {
                queryStr += ' and Sales_rep_o__r.name in:Active_SalesReps_CHK ';
            } else if (click == 'bar') {
                QueryStr += ' and Sales_rep_o__r.name = \'' + str + '\'';
            }
            QueryStr += ' order by sales_rep_o__r.name asc, CreatedDate desc';
            
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Current_Sales_Contest_TM_SMD_CHK') {
            isOrders = true;
            
            string QueryStr = QueryOrders;
            QueryStr += ' RecordType.name = \'Seawin China Hospitality\' and ';
            QueryStr += ' (GL_Account_Variable_1__r.name = \'Seawin China\' or GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
            QueryStr += ' and CreatedDate = THIS_MONTH ';
            QueryStr += ' and AcctSeederp__total__c > 0 ';
            
            if (click == 'chart') {
                queryStr += ' and Sales_rep_o__r.name in:Active_SalesReps_CHK ';
            } else if (click == 'bar') {
                QueryStr += ' and Sales_rep_o__r.name = \'' + str + '\'';
            }
            QueryStr += ' order by sales_rep_o__r.name asc, CreatedDate desc';
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Team_Quota_YTD_SMD_CHK') {
            isOrders = true;
            
            DateTime YearStartDate = FindMonthStartDate(d.year(), 1);
            
            DateTime YearToDateDate = DateTime.now();
            
            String QueryStr = QueryOrders;
            QueryStr += ' CreatedDate >=: YearStartDate and CreatedDate <=: YearToDateDate and';
            QueryStr += ' recordtype.name = \'Seawin China Hospitality\' and ';
            QueryStr += '(GL_Account_Variable_1__r.name = \'Seawin China\' or GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
            QueryStr += ' and Sales_Rep_o__r.name in:All_SalesReps_CHK ';
            QueryStr += ' order by sales_rep_o__r.name asc, CreatedDate desc';
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Team_Quota_Percent_SMD_CHK') {
            isOrders = true;
            
            DateTime YearStartDate = FindMonthStartDate(d.year(), 1);
            
            DateTime YearToDateDate = DateTime.now();
            
            String srsQuery = 'select id, name, Monthly_Quota__c from sales_rep__c where ';
            
            if (click == 'chart') {
                srsQuery += ' name in:All_SalesReps_CHK';
            } else if (click == 'bar') {
                srsQuery += ' name = \'' + str + '\'';
            }
            
            List<Sales_rep__c> SalesRep = Database.Query(srsQuery);
            
            set<string> srNames = new Set<string>();
            
            if (!SalesRep.isEmpty()) {
                for (Sales_rep__c s : salesrep) {
                    if (s.Monthly_Quota__c != null && s.Monthly_Quota__c != 0) {
                        srNames.add(s.name);
                    }
                }
            }
            
            String QueryStr = QueryOrders;
            QueryStr += ' CreatedDate >=: YearStartDate and CreatedDate <=: YearToDateDate and';
            QueryStr += ' recordtype.name = \'Seawin China Hospitality\' and ';
            QueryStr += '(GL_Account_Variable_1__r.name = \'Seawin China\' or GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
            QueryStr += ' and Sales_Rep_o__r.name in:srNames and ';
            QueryStr += ' acctseederp__total__c > 0 ';
            QueryStr += ' order by sales_rep_o__r.name asc, CreatedDate desc';
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Sales_Forecast_Pipeline_SMD_CHK') {
            isOpptys = true;
            ShowCloseDate = true;
            ShowER = true;
            ShowProb = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date ForecastMonthStart = Date.newInstance(year, month, 1);
            Date ForecastMonthEnd = Date.newInstance(
                year,
                month,
                Date.daysInMonth(year, month)
            );
            
            Date Pipeline_Start_Date = Date.newInstance(d.Year(), d.Month(), 1);
            Date Future_Date = Pipeline_Start_Date.addMonths(11);
            
            Date Pipeline_End_Date = Date.newInstance(
                Future_Date.year(),
                Future_Date.month(),
                Date.daysInMonth(Future_Date.year(), Future_Date.month())
            );
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' RecordType.name = \'Seawin China Hospitality\' ';
            QueryStr += ' and ForecastCategoryName = \'Pipeline\' and ';
            QueryStr += '(GL_Account_Variable_1__r.name = \'Seawin China\' or GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
            
            if (click == 'chart') {
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
                QueryStr += ' and CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date ';
            } else if (click == 'bar') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += duration == 'Missed'
                    ? ' and CloseDate <:Pipeline_Start_Date '
                    : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date ';
            } else if (click == 'left') {
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
                QueryStr += duration == 'Missed'
                    ? ' and CloseDate <:Pipeline_Start_Date '
                    : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
            }
            
            QueryStr += ' order by Name,Probability desc NULLS LAST';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'ExpectedRevenue');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Company_Total_Pipeline_SMD_CHK') {
            /*****************************************************************************************************
            *   @dashboard name  : Company Total Pipeline Last 12 Months
            *   @chart name      : Company_Total_Pipeline_SMD_CHK
            *   @description     : Put data on list of records Page(China), depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            String opportunity_dashboard_query = opp_dashb_query;
            opportunity_dashboard_query += ' WHERE Sales_Rep_Team__r.Name IN:All_SalesReps_CHK';
            opportunity_dashboard_query += ' AND  (Opportunity_GL_Var_1__r.Name = \'Seawin China\' OR Opportunity_GL_Var_1__r.Name = \'Seawin Hong Kong\')';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND RecordTypeName__c =\'Seawin China Hospitality\' ';

            String max_year;
            String max_month;

            if (click == 'chart'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-'); //Current date for ex if today if 3 March 2022 - here will be 3-2022
                max_year =  year_m[1];
                max_month = year_m[0];
            } else {
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);
            opp_dashboards = table_data;

            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        } else if (chart == 'Sales_Reps_Total_Pipeline_SMD_CHK') {
            /*****************************************************************************************************
            *   @dashboard name  : Company Total Pipeline Last 12 Months
            *   @chart name      : Company_Total_Pipeline_SMD_CHK
            *   @description     : Put data on list of records Page(China), depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = Apexpages.currentPage().getParameters().get('str');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-');
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE  (Opportunity_GL_Var_1__r.Name = \'Seawin China\' OR Opportunity_GL_Var_1__r.Name = \'Seawin Hong Kong\')';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';

            if (click == 'chart') {
                opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name in:All_SalesReps_CHK';
            } else if(click == 'legend' || click == 'point') {
                opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name = \'' + str + '\'';
            }
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');

        } else if (chart == 'Total_Pipeline_By_Lead_Source_SMD_CHK') {
            /*****************************************************************************************************
            *   @dashboard name  : Pipeline Last 12 Months By Lead Source
            *   @chart name      : Total_Pipeline_By_Lead_Source_SMD_CHK
            *   @description     : Put data on list of records Page(China), depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            isOpptys = true;
            showCloseDate = true;
            ShowClosedDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String str = Apexpages.currentPage().getParameters().get('str');
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            if(str == 'N/A' || str == 'NA') {
                str = '';
                str2 = 'N/A';
                str3 = 'NA';
            }
            
            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();
            
            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-'); //Last available date
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE  (Opportunity_GL_Var_1__r.Name = \'Seawin China\' OR Opportunity_GL_Var_1__r.Name = \'Seawin Hong Kong\')';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            
            // opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            // opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';


            if (click == 'legend' || click == 'point') {
                opportunity_dashboard_query += str == '' ? ' and (Opportunity_Lead_Source__c = \'' + str + '\'' : ' and Opportunity_Lead_Source__c = \'' + str + '\'';
                opportunity_dashboard_query += str == '' ? ' or Opportunity_Lead_Source__c = \'' + str2 + '\'' : '';
                opportunity_dashboard_query += str == '' ? ' or Opportunity_Lead_Source__c = \'' + str3 + '\')' : '';
            } else if(click == 'chart'){
                //If chart than we show all lead sources without filtering by lead source
            }

            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');

            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        } else if (chart == 'Newly_Submitted_Quotes_SMD_CHK') {
            isOpptys = true;
            ShowSubmittedDate = true;
            ShowER = true;
            ShowProb = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date SubmittedMonthStart = Date.newInstance(year, month, 1);
            Date SubmittedMonthEnd = month == d.month() ? Date.today() : 
            Date.newInstance(year, month, Date.daysInMonth(year, month));
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' RecordType.name = \'Seawin China Hospitality\' and ';
            QueryStr += ' (GL_Account_Variable_1__r.name = \'Seawin China\' or ';
            QueryStr += ' GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
            QueryStr += ' AND (ForecastCategoryName = \'Pipeline\' ';
            QueryStr += ' OR StageName = \'Sleep\' ';
            QueryStr += ' OR StageName = \'Closed Won\' ';
            QueryStr += ' OR StageName = \'Closed Lost\') ';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';
            
            if (click == 'chart') {
                QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_CHK ';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            } else if (click == 'point') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            }
            
            QueryStr += ' order by sales_rep_o__r.name, Newly_Submitted_Quote_First_Date__c desc';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Newly_Submitted_Opportunities_Last_12_Months_SMD_CHK') {
            isOpptys = true;
            ShowSubmittedDate = true;
            ShowER = true;
            ShowProb = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date SubmittedMonthStart = Date.newInstance(year, month, 1);
            Date SubmittedMonthEnd = month == d.month() ? Date.today() : 
            Date.newInstance(year, month, Date.daysInMonth(year, month));
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            //string QueryStr = QueryOpportunities;
            string QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue, (Select Status From Quotes Order By CreatedDate Asc Limit 1) FROM Opportunity where ';
            
            QueryStr += ' RecordType.name = \'Seawin China Hospitality\' ';
            QueryStr += ' AND (GL_Account_Variable_1__r.Name =\'Seawin China\' or GL_Account_Variable_1__r.Name =\'Seawin Hong Kong\') ';
            QueryStr += ' AND Type != \'Template\' ';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';
            
            if (click == 'chart') {
                QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_CHK ';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            } else if (click == 'point') {
                QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_CHK ';
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'month-point') {
                QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_CHK ';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            }
            
            QueryStr += ' order by sales_rep_o__r.name, Newly_Submitted_Quote_First_Date__c desc';
            
            //Changing the code start
            Set<Id> oppIds = new Set<Id>();
            List<Opportunity> allOppts = Database.query(QueryStr);
            for (Opportunity opp : allOppts) {
                for (Quote qt : opp.Quotes) {
                    if (qt.Status == 'Presented') {
                        oppIds.add(opp.Id);
                    }
                }
            }
            
            QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue FROM Opportunity where Id in :oppIds';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source_SMD_CHK') {
            isOpptys = true;
            ShowSubmittedDate = true;
            ShowER = true;
            ShowProb = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = ApexPages.currentPage().getParameters().get('str');
            
            if(str == 'N/A' || str == 'NA') {
                str = '';
                str2 = 'N/A';
                str3 = 'NA';
            }
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date SubmittedMonthStart = Date.newInstance(year, month, 1);
            Date SubmittedMonthEnd = month == d.month() ? Date.today() : 
            Date.newInstance(year, month, Date.daysInMonth(year, month));
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            //string QueryStr = QueryOpportunities;
            string QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue, (Select Status From Quotes Order By CreatedDate Asc Limit 1) FROM Opportunity where ';
            
            QueryStr += ' RecordType.name = \'Seawin China Hospitality\' ';
            QueryStr += ' AND (GL_Account_Variable_1__r.Name =\'Seawin China\' or GL_Account_Variable_1__r.Name =\'Seawin Hong Kong\') ';
            QueryStr += ' AND Type != \'Template\' ';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';
            
            if (click == 'chart') {
                QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_CHK ';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            } else if (click == 'point') {
                QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_CHK ';
                QueryStr += str == '' ? ' and (LeadSource = \'' + str + '\'' : ' and LeadSource = \'' + str + '\'';
                QueryStr += str == '' ? ' or LeadSource = \'' + str2 + '\'' : '';
                QueryStr += str == '' ? ' or LeadSource = \'' + str3 + '\')' : '';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:SubmittedMonthStart and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:SubmittedMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += str == '' ? ' and (LeadSource = \'' + str + '\'' : ' and LeadSource = \'' + str + '\'';
                QueryStr += str == '' ? ' or LeadSource = \'' + str2 + '\'' : '';
                QueryStr += str == '' ? ' or LeadSource = \'' + str3 + '\')' : '';
                QueryStr += ' and Newly_Submitted_Quote_First_Date__c >=:Only_Start_Date and ';
                QueryStr += ' Newly_Submitted_Quote_First_Date__c <=:Only_End_Date ';
            }
            
            QueryStr += ' order by sales_rep_o__r.name, Newly_Submitted_Quote_First_Date__c desc';
            
            //Changing the code start
            Set<Id> oppIds = new Set<Id>();
            List<Opportunity> allOppts = Database.query(QueryStr);
            for (Opportunity opp : allOppts) {
                for (Quote qt : opp.Quotes) {
                    if (qt.Status == 'Presented') {
                        oppIds.add(opp.Id);
                    }
                }
            }
            
            QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
            QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
            QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
            QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
            QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
            QueryStr += ' Awarded_Owner__c,Owner.Name, ';
            QueryStr += ' ExpectedRevenue FROM Opportunity where Id in :oppIds';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Lost_Opportunities_SMD_CHK') {
            isOpptys = true;
            ShowClosedDate = true;
            ShowLossReason = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date LostOpptyMonthStart = Date.newInstance(year, month, 1);
            Date LostOpptyMonthEnd = month == d.month() ? Date.today() : 
            Date.newInstance(year, month, Date.daysInMonth(year, month));
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' RecordType.name = \'Seawin China Hospitality\' ';
            QueryStr += ' and StageName = \'Closed Lost\' and ';
            QueryStr += '(GL_Account_Variable_1__r.name = \'Seawin China\' or GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
            QueryStr += ' AND Parent_Opportunity__c = NULL ';
            QueryStr += ' AND (NOT Name LIKE :ChangeOrder) ';
            QueryStr += ' AND (NOT Name LIKE :MockupOne) ';
            QueryStr += ' AND (NOT Name LIKE :MockupTwo) ';
            QueryStr += ' AND (NOT Name LIKE :MockupThree) ';
            QueryStr += ' AND (NOT Name LIKE :MockupFour) ';
            
            if (click == 'chart') {
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
                QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
            } else if (click == 'point') {
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and Closed_Date__c >=:LostOpptyMonthStart and Closed_Date__c <=:LostOpptyMonthEnd ';
            } else if (click == 'month-point') {
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
                QueryStr += ' and Closed_Date__c >=:LostOpptyMonthStart and Closed_Date__c <=:LostOpptyMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
            }
            
            QueryStr += ' order by sales_rep_o__r.name asc, Closed_Date__c desc';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Loss_Reasons_SMD_CHK') {
            string str = ApexPages.currentPage().getParameters().get('str');
            
            isOpptys = true;
            ShowClosedDate = true;
            ShowLossReason = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date LostOpptyMonthStart = Date.newInstance(year, month, 1);
            Date LostOpptyMonthEnd = month == d.month() ? Date.today() : 
            Date.newInstance(year, month, Date.daysInMonth(year, month));
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' RecordType.name = \'Seawin China Hospitality\' ';
            QueryStr += ' and StageName = \'Closed Lost\' ';
            QueryStr += ' and (GL_Account_Variable_1__r.name = \'Seawin China\' or GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
            QueryStr += ' and Parent_Opportunity__c = null ';
            QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
            
            if (click == 'chart') {
                QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
            } else if (click == 'point') {
                if (str == 'N/A') {
                    QueryStr += ' and Loss_Reason__c = null ';
                } else {
                    QueryStr += ' and Loss_Reason__c = \'' + str + '\'';
                }
                QueryStr += ' and Closed_Date__c >=:LostOpptyMonthStart and Closed_Date__c <=:LostOpptyMonthEnd ';
            } else if (click == 'legend') {
                if (str == 'N/A') {
                    QueryStr += ' and Loss_Reason__c = null ';
                } else {
                    QueryStr += ' and Loss_Reason__c = \'' + str + '\'';
                }
                QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
            }
            
            QueryStr += ' order by Loss_Reason__c asc, Closed_Date__c desc';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Sales_By_Lead_Source_Last_12_Months_SMD_CHK') {
            isOrders = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = ApexPages.currentPage().getParameters().get('str');
            
            if(str == 'N/A' || str == 'NA') {
                str = '';
                str2 = 'N/A';
                str3 = 'NA';
            }
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SalesMonthStart = FindMonthStartDate(year, month);
            DateTime SalesMonthEnd = FindMonthEndDate(year, month);
            
            List<opportunity> oppsChildList = new List<opportunity>();
            
            // get all sales rep name who are related to the logged in user gl variable
            showActiveDate = true;
            
            //---------------
            
            string QueryStr = QueryOrders;
            QueryStr += ' RecordType.name = \'Seawin China Hospitality\' ';
            QueryStr += ' and (GL_Account_Variable_1__r.Name = \'Seawin China\' or GL_Account_Variable_1__r.Name = \'Seawin Hong Kong\') ';
            QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
            
            if (click == 'chart') {
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
            } else if (click == 'bar') {
                QueryStr += str == '' ? ' and (AcctSeedERP__Opportunity__r.Leadsource = \'' + str + '\'' : 
                ' and AcctSeedERP__Opportunity__r.Leadsource = \'' + str + '\'';
                QueryStr += str == '' ? ' or AcctSeedERP__Opportunity__r.Leadsource = \'' + str2 + '\'' : '';
                QueryStr += str == '' ? ' or AcctSeedERP__Opportunity__r.Leadsource = \'' + str3 + '\')' : '';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <=:SalesMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += str == '' ? ' and (AcctSeedERP__Opportunity__r.Leadsource = \'' + str + '\'' : 
                ' and AcctSeedERP__Opportunity__r.Leadsource = \'' + str + '\'';
                QueryStr += str == '' ? ' or AcctSeedERP__Opportunity__r.Leadsource = \'' + str2 + '\'' : '';
                QueryStr += str == '' ? ' or AcctSeedERP__Opportunity__r.Leadsource = \'' + str3 + '\')' : '';
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
            } else if (click == 'left') {
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <:SalesMonthEnd ';
            }
            QueryStr += ' order by AcctSeedERP__Opportunity__r.Leadsource asc, CreatedDate desc';
            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Sales_Forecast_Pipeline_By_Lead_Source_SMD_CHK') {
            isOpptys = true;
            ShowCloseDate = true;
            ShowER = true;
            ShowProb = true;
            ShowOwner = true;
            ShowAwardedOwner = true;
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = ApexPages.currentPage().getParameters().get('str');
            
            if(str == 'N/A' || str == 'NA') {
                str = '';
                str2 = 'N/A';
                str3 = 'NA';
            }
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            Date ForecastMonthStart = Date.newInstance(year, month, 1);
            Date ForecastMonthEnd = Date.newInstance(
                year,
                month,
                Date.daysInMonth(year, month)
            );
            
            Date Pipeline_Start_Date = Date.newInstance(d.Year(), d.Month(), 1);
            Date Future_Date = Pipeline_Start_Date.addMonths(11);
            
            Date Pipeline_End_Date = Date.newInstance(
                Future_Date.year(),
                Future_Date.month(),
                Date.daysInMonth(Future_Date.year(), Future_Date.month())
            );
            
            string QueryStr = QueryOpportunities;
            QueryStr += ' RecordType.name = \'Seawin China Hospitality\' ';
            QueryStr += ' and ForecastCategoryName = \'Pipeline\' and ';
            QueryStr += '(GL_Account_Variable_1__r.name = \'Seawin China\' or GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
            QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
            
            if (click == 'chart') {
                QueryStr += ' and CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date ';
            } else if (click == 'bar') {
                QueryStr += str == '' ? ' and (LeadSource = \'' + str + '\'' : ' and LeadSource = \'' + str + '\'';
                QueryStr += str == '' ? ' or LeadSource = \'' + str2 + '\'' : '';
                QueryStr += str == '' ? ' or LeadSource = \'' + str3 + '\')' : '';
                QueryStr += duration == 'Missed'
                    ? ' and CloseDate <:Pipeline_Start_Date '
                    : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += str == '' ? ' and (LeadSource = \'' + str + '\'' : ' and LeadSource = \'' + str + '\'';
                QueryStr += str == '' ? ' or LeadSource = \'' + str2 + '\'' : '';
                QueryStr += str == '' ? ' or LeadSource = \'' + str3 + '\')' : '';
                QueryStr += ' and CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date ';
            } else if (click == 'left') {
                QueryStr += duration == 'Missed'
                    ? ' and CloseDate <:Pipeline_Start_Date '
                    : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
            }
            
            QueryStr += ' order by Name,Probability desc NULLS LAST';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'ExpectedRevenue');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Active_Opportunities_By_Stage_SMD_CHK') {
            ShowER = true;
            ShowProb = true;
            showCloseDate = true;
            
            isOpptys = true;
            string QueryStr = QueryOpportunities;
            QueryStr += ' RecordType.name = \'Seawin China Hospitality\' and ';
            QueryStr += ' ForecastCategoryName != \'Omitted\' and ForecastCategoryName != \'Closed\' and ';
            QueryStr += '(GL_Account_Variable_1__r.name = \'Seawin China\' or GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
            
            if (click == 'chart') {
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
            } else if (click == 'bar') {
                QueryStr +=
                    ' and StageName =:duration and sales_rep_o__r.name = \'' +
                    str +
                    '\'';
            } else if (click == 'legend') {
                QueryStr += '  and stagename =:duration ';
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
            } else if (click == 'left') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
            }
            QueryStr += ' order by stagename,Sales_Rep_O__r.name';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Neg_Win_Rate_SMD_CHK') {
            ShowClosedDate = true;
            ShowWon = true;
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            isOpptys = true;
            
            set<id> eligibleIds = new Set<id>();
            
            if (click == 'chart') {
                for (OpportunityHistory hstry : [
                    SELECT Id, OpportunityId, CreatedDate, StageName, Amount, CloseDate
                    FROM OpportunityHistory
                    WHERE
                    StageName = 'Negotiation'
                    AND Opportunity.RecordType.name = 'Seawin China Hospitality'
                    AND (Opportunity.GL_Account_Variable_1__r.name = 'Seawin China'
                         OR Opportunity.GL_Account_Variable_1__r.name = 'Seawin Hong Kong')
                    AND Opportunity.sales_rep_o__r.name IN :Active_SalesReps_CHK
                ]) {
                    eligibleIds.add(hstry.OpportunityId);
                }
            } else if (click == 'bar') {
                for (OpportunityHistory hstry : [
                    SELECT Id, OpportunityId, CreatedDate, StageName, Amount, CloseDate
                    FROM OpportunityHistory
                    WHERE
                    StageName = 'Negotiation'
                    AND Opportunity.RecordType.name = 'Seawin China Hospitality'
                    AND (Opportunity.GL_Account_Variable_1__r.name = 'Seawin China'
                         OR Opportunity.GL_Account_Variable_1__r.name = 'Seawin Hong Kong')
                    AND Opportunity.sales_rep_o__r.name = :str
                ]) {
                    eligibleIds.add(hstry.OpportunityId);
                }
            }
            
            if (Test.isRunningTest()) {
                map<id, opportunity> testMap = new Map<id, opportunity>(
                    [
                        SELECT id
                        FROM opportunity
                        WHERE
                        sales_rep_o__r.name IN :Active_SalesReps_CHK
                        AND (StageName = 'Closed Won'
                             OR StageName = 'Closed Lost')
                        LIMIT 5
                    ]
                );
                
                eligibleIds.AddAll(testMap.keyset());
            }
            
            if (eligibleIds.size() > 0) {
                string QueryStr = QueryOpportunities;
                QueryStr += ' RecordType.name = \'Seawin China Hospitality\' and ';
                QueryStr += ' (GL_Account_Variable_1__r.name = \'Seawin China\' or ';
                QueryStr += ' GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') and ';
                QueryStr += ' id in:eligibleIds and ';
                QueryStr += ' (stagename = \'Closed Won\' or stagename = \'Closed Lost\') ';
                QueryStr += ' and (NOT Name LIKE:ChangeOrder) ';
                QueryStr += ' and (NOT Name LIKE:MockupOne) ';
                QueryStr += ' and (NOT Name LIKE:MockupTwo) ';
                QueryStr += ' and (NOT Name LIKE:MockupThree) ';
                QueryStr += ' and (NOT Name LIKE:MockupFour) ';
                
                if (click == 'chart') {
                    QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_CHK ';
                } else if (click == 'bar') {
                    QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                }
                QueryStr += ' order by sales_rep_o__r.name asc, stagename desc, closed_date__c desc, Name';
                calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');

                Con = new ApexPages.StandardSetController(
                    Database.getQueryLocator(QueryStr)
                );
                Con.setPageSize(size);
            }
        } else if (chart == 'Win_Rate_SMD_CHK') {
            ShowClosedDate = true;
            ShowWon = true;
            
            String ChangeOrder = '%Change Order%';
            String MockupOne = '%Mock-Up%';
            String MockupTwo = '%Mock Up%';
            String MockupThree = '%Mock%';
            String MockupFour = '%Mockup%';
            
            isOpptys = true;
            string QueryStr = QueryOpportunities;
            QueryStr += ' RecordType.name = \'Seawin China Hospitality\' and ';
            QueryStr += ' (GL_Account_Variable_1__r.name = \'Seawin China\' or ';
            QueryStr += ' GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') and ';
            QueryStr += ' (stagename = \'Closed Won\' or stagename = \'Closed Lost\') ';
            QueryStr += ' and (NOT Name LIKE:ChangeOrder) ';
            QueryStr += ' and (NOT Name LIKE:MockupOne) ';
            QueryStr += ' and (NOT Name LIKE:MockupTwo) ';
            QueryStr += ' and (NOT Name LIKE:MockupThree) ';
            QueryStr += ' and (NOT Name LIKE:MockupFour) ';
            
            if (click == 'chart') {
                QueryStr += ' and sales_rep_o__r.name in:Active_SalesReps_CHK ';
            } else if (click == 'bar') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
            }
            QueryStr += ' order by sales_rep_o__r.name asc, stagename desc, closed_date__c desc, Name';
            calculateTotalAmount((List<Opportunity>)Database.query(QueryStr), 'Amount');

            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Activity_Graph_Last_12_Months_SMD_CHK') {
            /*****************************************************************************************************
            *   @dashboard name  : Activity Graph Last 12 Months
            *   @chart name      : Activity_Graph_Last_12_Months_SMD_CHK
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            if (String.isNotEmpty(str)) {
                All_SalesReps_CHK.clear();
                All_SalesReps_CHK.add(str);
            }
            
            List<sales_rep__c> salesReps = [
                SELECT Id, Name, Team__c, inactive_date__c
                FROM sales_rep__c
                WHERE name IN :All_SalesReps_CHK
            ];       
            
            isOpptys = true;
            showCloseDate = true;

            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = Apexpages.currentPage().getParameters().get('str');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-');
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE  (Opportunity_GL_Var_1__r.Name = \'Seawin China\' OR Opportunity_GL_Var_1__r.Name = \'Seawin Hong Kong\')';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Has_Activity_In_Last_Month__c = true ';
            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            opportunity_dashboard_query += ' AND RecordTypeName__c =\'Seawin China Hospitality\' ';


            if (click == 'chart') {
                opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name in:All_SalesReps_CHK';
            } else if(click == 'legend' || click == 'point') {
                opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name = \'' + str + '\'';
            }
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;

            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');
            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
        } else if (chart == 'Tasks_Completion_SMD_CHK') {
            isTasks = true;
            string DateStr = '';
            if (duration == 'Over Due') {
                DateStr += ' ActivityDate <: d and';
                DateStr += ' ActivityDate != null and status = \'Open\'';
            } else if (duration == 'On Time') {
                DateStr += ' ActivityDate >: d and ';
                DateStr += ' ActivityDate != null and status = \'Open\'';
            } else if (duration == 'No Due Date') {
                DateStr += ' ActivityDate=null and status=\'Open\'';
            } else {
                DateStr += ' ((ActivityDate <: d and';
                DateStr += ' ActivityDate != null and status = \'Open\')';
                
                DateStr += ' or (ActivityDate >: d and ';
                DateStr += ' ActivityDate != null and status = \'Open\')';
                
                DateStr += ' or (ActivityDate=null and status=\'Open\'))';
            }
            
            string QueryStr = QueryTasks;
            
            if (click == 'chart') {
                QueryStr += DateStr;
                QueryStr += ' and owner.name in:Active_Users_CHK ';
            } else if (click == 'bar') {
                QueryStr += DateStr;
                QueryStr += ' and owner.name = \'' + str + '\'';
            } else if (click == 'legend') {
                QueryStr += DateStr;
                QueryStr += ' and owner.name in:Active_Users_CHK ';
            } else if (click == 'left') {
                QueryStr += DateStr;
                QueryStr += ' and owner.name = \'' + str + '\'';
            }
            
            QueryStr += ' order by owner.name asc, activitydate desc';
            //allOpportunities = (List<Opportunity>)Database.query(QueryStr);
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Neglected_Opportunities_SMD_CHK') {
            
            /*****************************************************************************************************
            *   @dashboard name  : Neglected Opportunities
            *   @chart name      : Neglected_Opportunities_SMD_CHK
            *   @description     : Put data on list of records Page, depends on input params from front by url
            *   @author          : Marian Lyzhychka ©Peeklogic
            *****************************************************************************************************/
            isOpptys = true;
            ShowModBy = true;
            ShowModDate = true;
            ShowER = true;
            ShowProb = true;
            showNeglectedField = true;

            
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            String str = Apexpages.currentPage().getParameters().get('str');

            Integer year = yearStr != null && yearStr != '' ? Integer.valueOf(yearStr) : Date.Today().Year();
            Integer month = monthStr != null && monthStr != '' ? Integer.valueOf(monthStr) : Date.Today().Month();

            Map<string, integer> Last12MonthsList_CombinedMap = MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();

            String max_year;
            String max_month;
            if(click == 'chart' || click == 'legend'){
                Set<String> months = Last12MonthsList_CombinedMap.keySet(); //This method returns map of last 12 months, and we get last
                List<String> list_months = new List<String>(months);
                List<String> year_m = list_months[list_months.size() - 1].split('-');
                max_year =  year_m[1];
                max_month = year_m[0];
            } else if(click == 'point'){
                max_year = String.valueOf(year);
                max_month = String.valueOf(month);
            }

            String opportunity_dashboard_query = opp_dashb_query;

            opportunity_dashboard_query += ' WHERE  (Opportunity_GL_Var_1__r.Name = \'Seawin China\' OR Opportunity_GL_Var_1__r.Name = \'Seawin Hong Kong\')';
            opportunity_dashboard_query += ' AND Opportunity_Forecast_Category__c =\'Pipeline\' ';
            opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
            opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
            opportunity_dashboard_query += ' AND isNeglected__c = true ';
            opportunity_dashboard_query += ' AND RecordTypeName__c =\'Seawin China Hospitality\' ';

            if (click == 'chart') {
                opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name in:Active_SalesReps_CHK';
            } else if(click == 'legend' || click == 'point') {
                opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name = \'' + str + '\'';
            }
            opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';
            

            List<Opportunity_Dashboard__c> table_data = (List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query);

            opp_dashboards = table_data;

            calculateTotalAmount((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount__c');
            calculateTotalAmountCur((List<Opportunity_Dashboard__c>)Database.query(opportunity_dashboard_query), 'Amount');

        } else if (chart == 'New_Leads_SMD_CHK') {
            isLeads = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            Integer month = 5;
            
            if (yearStr != null && yearStr != '') {
                DateTime TD = Date.today();
                DateTime PrevDate = DateTime.newInstance(
                    TD.year() - 1,
                    TD.month(),
                    Date.daysInMonth(TD.year() - 1, TD.month())
                );
                
                String TodayYearShort = TD.format('YY');
                String PrevYearShort = PrevDate.format('YY');
                
                if (
                    Integer.ValueOf(yearStr) == TD.Year() ||
                    Integer.ValueOf(yearStr) == PrevDate.Year()
                ) {
                    Year = Integer.ValueOf(yearStr) == TD.Year()
                        ? TD.Year()
                        : PrevDate.Year();
                } else {
                    Year = (yearStr == TodayYearShort) ? TD.Year() : PrevDate.Year();
                }
            }
            
            Boolean JustYear = false;
            String DateStr = '';
            
            DateTime NewLeadsMonthStart;
            DateTime NewLeadsMonthEnd;
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
                
                NewLeadsMonthStart = FindMonthStartDate(year, month);
                NewLeadsMonthEnd = FindMonthEndDate(year, month);
            } else {
                DateStr += (Year == d.year())
                    ? ' CreatedDate = THIS_YEAR'
                    : ' CreatedDate = LAST_YEAR ';
                JustYear = true;
            }
            
            string QueryStr = QueryLeads;
            QueryStr += ' status = \'New\' ';
            
            if (click == 'chart') {
                QueryStr += ' and owner.name in:Active_Users_CHK ';
                QueryStr += ' and (CreatedDate = THIS_YEAR or CreatedDate = LAST_YEAR) ';
            } else if (click == 'legend') {
                QueryStr += ' and Owner.name in:Active_Users_CHK and';
                QueryStr += (JustYear)
                    ? DateStr
                    : ' CreatedDate >=:NewLeadsMonthStart and CreatedDate <=:NewLeadsMonthEnd ';
            } else if (click == 'bar') {
                QueryStr += ' and Owner.Name = \'' + str + '\' and ';
                QueryStr += (JustYear)
                    ? DateStr
                    : ' CreatedDate >=:NewLeadsMonthStart and CreatedDate <=:NewLeadsMonthEnd ';
            } else if (click == 'left') {
                QueryStr += ' and Owner.Name = \'' + str + '\'';
            }
            
            QueryStr += ' order by Owner.Name asc,CreatedDate desc';
            //allOpportunities = (List<Opportunity>)Database.query(QueryStr);
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'New_Customers_Last_12_Months_by_Type_SMD_CHK') {
            isAccounts = true;
            
            String Customer = 'Customer';
            String CustomerAndVendor = 'Customer And Vendor';
            
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SubmittedMonthStart = FindMonthStartDate(year, month);
            DateTime SubmittedMonthEnd = FindMonthEndDate(year, month);
            
            string QueryStr = QueryAccounts;
            QueryStr += ' (AcctSeed__Accounting_Type__c =:Customer or AcctSeed__Accounting_Type__c =:CustomerAndVendor) ';
            QueryStr += ' and (AcctSeed__GL_Account_Variable_1__r.Name = \'Seawin China\' or AcctSeed__GL_Account_Variable_1__r.Name = \'Seawin Hong Kong\')';
            
            if (click == 'point') {
                QueryStr += ' and createddate >= :SubmittedMonthStart AND createddate <= :SubmittedMonthEnd ';
                QueryStr += ' and Type =  \'' + str + '\'';
            }
            QueryStr += ' order by Type asc';
            //llOpportunities = (List<Opportunity>)Database.query(QueryStr);
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'Monthly_Sales_Last_12_Months_SMD_OEM_CHK') {
            // OEM Dashboard
            isOrders = true;
            String yearStr = ApexPages.currentPage().getParameters().get('year');
            String monthStr = ApexPages.currentPage().getParameters().get('month');
            
            Integer year = 2020;
            INteger month = 5;
            
            string recordtype = 'Seawin China OEM';
            //string recordtype = 'Seawin USA Hospitality';
            
            if (yearStr != null && yearStr != '') {
                year = Integer.valueOf(yearStr);
            }
            
            if (monthStr != null && monthStr != '') {
                month = Integer.valueOf(monthStr);
            }
            
            DateTime SalesMonthStart = FindMonthStartDate(year, month);
            DateTime SalesMonthEnd = FindMonthEndDate(year, month);
            
            List<opportunity> oppsChildList = new List<opportunity>();
            
            // get all sales rep name who are related to the logged in user gl variable
            showActiveDate = true;
            
            string QueryStr = QueryOrders;
            QueryStr += ' RecordType.name =:recordtype and ';
            QueryStr += ' (GL_Account_Variable_1__r.name = \'Seawin China\' or ';
            QueryStr += ' GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
            
            if (click == 'chart') {
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
            } else if (click == 'bar') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <=:SalesMonthEnd ';
            } else if (click == 'legend') {
                QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
                QueryStr += ' and CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date';
            } else if (click == 'left') {
                QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_CHK ';
                QueryStr += ' and CreatedDate >=:SalesMonthStart and CreatedDate <:SalesMonthEnd ';
            }
            QueryStr += ' order by sales_rep_o__r.name asc, CreatedDate desc';

            calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');

            //allOpportunities = (List<Opportunity>)Database.query(QueryStr);
            Con = new ApexPages.StandardSetController(
                Database.getQueryLocator(QueryStr)
            );
            Con.setPageSize(size);
        } else if (chart == 'TopTenAccounts_SMD_OEM_CHK') {
            isOrders = true;
            
            string recordtype = 'Seawin China OEM';
            string recordtype2 = 'Seawin China Hospitality';
            //string recordtype = 'Seawin USA Hospitality';
            
            Set<string> AccountIds = new Set<string>();
            
            List<AggregateResult> TopTen = [
                SELECT sum(acctseederp__total__c), acctseederp__customer__c id
                FROM acctseederp__sales_order__c
                WHERE
                (recordtype.name = :recordtype
                 OR recordtype.name = :recordtype2)
                AND (GL_Account_Variable_1__r.name = 'Seawin China'
                     OR GL_Account_Variable_1__r.name = 'Seawin Hong Kong')
                AND (CreatedDate = THIS_YEAR
                     OR CreatedDate = Last_Year)
                GROUP BY acctseederp__customer__c
                ORDER BY sum(acctseederp__total__c) DESC
                LIMIT 10
            ];
            
            if (!TopTen.isEmpty()) {
                for (aggregateResult a : TopTen) {
                    AccountIds.add((string) a.get('id'));
                }
                
                // get details of these accounts by a detailed soql query
                string QueryStr = QueryOrders;
                QueryStr += ' (recordtype.name=:recordtype or recordtype.name=:recordtype2) and ';
                QueryStr += ' (GL_Account_Variable_1__r.name = \'Seawin China\' or ';
                QueryStr += ' GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
                QueryStr += ' and (CreatedDate = THIS_YEAR or CreatedDate = Last_Year) ';
                QueryStr += ' and AcctSeedERP__Customer__c in:AccountIds ';
                QueryStr += ' order by AcctSeedERP__Customer__r.name, AcctSeedERP__Total__c desc';

                calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');
                Con = new ApexPages.StandardSetController(
                    Database.getQueryLocator(QueryStr)
                );
                Con.setPageSize(size);
            }
        } else if (chart == 'TopTenShipped_SMD_OEM_CHK') {
            String str = ApexPages.currentPage().getParameters().get('str');
            
            isOrders = true;
            showState = true;
            
            string recordtype = 'Seawin China OEM';
            //string recordtype = 'Seawin USA Hospitality';
            
            List<AggregateResult> Aggregates = [
                SELECT Count(id) ct, AcctSeedERP__Shipping_State__c state
                FROM AcctSeedERP__Sales_Order__c
                WHERE
                RecordType.Name = :recordtype
                AND (GL_Account_Variable_1__r.name = 'Seawin China'
                     OR GL_Account_Variable_1__r.name = 'Seawin Hong Kong')
                GROUP BY AcctSeedERP__Shipping_State__c
                ORDER BY Count(id) DESC
                LIMIT 10
            ];
            
            set<string> states = new Set<string>();
            
            if (!Aggregates.isEmpty()) {
                for (AggregateResult a : Aggregates) {
                    states.add((string) a.get('state'));
                }
                
                // get details of these accounts by a detailed soql query
                string QueryStr = QueryOrders;
                QueryStr += ' RecordType.name =:recordtype and ';
                QueryStr += ' (GL_Account_Variable_1__r.name = \'Seawin China\' or ';
                QueryStr += ' GL_Account_Variable_1__r.name = \'Seawin Hong Kong\') ';
                
                if (click == 'chart') {
                    QueryStr += ' and AcctSeedERP__Shipping_State__c in:states ';
                } else if (click == 'bar') {
                    if (str == 'N/A') {
                        QueryStr += ' and AcctSeedERP__Shipping_State__c = null ';
                    } else {
                        QueryStr += ' and AcctSeedERP__Shipping_State__c = \'' + str + '\'';
                    }
                }
                
                QueryStr += ' order by AcctSeedERP__Shipping_State__c asc';
                calculateTotalAmount((List<AcctSeedERP__Sales_Order__c>)Database.query(QueryStr), 'AcctSeedERP__Total__c');
                Con = new ApexPages.StandardSetController(
                    Database.getQueryLocator(QueryStr)
                );
                Con.setPageSize(size);
            }
        }  
    }
    
    public List<id> sortEngine(map<id, Integer> DataMap) {
        list<id> keyList = new List<string>();
        map<integer, list<id>> valuesMap = new Map<integer, list<id>>();
        
        for (id s : DataMap.keyset()) {
            integer value = DataMap.get(s);
            
            if (valuesMap.containskey(value)) {
                List<id> existing = valuesMap.get(value);
                existing.add(s);
                valuesMap.put(value, existing);
            } else {
                keyList = new List<id>();
                keyList.add(s);
                valuesMap.put(value, keyList);
            }
        }
        
        List<id> KeyListSorted = new List<id>();
        
        if (valuesMap.size() > 0) {
            list<integer> valuesAscending = new List<integer>(ValuesMap.keyset());
            valuesAscending.sort();
            
            List<integer> ValuesDescending = new List<integer>();
            for (Integer i = valuesAscending.size() - 1; i >= 0; i--) {
                ValuesDescending.add(valuesAscending[i]);
            }
            
            // create the sorted map
            
            for (integer d : ValuesDescending) {
                for (id s : ValuesMap.get(d)) {
                    KeyListSorted.add(s);
                }
            }
        }
        
        return KeyListSorted;
    }
    
    public Set<String> getUserIdsInSetFromTeamString(
        set<String> salesRepNames,
        String region
    ) {
        List<Sales_Rep__c> srList = new List<Sales_Rep__c>(
            [SELECT Team__c FROM Sales_Rep__c WHERE Name IN :salesRepNames]
        );
        
        Set<String> userIdsSet = new Set<String>();
        if (srList != null && srList.size() > 0) {
            for (sales_rep__c srp : srList) {
                List<String> teamUserList = srp.Team__c.split(';');
                system.debug('teamUserList === ' + teamUserList);
                for (String val : teamUserList) {
                    userIdsSet.add(val);
                }
            }
        }
        
        for (String usrId : userIdsSet) {
            if (region == 'usa') {
                if (!filteredUsersAgainstInsideSalesUsersUSAId(usrId)) {
                    userIdsSet.remove(usrId);
                }
            } else if (region == 'china') {
                if (!filteredUsersAgainstInsideSalesUsersCHKId(usrId)) {
                    userIdsSet.remove(usrId);
                }
            }
        }
        
        system.debug('userIdsSet === ' + userIdsSet);
        return userIdsSet;
    }
    
    public Set<String> getUserIdsInSetFromTeamString(
        String salesRepName,
        String region
    ) {
        List<Sales_Rep__c> srList = new List<Sales_Rep__c>(
            [SELECT Team__c FROM Sales_Rep__c WHERE Name = :str LIMIT 1]
        );
        
        Set<String> userIdsSet = new Set<String>();
        if (srList != null && srList.size() > 0) {
            List<String> teamUserList = srList[0].Team__c.split(';');
            system.debug('teamUserList === ' + teamUserList);
            for (String val : teamUserList) {
                userIdsSet.add(val);
            }
        }
        
        for (String usrId : userIdsSet) {
            if (region == 'usa') {
                if (!filteredUsersAgainstInsideSalesUsersUSAId(usrId)) {
                    userIdsSet.remove(usrId);
                }
            } else if (region == 'china') {
                if (!filteredUsersAgainstInsideSalesUsersCHKId(usrId)) {
                    userIdsSet.remove(usrId);
                }
            }
        }
        
        system.debug('userIdsSet === ' + userIdsSet);
        return userIdsSet;
    }
    
    public Boolean filteredUsersAgainstInsideSalesUsersUSAId(string userId) {
        return Inside_Sales_Users_USA_Id.contains(userId);
    }
    
    public Boolean filteredUsersAgainstInsideSalesUsersCHKId(string userId) {
        return Inside_Sales_Users_CHK_Id.contains(userId);
    }
    
    public Set<String> UserData_From_Teams(String teams) {
        Set<String> usersIds = new Set<String>();
        usersNames = new Set<String>();
        if (teams != null) {
            usersIds.addAll(UserIds_From_Teams(teams));
            usersNames.addAll(Usernames_From_Teams(usersIds));
        }
        
        //return usersIds;
        return usersNames;
    }
    
    public Set<String> UserIds_From_Teams(String teams) {
        Set<String> teamUserIds = new Set<String>();
        if (String.isNotEmpty(teams)) {
            List<String> teamsList = teams.split(';');
            for (String userid : teamsList) {
                teamUserIds.add(userid);
            }
        }
        
        return teamUserIds;
    }
    
    public Set<String> Usernames_From_Teams(Set<String> userIds) {
        Set<String> userNameSet = new Set<String>();
        
        List<User> usersList = new List<User>(
            [SELECT Name FROM User WHERE Id IN :userIds]
        );
        
        for (User usr : usersList) {
            userNameSet.add(usr.Name);
        }
        
        return userNameSet;
    }
    
    public boolean CheckUser(String TeamUserIds, String ownerId) {
        Boolean BelongsToTeam = false;
        
        if (String.isnotEmpty(TeamUserIds)) {
            List<String> UserIdList = TeamUserIds.split(';');
            
            for (String userid : UserIdList) {
                if (userid == ownerid) {
                    BelongsToTeam = true;
                    break;
                }
            }
        }
        
        return BelongsToTeam;
    }
    
    public DateTime FindMonthStartDate(Integer year, Integer month){
        
        String sdate_str = year + '-' + (month > 9 ? '' + month : '0' + month) + '-01T00:00:00.000Z';
        DateTime dt = DateTime.ValueofGmt(sdate_str.replace('T', ' '));
        return dt;
        
    }
    public DateTime FindMonthEndDate(Integer year, Integer month){
        
        Integer daysInMonth = Date.daysInMonth(year, month); 
        
        String sdate_str = year + '-' + (month > 9 ? '' + month : '0' + month) + '-' + daysInMonth + 'T23:59:59.000Z';
        DateTime dt = DateTime.ValueofGmt(sdate_str.replace('T', ' '));
        return dt;
        
    }

    public Date OnlyStartDate(){

        Date d = Date.Today();

        Integer Months_Passed = d.month();
        
        Integer Common_Start_Year = (Months_Passed < 12) ? d.year() - 1 : d.year();
        Integer Common_Start_Month = d.month() < 12 ? d.month() + 1 : 1;
        
        Date Only_Start_Date = Date.newInstance(Common_Start_Year, Common_Start_Month, 1);
        

        return Only_Start_Date;

    }

    public Date OnlyEndDate(){

        return Date.Today();

    }
}