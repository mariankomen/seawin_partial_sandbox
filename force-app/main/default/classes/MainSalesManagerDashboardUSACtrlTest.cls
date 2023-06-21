@isTest
public class MainSalesManagerDashboardUSACtrlTest {
    
    @TestSetup static void MakeData(){
        
        List<sales_rep__c> salesrepList = new List<sales_rep__c>();
        
        sales_rep__c sr = new sales_rep__c();
        
        sr.User__c = Userinfo.getUserId();
        sr.Active__c = 'Yes';
        sr.Name = 'Murtaza Ashraf';
        sr.Price_Level_1_12__c = 1;
        sr.Price_Level_13_20__c = 2;
        sr.Price_Level_21_26__c = 3;
        sr.Price_Level_27_30__c = 4;
        sr.Monthly_Quota__c = 1000;
        
        salesrepList.add(sr);
        
        sales_rep__c sr2 = new sales_rep__c();
        
        sr2.User__c = Userinfo.getUserId();
        sr2.Active__c = 'Yes';
        sr2.Name = 'Test Sales Rep';
        sr2.Price_Level_1_12__c = 1;
        sr2.Price_Level_13_20__c = 2;
        sr2.Price_Level_21_26__c = 3;
        sr.Price_Level_27_30__c = 4;
        sr2.Monthly_Quota__c = 1000;
        
        salesrepList.add(sr2);
        
        insert salesrepList;
        
    }
    
    @isTest static void runTests(){
        
        Sales_Rep__c salesrep = [select id,name from sales_rep__c limit 1];
        
        string teams = salesrep.id;

        Test.startTest();
        
        set<string> userIds = new set<string>();
        userIds.add(UserInfo.getUserId());
        
        List<MainSalesManagerDashboardUSACtrl.ValuesWrapper> vws = new List<MainSalesManagerDashboardUSACtrl.ValuesWrapper>();
                
        MainSalesManagerDashboardUSACtrl.ValuesWrapper vw = new MainSalesManagerDashboardUSACtrl.ValuesWrapper(
            1,
            null,
            null,
            10,
            2021,
            null,
            null
        );
        
        vws.add(vw);
        
        MainSalesManagerDashboardUSACtrl.MainWrapper mw = 
            new MainSalesManagerDashboardUSACtrl.MainWrapper(null, vws, 1);
        
        MainSalesManagerDashboardUSACtrl.YearlyWrapper yw = new 
            MainSalesManagerDashboardUSACtrl.YearlyWrapper(
            null,
            null,
            null,
            null,
            0.1,
            0.1,
            0.1,
            0.1,
            0.1,
            0.1
        );
        
        MainSalesManagerDashboardUSACtrl ext = new MainSalesManagerDashboardUSACtrl();
        
       	MainSalesManagerDashboardUSACtrl.Months();
        MainSalesManagerDashboardUSACtrl.Active_SalesReps();
        MainSalesManagerDashboardUSACtrl.Active_Users();
        MainSalesManagerDashboardUSACtrl.getAll_Account_Types();
        MainSalesManagerDashboardUSACtrl.getAll_Lead_Soruces();
        MainSalesManagerDashboardUSACtrl.getAll_SalesReps();
        MainSalesManagerDashboardUSACtrl.All_Users();
        MainSalesManagerDashboardUSACtrl.AllSalesRepsList();
        MainSalesManagerDashboardUSACtrl.AllSalesRepsMap();
        System.Assert(MainSalesManagerDashboardUSACtrl.AverageDueDays != null);
        MainSalesManagerDashboardUSACtrl.getcommunityUrl();
        MainSalesManagerDashboardUSACtrl.Full_End_Date();
        MainSalesManagerDashboardUSACtrl.Full_Start_Date();
        MainSalesManagerDashboardUSACtrl.Inside_Sales_Users();
        MainSalesManagerDashboardUSACtrl.getisTest();
        MainSalesManagerDashboardUSACtrl.getLastYear();
        MainSalesManagerDashboardUSACtrl.getLastYearMonthName();
        MainSalesManagerDashboardUSACtrl.getLastYearMonthStart();
        MainSalesManagerDashboardUSACtrl.getLastYearShort();
        MainSalesManagerDashboardUSACtrl.getMonthEnd();
        MainSalesManagerDashboardUSACtrl.getMonthName();
        MainSalesManagerDashboardUSACtrl.Next12MonthsList();
        MainSalesManagerDashboardUSACtrl.Only_End_Date();
        MainSalesManagerDashboardUSACtrl.Only_Start_Date();
        MainSalesManagerDashboardUSACtrl.getPrevMonthName();
        MainSalesManagerDashboardUSACtrl.getSysAdminUSA();
        MainSalesManagerDashboardUSACtrl.UsernameAndIdsMap();           
        MainSalesManagerDashboardUSACtrl.getYear();

        
        // Methods
        MainSalesManagerDashboardUSACtrl.CalculateUptoDateQuota(1000, Date.today(), Date.newInstance(2020, 1, 1));
        MainSalesManagerDashboardUSACtrl.CheckUser(UserInfo.getuserId(), UserInfo.getuserId());
        MainSalesManagerDashboardUSACtrl.Last12MonthsList();
        MainSalesManagerDashboardUSACtrl.Last12MonthsList_CombinedMap();
        MainSalesManagerDashboardUSACtrl.Last12MonthsList_Horizontal();
        MainSalesManagerDashboardUSACtrl.Next12MonthsList();
        
        map<string, List<MainSalesManagerDashboardUSACtrl.ValuesWrapper>> newMap = 
            new map<string, List<MainSalesManagerDashboardUSACtrl.ValuesWrapper>>();
        newMap.put('Test', vws);
        
        map<string, decimal> DataMap = new map<string, decimal>();
        DataMap.put('Test', 0.1);
        
        MainSalesManagerDashboardUSACtrl.SortByValues(newMap);
        MainSalesManagerDashboardUSACtrl.sortedKeys(newMap);
        MainSalesManagerDashboardUSACtrl.sortEngine(DataMap);

        MainSalesManagerDashboardUSACtrl.UserData_From_Teams(teams);
        MainSalesManagerDashboardUSACtrl.UserIds_From_Teams(teams);
        MainSalesManagerDashboardUSACtrl.Usernames_From_Teams(userIds);

        Test.stopTest();
        
    }
}