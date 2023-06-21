public virtual class MainSalesDashboardController {
    
    public static string getcommunityUrl() {
        
        return UserInfo.getUserType() == 'PowerPartner' ? '/sales' : '';
    }
    
    public static Id LoggedInUserId() { 
        
        return userinfo.getuserid();
    }
    
    public static String loggedInUserName() { 
        
        
        return UserInfo.getName();
    }
    
    public static User getUser() { 
        
        return [select id, name, default_gl_account_variable__c, Monthly_Quota__c, CreatedDate 
                from user where id =: userinfo.getuserid() limit 1];
        
    }
    
    public static boolean getIsTest(){
        
        return Test.isRunningTest();
    }
    
    public static Date Only_Start_Date() {
        
        Date d = getTodayDate();
        
        Integer Months_Passed = d.month();
        
        // TM = Twelve Months
        
        Integer Common_Start_Year = (Months_Passed < 12) ? d.year() - 1 : d.year();
        Integer Common_Start_Month = d.month() < 12 ? d.month() + 1 : 1;
        
        Date Only_Start_Date = Date.newInstance(Common_Start_Year, Common_Start_Month, 1);
        
        
        return Only_Start_Date;
    }
    public static Date Only_End_Date() {
        
        return Date.Today();
    }
    public static DateTime Full_Start_Date() {
        
        Date d = getTodayDate();
        
        Integer Months_Passed = d.month();
        
        Integer Common_Start_Year = (Months_Passed < 12) ? d.year() - 1 : d.year();
        Integer Common_Start_Month = d.month() < 12 ? d.month() + 1 : 1;
        
        String sdate_str = Common_Start_Year + '-'+ Common_Start_Month+'-01T00:00:00.000Z';
        DateTime Full_Start_Date = DateTime.ValueofGmt(sdate_str.replace('T', ' '));
        
        
        return Full_Start_Date;
    }
    public static DateTime Full_End_Date() {
        
        return DateTime.now();
    }
    
    public static Date getTodayDate() { 
        
        return Date.today();
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
        Map<string, integer> Last12MonthsList_CombinedMap = new Map<string, integer>();
        List<String> TEMPMonthsList = new List<String>();
        
        Date Only_Start_Date = Only_Start_Date();
        Date d = getTodayDate();
        
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
    
    public static List<string> Months() {
        return new List<string>{ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec' }; 
            
            }
    
    public class MainWrapper {
        public string Name { get; set; }
        public List<ValuesWrapperSD> Data { get; set; }
        public Decimal total { get; set; }
        
        public MainWrapper(string n, List<ValuesWrapperSD> d, Decimal t) {
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
    public class ValuesWrapperSD {
        public integer valueindex { get; set; }
        public string image { get; set; }
        public string name { get; set; }
        public decimal amount { get; set; }
        public Integer year { get; set; }
        public set<string> links { get; set; }
        public decimal misc { get; set; }
        
        public ValuesWrapperSD(
            Integer i,
            string img,
            string n,
            decimal a,
            integer y,
            decimal m
        ) {
            this.valueindex = i;
            this.image = img;
            this.name = n;
            this.amount = a;
            this.year = y;
            this.misc = m;
        }
    }
    public static List<string> sortedKeys(map<string, List<ValuesWrapper>> data) {
        map<string, decimal> DataMap = new Map<string, decimal>();
        for (string key : data.keyset()) {
            List<ValuesWrapper> values = data.get(key);
            
            Decimal total = 0;
            
            for (ValuesWrapper v : values) {
                if (v.amount == null)
                    v.amount = 0;
                
                total += v.amount;
            }
            
            DataMap.put(key, total);
        }
        
        return sortEngine(DataMap);
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
    public static Decimal CalculateUptoDateQuota(Decimal MonthlyQuota,Date InactiveDate,DateTime CreatedDate) {
        Date today_date = Date.today();
        Date year_start_date = Date.newInstance(today_date.year(), 1, 1);
        Date created_date = CreatedDate == null ? null : Date.newInstance(
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
        } else if (created_date != null && created_date.year() == today_date.year()) {
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
    
    public static map<string, integer> countOpportunitiesCount(List<Opportunity> oppList, String type){
        
        map<string, integer> opportunityCount = new map<string, integer>();
        string groupType = null;
        
        for(Opportunity opp : oppList){
            
            for(Quote qt : opp.Quotes){
                
                if(qt.Status == 'Presented'){
                    
                    if(type == 'month-year'){
                        groupType = 'Newly Submitted Opportunities Last 12 Months';
                    }
                    else if(type == 'repName'){
                        groupType = (String) opp.sales_rep_o__r.name;
                    }
                    else if(type == 'leadSource'){
                        groupType = (String) opp.LeadSource;
                    }
                    
                    Date quoteSubmittedDate = Date.valueOf(opp.Newly_Submitted_Quote_First_Date__c);
                    string key = groupType + quoteSubmittedDate.month() + quoteSubmittedDate.year();
                    key = String.isNotEmpty(key) ? key.capitalize() : key;
                    
                    if(opportunityCount.containsKey(key)){
                        integer oppValue = opportunityCount.get(key);
                        opportunityCount.put(key, oppValue + 1);
                    }
                    else{
                        opportunityCount.put(key, 1);
                    }
                }
            }
        }
        
        return opportunityCount;
    }
    
    public MainSalesDashboardController(){
        
        
    }
}