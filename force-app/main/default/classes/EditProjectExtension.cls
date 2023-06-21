public class EditProjectExtension {
    
    public Id projectId {get; set;}
    public AcctSeed__Project__c project {get; set;}
    public string retUrl {get; set;}
    
    public EditProjectExtension(ApexPages.StandardController std){
        
        projectId = (Id)std.getId();
        
        project = new AcctSeed__Project__c();
        
        retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        
        project = [SELECT Id, Name, OwnerId, CreatedDate,Project_Date__c, Project_Manager__c,
                    Lien__c, 
                   AcctSeed__Account__c,Note__c,
                   Barn_Doors_ETA__c,
                    LED_Mirrors_ETA__c,
                    Shower_Bases_ETA__c,
                    Shower_Doors_ETA__c,
                    Wall_Surrounds_ETA__c,
                   Mockup_ETA__c,
                   AcctSeed__Status__c, Contact__c, LastModifiedById, 
                   LastModifiedDate, CreatedById FROM AcctSeed__Project__c
                   where id =:projectId limit 1];

    }
    
    public PageReference saveRecord(){
        
        // check if there is no account and no contact provided
        if(Project.AcctSeed__Account__c == null && Project.Contact__c == null){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                       'Atleast an account or a contact is required for a project.'));
            return null;
        }
		
        Boolean OpportunityClosed = true;
        Boolean SalesOrdersClosed = true;
        Boolean PurchaseOrdersClosed = true;
        // check if the status has been changed
        if(project.AcctSeed__Status__c == 'Closed'){
            
            //Method below check does project is available for closing
            Boolean status = ProjectAutomaticalyClose.checkIfSingleProjectIsAvailableForClosing(project.Id);
            
            if(status == false){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
                'Project can not be closed because related Sales Order(s) or Opportunity(s) or Purchase Order(s) are still open.'));

                return null;
            }
            
        }
        
        try{

            update project;
            
        }catch(Exception ex){
            system.debug(ex.getMessage());
        }
        
        
        PageReference page = new PageReference('/' + projectId);
        
        if(retUrl != ''){
            
            page = new pageReference(retUrl);
        }
        
        return page;
    }
    
    public PageReference cancelOperation(){
        
        PageReference page = new PageReference('/' + projectId);
        
        if(retUrl != ''){
            
            page = new pageReference(retUrl);
        }
        
        return page;
    }
}