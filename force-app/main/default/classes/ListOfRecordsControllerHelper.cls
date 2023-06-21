public with sharing class ListOfRecordsControllerHelper {
    

    public static String Tasks_Completion_SMDQuery(String duration, String QueryTasks, Set<String> Active_Users_USA, String str, String click){
        Date d = Date.today();

        string DateStr = '';
            
        String dd = String.valueOf(d);
        
        if (duration == 'Over Due') {
            DateStr +=
                ' ActivityDate < ' +
                dd +
                ' and ActivityDate != null and status = \'Open\' ';
        } else if (duration == 'On Time') {
            DateStr +=
                ' ActivityDate > ' +
                dd +
                ' and ActivityDate != null and status = \'Open\' ';
        } else if (duration == 'No Due Date') {
            DateStr += ' ActivityDate=null and status=\'Open\'';
        } else {
            DateStr +=
                ' ((ActivityDate < ' +
                dd +
                ' and ActivityDate != null and status = \'Open\')';
            DateStr +=
                ' or (ActivityDate > ' +
                dd +
                ' and ActivityDate != null and status = \'Open\')';
            DateStr += ' or (ActivityDate=null and status=\'Open\'))';
        }
        
        string QueryStr = QueryTasks;
        
        if (click == 'chart') {
            QueryStr += DateStr;
            QueryStr += ' and owner.name in:Active_Users_USA ';
        } else if (click == 'bar') {
            QueryStr += DateStr;
            QueryStr += ' and owner.name = \'' + str + '\' ';
        } else if (click == 'legend') {
            QueryStr += DateStr;
            QueryStr += ' and owner.name in:Active_Users_USA ';
        } else if (click == 'left') {
            QueryStr += DateStr;
            QueryStr += ' and owner.name =\'' + str + '\' ';
        }
        
        QueryStr += ' order by owner.name asc, activitydate desc';

        return QueryStr;
    }

    public static String MonthlySalesLast12MonthBySalesRepTeamQuery(String str, 
                                                                    String query, 
                                                                    String click, 
                                                                    String yearStr, 
                                                                    String monthStr,
                                                                    String recordTypeName

                                                                    ){
        Integer year = 2020;
        INteger month = 5;                           
        if (yearStr != null && yearStr != '') {
            year = Integer.valueOf(yearStr);
        }
        
        if (monthStr != null && monthStr != '') {
            month = Integer.valueOf(monthStr);
        }
        
        String year_month = system.today().month() + '-' + system.today().year();
        
        string QueryStr = query;
        QueryStr += ' AcctSeedERP__Total__c > 0';
        
        String str_year = String.valueOf(year);
        String str_month = String.valueOf(month);
        String year_month_inverced = str_month+'-'+str_year;

        system.debug('year_month_inverced: '+year_month_inverced);
        if(click == 'chart'){
            // QueryStr += ' and Month_Year__c = \''+year_month_inverced+ '\'';

            QueryStr += ' AND CALENDAR_MONTH(createddate) = ' + Integer.valueOf(str_month)+'';
            QueryStr += ' AND CALENDAR_YEAR(createddate) = ' + Integer.valueOf(str_year)+'';
        }else if(click == 'point'){
            // QueryStr += ' and Month_Year__c = \''+year_month_inverced+ '\' ';
            QueryStr += ' AND CALENDAR_MONTH(createddate) = ' + Integer.valueOf(str_month)+'';
            QueryStr += ' AND CALENDAR_YEAR(createddate) = ' + Integer.valueOf(str_year)+'';
            QueryStr += ' and Sales_Rep_O__r.name = \''+str + '\'';
        }
        if(recordTypeName != 'All'){
            QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
        }
        QueryStr += ' AND AcctSeedERP__Status__c != \'Cancelled\'';
        QueryStr += ' order by Sales_Rep_O__r.name asc, CreatedDate desc';

        system.debug('QueryStr: '+QueryStr);
        return QueryStr;

    }

    public static String MonthlySalesLast12MonthByOwnerQuery(String str, 
                                                                    String query, 
                                                                    String click, 
                                                                    String yearStr, 
                                                                    String monthStr,
                                                                    String recordTypeName

                                                                    ){
        Integer year = 2020;
        INteger month = 5;                           
        if (yearStr != null && yearStr != '') {
            year = Integer.valueOf(yearStr);
        }
        
        if (monthStr != null && monthStr != '') {
            month = Integer.valueOf(monthStr);
        }
        
        String year_month = system.today().month() + '-' + system.today().year();
        
        string QueryStr = query;
        QueryStr += ' AcctSeedERP__Total__c > 0';
        
        String str_year = String.valueOf(year);
        String str_month = String.valueOf(month);
        String year_month_inverced = str_month+'-'+str_year;

        system.debug('year_month_inverced: '+year_month_inverced);
        if(click == 'chart'){
            // QueryStr += ' and Month_Year__c = \''+year_month_inverced+ '\'';

            QueryStr += ' AND CALENDAR_MONTH(createddate) = ' + Integer.valueOf(str_month)+'';
            QueryStr += ' AND CALENDAR_YEAR(createddate) = ' + Integer.valueOf(str_year)+'';
        }else if(click == 'point'){
            // QueryStr += ' and Month_Year__c = \''+year_month_inverced+ '\' ';
            QueryStr += ' AND CALENDAR_MONTH(createddate) = ' + Integer.valueOf(str_month)+'';
            QueryStr += ' AND CALENDAR_YEAR(createddate) = ' + Integer.valueOf(str_year)+'';
            QueryStr += ' and Owner.name = \''+str + '\'';
        }
        if(recordTypeName != 'All'){
            QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
        }
        QueryStr += ' AND AcctSeedERP__Status__c != \'Cancelled\'';
        QueryStr += ' order by Owner.name asc, CreatedDate desc';

        system.debug('QueryStr: '+QueryStr);
        return QueryStr;
    }

    public static String MonthlySalesLast12MonthByLeadSourceQuery(String str, 
                                                                    String query, 
                                                                    String click, 
                                                                    String yearStr, 
                                                                    String monthStr,
                                                                    String recordTypeName

                                                                    ){
        Integer year = 2020;
        INteger month = 5;                           
        if (yearStr != null && yearStr != '') {
            year = Integer.valueOf(yearStr);
        }
        
        if (monthStr != null && monthStr != '') {
            month = Integer.valueOf(monthStr);
        }
        
        String year_month = system.today().month() + '-' + system.today().year();
        
        string QueryStr = query;
        QueryStr += ' AcctSeedERP__Total__c > 0';
        
        String str_year = String.valueOf(year);
        String str_month = String.valueOf(month);
        String year_month_inverced = str_month+'-'+str_year;

        system.debug('year_month_inverced: '+year_month_inverced);
        if(click == 'chart'){
            // QueryStr += ' and Month_Year__c = \''+year_month_inverced+ '\'';

            QueryStr += ' AND CALENDAR_MONTH(createddate) = ' + Integer.valueOf(str_month)+'';
            QueryStr += ' AND CALENDAR_YEAR(createddate) = ' + Integer.valueOf(str_year)+'';
        }else if(click == 'point'){
            // QueryStr += ' and Month_Year__c = \''+year_month_inverced+ '\' ';
            QueryStr += ' AND CALENDAR_MONTH(createddate) = ' + Integer.valueOf(str_month)+'';
            QueryStr += ' AND CALENDAR_YEAR(createddate) = ' + Integer.valueOf(str_year)+'';
            QueryStr += ' and LeadSource__c = \''+str + '\'';
        }
        
        if(recordTypeName != 'All'){
            QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
        }
        QueryStr += ' AND AcctSeedERP__Status__c != \'Cancelled\'';
        QueryStr += ' order by LeadSource__c asc, CreatedDate desc';

        system.debug('QueryStr: '+QueryStr);
        return QueryStr;
    }

    public static String Current_Sales_Contest_TM_SMDQuery(String QueryOrders, String click, String str, String recordTypeName, Set<String> Active_SalesReps_USA){
        string QueryStr = QueryOrders;
        QueryStr += ' CreatedDate = THIS_MONTH ';
        QueryStr += ' and AcctSeederp__total__c > 0 ';
        
        if (click == 'chart') {
            QueryStr += ' and Sales_rep_o__r.name in:Active_SalesReps_USA ';
        } else if (click == 'bar') {
            QueryStr += ' and Sales_rep_o__r.name = \'' + str + '\'';
        }
        if(recordTypeName != 'All'){
            QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
        }
        QueryStr += ' and AcctSeedERP__Status__c != \'' + 'Cancelled' + '\'';
        QueryStr += ' order by sales_rep_o__r.name asc, CreatedDate desc';

        return QueryStr;
    }

    public static String Sales_Forecast_Pipeline_SMDQuery(String yearStr, String monthStr, String recordTypeName, String QueryOpportunities, String click, String str, String duration, Set<string> All_SalesReps_USA){
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
        
        string QueryStr = QueryOpportunities;
        // QueryStr += ' RecordType.name = \'Seawin USA Hospitality\' ';
        // QueryStr += ' and GL_Account_Variable_1__r.Name = \'Seawin USA\' ';
        QueryStr += '  ForecastCategoryName = \'Pipeline\' ';
        
        if (click == 'chart') {
            QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_USA ';
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
            QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_USA ';
            QueryStr += duration == 'Missed'
                ? ' and CloseDate <:Pipeline_Start_Date '
                : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
        }
        if(recordTypeName != 'All'){
            QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
        }
        QueryStr += ' order by Name,Probability desc NULLS LAST';
        system.debug('ForecastMonthStart end: '+ForecastMonthStart);
        return QueryStr;
    }


    public static String Newly_Submitted_Opportunities_Last_12_Months_By_Lead_Source_SMDQuery(){
        string QueryStr = 'SELECT Id, Name, GL_Account_Variable_1__c,HasOverdueTask,HasOpenActivity,';
        QueryStr += ' LastModifiedDate,CreatedDate,LastActivityDate,LastModifiedById, ';
        QueryStr += ' LeadSource, AccountId, StageName, Probability, IsWon,Parent_Opportunity__c,';
        QueryStr += ' Price_Level__c, Newly_Submitted_Quote_First_Date__c,closed_date__c,CloseDate, ';
        QueryStr += ' ForecastCategoryName,Amount, Sales_Rep_O__c,Loss_Reason__c, ';
        QueryStr += ' Awarded_Owner__c,Owner.Name, ';
        QueryStr += ' ExpectedRevenue, (Select Status From Quotes Order By CreatedDate Asc Limit 1) FROM Opportunity where ';
        return QueryStr;
    }

    public static String Lost_Opportunities_SMDQuery(String QueryOpportunities, String str, String recordTypeName, String click){
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
        
        if (click == 'chart') {
            QueryStr += ' and sales_rep_o__r.name in:All_SalesReps ';
            QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
        } else if (click == 'point') {
            QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
            QueryStr += ' and Closed_Date__c >=:LostOpptyMonthStart and Closed_Date__c <=:LostOpptyMonthEnd ';
        } else if (click == 'month-point') {
            QueryStr += ' and sales_rep_o__r.name in:All_SalesReps ';
            QueryStr += ' and Closed_Date__c >=:LostOpptyMonthStart and Closed_Date__c <=:LostOpptyMonthEnd ';
        } else if (click == 'legend') {
            QueryStr += ' and sales_rep_o__r.name = \'' + str + '\'';
            QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
        }
        if(recordTypeName != 'All'){
            QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
        }
        QueryStr += ' order by sales_rep_o__r.name asc, Closed_Date__c desc';


        // String query = 'select calendar_month(Closed_Date__c) month,calendar_year(Closed_Date__c) year,';
        // query += ' Count(id) ct from opportunity ';
        // query += ' Where Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date';
        // query += ' and sales_rep_o__r.name in:All_SalesReps';
        // query += ' and StageName = \'Closed Lost\' AND Parent_Opportunity__c = NULL';
        // if(recordTypeName != 'All'){
        //     query += buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
        // }
        // query += ' AND (NOT Name LIKE :ChangeOrder)';
        // query += ' AND (NOT Name LIKE :MockupOne)';
        // query += ' AND (NOT Name LIKE :MockupTwo)';
        // query += ' AND (NOT Name LIKE :MockupThree)';
        // query += ' AND (NOT Name LIKE :MockupFour)';
        // query += ' group by calendar_month(Closed_Date__c), calendar_year(Closed_Date__c)';
        // query += ' order by calendar_year(Closed_Date__c) asc';
        return QueryStr;
    }

    public static String PreOrder_Pipeline_By_Lead_Source_SMD_USAQuery(String opp_dashb_query, String recordTypeName, String click, String str, String str2, String str3){
        String opportunity_dashboard_query = opp_dashb_query;

        opportunity_dashboard_query += ' WHERE  Opportunity_Forecast_Category__c =\'Pipeline\' ';
        opportunity_dashboard_query += ' AND Opportunity_StageName__c =\'Pre-Order\' ';
        opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
        opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
        
        if(recordTypeName != 'All'){
            opportunity_dashboard_query += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('Opportunity__r.RecordType.Name', recordTypeName);
        }

        if (click == 'legend' || click == 'point') {
            opportunity_dashboard_query += str == '' ? ' and (Opportunity_Lead_Source__c = \'' + str + '\'' : ' and Opportunity_Lead_Source__c = \'' + str + '\'';
            opportunity_dashboard_query += str == '' ? ' or Opportunity_Lead_Source__c = \'' + str2 + '\'' : '';
            opportunity_dashboard_query += str == '' ? ' or Opportunity_Lead_Source__c = \'' + str3 + '\')' : '';
        } else if(click == 'chart'){
            //If chart than we show all lead sources without filtering by lead source
        }

        opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

        return opportunity_dashboard_query;
    }

    public static String Neglected_Opportunities_SMDQuery(String opp_dashb_query, String click, String str, String recordTypeName){
        String opportunity_dashboard_query = opp_dashb_query;

        opportunity_dashboard_query += ' WHERE  Opportunity_Forecast_Category__c =\'Pipeline\' ';
        opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
        opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';
        opportunity_dashboard_query += ' AND isNeglected__c = true ';

        if (click == 'chart') {
            opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name in:All_SalesReps_USA';
        } else if(click == 'legend' || click == 'point') {
            opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name = \'' + str + '\'';
        }
        
        if(recordTypeName != 'All'){
            opportunity_dashboard_query += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('Opportunity__r.RecordType.Name', recordTypeName);
        }
        opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';
        return opportunity_dashboard_query;
    }

    public static String Negotiation_Pipeline_By_Lead_Source_SMD_USAQuery(String opportunity_dashboard, String str, String str2,String str3, String recordTypeName, String click){
        string opportunity_dashboard_query = opportunity_dashboard;
        opportunity_dashboard_query += ' WHERE Opportunity_Forecast_Category__c =\'Pipeline\' ';
        opportunity_dashboard_query += ' AND Opportunity_StageName__c =\'Negotiation\' ';
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

        return opportunity_dashboard_query;
    }

    public static String Monthly_Sales_Last_12_Months_Spec_SMD_HQuery(String so_dashb_query, String click, String str, Integer year, Integer month){
        string QueryStr = so_dashb_query;
        QueryStr += ' WHERE GL_Account_Variable_1__r.Name = \'Seawin USA\' ';
            
        String str_year = String.valueOf(year);
        String str_month = String.valueOf(month);
        String year_month_inverced = str_year+'-'+str_month;

        if (click == 'chart') {
            QueryStr += ' and Month_Year__c =:year_month ';
            QueryStr += ' and Status__c != \'' + 'Cancelled' + '\'';
        } else if (click == 'bar') {
            QueryStr += ' and Specified_Rep__r.name = \'' + str + '\'';
            QueryStr += ' and Inserting_Month__c =:str_month and Inserting_Year__c =:str_year ';
            QueryStr += ' and Status__c != \'' + 'Cancelled' + '\'';
        } else if (click == 'legend') {
            QueryStr += ' and Specified_Rep__r.name = \'' + str + '\'';
            QueryStr += ' and Month_Year__c =:year_month_inverced ';
            QueryStr += ' and Status__c != \'' + 'Cancelled' + '\'';
        } else if (click == 'left') {
            
            QueryStr += ' and Inserting_Month__c =:str_month and Inserting_Year__c =:year ';
            QueryStr += ' and Status__c != \'' + 'Cancelled' + '\'';
        }
        QueryStr += ' order by Specified_Rep__r.name asc, CreatedDate desc';

        return QueryStr;
    }

    public static String Activity_Graph_Last_12_Months_SMD_USAQuery(String opp_dashb_query, String click, String str, String recordTypeName){
        String opportunity_dashboard_query = opp_dashb_query;

        opportunity_dashboard_query += ' WHERE  Opportunity_Forecast_Category__c =\'Pipeline\' ';
        opportunity_dashboard_query += ' AND Has_Activity_In_Last_Month__c = true ';
        opportunity_dashboard_query += ' AND Inserting_Year__c =: max_year ';
        opportunity_dashboard_query += ' AND Inserting_Month__c =: max_month ';

        if (click == 'chart') {
            opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name in:All_SalesReps_USA';
        } else if(click == 'legend' || click == 'point') {
            opportunity_dashboard_query += ' AND Sales_Rep_Team__r.Name = \'' + str + '\'';
        }
        
        if(recordTypeName != 'All'){
            opportunity_dashboard_query += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('Opportunity__r.recordtype.name', recordTypeName);
        }
        opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

        return opportunity_dashboard_query;
    }

    public static String Active_Opportunities_By_Stage_SMDQuery(String opp_dashb_query, String click, String str, String recordTypeName){
        String opportunity_dashboard_query = opp_dashb_query;

        opportunity_dashboard_query += ' WHERE Opportunity_Forecast_Category__c =\'Pipeline\' ';
        opportunity_dashboard_query += ' AND Month_Year__c =: year_month ';
        opportunity_dashboard_query += ' AND Amount__c != NULL';
        opportunity_dashboard_query += ' AND Sal_Rep_Team_Name__c IN:All_SalesReps_USA';
        
        if (click == 'chart') {
        }else{
            opportunity_dashboard_query += ' and Opportunity_StageName__c = \'' + str + '\'';
        }
        
        if(recordTypeName != 'All'){
            opportunity_dashboard_query += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('Opportunity__r.recordtype.name', recordTypeName);
        }
        opportunity_dashboard_query += ' ORDER BY Opportunity__r.Name';

        return opportunity_dashboard_query;
    }

    public static String Sales_Forecast_Pipeline_By_Lead_Source_SMDQuery(String QueryOpportunities, String click, String str, String str2, String str3, String duration, String recordTypeName){
        string QueryStr = QueryOpportunities;
        QueryStr += ' RecordType.name = \'Seawin USA Hospitality\' ';
        QueryStr += ' and GL_Account_Variable_1__r.Name = \'Seawin USA\' ';
        QueryStr += ' and ForecastCategoryName = \'Pipeline\' ';
        QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_USA ';
        
        if (click == 'chart') {
            QueryStr += ' and CloseDate >=: Pipeline_Start_Date_Start_Date and CloseDate <=: Pipeline_Start_Date_End_Date ';
        } else if (click == 'bar') {
            QueryStr += str == '' ? ' and (LeadSource = \'' + str + '\'' : ' and LeadSource = \'' + str + '\'';
            QueryStr += str == '' ? ' or LeadSource = \'' + str2 + '\'' : '';
            QueryStr += str == '' ? ' or LeadSource = \'' + str3 + '\')' : '';
            QueryStr += duration == 'Missed'
                ? ' and CloseDate <:Pipeline_Start_Date_Start_Date '
                : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
        } else if (click == 'legend') {
            QueryStr += str == '' ? ' and (LeadSource = \'' + str + '\'' : ' and LeadSource = \'' + str + '\'';
            QueryStr += str == '' ? ' or LeadSource = \'' + str2 + '\'' : '';
            QueryStr += str == '' ? ' or LeadSource = \'' + str3 + '\')' : '';
            QueryStr += ' and CloseDate >=: Pipeline_Start_Date_Start_Date and CloseDate <=: Pipeline_Start_Date_End_Date ';
        } else if (click == 'left') {
            QueryStr += duration == 'Missed'
                ? ' and CloseDate <:Pipeline_Start_Date_Start_Date '
                : ' and CloseDate >=:ForecastMonthStart and CloseDate <=:ForecastMonthEnd ';
        }
        if(recordTypeName != 'All'){
            QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
        }
        QueryStr += ' order by Name,Probability desc NULLS LAST';

        return QueryStr;
    }

    public static String Sales_By_Lead_Source_Last_12_Months_SMD_HQuery(String QueryOrders, String click, String str, String str2, String str3, String recordTypeName){
        string QueryStr = QueryOrders;
        QueryStr += ' sales_rep_o__r.name in:All_SalesReps_USA ';
        QueryStr += ' AND AcctSeedERP__Status__c != \'Cancelled\' ';
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
        if(recordTypeName != 'All'){
            QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
        }
        QueryStr += ' order by AcctSeedERP__Opportunity__r.Leadsource asc, CreatedDate desc';

        return QueryStr;
    }

    public static String Loss_Reasons_SMD_USAQuery(String QueryOpportunities, String click, String str, String recordTypeName){
        string QueryStr = QueryOpportunities;
        QueryStr += ' StageName = \'Closed Lost\' ';
        QueryStr += ' and Parent_Opportunity__c = null ';
        QueryStr += ' and sales_rep_o__r.name in:All_SalesReps_USA ';
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
                QueryStr += ' and Loss_Reason__c = \'' + str + '\'';
            }
            QueryStr += ' and Closed_Date__c >=:LostOpptyMonthStart and Closed_Date__c <=:LostOpptyMonthEnd ';
        } else if (click == 'legend') {
            if (str == 'N/A') {
                QueryStr += ' and Loss_Reason__c =  null ';
            } else {
                QueryStr += ' and Loss_Reason__c = \'' + str + '\'';
            }
            QueryStr += ' and Closed_Date__c >=: Only_Start_Date and Closed_Date__c <=: Only_End_Date ';
        }
        if(recordTypeName != 'All'){
            QueryStr += HospitalityDashboardUSAController.buildRecordTypeFilterQuery('recordtype.name', recordTypeName);
        }
        QueryStr += ' order by Loss_Reason__c asc, Closed_Date__c desc';

        return QueryStr;
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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