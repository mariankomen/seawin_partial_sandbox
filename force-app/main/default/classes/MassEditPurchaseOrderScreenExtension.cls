public with sharing class MassEditPurchaseOrderScreenExtension {
    
    public String poId {get; set;}
    public String polId {get; set;}
    public AcctSeedERP__Purchase_Order__c po {get; set;}
    public AcctSeedERP__Purchase_Order_Line__c pol {get; set;}
    public List<AcctSeedERP__Purchase_Order_Line__c> lines {get; set;}
    
    public boolean visible {get; set;}
    
    public Boolean LasttoDelete {get{
        
        if(lasttodelete == null) lasttodelete = false; return lasttodelete;
        
    } set;}
    
    
    public MassEditPurchaseOrderScreenExtension(ApexPages.StandardSetController std){
        
        visible = true;
        poId = ApexPages.currentPage().getParameters().get('id');
        
        if(poId != null){
            
            po = [SELECT Id,name,AcctSeedERP__Status__c, AcctSeedERP__Order_date__c, 
                  AcctSeedERP__type__c FROM AcctSeedERP__Purchase_Order__c where id=:poId];
            
            lines = [SELECT Id, Name, AcctSeedERP__Purchase_Order__c, Description__c, 
                     AcctSeedERP__Quantity__c, AcctSeedERP__Quantity_Received__c,Quantity_Received_Formula__c,Quantity_Unreceived_Formula__c,Purchase_Price__c,
                     AcctSeedERP__Quantity_Unreceived__c,AcctSeedERP__Product__r.name,AcctSeedERP__Product__r.Allow_Product_Description_Change__c, Product_Code__c, 
                     Size__c,AcctSeedERP__Total__c, AcctSeedERP__Unit_Price__c, sort_order__c
                     FROM AcctSeedERP__Purchase_Order_Line__c where AcctSeedERP__Purchase_Order__c =:poId 
                     order by sort_order__c,name,createddate asc];
            
            if(lines.IsEmpty()){
                visible = false;
                ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.ERROR,
                    'No Products found.'));
            }
            
        }
        
    }
    public PageReference UpdateLine(){
        
        update lines;
        
        PageReference page = new PageReference('/' + poId);
        page.setRedirect(true);
        return page;
    }
    public PageReference TrashIt(){
        
        polId = ApexPages.currentPage().getParameters().get('polId');
        
        if(polid != null){
            
            // check if there are lines left
            List<AcctSeedERP__Purchase_Order_Line__c> leftLines = [SELECT Id FROM AcctSeedERP__Purchase_Order_Line__c 
                                                                   where AcctSeedERP__Purchase_Order__c =:poId and id != :polid];
            
            if(leftLines.IsEmpty()){
                // show warning that just one line left
                LasttoDelete = true;
                ApexPages.addmessage(new ApexPages.message(
                    ApexPages.severity.WARNING,'Are you sure you want to delete.'));
                return null;                
            }
            
            
            
            // delete
            AcctSeedERP__Purchase_Order_Line__c pols = [SELECT Id FROM AcctSeedERP__purchase_Order_Line__c where id =:polid]; 
            delete pols;
            
            
            
            // String pageVal  = ApexPages.currentPage().getURL();
            String hostVal  = ApexPages.currentPage().getHeaders().get('Host');
            system.debug('the url to redirect to is: ');
            system.debug(hostVal + '/apex/MassEditSalesOrderScreenPage?id='+poId);
            // redirect
            PageReference page = new PageReference('https://' + hostVal + '/apex/MassEditPurchaseOrderScreenPage?id='+poId); 
            Page.setRedirect(true);
            return page;
            
        }
        
        return null;
    }
    public PageReference yes(){
        // delete
        AcctSeedERP__Purchase_Order_Line__c pols = [SELECT Id FROM AcctSeedERP__Purchase_Order_Line__c where id =:polid]; 
        delete pols;
        
        PageReference page = new PageReference('/' + poId);
        page.setRedirect(true);
        return page;
    }
    public PageReference no(){
        LasttoDelete = false;
        return null;
    }
    public PageReference back(){
        
        PageReference page = new PageReference('/' + poId);
        page.setRedirect(true);
        return page;
    }
}