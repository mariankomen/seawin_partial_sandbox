global class SalesDashboardController extends MainSalesDashboardController {
    
    @RemoteAction
    @ReadOnly
    global static Decimal Quota_YTD_Check() {

        User usr = getUser();
   
        decimal quotaAmount = usr.Monthly_Quota__c == null
            ? 0
            : usr.Monthly_Quota__c;
        
        decimal UptoDateQuota = CalculateUptoDateQuota(quotaAmount, null, null);
        
        return UptoDateQuota;  
    }
    @RemoteAction
    @ReadOnly
    global static List<AggregateResult> Quota_YTD() {

        User usr = getUser();
        
        Date d = gettodayDate();
        
        String sdate_str = d.year() + '-01-01T00:00:00.000Z';
        DateTime YearStartDate = DateTime.ValueofGmt(sdate_str.replace('T', ' '));
        
        DateTime YearToDateDate = DateTime.now();
        
        List<AggregateResult> Aggregates = [
            SELECT sum(acctseederp__total__c) sum
            FROM acctseederp__sales_order__c
            WHERE
            CreatedDate >= :YearStartDate
            AND CreatedDate <= :YearToDateDate
            AND ownerId = :usr.id
        ];
        
        return Aggregates;
    }


    /*****************************************************************************************************
    *   @dashboard name  : Sales by Lead Source Last 12 Months
    *   @chart name      : Sales_By_Lead_Source_Last_12_Months
    *   @description     : Preparing data for frontend rendering sales dashboard
    *   @author          : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Sales_By_Lead_Source_Last_12_Months() {
        
        List<String> Last12MonthsList = Last12MonthsList();
        DateTime Full_Start_Date = Full_Start_Date();
        DateTime Full_End_Date = Full_End_Date();
        List<String> Months = Months();

        
        List<AggregateResult> SalesByLeadSourceLastTwelveMonthsData = [select AcctSeedERP__Opportunity__r.Leadsource leadSource,
                                                                      calendar_month(CreatedDate) month,calendar_year(CreatedDate) year,
                                                                      sum(AcctSeederp__total__c) amount
                                                                      from AcctSeederp__sales_order__c
                                                                      where CreatedDate >=:Full_Start_Date and 
                                                                       CreatedDate <=:Full_End_Date
                                                                      and ownerId =:UserInfo.getUserid()
                                                                      and AcctSeederp__total__c > 0
                                                                      group by AcctSeedERP__Opportunity__r.Leadsource ,
                                                                       calendar_month(CreatedDate),calendar_year(CreatedDate)
                                                                      order by AcctSeedERP__Opportunity__r.Leadsource ,
                                                                       calendar_month(CreatedDate),calendar_year(CreatedDate) asc];
        
        map<string, List<ValuesWrapper>> SalesByLeadSourceLastTwelveMonthsMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> SalesByLeadSourceLastTwelveMonthsList = new List<ValuesWrapper>();
        
        if (!SalesByLeadSourceLastTwelveMonthsData.isEmpty()) {
            
            for (AggregateResult so : SalesByLeadSourceLastTwelveMonthsData) {
                
                string key = (string) so.get('leadSource');
                key = String.isNotEmpty(key) ? key.capitalize() : key;
                
                if (SalesByLeadSourceLastTwelveMonthsMapLocal.containskey(key)) {
                    List<ValuesWrapper> exists = SalesByLeadSourceLastTwelveMonthsMapLocal.get(key);
                    
                    exists.add(
                        new ValuesWrapper(
                            Last12MonthsList.indexOf(Months[(Integer) so.get('month') - 1]),
                            Months[(Integer) so.get('month') - 1],
                            Months[(Integer) so.get('month') - 1],
                            (Decimal) so.get('amount'),
                            (Integer) so.get('year'),
                            null,
                            null
                        )
                    );
                    SalesByLeadSourceLastTwelveMonthsMapLocal.put(key, exists);
                } else {
                    SalesByLeadSourceLastTwelveMonthsList = new List<ValuesWrapper>();
                    SalesByLeadSourceLastTwelveMonthsList.add(
                        new ValuesWrapper(
                            Last12MonthsList.indexOf(Months[(Integer) so.get('month') - 1]),
                            Months[(Integer) so.get('month') - 1],
                            Months[(Integer) so.get('month') - 1],
                            (Decimal) so.get('amount'),
                            (Integer) so.get('year'),
                            null,
                            null
                        )
                    );
                    SalesByLeadSourceLastTwelveMonthsMapLocal.put(key, SalesByLeadSourceLastTwelveMonthsList);
                }
            }
        }
        if (SalesByLeadSourceLastTwelveMonthsMapLocal.size() > 0) {
            List<string> sortedKeys = sortedKeys(SalesByLeadSourceLastTwelveMonthsMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (SalesByLeadSourceLastTwelveMonthsMapLocal.containskey(s)) {
                    sortedMap.put(s, SalesByLeadSourceLastTwelveMonthsMapLocal.get(s));
                }
            }
            SalesByLeadSourceLastTwelveMonthsMapLocal = sortedMap;
            
            //SalesByLeadSourceLastTwelveMonthsKeys = SalesByLeadSourceLastTwelveMonthsMapLocal.keyset();
            //SalesByLeadSourceLastTwelveMonthsMap = SalesByLeadSourceLastTwelveMonthsMapLocal;
        }
        
        return SalesByLeadSourceLastTwelveMonthsMapLocal;
    }
    


   
    @RemoteAction
    @ReadOnly
    global static List<AggregateREsult> Monthly_Sales_Last_12_Months() {
        
        List<String> Last12MonthsList = Last12MonthsList();
        DateTime Full_Start_Date = Full_Start_Date();
        DateTime Full_End_Date = Full_End_Date();
        List<String> Months = Months();

        List<AggregateREsult> SalesData = [select sales_rep_o__r.name name,
                                          calendar_month(CreatedDate) month,calendar_year(CreatedDate) year,
                                          sum(AcctSeederp__total__c) c
                                          from AcctSeederp__sales_order__c
                                          where CreatedDate >=:Full_Start_Date and CreatedDate <=:Full_End_Date
                                          and ownerId =:UserInfo.getuserid()
                                          and AcctSeederp__total__c > 0
                                          group by Sales_rep_o__r.name,calendar_month(CreatedDate),
                                          calendar_year(CreatedDate)
                                          order by Sales_rep_o__r.name,calendar_month(CreatedDate),
                                          calendar_year(CreatedDate) asc];
        
        return SalesData;
    }
    
    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Sales_Forecast_Pipeline_By_Lead_Source() {
        
        map<string, decimal> MissedOpptysMap = new Map<string, decimal>();
        
        List<String> Last12MonthsList = Last12MonthsList();
        List<String> Next12MonthsList = Next12MonthsList();
        List<String> Months = Months();
        
        Date d = getTodayDate();
        
        Date Pipeline_Start_Date = Date.newInstance(d.Year(), d.Month(), 1);
        Date Future_Date = Pipeline_Start_Date.addMonths(11);
        
        Date Pipeline_End_Date = Date.newInstance(
            Future_Date.year(),
            Future_Date.month(),
            Date.daysInMonth(Future_Date.year(), Future_Date.month())
        );
        
        List<AggregateResult> MissedForecasts = [select LeadSource leadSource, Sum(ExpectedRevenue) amount from opportunity
                                                Where CloseDate <: Pipeline_Start_Date
                                                and ownerId =:UserInfo.getuserId()
                                                and ForecastCategoryName = 'Pipeline'
                                                group by LeadSource];
        
        if (!MissedForecasts.isEmpty()) {
            for (aggregateresult agr : Missedforecasts) {
                MissedOpptysMap.put(
                    (String) agr.get('leadSource'),
                    (decimal) agr.get('amount')
                );
            }
        }
        
        List<AggregateResult> forecasts = [select LeadSource leadSource,
                                          calendar_month(CloseDate) month,calendar_year(closedate) year,
                                          Sum(ExpectedRevenue) amount from opportunity
                                          Where CloseDate >=: Pipeline_Start_Date and CloseDate <=: Pipeline_End_Date
                                          and ownerId =:UserInfo.getuserid()
                                          and ForecastCategoryName = 'Pipeline'
                                          group by LeadSource, calendar_month(closedate), 
                                           calendar_year(closedate)
                                          order by LeadSource, calendar_month(closedate), 
                                           calendar_year(closedate) asc];
        
        map<string, List<ValuesWrapper>> SalesForecastPipelineByLeadSourceMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> SalesForecastPipelineByLeadSourceList = new List<ValuesWrapper>();
        if (!forecasts.isEmpty()) {
            for (AggregateResult a : forecasts) {
                string key = (String) a.get('leadSource');
                key = String.isNotEmpty(key) ? key.capitalize() : key;
                
                Decimal missedAmount = MissedOpptysMap.containsKey(key)
                    ? MissedOpptysMap.get(key)
                    : 0;
                
                ValuesWrapper vw = new ValuesWrapper(
                            Next12MonthsList.indexOf(Months[(Integer) a.get('month') - 1]),
                            Months[(Integer) a.get('month') - 1],
                            (String) a.get('leadSource'),
                            (Decimal) a.get('amount'),
                            (Integer) a.get('year'),
                            null,
                            MissedAmount
                        );
                
                SalesForecastPipelineByLeadSourceList = new List<ValuesWrapper>();
                
                if (SalesForecastPipelineByLeadSourceMapLocal.containsKey(key)) {
                    SalesForecastPipelineByLeadSourceList = SalesForecastPipelineByLeadSourceMapLocal.get(key);
                    SalesForecastPipelineByLeadSourceList.add(
                        vw
                    );
                } else {
                    SalesForecastPipelineByLeadSourceList.add(
                        vw
                    );
                    
                }
                
                SalesForecastPipelineByLeadSourceMapLocal.put(key, SalesForecastPipelineByLeadSourceList);
            }
        }
        if (SalesForecastPipelineByLeadSourceMapLocal.size() > 0) {
            // sort the data
            List<string> sortedKeys = sortedKeys(SalesForecastPipelineByLeadSourceMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (SalesForecastPipelineByLeadSourceMapLocal.containskey(s)) {
                    sortedMap.put(s, SalesForecastPipelineByLeadSourceMapLocal.get(s));
                }
            }
            
            SalesForecastPipelineByLeadSourceMapLocal = sortedMap;
        }
        
        return SalesForecastPipelineByLeadSourceMapLocal;
    }
    
    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Sales_Forecast_Pipeline() {
        
        Date VeryCurrentDate = getTodayDate();
        Date Only_Start_Date = Only_Start_Date();
        Date Only_End_Date = Only_End_Date();
        
        List<String> Next12MonthsList = Next12MonthsList();
        List<String> Months = Months();
        
        Decimal MissedAmount = 0;
        
        Date TM_Start_Date = Date.newInstance(
            VeryCurrentDate.Year(),
            VeryCurrentDate.Month(),
            1
        );
        Date TM_End_Date = VeryCurrentDate.addMonths(11);
        
        TM_End_Date = Date.newInstance(
        TM_End_Date.year(),
        TM_End_Date.month(),
        Date.daysInMonth(TM_End_Date.year(), TM_End_Date.month())
      );

        
        List<AggregateResult> MissedForecasts = [select Sum(ExpectedRevenue) amount from opportunity
                                                Where CloseDate <: TM_Start_Date and
                                                ForecastCategoryName = 'Pipeline'
                                                and OwnerId =:UserInfo.getUserId()];
        
        if (!MissedForecasts.isEmpty()) {
            MissedAmount = (Decimal) MissedForecasts[0].get('amount');
        }
        
        List<AggregateResult> forecasts = [select calendar_month(CloseDate) month,calendar_year(closedate) year,
                                          ForecastCategoryName forecast, Sum(ExpectedRevenue) amount from opportunity
                                          Where CloseDate >=: TM_Start_Date and CloseDate <=: TM_End_Date and
                                          ForecastCategoryName = 'Pipeline'
                                          and OwnerId =:UserInfo.getUserId()
                                          group by ForecastCategoryName, calendar_year(closedate),
                                          calendar_month(closedate) 
                                          order by ForecastCategoryName, calendar_year(closedate),
                                          calendar_month(closedate) 
                                          asc];
        
        map<string, List<ValuesWrapper>> ForecastMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> ForecastList = new List<ValuesWrapper>();
        if (!forecasts.isEmpty()) {
            for (AggregateResult a : forecasts) {
                string key = (String) a.get('forecast');
                
                ValuesWrapper vw = new ValuesWrapper(
                            Next12MonthsList.indexOf(Months[(Integer) a.get('month') - 1]),
                            Months[(Integer) a.get('month') - 1],
                            (String) a.get('forecast'),
                            (Decimal) a.get('amount'),
                            (Integer) a.get('year'),
                            null,
                            MissedAmount
                        );
                
                ForecastList = new List<ValuesWrapper>();
                
                if (ForecastMapLocal.containsKey(key)) {
                    ForecastList = ForecastMapLocal.get(key);
                    ForecastList.add(
                        vw
                    );
                } else {
                    
                    ForecastList.add(
                        vw
                    );
                }
                
                ForecastMapLocal.put(key, ForecastList);
            }
        }
        
        return ForecastMapLocal;
    }
    
    @RemoteAction
    @ReadOnly
    global static List<AggregateResult> Pipeline_Last_12_Months() {
        /*****************************************************************************************************
        *   @dashboard name  : Company Total Pipeline Last 12 Months
        *   @chart name      : Company_Total_Pipeline_SMD_USA
        *   @description     : Preparing data for frontend rendering
        *   @author          : Marian Lyzhychka ©Peeklogic
        *****************************************************************************************************/

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
            AND Opportunity__r.OwnerId = :UserInfo.getUserId()
            AND Amount__c != null
            
            GROUP BY calendar_year(Inserting_Date__c), calendar_month(Inserting_Date__c)
        ];
        system.debug(JSON.serialize(opportunity_data));
        
        return opportunity_data;

        
        // Map<string, integer> Last12MonthsList_CombinedMap = Last12MonthsList_CombinedMap();
        
        // DateTime Full_End_Date = Full_End_Date();
        
        // Date Only_Start_Date = Only_Start_Date();
        
        // List<AggregateResult> Open = [
        //     SELECT
        //     Sum(amount) amount,
        //     Owner.Name name,
        //     calendar_month(createddate) month,
        //     calendar_year(createddate) year
        //     FROM opportunity
        //     WHERE
        //     createddate <= :Full_End_Date
        //     AND OwnerId = :UserInfo.getUserId()
        //     AND ForecastCategoryName = 'Pipeline'
        //     AND amount > 0
        //     AND amount != NULL
        //     GROUP BY
        //     Owner.Name,
        //     calendar_year(createddate),
        //     calendar_month(createddate)
            
        //     ORDER BY
        //     Owner.Name,
        //     calendar_year(createddate),
        //     calendar_month(createddate) ASC
        // ];
        
        // map<string, List<ValuesWrapper>> UserTotalPipelineMapLocal = new Map<string, List<ValuesWrapper>>();
        // map<string, map<Integer, Decimal>> Open_SalesAmountMap = new Map<string, map<Integer, Decimal>>();
        
        // map<Integer, Decimal> MonthAmountMap = new Map<Integer, Decimal>();
        
        // if (!Open.isEmpty()) {
        //     MonthAmountMap = new Map<Integer, Decimal>();
        //     for (AggregateResult a : Open) {
        //         String key = (String) a.get('name');
        //         key = String.isNotEmpty(key) ? key.capitalize() : key;
                
        //         Integer m = (Integer) a.get('month');
        //         Integer y = (Integer) a.get('year');
        //         Decimal amt = (Decimal) a.get('amount');
                
        //         Date dt = Date.newInstance(y, m, 1);
                
        //         Integer MonthIndex = dt >= Only_Start_Date
        //             ? Last12MonthsList_CombinedMap.get(m + '-' + y)
        //             : 0;
                
        //         if (Open_SalesAmountMap.containsKey(key)) {
        //             map<integer, Decimal> maps = Open_SalesAmountMap.get(key);
                    
        //             maps.put(
        //                 MonthIndex,
        //                 MonthAmountMap.containsKey(MonthIndex)
        //                 ? MonthAmountMap.get(MonthIndex) + amt
        //                 : amt
        //             );
        //             Open_SalesAmountMap.put(key, maps);
        //         } else {
        //             MonthAmountMap = new Map<Integer, Decimal>();
                    
        //             MonthAmountMap.put(
        //                 MonthIndex,
        //                 MonthAmountMap.containsKey(MonthIndex)
        //                 ? MonthAmountMap.get(MonthIndex) + amt
        //                 : amt
        //             );
                    
        //             Open_SalesAmountMap.put(key, MonthAmountMap);
        //         }
        //     }
        // }
        
        // Set<string> UserKeys = new Set<string>(Open_SalesAmountMap.Keyset());
        
        // for (String key : UserKeys) {
        //     map<Integer, Decimal> UserMap_Open = Open_SalesAmountMap.get(key);
            
        //     List<ValuesWrapper> ValuesList = new List<ValuesWrapper>();
            
        //     Decimal TotalAmount = 0;
        //     Decimal PipelineAmount = 0;
            
        //     for (Integer i = 0; i < 12; i++) {
        //         if (UserMap_Open != null) {
        //             if (UserMap_Open.containsKey(i)) {
        //                 PipelineAmount += UserMap_Open.get(i) == null
        //                     ? 0
        //                     : UserMap_Open.get(i);
        //             }
        //         }

                
        //         TotalAmount = PipelineAmount;
                
        //         if (TotalAmount > 0){
        //             ValuesList.add(new ValuesWrapper(i, null, null, TotalAmount, 0, null, 0.0));
        //         }
        //     }
            
        //     UserTotalPipelineMapLocal.put(key, ValuesList);
        // }
        
        // return UserTotalPipelineMapLocal;
        
        
    }
    
    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Newly_Submitted_Opportunities() {
        
        List<String> Last12MonthsList_Horizontal = Last12MonthsList_Horizontal();
        Date Only_Start_Date = Only_Start_Date();
        Date Only_End_Date = Only_End_Date();
        
        List<String> Months = Months();
        
        String ChangeOrder = '%Change Order%';
        String MockupOne = '%Mock-Up%';
        String MockupTwo = '%Mock Up%';
        String MockupThree = '%Mock%';
        String MockupFour = '%Mockup%';
        
        
        List<Opportunity> submitted = [
            SELECT Id, Newly_Submitted_Quote_First_Date__c, owner.name, 
            (Select Status From Quotes Order By CreatedDate Asc Limit 1) From Opportunity 
            WHERE ownerId = :UserInfo.getUserId()  
            AND Newly_Submitted_Quote_First_Date__c >= :Only_Start_Date
            AND Newly_Submitted_Quote_First_Date__c <= :Only_End_Date
            AND Parent_Opportunity__c = NULL
            AND (ForecastCategoryName = 'Pipeline' OR StageName = 'Sleep' OR StageName = 'Closed Won' OR StageName = 'Closed Lost')
            AND (NOT Name LIKE :ChangeOrder)
            AND (NOT Name LIKE :MockupOne)
            AND (NOT Name LIKE :MockupTwo)
            AND (NOT Name LIKE :MockupThree)
            AND (NOT Name LIKE :MockupFour)
            order by Newly_Submitted_Quote_First_Date__c asc
        ];
        
        map<string, List<ValuesWrapper>> NewlySubmittedOpportunitiesMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> SubmittedList = new List<ValuesWrapper>();
        map<string, Integer> UniqueMap = new Map<string, Integer>();
        map<string, integer> opportunitiesCount = new map<string, integer>();
        set<string> checkValueWrapper = new set<string>();
        opportunitiesCount = countOpportunitiesCount(submitted, 'month-year');
        
        if (!submitted.isEmpty()) {
            
            for (Opportunity a : submitted) {
                
                Date quoteSubmittedDate = Date.valueOf(a.Newly_Submitted_Quote_First_Date__c);
                
                string key = 'Newly Submitted Opportunities Last 12 Months';
                
                ValuesWrapper vw = new ValuesWrapper(
                                Last12MonthsList_Horizontal.indexOf( Months[(Integer) quoteSubmittedDate.month() - 1] ),
                                Months[(Integer) quoteSubmittedDate.month() - 1],
                                Months[(Integer) quoteSubmittedDate.month() - 1],
                                (Decimal) opportunitiesCount.get(key+quoteSubmittedDate.month()+quoteSubmittedDate.year()),
                                (Integer) quoteSubmittedDate.year(),
                                null,
                                null
                            );
                
                SubmittedList = new List<ValuesWrapper>();
                
                if(checkValueWrapper.contains(key+quoteSubmittedDate.month()+quoteSubmittedDate.year())){
                    // do nothing
                }
                else{
                    
                    checkValueWrapper.add(key+quoteSubmittedDate.month()+quoteSubmittedDate.year());
                    
                    if (NewlySubmittedOpportunitiesMapLocal.containsKey(key)) {
                        
                        SubmittedList = NewlySubmittedOpportunitiesMapLocal.get(key);
                        SubmittedList.add(
                            vw
                        );
                    } else {

                        SubmittedList.add(
                            vw
                        );
                        
                    }
                    
                    NewlySubmittedOpportunitiesMapLocal.put(key, SubmittedList);
                }
            }
        }
        
        if (NewlySubmittedOpportunitiesMapLocal.size() > 0) {
            // sort the data
            List<string> sortedKeys = sortedKeys(NewlySubmittedOpportunitiesMapLocal);
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
    global static map<string, List<ValuesWrapper>> Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source() {
        
        List<String> Last12MonthsList_Horizontal = Last12MonthsList_Horizontal();
        Date Only_Start_Date = Only_Start_Date();
        Date Only_End_Date = Only_End_Date();
        List<String> Months = Months();
        
        String ChangeOrder = '%Change Order%';
        String MockupOne = '%Mock-Up%';
        String MockupTwo = '%Mock Up%';
        String MockupThree = '%Mock%';
        String MockupFour = '%Mockup%';
        
        List<Opportunity> submitted = [
            SELECT Id, Newly_Submitted_Quote_First_Date__c, LeadSource, owner.name, 
            (Select Status From Quotes Order By CreatedDate Asc Limit 1) From Opportunity 
            WHERE ownerId = :UserInfo.getUserId() 
            AND Newly_Submitted_Quote_First_Date__c >= :Only_Start_Date
            AND Newly_Submitted_Quote_First_Date__c <= :Only_End_Date
            AND Parent_Opportunity__c = NULL
            AND (ForecastCategoryName = 'Pipeline'
                 OR StageName = 'Sleep'
                 OR StageName = 'Closed Won'
                 OR StageName = 'Closed Lost')
            AND (NOT Name LIKE :ChangeOrder)
            AND (NOT Name LIKE :MockupOne)
            AND (NOT Name LIKE :MockupTwo)
            AND (NOT Name LIKE :MockupThree)
            AND (NOT Name LIKE :MockupFour)
            order by LeadSource, Newly_Submitted_Quote_First_Date__c asc
        ];
        
        map<string, List<ValuesWrapper>> newlySubmittedOpportunitiesLastTwelveMonthsByLeadSourceMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> SubmittedList = new List<ValuesWrapper>();
        map<string, Integer> UniqueMap = new Map<string, Integer>();
        map<string, integer> opportunitiesCount = new map<string, integer>();
        set<string> checkValueWrapper = new set<string>();
        opportunitiesCount = countOpportunitiesCount(submitted, 'leadSource');
        
        if (!submitted.isEmpty()) {
            
            for (Opportunity a : submitted) {
                
                string key = (String) a.LeadSource;
                key = String.isNotEmpty(key) ? key.capitalize() : key;
                
                Date quoteSubmittedDate = Date.valueOf(a.Newly_Submitted_Quote_First_Date__c);
                
                ValuesWrapper vw = new ValuesWrapper(
                                Last12MonthsList_Horizontal.indexOf( Months[(Integer) quoteSubmittedDate.month() - 1] ),
                                Months[(Integer) quoteSubmittedDate.month() - 1],
                                Months[(Integer) quoteSubmittedDate.month() - 1],
                                opportunitiesCount.get(key+quoteSubmittedDate.month()+quoteSubmittedDate.year()),
                                (Integer) quoteSubmittedDate.year(),
                                null,
                                null
                            );
                
                SubmittedList = new List<ValuesWrapper>();
                
                if(checkValueWrapper.contains(key+quoteSubmittedDate.month()+quoteSubmittedDate.year())){
                    // do nothing
                }
                else{
                    
                    checkValueWrapper.add(key+quoteSubmittedDate.month()+quoteSubmittedDate.year());
                    
                    if (newlySubmittedOpportunitiesLastTwelveMonthsByLeadSourceMapLocal.containsKey(key)) {
                        
                        SubmittedList = newlySubmittedOpportunitiesLastTwelveMonthsByLeadSourceMapLocal.get(key);
                        SubmittedList.add(
                            vw
                        );
  
                    } else {

                        SubmittedList.add(
                            vw
                        );
                    }
                    
                    newlySubmittedOpportunitiesLastTwelveMonthsByLeadSourceMapLocal.put(key, SubmittedList);
                }
            }
        }
        
        if (newlySubmittedOpportunitiesLastTwelveMonthsByLeadSourceMapLocal.size() > 0) {
            
            // sort data
            List<string> sortedKeys = sortedKeys(newlySubmittedOpportunitiesLastTwelveMonthsByLeadSourceMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (newlySubmittedOpportunitiesLastTwelveMonthsByLeadSourceMapLocal.containskey(s)) {
                    sortedMap.put(s, newlySubmittedOpportunitiesLastTwelveMonthsByLeadSourceMapLocal.get(s));
                }
            }
            
            newlySubmittedOpportunitiesLastTwelveMonthsByLeadSourceMapLocal = sortedMap;
            //newlySubmittedOpportunitiesLastTwelveMonthsByLeadSourceKeys = newlySubmittedOpportunitiesLastTwelveMonthsByLeadSourceMap.keyset();
        }
        
        return newlySubmittedOpportunitiesLastTwelveMonthsByLeadSourceMapLocal;
    }
    
    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Lost_Opportunities() {
        
        List<String> Last12MonthsList_Horizontal = Last12MonthsList_Horizontal();
        Date Only_Start_Date = Only_Start_Date();
        Date Only_End_Date = Only_End_Date();
        List<String> Months = Months();
        Id LoggedInUserId = LoggedInUserId();
        
        String ChangeOrder = '%Change Order%';
        String MockupOne = '%Mock-Up%';
        String MockupTwo = '%Mock Up%';
        String MockupThree = '%Mock%';
        String MockupFour = '%Mockup%';

        List<AggregateResult> LostOpptysData = [Select calendar_month(Closed_Date__c) month,
                                                calendar_year(Closed_Date__c) year,
                                               Count(id) ct from opportunity
                                               Where Closed_Date__c >=: Only_Start_Date and 
                                                Closed_Date__c <=: Only_End_Date
                                               and ownerId =:LoggedInUserId
                                               and StageName = 'Closed Lost'
                                               AND Parent_Opportunity__c = NULL
                                               AND (NOT Name LIKE :ChangeOrder)
                                               AND (NOT Name LIKE :MockupOne)
                                               AND (NOT Name LIKE :MockupTwo)
                                               AND (NOT Name LIKE :MockupThree)
                                               AND (NOT Name LIKE :MockupFour)
                                               group by calendar_year(Closed_Date__c),
                                               calendar_month(Closed_Date__c) 
                                               order by calendar_year(Closed_Date__c),
                                               calendar_month(Closed_Date__c) 
                                               asc];
        
        map<string, List<ValuesWrapper>> LostOpptyMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> LostOpptyList = new List<ValuesWrapper>();
        string key = 'Lost Opportunities Last 12 Months';
        
        if (!LostOpptysData.isEmpty()) {
            
            for (AggregateResult a : LostOpptysData) {
                
                ValuesWrapper vw = new ValuesWrapper(
                            Last12MonthsList_Horizontal.indexOf( Months[(Integer) a.get('month') - 1] ),
                            Months[(Integer) a.get('month') - 1],
                            Months[(Integer) a.get('month') - 1],
                            (Decimal) a.get('ct'),
                            (Integer) a.get('year'),
                            null,
                            null
                        );
                
                LostOpptyList = new List<ValuesWrapper>();
                
                if (LostOpptyMapLocal.containsKey(key)) {
                    LostOpptyList = LostOpptyMapLocal.get(key);
                    LostOpptyList.add(
                        vw
                    );
                } else {
                    
                    LostOpptyList.add(
                        vw
                    );
                }
                
                LostOpptyMapLocal.put(key, LostOpptyList);
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
    global static map<string, List<ValuesWrapper>> Loss_Reasons() {
        
        List<String> Last12MonthsList_Horizontal = Last12MonthsList_Horizontal();
        Date Only_Start_Date = Only_Start_Date();
        Date Only_End_Date = Only_End_Date();
        List<String> Months = Months();
        Id LoggedInUserId = LoggedInUserId();
        
        String ChangeOrder = '%Change Order%';
        String MockupOne = '%Mock-Up%';
        String MockupTwo = '%Mock Up%';
        String MockupThree = '%Mock%';
        String MockupFour = '%Mockup%';

        List<AggregateResult> LossReasonsData = [Select Loss_Reason__c name, 
                                                calendar_month(Closed_Date__c) month,
                                                calendar_year(Closed_Date__c) year,
                                               Count(id) ct from opportunity
                                               Where Closed_Date__c >=: Only_Start_Date and 
                                                Closed_Date__c <=: Only_End_Date
                                               and ownerId =:LoggedInUserId
                                               and StageName = 'Closed Lost'
                                               AND Parent_Opportunity__c = NULL
                                               AND (NOT Name LIKE :ChangeOrder)
                                               AND (NOT Name LIKE :MockupOne)
                                               AND (NOT Name LIKE :MockupTwo)
                                               AND (NOT Name LIKE :MockupThree)
                                               AND (NOT Name LIKE :MockupFour)
                                               group by Loss_Reason__c, 
                                                calendar_year(Closed_Date__c),
                                               calendar_month(Closed_Date__c) 
                                               order by Loss_Reason__c, calendar_year(Closed_Date__c),
                                               calendar_month(Closed_Date__c) 
                                               asc];
        
        map<string, List<ValuesWrapper>> LossReasonMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> LossReasonList = new List<ValuesWrapper>();
        if (!LossReasonsData.isEmpty()) {
            for (AggregateResult a : LossReasonsData) {

                String key = a.get('name') != null && 
                (String)a.get('name') != 'NA' && (String)a.get('name') != 'N/A' ? 
                (String) a.get('name') : 'N/A';
                key = String.isNotEmpty(key) && key != 'N/A' ? key.capitalize() : key;
                
                ValuesWrapper vw = new ValuesWrapper(
                            Last12MonthsList_Horizontal.indexOf( Months[(Integer) a.get('month') - 1] ),
                            Months[(Integer) a.get('month') - 1],
                            (String) a.get('name'),
                            (Decimal) a.get('ct'),
                            (Integer) a.get('year'),
                            null,
                            null
                        );
                
                LossReasonList = new List<ValuesWrapper>();
                
                if (LossReasonMapLocal.containsKey(key)) {
                    LossReasonList = LossReasonMapLocal.get(key);
                    LossReasonList.add(
                        vw
                    );
                } else {
                    LossReasonList.add(
                        vw
                    );
                }
                
                LossReasonMapLocal.put(key, LossReasonList);
            }
        }
        if (LossReasonMapLocal.size() > 0) {
            // sort the data
            List<string> sortedKeys = sortedKeys(LossReasonMapLocal);
            map<string, List<ValuesWrapper>> sortedMap = new Map<string, List<ValuesWrapper>>();
            
            for (string s : sortedKeys) {
                if (LossReasonMapLocal.containskey(s)) {
                    sortedMap.put(s, LossReasonMapLocal.get(s));
                }
            }
            
            LossReasonMapLocal = sortedMap;
            
            //LossReasonsKeys = LossReasonMapLocal.keyset();
            //LossReasonsMap = LossReasonMapLocal;
        }
        
        return LossReasonMapLocal;
    }
    
    @RemoteAction
    @ReadOnly
    global static map<string, List<ValuesWrapper>> Your_WinRate() {
        
        User usr = getUser();
        
        Decimal Win_Percentage = 0;
        Decimal Neg_Percentage = 0;
        
        string recordtypename = usr.Default_GL_Account_Variable__c == 'Seawin USA'
            ? 'Seawin USA Hospitality'
            : 'Seawin China Hospitality';
        
        String ChangeOrder = '%Change Order%';
        String MockupOne = '%Mock-Up%';
        String MockupTwo = '%Mock Up%';
        String MockupThree = '%Mock%';
        String MockupFour = '%Mockup%';
        
        // get records from opportunity history which were at negotiation stage
        
        set<id> HistoryIds = new Set<id>();
        
        for (OpportunityHistory hstry : [
            SELECT Id, OpportunityId, CreatedDate, StageName, Amount, CloseDate
            FROM OpportunityHistory
            WHERE
            StageName = 'Negotiation'
            AND Opportunity.RecordType.name = :recordtypename
            AND Opportunity.ownerid = :UserInfo.getUserId()
        ]) {
            HistoryIds.add(hstry.OpportunityId);
        }
        if (Test.isRunningTest()) {
            map<id, opportunity> testMap = new Map<id, opportunity>(
                [
                    SELECT id
                    FROM opportunity
                    WHERE
                    ownerid = :UserInfo.getUserId()
                    AND (StageName = 'Closed Won'
                         OR StageName = 'Closed Lost')
                ]
            );
            
            HistoryIds.AddAll(testMap.keyset());
        }
        
        if (HistoryIds.size() > 0) {
            List<AggregateResult> Neg_totals = [
                SELECT count(id) ct
                FROM opportunity
                WHERE
                id IN :HistoryIds
                AND ownerid = :UserInfo.getUserId()
                AND RecordType.Name = :recordtypename
                AND (StageName = 'Closed Won'
                     OR StageName = 'Closed Lost')
                AND (NOT Name LIKE :ChangeOrder)
                AND (NOT Name LIKE :MockupOne)
                AND (NOT Name LIKE :MockupTwo)
                AND (NOT Name LIKE :MockupThree)
                AND (NOT Name LIKE :MockupFour)
            ];
            
            List<AggregateResult> NegWinData = new List<AggregateResult>();
            
            if (!Neg_totals.isEmpty()) {
                NegWinData = [
                    SELECT count(id) ct
                    FROM opportunity
                    WHERE
                    id IN :HistoryIds
                    AND ownerid = :UserInfo.getUserId()
                    AND RecordType.Name = :recordtypename
                    AND StageName = 'Closed Won'
                    AND (NOT Name LIKE :ChangeOrder)
                    AND (NOT Name LIKE :MockupOne)
                    AND (NOT Name LIKE :MockupTwo)
                    AND (NOT Name LIKE :MockupThree)
                    AND (NOT Name LIKE :MockupFour)
                ];
            }
            
            if (!NegWinData.isEmpty()) {
                Neg_Percentage = (Decimal) Neg_totals[0].get('ct') > 0
                    ? ((Decimal) NegWinData[0].get('ct') /
                       (Decimal) Neg_totals[0].get('ct')) * 100
                    : 0;
                Neg_Percentage = Neg_Percentage.setScale(2);
            }
        }
        
        // Win Rate
        
        /* ----------------- This Month Data ------------------------- */
        List<AggregateResult> win_totals = [
            SELECT count(id) ct
            FROM opportunity
            WHERE
            (StageName = 'Closed Won'
             OR StageName = 'Closed Lost')
            AND RecordType.name = :recordtypename
            AND OwnerId = :UserInfo.getUserId()
            AND (NOT Name LIKE :ChangeOrder)
            AND (NOT Name LIKE :MockupOne)
            AND (NOT Name LIKE :MockupTwo)
            AND (NOT Name LIKE :MockupThree)
            AND (NOT Name LIKE :MockupFour)
        ];
        
        List<AggregateResult> WinData = new List<AggregateResult>();
        
        if (!win_totals.isEmpty()) {
            WinData = [
                SELECT count(id) ct
                FROM opportunity
                WHERE
                StageName = 'Closed Won'
                AND OwnerId = :UserInfo.getUserId()
                AND RecordType.name = :recordtypename
                AND (NOT Name LIKE :ChangeOrder)
                AND (NOT Name LIKE :MockupOne)
                AND (NOT Name LIKE :MockupTwo)
                AND (NOT Name LIKE :MockupThree)
                AND (NOT Name LIKE :MockupFour)
            ];
        }
        
        if (!WinData.isEmpty()) {
            Win_percentage = (Decimal) win_totals[0].get('ct') > 0
                ? ((Decimal) WinData[0].get('ct') / (Decimal) win_totals[0].get('ct')) *
                100
                : 0;
            Win_percentage = Win_percentage.setScale(2);
        }
        // construct the map
        ValuesWrapper neg = new ValuesWrapper(
            0,
            null,
            null,
            neg_percentage,
            null,
            null,
            0
        );
        ValuesWrapper win = new ValuesWrapper(
            1,
            null,
            null,
            win_percentage,
            null,
            null,
            0
        );
        
        map<string, List<ValuesWrapper>> YourWinRateMap = new map<string, List<ValuesWrapper>>();
        
        YourWinRateMap.put('Negotiation', new List<ValuesWrapper>{ neg });
        YourWinRateMap.put('Over All', new List<ValuesWrapper>{ win });
        
		return YourWinRateMap;
    }
    
    @RemoteAction
    @ReadOnly
    global static List<Opportunity_Dashboard__c> Neglected_Opportunities() {
        /*****************************************************************************************************
        *   @dashboard name  : Neglected Opportunities
        *   @chart name      : Neglected_Opportunities
        *   @description     : Preparing data for frontend rendering of dashboard
        *   @author          : Marian Lyzhychka ©Peeklogic
        *****************************************************************************************************/
        Map<string, integer> Last12MonthsList_CombinedMap = Last12MonthsList_CombinedMap();
        String year_month = system.today().month() + '-' + system.today().year();

        List<Opportunity_Dashboard__c> all_neglected = [SELECT Id,
                                                                isNeglected__c,
                                                                Opportunity_Neglected_Days__c 
                                                                FROM Opportunity_Dashboard__c
                                                                WHERE Opportunity_Forecast_Category__c = 'Pipeline'
                                                                AND isNeglected__c = true
                                                                AND opportunity__r.ownerId = :UserInfo.getuserid()
                                                                AND Month_Year__c =:year_month];
        system.debug('all_neglected: '+JSON.serialize(all_neglected));
        return all_neglected.size() > 0 ? all_neglected : new List<Opportunity_Dashboard__c>();
        
    } 
    
    @RemoteAction
    @ReadOnly
    global static List<AggregateResult> Active_Opportunities_By_Stage() {
        /*****************************************************************************************************
        *   @dashboard name  : Active Opportunities by Stage
        *   @chart name      : Active_Opportunities_By_Stage
        *   @description     : Preparing data for frontend rendering of dashboard
        *   @author          : Marian Lyzhychka ©Peeklogic
        *****************************************************************************************************/

        User usr = getUser();
        
        string recordtypename = usr.Default_GL_Account_Variable__c == 'Seawin USA' ? 'Seawin USA Hospitality' : 'Seawin China Hospitality';

        String year_month = system.today().month() + '-' + system.today().year();

        Map<string, integer> Last12MonthsList_CombinedMap = Last12MonthsList_CombinedMap();
        
        List<AggregateResult> opportunities_with_activity = [SELECT SUM(Amount__c) amount, 
                                                                    Opportunity_StageName__c stage
                                                                    FROM Opportunity_Dashboard__c
                                                                    WHERE Opportunity_Forecast_Category__c = 'Pipeline'
                                                                    AND Opportunity__r.ownerId =:UserInfo.getUserId()
                                                                    AND Month_Year__c =:year_month
                                                                    AND Amount__c != NULL
                                                                    
                                                                    GROUP BY Opportunity_StageName__c];
        return opportunities_with_activity;
    }
    
    @RemoteAction
    @ReadOnly
    global static map<string, List<MainWrapper>> Tasks_Completion() {
        
        List<AggregateResult> aggregates = [
            SELECT count(id) ct, ActivityDate dt
            FROM task
            WHERE
            (ActivityDate < :Date.today()
             OR ActivityDate > :Date.today()
             OR ActivityDate = NULL)
            AND status = 'Open'
            AND ownerId = :userinfo.getUserId()
            GROUP BY ActivityDate
        ];

        List<AggregateResult> totalTasksAgr = [
            SELECT count(id) ct
            FROM task
            WHERE
            status = 'Open'
            AND ownerId = :userinfo.getUserId()
        ];
        
        Integer totalTasks = (Integer)totalTasksAgr[0].get('ct');
        
        List<MainWrapper> TasksCompletionData = new List<MainWrapper>();
        
        map<string, List<ValuesWrapperSD>> taskMap = new Map<string, List<ValuesWrapperSD>>();
        List<ValuesWrapperSD> TaskDataList = new List<ValuesWrapperSD>();
        
        if (!aggregates.isEmpty()) {
            for (AggregateResult a : aggregates) {
                // find the index to place it right in the graph
                // Over Due, On Time, No Due Date
                Date dt = (Date) a.get('dt');
                
                String index = (dt == null)
                    ? 'No Due Date'
                    : (dt < Date.today()) ? 'Over Due' : 'On Time';

                    TaskDataList = new List<ValuesWrapperSD>();
                
                if ((Decimal) a.get('ct') != 0) {

                    ValuesWrapperSD vwd = new ValuesWrapperSD(
                            null,
                            null,
                            index,
                            (Decimal) a.get('ct'),
                            null,
                            null
                        );
                    
                    if(taskMap.containsKey(index)){

                        TaskDataList = taskMap.get(index);

                        for(ValuesWrapperSD vw : TaskDataList){

                            vw.amount += (Decimal) a.get('ct');
                        }
                    }else{
                        TaskDataList.add(vwd);
                    }
                    taskMap.put(index, TaskDataList);
                }
            }
            
            for (string key : taskMap.keyset()) {
                MainWrapper m = new MainWrapper(null, taskMap.get(key), totalTasks);
                
                TasksCompletionData.add(m);
            }
        }
        
        map<string, List<MainWrapper>> TempMap = new map<string, List<MainWrapper>>();
            TempMap.put('taskcompletiondata', TasksCompletionData);
        
        return TempMap;
    }



    //NEW GRAPHS

    @RemoteAction
    @ReadOnly
    global static List<AggregateResult> Company_Total_Pre_Order_Pipeline_Last_12_Months_Sales() {
        /*****************************************************************************************************
        *   @dashboard name  : Company Total Pipeline Last 12 Months
        *   @chart name      : Company_Total_Pipeline_SMD_USA
        *   @description     : Preparing data for frontend rendering
        *   @author          : Marian Lyzhychka ©Peeklogic
        *****************************************************************************************************/

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
            AND Opportunity_StageName__c = 'Pre-Order'
            AND Opportunity_GL_Var_1__r.Name = 'Seawin USA'
            AND Amount__c != null
            AND Opportunity__r.ownerId =:UserInfo.getUserId()       
            GROUP BY calendar_year(Inserting_Date__c), calendar_month(Inserting_Date__c)
        ];
        system.debug(JSON.serialize(opportunity_data));
        
        return opportunity_data;
    }

    @RemoteAction
    @ReadOnly
    global static List<AggregateResult> Company_Total_Negotiation_Pipeline_Last_12_Months() {
        /*****************************************************************************************************
        *   @dashboard name  : Negotiation Pipeline Last 12 Months
        *   @chart name      : Company_Total_Pipeline_SMD_USA
        *   @description     : Preparing data for frontend rendering
        *   @author          : Marian Lyzhychka ©Peeklogic
        *****************************************************************************************************/

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
            AND Opportunity_StageName__c = 'Negotiation'
            AND Opportunity_GL_Var_1__r.Name = 'Seawin USA'
            AND Amount__c != null
            AND Opportunity__r.ownerId =:UserInfo.getUserId()       
            GROUP BY calendar_year(Inserting_Date__c), calendar_month(Inserting_Date__c)
        ];
        system.debug(JSON.serialize(opportunity_data));
        
        return opportunity_data;
    }

    public SalesDashboardController() {

    }
}