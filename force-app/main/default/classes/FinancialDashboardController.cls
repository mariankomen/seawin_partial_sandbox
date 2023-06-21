public class FinancialDashboardController {
    
    Public List<MainWrapper> TopBillingCustomersData {get; set;}
    Public set<String> BillingAgingCategories {get; set;}
    Public Decimal AverageDueDays {get; set;}
    
    Public Boolean isTest {get; set;}
    
    Public string UserGL {get; set;}
    
    // Billing Aging
    Public Map<string, Decimal> BillingAgingMap {get; set;}
    Public set<string> BillingAgingKeys {get; set;}
    Public Integer SizeOfBillingAgingMap {get{return BillingAgingMap.size();} set;}
    
    public FinancialDashboardController(){
        
        BillingAgingMap = new Map<string, Decimal>();
        BillingAgingKeys = new set<String>();

        isTest = Test.isRunningTest();
        
        AverageDueDays = 0;
		
        this.Billing_Aging();
        this.Collection_Performance();
        this.Top_Ten_Customers_By_Balance();
    }
    
    public string BuildQuery_String(){

        user usr = [select default_gl_account_variable__c from user where id =: userinfo.getUserId() limit 1];
        
        UserGL = usr.default_gl_account_variable__c;
        
        string queryHelper = '';
        
        if(usr.default_gl_account_variable__c != null){
            
            List<string> RegionList = usr.default_gl_account_variable__c.split(';');
            
            set<String> RegionSet = new set<String>(REgionLIst);
            
            integer len = RegionSet.size();
            integer i = 1;
            
            if(len > 1){
                
                queryHelper += ' ( ';
            }
            
            for(String str : RegionSet){
                
                queryHelper += 'GL_Account_Variable_1__c =\''+ str+'\''+ ((i < len && len > 1)?' Or ':'');
                
                i++;
                
            }
            
            if(len > 1){
                
                queryHelper += ' ) ';
            }
            
            queryHelper += ' And ';
            
        }
        
        return queryHelper;
    }
    
    public void Billing_Aging(){
        
        string QueryHelper = this.BuildQuery_String();
        
        string Closed = 'Closed';
        string Posted = 'Posted';
        string CreditMemo = 'Credit Memo';
        
        set<string> BillingAgingCategories = new set<string>{'0-Current', '1-30 Days', '31-60 Days',
            '61-90 Days', 'Over 90 Days'};
                
                String QueryStr = 'SELECT AcctSeed__Age__c, AcctSeed__Balance__c';
        QueryStr += ' FROM AcctSeed__Billing__c where ';
        QueryStr += QueryHelper;
        QueryStr += (isTest) ? ' AcctSeed__Age__c !=:Closed and ' : 
        ' AcctSeed__Age__c !=:Closed and AcctSeed__Status__c =:Posted and ';
        QueryStr += ' AcctSeed__Type__c !=:CreditMemo ';
        QueryStr += ' order by AcctSeed__Age__c asc ';
        
        List<AcctSeed__Billing__c> BillingAgingRecords = Database.query(QueryStr);
        
        if(!BillingAgingRecords.IsEmpty()){
            
            for(AcctSeed__Billing__c b : BillingAgingRecords){
                string key = b.AcctSeed__Age__c;
                
                if(BillingAgingMap.containsKey(key)){
                    
                    Decimal exists = BillingAgingMap.get(key);
                    
                    Decimal newBalance = exists + b.AcctSeed__Balance__c;
                    
                    BillingAgingMap.put(key, newBalance);
                    
                }else{
                    
                    BillingAgingMap.put(key, b.AcctSeed__Balance__c == null ? 0 : b.AcctSeed__Balance__c);
                }
            }
            
            
            if(BillingAgingMap.size() > 0){
                map<string, decimal> sortedMap = new map<string, decimal>();
                
                for(string key : BillingAgingCategories){
                    if(BillingAgingMap.containsKey(key)){
                        
                        sortedMap.put(key, BillingAgingMap.get(key));
                    }else{
                        
                        sortedMap.put(key, 0);
                    }
                }
                
                BillingAgingMap = sortedMap;
                BillingAgingKeys = BillingAgingMap.keyset();
            }
        }
        
        
    }
    public void Collection_Performance(){
        
        string QueryHelper = this.BuildQuery_String();
        
        // calculate the average due days
        Decimal TotalPricesWithDays = 0;
        Decimal TotalAmounts = 0;
        
        string Closed = 'Closed';
        string Posted = 'Posted';
        string CreditMemo = 'Credit Memo';
        
        String QueryStr = 'SELECT AcctSeed__Age__c, AcctSeed__Total__c,';
        QueryStr += ' AcctSeed__Due_Date2__c FROM AcctSeed__Billing__c where ';
        QueryStr += QueryHelper;
        QueryStr += (isTest) ? ' AcctSeed__Age__c !=:Closed and ' : 
        ' AcctSeed__Age__c !=:Closed and AcctSeed__Status__c =:Posted and ';
        QueryStr += ' AcctSeed__Type__c !=:CreditMemo ';
        QueryStr += ' order by AcctSeed__Age__c asc ';
        
        List<AcctSeed__Billing__c> CollectionPerformanceRecords = Database.query(QueryStr);
        
        if(!CollectionPerformanceRecords.IsEmpty()){
            for(AcctSeed__Billing__c b : CollectionPerformanceRecords){
                
                Date tdy = Date.today();
                Date dueDate = b.AcctSeed__Due_Date2__c;
                
                Integer dueDays = (tdy > dueDate) ? dueDate.daysBetween(tdy) : tdy.daysBetween(dueDate);
                
                Decimal TotalAmt = b.AcctSeed__Total__c == null ? 0 : b.AcctSeed__Total__c;
                
                TotalAmounts += TotalAmt;
                
                Decimal amount = TotalAmt * dueDays;
                TotalPricesWithDays += amount;
                
            }
            
            AverageDueDays = (TotalPricesWithDays / TotalAmounts).setScale(2);
            
        }
    }
    Public void Top_Ten_Customers_By_Balance(){
        
        String QueryHelper = this.BuildQuery_String();
		string Posted = 'Posted';        
        
        String SumPostedBillingQuery = 'SELECT SUM(AcctSeed__Balance__c) balance,';
        SumPostedBillingQuery += 'AcctSeed__Customer__r.Name customer FROM AcctSeed__Billing__c ';
        SumPostedBillingQuery += (queryHelper != '' && !isTest) ? 'where ' + queryHelper : '';
        SumPostedBillingQuery += (isTest) ? '' : (queryHelper != '')?
            ' AcctSeed__Status__c =:Posted ':' where AcctSeed__Status__c =:Posted ';
        SumPostedBillingQuery += 'group by AcctSeed__Customer__r.Name ';
        SumPostedBillingQuery += 'order by SUM(AcctSeed__Balance__c) desc Limit 10';
        
        List<AggregateREsult> CustomersAgr = Database.Query(SumPostedBillingQuery);
        
        if(!CustomersAgr.isEmpty()){
            
            Decimal TotalBalance = 0;
            TopBillingCustomersData = new list<mainWrapper>();
            List<ValuesWrapper> TopCustomersData = new list<Valueswrapper>();
            
            for(AggregateREsult agr : CustomersAgr){
                
                if((Decimal)agr.get('balance') != 0){
                    
                    TotalBalance += (Decimal)agr.get('balance');
                
                	TopCustomersData.add(new ValuesWrapper(0,(String)agr.get('customer'), null, 
                                                           (Decimal)agr.get('balance'), null, null, null));  
                }
            }
            if(!TopCustomersData.isEmpty()){
                
                TopBillingCustomersData.add(new mainWrapper(null, TopCustomersData, TotalBalance));
            }
        }
    }
    
    public class MainWrapper{
        
        public string Name {get; set;}
        public List<ValuesWrapper> Data {get; set;}
        public Decimal total {get; set;}
        
        public MainWrapper(string n, List<ValuesWrapper> d, Decimal t){
            this.Name = n;
            this.Data = d;
            this.total = t;
        }
    }
    public class ValuesWrapper{
        public integer index {get; set;}
        public string name {get; set;}
        public string age {get; set;}
        public decimal amount {get; set;}
        public Integer year {get; set;}
        public List<string> links {get; set;}
        public decimal misc {get; set;}
        
        public ValuesWrapper(Integer i, string n, string g, decimal a, integer y, List<string> l, decimal m){
            this.Index = i;
            this.name = n;
            this.age = g;
            this.amount = a;
            this.year = y;
            this.links = l;
            this.misc = m;
        }
    }
    
}