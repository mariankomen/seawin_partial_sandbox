@RestResource(urlMapping = '/v1/integration/*')
global with sharing class RestApiService {
    
    public class WebServiceException extends Exception {}

    @HttpPost
    webservice static void doPost(){
        String requestURI = RestContext.request.requestURI;
        String requestURIWildcard = requestURI.replace('/v1/integration','');

        try{

            if(requestURIWildcard == '/newclient'){
                RestContext.response.responseBody = Blob.valueOf(createNewClient(RestContext.request.requestBody.toString()));
            }else if(requestURIWildcard == '/newreview'){
                RestContext.response.responseBody = Blob.valueOf(createNewReview(RestContext.request.requestBody.toString()));
            }else if(requestURIWildcard == '/updateregistrationstatus'){
                RestContext.response.responseBody = Blob.valueOf(updateRegistrationStatus(RestContext.request.params.get('id')));
            }else{
                throw new WebServiceException('Endpoint not found.'); 
            }

        }catch(Exception e){
            throw new WebServiceException(e.getMessage()); 
        }
    }


    @HttpGet
    webservice static void doGet(){
        String requestURI = RestContext.request.requestURI;
        String requestURIWildcard = requestURI.replace('/v1/integration','');

        try{
            if(requestURIWildcard == '/client'){
                String client_id = RestContext.request.params.get('id');
                RestContext.response.responseBody = Blob.valueOf(getClient(client_id));

            }else if(requestURIWildcard == '/findclient'){
                String client_email = RestContext.request.params.get('email');
                RestContext.response.responseBody = Blob.valueOf(getClientByEmail(client_email));

            }else{
                throw new WebServiceException('Endpoint not found.'); 
            }
        }catch(Exception e){
            throw new WebServiceException(e.getMessage()); 
 
        }
    }

    public static String getClient(Id clientId){
        if(clientId == null){
            throw new WebServiceException('Missing params: client_id is required.');
        }
        GetClientsResponseWrapper response;
        try{
            Client__c client = [SELECT Id, Name, Email__c, First_Name__c, Last_Name__c, Phone__c, OwnerId FROM Client__c WHERE Id=: clientId];
            response = new GetClientsResponseWrapper('success', client);
        }catch(Exception e){
            RestContext.response.statusCode = 404;
            response = new GetClientsResponseWrapper('failed', null);

        }
        return JSON.serialize(response);

    }
    public static String getClientByEmail(String clientEmail){
        if(clientEmail == null){
            throw new WebServiceException('Missing params: email is required.');
        }
        GetClientsResponseWrapper response;
        try{
            List<Client__c> clients = [SELECT Id, Name, Email__c, First_Name__c, Last_Name__c, Phone__c, OwnerId FROM Client__c WHERE Email__c=: clientEmail];
            if(clients.isEmpty()){
                response = new GetClientsResponseWrapper('failed', null);
                RestContext.response.statusCode = 404;
            }else{
                response = new GetClientsResponseWrapper('success', clients[0]);
            }
        } catch(Exception e){
        }
        return JSON.serialize(response);

    }
    public static String createNewClient(String body){
        ClientWrapper client = (ClientWrapper)JSON.deserialize(body, ClientWrapper.class);
        Client__c cli = new Client__c();
        cli.Email__c = client.email;
        cli.First_Name__c = client.first_name;
        cli.Last_Name__c = client.last_name;
        cli.Phone__c = client.phone;

        insert cli;
        RestContext.response.statusCode = 200;
        return JSON.serialize(cli);
    }

    public static String createNewReview(String body){
        ReviewWrapper review = (ReviewWrapper)JSON.deserialize(body, ReviewWrapper.class);
        if(review.client_id == null){
            throw new WebServiceException('Missing params: client_id is required.');
        }

        List<Client__c> client = [SELECT Id, Email__c FrOM Client__c WHERE Id =: review.client_id LIMIT 1];
        if(client.isEmpty()){
            throw new WebServiceException('Can not find client with id: '+review.client_id);
        }

        List<Product2> product = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode =: review.product_code LIMIT 1];

        if(product.isEmpty()){
            
            throw new WebServiceException('Can not find product with Product Code: '+review.product_code);
        }

        Client_Review__c reviewRecord = new Client_Review__c();
        reviewRecord.Client__c = client[0].Id;
        reviewRecord.Product__c = product[0].Id;
        reviewRecord.Seller__c = review.seller;
        reviewRecord.Date_of_Purchase__c = Date.valueOf(review.date_of_purchase);
        reviewRecord.PO_Number__c = review.po_number;
        insert reviewRecord;
        return JSON.serialize(reviewRecord);
    }

    public static String updateRegistrationStatus(Id reviewId){
        List<Client_Review__c> review = [SELECT Id, Client__c, Product__c, Seller__c, Date_of_Purchase__c, PO_Number__c, Review_Done__c FROM Client_Review__c WHERE Id=:reviewId];
        if(review.isEmpty()){
            throw new WebServiceException('Can not find product registration with Id: '+reviewId);
        }

        review[0].Review_Done__c = true;
        update review;
        return JSON.serialize(review[0]);
    }
    public class ClientWrapper{
        public String first_name {get;set;}
        public String last_name {get;set;}
        public String email {get;set;}
        public String phone {get;set;}
        
    }

    public class ReviewWrapper{
        public Id client_id {get;set;}
        public String product_code {get;set;}
        public String reviewer_email {get;set;}
        public String seller {get;set;}
        public Date date_of_purchase {get;set;}
        public String po_number {get;set;}
    }

    public class GetClientsResponseWrapper{
        public String status {get;set;}
        public Client__c data {get;set;}

        public GetClientsResponseWrapper(String status, Client__c data){
            this.status = status;
            this.data = data;
        }
    }
}