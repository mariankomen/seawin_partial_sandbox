@isTest
public class BookKeeperDashboardControllerTest {
    
    @TestSetup static void createData(){
        
        TestUtility.CreateData();
    }
    @isTest static void runTest(){
        
        BookKeeperDashboardController bdc = new BookKeeperDashboardController();
        
    }
}