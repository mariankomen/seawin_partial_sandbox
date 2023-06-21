@isTest
public with sharing class RestApiServiceTest {

    @TestSetup
    static void makeData(){
        Client__c client = new Client__c();
        client.Email__c = 'testemail@gmail.com';
        client.First_Name__c = 'test';
        client.Last_Name__c = 'test';
        client.Phone__c = '9999999999';

        insert client;

        AcctSeed__GL_Account__c ga = new AcctSeed__GL_Account__c();
        ga.Name = 'GL Account Test';
        ga.AcctSeed__Active__c = true;
        ga.AcctSeed__Type__c = 'Revenue';
        ga.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        ga.AcctSeed__Sub_Type_2__c = 'Product Family 1';
        ga.AcctSeed__Bank__c = false;
        
        insert ga;
        
        // create product
        Product2 prod = new Product2();
        
        prod.Name = 'myProduct';
        prod.ProductCode = 'ABC123';
        prod.AcctSeed__Unit_Cost__c = 100;
        prod.ProductCode = 'JTH-02';
        prod.IsActive = true;
        prod.AcctSeed__Inventory_Type__c = 'Purchased';
        prod.AcctSeed__Expense_GL_Account__c = ga.id;
        prod.AcctSeed__Inventory_GL_Account__c = ga.id;
        prod.AcctSeed__Revenue_GL_Account__c = ga.id;
        
        insert prod;


        Client_Review__c reviewRecord = new Client_Review__c();
        reviewRecord.Client__c = client.Id;
        reviewRecord.Product__c = prod.Id;
        reviewRecord.Seller__c = 'test';
        reviewRecord.PO_Number__c = 'PO-1111';
        
        insert reviewRecord;
    }


    @isTest
    public static void doPostNewClientTest(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');

        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = '/newclient';
        req.requestBody = Blob.valueOf('{ "first_name":"test", "last_name":"last", "email":"test@gmail.com", "phone" : "(999)999999" }');
        RestApiService.doPost();
    }

    @isTest
    public static void doPostNewReviewTest(){
        Client__c cl = [SELECT Id from Client__c LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');

        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = '/newreview';
        req.requestBody = Blob.valueOf('{ "client_id": "'+cl.Id +'", "product_code":"JTH-02", "seller":"Some Name", "date_of_purchase": "2000-05-04", "po_number": "PO-11111" }');
        RestApiService.doPost();
    }

    @isTest
    public static void doPostUpdateStatusTest(){
        Client_Review__c cl = [SELECT Id from Client_Review__c LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');

        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = '/updateregistrationstatus';
        req.params.put('id',cl.Id);
        RestApiService.doPost();
    }

    @isTest
    public static void doGetTest(){
        Client__c cl = [SELECT Id from Client__c LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');

        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = '/client';
        req.params.put('id',cl.Id);
        RestApiService.doGet();
    }

    @isTest
    public static void doGetEmailTest(){
        Client__c cl = [SELECT Id, Email__c from Client__c LIMIT 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');

        RestContext.request = req;
        RestContext.response = res;
        req.requestURI = '/findclient';
        req.params.put('email',cl.Email__c);
        RestApiService.doGet();
    }
}