global without sharing class OEMDashboardChinaController extends MainSalesManagerDashboardChinaCtrl{
    
    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Monthly_Sales_Last_12_Months_OEM() {

        DateTime Full_Start_Date = Full_Start_Date();
        DateTime Full_End_Date = Full_End_Date();

        Set<string> All_SalesReps = getAll_SalesReps();

        List<String> Last12MonthsList = Last12MonthsList();

        List<String> Months = Months();
        
        string recordtype = 'Seawin China OEM';
        
        List<AggregateResult> MonthlySalesOEMData = [select sales_rep_o__r.name name,calendar_month(CreatedDate) month,calendar_year(CreatedDate) year,
                                                    sum(AcctSeederp__total__c) amount
                                                    from AcctSeederp__sales_order__c
                                                    where CreatedDate >=:Full_Start_Date and 
                                                    CreatedDate <=:Full_End_Date
                                                    and RecordType.name =:recordtype
                                                    and (GL_Account_Variable_1__r.Name = 'Seawin China' or 
                                                         GL_Account_Variable_1__r.Name = 'Seawin Hong Kong')
                                                    and Sales_rep_o__r.name in:All_SalesReps
                                                    and CreatedDate != null
                                                    and AcctSeederp__total__c > 0
                                                    group by Sales_rep_o__r.name, calendar_month(CreatedDate), calendar_year(CreatedDate)
                                                    order by Sales_rep_o__r.name, calendar_year(CreatedDate) asc];
        
        map<string, List<ValuesWrapper>> MonthlySalesOEMMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> ValuesList = new List<ValuesWrapper>();
        
        if (!MonthlySalesOEMData.isEmpty()) {
            for (AggregateResult so : MonthlySalesOEMData) {
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
                
                if (MonthlySalesOEMMapLocal.containskey(key)) {
                    
                    ValuesList = MonthlySalesOEMMapLocal.get(key);
                    ValuesList.add(vw);
                } else {

                    ValuesList.add(vw);
                }
                
                MonthlySalesOEMMapLocal.put(key, ValuesList);
            }
        }
        if (MonthlySalesOEMMapLocal.size() > 0) {
            List<string> sortedKeys = sortedKeys(MonthlySalesOEMMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (MonthlySalesOEMMapLocal.containskey(s)) {
                    sortedMap.put(s, MonthlySalesOEMMapLocal.get(s));
                }
            }
            MonthlySalesOEMMapLocal = sortedMap;
            
            //MonthlySalesOEMKeys = MonthlySalesOEMMapLocal.keyset();
            //MonthlySalesOEMMap = MonthlySalesOEMMapLocal;
        }

        return MonthlySalesOEMMapLocal;
    }
    
    public void Top_Ten_Accounts_OEM() {

        Date MonthStart = getMonthStart();
        Date LastYearMonthStart = getLastYearMonthStart();
        
        string recordtype = 'Seawin China OEM';
        
        Map<string, YearlyWrapper> TopTenDetailsMap = new Map<string, YearlyWrapper>();
        
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
            AND (GL_Account_Variable_1__r.Name = 'Seawin China' OR GL_Account_Variable_1__r.Name = 'Seawin Hong Kong') 
            AND (CreatedDate = THIS_YEAR OR CreatedDate = Last_Year) 
            GROUP BY
            acctseederp__customer__r.name,
            acctseederp__customer__c,
            acctseederp__customer__r.sales_rep_o__r.name,
            acctseederp__customer__r.owner.name
            
            ORDER BY sum(acctseederp__total__c) DESC
            LIMIT 10
        ];
        if (!TopTen.isEmpty()) {
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
                TopTenDetailsMap.put((string) a.get('name'), yw);
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
                AND (GL_Account_Variable_1__r.Name = 'Seawin China' OR GL_Account_Variable_1__r.Name = 'Seawin Hong Kong') 
                AND (CreatedDate = THIS_YEAR OR CreatedDate = Last_Year) 
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
            TopTenAccountsOEM = new List<YearlyWrapper>();
            
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
                        
                        try{
                            
                            YearlyWrapper exists = TopTenDetailsMap.get(key);
                            
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
                            
                        } catch(Exception ex){
                            system.debug('Exception has occured...');
                            system.debug(ex.getMessage());
                        }
                    }
                }
                
                if (UniqueMap.size() > 0) {
                    map<string, YearlyWrapper> SortedMap = new Map<string, YearlyWrapper>();
                    // sort the map sum of amount descending using the previous map keys order
                    for (string key : TopTenDetailsMap.keyset()) {
                        if (UniqueMap.containsKey(key)) {
                            TopTenAccountsOEM.add(UniqueMap.get(key));
                        }
                    }
                }
            }
        }
    }
    
    public void Top_Ten_Shipped_OEM() {
        
        string recordtype = 'Seawin China OEM';
        Map<string, Decimal> TopTenShippedOEMLocal = new Map<string, Decimal>();
        
        List<AggregateResult> Aggregates = [
            SELECT Count(id) ct, AcctSeedERP__Shipping_State__c state
            FROM AcctSeedERP__Sales_Order__c
            WHERE
            RecordType.Name = :recordtype 
            AND (GL_Account_Variable_1__r.Name = 'Seawin China' OR GL_Account_Variable_1__r.Name = 'Seawin Hong Kong') 
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
                
                TopTenShippedOEMLocal.put(
                    key,
                    (Decimal) a.get('ct') == null ? 0 : (Decimal) a.get('ct')
                );
            }
            TopTenShippedOEMMap = TopTenShippedOEMLocal;
            TopTenShippedOEMKeys = TopTenShippedOEMLocal.keyset();
        }
    }
    
    public OEMDashboardChinaController() {
        
        if(getSysAdminCHK() || getisTest()){
            
            this.Top_Ten_Accounts_OEM();
            this.Top_Ten_Shipped_OEM();
        }
    }
}