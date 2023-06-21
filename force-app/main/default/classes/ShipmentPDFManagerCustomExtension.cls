public class ShipmentPDFManagerCustomExtension {
    
    AcctSeedERP__Shipment__c shipment {get; set;}
    
    // variables
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
    
    public boolean showSendUser {get; set;}
    
    public string sendToEmail {get; set;}
    public string ccEmail {get; set;}
    
    public list<Attachment> attachments {get; set;}
    public List<AttachmentWrapper> attachmentList {get; set;} 
    
    public ShipmentPDFManagerCustomExtension(ApexPages.StandardController std){
        
        shipment = new AcctSeedERP__Shipment__c();
        attachments = new list<Attachment>();
        attachmentList = new List<AttachmentWrapper>();
        
        this.attach = new attachment();
        showPage = true;
        showSavePdf = true;
        this.selectedOrgWideEmailAddress = '';
        fromAddressPicklistEnabled = true;
        
        sendccUser = false;
        
        list<string> fieldNames = new list<string>{'id', 'Name', 
            'AcctSeedERP__Packing_Slip_Format__r.AcctSeed__Default_Email_Template__c',
            'AcctSeedERP__Sales_Order__r.AcctSeedERP__Customer__c', 
            'AcctSeedERP__Sales_Order__r.Contact__r.Email'}; if(!Test.isRunningTest()){ std.addFields(fieldNames); }
        
        shipment = (AcctSeedERP__Shipment__c)std.getRecord();
        
        //All Attachements from this shipment
        for(Attachment at: [SELECT Id, ParentId, Name, ContentType, BodyLength, Body, Description, 
                                        OwnerId, CreatedDate, LastModifiedDate, LastModifiedById, IsPrivate, 
                                        IsDeleted FROM Attachment where parentId =:shipment.id order by CreatedDate desc]){
            attachmentList.add(new AttachmentWrapper(at));
        }
        
        // -------------------------------- CC Emails ------------------------------------- //
        
        string ccemails = ApexPages.currentPage().getParameters().get('ccemails');
        string completeToEmails = ApexPages.currentPage().getParameters().get('completeTo');
        string completeCcEmails = ApexPages.currentPage().getParameters().get('completeCc');
        
        string onlycEmails = '';
        string contactcEmails = '';
        string salesRepcEmails = '';
        string allcEmails = '';
        
        if(ccemails == null){
            if(completeCcEmails != null){
               ccemails = completeCcEmails; 
            }
        }
        
        if(ccemails != null){
            String emailsFormat = ccemails.removeStart(';');
            // String emailsFormatted = emails.removeEnd(';');
            
            string[] arrayEmails = emailsFormat.split(';');
            
            set<id> contactEmailIds = new set<id>();
            set<id> salesRepEmailIds = new set<id>();
            for(string str : arrayEmails){
                if(str.indexOf('@') > -1){
                    onlycEmails += ';' + str;                
                }else{
                    
                    if(!String.isBlank(str)){
                        Id strId = (Id)str;
                        Schema.SObjectType sobjectType = strId.getSObjectType();
                        String sobjectName = sobjectType.getDescribe().getName();
                        
                        if(sobjectName == 'Contact'){
                            contactEmailIds.add(str);
                        }else if(sobjectName == 'Sales_Rep__c'){
                            salesRepEmailIds.add(str);
                        }
                    }
                }
            }
            
            list<Contact> contactsAre = new list<Contact>();
            list<Sales_Rep__c> SalesRepsAre = new list<Sales_Rep__c>();
            if(contactEmailIds.size() > 0){
                contactsAre = [select email,name from contact where id in:contactEmailIds];
                
                if(!contactsAre.Isempty()){
                    
                    for(contact cstr : contactsAre){
                        
                        contactcEmails += ';' + cstr.Email;
                    }
                }
            }
            if(salesRepEmailIds.size() > 0){
                
                SalesRepsAre = [select email__c,name from sales_rep__c where id in:salesRepEmailIds];
                
                if(!SalesRepsAre.Isempty()){
                    
                    for(sales_rep__c slstr : SalesRepsAre){
                        
                        salesRepcEmails += ';' + slstr.Email__c;
                    }
                }
            }
            
            if(onlycEmails != ''){ 
                onlycEmails = onlycEmails.removeStart(';');  
            }else if(contactcEmails != ''){
                contactcEmails = contactcEmails.removeStart(';'); 
            }else if(salesRepcEmails != ''){
                salesRepcEmails = salesRepcEmails.removeStart(';'); 
            }
            
            allcEmails = onlycEmails + contactcEmails + salesRepcEmails;
            
            set<string> allcEmailsSet = new set<string>(allcEmails.split(';'));
            
            allcEmails = '';
            
            for(string str : allcEmailsSet){
                
                allcEmails += str + ';';
            }
            
            allcEmails = allcEmails.removeEnd(';');
            
        }
        
        ccEmail = (ccemails != null)?allcEmails:((completeCcEmails != null)?completeCcEmails:'');
            
            // -------------------------------- CC Emails End --------------------------------- //
            
            // --------------------- To Emails ------------------------------------- //
            
            string toemails = ApexPages.currentPage().getParameters().get('toemails');
        
        string onlytEmails = '';
        string contacttEmails = '';
        string salesReptEmails = '';
        string alltEmails = '';
        
        if(toemails == null){
            if(completeToEmails != null){
               toemails = completeToEmails; 
            }
        }
        
        if(toemails != null){
            String emailsFormat = toemails.removeStart(';');
            // String emailsFormatted = emails.removeEnd(';');
            
            string[] arrayEmails = emailsFormat.split(';');
            
            set<id> contactEmailIds = new set<id>();
            set<id> salesRepEmailIds = new set<id>();
            for(string str : arrayEmails){
                if(str.indexOf('@') > -1){
                    onlytEmails += ';' + str;                
                }else{
                    
                    if(!String.isBlank(str)){
                        Id strId = (Id)str;
                        Schema.SObjectType sobjectType = strId.getSObjectType();
                        String sobjectName = sobjectType.getDescribe().getName();
                        
                        if(sobjectName == 'Contact'){
                            contactEmailIds.add(str);
                        }else if(sobjectName == 'Sales_Rep__c'){
                            salesRepEmailIds.add(str);
                        }
                    }
                }
            }
            
            list<Contact> contactsAre = new list<Contact>();
            list<Sales_Rep__c> SalesRepsAre = new list<Sales_Rep__c>();
            if(contactEmailIds.size() > 0){
                contactsAre = [select email,name from contact where id in:contactEmailIds];
                
                if(!contactsAre.Isempty()){
                    
                    for(contact cstr : contactsAre){
                        
                        contacttEmails += ';' + cstr.Email;
                    }
                }
            }
            if(salesRepEmailIds.size() > 0){
                
                SalesRepsAre = [select email__c,name from sales_rep__c where id in:salesRepEmailIds];
                
                if(!SalesRepsAre.Isempty()){
                    
                    for(sales_rep__c slstr : SalesRepsAre){
                        
                        salesReptEmails += ';' + slstr.Email__c;
                    }
                }
            }
            
            if(onlytEmails != ''){ 
                onlytEmails = onlytEmails.removeStart(';');  
            }else if(contacttEmails != ''){
                contacttEmails = contacttEmails.removeStart(';'); 
            }else if(salesReptEmails != ''){
                salesReptEmails = salesReptEmails.removeStart(';'); 
            }
            
            alltEmails = onlytEmails + contacttEmails + salesReptEmails;
            
            set<string> alltEmailsSet = new set<string>(alltEmails.split(';'));
            
            alltEmails = '';
            
            for(string str : alltEmailsSet){
                
                alltEmails += str + ';';
            }
            
            alltEmails = alltEmails.removeEnd(';');
            
        }
        
        sendToEmail = (toemails != null)?alltEmails:
        (completeToEmails != null) ? completeToEmails : shipment.AcctSeedERP__Sales_Order__r.Contact__r.Email;
        
        // -------------------------------- To Emails End --------------------------------- //
        
        try{
            this.emailTemplate = [SELECT Id, Name, DeveloperName, TemplateType, Subject, HtmlValue, Body FROM EmailTemplate 
                                  WHERE 
                                  DeveloperName =:shipment.AcctSeedERP__Packing_Slip_Format__r.AcctSeed__Default_Email_Template__c
                                  LIMIT 1];
        }Catch(Exception e){
            system.debug('Template exception:');
            system.debug(e.getMessage());
            this.hasEmailTemplate = false;
        }
        setCustmEmailTemplate();  
        
        
    }
    
    public void setCustmEmailTemplate(){
        if(this.hasEmailTemplate){
            List<String> bodies = new List<String>();
            bodies.add(this.emailTemplate.Subject);
            bodies.add(this.emailTemplate.Body);
            // this.shipment.AcctSeedERP__Sales_Order__r.Contact__c
            List<Messaging.RenderEmailTemplateBodyResult> result = Messaging.renderEmailTemplate(this.shipment.AcctSeedERP__Sales_Order__r.Contact__c, 
                                                                                                 this.shipment.Id, bodies);
            this.custmEmailTemplate = new customEmailTemplate(result[0].getMergedBody(), result[1].getMergedBody(), false);
            
        }else{
            this.custmEmailTemplate = new customEmailTemplate('', '', false);
        }
    }
    
    public void saveAttach(){
        
        PageReference page = Page.ShipmentPDFCustom; 
        page.getParameters().put('id', this.shipment.id);
        
        Date dat = Date.today();
        
        Blob pageBlob = null;
        
        if(!Test.isRunningTest()){
            pageBlob = page.getContentAsPDF();
        }else{
            pageBlob = Blob.valueOf('Test blob file.');
        }
        
        try{
            Attachment attach = new Attachment();
            attach.Body = pageBlob;
            attach.ContentType = 'application/pdf';
            attach.Name = 'Shipment PDF-' + dat.year()+''+dat.month()+''+dat.day()+'.pdf';
            attach.ParentId = this.shipment.id;
            
            insert attach;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 
                                                       'The attachment has been saved.'));
        }catch(Exception ex){
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Fatal, 'Attachment could not be saved.'));
            
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
    
    public PageReference saveAndEmail(){


        Boolean SomethingIsMissing = false;
        
        list<ApexPages.message> msg = new list<ApexPages.message>();
        
        
        if(String.isBlank(sendToEmail)){
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

        /*
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
		*/        
        PageReference page = Page.ShipmentPDFCustom; 
        page.getParameters().put('id', this.shipment.id);
        
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
            attachToObject.Name = 'Shipment PDF-' + dat.year()+''+dat.month()+''+dat.day()+'.pdf';
            attachToObject.ParentId = this.shipment.id;
            
            insert attachToObject;
            // save complete
            
            
            list<Messaging.SingleEmailMessage> emailmessages = new list<Messaging.SingleEmailMessage>();
            
            Messaging.EmailFileAttachment emailattach = new Messaging.EmailFileAttachment();
            emailattach.contenttype = 'application/pdf';
            emailattach.setFileName('Shipment PDF-' + dat.year()+''+dat.month()+''+dat.day()+'.pdf');
            emailattach.setBody(pageBlob);
            
            list<Messaging.EmailFileAttachment> emailattachAdditionals = new list<Messaging.EmailFileAttachment>();
            
            // check if there is any other attachment alongwith the pdf
            if(attachmentList.size() > 0){
                for(AttachmentWrapper awr : attachmentList){
                    if(awr.selected){
                       Messaging.EmailFileAttachment emailattachAdditional = new Messaging.EmailFileAttachment();
                        
                       	emailattachAdditional.contenttype = awr.attachment.contenttype;
                		emailattachAdditional.setFileName(awr.attachment.name);
                		emailattachAdditional.setBody(awr.attachment.body);
                        
                        emailattachAdditionals.add(emailattachAdditional);  
                    } 
                }
            }
            
            // get the contact
            
            //List<Contact> contct = [select email from contact where E=:sendContact.Contact__c limit 1];
            set<string> toEmailsAre = new set<string>();
            set<string> ccEmailsAre = new set<string>();
            // add the sendToEmail emails
            toEmailsAre.addAll(sendToEmail.split(';'));
			// add the ccEmail emails
            if(!String.IsBlank(ccEmail)){
                ccEmailsAre.addAll(ccEmail.split(';')); 
            }

            // if cc to me checked, pick up the current user email
            if(sendccUser){
               ccEmailsAre.add(UserInfo.getUserEmail()); 
            }
            
            // map of contactId and email
            map<string, id> EmailToNameMap = new map<string,id>();
            for(contact contct : [select id, name, email from contact where email in:toEmailsAre]){
            
            	EmailToNameMap.put(contct.email, contct.id);
            }
            
            for(sales_rep__c reps : [select id, name, email__c from sales_rep__c where email__c in:toEmailsAre]){
                
                EmailToNameMap.put(reps.email__c, reps.id);
            }

            for(string emailStr : EmailToNameMap.keyset()){
                
                id objectId = EmailToNameMap.get(emailStr);
                
                Messaging.SingleEmailMessage emailmessage = new Messaging.SingleEmailMessage();
  
                List<String> addresses = new List<String>{emailStr};
                emailmessage.setReplyTo(selectedOrgWideEmailAddress);
                emailmessage.setToAddresses(addresses);
                
                // render the email template
                List<String> bodies = new List<String>();
                
                //EmailTemplate emailTemplateSingle = new EmailTemplate();
                
                bodies.add(this.emailTemplate.Subject);
                bodies.add(this.emailTemplate.Body);
                // this.shipment.AcctSeedERP__Sales_Order__r.Contact__c
                List<Messaging.RenderEmailTemplateBodyResult> result = Messaging.renderEmailTemplate(objectId, 
                                                                                                     this.shipment.Id, bodies);
                
                customEmailTemplate custmEmailTemplate = new customEmailTemplate(result[0].getMergedBody(), result[1].getMergedBody(), false);
                // render complete
                emailmessage.setSubject(custmEmailTemplate.emailSubject);
                emailmessage.setPlainTextBody(custmEmailTemplate.emailBody);
                List<String> CCaddresses = new List<String>(ccEmailsAre);
                emailmessage.setCcAddresses(CCaddresses);
                
                if(emailattachAdditionals.size() > 0){
                    // emailmessage.setFileAttachments(new Messaging.EmailFileAttachment[] {emailattach}); 
                    emailattachAdditionals.add(emailattach);
                    emailmessage.setFileAttachments(emailattachAdditionals); 
                }else{
                    emailmessage.setFileAttachments(new Messaging.EmailFileAttachment[] {emailattach}); 
                }
                
                emailMessages.add(emailmessage);
                
            }

            Messaging.SendEmailResult [] r = Messaging.sendEmail(emailMessages, false);
            
            if(r[0].IsSuccess()){
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Confirm, 
                                                           'PDF successfully emailed to: '+ 
                                                          '<ul><li>To Addresses: '+sendToEmail+'</li>'+
                                                           (!string.isBlank(ccEmail)?'<li>CC Addresses: '+ccEmail+'</li>':'')
                                                          ));
            }else{
                
                system.debug(r.get(0).getErrors());
                
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
    
    public class AttachmentWrapper
    {
        public Attachment attachment{get; set;}
        public Boolean selected {get; set;}
        public AttachmentWrapper(Attachment attach)
        {
            attachment = attach;
            selected = false;
        }
    }
    
}