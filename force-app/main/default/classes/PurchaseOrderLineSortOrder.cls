public with sharing class PurchaseOrderLineSortOrder {
    
    public List<AcctSeedERP__Purchase_Order_Line__c> lines {get; set;}
    private map<id, acctseederp__Purchase_order_line__c> linesMap = new map<id, acctseederp__Purchase_order_line__c>();
    public String jsonStr {get; set;}
    
    public acctseederp__purchase_order__c po {get; set;}
    
    // sales order id is
    public id poId {get; set;}
    
    public boolean visible {get{
        
        if(visible == null) visible = true;
        return visible;
        
        
    } set;}
    
    public PurchaseOrderLineSortOrder(ApexPages.StandardSetController ssc){
        lines = new List<AcctSeedERP__Purchase_Order_Line__c>();
        
        poId = ApexPages.currentPage().getParameters().get('id');
        
        po = [select name from acctseederp__purchase_order__c where id =:poId];
        
        lines = [select id, name, acctseederp__product__r.name, product_Code__c, 
                 sort_order__c, description__c, size__c, quantity_formula__c,
                 quantity_received_formula__c, quantity_unreceived_formula__c, Purchase_price__c, total_price__c 
                 from AcctSeedERP__Purchase_Order_Line__c 
                 where AcctSeedERP__Purchase_Order__c =: poId order by sort_order__c,name,createddate asc];
        
        if(lines.isEmpty()){
            
		   ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL, 
                                                     'No Products found.'
                                                     ));            
           visible = false; 
        }
    }
    public PageReference back(){
        
        PageReference page = new PageReference('/' + poid);
        page.setRedirect(true);
        
        return page;
        
    }
    public Pagereference createsort(){
        
        string obj = ApexPages.currentPage().getParameters().get('sortstring');
        
        if(obj.Length() > 0){
            
            // create a map of lines
            for(acctseederp__purchase_order_line__c line : lines){
                
                linesMap.put(line.id, line);
                
            }
            
            list<wrapper> sortlist = (list<wrapper>)JSON.deserialize(obj, list<Wrapper>.class);
            
            for(wrapper w : sortlist){
                // get the line from the map
                acctseederp__purchase_order_line__c line = linesMap.get(w.id);
                if(line == null) continue;
                
                line.Sort_Order__c = Decimal.valueOf(w.sorts);
            }
            
            list<acctseederp__purchase_order_line__c> linesUpdatables = new list<acctseederp__purchase_order_line__c>();
            
            linesUpdatables.addAll(linesMap.values());
            
            update linesUpdatables;
            
            Pagereference pr = new PageReference('/' + poId);
            pr.setRedirect(true);
            return pr;
        }
        return null;
    }
    class Wrapper {
        
        public string id,sorts;
        
    }
}