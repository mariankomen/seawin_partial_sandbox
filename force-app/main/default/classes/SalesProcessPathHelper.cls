public class SalesProcessPathHelper {

    public static User usr {get{

        return [Select Id,Name,contactId from User where Id=:UserInfo.getUserId() Limit 1];
    }}
    
    public static map<string, integer> Process(string objectName, string fieldName, string recordTypeId){
        
        // list<string> StageValuesList = new list<string>();
        map<string, integer> StagePositionMap = new map<string, integer>();
        
        // get the picklist values
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm();
        endpoint += usr.ContactId == null ? '' : '/sales';
        endpoint += '/services/data/v41.0';
        endpoint += '/ui-api/object-info/'+objectName+'/picklist-values/'+recordTypeId+'/'+fieldName;
        
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        
        // set Authorization 
        request.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        HttpResponse response = http.send(request);
        
        If(response.getStatusCode() == 301 || response.getStatusCode() == 302){    
            request.setEndpoint(response.getHeader('Location'));response = new Http().send(request);}
        
        Map<String,Object> root = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> pValues = (List<Object>)root.get('values');
        
        Integer i = 1;
        for(Object pValue : pValues){
            Map<String,Object> pValueMap = (Map<String,Object>)pValue;
            //StageValuesList.add((String)pValueMap.get('label'));
            StagePositionMap.put((String)pValueMap.get('label'), i);
            
            i++;
        }
        
        return StagePositionMap;
    }
}