public class OptionalProductOppDeleteExtension {
    
    public id opId {get; set;}
    public boolean showApprovalMsg {get; set;}
    public optional_products_opportunity__c optionalOLI {get; set;}
    public boolean hasBilling {get; set; }
    public boolean hasSO {get; set; }
    
    public OptionalProductOppDeleteExtension(ApexPages.standardcontroller std){
        
        Id LineId = (id)std.getId();
        showApprovalMsg = false;
        hasBilling = false;
        hasSO = false;
        
        optionalOLI = new optional_products_opportunity__c();
        
        optionalOLI = [select id, opportunity__c, Opportunity__r.Sent_For_Approval__c,
                       Opportunity__r.TotalBills__c,Opportunity__r.TotalSalesOrderInOpp__c
                       from optional_products_opportunity__c 
                       where id =: LineId limit 1];
        
        User usr = [select Alias from User where  id =: UserInfo.getUserId() limit 1];
        
        if(optionalOLI.Opportunity__r.Sent_For_Approval__c && 
           usr.Alias != 'gshilman' && usr.Alias != 'mashr'){
               
               showApprovalMsg = true;
           }
        
        opId = optionalOLI.Opportunity__c;
    }
    public PageReference PageAction(){
        
        if(optionalOLI.Opportunity__r.TotalSalesOrderInOpp__c > 0){
            hasSO = true;            
        }
        
        PageReference page = new Pagereference('/'+opId); 
        page.setRedirect(true);
        System.debug('hasSO: ' + hasSO);
        System.debug('showApprovalMsg: '+ showApprovalMsg);
        
        if(!showApprovalMsg){ // if the opportunity is not in approval
            if(!hasSO){
                try{
                    delete optionalOLI;  
                    
                }catch(Exception ex){

                }  
                
                return page;
            }
        }
        
        return null;
    }
    public PageReference back(){
        PageReference page = new Pagereference('/'+opId); 
        page.setRedirect(true);
        
        return page;
        
    }
}