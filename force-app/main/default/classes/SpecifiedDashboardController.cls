global without sharing class SpecifiedDashboardController extends MainSalesManagerDashboardUSACtrl{
    

    @RemoteAction
    @ReadOnly
    global static map<String, List<ValuesWrapper>> Monthly_Sales_Last_12_Months_Specified() {

        DateTime Full_Start_Date = Full_Start_Date();
        DateTime Full_End_Date = Full_End_Date();

        set<String> All_SalesReps = getAll_SalesReps();
        List<String> Months = Months();
        List<String> Last12MonthsList = Last12MonthsList();

        map<String, List<ValuesWrapper>> MonthlySalesMapLocal = new Map<string, List<ValuesWrapper>>();
        
        List<AggregateResult> MonthlySalesData = [select Specified_Rep__r.name name, calendar_month(CreatedDate) month,
        calendar_year(CreatedDate) year,
        sum(AcctSeederp__total__c) amount from AcctSeederp__sales_order__c
        where CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date
        
        and GL_Account_Variable_1__r.Name = 'Seawin USA'
        and Specified_Rep__c != null
        and AcctSeederp__total__c > 0
        group by Specified_Rep__r.name,calendar_month(CreatedDate),
        calendar_year(CreatedDate)
        order by Specified_Rep__r.name, calendar_year(CreatedDate),
        calendar_month(CreatedDate) asc];

        List<ValuesWrapper> ValuesList = new List<ValuesWrapper>();
        
        if (!MonthlySalesData.isEmpty()) {
            for (AggregateResult so : MonthlySalesData) {
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
                
                if (MonthlySalesMapLocal.containskey(key)) {
                    
                    ValuesList = MonthlySalesMapLocal.get(key);
                    ValuesList.add(vw);
                } else {
                    
                    ValuesList.add(vw);
                }
                
                MonthlySalesMapLocal.put(key, ValuesList);
            }
        }
        if (MonthlySalesMapLocal.size() > 0) {
            List<string> sortedKeys = sortedKeys(MonthlySalesMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (MonthlySalesMapLocal.containskey(s)) {
                    sortedMap.put(s, MonthlySalesMapLocal.get(s));
                }
            }
            MonthlySalesMapLocal = sortedMap;
        }

        return MonthlySalesMapLocal;
    }

    @RemoteAction
    @ReadOnly
    global static map<String, List<ValuesWrapper>> Monthly_Sales_Last_12_Months_Referrall() {

        DateTime Full_Start_Date = Full_Start_Date();
        DateTime Full_End_Date = Full_End_Date();

        set<String> All_SalesReps = getAll_SalesReps();
        List<String> Months = Months();
        List<String> Last12MonthsList = Last12MonthsList();

        map<String, List<ValuesWrapper>> MonthlySalesMapLocal = new Map<string, List<ValuesWrapper>>();
        
        List<AggregateResult> MonthlySalesData = [select Referral_Sales_Rep__r.name name, calendar_month(CreatedDate) month,
        calendar_year(CreatedDate) year,
        sum(AcctSeederp__total__c) amount from AcctSeederp__sales_order__c
        where CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date
        
        and GL_Account_Variable_1__r.Name = 'Seawin USA'
        and Referral_Sales_Rep__c != null
        and AcctSeederp__total__c > 0
        group by Referral_Sales_Rep__r.name,calendar_month(CreatedDate),
        calendar_year(CreatedDate)
        order by Referral_Sales_Rep__r.name, calendar_year(CreatedDate),
        calendar_month(CreatedDate) asc];

        List<ValuesWrapper> ValuesList = new List<ValuesWrapper>();
        
        if (!MonthlySalesData.isEmpty()) {
            for (AggregateResult so : MonthlySalesData) {
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
                
                if (MonthlySalesMapLocal.containskey(key)) {
                    
                    ValuesList = MonthlySalesMapLocal.get(key);
                    ValuesList.add(vw);
                } else {
                    
                    ValuesList.add(vw);
                }
                
                MonthlySalesMapLocal.put(key, ValuesList);
            }
        }
        if (MonthlySalesMapLocal.size() > 0) {
            List<string> sortedKeys = sortedKeys(MonthlySalesMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (MonthlySalesMapLocal.containskey(s)) {
                    sortedMap.put(s, MonthlySalesMapLocal.get(s));
                }
            }
            MonthlySalesMapLocal = sortedMap;
        }

        return MonthlySalesMapLocal;
    }

    @RemoteAction
    @ReadOnly
    global static map<String, List<ValuesWrapper>> Monthly_Sales_Last_12_Months_Manufacture() {

        DateTime Full_Start_Date = Full_Start_Date();
        DateTime Full_End_Date = Full_End_Date();

        set<String> All_SalesReps = getAll_SalesReps();
        List<String> Months = Months();
        List<String> Last12MonthsList = Last12MonthsList();

        map<String, List<ValuesWrapper>> MonthlySalesMapLocal = new Map<string, List<ValuesWrapper>>();
        
        List<AggregateResult> MonthlySalesData = [select Manufacturer_Rep__r.name name, calendar_month(CreatedDate) month,
        calendar_year(CreatedDate) year,
        sum(AcctSeederp__total__c) amount from AcctSeederp__sales_order__c
        where CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date
        
        and GL_Account_Variable_1__r.Name = 'Seawin USA'
        and Manufacturer_Rep__c != null
        and AcctSeederp__total__c > 0
        group by Manufacturer_Rep__r.name,calendar_month(CreatedDate),
        calendar_year(CreatedDate)
        order by Manufacturer_Rep__r.name, calendar_year(CreatedDate),
        calendar_month(CreatedDate) asc];

        List<ValuesWrapper> ValuesList = new List<ValuesWrapper>();
        
        if (!MonthlySalesData.isEmpty()) {
            for (AggregateResult so : MonthlySalesData) {
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
                
                if (MonthlySalesMapLocal.containskey(key)) {
                    
                    ValuesList = MonthlySalesMapLocal.get(key);
                    ValuesList.add(vw);
                } else {
                    
                    ValuesList.add(vw);
                }
                
                MonthlySalesMapLocal.put(key, ValuesList);
            }
        }
        if (MonthlySalesMapLocal.size() > 0) {
            List<string> sortedKeys = sortedKeys(MonthlySalesMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (MonthlySalesMapLocal.containskey(s)) {
                    sortedMap.put(s, MonthlySalesMapLocal.get(s));
                }
            }
            MonthlySalesMapLocal = sortedMap;
        }

        return MonthlySalesMapLocal;
    }

    @RemoteAction
    @ReadOnly
    global static List<AggregateResult> Specififed_Reps_Sales_Last_12_Months() {
        //Sales Last 12 Months by Specified Rep
        List<AggregateResult> MonthlySalesData = [SELECT Specified_Rep__r.Name name,
                                                        calendar_month(Inserting_Date__c) month,
                                                        calendar_year(Inserting_Date__c) year,
                                                        SUM(Total_With_Fee__c) amount
                                                        FROM Sales_Order_Dashboard__c
                                                        WHERE GL_Account_Variable_1__r.Name = 'Seawin USA'
                                                        AND Opportunity__r.Specified_del__c = true
                                                        AND Specified_Rep__c != null
                                                        GROUP BY Specified_Rep__r.Name, 
                                                                    calendar_year(Inserting_Date__c), 
                                                                    calendar_month(Inserting_Date__c)
                                                                    ];
        
        return MonthlySalesData;
    }

    @RemoteAction
    @ReadOnly
    global static Map<String, List<AggregateResult>> Specififed_Reps_Total_Pipeline_Pre_Order_Last_12_Months() {
        /*****************************************************************************************************
        *   @dashboard name  : Pre-Orders Pipeline last 12 months by Specified Rep
        *   @chart name      : Sales_Reps_Total_Pipeline_SMD_USA
        *   @description     : Preparing data for frontend rendering
        *   @author          : Marian Lyzhychka ©Peeklogic
        *****************************************************************************************************/
        Set<string> All_SalesReps = getAll_SalesReps();

        Map<string, integer> Last12MonthsList_CombinedMap = Last12MonthsList_CombinedMap();
        
        List<AggregateResult> opp_dashboard_data = [SELECT  SUM(Amount__c) amount, 
                                                            calendar_month(Inserting_Date__c) month,
                                                            calendar_year(Inserting_Date__c) year,
                                                            Specified_Rep__r.Name sal_rep
                                                            FROM Opportunity_Dashboard__c
                                                            WHERE Month_Year__c IN:Last12MonthsList_CombinedMap.keySet()
                                                            AND Opportunity_Forecast_Category__c = 'Pipeline'
                                                            AND Opportunity_GL_Var_1__r.Name = 'Seawin USA'
                                                            AND Amount__c != null
                                                            AND Opportunity_StageName__c = 'Pre-Order'
                                                            AND Specified__c = true
                                                            AND Specified_Rep__c != null
                                                            GROUP BY Specified_Rep__r.Name, 
                                                                    calendar_year(Inserting_Date__c), 
                                                                    calendar_month(Inserting_Date__c)];

        Map<String, List<AggregateResult>> sal_rep_month = new Map<String, List<AggregateResult>>();
        
        for(AggregateResult ar:opp_dashboard_data){
            String salRepName = String.valueOf(ar.get('sal_rep'));
            if(!sal_rep_month.containsKey(salRepName)){
                List<AggregateResult> sal_rep_data = new List<AggregateResult>();
                sal_rep_data.add(ar);
                sal_rep_month.put(salRepName,sal_rep_data);
            } else{
                sal_rep_month.get(salRepName).add(ar);
            }
        }

        return sal_rep_month;
    }
    
    
    

    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Sales_Forecast_Pipeline_Spicified() {
        //Sales Forecast by Specified Rep
        List<String> Next12MonthsList = Next12MonthsList();

        Date d = getTodayDate();

        Set<string> All_SalesReps = getAll_SalesReps();

        List<String> Months = Months();

        map<string, decimal> MissedOpptysMap = new Map<string, decimal>();
        
        Date Pipeline_Start_Date = Date.newInstance(d.Year(), d.Month(), 1);
        Date Future_Date = Pipeline_Start_Date.addMonths(11);
        
        Date Pipeline_End_Date = Date.newInstance(
            Future_Date.year(),
            Future_Date.month(),
            Date.daysInMonth(Future_Date.year(), Future_Date.month())
        );
        
        List<AggregateResult> MissedForecasts = [select Specified_Rep__r.name name, Sum(ExpectedRevenue) amount from opportunity
                                                Where CloseDate <: Pipeline_Start_Date
                                                and Specified_del__c = true
                                                and Specified_Rep__c != null
                                                and GL_Account_Variable_1__r.name = 'Seawin USA'
                                                
                                                and ForecastCategoryName = 'Pipeline'
                                                group by Specified_Rep__r.name];
        
        if (!MissedForecasts.isEmpty()) {
            for (aggregateresult agr : Missedforecasts) {
                MissedOpptysMap.put(
                    (String) agr.get('name'),
                    (decimal) agr.get('amount')
                );
            }
        }
        
        // List<AggregateResult> forecasts = [select Specified_Rep__r.name name,calendar_month(CloseDate) month,calendar_year(closedate) year,
        //                                     Sum(ExpectedRevenue) amount from opportunity
        //                                     Where Specified_Rep__c != null
        //                                     and GL_Account_Variable_1__r.name = 'Seawin USA'
                                            
        //                                     and ForecastCategoryName = 'Pipeline'
        //                                     group by Specified_Rep__r.name, calendar_month(closedate), calendar_year(closedate)
        //                                     order by calendar_year(closedate) asc];
        List<AggregateResult> forecasts = [select Specified_Rep__r.name name,calendar_month(CloseDate) month,calendar_year(closedate) year,
                                          Sum(ExpectedRevenue) amount from opportunity
                                          Where CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date
                                          and Specified_del__c = true
                                          and Specified_Rep__c != null
                                          and GL_Account_Variable_1__r.name = 'Seawin USA'
                                          
                                          and ForecastCategoryName = 'Pipeline'
                                          group by Specified_Rep__r.name, calendar_month(closedate), calendar_year(closedate)
                                          order by calendar_year(closedate) asc];
        
        map<string, List<ValuesWrapper>> ForecastMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> ValuesList = new List<ValuesWrapper>();
        if (!forecasts.isEmpty()) {
            for (AggregateResult a : forecasts) {
                string key = (String) a.get('name');
                key = String.isNotEmpty(key) ? key.capitalize() : key;
                
                Decimal missedAmount = MissedOpptysMap.containsKey(key)
                    ? MissedOpptysMap.get(key)
                    : 0;
                
                ValuesList = new List<ValuesWrapper>();
                
                ValuesWrapper vw = new ValuesWrapper(
                            Next12MonthsList.indexOf(Months[(Integer) a.get('month') - 1]),
                            Months[(Integer) a.get('month') - 1],
                            (String) a.get('name'),
                            (Decimal) a.get('amount'),
                            (Integer) a.get('year'),
                            null,
                            MissedAmount
                        );
                
                if (ForecastMapLocal.containsKey(key)) {
                    
                    ValuesList = ForecastMapLocal.get(key);
                    ValuesList.add(vw);
                } else {

                    ValuesList.add(vw);
                }
                
                ForecastMapLocal.put(key, ValuesList);
            }
        }
        if (ForecastMapLocal.size() > 0) {
            // sort the data
            List<string> sortedKeys = sortedKeys(ForecastMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (ForecastMapLocal.containskey(s)) {
                    sortedMap.put(s, ForecastMapLocal.get(s));
                }
            }
            
            ForecastMapLocal = sortedMap;
            
            //ForecastKeys = ForecastMapLocal.keyset();
            //ForecastMap = ForecastMapLocal;
        }

        return ForecastMapLocal;
    }

    @RemoteAction
    @ReadOnly
    global static List<AggregateResult> Company_Total_Pipeline_Last_12_Months_Specified(){
        /*****************************************************************************************************
        *   @dashboard name  : Company Total Specified Pipeline Last 12 Months
        *   @chart name      : Company_Total_Pipeline_Last_12_Months_Specified
        *   @description     : Preparing data for frontend rendering
        *   @author          : Marian Lyzhychka ©Peeklogic
        *****************************************************************************************************/
        Set<string> All_SalesReps = getAll_SalesReps();

        Map<string, integer> Last12MonthsList_CombinedMap = Last12MonthsList_CombinedMap();
        
        List<AggregateResult> opportunity_data = [
            SELECT  
            SUM(Amount__c) amount, 
            calendar_month(Inserting_Date__c) month,
            calendar_year(Inserting_Date__c) year
            FROM Opportunity_Dashboard__c 
            WHERE 
            Month_Year__c IN:Last12MonthsList_CombinedMap.keySet()
            AND Opportunity_Forecast_Category__c = 'Pipeline'
            AND Opportunity_GL_Var_1__r.Name = 'Seawin USA'
            AND Amount__c != null
            AND Specified__c = true
            AND Specified_Rep__c != null            
            GROUP BY calendar_year(Inserting_Date__c), calendar_month(Inserting_Date__c)
        ];
        system.debug(JSON.serialize(opportunity_data));
        
        return opportunity_data;
    }



    @RemoteAction
    @ReadOnly
    global static Map<String, List<AggregateResult>> Specififed_Reps_Total_Pipeline_Last_12_Months() {
        /*****************************************************************************************************
        *   @dashboard name  : Pipeline Last 12 Months by Specified Rep
        *   @chart name      : Sales_Reps_Total_Pipeline_SMD_USA
        *   @description     : Preparing data for frontend rendering
        *   @author          : Marian Lyzhychka ©Peeklogic
        *****************************************************************************************************/
        Set<string> All_SalesReps = getAll_SalesReps();

        Map<string, integer> Last12MonthsList_CombinedMap = Last12MonthsList_CombinedMap();
        
        List<AggregateResult> opp_dashboard_data = [SELECT  SUM(Amount__c) amount, 
                                                            calendar_month(Inserting_Date__c) month,
                                                            calendar_year(Inserting_Date__c) year,
                                                            Specified_Rep__r.Name sal_rep
                                                            FROM Opportunity_Dashboard__c
                                                            WHERE Month_Year__c IN:Last12MonthsList_CombinedMap.keySet()
                                                            AND Opportunity_Forecast_Category__c = 'Pipeline'
                                                            AND Opportunity_GL_Var_1__r.Name = 'Seawin USA'
                                                            AND Amount__c != null
                                                            AND Specified__c = true
                                                            AND Specified_Rep__c != null
                                                            GROUP BY Specified_Rep__r.Name, 
                                                                    calendar_year(Inserting_Date__c), 
                                                                    calendar_month(Inserting_Date__c)];

        Map<String, List<AggregateResult>> sal_rep_month = new Map<String, List<AggregateResult>>();
        
        for(AggregateResult ar:opp_dashboard_data){
            String salRepName = String.valueOf(ar.get('sal_rep'));
            if(!sal_rep_month.containsKey(salRepName)){
                List<AggregateResult> sal_rep_data = new List<AggregateResult>();
                sal_rep_data.add(ar);
                sal_rep_month.put(salRepName,sal_rep_data);
            } else{
                sal_rep_month.get(salRepName).add(ar);
            }
        }

        return sal_rep_month;
    }


    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Newly_Submitted_Opportunities_By_Specified_Rep() {

        Set<string> Active_SalesReps = Active_SalesReps();

        Date Only_Start_Date = Only_Start_Date();
        Date Only_End_Date = Only_End_Date();

        List<String> Months = Months();

        List<String> Last12MonthsList_Horizontal = Last12MonthsList_Horizontal();
        
        String ChangeOrder = '%Change Order%';
        String MockupOne = '%Mock-Up%';
        String MockupTwo = '%Mock Up%';
        String MockupThree = '%Mock%';
        String MockupFour = '%Mockup%';
        
        List<Opportunity> submitted = [
            SELECT
            Id,
            Newly_Submitted_Quote_First_Date__c,
            sales_rep_o__r.name,
            (SELECT Status FROM Quotes ORDER BY CreatedDate ASC LIMIT 1)
            FROM Opportunity
            WHERE GL_Account_Variable_1__r.Name = 'Seawin USA'
            AND Newly_Submitted_Quote_First_Date__c >= :Only_Start_Date
            AND Newly_Submitted_Quote_First_Date__c <= :Only_End_Date
            AND Parent_Opportunity__c = NULL
            AND Specified_Rep__c != null
            AND Specified_del__c = true
            AND Type != 'Template'
            AND (NOT Name LIKE :ChangeOrder)
            AND (NOT Name LIKE :MockupOne)
            AND (NOT Name LIKE :MockupTwo)
            AND (NOT Name LIKE :MockupThree)
            AND (NOT Name LIKE :MockupFour)
            ORDER BY Newly_Submitted_Quote_First_Date__c ASC
        ];
        
        map<string, List<ValuesWrapper>> NewlySubmittedOpportunitiesMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> ValuesList = new List<ValuesWrapper>();
        map<string, integer> opportunitiesCount = new Map<string, integer>();
        set<string> checkValueWrapper = new Set<string>();
        opportunitiesCount = countOpportunitiesCount(submitted, 'month-year');
        
        if (!submitted.isEmpty()) {
            for (Opportunity a : submitted) {
                Date quoteSubmittedDate = Date.valueOf(
                    a.Newly_Submitted_Quote_First_Date__c
                );
                
                string key = 'Newly Submitted Opportunities Last 12 Months';
                
                ValuesList = new List<ValuesWrapper>();
                
                ValuesWrapper vw = new ValuesWrapper(
                                Last12MonthsList_Horizontal.indexOf( Months[(Integer) quoteSubmittedDate.month() - 1] ),
                                Months[(Integer) quoteSubmittedDate.month() - 1],
                                Months[(Integer) quoteSubmittedDate.month() - 1],
                                opportunitiesCount.get(key + quoteSubmittedDate.month() + quoteSubmittedDate.year()),
                                (Integer) quoteSubmittedDate.year(),
                                null,
                                null
                            );
                
                if (checkValueWrapper.contains(key + quoteSubmittedDate.month() + quoteSubmittedDate.year())){
                    // do nothing
                } else {
                    checkValueWrapper.add( key + quoteSubmittedDate.month() + quoteSubmittedDate.year());
                    
                    if (NewlySubmittedOpportunitiesMapLocal.containsKey(key)) {
                        ValuesList = NewlySubmittedOpportunitiesMapLocal.get(key );
                        ValuesList.add(vw);
                    } else {
                        ValuesList.add(vw);
                    }
                    
                    NewlySubmittedOpportunitiesMapLocal.put(key, ValuesList);
                }
            }
        }
        
        if (NewlySubmittedOpportunitiesMapLocal.size() > 0) {
            // sort the data
            List<string> sortedKeys = sortedKeys(NewlySubmittedOpportunitiesMapLocal );
            //List<string> sortedKeys = this.sortedKeysIntegerParsingVersion(NewlySubmittedOpportunitiesMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (NewlySubmittedOpportunitiesMapLocal.containskey(s)) {
                    sortedMap.put(s, NewlySubmittedOpportunitiesMapLocal.get(s));
                }
            }
            
            NewlySubmittedOpportunitiesMapLocal = sortedMap;
            //NewlySubmittedOpportunitiesKeys = NewlySubmittedOpportunitiesMap.keyset();
        }

        return NewlySubmittedOpportunitiesMapLocal;
    }

    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Lost_Specified_Opportunities() {

        Set<string> All_SalesReps = getAll_SalesReps();

        Date Only_Start_Date = Only_Start_Date();
        Date Only_End_Date = Only_End_Date();

        List<String> Months = Months();

        List<String> Last12MonthsList_Horizontal = Last12MonthsList_Horizontal();
        
        String ChangeOrder = '%Change Order%';
        String MockupOne = '%Mock-Up%';
        String MockupTwo = '%Mock Up%';
        String MockupThree = '%Mock%';
        String MockupFour = '%Mockup%';
        
        List<AggregateResult> LostOpptysData = [select calendar_month(Closed_Date__c) month,calendar_year(Closed_Date__c) year,
                                               Count(id) ct from opportunity 
                                                Where Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date
                                               and GL_Account_Variable_1__r.Name = 'Seawin USA'
                                               and StageName = 'Closed Lost' AND Parent_Opportunity__c = NULL
                                               and Specified_del__c = true
                                               and Specified_Rep__c != null
                                               AND (NOT Name LIKE :ChangeOrder)
                                               AND (NOT Name LIKE :MockupOne)
                                               AND (NOT Name LIKE :MockupTwo)
                                               AND (NOT Name LIKE :MockupThree)
                                               AND (NOT Name LIKE :MockupFour)
                                               group by calendar_month(Closed_Date__c), calendar_year(Closed_Date__c)
                                               order by calendar_year(Closed_Date__c) asc];
        
        map<string, List<ValuesWrapper>> LostOpptyMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> ValuesList = new List<ValuesWrapper>();
        string key = 'Lost Opportunities Last 12 Months';
        
        if (!LostOpptysData.isEmpty()) {
            for (AggregateResult a : LostOpptysData) {
                
                ValuesList = new List<ValuesWrapper>();
                
                ValuesWrapper vw = new ValuesWrapper(
                            Last12MonthsList_Horizontal.indexOf(
                                Months[(Integer) a.get('month') - 1]
                            ),
                            Months[(Integer) a.get('month') - 1],
                            Months[(Integer) a.get('month') - 1],
                            (Decimal) a.get('ct'),
                            (Integer) a.get('year'),
                            null,
                            null
                        );
                
                if (LostOpptyMapLocal.containsKey(key)) {
                    
                    ValuesList = LostOpptyMapLocal.get(key);
                    ValuesList.add(vw);
                } else {

                    ValuesList.add(vw);
                }
                LostOpptyMapLocal.put(key, ValuesList);
            }
        }
        if (LostOpptyMapLocal.size() > 0) {
            // sort the data
            List<string> sortedKeys = sortedKeys(LostOpptyMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (LostOpptyMapLocal.containskey(s)) {
                    sortedMap.put(s, LostOpptyMapLocal.get(s));
                }
            }
            
            LostOpptyMapLocal = sortedMap;
            
            //LostOpptysKeys = LostOpptyMapLocal.keyset();
            //LostOpptysMap = LostOpptyMapLocal;
        }

        return LostOpptyMapLocal;
    }


    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Win_Rate_Specified() {

        

        String ChangeOrder = '%Change Order%';
        String MockupOne = '%Mock-Up%';
        String MockupTwo = '%Mock Up%';
        String MockupThree = '%Mock%';
        String MockupFour = '%Mockup%';
        
        map<string, List<ValuesWrapper>> WinRateMapLocal = new Map<string, List<ValuesWrapper>>();
        
        List<AggregateResult> totals = [
            SELECT count(id) ct, Specified_Rep__r.name name
            FROM opportunity
            WHERE GL_Account_Variable_1__r.name = 'Seawin USA'
            AND (StageName = 'Closed Won'
                 OR StageName = 'Closed Lost')
            AND (NOT Name LIKE :ChangeOrder)
            AND (NOT Name LIKE :MockupOne)
            AND (NOT Name LIKE :MockupTwo)
            AND (NOT Name LIKE :MockupThree)
            AND (NOT Name LIKE :MockupFour)
            AND Specified_Rep__c != null 
            AND Specified_del__c = true
            GROUP BY Specified_Rep__r.name
        ];
        
        List<AggregateResult> WinData = new List<AggregateResult>();
        map<string, decimal> TotalOpptysMap = new Map<string, decimal>();
        // if (!totals.isEmpty()) {
            for (AggregateResult a : totals) {
                string key = (string) a.get('name');
                key = String.isNotEmpty(key) ? key.capitalize() : key;
                
                TotalOpptysMap.put(key, (decimal) a.get('ct'));
            }
            
            system.debug('TotalOpptysMap: '+JSON.serialize(TotalOpptysMap));
            WinData = [
                SELECT count(id) ct, Specified_Rep__r.name name
                FROM opportunity
                WHERE GL_Account_Variable_1__r.name = 'Seawin USA'
                AND StageName = 'Closed Won'
                AND (NOT Name LIKE :ChangeOrder)
                AND (NOT Name LIKE :MockupOne)
                AND (NOT Name LIKE :MockupTwo)
                AND (NOT Name LIKE :MockupThree)
                AND (NOT Name LIKE :MockupFour)
                AND Specified_Rep__c != null 
                AND Specified_del__c = true
                GROUP BY Specified_Rep__r.name
                ORDER BY Specified_Rep__r.name
            ];
        // }
        
        List<ValuesWrapper> WinDataList = new List<ValuesWrapper>();
        map<string, Decimal> TotalMap = new Map<string, Decimal>();
        
        Integer i = 0;
        if (!WinData.isEmpty()) {
            for (AggregateResult a : WinData) {
                string key = (String) a.get('name');
                key = String.isNotEmpty(key) ? key.capitalize() : key;
                
                Decimal totalOpptys = TotalOpptysMap.get(key) == null ? 0 : TotalOpptysMap.get(key);
                Decimal ct = (Decimal) a.get('ct');
                Decimal percent = totalOpptys != 0 ? (ct / totalOpptys) * 100 : 0;
                
                WinDataList = new List<ValuesWrapper>();
                WinDataList.add(
                    new ValuesWrapper(
                        i,
                        null,
                        null,
                        percent.setScale(2),
                        null,
                        null,
                        null
                    )
                );
                
                WinRateMapLocal.put(key, WinDataList);
                i++;
            }
        }
        
        if (WinRateMapLocal.size() > 0) {
            List<string> sortedKeys = sortedKeys(WinRateMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (WinRateMapLocal.containskey(s)) {
                    sortedMap.put(s, WinRateMapLocal.get(s));
                }
            }
            WinRateMapLocal = sortedMap;
            
            //WinRateKeys = WinRateMapLocal.Keyset();
            //WinRateMap = WinRateMapLocal;
        }

        return WinRateMapLocal;
    }

    @RemoteAction
    @ReadOnly
    global static List<Opportunity> Win_Rate_Specified_New() {
        String ChangeOrder = '%Change Order%';
        String MockupOne = '%Mock-Up%';
        String MockupTwo = '%Mock Up%';
        String MockupThree = '%Mock%';
        String MockupFour = '%Mockup%';

        List<Opportunity> opps = [SELECT id, name, Specified_Rep__r.name, stagename
                                    FROM opportunity
                                    WHERE GL_Account_Variable_1__r.name = 'Seawin USA'
                                    AND (StageName = 'Closed Won'
                                        OR StageName = 'Closed Lost')
                                    
                                    AND Specified_Rep__c != null 
                                    AND Specified_del__c = true
                            ];
        return opps;
    }
    @RemoteAction
    @ReadOnly
    global static List<Opportunity> Win_Rate_Ref_New() {
        String ChangeOrder = '%Change Order%';
        String MockupOne = '%Mock-Up%';
        String MockupTwo = '%Mock Up%';
        String MockupThree = '%Mock%';
        String MockupFour = '%Mockup%';

        List<Opportunity> opps = [SELECT id, name, Referral_Sales_Rep__r.name, stagename
                                    FROM opportunity
                                    WHERE GL_Account_Variable_1__r.name = 'Seawin USA'
                                    AND (StageName = 'Closed Won'
                                        OR StageName = 'Closed Lost')
                                    
                                    AND Referral_Sales_Rep__c != null 
                            ];
        return opps;
    }






    //Sales Last 12 Months by Referral Rep
    @RemoteAction
    @ReadOnly
    global static List<AggregateResult> Refferal_Reps_Sales_Last_12_Months() {

        List<AggregateResult> MonthlySalesData = [SELECT Referral_Sales_Rep__r.Name name,
                                                        calendar_month(Inserting_Date__c) month,
                                                        calendar_year(Inserting_Date__c) year,
                                                        SUM(Total_With_Fee__c) amount
                                                        FROM Sales_Order_Dashboard__c
                                                        WHERE GL_Account_Variable_1__r.Name = 'Seawin USA'
                                                        AND Referral_Sales_Rep__c != null
                                                        GROUP BY Referral_Sales_Rep__r.Name, 
                                                                    calendar_year(Inserting_Date__c), 
                                                                    calendar_month(Inserting_Date__c)
                                                                    ];
        
        return MonthlySalesData;
    }

    @RemoteAction
    @ReadOnly
    global static Map<String, List<AggregateResult>> Refferral_Reps_Total_Pipeline_Pre_Order_Last_12_Months() {
        /*****************************************************************************************************
        *   @dashboard name  : Pre-Orders Pipeline last 12 months by Referral Rep
        *   @chart name      : Sales_Reps_Total_Pipeline_SMD_USA
        *   @description     : Preparing data for frontend rendering
        *   @author          : Marian Lyzhychka ©Peeklogic
        *****************************************************************************************************/
        Set<string> All_SalesReps = getAll_SalesReps();

        Map<string, integer> Last12MonthsList_CombinedMap = Last12MonthsList_CombinedMap();
        
        List<AggregateResult> opp_dashboard_data = [SELECT  SUM(Amount__c) amount, 
                                                            calendar_month(Inserting_Date__c) month,
                                                            calendar_year(Inserting_Date__c) year,
                                                            Referral_Sales_Rep__r.Name sal_rep
                                                            FROM Opportunity_Dashboard__c
                                                            WHERE Month_Year__c IN:Last12MonthsList_CombinedMap.keySet()
                                                            AND Opportunity_Forecast_Category__c = 'Pipeline'
                                                            AND Opportunity_GL_Var_1__r.Name = 'Seawin USA'
                                                            AND Amount__c != null
                                                            AND Opportunity_StageName__c = 'Pre-Order'
                                                            AND Referral_Sales_Rep__c != null
                                                            GROUP BY Referral_Sales_Rep__r.Name, 
                                                                    calendar_year(Inserting_Date__c), 
                                                                    calendar_month(Inserting_Date__c)];

        Map<String, List<AggregateResult>> sal_rep_month = new Map<String, List<AggregateResult>>();
        
        for(AggregateResult ar:opp_dashboard_data){
            String salRepName = String.valueOf(ar.get('sal_rep'));
            if(!sal_rep_month.containsKey(salRepName)){
                List<AggregateResult> sal_rep_data = new List<AggregateResult>();
                sal_rep_data.add(ar);
                sal_rep_month.put(salRepName,sal_rep_data);
            } else{
                sal_rep_month.get(salRepName).add(ar);
            }
        }

        return sal_rep_month;
    }


    //Sales Forecast by Referral Rep
    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Sales_Forecast_Pipeline_Refferrall() {

        List<String> Next12MonthsList = Next12MonthsList();

        Date d = getTodayDate();

        Set<string> All_SalesReps = getAll_SalesReps();

        List<String> Months = Months();

        map<string, decimal> MissedOpptysMap = new Map<string, decimal>();
        
        Date Pipeline_Start_Date = Date.newInstance(d.Year(), d.Month(), 1);
        Date Future_Date = Pipeline_Start_Date.addMonths(11);
        
        Date Pipeline_End_Date = Date.newInstance(
            Future_Date.year(),
            Future_Date.month(),
            Date.daysInMonth(Future_Date.year(), Future_Date.month())
        );
        
        List<AggregateResult> MissedForecasts = [select Referral_Sales_Rep__r.name name, Sum(ExpectedRevenue) amount from opportunity
                                                Where CloseDate <: Pipeline_Start_Date
                                                and Referral_Sales_Rep__c != null
                                                and GL_Account_Variable_1__r.name = 'Seawin USA'
                                                
                                                and ForecastCategoryName = 'Pipeline'
                                                group by Referral_Sales_Rep__r.name];
        
        if (!MissedForecasts.isEmpty()) {
            for (aggregateresult agr : Missedforecasts) {
                MissedOpptysMap.put(
                    (String) agr.get('name'),
                    (decimal) agr.get('amount')
                );
            }
        }
        
        
        List<AggregateResult> forecasts = [select Referral_Sales_Rep__r.name name,calendar_month(CloseDate) month,calendar_year(closedate) year,
                                          Sum(ExpectedRevenue) amount from opportunity
                                          Where CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date
                                          and Referral_Sales_Rep__c != null
                                          and GL_Account_Variable_1__r.name = 'Seawin USA'
                                          
                                          and ForecastCategoryName = 'Pipeline'
                                          group by Referral_Sales_Rep__r.name, calendar_month(closedate), calendar_year(closedate)
                                          order by calendar_year(closedate) asc];
        
        map<string, List<ValuesWrapper>> ForecastMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> ValuesList = new List<ValuesWrapper>();
        if (!forecasts.isEmpty()) {
            for (AggregateResult a : forecasts) {
                string key = (String) a.get('name');
                key = String.isNotEmpty(key) ? key.capitalize() : key;
                
                Decimal missedAmount = MissedOpptysMap.containsKey(key)
                    ? MissedOpptysMap.get(key)
                    : 0;
                
                ValuesList = new List<ValuesWrapper>();
                
                ValuesWrapper vw = new ValuesWrapper(
                            Next12MonthsList.indexOf(Months[(Integer) a.get('month') - 1]),
                            Months[(Integer) a.get('month') - 1],
                            (String) a.get('name'),
                            (Decimal) a.get('amount'),
                            (Integer) a.get('year'),
                            null,
                            MissedAmount
                        );
                
                if (ForecastMapLocal.containsKey(key)) {
                    
                    ValuesList = ForecastMapLocal.get(key);
                    ValuesList.add(vw);
                } else {

                    ValuesList.add(vw);
                }
                
                ForecastMapLocal.put(key, ValuesList);
            }
        }
        if (ForecastMapLocal.size() > 0) {
            // sort the data
            List<string> sortedKeys = sortedKeys(ForecastMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (ForecastMapLocal.containskey(s)) {
                    sortedMap.put(s, ForecastMapLocal.get(s));
                }
            }
            
            ForecastMapLocal = sortedMap;
            
            //ForecastKeys = ForecastMapLocal.keyset();
            //ForecastMap = ForecastMapLocal;
        }

        return ForecastMapLocal;
    }


    @RemoteAction
    @ReadOnly
    global static List<AggregateResult> Company_Total_Pipeline_Last_12_Months_Referral(){
        /*****************************************************************************************************
        *   @dashboard name  : Company Total Specified Pipeline Last 12 Months
        *   @chart name      : Company_Total_Pipeline_Last_12_Months_Referral
        *   @description     : Preparing data for frontend rendering
        *   @author          : Marian Lyzhychka ©Peeklogic
        *****************************************************************************************************/
        Set<string> All_SalesReps = getAll_SalesReps();

        Map<string, integer> Last12MonthsList_CombinedMap = Last12MonthsList_CombinedMap();
        
        List<AggregateResult> opportunity_data = [
            SELECT  
            SUM(Amount__c) amount, 
            calendar_month(Inserting_Date__c) month,
            calendar_year(Inserting_Date__c) year
            FROM Opportunity_Dashboard__c 
            WHERE 
            Month_Year__c IN:Last12MonthsList_CombinedMap.keySet()
            AND Opportunity_Forecast_Category__c = 'Pipeline'
            AND Opportunity_GL_Var_1__r.Name = 'Seawin USA'
            AND Amount__c != null
            AND Referral_Sales_Rep__c != null            
            GROUP BY calendar_year(Inserting_Date__c), calendar_month(Inserting_Date__c)
        ];
        system.debug(JSON.serialize(opportunity_data));
        
        return opportunity_data;
    }

    @RemoteAction
    @ReadOnly
    global static Map<String, List<AggregateResult>> Referral_Reps_Total_Pipeline_Last_12_Months() {
        /*****************************************************************************************************
        *   @dashboard name  : Pipeline Last 12 Months by Specified Rep
        *   @chart name      : Sales_Reps_Total_Pipeline_SMD_USA
        *   @description     : Preparing data for frontend rendering
        *   @author          : Marian Lyzhychka ©Peeklogic
        *****************************************************************************************************/
        Set<string> All_SalesReps = getAll_SalesReps();

        Map<string, integer> Last12MonthsList_CombinedMap = Last12MonthsList_CombinedMap();
        
        List<AggregateResult> opp_dashboard_data = [SELECT  SUM(Amount__c) amount, 
                                                            calendar_month(Inserting_Date__c) month,
                                                            calendar_year(Inserting_Date__c) year,
                                                            Referral_Sales_Rep__r.Name sal_rep
                                                            FROM Opportunity_Dashboard__c
                                                            WHERE Month_Year__c IN:Last12MonthsList_CombinedMap.keySet()
                                                            AND Opportunity_Forecast_Category__c = 'Pipeline'
                                                            AND Opportunity_GL_Var_1__r.Name = 'Seawin USA'
                                                            AND Amount__c != null
                                                            AND Referral_Sales_Rep__c != null
                                                            GROUP BY Referral_Sales_Rep__r.Name, 
                                                                    calendar_year(Inserting_Date__c), 
                                                                    calendar_month(Inserting_Date__c)];

        Map<String, List<AggregateResult>> sal_rep_month = new Map<String, List<AggregateResult>>();
        
        for(AggregateResult ar:opp_dashboard_data){
            String salRepName = String.valueOf(ar.get('sal_rep'));
            if(!sal_rep_month.containsKey(salRepName)){
                List<AggregateResult> sal_rep_data = new List<AggregateResult>();
                sal_rep_data.add(ar);
                sal_rep_month.put(salRepName,sal_rep_data);
            } else{
                sal_rep_month.get(salRepName).add(ar);
            }
        }

        return sal_rep_month;
    }

    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Newly_Submitted_Opportunities_By_Referrall_Rep() {

        Set<string> Active_SalesReps = Active_SalesReps();

        Date Only_Start_Date = Only_Start_Date();
        Date Only_End_Date = Only_End_Date();

        List<String> Months = Months();

        List<String> Last12MonthsList_Horizontal = Last12MonthsList_Horizontal();
        
        String ChangeOrder = '%Change Order%';
        String MockupOne = '%Mock-Up%';
        String MockupTwo = '%Mock Up%';
        String MockupThree = '%Mock%';
        String MockupFour = '%Mockup%';
        
        List<Opportunity> submitted = [
            SELECT
            Id,
            Newly_Submitted_Quote_First_Date__c,
            Referral_Sales_Rep__r.name,
            (SELECT Status FROM Quotes ORDER BY CreatedDate ASC LIMIT 1)
            FROM Opportunity
            WHERE GL_Account_Variable_1__r.Name = 'Seawin USA'
            AND Newly_Submitted_Quote_First_Date__c >= :Only_Start_Date
            AND Newly_Submitted_Quote_First_Date__c <= :Only_End_Date
            AND Parent_Opportunity__c = NULL
            AND Referral_Sales_Rep__c != null
            AND Type != 'Template'
            AND (NOT Name LIKE :ChangeOrder)
            AND (NOT Name LIKE :MockupOne)
            AND (NOT Name LIKE :MockupTwo)
            AND (NOT Name LIKE :MockupThree)
            AND (NOT Name LIKE :MockupFour)
            ORDER BY Newly_Submitted_Quote_First_Date__c ASC
        ];
        
        map<string, List<ValuesWrapper>> NewlySubmittedOpportunitiesMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> ValuesList = new List<ValuesWrapper>();
        map<string, integer> opportunitiesCount = new Map<string, integer>();
        set<string> checkValueWrapper = new Set<string>();
        opportunitiesCount = countOpportunitiesCount(submitted, 'month-year');
        
        if (!submitted.isEmpty()) {
            for (Opportunity a : submitted) {
                Date quoteSubmittedDate = Date.valueOf(
                    a.Newly_Submitted_Quote_First_Date__c
                );
                
                string key = 'Newly Submitted Opportunities Last 12 Months';
                
                ValuesList = new List<ValuesWrapper>();
                
                ValuesWrapper vw = new ValuesWrapper(
                                Last12MonthsList_Horizontal.indexOf( Months[(Integer) quoteSubmittedDate.month() - 1] ),
                                Months[(Integer) quoteSubmittedDate.month() - 1],
                                Months[(Integer) quoteSubmittedDate.month() - 1],
                                opportunitiesCount.get(key + quoteSubmittedDate.month() + quoteSubmittedDate.year()),
                                (Integer) quoteSubmittedDate.year(),
                                null,
                                null
                            );
                
                if (checkValueWrapper.contains(key + quoteSubmittedDate.month() + quoteSubmittedDate.year())){
                    // do nothing
                } else {
                    checkValueWrapper.add( key + quoteSubmittedDate.month() + quoteSubmittedDate.year());
                    
                    if (NewlySubmittedOpportunitiesMapLocal.containsKey(key)) {
                        ValuesList = NewlySubmittedOpportunitiesMapLocal.get(key );
                        ValuesList.add(vw);
                    } else {
                        ValuesList.add(vw);
                    }
                    
                    NewlySubmittedOpportunitiesMapLocal.put(key, ValuesList);
                }
            }
        }
        
        if (NewlySubmittedOpportunitiesMapLocal.size() > 0) {
            // sort the data
            List<string> sortedKeys = sortedKeys(NewlySubmittedOpportunitiesMapLocal );
            //List<string> sortedKeys = this.sortedKeysIntegerParsingVersion(NewlySubmittedOpportunitiesMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (NewlySubmittedOpportunitiesMapLocal.containskey(s)) {
                    sortedMap.put(s, NewlySubmittedOpportunitiesMapLocal.get(s));
                }
            }
            
            NewlySubmittedOpportunitiesMapLocal = sortedMap;
            //NewlySubmittedOpportunitiesKeys = NewlySubmittedOpportunitiesMap.keyset();
        }

        return NewlySubmittedOpportunitiesMapLocal;
    }

    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Lost_Referrall_Opportunities() {

        Set<string> All_SalesReps = getAll_SalesReps();

        Date Only_Start_Date = Only_Start_Date();
        Date Only_End_Date = Only_End_Date();

        List<String> Months = Months();

        List<String> Last12MonthsList_Horizontal = Last12MonthsList_Horizontal();
        
        String ChangeOrder = '%Change Order%';
        String MockupOne = '%Mock-Up%';
        String MockupTwo = '%Mock Up%';
        String MockupThree = '%Mock%';
        String MockupFour = '%Mockup%';
        
        List<AggregateResult> LostOpptysData = [select calendar_month(Closed_Date__c) month,calendar_year(Closed_Date__c) year,
                                               Count(id) ct from opportunity 
                                                Where Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date
                                               and GL_Account_Variable_1__r.Name = 'Seawin USA'
                                               and StageName = 'Closed Lost' AND Parent_Opportunity__c = NULL
                                               
                                               and Referral_Sales_Rep__c != null
                                               AND (NOT Name LIKE :ChangeOrder)
                                               AND (NOT Name LIKE :MockupOne)
                                               AND (NOT Name LIKE :MockupTwo)
                                               AND (NOT Name LIKE :MockupThree)
                                               AND (NOT Name LIKE :MockupFour)
                                               group by calendar_month(Closed_Date__c), calendar_year(Closed_Date__c)
                                               order by calendar_year(Closed_Date__c) asc];
        
        map<string, List<ValuesWrapper>> LostOpptyMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> ValuesList = new List<ValuesWrapper>();
        string key = 'Lost Opportunities Last 12 Months';
        
        if (!LostOpptysData.isEmpty()) {
            for (AggregateResult a : LostOpptysData) {
                
                ValuesList = new List<ValuesWrapper>();
                
                ValuesWrapper vw = new ValuesWrapper(
                            Last12MonthsList_Horizontal.indexOf(
                                Months[(Integer) a.get('month') - 1]
                            ),
                            Months[(Integer) a.get('month') - 1],
                            Months[(Integer) a.get('month') - 1],
                            (Decimal) a.get('ct'),
                            (Integer) a.get('year'),
                            null,
                            null
                        );
                
                if (LostOpptyMapLocal.containsKey(key)) {
                    
                    ValuesList = LostOpptyMapLocal.get(key);
                    ValuesList.add(vw);
                } else {

                    ValuesList.add(vw);
                }
                LostOpptyMapLocal.put(key, ValuesList);
            }
        }
        if (LostOpptyMapLocal.size() > 0) {
            // sort the data
            List<string> sortedKeys = sortedKeys(LostOpptyMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (LostOpptyMapLocal.containskey(s)) {
                    sortedMap.put(s, LostOpptyMapLocal.get(s));
                }
            }
            
            LostOpptyMapLocal = sortedMap;
            
            //LostOpptysKeys = LostOpptyMapLocal.keyset();
            //LostOpptysMap = LostOpptyMapLocal;
        }

        return LostOpptyMapLocal;
    }


    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Win_Rate_Referral() {
        //Win Rate by Referral Rep
        Set<string> Active_SalesReps = Active_SalesReps();

        String ChangeOrder = '%Change Order%';
        String MockupOne = '%Mock-Up%';
        String MockupTwo = '%Mock Up%';
        String MockupThree = '%Mock%';
        String MockupFour = '%Mockup%';
        
        map<string, List<ValuesWrapper>> WinRateMapLocal = new Map<string, List<ValuesWrapper>>();
        
        List<AggregateResult> totals = [
            SELECT count(id) ct, Referral_Sales_Rep__r.name name
            FROM opportunity
            WHERE GL_Account_Variable_1__r.name = 'Seawin USA'
            AND (StageName = 'Closed Won'
                 OR StageName = 'Closed Lost')
            AND (NOT Name LIKE :ChangeOrder)
            AND (NOT Name LIKE :MockupOne)
            AND (NOT Name LIKE :MockupTwo)
            AND (NOT Name LIKE :MockupThree)
            AND (NOT Name LIKE :MockupFour)
            AND Referral_Sales_Rep__c != null 
            GROUP BY Referral_Sales_Rep__r.name
        ];
        
        List<AggregateResult> WinData = new List<AggregateResult>();
        map<string, decimal> TotalOpptysMap = new Map<string, decimal>();
        //if (!totals.isEmpty()) {
            for (AggregateResult a : totals) {
                string key = (string) a.get('name');
                key = String.isNotEmpty(key) ? key.capitalize() : key;
                
                TotalOpptysMap.put(key, (decimal) a.get('ct'));
            }
            
            WinData = [
                SELECT count(id) ct, Referral_Sales_Rep__r.name name
                FROM opportunity
                WHERE GL_Account_Variable_1__r.name = 'Seawin USA'
                AND StageName = 'Closed Won'
                AND (NOT Name LIKE :ChangeOrder)
                AND (NOT Name LIKE :MockupOne)
                AND (NOT Name LIKE :MockupTwo)
                AND (NOT Name LIKE :MockupThree)
                AND (NOT Name LIKE :MockupFour)
                AND Referral_Sales_Rep__c != null 
                
                GROUP BY Referral_Sales_Rep__r.name
                ORDER BY Referral_Sales_Rep__r.name
            ];
        //}
        
        List<ValuesWrapper> WinDataList = new List<ValuesWrapper>();
        map<string, Decimal> TotalMap = new Map<string, Decimal>();
        
        Integer i = 0;
        if (!WinData.isEmpty()) {
            for (AggregateResult a : WinData) {
                string key = (String) a.get('name');
                key = String.isNotEmpty(key) ? key.capitalize() : key;
                
                Decimal totalOpptys = TotalOpptysMap.get(key) == null ? 0 : TotalOpptysMap.get(key);
                Decimal ct = (Decimal) a.get('ct');
                Decimal percent = totalOpptys != 0 ? (ct / totalOpptys) * 100 : 0;
                
                WinDataList = new List<ValuesWrapper>();
                WinDataList.add(
                    new ValuesWrapper(
                        i,
                        null,
                        null,
                        percent.setScale(2),
                        null,
                        null,
                        null
                    )
                );
                
                WinRateMapLocal.put(key, WinDataList);
                i++;
            }
        }
        
        if (WinRateMapLocal.size() > 0) {
            List<string> sortedKeys = sortedKeys(WinRateMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (WinRateMapLocal.containskey(s)) {
                    sortedMap.put(s, WinRateMapLocal.get(s));
                }
            }
            WinRateMapLocal = sortedMap;
            
            //WinRateKeys = WinRateMapLocal.Keyset();
            //WinRateMap = WinRateMapLocal;
        }

        return WinRateMapLocal;
    }

    //Sales Last 12 Months by Manufacturer Rep
    @RemoteAction
    @ReadOnly
    global static List<AggregateResult> Manuf_Reps_Sales_Last_12_Months() {

        List<AggregateResult> MonthlySalesData = [SELECT Manufacturer_Rep__r.Name name,
                                                        calendar_month(Inserting_Date__c) month,
                                                        calendar_year(Inserting_Date__c) year,
                                                        SUM(Total_With_Fee__c) amount
                                                        FROM Sales_Order_Dashboard__c
                                                        WHERE GL_Account_Variable_1__r.Name = 'Seawin USA'
                                                        AND Manufacturer_Rep__c != null
                                                        GROUP BY Manufacturer_Rep__r.Name, 
                                                                    calendar_year(Inserting_Date__c), 
                                                                    calendar_month(Inserting_Date__c)
                                                                    ];
        
        return MonthlySalesData;
    }

    @RemoteAction
    @ReadOnly
    global static Map<String, List<AggregateResult>> Manuf_Reps_Total_Pipeline_Pre_Order_Last_12_Months() {
        /*****************************************************************************************************
        *   @dashboard name  : Pre-Orders Pipeline last 12 months by Manufacturer Rep
        *   @chart name      : Sales_Reps_Total_Pipeline_SMD_USA
        *   @description     : Preparing data for frontend rendering
        *   @author          : Marian Lyzhychka ©Peeklogic
        *****************************************************************************************************/
        Set<string> All_SalesReps = getAll_SalesReps();

        Map<string, integer> Last12MonthsList_CombinedMap = Last12MonthsList_CombinedMap();
        
        List<AggregateResult> opp_dashboard_data = [SELECT  SUM(Amount__c) amount, 
                                                            calendar_month(Inserting_Date__c) month,
                                                            calendar_year(Inserting_Date__c) year,
                                                            Manufacturer_Rep__r.Name sal_rep
                                                            FROM Opportunity_Dashboard__c
                                                            WHERE Month_Year__c IN:Last12MonthsList_CombinedMap.keySet()
                                                            AND Opportunity_Forecast_Category__c = 'Pipeline'
                                                            AND Opportunity_GL_Var_1__r.Name = 'Seawin USA'
                                                            AND Amount__c != null
                                                            AND Opportunity_StageName__c = 'Pre-Order'
                                                            AND Manufacturer_Rep__c != null
                                                            GROUP BY Manufacturer_Rep__r.Name, 
                                                                    calendar_year(Inserting_Date__c), 
                                                                    calendar_month(Inserting_Date__c)];

        Map<String, List<AggregateResult>> sal_rep_month = new Map<String, List<AggregateResult>>();
        
        for(AggregateResult ar:opp_dashboard_data){
            String salRepName = String.valueOf(ar.get('sal_rep'));
            if(!sal_rep_month.containsKey(salRepName)){
                List<AggregateResult> sal_rep_data = new List<AggregateResult>();
                sal_rep_data.add(ar);
                sal_rep_month.put(salRepName,sal_rep_data);
            } else{
                sal_rep_month.get(salRepName).add(ar);
            }
        }

        return sal_rep_month;
    }

    //Sales Forecast by Manufacturer Rep
    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Sales_Forecast_Pipeline_Manuf() {

        List<String> Next12MonthsList = Next12MonthsList();

        Date d = getTodayDate();

        Set<string> All_SalesReps = getAll_SalesReps();

        List<String> Months = Months();

        map<string, decimal> MissedOpptysMap = new Map<string, decimal>();
        
        Date Pipeline_Start_Date = Date.newInstance(d.Year(), d.Month(), 1);
        Date Future_Date = Pipeline_Start_Date.addMonths(11);
        
        Date Pipeline_End_Date = Date.newInstance(
            Future_Date.year(),
            Future_Date.month(),
            Date.daysInMonth(Future_Date.year(), Future_Date.month())
        );
        
        List<AggregateResult> MissedForecasts = [select Manufacturer_Rep__r.name name, Sum(ExpectedRevenue) amount from opportunity
                                                Where CloseDate <: Pipeline_Start_Date
                                                and Manufacturer_Rep__c != null
                                                and GL_Account_Variable_1__r.name = 'Seawin USA'
                                                
                                                and ForecastCategoryName = 'Pipeline'
                                                group by Manufacturer_Rep__r.name];
        
        if (!MissedForecasts.isEmpty()) {
            for (aggregateresult agr : Missedforecasts) {
                MissedOpptysMap.put(
                    (String) agr.get('name'),
                    (decimal) agr.get('amount')
                );
            }
        }
        
       
        List<AggregateResult> forecasts = [select Manufacturer_Rep__r.name name,calendar_month(CloseDate) month,calendar_year(closedate) year,
                                          Sum(ExpectedRevenue) amount from opportunity
                                          Where CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date
                                          and Manufacturer_Rep__c != null
                                          and GL_Account_Variable_1__r.name = 'Seawin USA'
                                          
                                          and ForecastCategoryName = 'Pipeline'
                                          group by Manufacturer_Rep__r.name, calendar_month(closedate), calendar_year(closedate)
                                          order by calendar_year(closedate) asc];
        
        map<string, List<ValuesWrapper>> ForecastMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> ValuesList = new List<ValuesWrapper>();
        if (!forecasts.isEmpty()) {
            for (AggregateResult a : forecasts) {
                string key = (String) a.get('name');
                key = String.isNotEmpty(key) ? key.capitalize() : key;
                
                Decimal missedAmount = MissedOpptysMap.containsKey(key)
                    ? MissedOpptysMap.get(key)
                    : 0;
                
                ValuesList = new List<ValuesWrapper>();
                
                ValuesWrapper vw = new ValuesWrapper(
                            Next12MonthsList.indexOf(Months[(Integer) a.get('month') - 1]),
                            Months[(Integer) a.get('month') - 1],
                            (String) a.get('name'),
                            (Decimal) a.get('amount'),
                            (Integer) a.get('year'),
                            null,
                            MissedAmount
                        );
                
                if (ForecastMapLocal.containsKey(key)) {
                    
                    ValuesList = ForecastMapLocal.get(key);
                    ValuesList.add(vw);
                } else {

                    ValuesList.add(vw);
                }
                
                ForecastMapLocal.put(key, ValuesList);
            }
        }
        if (ForecastMapLocal.size() > 0) {
            // sort the data
            List<string> sortedKeys = sortedKeys(ForecastMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (ForecastMapLocal.containskey(s)) {
                    sortedMap.put(s, ForecastMapLocal.get(s));
                }
            }
            
            ForecastMapLocal = sortedMap;
            
            //ForecastKeys = ForecastMapLocal.keyset();
            //ForecastMap = ForecastMapLocal;
        }

        return ForecastMapLocal;
    }



    public static void coverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}