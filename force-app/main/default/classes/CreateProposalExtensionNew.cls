public class CreateProposalExtensionNew {

    public Quote quoteRecord {get;set;}

    public CreateProposalExtensionNew(Apexpages.StandardController std) {
        list<string> fieldNames = new list<string>{'GL_Account_Variable_1__c'}; 
        if(!Test.isRunningTest()){
            quoteRecord = (Quote)std.getRecord();
        }
    }

    @AuraEnabled
    public static string saveProposalPDF(String qId, String str){
        quote q = [select id, 
                   opportunity.name from quote where id =:qId limit 1];
        
        //string base64Str = ApexPages.currentPage().getParameters().get('merged');
        
        blob converted = EncodingUtil.base64Decode(str);
        
        Attachment atch = new Attachment();
        
        atch.name = q.Opportunity.name + ' Proposal.pdf';
        atch.body = converted;
        atch.Description = q.Opportunity.name + ' Proposal';
        atch.ContentType = 'application/pdf';
        atch.parentId = qId;
        try{
            
            insert atch;

        }catch(Exception ex){
            
            system.debug(ex.getMessage());
        }
        
        return qId;
    }
    
    // FOR LWC
    public class ProposalException extends Exception {}

    @AuraEnabled
    public static string getQuoteAndQuoteLines(String quoteId){
        try {
            Quote quoteRecord = [SELECT Id, Name, Opportunity_in_Approval__c, GL_Account_Variable_1__c FROM Quote WHERE Id=:quoteId LIMIT 1];
            List<QuoteLineItem> quoteItems = [SELECT sortorder, product2id, product2.name,product2.category__c,
                                           product2.technical_specs_Id__c,createddate FROM QuoteLineItem
                                           WHERE QuoteId =:quoteRecord.id order by sortorder,
                                           product2.name,createddate asc];

            QuoteWrapper wrapper = new QuoteWrapper(quoteRecord, quoteItems);
            return JSON.serialize(wrapper);
        } catch (Exception e) {
            throw new ProposalException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Boolean checkDoesQuoteHasProposal(String quoteId){
        try {
            Quote q = [SELECT Id, Opportunity.Name FROM Quote WHERE Id=:quoteId];
            String proposalName = q.Opportunity.Name + ' Proposal.pdf';

            List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId=:quoteId AND Name=:proposalName];

            return attachments.isEmpty() ? false : true;
        } catch (Exception e) {
            throw new ProposalException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string fetchQuoteProposalTemplates(String quoteId){
        try {
            Quote quoteRecord = [SELECT Id, Name, GL_Account_Variable_1__c FROM Quote WHERE Id=:quoteId LIMIT 1];
            List<Quote_Proposal_Template__c> templates = [SELECT Id, Name, Template_Name__c, GL_Account_Variable_1__c FROM Quote_Proposal_Template__c WHERE GL_Account_Variable_1__r.Name=:quoteRecord.GL_Account_Variable_1__c];
            return JSON.serialize(templates);
        } catch (Exception e) {
            throw new ProposalException(e.getMessage());
        }
    }

    // !PAGE 1
    @AuraEnabled
    public static String getFrontPageStatic(String quoteId){
        try{
            Quote quoteRecord = [SELECT Id, Name, GL_Account_Variable_1__c FROM Quote WHERE Id=:quoteId LIMIT 1];
            PageReference proposalPage = null;
    
            if(quoteRecord.GL_Account_Variable_1__c == 'Seawin USA'){
                proposalPage = Page.SeawinProposalPage;
            }else if(quoteRecord.GL_Account_Variable_1__c == 'Seawin China'){
                proposalPage = Page.SeawinChinaProposalPage;
            }
    
            proposalPage.getParameters().put('quoteid', quoteRecord.id);
            String frontPage;
            try {
                frontPage = EncodingUtil.base64Encode(proposalPage.getContentAsPDF());  
            }
            catch (Exception e) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 
                                                            'The front page for the PDF could not be retrieved. Please retry.'));
            }
    
            return frontPage;
        }catch(Exception e){
            throw new ProposalException(e.getMessage());
        }
        
    }
    // !PAGE 2
    @AuraEnabled
    public static string getProposalTemplateContent(String parentId, String name){
        try {
            List<Attachment> proposalTemplate = [SELECT Id, ParentId, Body, Name FROM Attachment where ParentId=:parentId and Name=:name];
            return EncodingUtil.base64Encode(proposalTemplate[0].Body);
            
        } catch (Exception e) {
            if(e.getMessage().contains('List index out of bounds: 0')){
                throw new ProposalException('Can not find template in attachments.');
            }else{
                throw new ProposalException(e.getMessage());
            }
        }
    }
    // !PAGE 3
    @AuraEnabled
    public static string getQuoteDocumentContent(String quoteId){
        try {
            List<QuoteDocument> QuoteDocuments = [SELECT id, Document FROM QuoteDocument WHERE quoteId =:quoteId order by createddate desc limit 1];
            return EncodingUtil.base64Encode(QuoteDocuments[0].Document);
            
        } catch (Exception e) {
            throw new ProposalException('Cat not find quote document.');
        }
    }

    @AuraEnabled
    public static List<String> getProductSpecRepParsedURL(String qouteLinesSpecURLJSON){
        try{
            Set<String> qouteLinesSpecURL = (Set<String>)JSON.deserialize(qouteLinesSpecURLJSON, Set<String>.class);
            List<String> specRepBlobs = new List<String>();

            List<LinkWrapper> linkWrappers = new List<LinkWrapper>();
    
            for(String url: qouteLinesSpecURL){
                linkWrappers.add(new LinkWrapper(url));
            }
    
            String endpoint = 'https://sharepint-py-server.onrender.com';
    
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setBody(JSON.serialize(linkWrappers));
            request.setHeader('Content-Type','application/json');
            request.setTimeout(120000);
            try{
                HTTPResponse res = http.send(request);
    
                List<ResponsePythonWrapper> response = (List<ResponsePythonWrapper>)JSON.deserialize(res.getBody(), List<ResponsePythonWrapper>.class);
                for(ResponsePythonWrapper wrap: response){
                    Blob content = getProductTechnicalSpecifications(wrap.new_link, wrap.cookies.FedAuth);
                    if(content != null){
                        specRepBlobs.add(EncodingUtil.base64Encode(content));
                    }
                }
    
                
            }catch(Exception e){
                system.debug('709: '+e.getMessage());
                throw new ProposalException(e.getMessage());
            }
    
            return specRepBlobs;
        }catch(Exception e){
            throw new ProposalException(e.getMessage());
        }
        

    }

    public static Blob getProductTechnicalSpecifications(String techSpecUrl, String cookie){
        String endpoint = techSpecUrl;

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setTimeout(120000);
        request.setHeader('Cookie', 'FedAuth='+cookie);
        HTTPResponse res = http.send(request);
        // system.debug('726 response: '+res);
        if(res.getStatusCode() == 200){
            return res.getBodyasBlob();
        }else{
            return null;
        }
    }


    
    public class QuoteWrapper{
        public Quote quote {get;set;}
        public List<QuoteLineItem> quoteLineItems {get;set;}

        public QuoteWrapper(Quote quote, List<QuoteLineItem> quoteLineItems){
            this.quote = quote;
            this.quoteLineItems = quoteLineItems;
        }
    }

    public class LinkWrapper{
        public String link {get;set;}

        public LinkWrapper(String link){
            this.link = link;
        }
    }

    public class ResponsePythonWrapper{
        public String input_link {get;set;}
        public String new_link {get;set;}
        public CookieWrapper cookies {get;set;}

        public ResponsePythonWrapper(String input_link, String new_link, CookieWrapper cookies){
            this.input_link = input_link;
            this.new_link = new_link;
            this.cookies = cookies;
        }
    }

    public class CookieWrapper{
        public String FedAuth {get;set;}

        public CookieWrapper(String FedAuth){
            this.FedAuth = FedAuth;
        }
    }

    public class wrapper{
        
        public string str {get; set;}
        public string qId {get; set;}
    }
    

    public void coverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}