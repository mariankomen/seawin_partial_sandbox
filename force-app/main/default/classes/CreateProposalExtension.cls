public class CreateProposalExtension {
    
    public Quote qt {get; set;}
    public Boolean hasBlobs {get; set;}
    public Boolean MissingCase {get; set;}
    public Boolean CreateAnyway {get; set;}
    public Boolean EnforceDeveloperMode {get; set;}
    
    public boolean ProposalHasError {get; set;}
    public boolean QuotaHasExceeded {get; set;}
    public boolean ErrorHasOccured {get; set;}
    public boolean ErrorEncrypted {get; set;}
    
    public string username {get; set;}
    public string password {get; set;}
    public Boolean isTest {get; set;}
    public string url {get; set;}
    public transient list<string> blobs64 {get; set;}
    public transient map<string, string> Base64Map {get; set;}
    public set<string> BlobKeys {get; set;}
    
    public set<id> missingIds {get; set;}
    public map<id, string> missingMap {get; set;}
    
    public set<id> ProblemIds {get; set;}
    public map<id, string> ProblemMap {get; set;}

    public string Org {get; set;}
    public string WithSpecs {get; set;}
    
    public CreateProposalExtension(apexpages.StandardController std){
        
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1][0].IsSandbox;
        
        Boolean isDeveloper = [select Id, Salesforce_Developer__c 
                  from User where Id=:UserInfo.getUserId() Limit 1][0].Salesforce_Developer__c;
        
        isTest = isSandbox ? true : isDeveloper;
        
        list<string> fieldNames = new list<string>{'name'}; 
        
        if(!Test.isRunningTest()) std.addFields(fieldNames);
        
        String isContinueStr = ApexPages.currentPage().getParameters().get('isContinue');
        WithSpecs = ApexPages.currentPage().getParameters().get('specs');
        Org = ApexPages.currentPage().getParameters().get('org');
        
        if(isContinueStr == null) isContinueStr = 'false';
        
        Boolean isContinue = Boolean.ValueOf(isContinueStr);
        
        ProposalHasError = false;
        QuotaHasExceeded = false;
        ErrorHasOccured = false;
        
        
        qt = (Quote)std.getRecord();
        
        username = '9c1ca8fb-813e-4ed7-970f-42188962713f';
        password = '4RKxwJo4QB1YnyjN';
        //IsTest = false;
        hasBlobs = false;
        MissingCase = false;
        url = 'https://www.hypdf.com/pdfunite';
        blobs64 = new list<string>();
        CreateAnyway = false;
        
        missingIds = new set<id>();
        missingMap = new map<id, string>();
        
        ProblemIds = new set<id>();
        ProblemMap = new map<id, string>();
        
        //try{
            
            list<quotelineitem> quoteli = [select sortorder, product2id, product2.name,product2.category__c,
                                           product2.technical_specs_Id__c,createddate from quotelineitem
                                           where QuoteId =:qt.id order by sortorder,
                                           product2.name,createddate asc];
            
            if(quoteli.IsEmpty()){
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
                                                           'No Products (Quote Line Items) found.'));
                MissingCase = true;
                
            }else{
                
                
                
                // check if the quote pdf has been created
                list<quotedocument> QuoteDocument = [select id, document from quotedocument where
                                                     quoteId =:qt.id order by createddate desc limit 1];
                
                if(QuoteDocument.isEmpty() & !Test.isRunningTest()){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
                                                               'No Quote PDF found. Please first create Quote PDF by '+ 
                                                               'clicking the button "Create PDF" on the Quote.'));
                    MissingCase = true;
                }else{
                    // Check if the Proposal PDF exists
                    List<StaticResource> ProposalPDFId = new List<StaticResource>();

                    List<StaticResource> PastProjectsPDF = new List<StaticResource>();

                    if(Org == 'Seawin USA'){
                        ProposalPDFId = [SELECT Id, Body FROM StaticResource WHERE Name = 'new_proposal_usa' LIMIT 1];
                        //String body = sr.Body;
                        //ProposalPDFId = [select id from contentdocument where 
                                                           //title = 'new-proposal' limit 1];
                    }else{
                        ProposalPDFId = [SELECT Id, Body FROM StaticResource WHERE Name = 'new_proposal_china' LIMIT 1];
                        //ProposalPDFId = [select id from contentdocument where 
                                                           //title = 'new-proposal-china' limit 1];
                    }
                    
                    if(ProposalPDFId.IsEmpty()){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
                                                                   'No Proposal PDF found. Please upload Proposal PDF as Static Resource.'));
                        MissingCase = true;
                    }else{

                        PastProjectsPDF = [SELECT Id, Body FROM StaticResource WHERE Name = 'new_proposal_projects' LIMIT 1];
                        
                        // get the static pages from files link
                        //list<contentversion> ProposalPDF = [SELECT VersionData FROM ContentVersion WHERE 
                                                            //ContentDocumentId =: ProposalPDFId[0].id AND IsLatest = true];
                        Boolean noLink = false;
                        
                        //map<id, id> TechIdsMap = new map<id, id>();
                        //set<string> TechIds = new set<string>();
                        map<string, string> Order_of_Map = new map<string, string>();
                        map<string, string> Tech_Links_Map = new map<string, string>();
                        map<string, string> Tech_Ids_Map = new map<string, string>();

                        if(WithSpecs == 'yes'){

                            for(quotelineitem qtl : quoteli){
                                
                                if(qtl.product2.technical_specs_Id__c != null){
                                    if(qtl.product2.technical_specs_Id__c.CONTAINS('.')){ // its a link
                                        Tech_Links_Map.put(qtl.product2.technical_specs_Id__c,
                                                        qtl.product2.technical_specs_Id__c);
                                    }else{ // else its an id
                                        Tech_Ids_Map.put(qtl.product2.technical_specs_Id__c,
                                                        qtl.product2.technical_specs_Id__c);
                                    }
                                    Order_of_Map.put(qtl.product2.technical_specs_Id__c, 
                                                    qtl.product2.technical_specs_Id__c);
                                }else{
                                    
                                    missingIds.add(qtl.product2id);
                                    missingMap.put(qtl.product2id, qtl.product2.name);
                                    
                                    noLink = true;
                                }
                            }
                        }
                        
                        // -------------- Get the front page-----------
                        
                        PageReference ProposalPage = null;

                        if(Org == 'Seawin USA'){
                            ProposalPage = Page.SeawinProposalPage;
                        }else{
                            ProposalPage = Page.SeawinChinaProposalPage;
                        }
                        
                        ProposalPage.getParameters().put('quoteid', qt.id);
                        
                        Blob PagePdf;
                        try {
                            PagePdf = ProposalPage.getContentAsPDF();
                        }
                        catch (Exception e) {
                            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
                                                                       'The front page for the PDF could not be retrieved. Please retry.'));
                        }
                        
                        if(PagePdf == null && Test.isRunningTest()){
                            
                            PagePdf = EncodingUtil.base64Decode('test');
                        }
                        
                        // --------------
                        
                        // ----- Uncomment to create proposal without Technical Specs PDFs
                        
                        // list<blob> blobs = new list<blob>();
                        // blobs.add(PagePdf);
                        // blobs.add(ProposalPDF[0].VersionData);
                        // if(!Test.isRunningTest()){ blobs.add(quoteDocument[0].document); }

                        // if(!blobs.isEmpty()){
                        // hasBlobs = true;
                        // INteger i = 1;
                        // for(blob b : blobs){
                        // string newStr = EncodingUtil.base64Encode(b);
                        // blobs64.add(newStr);
                        // i++;
                        // }
                        // }
                        
                        // ------- Comment out this part to only create proposal without Technical Specs PDF
                        if(noLink && !isContinue){

                            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
                                                                       'The following Product(s) are missing their '+ 
                                                                       'Techincal Specs PDF. <br/><br/><b>1.</b> Please upload each '+ 
                                                                       'Product\'s Technical Specs PDF to '+ 
                                                                       '<a target="_blank" '+
                                                                       'style="font-size:100%; font-weight: bold; '+
                                                                       'margin: 0 3px;" '+
                                                                       'href="/_ui/core/chatter/files/FileTabPage">'+
                                                                       'Files</a><br/><b>2.</b> Then copy the 15-digit Id from the '+ 
                                                                       'uploaded file\'s URL and paste it to the '+ 
                                                                       '"Technical Specs Link" field on the respective '+
                                                                       'Product(s). <br/><b>3.</b> In case its a link then enter a link in the field.'));
                            MissingCase = true;
                            CreateAnyway = true;
                        }else{
                            
                            map<string, blob> BlobsMap = new map<string, blob>();
                            
                            list<blob> blobs = new list<blob>();
                            
                            //blobs.add(PagePdf);
                            //blobs.add(ProposalPDF[0].VersionData);
                            //if(!Test.isRunningTest()){ blobs.add(quoteDocument[0].document); }
                            
                            blobs64.add(EncodingUtil.base64Encode(PagePdf));
                            if(!ProposalPDFId.isEmpty()) blobs64.add(EncodingUtil.base64Encode(ProposalPDFId[0].Body));
                            if(!PastProjectsPDF.isEmpty()) blobs64.add(EncodingUtil.base64Encode(PastProjectsPDF[0].Body));
                            if(!Test.isRunningTest()){ 
                                blobs64.add(EncodingUtil.base64Encode(quoteDocument[0].document)); }
                            
                            if(Tech_Ids_Map.size() > 0){
                                
                                map<id, blob> ctverMap = new map<id, blob>();
                                
                                for(contentversion ctver : [select versiondata,contentdocumentid from 
                                                            contentversion where contentdocumentid 
                                                            in:Tech_Ids_Map.Keyset()]){
                                                                
                                                                ctverMap.put(ctver.contentdocumentid, ctver.versiondata);
                                                            }
                                
                                if(ctverMap.size() > 0){
                                    for(string docId : Tech_Ids_Map.keyset()){

                                        docId = docId.left(15);
                                        
                                        blob vdata = ctverMap.get(docId);
                                        
                                        if(vdata == null) continue;
                                        BlobsMap.put(docId, vdata);
                                        // blobs.add(vdata);
                                    }
                                }
                            }
                            
                            httprequest req = new HttpRequest();
                            Http sent = new Http();
                            HttpResponse res = new HttpResponse();
                            
                            if(Tech_Links_Map.size() > 0){
                                
                                // first create remote settings for the new urls
                                MetadataServiceUtility.createRemoteSiteSettings(Tech_Links_Map.keySet());

                                for(String endpoint : Tech_Links_Map.keySet()){
                                    
                                    // get the blob from each link
                                    req = new HttpRequest();
                                    sent = new Http();
                                    res = new HttpResponse();

                                    req.setEndpoint(endpoint);
                                    req.setMethod('GET');
                                    res = sent.send(req);
                                    blob b = res.getBodyAsBlob();

                                    BlobsMap.put(endpoint, b);
                                }
                            }
                            
                            if(BlobsMap.size() > 0){
                                
                                BlobKeys = BlobsMap.keySet();
                            }
                            
							base64Map = new map<string, string>();
                            
                            // reiterate over the BlobsMap and using Order_of_Map put the blob in order as order of quote lines products

                            if(Order_of_Map.size() > 0 && BlobsMap.size() > 0){

                                for(string s : Order_of_Map.keySet()){

                                    if(BlobsMap.containsKey(s)){
                                        //blobs.add(BlobsMap.get(s));
                                        base64Map.put(s, EncodingUtil.base64Encode(BlobsMap.get(s)));
                                    }
                                }
                            }
                            
                            if(!blobs64.isEmpty()){
                                hasBlobs = true;
                                if(base64Map.size() > 0){
                                
                                    blobs64.addAll(base64Map.values());
                                }
                            }
                        }
                    }
                }
            }
            
       // }catch(Exception ex){
            
            //system.debug('Exception has occured.');
            //system.debug(ex.getMessage());
        //}
        
    }
    
    public PageReference refresh(){
        
        PageReference page = new pageReference('/apex/CreateProposalPage?scontrolCaching=1&id='+qt.id+'&isContinue=false' +
        '&specs='+WithSpecs+'&org='+Org);
        page.setRedirect(true);
        
        return page;
    }
    public PageReference continueAnyway(){
        
        PageReference page = new pageReference('/apex/CreateProposalPage?scontrolCaching=1&id='+qt.id+'&isContinue=true' +
        '&specs='+WithSpecs+'&org='+Org);
        page.setRedirect(true);
        
        return page;
    }
    
    @remoteaction
    public static string savePDF(wrapper wrp){
        quote q = [select id, 
                   opportunity.name from quote where id =:wrp.qId limit 1];
        
        //string base64Str = ApexPages.currentPage().getParameters().get('merged');
        
        blob converted = EncodingUtil.base64Decode(wrp.str);
        
        Attachment atch = new Attachment();
        
        atch.name = q.Opportunity.name + ' Proposal.pdf';
        atch.body = converted;
        atch.Description = q.Opportunity.name + ' Proposal';
        atch.ContentType = 'application/pdf';
        atch.parentId = wrp.qId;
        try{
            
            insert atch;

        }catch(Exception ex){
            
            system.debug(ex.getMessage());
        }
        
        return wrp.qId;
    }
    
    public void QuotaExceeded(){
        
        string typeOfError = ApexPages.currentPage().getParameters().get('reason');
        
        if(typeOfError != null){
            
            ProposalHasError = true;
            
            if(typeOfError == 'payment'){
                
                QuotaHasExceeded = true;
            }else{
                ErrorHasOccured = true;
            }
            
        }
    }
    public void PDFError(){

        problemIds = new set<id>();
        ProblemMap = new map<id, string>();

        string linkStr = ApexPages.currentPage().getParameters().get('links');
        string qid = ApexPages.currentPage().getParameters().get('qid');
        
        if(linkStr != null){
            ErrorEncrypted = true;
            List<string> LinksList = linkStr.split(';');
            
            List<QuoteLineItem> lineitems = [select id, product2id, product2.name from quotelineitem where
                                            product2.Technical_Specs_Id__c in:LinksList and quoteid =: qid];
            
            if(!lineitems.isEmpty()){

                for(QuoteLineItem qli : lineitems){
                    
                    problemIds.add(qli.Product2Id);
                    problemMap.put(qli.Product2Id, qli.Product2.name);
                }
                
                // add message to page
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
                                                                       'The following Product(s) Technical Specs PDF '+ 
                                                                       'are protected. <br/>Note that protected PDFs cannnot be '+ 
                                                                       'modified or merged. Please change these and retry.'));
            }
            
        }
    }
    
    public class wrapper{
        
        public string str {get; set;}
        public string qId {get; set;}
    }

    
}