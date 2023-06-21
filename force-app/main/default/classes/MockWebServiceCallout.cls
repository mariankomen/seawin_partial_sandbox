@isTest
global class MockWebServiceCallout implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"controllerValues":{},"defaultValue":null,"url":"/services/data/v41.0/ui-api/object-info/Opportunity/picklist-values/0121I000000QbTQQA0/StageName","values":[{"attributes":{"closed":false,"defaultProbability":0,"forecastCategoryName":"Pipeline","picklistAtrributesValueType":"OpportunityStage","won":false},"label":"Needs Analysis"}]}');
        res.setStatusCode(200);
        return res;
    }
}