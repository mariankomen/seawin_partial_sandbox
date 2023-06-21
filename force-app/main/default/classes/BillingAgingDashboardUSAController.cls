global without sharing class BillingAgingDashboardUSAController extends MainSalesManagerDashboardUSACtrl {

    public BillingAgingDashboardUSAController() {

    }
    
    @RemoteAction
    @ReadOnly
    global static map<string, decimal> Billing_Aging() {
        
        Boolean isTest = getisTest();
        String userId = UserInfo.getUserId();
        Set<string> All_Users = All_Users();
        
        map<string, decimal> BillingAgingMap = new map<string, decimal>();

        Decimal TotalPricesWithDays = 0;
        Decimal TotalAmounts = 0;

        string Closed = 'Closed';
        string Posted = 'Posted';
        string CreditMemo = 'Credit Memo';
        
        set<string> BillingAgingCategories = new Set<string>{
            '0-Current',
                '1-30 Days',
                '31-60 Days',
                '61-90 Days',
                'Over 90 Days'
                };
                    
        String QueryStr = 'SELECT AcctSeed__Age__c, AcctSeed__Balance__c, AcctSeed__Total__c, ';
        QueryStr += ' AcctSeed__Due_Date2__c FROM AcctSeed__Billing__c where ';
        QueryStr += (isTest) ? ' OwnerId =:UserId ' : ' Owner.name in:All_Users ';
        QueryStr += (isTest)
            ? ' and AcctSeed__Age__c !=:Closed and '
            : ' and AcctSeed__Age__c !=:Closed and AcctSeed__Status__c =:Posted and ';
        QueryStr += ' AcctSeed__Type__c !=:CreditMemo and ';
        QueryStr += ' GL_Account_Variable_1__c =\'Seawin USA\' ';
        QueryStr += ' order by AcctSeed__Age__c asc ';
        
        List<AcctSeed__Billing__c> BillingAgingRecords = Database.query(QueryStr);
        
        if (!BillingAgingRecords.IsEmpty()) {
            for (AcctSeed__Billing__c b : BillingAgingRecords) {
                string key = b.AcctSeed__Age__c;
                
                if (BillingAgingMap.containsKey(key)) {
                    Decimal exists = BillingAgingMap.get(key);
                    
                    Decimal newBalance = exists + b.AcctSeed__Balance__c;
                    
                    BillingAgingMap.put(key, newBalance);
                } else {
                    BillingAgingMap.put(
                        key,
                        b.AcctSeed__Balance__c == null ? 0 : b.AcctSeed__Balance__c
                    );
                }

                // The code below is for Collection_Performance graph
                Date tdy = Date.today();
                Date dueDate = b.AcctSeed__Due_Date2__c;
                
                Integer dueDays = (tdy > dueDate)
                    ? dueDate.daysBetween(tdy)
                    : tdy.daysBetween(dueDate);
                
                Decimal TotalAmt = b.AcctSeed__Total__c == null
                    ? 0
                    : b.AcctSeed__Total__c;
                
                TotalAmounts += TotalAmt;
                
                Decimal amount = TotalAmt * dueDays;
                TotalPricesWithDays += amount;

            }
            
            if (BillingAgingMap.size() > 0) {
                map<string, decimal> sortedMap = new Map<string, decimal>();
                
                for (string key : BillingAgingCategories) {
                    if (BillingAgingMap.containsKey(key)) {
                        sortedMap.put(key, BillingAgingMap.get(key));
                    } else {
                        sortedMap.put(key, 0);
                    }
                }
                
                BillingAgingMap = sortedMap;
                //BillingAgingKeys = BillingAgingMap.keyset();


                //AverageDueDays = (TotalPricesWithDays / TotalAmounts).setScale(2);
            }
        }
        
        return BillingAgingMap;
    }
    
    @RemoteAction
    @ReadOnly
    global static Decimal Billing_Collection_Performance() {
        
        Boolean isTest = getisTest();
        String userId = UserInfo.getUserId();
        Set<string> All_Users = All_Users();
        
        decimal AverageDueDays = 0.00;
        
        map<string, decimal> BillingAgingMap = new map<string, decimal>();

        Decimal TotalPricesWithDays = 0;
        Decimal TotalAmounts = 0;

        string Closed = 'Closed';
        string Posted = 'Posted';
        string CreditMemo = 'Credit Memo';
        
        set<string> BillingAgingCategories = new Set<string>{
            '0-Current',
                '1-30 Days',
                '31-60 Days',
                '61-90 Days',
                'Over 90 Days'
                };
                    
        String QueryStr = 'SELECT AcctSeed__Age__c, AcctSeed__Balance__c, AcctSeed__Total__c, ';
        QueryStr += ' AcctSeed__Due_Date2__c FROM AcctSeed__Billing__c where ';
        QueryStr += (isTest) ? ' OwnerId =:UserId ' : ' Owner.name in:All_Users ';
        QueryStr += (isTest)
            ? ' and AcctSeed__Age__c !=:Closed and '
            : ' and AcctSeed__Age__c !=:Closed and AcctSeed__Status__c =:Posted and ';
        QueryStr += ' AcctSeed__Type__c !=:CreditMemo and ';
        QueryStr += ' GL_Account_Variable_1__c =\'Seawin USA\' ';
        QueryStr += ' order by AcctSeed__Age__c asc ';
        
        List<AcctSeed__Billing__c> BillingAgingRecords = Database.query(QueryStr);
        
        if (!BillingAgingRecords.IsEmpty()) {
            for (AcctSeed__Billing__c b : BillingAgingRecords) {
                string key = b.AcctSeed__Age__c;
                
                if (BillingAgingMap.containsKey(key)) {
                    Decimal exists = BillingAgingMap.get(key);
                    
                    Decimal newBalance = exists + b.AcctSeed__Balance__c;
                    
                    BillingAgingMap.put(key, newBalance);
                } else {
                    BillingAgingMap.put(
                        key,
                        b.AcctSeed__Balance__c == null ? 0 : b.AcctSeed__Balance__c
                    );
                }

                // The code below is for Collection_Performance graph
                Date tdy = Date.today();
                Date dueDate = b.AcctSeed__Due_Date2__c;
                
                Integer dueDays = (tdy > dueDate)
                    ? dueDate.daysBetween(tdy)
                    : tdy.daysBetween(dueDate);
                
                Decimal TotalAmt = b.AcctSeed__Total__c == null
                    ? 0
                    : b.AcctSeed__Total__c;
                
                TotalAmounts += TotalAmt;
                
                Decimal amount = TotalAmt * dueDays;
                TotalPricesWithDays += amount;

            }
            
            if (BillingAgingMap.size() > 0) {


                AverageDueDays = (TotalPricesWithDays / TotalAmounts).setScale(2);
            }
        }
        
        return AverageDueDays;
    }
}