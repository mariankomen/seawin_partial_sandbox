public class ManufactureInvntryMovmntLabelController {
        
    public String invQtyAvailableID {get; set;}
    public Boolean NotSelected {get; set;}
    public Boolean AllowCreate {get; set;}
    public List<Wrapper> wrapperList {get; set;}
    public Boolean showError {get; set;}
    public set<id> SelectedLineIds {get; set;}  
    
    public List<SelectOption> getTemplates() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Choose Template'));
        options.add(new SelectOption('Glass Label Template','Glass Label Template'));
        options.add(new SelectOption('Hardware Label Template','Hardware Label Template'));
        
        return options;  
    }
        
    public ManufactureInvntryMovmntLabelController(){    
        
        NotSelected = false;
        AllowCreate = false;
        showError = false;
        wrapperList = new List<Wrapper>();
        SelectedLineIds = new set<id>();
        
        invQtyAvailableID = ApexPages.currentPage().getParameters().get('parent');
        
        AcctSeedERP__Inventory_Balance__c invQtyAvailable = [select id 
                                                             from AcctSeedERP__Inventory_Balance__c
                                                             where id =: invQtyAvailableID limit 1];
        
        List<AcctSeedERP__Manufacturing_Inventory_Movement__c> movements =  
            [select id, AcctSeedERP__Product__c, AcctSeedERP__Quantity__c,
             AcctSeedERP__Inventory_Balance__r.AcctSeedERP__Product__r.ProductCode           
             from AcctSeedERP__Manufacturing_Inventory_Movement__c
             where AcctSeedERP__Inventory_Balance__c =: invQtyAvailable.Id];
        
        if(!movements.isEmpty()){
            AllowCreate = true;
            for(AcctSeedERP__Manufacturing_Inventory_Movement__c m : movements){
                Wrapper w = new Wrapper(m, null, false);
                wrapperList.add(w);
            }
        }
        
    }
    
    
    public PageReference saveLabel(){
        
        NotSelected = true;
        SelectedLineIds = new set<id>();
        showError = false; 
        
        for(Wrapper w : wrapperList){
            System.debug('w is: ' + w);
            if(w.selected){
                SelectedLineIds.add(w.movement.id);
                NotSelected = false;
                if(w.selectedTemplate == null){
                    showError = true;
                    break;
                }
            }
        }
        
        if(!NotSelected & !showError){           
            Map<Id, String> idsList = new Map<Id, String>();
            String data = '';
            for(Wrapper wl : wrapperList){
                if(wl.selectedTemplate == 'Glass Label Template'){
                    data = data + wl.movement.Id + ':' + wl.selectedTemplate + ',';
                    idsList.put(wl.movement.Id, wl.selectedTemplate);
                }
                else if(wl.selectedTemplate == 'Hardware Label Template'){
                    data = data + wl.movement.Id + ':' + wl.selectedTemplate + ',';        
                    idsList.put(wl.movement.Id, wl.selectedTemplate);
                }
            }
            
            System.debug('idsList: ' + idsList);
            PageReference page = new PageReference('/apex/ManufcturInvntryMovmntLablTmpltePage?data='+data);
            page.setRedirect(true);            
            return page;
        }
        
        
        return null;
        
    }
    
    public PageReference BackButton(){
        
        PageReference page = new PageReference('/'+invQtyAvailableID); 
        page.setRedirect(true);
        
        return page;
    }
    
    public PageReference refreshPage(){
        
        showError = false;
        
        return null;
        
    }
    
    
    Public class Wrapper{
        
        public AcctSeedERP__Manufacturing_Inventory_Movement__c movement {get; set;}
        public string selectedTemplate {get; set;}
        public Boolean selected {get; set;}
        
        public Wrapper(AcctSeedERP__Manufacturing_Inventory_Movement__c m, string t, boolean s){
            
            movement = m;
            selectedTemplate = t;
            selected = s;
        }
    }
    
}