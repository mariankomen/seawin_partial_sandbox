global without sharing class OnlineDropShipmentDashboardUSACtrl extends MainSalesManagerDashboardUSACtrl {
	
    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Monthly_Sales_Last_12_Months_DropShip() {

        DateTime Full_Start_Date = Full_Start_Date();
        DateTime Full_End_Date = Full_End_Date();

        Set<string> All_SalesReps = getAll_SalesReps();

        List<String> Last12MonthsList = Last12MonthsList();

        List<String> Months = Months();
        
        string recordtype = 'Seawin USA Online/Drop Shipment';
        //recordtype = 'Seawin USA Hospitality';
        
        List<AggregateResult> MonthlySalesDropshipData = [select sales_rep_o__r.name name,calendar_month(CreatedDate) month,calendar_year(CreatedDate) year,
                                                         sum(AcctSeederp__total__c) amount
                                                         from AcctSeederp__sales_order__c
                                                         where CreatedDate >=:Full_Start_Date and 
                                                          CreatedDate <=:Full_End_Date
                                                         and RecordType.name =:recordtype
                                                         and GL_Account_Variable_1__r.Name = 'Seawin USA'
                                                         and Sales_rep_o__r.name in:All_SalesReps
                                                         and CreatedDate != null
                                                         and AcctSeederp__total__c > 0
                                                         group by Sales_rep_o__r.name, calendar_month(CreatedDate), calendar_year(CreatedDate)
                                                         order by Sales_rep_o__r.name, calendar_year(CreatedDate) asc];
        
        map<string, List<ValuesWrapper>> MonthlySalesDropshipMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> ValuesList = new List<ValuesWrapper>();
        
        if (!MonthlySalesDropshipData.isEmpty()) {
            for (AggregateResult so : MonthlySalesDropshipData) {
                string key = (string) so.get('name');
                key = String.isNotEmpty(key) ? key.capitalize() : key;
                
                ValuesList = new List<ValuesWrapper>();
                
                ValuesWrapper vw = new ValuesWrapper(
                            Last12MonthsList.indexOf(Months[(Integer) so.get('month') - 1]),
                            Months[(Integer) so.get('month') - 1],
                            Months[(Integer) so.get('month') - 1],
                            (Decimal) so.get('amount'),
                            (Integer) so.get('year'),
                            null,
                            null
                        );
                
                if (MonthlySalesDropshipMapLocal.containskey(key)) {
                    
                    ValuesList = MonthlySalesDropshipMapLocal.get(key);
                    ValuesList.add(vw);
                } else {

                    ValuesList.add(vw);
                }
                
                MonthlySalesDropshipMapLocal.put(key, ValuesList);
            }
        }
        if (MonthlySalesDropshipMapLocal.size() > 0) {
            List<string> sortedKeys = sortedKeys(MonthlySalesDropshipMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (MonthlySalesDropshipMapLocal.containskey(s)) {
                    sortedMap.put(s, MonthlySalesDropshipMapLocal.get(s));
                }
            }
            MonthlySalesDropshipMapLocal = sortedMap;
            
            //MonthlySalesDropshipKeys = MonthlySalesDropshipMapLocal.keyset();
            //MonthlySalesDropshipMap = MonthlySalesDropshipMapLocal;
        }
        
        return MonthlySalesDropshipMapLocal;
    }
    
    public void Top_Ten_Accounts_Dropship() {

        Date MonthStart = getMonthStart();
        Date LastYearMonthStart = getLastYearMonthStart();

        string recordtype = 'Seawin USA Online/Drop Shipment';
        //string recordtype = 'Seawin USA Hospitality';
        Map<string, YearlyWrapper> TopTenDetailsMap = new Map<string, YearlyWrapper>();
        //Seawin USA Online/Drop Shipment
        
        List<AggregateResult> TopTen = [
            SELECT
            sum(acctseederp__total__c) total,
            acctseederp__customer__r.name name,
            acctseederp__customer__c id,
            acctseederp__customer__r.sales_rep_o__r.name salesrep,
            acctseederp__customer__r.owner.name owner
            FROM acctseederp__sales_order__c
            WHERE
            recordtype.name = :recordtype
            AND GL_Account_Variable_1__r.Name = 'Seawin USA'
            AND (CreatedDate = THIS_YEAR
                 OR CreatedDate = Last_Year)
            GROUP BY
            acctseederp__customer__r.name,
            acctseederp__customer__c,
            acctseederp__customer__r.sales_rep_o__r.name,
            acctseederp__customer__r.owner.name
            
            ORDER BY sum(acctseederp__total__c) DESC
            LIMIT 10
        ];
        if (!TopTen.isEmpty()) {
            String nameOfCustomer = '';
            for (AggregateResult a : TopTen) {
                YearlyWrapper yw = new YearlyWrapper(
                    (string) a.get('name'),
                    (string) a.get('id'),
                    (string) a.get('owner'),
                    (string) a.get('salesrep'),
                    (decimal) a.get('total'),
                    0,
                    0,
                    0,
                    0,
                    0
                );
                nameOfCustomer = (string) a.get('name');
                TopTenDetailsMap.put(nameOfCustomer.capitalize(), yw);
            }
        }
        
        if (TopTenDetailsMap.size() > 0) {
            List<AggregateResult> details = [
                SELECT
                sum(acctseederp__total__c) amount,
                acctseederp__customer__r.name name,
                acctseederp__customer__c id,
                acctseederp__customer__r.sales_rep_o__r.name salesrep,
                acctseederp__customer__r.owner.name owner,
                calendar_year(CreatedDate) year,
                calendar_month(CreatedDate) month
                FROM acctseederp__sales_order__c
                WHERE
                recordtype.name = :recordtype
                AND GL_Account_Variable_1__r.Name = 'Seawin USA'
                AND (CreatedDate = THIS_YEAR
                     OR CreatedDate = Last_Year)
                AND acctseederp__customer__r.name IN :TopTenDetailsMap.keySet()
                GROUP BY
                acctseederp__customer__r.name,
                acctseederp__customer__c,
                acctseederp__customer__r.sales_rep_o__r.name,
                acctseederp__customer__r.owner.name,
                calendar_year(CreatedDate),
                calendar_month(CreatedDate)
                
                ORDER BY
                acctseederp__customer__r.name,
                calendar_year(CreatedDate),
                calendar_month(CreatedDate)
            ];
            TopTenAccountsDropship = new List<YearlyWrapper>();
            
            map<string, YearlyWrapper> UniqueMap = new Map<string, YearlyWrapper>();
            
            if (!details.isEmpty()) {
                for (AggregateResult a : details) {
                    String key = a.get('name') != null && 
                    (String)a.get('name') != 'NA' && (String)a.get('name') != 'N/A' ? 
                    (String) a.get('name') : 'N/A';
                    key = String.isNotEmpty(key) && key != 'N/A' ? key.capitalize() : key;
                    
                    Integer year = (Integer) a.get('year');
                    Integer month = (Integer) a.get('month');
                    
                    Boolean IsCurrentMonth = false;
                    Boolean IsCurrentYear = false;
                    Boolean IsLastMonth = false;
                    Boolean IsPrevMonth = false;
                    
                    Decimal MonthTotal = 0;
                    Decimal YearTotal = 0;
                    
                    if (year == MonthStart.year()) {
                        // this year
                        if (month == MonthStart.Month()) {
                            // this year's this month
                            IsCurrentMonth = true;
                            MonthTotal = (Decimal) a.get('amount');
                        } else if (month == (MonthStart.Month() - 1)) {
                            MonthTotal = (Decimal) a.get('amount');
                            IsPrevMonth = true;
                        }
                        IsCurrentYear = true;
                        YearTotal = (Decimal) a.get('amount');
                    } else if (year == LastYearMonthStart.year()) {
                        // last year
                        if (month == LastYearMonthStart.month()) {
                            // last year's this month
                            MonthTotal = (Decimal) a.get('amount');
                            IsLastMonth = true;
                        }
                        YearTotal = (Decimal) a.get('amount');
                    }
                    
                    if (UniqueMap.containsKey(key)) {
                        YearlyWrapper yw = UniqueMap.get(key);
                        
                        if (IsCurrentYear) {
                            if ((IsCurrentMonth)) {
                                yw.thismonth += MonthTotal;
                            } else if (isPrevMonth) {
                                yw.prevmonth += MonthTotal;
                            }
                            yw.thisyear += YearTotal;
                        } else {
                            if (IsLastMonth) {
                                yw.lastmonth += MonthTotal;
                            }
                            yw.lastyear += YearTotal;
                        }
                        
                        UniqueMap.put(key, yw);
                    } else {
                        YearlyWrapper exists = TopTenDetailsMap.get(key);
                        if (exists != null) {
                            YearlyWrapper yw = new YearlyWrapper(
                                exists.name,
                                exists.acctid,
                                exists.owner,
                                exists.salesrep,
                                exists.total,
                                (IsCurrentMonth) ? MonthTotal : 0,
                                (IsPrevMonth) ? MonthTotal : 0,
                                (IsLastMonth) ? MonthTotal : 0,
                                (IsCurrentYear) ? YearTotal : 0,
                                (!IsCurrentYear) ? YearTotal : 0
                            );
                            
                            UniqueMap.put(key, yw);
                        }
                    }
                }
                
                if (UniqueMap.size() > 0) {
                    map<string, YearlyWrapper> SortedMap = new Map<string, YearlyWrapper>();
                    // sort the map sum of amount descending using the previous map keys order
                    for (string key : TopTenDetailsMap.keyset()) {
                        if (UniqueMap.containsKey(key)) {
                            TopTenAccountsDropship.add(UniqueMap.get(key));
                        }
                    }
                }
            }
        }
    }
    
    public void Top_Ten_Shipped_Dropship() {
        string recordtype = 'Seawin USA Online/Drop Shipment';
        //string recordtype = 'Seawin USA Hospitality';
        Map<string, Decimal> TopTenShippedDropShipLocal = new Map<string, Decimal>();
        
        List<AggregateResult> Aggregates = [
            SELECT Count(id) ct, AcctSeedERP__Shipping_State__c state
            FROM AcctSeedERP__Sales_Order__c
            WHERE
            RecordType.Name = :recordtype
            AND GL_Account_Variable_1__r.Name = 'Seawin USA'
            GROUP BY AcctSeedERP__Shipping_State__c
            ORDER BY Count(id) DESC
            LIMIT 10
        ];
        
        if (!Aggregates.IsEmpty()) {
            for (AggregateResult a : Aggregates) {
                String key = a.get('state') != null && 
                    (String)a.get('state') != 'NA' && (String)a.get('state') != 'N/A' ? 
                    (String) a.get('state') : 'N/A';
                    key = String.isNotEmpty(key) && key != 'N/A' ? key.capitalize() : key;
                
                TopTenShippedDropShipLocal.put(
                    key,
                    (Decimal) a.get('ct') == null ? 0 : (Decimal) a.get('ct')
                );
            }
            TopTenShippedDropshipMap = TopTenShippedDropShipLocal;
            TopTenShippedDropShipKeys = TopTenShippedDropShipLocal.keyset();
        }
    }
    
    public OnlineDropShipmentDashboardUSACtrl() {

        if (getSysAdminUSA()) {
            this.Top_Ten_Accounts_Dropship();
            this.Top_Ten_Shipped_Dropship();
        }
    }
}