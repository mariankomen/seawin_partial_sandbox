@isTest
public class MainSalesManagerDashboardChinaCtrlTest {
    
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
        
        List<MainSalesManagerDashboardChinaCtrl.ValuesWrapper> vws = new List<MainSalesManagerDashboardChinaCtrl.ValuesWrapper>();
                
        MainSalesManagerDashboardChinaCtrl.ValuesWrapper vw = new MainSalesManagerDashboardChinaCtrl.ValuesWrapper(
            1,
            null,
            null,
            10,
            2021,
            null,
            null
        );
        
        vws.add(vw);
        
        MainSalesManagerDashboardChinaCtrl.MainWrapper mw = 
            new MainSalesManagerDashboardChinaCtrl.MainWrapper(null, vws, 1);
        
        MainSalesManagerDashboardChinaCtrl.YearlyWrapper yw = new 
            MainSalesManagerDashboardChinaCtrl.YearlyWrapper(
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
        
        MainSalesManagerDashboardChinaCtrl ext = new MainSalesManagerDashboardChinaCtrl();
        
       	MainSalesManagerDashboardChinaCtrl.Months();
        MainSalesManagerDashboardChinaCtrl.Active_SalesReps();
        MainSalesManagerDashboardChinaCtrl.Active_Users();
        MainSalesManagerDashboardChinaCtrl.getAll_Account_Types();
        MainSalesManagerDashboardChinaCtrl.getAll_Lead_Soruces();
        MainSalesManagerDashboardChinaCtrl.getAll_SalesReps();
        MainSalesManagerDashboardChinaCtrl.All_Users();
        MainSalesManagerDashboardChinaCtrl.AllSalesRepsList();
        MainSalesManagerDashboardChinaCtrl.AllSalesRepsMap();
        System.Assert(MainSalesManagerDashboardChinaCtrl.AverageDueDays != null);
        MainSalesManagerDashboardChinaCtrl.getcommunityUrl();
        MainSalesManagerDashboardChinaCtrl.Full_End_Date();
        MainSalesManagerDashboardChinaCtrl.Full_Start_Date();
        MainSalesManagerDashboardChinaCtrl.Inside_Sales_Users();
        MainSalesManagerDashboardChinaCtrl.getisTest();
        MainSalesManagerDashboardChinaCtrl.getLastYear();
        MainSalesManagerDashboardChinaCtrl.getLastYearMonthName();
        MainSalesManagerDashboardChinaCtrl.getLastYearMonthStart();
        MainSalesManagerDashboardChinaCtrl.getLastYearShort();
        MainSalesManagerDashboardChinaCtrl.getMonthEnd();
        MainSalesManagerDashboardChinaCtrl.getMonthName();
        MainSalesManagerDashboardChinaCtrl.Next12MonthsList();
        MainSalesManagerDashboardChinaCtrl.Only_End_Date();
        MainSalesManagerDashboardChinaCtrl.Only_Start_Date();
        MainSalesManagerDashboardChinaCtrl.getPrevMonthName();
        MainSalesManagerDashboardChinaCtrl.getSysAdminCHK();
        MainSalesManagerDashboardChinaCtrl.UsernameAndIdsMap();           
        MainSalesManagerDashboardChinaCtrl.getYear();

        
        // Methods
        MainSalesManagerDashboardChinaCtrl.CalculateUptoDateQuota(1000, Date.today(), Date.newInstance(2020, 1, 1));
        MainSalesManagerDashboardChinaCtrl.CheckUser(UserInfo.getuserId(), UserInfo.getuserId());
        MainSalesManagerDashboardChinaCtrl.Last12MonthsList();
        MainSalesManagerDashboardChinaCtrl.Last12MonthsList_CombinedMap();
        MainSalesManagerDashboardChinaCtrl.Last12MonthsList_Horizontal();
        MainSalesManagerDashboardChinaCtrl.Next12MonthsList();
        
        map<string, List<MainSalesManagerDashboardChinaCtrl.ValuesWrapper>> newMap = 
            new map<string, List<MainSalesManagerDashboardChinaCtrl.ValuesWrapper>>();
        newMap.put('Test', vws);
        
        map<string, decimal> DataMap = new map<string, decimal>();
        DataMap.put('Test', 0.1);
        
        MainSalesManagerDashboardChinaCtrl.SortByValues(newMap);
        MainSalesManagerDashboardChinaCtrl.sortedKeys(newMap);
        MainSalesManagerDashboardChinaCtrl.sortEngine(DataMap);

        MainSalesManagerDashboardChinaCtrl.UserData_From_Teams(teams);
        MainSalesManagerDashboardChinaCtrl.UserIds_From_Teams(teams);
        MainSalesManagerDashboardChinaCtrl.Usernames_From_Teams(userIds);

        Test.stopTest();
        
    }
}