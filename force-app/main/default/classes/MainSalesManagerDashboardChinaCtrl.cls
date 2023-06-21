public virtual class MainSalesManagerDashboardChinaCtrl {
    
    // Hospitality Dashboard
    public static string getcommunityUrl() {
            
            return UserInfo.getUserType() == 'PowerPartner' ? '/sales' : '';
    }
    
    public static List<string> Months() {

            return new List<string>{
                'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sept',
                    'Oct',
                    'Nov',
                    'Dec'
                    };
    }

    public static string getYearShort() {

            DateTime tdy = Date.today();
            return tdy.format('YY');
    }
    public static String getLastYearShort() {
            DateTime t = Date.today();
            DateTime tdy = Date.NewInstance(t.Year() - 1, t.month(), 1);
            
            return tdy.format('YY');
    }
    
    // Collection Performance
    public static Decimal AverageDueDays { get; set; }

    public List<YearlyWrapper> TopTenAccountsOEM { get; set; }
    
    public transient Map<string, Decimal> TopTenShippedOEMMap { get; set; }
    public transient Set<string> TopTenShippedOEMKeys { get; set; }
    public transient Integer SizeOfTopTenShippedOEMMap {
        get {
            return TopTenShippedOEMMap.size();
        }
        set;
    }
    
    // Utility functions
    public static Decimal CalculateUptoDateQuota(
        Decimal MonthlyQuota,
        Date InactiveDate,
        DateTime CreatedDate
    ) {
        Date today_date = Date.today();
        Date year_start_date = Date.newInstance(today_date.year(), 1, 1);
        Date created_date = Date.newInstance(
            CreatedDate.year(),
            CreatedDate.month(),
            CreatedDate.day()
        );
        
        Decimal per_day_quota = 0;
        
        Integer days = 0;
        Integer months = 0;
        Decimal quota = 0;
        
        if (InactiveDate != null && InactiveDate.year() == today_date.year()) {
            // If sales rep is inactive
            months = year_start_date.monthsBetween(InactiveDate);
            per_day_quota =
                MonthlyQuota /
                Date.daysInMonth(InactiveDate.year(), InactiveDate.month());
            
            days = months > 0
                ? InactiveDate.day()
                : year_start_date.daysBetween(InactiveDate);
            
            quota = (months * MonthlyQuota) + (per_day_quota * days);
        } else if (created_date.year() == today_date.year()) {
            // If the sales rep was created this year
            months = created_date.monthsBetween(today_date);
            per_day_quota =
                MonthlyQuota / Date.daysInMonth(today_date.year(), today_date.month());
            
            days = months > 0
                ? today_date.day()
                : created_date.daysBetween(today_date);
            
            quota = (months * MonthlyQuota) + (per_day_quota * days);
        } else if (InactiveDate == null) {
            // If sales rep is active and the above condition does not meet
            months = year_start_date.monthsBetween(today_date);
            per_day_quota =
                MonthlyQuota / Date.daysInMonth(today_date.year(), today_date.month());
            
            days = months > 0
                ? today_date.day()
                : year_start_date.daysBetween(today_date);
            
            quota = (months * MonthlyQuota) + (per_day_quota * days);
        }
        
        return quota;
    }
    
    public class MainWrapper {
        public string Name { get; set; }
        public List<ValuesWrapper> Data { get; set; }
        public Decimal total { get; set; }
        
        public MainWrapper(string n, List<ValuesWrapper> d, Decimal t) {
            this.Name = n;
            this.Data = d;
            this.total = t;
        }
    }
    public class ValuesWrapper {
        public integer valueindex { get; set; }
        public string name { get; set; }
        public string general { get; set; }
        public decimal amount { get; set; }
        public Integer year { get; set; }
        public List<string> links { get; set; }
        public decimal misc { get; set; }
        
        public ValuesWrapper(
            Integer i,
            string n,
            string g,
            decimal a,
            integer y,
            List<string> l,
            decimal m
        ) {
            this.valueindex = i;
            this.name = n;
            this.general = g;
            this.amount = a;
            this.year = y;
            this.links = l;
            this.misc = m;
        }
    }
    
    public class YearlyWrapper {
        public string name { get; set; }
        public string acctid { get; set; }
        public string owner { get; set; }
        public string salesrep { get; set; }
        public decimal total { get; set; }
        public decimal thismonth { get; set; }
        public decimal prevmonth { get; set; }
        public decimal lastmonth { get; set; }
        public decimal thisyear { get; set; }
        public decimal lastyear { get; set; }
        
        public YearlyWrapper(
            string n,
            string a,
            string o,
            string s,
            decimal tl,
            decimal tm,
            decimal pm,
            decimal lm,
            decimal ty,
            decimal ly
        ) {
            this.name = n;
            this.acctid = a;
            this.owner = o;
            this.salesrep = s;
            this.total = tl;
            this.thismonth = tm;
            this.prevmonth = pm;
            this.lastmonth = lm;
            this.thisyear = ty;
            this.lastyear = ly;
        }
    }
    
    public static List<string> sortedKeys(map<string, List<ValuesWrapper>> data) {
        
        list<string> sortedKeys = new List<string>(data.keyset());
        sortedKeys.sort();
        
        return sortedKeys;
    }
    
    public static List<string> sortEngine(map<string, Decimal> DataMap) {
        list<string> keyList = new List<string>();
        map<decimal, list<string>> valuesMap = new Map<decimal, list<string>>();
        
        for (string s : DataMap.keyset()) {
            Decimal value = DataMap.get(s);
            
            if (valuesMap.containskey(value)) {
                List<string> existing = valuesMap.get(value);
                existing.add(s);
                valuesMap.put(value, existing);
            } else {
                keyList = new List<string>();
                keyList.add(s);
                valuesMap.put(value, keyList);
            }
        }
        
        List<string> KeyListSorted = new List<string>();
        
        if (valuesMap.size() > 0) {
            list<Decimal> valuesAscending = new List<Decimal>(ValuesMap.keyset());
            valuesAscending.sort();
            
            List<Decimal> ValuesDescending = new List<Decimal>();
            for (Integer i = valuesAscending.size() - 1; i >= 0; i--) {
                ValuesDescending.add(valuesAscending[i]);
            }
            
            // create the sorted map
            
            for (decimal d : ValuesDescending) {
                for (string s : ValuesMap.get(d)) {
                    KeyListSorted.add(s);
                }
            }
        }
        
        return KeyListSorted;
    }
    
    public static List<String> Next12MonthsList() {
        List<String> Next12MonthsList = new List<String>();
        
        Date now = date.today();
        Integer month = now.month() - 1;
        
        List<String> names = new List<string>{
            'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sept',
                'Oct',
                'Nov',
                'Dec'
                };
                    
                    for (Integer i = 0; i < 12; ++i) {
                        Next12MonthsList.add(names[month]);
                        if (++month == 12) {
                            month = 0;
                        }
                    }

                    return Next12MonthsList;
    }
    public static List<String> Last12MonthsList() {
        List<String> Last12MonthsList = new List<String>();
        
        Date now = date.today();
        Integer month = now.month() - 1;
        
        List<String> names = new List<string>{
            'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sept',
                'Oct',
                'Nov',
                'Dec'
                };
                    
                    for (Integer i = 0; i < 12; ++i) {
                        Last12MonthsList.add(names[month]);
                        if (--month == -1) {
                            month = 11;
                        }
                    }

                    return Last12MonthsList;
    }
    public static List<String> Last12MonthsList_Horizontal() {
        List<String> Last12MonthsList_Horizontal = new List<String>();
        List<String> TEMPMonthsList = new List<String>();
        
        Date now = date.today();
        Integer month = now.month() - 1;
        
        List<String> names = new List<string>{
            'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sept',
                'Oct',
                'Nov',
                'Dec'
                };
                    
                    for (Integer i = 0; i < 12; ++i) {
                        TEMPMonthsList.add(names[month]);
                        if (--month == -1) {
                            month = 11;
                        }
                    }
        
        // reverse the order
        for (Integer i = 11; i >= 0; i--) {
            Last12MonthsList_Horizontal.add(TEMPMonthsList[i]);
        }

        return Last12MonthsList_Horizontal;
    }
    public static Map<string, integer> Last12MonthsList_CombinedMap() {
        Date d = getTodayDate();
        Date Only_Start_Date = Only_Start_Date();
        Map<string, integer> Last12MonthsList_CombinedMap = new Map<string, integer>();
        List<String> TEMPMonthsList = new List<String>();
        
        Integer Month = Only_Start_Date.month(); // 9
        Integer CurrentMonth = d.month(); // 8
        Integer TotalDifference = 12 - CurrentMonth;
        Integer TotalPreviousMonths = 12 - Month;
        
        List<String> names = new List<string>{
            'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sept',
                'Oct',
                'Nov',
                'Dec'
                };
                    
                    for (Integer i = 0; i < 12; i++) {
                        Integer year = TotalDifference > 0 &&
                            i < TotalDifference
                            ? d.year() - 1
                            : (TotalDifference == 0 && i <= TotalPreviousMonths) ||
                                (TotalDifference > 0 &&
                                 i <= TotalDifference + 11)
                                ? d.year()
                                : d.year() + 1;
                        
                        string key = month + '-' + year;
                        
                        Last12MonthsList_CombinedMap.put(key, i);
                        if (++month == 13) {
                            month = 1;
                        }
                    }

                    return Last12MonthsList_CombinedMap;
    }
    public static map<string, List<ValuesWrapper>> SortByValues(
        map<string, List<ValuesWrapper>> maps
    ) {
        map<string, List<ValuesWrapper>> returnedMap = new Map<string, List<ValuesWrapper>>();
        
        set<string> keys = maps.keyset();
        
        for (string MainKey : keys) {
            List<ValuesWrapper> values = maps.get(MainKey);
            
            map<integer, ValuesWrapper> ValuesMap = new Map<integer, valuesWrapper>();
            
            for (ValuesWrapper v : values) {
                ValuesMap.put(v.valueindex, v);
            }
            
            List<Integer> RandomKeys = new List<integer>(ValuesMap.keyset());
            
            RandomKeys.sort();
            
            map<integer, ValuesWrapper> SortedMap = new Map<integer, valuesWrapper>();
            
            for (integer SubKey : RandomKeys) {
                if (ValuesMap.containsKey(SubKey)) {
                    SortedMap.put(SubKey, ValuesMap.get(SubKey));
                }
            }
            
            returnedMap.put(MainKey, SortedMap.Values());
        }
        
        return returnedMap;
    }
    
    public static boolean CheckUser(String TeamUserIds, String ownerId) {
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
    
    public static Set<String> UserData_From_Teams(String teams) {
        Set<String> usersIds = new Set<String>();
        Set<String> usersNames = new Set<String>();
        if (teams != null) {
            usersIds.addAll(UserIds_From_Teams(teams));
            usersNames.addAll(Usernames_From_Teams(usersIds));
        }
        
        //return usersIds;
        return usersNames;
    }
    
    public static Set<String> UserIds_From_Teams(String teams) {
        Set<String> teamUserIds = new Set<String>();
        if (String.isNotEmpty(teams)) {
            List<String> teamsList = teams.split(';');
            for (String userid : teamsList) {
                teamUserIds.add(userid);
            }
        }
        
        return teamUserIds;
    }
    
    public static Set<String> Usernames_From_Teams(Set<String> userIds) {
        Set<String> userNameSet = new Set<String>();

        map<string, string> UsernameAndIdsMap = UsernameAndIdsMap();
        
        for (string userId : userIds) {
            userNameSet.add(UsernameAndIdsMap.get(userId));
        }
        
        return userNameSet;
    }

    public static map<string, integer> countOpportunitiesCount(
        List<Opportunity> oppList,
        String type
    ) {
        map<string, integer> opportunityCount = new Map<string, integer>();
        string groupType = null;
        
        for (Opportunity opp : oppList) {
            for (Quote qt : opp.Quotes) {
                if (qt.Status == 'Presented') {
                    if (type == 'month-year') {
                        groupType = 'Newly Submitted Opportunities Last 12 Months';
                    } else if (type == 'repName') {
                        groupType = (String) opp.sales_rep_o__r.name;
                    } else if (type == 'leadSource') {
                        groupType = (String) opp.LeadSource;
                    }
                    
                    Date quoteSubmittedDate = Date.valueOf(
                        opp.Newly_Submitted_Quote_First_Date__c
                    );
                    string key =
                        groupType +
                        quoteSubmittedDate.month() +
                        quoteSubmittedDate.year();
                    key = String.isNotEmpty(key) ? key.capitalize() : key;
                    
                    if (opportunityCount.containsKey(key)) {
                        integer oppValue = opportunityCount.get(key);
                        opportunityCount.put(key, oppValue + 1);
                    } else {
                        opportunityCount.put(key, 1);
                    }
                }
            }
        }
        
        return opportunityCount;
    }

    public static Set<string> Active_Users(){

        Set<string> Active_Users = new Set<string>();

        List<User> Active_Users_List = [
            SELECT name
            FROM user
            WHERE
            isActive = TRUE AND
            default_gl_account_variable__c INCLUDES ('Seawin China', 'Seawin Hong Kong')
            AND name != 'Murtaza Ashraf'
            AND name != 'Ashraf Murtaza'
        ];
        
        if (!Active_Users_List.isEmpty()) {
            for (User active_usrs : Active_Users_List) {
                Active_Users.add(active_usrs.name);
            }
        }

        if (getisTest()) {
            Active_Users.add('Murtaza Ashraf');
        }

        return Active_Users;
 
    }

    public static Set<string> Inside_Sales_Users(){

        Set<string> Inside_Sales_Users = new Set<string>();

        List<User> Inside_Sales_Users_List = [
            SELECT name
            FROM user
            WHERE
            default_gl_account_variable__c INCLUDES ('Seawin China', 'Seawin Hong Kong')
            AND Profile.name LIKE '%Inside Sales%'
            AND name != 'Murtaza Ashraf'
            AND name != 'Ashraf Murtaza'
        ];
        
        if (!Inside_Sales_Users_List.isEmpty()) {
            for (User inside_users : Inside_Sales_Users_List) {
                Inside_Sales_Users.add(inside_users.name);
            }
        }

        if (getisTest()) {
            Inside_Sales_Users.add('Murtaza Ashraf');
        }

        return Inside_Sales_Users;

    }

    public static Set<string> getAll_SalesReps(){

        Set<string> All_SalesReps = new Set<string>();

        List<sales_rep__c> All_SalesReps_List = [
            SELECT name,Monthly_Quota__c, InActive_date__c, CreatedDate, team__c
            FROM sales_rep__c
            WHERE name != 'Murtaza Ashraf' AND name != 'Ashraf Murtaza'
            //AND GL_Account_Variable_to_Sales_Rep__r.Name = 'Seawin USA'
        ];
        
        if (!All_SalesReps_List.isEmpty()) {
            for (Sales_rep__c all_sales : All_SalesReps_List) {
                All_SalesReps.add(all_sales.name);
            }
        }

        if (getisTest()) {
            All_SalesReps.add('Murtaza Ashraf');
        }

        return All_SalesReps;
    }
    
    public static List<Sales_rep__c> AllSalesRepsList(){

        List<Sales_rep__c> AllSalesRepsList = new List<Sales_rep__c>();

        List<sales_rep__c> All_SalesReps_List = [
            SELECT name,Monthly_Quota__c, InActive_date__c, CreatedDate, team__c
            FROM sales_rep__c
            WHERE name != 'Murtaza Ashraf' AND name != 'Ashraf Murtaza'
            //AND GL_Account_Variable_to_Sales_Rep__r.Name = 'Seawin USA'
        ];
        
        if (!All_SalesReps_List.isEmpty()) {
            for (Sales_rep__c all_sales : All_SalesReps_List) {
                AllSalesRepsList.add(all_sales);
            }
        }


        return AllSalesRepsList;
    }

    public static map<id, string> AllSalesRepsMap(){

        map<id, string> AllSalesRepsMap = new map<id, string>();

        List<sales_rep__c> All_SalesReps_List = [
            SELECT name,Monthly_Quota__c, InActive_date__c, CreatedDate, team__c
            FROM sales_rep__c
            WHERE name != 'Murtaza Ashraf' AND name != 'Ashraf Murtaza'
            //AND GL_Account_Variable_to_Sales_Rep__r.Name = 'Seawin USA'
        ];
        
        if (!All_SalesReps_List.isEmpty()) {
            for (Sales_rep__c all_sales : All_SalesReps_List) {
                AllSalesRepsMap.put(all_sales.id, all_sales.name);
            }
        }

        return AllSalesRepsMap;
    }

    public static Set<string> Active_SalesReps(){

        Set<string> Active_SalesReps = new Set<string>();

        List<sales_rep__c> Active_Sales_Reps_List = [
            SELECT name
            FROM sales_rep__c
            WHERE
            Active__c = 'Yes'
            AND name != 'Murtaza Ashraf'
            AND name != 'Ashraf Murtaza'
            //AND GL_Account_Variable_to_Sales_Rep__r.Name = 'Seawin USA'
        ];
        if (!Active_Sales_Reps_List.isEmpty()) {
            for (Sales_rep__c active_reps : Active_Sales_Reps_List) {
                Active_SalesReps.add(active_reps.name);
            }
        }

        if (getisTest()) {
            Active_SalesReps.add('Murtaza Ashraf');
        }

        return Active_SalesReps;
    }

    public static Set<string> All_Users(){

        Set<string> All_Users = new Set<string>();

        List<User> All_Users_List = [
            SELECT id,name
            FROM user
            WHERE
            default_gl_account_variable__c INCLUDES ('Seawin China', 'Seawin Hong Kong')
            AND name != 'Murtaza Ashraf'
            AND name != 'Ashraf Murtaza'
        ];
        
        if (!All_Users_List.isEmpty()) {
            for (User all_usrs : All_Users_List) {
                All_Users.add(all_usrs.name);
                
            }
        }

        if (getisTest()) {
            All_Users.add('Murtaza Ashraf');
        }

        return All_Users;
    }

    public static map<string, string> UsernameAndIdsMap(){

        map<string, string> UsernameAndIdsMap = new map<string, string>();

        List<User> All_Users_List = [
            SELECT id,name
            FROM user
            WHERE
            default_gl_account_variable__c INCLUDES ('Seawin China', 'Seawin Hong Kong')
            AND name != 'Murtaza Ashraf'
            AND name != 'Ashraf Murtaza'
        ];
        
        if (!All_Users_List.isEmpty()) {
            for (User all_usrs : All_Users_List) {
                UsernameAndIdsMap.put(all_usrs.id, all_usrs.name);
                
            }
        }

        return UsernameAndIdsMap;
    }

    public static Set<string> getAll_Lead_Soruces(){

        Set<string> All_Lead_Soruces = new Set<string>();

        List<AggregateResult> oppList = new List<AggregateResult>(
            [SELECT LeadSource FROM opportunity GROUP BY LeadSource]
        );
        if (oppList.size() > 0) {
            for (AggregateResult opp : oppList) {
                string leadSource = (string) opp.get('LeadSource');
                leadSource = String.isNotEmpty(leadSource)
                    ? leadSource.capitalize()
                    : leadSource;
                All_Lead_Soruces.add(leadSource);
            }
        }

        return All_Lead_Soruces;

    }

    public static Set<string> getAll_Account_Types(){

        Set<string> All_Account_Types = new Set<string>();

        Schema.DescribeFieldResult accountTypeFieldResult = Account.Type.getDescribe();
        List<Schema.PicklistEntry> accountTypeList = accountTypeFieldResult.getPicklistValues();
        if (!accountTypeList.isEmpty()) {
            for (Schema.PicklistEntry at : accountTypeList) {
                All_Account_Types.add(at.getValue());
            }
        }

        return All_Account_Types;
    }

    public static string getYear(){

        Date d = Date.today();

        Datetime thsYear = DateTime.newInstance(d.year(), d.month(), d.day());

        return thsYear.format('YYYY');

    }

    public static string getLastYear(){

        Date d = getTodayDate();

        Datetime lstYear = DateTime.newInstance(d.year() - 1, d.month(), d.day());

        return  lstYear.format('YYYY');

    }

    public static boolean getSysAdminCHK(){

        Boolean SysAdminCHK = false;

        List<User> LoggedInUserCHK = [
            SELECT id
            FROM user
            WHERE
            default_gl_account_variable__c INCLUDES ('Seawin China', 'Seawin Hong Kong')
            AND default_gl_account_variable__c EXCLUDES ('Seawin USA') 
            AND id = :UserInfo.getUserId()
            LIMIT 1
        ];
        
        if (!LoggedInUserCHK.isEmpty()) {
            SysAdminCHK = true;
        }

        return SysAdminCHK;
    }

    public static boolean getisTest(){

        return Test.isRunningTest();
    }

    public static Date getTodayDate(){

        return Date.today();
    }

    public static Date getMonthStart(){

        Date d = getTodayDate();

        return Date.newInstance(d.year(), d.month(), 1);
    }

    public static Date getMonthEnd(){

        Date d = getTodayDate();

        return Date.newInstance(d.year(), d.month(), Date.DaysInMonth(d.year(), d.month()));
    }

    public static Date getLastYearMonthStart(){

        Date d = getTodayDate();

        return Date.newInstance(d.year() - 1, d.month(), 1);
    }

    public static String getPrevMonthName(){

        Date d = getTodayDate();

        Datetime thsYear = DateTime.newInstance(d.year(), d.month(), d.day());

        List<string> Months = Months();

        return Months[((thsYear.month() - 2) > -1) ? thsYear.month() - 2 : 11] +
        ' \'' +
        thsYear.format('YY');
    }

    public static String getMonthName(){

        Date d = getTodayDate();

        Datetime thsYear = DateTime.newInstance(d.year(), d.month(), d.day());

        List<string> Months = Months();

        return  Months[thsYear.month() - 1] + ' \'' + thsYear.format('YY');
    }

    public static String getLastYearMonthName(){

        Date d = getTodayDate();

        Datetime thsYear = DateTime.newInstance(d.year(), d.month(), d.day());
        Datetime lstYear = DateTime.newInstance(d.year() - 1, d.month(), d.day());

        List<string> Months = Months();

        return  Months[thsYear.month() - 1] + ' \'' + lstYear.format('YY');

    }

    public static DateTime Full_Start_Date(){

        Date d = getTodayDate();

        Integer Months_Passed = d.month();
        
        Integer Common_Start_Year = (Months_Passed < 12) ? d.year() - 1 : d.year();
        Integer Common_Start_Month = d.month() < 12 ? d.month() + 1 : 1;

        String sdate_str = Common_Start_Year + '-'+ Common_Start_Month+'-01T00:00:00.000Z';
        DateTime Full_Start_Date = DateTime.ValueofGmt(sdate_str.replace('T', ' '));

        return Full_Start_Date;

    }

    public static DateTime Full_End_Date(){

        return DateTime.now();
    }

    public static Date Only_Start_Date(){

        Date d = getTodayDate();

        Integer Months_Passed = d.month();
        
        Integer Common_Start_Year = (Months_Passed < 12) ? d.year() - 1 : d.year();
        Integer Common_Start_Month = d.month() < 12 ? d.month() + 1 : 1;
        
        Date Only_Start_Date = Date.newInstance(Common_Start_Year, Common_Start_Month, 1);
        

        return Only_Start_Date;

    }

    public static Date Only_End_Date(){

        return Date.Today();

    }

    public static List<ValuesWrapper> SortIndices(List<ValuesWrapper> values){

        map<integer, ValuesWrapper> sortMap = new map<integer, ValuesWrapper>();

        for(ValuesWrapper vw : values){

            sortMap.put(vw.valueIndex, vw);
        }

        List<Integer> keys = new List<Integer>(sortMap.keyset());

        keys.sort();

        values.clear();

        for(Integer intg : keys){

            values.add(sortMap.get(intg));
        }

        return values;
    }
    
    public MainSalesManagerDashboardChinaCtrl(){
        
        AverageDueDays = 0;

        TopTenAccountsOEM = new List<YearlyWrapper>();
        
        TopTenShippedOEMMap = new Map<string, Decimal>();
        TopTenShippedOEMKeys = new Set<string>();
        
    }
}