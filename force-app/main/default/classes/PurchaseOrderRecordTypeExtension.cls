public class PurchaseOrderRecordTypeExtension {
    
    public List<string> stringList {get; set;}
    public transient List<RecordTypeInfo> recTypeInfo{get; set;}
    public List<SelectOption> options {get; set;}
    String GLVariable1 {get; set;}
    String retURL {get; set;}
    Public String selected {get;set;}
    public Set<ID> recTypeIDs {get; set;}
    public String POID {get; set;}
    public List<RecordType> filteredRecTypeList {get{
        return [select id, name, Description
                from RecordType
                where id in: recTypeIDs];
    } set; }
    
    public PurchaseOrderRecordTypeExtension(){
        GLVariable1 = ApexPages.currentPage().getParameters().get('GLVariable1');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        POID = ApexPages.currentPage().getParameters().get('POID');
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
        
        for(RecordTypeInfo info: AcctSeedERP__Purchase_Order__c.SObjectType.getDescribe().getRecordTypeInfos()) {
            if(info.isAvailable()) {
                recTypeInfo.add(info);
            }
        }
       
        if(GLVariable1 == 'Seawin Hong Kong'){
            for(RecordTypeInfo rec : recTypeInfo){
                if(rec.Name.contains('Seawin China') ){
                    options.add(new SelectOption(rec.getRecordTypeId(), rec.getName()));//Populate Seawin China for Hong Kong
                    
                    recTypeIDs.add(rec.getRecordTypeId());
                }
            }
        }else{ //When GLVariable1 = 'Seawin USA' OR 'Seawin China'
            for(RecordTypeInfo rec : recTypeInfo){
                if(rec.Name.contains(GLVariable1)){
                    options.add(new SelectOption(rec.getRecordTypeId(), rec.getName()));
                    recTypeIDs.add(rec.getRecordTypeId());
                }
            }
        }
        
        string soRecTypeName = ApexPages.currentPage().getParameters().get('recType');//It gets value when creating PO from SO
        string soRecTypeId = ApexPages.currentPage().getParameters().get('recTypeId');//It gets value when changing existing PO rec Type
       //Set Record Type to the PO Record Type
       //C1: if PO created from SO, set SO record Type on PO
       //C2: if PO record Type is changed, set PO existing rec Type value
       
        for(RecordTypeInfo rec : recTypeInfo){
            if(rec.getName() == soRecTypeName || rec.getRecordTypeId() == soRecTypeId){
                selected = rec.getRecordTypeId();
            }   
        }
    }
    
    public PageReference OnContinue(){
        
        PageReference page;
        String url;
        if(POID != null){
            System.debug('if');
            System.debug('selected: ' + selected);
            AcctSeedERP__Purchase_Order__c poRec = [select id, RecordTypeId from AcctSeedERP__Purchase_Order__c
                                                    where id =: POID];
            poRec.RecordTypeId = selected;
            update poRec;
            url = '/apex/PurchaseOrderPage?id='+POID+'&sfdc.override=1';
            
            page = new PageReference(url);
            
        }else{
            System.debug('else');
            String retURL2 = ApexPages.currentPage().getParameters().get('retURL');
            String SOID = ApexPages.currentPage().getParameters().get('soId');
            String GLAccVar1ID = ApexPages.currentPage().getParameters().get('glAccVar1Id');
            String RelatedOppID = ApexPages.currentPage().getParameters().get('relatedOppId');
            String ShippingAccID = ApexPages.currentPage().getParameters().get('shipngCompanyId');
            String ShippingContactID = ApexPages.currentPage().getParameters().get('shipngContactId');
            String ProjectID = ApexPages.currentPage().getParameters().get('projectId');
            String ShippingStreet = ApexPages.currentPage().getParameters().get('shpngStreet');
            String ShippingCity = ApexPages.currentPage().getParameters().get('shipngCity');
            String ShippingState = ApexPages.currentPage().getParameters().get('shipngStat');
            String ShippingPostalCode = ApexPages.currentPage().getParameters().get('shipngPostalCode');
            String ShippingCountry = ApexPages.currentPage().getParameters().get('shipngCountry');
            
            System.debug('SOID: ' + ApexPages.currentPage().getParameters().get('soId'));
            
            
            url = '/apex/AddPurchaseOrder?retURL='+retURL;
            url = url + '&RecordType='+selected;
            url = url + '&apex/AddPurchaseOrder?retURL=/'+retURL2;
            url = url + '&soId='+(SOID==null?'':SOID);
            url = url + '&glAccVar1Id='+(GLAccVar1ID==null?'':GLAccVar1ID);
            url = url + '&relatedOppId='+(RelatedOppID==null?'':RelatedOppID);
            url = url + '&projectId='+(ProjectID==null?'':ProjectID);
            url = url + '&shipngCompanyId='+(ShippingAccID==null?'':ShippingAccID);
            url = url + '&shipngContactId='+(ShippingContactID==null?'':ShippingContactID);
            url = url + '&shpngStreet='+(ShippingStreet==null?'':ShippingStreet);
            url = url + '&shipngCity='+(ShippingCity==null?'':ShippingCity);
            url = url + '&shipngStat='+(ShippingState==null?'':ShippingState);
            url = url + '&shipngPostalCode='+(ShippingPostalCode==null?'':ShippingPostalCode);
            url = url + '&shipngCountry='+(ShippingCountry==null?'':ShippingCountry);
            
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