public with sharing class OptionalProductsQuoteSortOrder {
    
    public List<Optional_Products_Quote__c> lines {get; set;}
    private map<id, Optional_Products_Quote__c> linesMap = new map<id, Optional_Products_Quote__c>();
    public String jsonStr {get; set;}
    
    // sales order id is
    public id quoteId {get; set;}
    
    public Quote qt {get; set;}
    
    public boolean visible {get{
        
        if(visible == null) visible = true;
        return visible;
        
    } set;}
    
    public OptionalProductsQuoteSortOrder(ApexPages.StandardSetController ssc){
        lines = new List<Optional_Products_Quote__c>();
        
        quoteId = ApexPages.currentPage().getParameters().get('id');
        
        qt = [select name from Quote where id=:quoteId];
        
        lines = [SELECT Id, Name, Item_Description__c, Product__r.name, Quantity__c, 
                 Quote__c, UnitPrice__c, Size__c, SortOrder__c, TotalPrice__c, Product_Code_Formula__c 
                 FROM Optional_Products_Quote__c 
                 where Quote__c =: quoteId order by sortorder__c,name,createddate asc];
        
        if(lines.isEmpty()){
            
		   ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL, 
                                                     'No Products found.'
                                                     ));            
           visible = false; 
        }
    }
    public PageReference back(){
        
        PageReference page = new PageReference('/' + quoteId);
        page.setRedirect(true);
        
        return page;
        
    }
    public Pagereference createsort(){
        
        string obj = ApexPages.currentPage().getParameters().get('sortstring');
        
        if(obj.Length() > 0){
            
            // create a map of lines
            for(optional_products_quote__c line : lines){
                
                linesMap.put(line.id, line);
                
            }
            
            list<wrapper> sortlist = (list<wrapper>)JSON.deserialize(obj, list<Wrapper>.class);
            
            for(wrapper w : sortlist){
                // get the line from the map
                optional_products_quote__c line = linesMap.get(w.id);
                if(line == null) continue;
                
                line.SortOrder__c = Decimal.valueOf(w.sorts);
            }
            
            list<optional_products_quote__c> linesUpdatables = new list<optional_products_quote__c>();
            
            linesUpdatables.addAll(linesMap.values());
            
            update linesUpdatables;
            
            Pagereference pr = new PageReference('/' + quoteId);
            pr.setRedirect(true);
            return pr;
        }
        return null;
    }
    class Wrapper {
        
        public string id,sorts;
        
    }
}