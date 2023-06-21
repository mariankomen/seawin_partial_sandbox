public with sharing class OpportunityProductsSortOrderController {
    
    public List<OpportunityLineItem> lines {get; set;}
    private map<id, OpportunityLineItem> linesMap = new map<id, OpportunityLineItem>();
    public String jsonStr {get; set;}
     
    public boolean visible {get{
        if(visible == null) visible = true;
        return visible;
    } set;}
    
    public Id OpId {get; set;}
    public Opportunity op {get; set;}
    public OpportunityProductsSortOrderController(){    
        
        lines = new List<OpportunityLineItem>();
        OpId = ApexPages.CurrentPage().getParameters().get('id');
        op = [select name from Opportunity where id=:OpId];
        
        lines = [select id, Quantity, Product2.Name, ProductCode, Item_Description__c, UnitPrice, TotalPrice, Size__c  
                 from OpportunityLineItem 
                 where OpportunityId =: OpId]; 
        
        System.debug('lines1: ' + lines);
        lines = [select id, Quantity, Product2.Name, ProductCode, Item_Description__c, UnitPrice, TotalPrice, Size__c  
                 from OpportunityLineItem 
                 where OpportunityId =: OpId order by SortOrder, name, createddate asc]; 
        
        System.debug('lines2: ' + lines);
        
        if(lines.isEmpty()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL, 'No Products found.'));
            visible = false;
        }
    }
    
    public PageReference back(){
        
        PageReference page = new PageReference('/' + OpId);
        page.setRedirect(true);
        
        return page;
        
    }
    
    public Pagereference createsort(){
        string obj = ApexPages.currentPage().getParameters().get('sortstring');
        if(obj.Length() > 0){
            // create a map of lines
            for(OpportunityLineItem line : lines){
                linesMap.put(line.Id, line);
            }
            
            list<wrapper> sortlist = (list<wrapper>)JSON.deserialize(obj, list<Wrapper>.class);
            for(wrapper w : sortlist){
                // get the line from the map
                OpportunityLineItem line = linesMap.get(w.id);
                if(line == null) continue; 
                line.SortOrder = Integer.valueOf(w.sorts);
            }
            
            list<OpportunityLineItem> linesUpdatables = new list<OpportunityLineItem>();
            linesUpdatables.addAll(linesMap.values());
            update linesUpdatables;
            Pagereference pr = new PageReference('/' + OpId);
            pr.setRedirect(true);
            return pr;
        }
        return null;
    }
    
    class Wrapper {   
        public string id,sorts;
    }
}