public with sharing class OptionalProductsOppSortOrder {
    
    public List<Optional_Products_Opportunity__c> lines {get; set;}
    private map<id, Optional_Products_Opportunity__c> linesMap = new map<id, Optional_Products_Opportunity__c>();
    public String jsonStr {get; set;}
    
    // sales order id is
    public id oppId {get; set;}
    
    public Opportunity opp {get; set;}
    
    public boolean visible {get{
        
        if(visible == null) visible = true;
        return visible;
        
    } set;}
    
    public OptionalProductsOppSortOrder(ApexPages.StandardSetController ssc){
        lines = new List<Optional_Products_Opportunity__c>();
        
        oppId = ApexPages.currentPage().getParameters().get('id');
        
        opp = [select name from Opportunity where id=:oppId];
        
        lines = [SELECT Id, Name, Item_Description__c, Product__r.name, Product_Code_Formula__c, Quantity__c, 
                 Opportunity__c, UnitPrice__c, Size__c, SortOrder__c, TotalPrice__c 
                 FROM Optional_Products_Opportunity__c 
                 where Opportunity__c =: oppId order by sortorder__c,name,createddate asc];
        
        if(lines.isEmpty()){
            
		   ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL, 
                                                     'No Products found.'
                                                     ));            
           visible = false; 
        }
    }
    public PageReference back(){
        
        PageReference page = new PageReference('/' + oppId);
        page.setRedirect(true);
        
        return page;
        
    }
    public Pagereference createsort(){
        
        string obj = ApexPages.currentPage().getParameters().get('sortstring');
        
        if(obj.Length() > 0){
            
            // create a map of lines
            for(optional_products_opportunity__c line : lines){
                
                linesMap.put(line.id, line);
                
            }
            
            list<wrapper> sortlist = (list<wrapper>)JSON.deserialize(obj, list<Wrapper>.class);
            
            for(wrapper w : sortlist){
                // get the line from the map
                optional_products_opportunity__c line = linesMap.get(w.id);
                if(line == null) continue;
                
                line.SortOrder__c = Decimal.valueOf(w.sorts);
            }
            
            list<optional_products_opportunity__c> linesUpdatables = new list<optional_products_opportunity__c>();
            
            linesUpdatables.addAll(linesMap.values());
            
            update linesUpdatables;
            
            Pagereference pr = new PageReference('/' + oppId);
            pr.setRedirect(true);
            return pr;
        }
        return null;
    }
    class Wrapper {
        
        public string id,sorts;
        
    }
}