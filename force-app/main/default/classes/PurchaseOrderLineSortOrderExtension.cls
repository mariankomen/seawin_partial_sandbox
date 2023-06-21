public with sharing class PurchaseOrderLineSortOrderExtension {

    public List<AcctSeedERP__Purchase_Order_Line__c> lines {get; set;}
    public List<AcctSeedERP__Purchase_Order_Line__c> restoreLines {get; set;}
    public List<SelectOption> lineslist {get; set;}
    public String selectedValue {get; set;}
    
    // directions
    public string top {get; set;}
    public string bottom {get; set;}
    public string up {get; set;}
    public string down {get; set;}
    
    // sales order id is
    public id poId {get; set;}
    
    public PurchaseOrderLineSortOrderExtension(ApexPages.StandardSetController ssc){
        lines = new List<AcctSeedERP__Purchase_Order_Line__c>();
        restoreLines = new List<AcctSeedERP__Purchase_Order_Line__c>();
        lineslist = new List<SelectOption>();
        
        poId = ApexPages.currentPage().getParameters().get('id');
        lines = [select id, name, sortordertemp__c, sort_order__c from AcctSeedERP__Purchase_Order_Line__c where AcctSeedERP__Purchase_Order__c =: poId order by sort_order__c asc];
        
        // so we can restore the default sortorder
        restoreLines = lines;

        for(AcctSeedERP__Purchase_Order_Line__c pol : lines){
            lineslist.add(new SelectOption(pol.id, pol.name));
        }
    }

    public List<AcctSeedERP__Purchase_Order_Line__c> TopBottom(String str, List<AcctSeedERP__Purchase_Order_Line__c> lines, String direction, Integer minSort, Integer maxSort){
        
        Integer counter = 1;
        integer currentPos = 0;
        Integer mincount = 1;
        
        for(AcctSeedERP__Purchase_Order_Line__c lineitem : lines){
            if(str == lineitem.id) currentPos = mincount;
            mincount++;
        }
        
        for(AcctSeedERP__Purchase_Order_Line__c line : lines){
            
            if(line.sortordertemp__c == null) line.sortordertemp__c = 0;
            
			Integer atExtreme = (direction == 'top') ? maxSort : minSort;
            Integer allOthers = (direction == 'top') ? ( counter + 1 ) : ( counter - 1);
            line.sortordertemp__c = (counter == currentPos) ? atExtreme : allOthers;
                
            counter++;
        }
        return lines;
    }
    public void InitSort(string str, string direction){
        lines = [select id, name, sortordertemp__c, sort_order__c from AcctSeedERP__Purchase_Order_Line__c where AcctSeedERP__Purchase_Order__c =: poId order by SortOrderTemp__c asc];
        AcctSeedERP__Purchase_Order_Line__c lineone = [select sortordertemp__c, sort_order__c from AcctSeedERP__Purchase_Order_Line__c where id =: str];
        
        Integer minSort = lines.size();
        Integer maxSort = lines.size() - (lines.size() - 1);
        Integer counter = 1;
        integer currentPos = 0;
        Integer mincount = 1;
        
        for(AcctSeedERP__Purchase_Order_Line__c lineitem : lines){
            if(str == lineitem.id) currentPos = mincount;
            mincount++;
        }
        
        for(AcctSeedERP__Purchase_Order_Line__c line : lines){
            if(line.sortordertemp__c == null) line.sortordertemp__c = 0;
            if(direction == 'up'){
                if(counter == currentPos){
                    line.sortordertemp__c = currentPos - 1;
                }else if(counter == (currentPos - 1)){
                    line.sortordertemp__c = currentPos;
                }else{
                    line.sortordertemp__c = counter; 
                }
                counter++;
            }else if(direction == 'down'){
                if(counter == currentPos){
                    line.sortordertemp__c = currentPos + 1;
                }else if(counter == (currentPos + 1)){
                    line.sortordertemp__c = currentPos;
                }else{
                    line.sortordertemp__c = counter; 
                }
                counter++;
            }else if(direction == 'top' || direction == 'bottom'){
                
                lines = TopBottom(str, lines, direction, minSort, maxSort); 
            }
        }
        
        update lines;
        
        counter = 1;
        
        lines = [select id, name from AcctSeedERP__Purchase_Order_Line__c where AcctSeedERP__Purchase_Order__c =: poId order by sortordertemp__c asc];
        
        lineslist.clear();
        
        for(AcctSeedERP__Purchase_Order_Line__c pol : lines){
            lineslist.add(new SelectOption(pol.id, pol.name));
        }
    }
    
    public PageReference moveUp(){
        
        if(selectedValue != null && up != null){
            InitSort(selectedValue, up);
        }
        return null;
        
    }
    public PageReference moveDown(){
        
        if(selectedValue != null && down != null){
            InitSort(selectedValue, down);
        }
        return null;
        
    }
    public PageReference moveTop(){
        if(selectedValue != null && top != null){
            InitSort(selectedValue, top);
        }
        return null;
        
    }
    public PageReference moveBottom(){
        if(selectedValue != null && bottom != null){
            InitSort(selectedValue, bottom);
        }
        
        return null;
    }
    public PageReference restoreDefauts(){
        
        if(!restoreLines.isEmpty()){
            
             for(AcctSeedERP__Purchase_Order_Line__c line : restoreLines){
                
                line.SortOrderTemp__c = null;
                
            }
            
            update restoreLines;
        }
        return new PageReference('/' + poId);
        
    }
    public PageReference saveWork(){
        
        lines = [select id, name, sortordertemp__c, sort_order__c from AcctSeedERP__Purchase_Order_Line__c where AcctSeedERP__Purchase_Order__c =: poId order by sort_order__c asc];
        
        if(!lines.isEmpty()){
            for(AcctSeedERP__Purchase_Order_Line__c line : lines){
                
                line.sort_order__c = line.SortOrderTemp__c;
                
            }
            
            update lines;
        }
        
        return new PageReference('/' + poId);
    }
}