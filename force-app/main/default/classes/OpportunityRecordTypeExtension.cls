public class OpportunityRecordTypeExtension {
	
    public List<string> stringList {get; set;}
    //public List<RecordType> recordTypList{get; set; }
    public transient List<RecordTypeInfo> recTypeInfo{get; set;}
    public List<SelectOption> options {get; set;}
    String GLVariable1 {get; set;}
    String retURL {get; set;}
    Public String selected {get;set;}
    public Set<ID> recTypeIDs {get; set;}
    public String OppID{get; set;}
    public String acctId{get; set;}
    public List<RecordType> filteredRecTypeList {get{
        return [select id, name, Description
                from RecordType
                where id in: recTypeIDs];
    } set; }
   
    public OpportunityRecordTypeExtension(){
        GLVariable1 = ApexPages.currentPage().getParameters().get('GLVariable1');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        acctId = ApexPages.currentPage().getParameters().get('id');
        OppID = ApexPages.currentPage().getParameters().get('OppID');
        filteredRecTypeList = new List<RecordType>();
        options = new List<SelectOption>();
        stringList  = new list<string>();
        recTypeIDs = new Set<ID>();
        RecordTypesGet();
        
    }
        
    public void RecordTypesGet(){
        
        options = new List<Selectoption>();
        //recordTypList = new List<RecordType>();
        recTypeInfo = new List<RecordTypeInfo>();
        
        for(RecordTypeInfo info: Opportunity.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(info.isAvailable()) {
                System.debug('info: ' + info);
                recTypeInfo.add(info);
            }
        }
        
        //recordTypList = [select id,name,Description from RecordType 
                         //where SobjectType = 'Opportunity' and IsActive = true];
        
        if(GLVariable1 == 'Seawin Hong Kong'){
            for(RecordTypeInfo rec : recTypeInfo){
                if(rec.Name.contains('Seawin China') && rec.Name != 'Master'){
                    options.add(new SelectOption(rec.getRecordTypeId(), rec.getName()));//Populate Seawin China for Hong Kong
                    recTypeIDs.add(rec.getRecordTypeId());
                }
            }
        }else{ //When GLVariable1 = 'Seawin USA' OR 'Seawin China'
            for(RecordTypeInfo rec : recTypeInfo){
                if(rec.Name.contains(GLVariable1) && rec.Name != 'Master'){
                    options.add(new SelectOption(rec.getRecordTypeId(), rec.getName()));
                    recTypeIDs.add(rec.getRecordTypeId());
                }
            }
        }
    }
    
    public PageReference OnContinue(){
        
        PageReference page;
        String url;
        if(OppID != null){
            
            url = '/'+OppID+'/e?nooverride=1&RecordType='+selected;
            url = url + '&retURL=/apex/OpportunityPage?id='+OppID;
            page = new PageReference(url);
            
        }else{

            url = '/apex/OpportunitySalesRepPage?id='+acctId+'&retURL='+retURL+'&RecordType='+selected;
            page = new PageReference(url);
        }
       
        page.setRedirect(true);
        return page;
    }
    
    public PageReference Cancel(){
        PageReference page = new PageReference(retURL);
        page.setRedirect(true);
        return page;
    }
    
}