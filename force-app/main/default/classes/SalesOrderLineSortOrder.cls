public with sharing class SalesOrderLineSortOrder {
    
    public List<AcctSeedERP__Sales_Order_Line__c> lines {get; set;}
    private map<id, acctseederp__sales_order_line__c> linesMap = new map<id, acctseederp__sales_order_line__c>();
    public String jsonStr {get; set;}
    public Boolean isLoaded {get; set;}
    // sales order id is
    public id soId {get; set;}
    public Boolean render_childs {get; set;}
    
    public acctseederp__sales_order__c so {get; set;}
    
    public boolean visible {get{
        
        if(visible == null) visible = true;
        return visible;
        
    } set;}
    public Map<AcctSeedERP__Sales_Order_line__c, Integer> kits {get;set;}
    public List<List<AcctSeedERP__Sales_Order_line__c>> childrens {get;set;} 
    public List<AcctSeedERP__Sales_Order_line__c> kits_parents {get;set;} 

    public SalesOrderLineSortOrder(ApexPages.StandardSetController ssc){
        lines = new List<AcctSeedERP__Sales_Order_Line__c>();
        kits = new Map<AcctSeedERP__Sales_Order_line__c, Integer>();
        childrens = new List<List<AcctSeedERP__Sales_Order_line__c>>();
        kits_parents = new List<AcctSeedERP__Sales_Order_line__c>();
        render_childs = false;
        soId = ApexPages.currentPage().getParameters().get('id');
        isLoaded = false;
        so = [select name from acctseederp__sales_order__c where id=:soId];
        
        lines = [select id, name,acctseederp__product__c, acctseederp__product__r.name, productCode__c, 
                 sortorder__c, item_description__c, size__c, quantityformula__c,
                 quantity_allocated_formula__c, quantity_shipped_formula__c, sales_price__c, total_price__c,Kit_Children__c,Kit__c 
                 from AcctSeedERP__Sales_Order_Line__c 
                 where AcctSeedERP__Sales_Order__c =: soId order by sortorder__c asc];
        system.debug('acctseederp__product__r : '+JSON.serialize(lines));
        if(lines.isEmpty()){
            
		   ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL, 
                                                     'No Products found.'
                                                     ));            
           visible = false; 
        }

        getLinesRenderWrapper(lines);
        render_childs = childrens.size() > 0 ? true : false;
        isLoaded = true;
    }
    public PageReference back(){
        
        PageReference page = new PageReference('/' + soid);
        page.setRedirect(true);
        
        return page;
        
    }

    public void getLinesRenderWrapper(List<AcctSeedERP__Sales_Order_Line__c> lines){
        Map<Id, List<Id>> kit_relation = SalesOrderPDFController.getKitsRelation();
        Map<Id, AcctSeedERP__Sales_Order_Line__c> sol_map = new Map<Id, AcctSeedERP__Sales_Order_Line__c>();
        List<AcctSeedERP__Sales_Order_line__c> not_kit_not_kitprod = new List<AcctSeedERP__Sales_Order_line__c>();
        Map<Id, List<Id>> current_so_relation = new Map<Id, List<Id>>();

        for(AcctSeedERP__Sales_Order_Line__c sol: lines){
            sol_map.put(sol.AcctSeedERP__Product__c, sol); //Making map <ProductId, SalesOrderLine>

            //Sales Order can have not KIT and not KIT Product lines
            //We make another list with this items and will add to the end of pdf in code above
            if(sol.Kit__c == false && sol.Kit_Children__c == false){
                not_kit_not_kitprod.add(sol);
            }
        }
        system.debug('not_kit_not_kitprod: '+JSON.serialize(not_kit_not_kitprod));
        /* This part of code sort Sales Order Lines in order KIT parent and above him related Kit Products */

        for(Id solId: sol_map.keySet()){
            if(sol_map.get(solId).Kit__c == true && kit_relation.containsKey(solId)){
                List<Id> childs = new List<Id>(); //List of related to KIT -> KIT products

                //We make map with Kit and related Kit products to him 
                for(Id kit_prod:kit_relation.get(solId)){
                    if(sol_map.containsKey(kit_prod)){
                        childs.add(kit_prod);
                    }
                }
                current_so_relation.put(solId, childs); //Putting map with ProductId(KIT) and list of child(KIT Products)
            }
        }
        // Map<AcctSeedERP__Sales_Order_line__c, Integer> kits = new Map<AcctSeedERP__Sales_Order_line__c, Integer>();
        
        Integer index = 0;
        for(Id line: current_so_relation.keySet()){
            
            for(AcctSeedERP__Sales_Order_Line__c l: lines){
                if(l.AcctSeedERP__Product__c == line){
                    kits.put(l, index);
                    kits_parents.add(l);
                }
            }
            index++;

        }
        
        
        for(Id line: current_so_relation.keySet()){
            List<AcctSeedERP__Sales_Order_line__c> childrens_k = new List<AcctSeedERP__Sales_Order_line__c>();
            for(Id child: current_so_relation.get(line)){
                for(AcctSeedERP__Sales_Order_Line__c l: lines){
                    if(l.AcctSeedERP__Product__c == child){
                        childrens_k.add(l);
                    }
                }
            }
            childrens.add(childrens_k);
            
        }
        
        for(AcctSeedERP__Sales_Order_line__c not_kit:not_kit_not_kitprod){
            List<AcctSeedERP__Sales_Order_line__c> childrens_k = new List<AcctSeedERP__Sales_Order_line__c>();
            kits.put(not_kit, index);
            kits_parents.add(not_kit);
            childrens.add(childrens_k);
            index++;
        }
        system.debug('kits_parents: '+kits_parents.size());
        system.debug('childrens: '+childrens.size());
    }



    @RemoteAction
    public static void saveSorting(String json_sort, String soId){
        system.debug('Id; '+soId);
        List<SortingWrapper> sortlist = (List<SortingWrapper>)JSON.deserialize(json_sort, List<SortingWrapper>.class);
        List<acctseederp__sales_order_line__c> lines = [select id, name,acctseederp__product__c, acctseederp__product__r.name, productCode__c, 
                                                        sortorder__c, item_description__c, size__c, quantityformula__c,
                                                        quantity_allocated_formula__c, quantity_shipped_formula__c, sales_price__c, total_price__c,Kit_Children__c,Kit__c 
                                                        from AcctSeedERP__Sales_Order_Line__c 
                                                        where AcctSeedERP__Sales_Order__c =: soId order by sortorder__c asc];
        List<acctseederp__sales_order_line__c> for_update = new List<acctseederp__sales_order_line__c>();

        map<id, acctseederp__sales_order_line__c> sol_map = new map<id, acctseederp__sales_order_line__c>(lines);

        for(SortingWrapper sw:sortlist){
            acctseederp__sales_order_line__c line = sol_map.get(sw.solId);
            line.SortOrder__c = sw.sortNumber;
            for_update.add(line);
        }
        update for_update;
    }




    public Pagereference createsort(){
        
        string obj = ApexPages.currentPage().getParameters().get('sortstring');
        
        if(obj.Length() > 0){
            
            // create a map of lines
            for(acctseederp__sales_order_line__c line : lines){
                
                linesMap.put(line.id, line);
                
            }
            
            list<wrapper> sortlist = (list<wrapper>)JSON.deserialize(obj, list<Wrapper>.class);
            
            for(wrapper w : sortlist){
                // get the line from the map
                acctseederp__sales_order_line__c line = linesMap.get(w.id);
                if(line == null) continue;
                
                line.SortOrder__c = Decimal.valueOf(w.sorts);
            }
            
            list<acctseederp__sales_order_line__c> linesUpdatables = new list<acctseederp__sales_order_line__c>();
            
            linesUpdatables.addAll(linesMap.values());
            
            update linesUpdatables;
            
            Pagereference pr = new PageReference('/' + soId);
            pr.setRedirect(true);
            return pr;
        }
        return null;
    }
    class Wrapper {
        
        public string id,sorts;
        
    }
    public class SortingWrapper{
        public Id solId {get;set;}
        public Integer sortNumber {get;set;}

        public SortingWrapper(Id sId, Integer n){
            solId = sId;
            sortNumber = n;
        }
    }

    public class childrenWrapper{
        Id parentId {get; set;}
        Id childrenId {get; set;}
        Decimal children_amount {get; set;}

        public childrenWrapper(Id parId, Id chilId, Decimal amount){
            parentId = parId;
            childrenId = chilId;
            children_amount = amount;
        }
    }
}