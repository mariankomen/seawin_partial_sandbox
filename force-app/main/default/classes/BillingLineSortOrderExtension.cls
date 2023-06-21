public with sharing class BillingLineSortOrderExtension {
    
    public List<AcctSeed__Billing_Line__c> lines {get; set;}
    private map<id, AcctSeed__Billing_Line__c> linesMap = new map<id, AcctSeed__Billing_Line__c>();
    public String jsonStr {get; set;}
    
    // sales order id is
    public id billId {get; set;}
    
    public acctseed__Billing__c billing {get; set;}
    
    public boolean visible {get{
        
        if(visible == null) visible = true;
        return visible;
        
    } set;}
    

    public Map<AcctSeed__Billing_Line__c, Integer> kits {get;set;}
    public List<List<AcctSeed__Billing_Line__c>> childrens {get;set;} 
    public List<AcctSeed__Billing_Line__c> kits_parents {get;set;} 
    public Boolean render_childs {get; set;}

    public BillingLineSortOrderExtension(ApexPages.StandardSetController ssc){
        lines = new List<AcctSeed__Billing_Line__c>();
        kits = new Map<AcctSeed__Billing_Line__c, Integer>();
        childrens = new List<List<AcctSeed__Billing_Line__c>>();
        kits_parents = new List<AcctSeed__Billing_Line__c>();

        billId = ApexPages.currentPage().getParameters().get('id');
        
        billing = [select name from acctseed__Billing__c where id=:billId];
        
        lines = [SELECT Id, Name, AcctSeed__Billing__c, AcctSeed__Comment__c, AcctSeed__Date__c, 
                 AcctSeed__Expense_GL_Account__c, AcctSeed__GL_Account_Variable_1__c, 
                 AcctSeed__Inventory_GL_Account__c, AcctSeed__Hours_Units__c, 
                 AcctSeed__List_Price__c, AcctSeed__Opportunity_Product_Id__c, 
                 AcctSeed__Product__c, AcctSeed__Product__r.name, AcctSeed__Project__c, AcctSeed__Rate__c, 
                 AcctSeed__Revenue_GL_Account__c,AcctSeed__Revenue_GL_Account__r.Name, AcctSeed__Total__c, Item_Description__c, 
                 Unit_Cost__c, Total_Price__c, Size__c, Quantity__c, Product_Code__c, sort_order__c 
                 FROM AcctSeed__Billing_Line__c 
                 where AcctSeed__Billing__c =: billId order by sort_order__c,name,createddate asc];
        getBillingLinesRenderWrapper(lines);
        render_childs = childrens.size() > 0 ? true : false;

        if(lines.isEmpty()){
            
		   ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL, 'No Products found.'));            
           visible = false; 
        }
    }

    public void getBillingLinesRenderWrapper(List<AcctSeed__Billing_Line__c> lines){

        Set<Id> all_kits_childrens = new Set<Id>();
        Map<Id, List<Id>> kit_relation = SalesOrderPDFController.getKitsRelation();
        for(Id kit:kit_relation.keySet()){
            all_kits_childrens.add(kit);
            for(Id chil: kit_relation.get(kit)){
                all_kits_childrens.add(chil);
            }
        }
        Map<Id, AcctSeed__Billing_Line__c> sol_map = new Map<Id, AcctSeed__Billing_Line__c>();
        List<AcctSeed__Billing_Line__c> not_kit_not_kitprod = new List<AcctSeed__Billing_Line__c>();

        Map<Id, List<Id>> current_so_relation = new Map<Id, List<Id>>();

        for(AcctSeed__Billing_Line__c sol: lines){
            sol_map.put(sol.AcctSeed__Product__c, sol); //Making map <ProductId, SalesOrderLine>

            //Sales Order can have not KIT and not KIT Product lines
            //We make another list with this items and will add to the end of pdf in code above
            if(!all_kits_childrens.contains(sol.AcctSeed__Product__c)){
                not_kit_not_kitprod.add(sol);
            }
        }


        for(Id bil: sol_map.keySet()){

            if(kit_relation.containsKey(bil)){
                current_so_relation.put(bil, new List<Id>());
                continue;
            }
            for(Id kit_r:kit_relation.keySet()){
                if(kit_relation.get(kit_r).contains(bil)){
                    if(current_so_relation.containsKey(kit_r)){
                        current_so_relation.get(kit_r).add(bil);
                    }else{
                        current_so_relation.put(kit_r, new List<Id>());
                    }
                }
            }

        }

        Integer index = 0;
        for(Id line: current_so_relation.keySet()){
            for(AcctSeed__Billing_Line__c l: lines){
                if(l.AcctSeed__Product__c == line){
                    kits.put(l, index);
                    kits_parents.add(l);
                }
            }
            index++;

        }

        for(Id line: current_so_relation.keySet()){
            List<AcctSeed__Billing_Line__c> childrens_k = new List<AcctSeed__Billing_Line__c>();
            for(Id child: current_so_relation.get(line)){
                for(AcctSeed__Billing_Line__c l: lines){
                    if(l.AcctSeed__Product__c == child){
                        childrens_k.add(l);
                    }
                }
            }
            childrens.add(childrens_k);
            
        }

        for(AcctSeed__Billing_Line__c not_kit:not_kit_not_kitprod){
            List<AcctSeed__Billing_Line__c> childrens_k = new List<AcctSeed__Billing_Line__c>();
            kits.put(not_kit, index);
            kits_parents.add(not_kit);
            childrens.add(childrens_k);
            index++;
        }
    }

    @RemoteAction
    public static void saveSorting(String json_sort, String billId){
        List<SortingWrapper> sortlist = (List<SortingWrapper>)JSON.deserialize(json_sort, List<SortingWrapper>.class);
        List<AcctSeed__Billing_Line__c> lines = [SELECT Id, Name, AcctSeed__Billing__c, AcctSeed__Comment__c, AcctSeed__Date__c, 
                                                AcctSeed__Expense_GL_Account__c, AcctSeed__GL_Account_Variable_1__c, 
                                                AcctSeed__Inventory_GL_Account__c, AcctSeed__Hours_Units__c, 
                                                AcctSeed__List_Price__c, AcctSeed__Opportunity_Product_Id__c, 
                                                AcctSeed__Product__c, AcctSeed__Product__r.name, AcctSeed__Project__c, AcctSeed__Rate__c, 
                                                AcctSeed__Revenue_GL_Account__c,AcctSeed__Revenue_GL_Account__r.Name, AcctSeed__Total__c, Item_Description__c, 
                                                Unit_Cost__c, Total_Price__c, Size__c, Quantity__c, Product_Code__c, sort_order__c 
                                                FROM AcctSeed__Billing_Line__c 
                                                where AcctSeed__Billing__c =: billId order by sort_order__c,name,createddate asc];
        List<AcctSeed__Billing_Line__c> for_update = new List<AcctSeed__Billing_Line__c>();
        Map<Id, AcctSeed__Billing_Line__c> bil_map = new Map<Id, AcctSeed__Billing_Line__c>(lines);
        for(SortingWrapper sw: sortlist){
            AcctSeed__Billing_Line__c line = bil_map.get(sw.solId);
            line.Sort_Order__c = sw.sortNumber;
            for_update.add(line);
        }
        update for_update;

    }

    public PageReference back(){
        
        PageReference page = new PageReference('/' + billid);
        page.setRedirect(true);
        
        return page;
        
    }
    public Pagereference createsort(){
        
        string obj = ApexPages.currentPage().getParameters().get('sortstring');
        
        if(obj.Length() > 0){
            
            // create a map of lines
            for(acctseed__billing_line__c line : lines){
                
                linesMap.put(line.id, line);
                
            }
            
            list<wrapper> sortlist = (list<wrapper>)JSON.deserialize(obj, list<Wrapper>.class);
            
            for(wrapper w : sortlist){
                // get the line from the map
                acctseed__billing_line__c line = linesMap.get(w.id);
                if(line == null) continue;
                
                line.Sort_Order__c = Decimal.valueOf(w.sorts);
            }
            
            list<acctseed__billing_line__c> linesUpdatables = new list<acctseed__billing_line__c>();
            
            linesUpdatables.addAll(linesMap.values());
            
            update linesUpdatables;
            
            Pagereference pr = new PageReference('/' + billId);
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
}