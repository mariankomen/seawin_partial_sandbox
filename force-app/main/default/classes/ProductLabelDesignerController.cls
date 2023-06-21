public class ProductLabelDesignerController {
    
    public String returnId {get; set;}
    public PO_Shipment__c shipmnt{get; set;}
    public List<Wrapper> wrapperList {get; set;}
    public Boolean AllowCreate {get; set;}
    public Boolean showError {get; set;}
    public List<string> ProductNames {get; set;}
    public set<id> SelectedLineIds {get; set;}
    public map<string, id> GetProductIdMapForLinkMap {get; set;}
    public map<string, string> BackupTemplateMap {get; set;}
    public string shipmntId {get; set;}
    public Boolean NotSelected {get; set;}
    
    public List<SelectOption> getTemplates() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Choose Template'));
        options.add(new SelectOption('Glass Label Template','Glass Label Template'));
        options.add(new SelectOption('Hardware Label Template','Hardware Label Template'));
        
        return options;  
    }
    
    public ProductLabelDesignerController(){
        
        wrapperList = new List<Wrapper>();
        AllowCreate = false;
        showError = false;
        NotSelected = false;
        SelectedLineIds = new set<id>();
        ProductNames = new List<String>();
        GetProductIdMapForLinkMap = new map<string, id>();
        BackupTemplateMap = new map<string, string>();
        
        returnId = ApexPages.currentPage().getParameters().get('shipmnt');
        shipmntId = ApexPages.currentPage().getParameters().get('shipmnt');
        
        shipmnt = [SELECT Id, Name 
                   FROM PO_Shipment__c where Id =:returnId Limit 1];
        
        Product2 prod = new Product2();
        
        List<PO_Shipment_Line__c> lines = [select id, name, PO_Shipment__c,
                                           Product__c,
                                           Product_Code__c,Description__c,Size__c,
                                           Total_Price__c,Quantity_Shipped__c,
                                           Product__r.Name,
                                           Product__r.Series__c,
                                           Product__r.size__c,
                                           Product__r.Glass__c,
                                           Product__r.Glass_Thickness__c,
                                           Product__r.Direction__c,
                                           Product__r.Description,
                                           Product__r.Hardware_Finish__c,
                                           Product__r.ProductCode
                                           from PO_Shipment_Line__c
                                           where PO_Shipment__c =: shipmnt.Id];
      
        if(!lines.isEmpty()){
            AllowCreate = true;
            for(PO_Shipment_Line__c l : lines){
                Wrapper w = new Wrapper(l, null, false);
                wrapperList.add(w);
            }
        }
    }
    
    public List<Wrapper> ReBuildProducts(){
        
        List<Wrapper> wrapperListRebuild = new List<Wrapper>();
        
        List<PO_Shipment_Line__c> lines = [select id, name, PO_Shipment__c,
                                           Product__c,
                                           Product_Code__c,Description__c,Size__c,
                                           Total_Price__c,
                                           Product__r.Name,
                                           Product__r.Series__c,
                                           Product__r.size__c,
                                           Product__r.Glass__c,
                                           Product__r.Glass_Thickness__c,
                                           Product__r.Direction__c,
                                           Product__r.Description,
                                           Product__r.Hardware_Finish__c,
                                           Product__r.ProductCode,LastModifiedDate
                                           from PO_Shipment_Line__c where
                                           id in:SelectedLineIds];
        
        if(!Lines.isEmpty()){
            
            AllowCreate = true;
            
            for(PO_Shipment_Line__c l : Lines){
                
                String template = BackupTemplateMap.get(l.Product__r.name);
                
                Wrapper w = new Wrapper(l, template, true);
                
                wrapperListRebuild.add(w);
            }
        }
        
        return wrapperListRebuild;
    }
    
    public PageReference saveLabel(){
        
        showError = false;
        NotSelected = true;
        GetProductIdMapForLinkMap = new map<string, id>();
        SelectedLineIds = new set<id>();
        BackupTemplateMap = new map<string, string>();
        ProductNames = new List<String>();
        
        for(Wrapper w : wrapperList){
            if(w.selected){
                SelectedLineIds.add(w.line.id);
                NotSelected = false;
                if(w.selectedTemplate == null){
                    showError = true;
                    break;
                }
            }
        }
        
        if(!NotSelected){
            List<Attachment> attachmentList = new List<Attachment>();
            Map<Id, String> idsList = new Map<Id, String>();
            String ss='';
            for(Wrapper wl : wrapperList){
                if(wl.selectedTemplate == 'Glass Label Template'){
                    ss = ss + wl.line.Id + ':' + wl.selectedTemplate + ',';
                    idsList.put(wl.line.Id, wl.selectedTemplate);
                }
                else if(wl.selectedTemplate == 'Hardware Label Template'){
                    ss = ss + wl.line.Id + ':' + wl.selectedTemplate + ',';        
                    idsList.put(wl.line.Id, wl.selectedTemplate);
                }
            }
            
            PageReference page = new PageReference('/apex/labelTemplatePage?data='+ss);
            page.setRedirect(true);            
            return page;
        }
        
        return null;
    }
    
    public PageReference refreshPage(){
        
        showError = false;
        
        return null;
        
    }
    
    public PageReference BackButton(){
        
        PageReference page = new PageReference('/'+returnId); 
        page.setRedirect(true);
        
        return page;
    }
    
    Public class Wrapper{
        
        public PO_Shipment_Line__c line {get; set;}
        public string selectedTemplate {get; set;}
        public Boolean selected {get; set;}
        
        public Wrapper(PO_Shipment_Line__c l, string t, boolean s){
            
            line = l;
            selectedTemplate = t;
            selected = s;
        }
    }
}