public class PurchaseOrderAutoReceiveController {
    
    public acctseederp__purchase_order__c po {get; set;}
    
    public PageReference PageAction(){
        
        po = new acctseederp__purchase_order__c();
        
        String POId = ApexPages.currentPage().getParameters().get('id');
        
        po = [select id, name, stage__c from acctseederp__purchase_order__c
                                                     where id =: POId limit 1];
        
        boolean HasInventoryProducts = false;
        
        // check if there are inventory products
        list<acctseederp__purchase_order_line__c> lines = [select acctseederp__product__r.acctseed__inventory_Product__c
                                                           from acctseederp__purchase_order_line__c where 
                                                           acctseederp__purchase_order__c =: po.id];
        
        PageReference page = new PageReference('/' + po.id);
        
        if(!lines.isEmpty()){
            for(acctseederp__purchase_order_line__c pol : lines){
                
                if(pol.acctseederp__product__r.acctseed__inventory_Product__c){
                    
                    HasInventoryProducts = true;
                }
            }
            
            if(HasInventoryProducts){
                page = new PageReference('/apex/AcctSeedERP__PurchaseOrderReceive?scontrolCaching=1&id=' + po.id);
            }else{
                // run the update to set to received stage and closed status
                
                
                po.Stage__c = 'Received';
                
                update po;
                
            }
        }else{
            
            return null;
        }
        
        page.setRedirect(true);
        return page;
    }
    
    public PageReference back(){
        PageReference page = new PageReference('/' + po.id);
        page.setRedirect(true);
        return page;
        
    }
}