public class OpportunityPageExtension {
    
    public List<OpportunityLineItem> oliKit {get; set;}
    public List<AcctSeed__Product_Part__c> productPartList {get; set; }
    public List<Attachment> attachments {get; set;}
    public List<Attachment> executedDocs {get; set;}
    public List<Attachment> attachmentWithoutExecutedDocs {get; set;}
    public List<ActivityHistory> activities {get; set;}
    public Opportunity op {get; set;}
    public String notificationMessage {get; set;}
    
    //for sorting
    public String sortWith {get; set;}
    public string sortProcess {get;set;}
    public string sortField {get;set;}
    public boolean TitleSortUp {get; set;}
    public boolean LastSortUp {get; set;}
    public Boolean CreatedSortUp {get; set;}
    public boolean BySortUp {get; set;}
    public boolean TitleSortDown {get; set;}
    public boolean LastSortDown {get; set;}
    public Boolean CreatedSortDown {get; set;}
    public boolean BySortDown {get; set;}
    
    public boolean AccountHasChanged {get; set;}
    public string SourceAccount {get; set;}
    
    public boolean ContactHasChanged {get; set;}
    public string SourceContact {get; set;}
    
    public boolean hasSalesOrder {get; set;}
    public boolean OpportunityHasChanged {get; set;}
    public String baseUrl {get; set;}
    public Boolean contactNewHasValue {get; set;}
    public string communityUrl {
        get{
 
        	string contactId = [select id, contactId from User where id =: userinfo.getUserId() limit 1][0].contactId;
            string url = System.URL.getSalesforceBaseURL().toExternalForm();
            
            return  contactId == null ? url : url + '/sales';
    	}
    }
   
    public OpportunityPageExtension(ApexPages.StandardController std) {

        baseUrl = System.URL.getOrgDomainUrl().toExternalForm();
        oliKit = new LIST<OpportunityLineItem>();
        productPartList = new List<AcctSeed__Product_Part__c>();
        attachments = new list<Attachment>();
        executedDocs = new list<Attachment>();
        attachmentWithoutExecutedDocs = new list<Attachment>();
        activities = new List<ActivityHistory>();
        
        op = new Opportunity();
        
        
        TitleSortUp = true; 
        LastSortUp = true;
        createdSortup = true;
        BySortUp = true; 
        TitleSortDown = false; 
        LastSortDown = false; 
        createdSortDown = false;
        BySortDown = false; 
        hasSalesOrder = false;
     
        list<string> fields = new list<string>{'Name', 'Account.name','LastModifiedDate',
            'LastViewedDate','LastReferencedDate','Show_Account_Message__c','Show_Contact_Message__c',
            'Show_Opportunity_Message__c',
            'ContactPerson__r.Name', 'ContactPerson__c'}; If(!Test.isRunningTest()) {std.addFields(fields);}
        
        op = (Opportunity)std.getRecord();
        
        
    }
    public void ChangedMessage(){
        
        
        //----------------------- Field History for Price Level and GL Account Variable 1 -----------------
        AccountHasChanged = false;
        SourceAccount = '';
        
        contactNewHasValue = false;
        ContactHasChanged = false;
        SourceContact = '';
        
        OpportunityHasChanged = false;

        // check if there are any Sales orders, if so fetch their attachments
        
        set<id> soIds = new set<id>();
        for(AcctSeedERP__Sales_order__c so : [select id from AcctSeedERP__Sales_order__c
                                              where AcctSeedERP__opportunity__c =: op.id]){
                                                  
                                                  soIds.add(so.id);            
                                              }
        
        if(!soIds.isEmpty()){
            hasSalesOrder = true;
            attachments.AddAll([SELECT Id, IsDeleted, ParentId, Name, 
                                ContentType, Description, LastModifiedDate, 
                                LastModifiedById, CreatedDate, CreatedById, 
                                OwnerId FROM Attachment 
                                where (parentId in:soIds or parentId =: op.id)
                                order by createddate desc]);
            
            
            
        }else{
            
            attachments.AddAll([SELECT Id, IsDeleted, ParentId, Name, 
                                ContentType, Description, LastModifiedDate, 
                                LastModifiedById, CreatedDate, CreatedById, 
                                OwnerId FROM Attachment where parentId =: op.id order by createddate desc]);
        }
        
        for(Attachment att: attachments ){
            
            if(att.Description != null && att.Description.Contains('<For Executed purpose>')){
                executedDocs.add(att);    
            }
            else{
                
                attachmentWithoutExecutedDocs.add(att); 
            }   
        }
    
        list<Opportunity> opportunityData = [Select Name, (Select Subject, Description, whoId, isTask, 
                                                           ActivityDate,Location,OwnerId 
                                                           from ActivityHistories Order by ActivityDate desc ) from Opportunity 
                                             where id =:op.id]; 
       
        if(!opportunityData.isEmpty()){
            
            activities.addAll(opportunityData[0].ActivityHistories);
        }
        
        
        
        oliKit = [select id, name, ProductCode, Product2.Type__c from OpportunityLineItem
                  where OpportunityId =: op.Id];
        
        Set<id> kitProdIds = new Set<id>();
        for(OpportunityLineItem o: oliKit){
            
            if(o.Product2.Type__c == 'Kit'){
                kitProdIds.add(o.Product2Id);
            }
        }
        
        LIST<AcctSeed__Product_Part__c> productPartList = new LIST <AcctSeed__Product_Part__c>();
        productPartList = [select id, Name,AcctSeed__Product__c from AcctSeed__Product_Part__c where
                           AcctSeed__Product__c in: kitProdIds];
        
        System.debug('op name: ' + op.name);
        //Notification Message
        List<Opportunity> opportunityDataForMessage = new List<Opportunity>([SELECT Id FROM Opportunity WHERE id = :op.Id AND Account.Id !=null AND Sales_Rep_O__c != null AND (Sales_Rep_O__r.Quote_Shower_Doors__c = false OR Sales_Rep_O__r.Quote_Wall_Surrounds__c = false OR Sales_Rep_O__r.Quote_Shower_Bases__c = false OR Sales_Rep_O__r.Quote_Barn_Doors__c = false OR Sales_Rep_O__r.Quote_LED_Mirrors__c = false OR Sales_Rep_O__r.Quote_Vanities_Kitchens__c = false OR Account.Shower_Doors__c = false OR Account.Wall_Surrounds__c = false OR Account.Shower_Bases__c = false OR Account.Barn_Doors__c = false OR Account.LED_Mirrors__c = false OR Account.Vanities_Kitchens__c = false)]);
        
        if(opportunityDataForMessage.size() > 0){
            notificationMessage = 'See check mark fields on Account screen \n See check mark fields on Sales rep screen';
        }
        
        
        
        
        
        // get the latest field value record for account name
        
        List<OpportunityFieldHistory> fieldHistoryAccount = [SELECT NewValue, OldValue, Field, OpportunityId, Id, CreatedDate, 
         CreatedById FROM OpportunityFieldHistory where field = 'Account'
                                                     and OpportunityId=:op.id
                                                     order by createddate desc limit 1];
        
         //&& op.show_message__c
        
        if(!fieldHistoryAccount.isEmpty() && op.show_account_message__c){ // field value has changed and show the message
            AccountHasChanged = true;
            SourceAccount = op.Account.name;
        }
        
        List<OpportunityFieldHistory> fieldHistoryContact = [SELECT NewValue, OldValue, Field, OpportunityId, Id, CreatedDate, 
                                                             CreatedById 
                                                             FROM OpportunityFieldHistory 
                                                             where field = 'ContactPerson__c' and OpportunityId=:op.id
                                                             order by createddate desc limit 1];
        
        //  && op.show_message__c
        System.debug('fieldHistoryContact: ' + fieldHistoryContact);
        if(!fieldHistoryContact.isEmpty() && op.show_contact_message__c){ // field value has changed and show the message
            if(fieldHistoryContact[0].NewValue != null)//If contact field new value
                contactNewHasValue = true;
            
            ContactHasChanged = true;
            SourceContact = op.ContactPerson__r.name;
        }
        
        
        if(hasSalesOrder && op.show_opportunity_message__c){
            
            OpportunityHasChanged = true;
            
            
        }
    }

    public void ResetFields(){

        try{
        	op.show_account_message__c = false;
        	op.show_contact_message__c = false;
        	op.show_opportunity_message__c = false; 
           	update op; 
        }catch(Exception ex){
            system.debug('Exception has occured.');
            system.debug(ex.getMessage());
			             
        }
    }
    public void hideAccountChangeMessage(){
        AccountHasChanged = false;
    }
    public void hideContactChangeMessage(){
        ContactHasChanged = false;
    }
    public void hideOpportunityChangeMessage(){
        OpportunityHasChanged = false;
    }
    public void searchResult(Id OppId){
        attachments = new list<Attachment>();
        
        String queryStr = '';
        
        // check if there are any Sales orders, if so fetch their attachments
        
        set<id> soIds = new set<id>();
        for(AcctSeedERP__Sales_order__c so : [select id from AcctSeedERP__Sales_order__c
                                              where AcctSeedERP__opportunity__c =: OppId]){
                                                  
                                                  soIds.add(so.id);            
                                              }
        
        if(!soIds.isEmpty()){
            queryStr += 'SELECT Id, IsDeleted, ParentId, Name,'+ 
                'ContentType, Description, LastModifiedDate,'+ 
                'LastModifiedById, CreatedDate, CreatedById,'+
                'OwnerId FROM Attachment where (parentId =: OppId or parentId in:soIds) ';
            
            queryStr += ((String.isEmpty(sortWith)) ? '' : 'order by '+sortField+' '+sortProcess+' NULLS LAST ');
            
            
            
            attachments.AddAll((list<Attachment>)Database.query(queryStr));
            
        }else{
            
            queryStr += 'SELECT Id, IsDeleted, ParentId, Name,'+ 
                'ContentType, Description, LastModifiedDate,'+ 
                'LastModifiedById, CreatedDate, CreatedById,'+
                'OwnerId FROM Attachment where parentId =: OppId ';
            queryStr += ((String.isEmpty(sortWith)) ? '' : 'order by '+sortField+' '+sortProcess+' NULLS LAST ');
            
            attachments.AddAll((list<Attachment>)Database.query(queryStr));
            
        }
    }
    public void setSort(String field, String process){
        
        sortProcess = process;
        sortField = field;
        
        SearchResult(op.id);
        
    }
    public void resetSort(String typeIs){
        
        if(typeIs == 'Title'){
            //TitleSortUp = true;
            //TitleSortDown = false;
            LastSortUp = true;
            LastSortDown = false;
            BySortUp = true;
            BySortDown = false;
            CreatedSortUp = true;
            CreatedSortDown = false;
        }else if(typeIs == 'Last'){
            TitleSortUp = true;
            TitleSortDown = false;
            //LastSortUp = true;
            //LastSortDown = false;
            BySortUp = true;
            BySortDown = false;
            CreatedSortUp = true;
            CreatedSortDown = false;
        }else if(typeIs == 'Created'){
            TitleSortUp = true;
            TitleSortDown = false;
            LastSortUp = true;
            LastSortDown = false;
            BySortUp = true;
            BySortDown = false;
        }else if(typeIs == 'By'){
            TitleSortUp = true;
            TitleSortDown = false;
            LastSortUp = true;
            LastSortDown = false;
            CreatedSortUp = true;
            CreatedSortDown = false;
            //BySortUp = true;
            //BySortDown = false;
            
        }
    }
    
    public void checkSort(){        
        sortWith = ApexPages.currentPage().getParameters().get('sort');
        if(sortWith == 'title'){
            
            if(TitleSortUp == true) sortProcess = 'ASC';
            
            if(sortProcess == 'DESC'){
                sortProcess = 'ASC';
                TitleSortUp = true;
                TitleSortDown = false;
                setSort('Name', 'ASC');  
            }else if(sortProcess == 'ASC'){
                sortProcess = 'DESC';
                TitleSortUp = false;
                TitleSortDown = true;
                setSort('Name', 'DESC'); 
            }
            resetSort('Title');            
        }else if(sortWith == 'last'){
            
            if(LastSortUp == true) sortProcess = 'ASC';
            
            if(sortProcess == 'DESC'){
                sortProcess = 'ASC';
                LastSortUp = true;
                LastSortDown = false;
                setSort('LastModifiedDate', 'ASC');  
            }else if(sortProcess == 'ASC'){
                sortProcess = 'DESC';
                LastSortUp = false;
                LastSortDown = true;
                setSort('LastModifiedDate', 'DESC'); 
            }
            resetSort('Last');            
        }else if(sortWith == 'created'){
            
            if(CreatedSortUp == true) sortProcess = 'ASC';
            
            if(sortProcess == 'DESC'){
                sortProcess = 'ASC';
                CreatedSortUp = true;
                CreatedSortDown = false;
                setSort('CreatedDate', 'ASC');  
            }else if(sortProcess == 'ASC'){
                sortProcess = 'DESC';
                CreatedSortUp = false;
                CreatedSortDown = true;
                setSort('CreatedDate', 'DESC'); 
            }
            resetSort('Created');            
        }else if(sortWith == 'by'){
            
            if(BySortUp == true) sortProcess = 'ASC';
            
            if(sortProcess == 'DESC'){
                sortProcess = 'ASC';
                BySortUp = true;
                BySortDown = false;
                setSort('CreatedbyId', 'ASC');  
            }else if(sortProcess == 'ASC'){
                sortProcess = 'DESC';
                BySortUp = false;
                BySortDown = true;
                setSort('CreatedbyId', 'DESC'); 
            }
            resetSort('By');            
        }
    }
    
    public PageReference newAttachment(){
        
        string url = '?id='+op.id+'&sfdc.override=1';
        
        //custom attachment page
        PageReference page = new PageReference(
            communityUrl + '/apex/OpportunityAttachmentPage?pid='+op.id+'&parentname='+op.name+'&retURL='+communityUrl+'/apex/OpportunityPage'+url+'&id='+op.id+'&sfdc.override=1'
        );
        
        //for default attachment page
        PageReference page2 = new PageReference(
            communityUrl + '/p/attach/NoteAttach?pid='+op.id+'&parentname='+op.name+'&retURL='+communityUrl+'/apex/OpportunityPage'+url+'&id='+op.id+'&sfdc.override=1'
        );
        page2.setRedirect(true);
        
        return page2;
    }
    
    public PageReference newAttachmentTest(){
        
        string url = '?id='+op.id+'&sfdc.override=1';
        
        //string url = '?id='+op.id;
       String oppName = EncodingUtil.urlEncode(op.name, 'UTF-8');
        //custom attachment page
        PageReference page = new PageReference( 
 communityUrl + '/apex/OpportunityAttachmentPage?pid='+op.id+'&parentname='+oppName+'&retURL='+communityUrl+'/apex/OpportunityPage'+url+'&id='+op.id+'&sfdc.override=1'
 //'/apex/OpportunityAttachmentPage?id='+op.id+'&parentname='+ op.name+'pid='+op.id
        
        );
        
        page.setRedirect(true);
        
        return page;
    }
    
    public Pagereference editAttachment(){
        string editId = ApexPages.currentPage().getParameters().get('editId');
        LIST<AcctSeedERP__Sales_Order__c> SO = [select id from AcctSeedERP__Sales_Order__c
                                                where AcctSeedERP__Opportunity__c =: op.id limit 1];
        PageReference page;
        if(!SO.isEmpty()){
           
            String retURL = communityUrl + '/apex/OpportunityPage?id='+op.Id+'&sfdc.override=1';
            page = new PageReference(communityUrl + '/apex/OpportunityAttachmentEditPage?retURL='+retURL);
        }
        else{
            page = new PageReference('/' +editId+'/e?retURL='+communityUrl + '/' +op.id);    
        }
        page.setRedirect(true);
        return page;
    }
    public Pagereference viewAttachment(){
        string viewId = ApexPages.currentPage().getParameters().get('viewId');
        PageReference page = new PageReference(communityUrl + '/servlet/servlet.FileDownload?file='+viewId);
        page.setRedirect(true);
        
        return page;
    }
    public PageReference sendAnEmail(){
        
        string url = communityUrl + '/_ui/core/email/author/EmailAuthor?p2_lkid=&rtype=003&p3_lkid='+op.id+'&retURL='+communityUrl+'/'+op.id;
        
        PageReference page = new PageReference(url);
        page.setRedirect(true);
        
        return page;
    }
    
    public Pagereference deleteAttachment(){
        string deleteId = ApexPages.currentPage().getParameters().get('deleteId');
        LIST<AcctSeedERP__Sales_Order__c> SO = [select id from AcctSeedERP__Sales_Order__c
                                                where AcctSeedERP__Opportunity__c =: op.Id limit 1];
        PageReference page;
        if(!SO.isEmpty()){
            String retURL = communityUrl + '/apex/OpportunityPage?id='+op.Id+'&sfdc.override=1';
            page = new PageReference(communityUrl + '/apex/OpportunityAttachmentDeletePage?retURL='+retURL);
        }
        else if(deleteId != null){
            delete [select id from Attachment where id =:deleteId];
            page = new PageReference('/' + op.id);
        }
        system.debug('communityUrl: ' + communityUrl);
        page.setRedirect(true);
        return page;
    }
    
    // Activity History related list methods
    public PageReference editActivity(){
        string editId = ApexPages.currentPage().getParameters().get('editActivityId');
        

        String url = communityUrl + '/'+editId+'/e?retURL='+communityUrl+'/apex/OpportunityPage?id='+op.id+'&sfdc.override=1';
        
        PageReference page = new PageReference(url);
        page.setRedirect(true);
        
        return page;
        
    }
    public PageReference deleteActivity(){
        
        string deleteId = ApexPages.currentPage().getParameters().get('deleteActivityId');
        
        PageReference page = new PageReference(communityUrl + '/' + op.id);
        
        if(deleteId != null){
            
            delete [select id from task where id =:deleteId limit 1];
            
        	page.setRedirect(true);
            
        }else{
            
            page = null;
        }

        return page;
    }
    public PageReference gotoActivity(){
        
        string gotoId = ApexPages.currentPage().getParameters().get('gotoActivityId');
        
        string url = communityUrl + '/' + gotoId;
        
        PageReference page = new PageReference(url);
        page.setRedirect(true);
        
        return page;
    }
    public PageReference logCall(){
        
        string url = communityUrl + '/00T/e?title=Call&who_id='+userinfo.getUserId()
            + '&what_id='+op.id+'&followup=1&tsk5=Call&retURL='+communityUrl+'/apex/OpportunityPage?id='+op.id;
        
        PageReference page = new PageReference(url);
        page.setRedirect(true);
        
        return page;
    }
    public PageReference mailMerge(){
        
        string url = communityUrl + '/mail/mmchoose.jsp?id='+op.id+'&1='+op.name+'&retURL='+communityUrl+'/apex/OpportunityPage?id='+op.id;
        PageReference page = new PageReference(url);
        page.setRedirect(true);
        
        return page;
    }
    public PageReference viewAll(){
        
        string url = communityUrl + '/ui/core/activity/ViewAllActivityHistoryPage?retURL='+communityUrl+'/apex/OpportunityPage?id='+op.id+'&id='+op.id;
        
        PageReference page = new PageReference(url);
        page.setRedirect(true);
        
        return page;
    }
    
    public PageReference save() { 
        return new PageReference('google.com');
    }
    
    public PageReference getCheckedAttachments(){ 
        
        String attachmentIDs = ApexPages.currentPage().getParameters().get('attachmentIDs');
        
        set<id> attachIds = new set<Id>();
        LIST<String> attachIdsList = new List<String>();

        if(attachmentIDs.contains(',')){ //whether attachmentIDs have many ids => commas exist
            attachIdsList.addAll(attachmentIDs.Split(','));
        }
        else{
            attachIdsList.add(attachmentIDs); //when attachmentIDs have just 1 ids => no Comma
        }
        
        for(String str : attachIdsList){
            attachIds.add(str.remove('\''));
        }
       
        List<Attachment> checkAttachments =[select id, Description from Attachment
                                            where id in: attachIds];
        
        for(Attachment att : checkAttachments){
            if(att.Description == null){
                att.Description = '<For Executed purpose>';
            }
            else{
                att.Description = att.Description+'<For Executed purpose>';
            }
           
        }
           
        try{ 
            update checkAttachments;
        }
        catch(Exception ex){
            
        }
        
        PageReference page = new PageReference (communityUrl + '/apex/OpportunityPage?id=' + op.Id);
        page.setRedirect(true);
        return page;
    }
    
    public PageReference getCheckedExecutedDocs(){
     
        String attachmentIDs = ApexPages.currentPage().getParameters().get('attachmentIDs');
        set<id> attachIds = new set<Id>();
        LIST<String> attachIdsList = new List<String>();
        
        if(attachmentIDs.contains(',')){ //whether attachmentIDs have many ids => commas exist
            attachIdsList.addAll(attachmentIDs.Split(','));
        }
        else{
            attachIdsList.add(attachmentIDs); //when attachmentIDs have just 1 ids => no Comma
        }
        
        for(String str : attachIdsList){
            attachIds.add(str.remove('\''));
        }
       
        List<Attachment> checkAttachments =[select id, Description from Attachment
                                            where id in: attachIds];
        
        for(Attachment att : checkAttachments){
            
            String description = att.Description;
            att.Description = description.remove('<For Executed purpose>');
            //description.remove('<For Executed purpose>');
            // att.Description = att.Description+'<For Executed purpose>';
        }
           
        try{ 
            update checkAttachments;
        }
        catch(Exception ex){
            
        }
        
        PageReference page = new PageReference (communityUrl + '/apex/OpportunityPage?id='+op.Id);
        page.setRedirect(true);
        return page;
    }
}