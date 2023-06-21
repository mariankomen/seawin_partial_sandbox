public without sharing class SalesOrderPDFManager {
    
    public AcctSeedERP__Sales_Order__c salesOrder{get;set;}
    public Boolean showSavePdf{get;set;}
    public Boolean showSendEmail{get;set;}
    public Boolean showPage{get;set;}
    public Boolean fromAddressPicklistEnabled{get;set;}
    public Boolean sendccUser{get;set;}
    public String ccAddresses{get;set;}
    public String selectedOrgWideEmailAddress{get;set;}
    public Attachment attach {get;set;}
    public EmailTemplate emailTemplate {get;set;}
    public customEmailTemplate custmEmailTemplate{get;set;}
    private Boolean hasEmailTemplate = true;
    
    public string communityUrl {
        
        get{
            String contactId = [select contactId from user where id =: UserInfo.getUserId() Limit 1][0].contactId;
            
            return contactId == null ? '' : '/sales';
        }
        
    }
    
    public SalesOrderPDFManager(ApexPages.StandardController stdController){
        this.attach = new attachment();
        this.showSavePdf = true;
        this.showSendEmail = true;
        this.showPage = true;
        this.fromAddressPicklistEnabled = true;
        this.sendccUser = false;
        this.ccAddresses = '';
        this.selectedOrgWideEmailAddress = '';
        List<String> fieldNames = new List<String>();
        fieldNames.add('Id');
        fieldNames.add('Contact__c');
        fieldNames.add('Sales_Order_Format__r.AcctSeed__Default_Email_Template__c');
        
        if(!Test.isRunningTest()){
            stdController.addFields(fieldNames); 
        }
        this.salesOrder = (AcctSeedERP__Sales_Order__c)stdController.getRecord();
        
        try{
            this.emailTemplate = [SELECT Id, Name, DeveloperName, TemplateType, Subject, HtmlValue, Body FROM EmailTemplate 
                                  WHERE DeveloperName =:salesOrder.Sales_Order_Format__r.AcctSeed__Default_Email_Template__c
                                  LIMIT 1];
        }Catch(Exception e){
            this.hasEmailTemplate = false;
        }
        setCustmEmailTemplate();        
    }
    public void setCustmEmailTemplate(){
        if(this.hasEmailTemplate){
            List<String> bodies = new List<String>();
            bodies.add(this.emailTemplate.Subject);
            bodies.add(this.emailTemplate.Body);
            List<Messaging.RenderEmailTemplateBodyResult> result = Messaging.renderEmailTemplate(this.salesOrder.AcctSeedERP__Customer__c, 
                                                                                                 this.salesOrder.Id, bodies);
            this.custmEmailTemplate = new customEmailTemplate(result[0].getMergedBody(), result[1].getMergedBody(), false);
            
        }else{
            this.custmEmailTemplate = new customEmailTemplate('', '', false);
        }
    }
    
    public List<SelectOption> getOrgWideEmailSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(UserInfo.getUserEmail(),UserInfo.getUserEmail()));
        for(OrgWideEmailAddress owe : [select id, Address, DisplayName from OrgWideEmailAddress]){
            options.add(new SelectOption(owe.Address + '', owe.DisplayName + '<' + owe.Address + '>'));
        }
        return options;
    }
    
    public void saveAttach(){
        
        PageReference page = Page.SalesOrderPDFInvoice; 
        page.getParameters().put('id', this.salesorder.id);
        
        Date dat = Date.today();
        
        Blob pageBlob = Blob.valueOf('Test blob file.');
        
        if(!Test.isRunningTest()) pageBlob = page.getContentAsPDF();
        
        try{
            Attachment saveAttachmentFile = new Attachment();
            saveAttachmentFile.Body = pageBlob;
            saveAttachmentFile.ContentType = 'application/pdf';
            saveAttachmentFile.Name = 'Sales Order PDF-' + dat.year()+''+dat.month()+''+dat.day()+'.pdf';
            saveAttachmentFile.ParentId = this.salesOrder.id;
            
            insert saveAttachmentFile;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 
                                                       'The attachment has been saved.'));
            
        }catch(Exception ex){
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Fatal, 'Attachment could not be saved.'));
            
        }
    }
    public PageReference saveAndEmail(){
        
        Boolean SomethingIsMissing = false;
        
        list<ApexPages.message> msg = new list<ApexPages.message>();
        
        if(salesOrder.Contact__c == null){
            msg.add(new ApexPages.message(ApexPages.Severity.Fatal, 'Send to Contact cannot be empty.'));
            SomethingIsMissing = true;
        }
        if(custmEmailTemplate.emailSubject == ''){
            msg.add(new ApexPages.message(ApexPages.Severity.Fatal, 'Email subject cannot be empty.'));
            SomethingIsMissing = true;
        }
        if(custmEmailTemplate.emailBody == ''){
            msg.add(new ApexPages.message(ApexPages.Severity.Fatal, 'Email body cannot be empty.'));
            SomethingIsMissing = true;
        }
        if(sendccUser){
            if(ccAddresses == ''){
                msg.add(new ApexPages.message(ApexPages.Severity.Fatal,'CC Addresses cannot be empty if CC Me is checked.'));
                SomethingIsMissing = true;
            }
        }

        if(attach.name != null){
            if(attach.body.size() < 1){
                msg.add(new ApexPages.message(ApexPages.Severity.Fatal,'The Email attachment is an empty file.'));
                SomethingIsMissing = true;
            }
        }
        
        if(SomethingIsMissing){
            for(ApexPages.message msgg : msg){
                ApexPages.addMessage(msgg);
            }
            return null;
        }
        
        PageReference page = Page.SalesOrderPDFInvoice; 
        page.getParameters().put('id', this.salesorder.id);
        
        Date dat = Date.today();
        
        Blob pageBlob = null;
        
        if(!Test.isRunningTest()){
            pageBlob = page.getContentAsPDF();
        }else{
            pageBlob = Blob.valueOf('Test blob file.');
        }
        
        try{
            
            // save the attachment to object
            Attachment attachToObject = new Attachment();
            attachToObject.Body = pageBlob;
            attachToObject.ContentType = 'application/pdf';
            attachToObject.Name = 'Sales Order PDF-' + dat.year()+''+dat.month()+''+dat.day()+'.pdf';
            attachToObject.ParentId = this.salesOrder.id;
            
            insert attachToObject;
            // save complete
            
            Messaging.SingleEmailMessage emailmessage = new Messaging.SingleEmailMessage();
            
            Messaging.EmailFileAttachment emailattach = new Messaging.EmailFileAttachment();
            emailattach.contenttype = 'application/pdf';
            emailattach.setFileName('Sales Order PDF-' + dat.year()+''+dat.month()+''+dat.day()+'.pdf');
            emailattach.setBody(pageBlob);
            
            Messaging.EmailFileAttachment emailattachAdditional = new Messaging.EmailFileAttachment();
            
            // check if there is any other attachment alongwith the pdf
            if(attach.name != null){

                emailattachAdditional.contenttype = attach.contenttype;

                emailattachAdditional.setFileName(attach.name);
                emailattachAdditional.setBody(attach.body);
            }
            
            // get the contact
            
            List<Contact> contct = [select email from contact where id=:salesOrder.Contact__c limit 1];
            
            List<String> addresses = new List<String>{contct[0].email};
                emailmessage.setSubject(custmEmailTemplate.emailSubject);
            emailmessage.setReplyTo(selectedOrgWideEmailAddress);
            emailmessage.setToAddresses(addresses);
            emailmessage.setPlainTextBody(custmEmailTemplate.emailBody);
            if(sendccUser){
                if(ccAddresses != ''){
                    List<String> strCC = ccAddresses.split(',');
                    system.debug(strCC);
                    emailmessage.setCcAddresses(strCC);
                }  
            }
            if(attach.name != null){
                emailmessage.setFileAttachments(new Messaging.EmailFileAttachment[] {emailattach, emailattachAdditional}); 
            }else{
                emailmessage.setFileAttachments(new Messaging.EmailFileAttachment[] {emailattach}); 
            }
            
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailmessage});
            
            if(r[0].IsSuccess()){
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Confirm, 
                                                           'PDF successfully emailed to: ('+contct[0].email+')'));
            }else{
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Fatal, 
                                                           'Error has occured while sending the email. Please retry.'));
            }
            
        }catch(Exception ex){
            
            system.debug(ex.getMessage());
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Fatal, 
                                                       'Error has occured while sending email. Please contact the adminsitrator.'));
            
        }
        
        return null;
    }
    
    class customEmailTemplate {
        public string emailBody{get;set;}
        public string emailSubject{get;set;}
        public Boolean isHTML{get;set;}
        
        public customEmailTemplate(String subject, String body, Boolean ishtml) {
            this.emailSubject = subject;
            this.emailBody = body;
            this.isHTML = ishtml;
        }
    }
}