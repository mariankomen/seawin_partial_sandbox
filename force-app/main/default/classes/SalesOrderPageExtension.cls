public class SalesOrderPageExtension {
    public List<Attachment> attachments {get; set;}
    public List<Attachment> executedDocs {get; set;}
    public List<Attachment> attachmentWithoutExecutedDocs {get; set;}
    AcctSeedERP__Sales_Order__c so {get; set;}
    public List<AcctSeedERP__Sales_Order__History> SOHistory {get; set;}
    
    public Boolean showChangeMessage {get; set;}
    public string ChangeMessage {get; set;}
    
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
    
    public boolean SOLHasChanged {get; set;}
    public boolean HasPO {get; set;}
  
	public SalesOrderPageExtension(ApexPages.StandardController std) {
		attachments = new list<Attachment>();
        executedDocs = new list<Attachment>();
        attachmentWithoutExecutedDocs = new list<Attachment>();
        so = new AcctSeedERP__Sales_Order__c();
        SOHistory = new List<AcctSeedERP__Sales_Order__History>();
        showChangeMessage = false;
        ChangeMessage = null;
        
        SOLHasChanged = false;
        HasPO = false;
       
        Sohistory = [SELECT Id, Field, NewValue, CreatedDate, 
                     CreatedBy.Name FROM 
                     AcctSeedERP__Sales_Order__History where Field = 'AcctSeedERP__Status__c' 
                     order by createddate desc limit 1];
        
        TitleSortUp = true; 
        LastSortUp = true;
        createdSortup = true;
        BySortUp = true; 
        TitleSortDown = false; 
        LastSortDown = false; 
        createdSortDown = false;
        BySortDown = false;
        
        list<string> fields = new list<string>{'Name', 'Status_Helper__c', 'AcctSeedERP__Status__c',
            'Stage_Helper__c', 'Stage__c', 'AcctSeedERP__Customer__r.name',
            'Contact__r.name', 'Show_Account_Message__c', 'Show_Contact_Message__c','Show_SalesOrder_Message__c'}; 
                If(!Test.isRunningTest()) {std.addFields(fields);}
        
        so = (AcctSeedERP__Sales_Order__c)std.getRecord();
        /*
		attachments.AddAll([SELECT Id, IsDeleted, ParentId, Name, 
                                               ContentType, Description, LastModifiedDate, 
                                               LastModifiedById, CreatedDate, CreatedById, 
                                               OwnerId FROM Attachment where parentId =: so.id]);
        */
        
        LIst<AcctSeedERP__Purchase_Order__c> PoList = [select id from AcctSeedERP__Purchase_Order__c
                                                      where Sales_Order__c =: so.id limit 1];
        
        if(!POLIst.isEmpty()){
            // has purchase order
            HasPO = true;
        }
        
        // check if there are any Sales orders, if so fetch their attachments
        AccountHasChanged = false;
        SourceAccount = '';
        
        ContactHasChanged = false;
        SourceContact = '';
        
        if(so.Status_Helper__c == 'Hold' && so.AcctSeedERP__Status__c == 'Open'){
            
            showChangeMessage = true;
              ChangeMessage = 'Status from Hold was changed to Open';
          }else if(so.Status_Helper__c == 'Open' && so.AcctSeedERP__Status__c == 'Closed'){
              
              showChangeMessage = true;
              ChangeMessage = 'Status from Open was changed to Closed';
          }
        
        set<id> opIds = new set<id>();
        for(AcctSeedERP__Sales_order__c ss : [select AcctSeedERP__opportunity__c from AcctSeedERP__Sales_order__c
                                             where id =: so.id]){
            
			opIds.add(ss.AcctSeedERP__opportunity__c);            
        }
        
        if(!opIds.isEmpty()){
            
            attachments.AddAll([SELECT Id, IsDeleted, ParentId, Name, 
                                ContentType, Description, LastModifiedDate, 
                                LastModifiedById, CreatedDate, CreatedById, 
                                OwnerId FROM Attachment 
                                where (parentId in:opIds or parentId =:so.id)
                                order by createddate desc]);
            
            
            
        }else{
            
            attachments.AddAll([SELECT Id, IsDeleted, ParentId, Name, 
                                ContentType, Description, LastModifiedDate, 
                                LastModifiedById, CreatedDate, CreatedById, 
                                OwnerId FROM Attachment where parentId =: so.id order by createddate desc]);     
        }
        
        for(Attachment att: attachments ){
            
            if(att.Description != null && att.Description.Contains('<For Executed purpose>')){
                System.debug('if');
                executedDocs.add(att);    
            }
            else{
                System.debug('else');
                attachmentWithoutExecutedDocs.add(att); 
            }   
        }
        System.debug('executedDocs: ' + executedDocs);
        System.debug('attachmentWithoutExecutedDocs: ' + attachmentWithoutExecutedDocs);
    }
    
    public void ChangedMessage(){
        
        // get the latest field value record for account name
        
        List<AcctSeedERP__Sales_Order__History> fieldHistory = [SELECT NewValue, OldValue, Field, 
                                                                ParentId, Id, CreatedDate, 
         CreatedById FROM AcctSeedERP__Sales_Order__History where field = 'AcctSeedERP__Customer__c'
                                                     and ParentId=:so.id
                                                     order by createddate desc limit 1];
        // && so.show_account_message__c
        if(!fieldHistory.isEmpty() && so.show_account_message__c){ // field value has changed and show the message
            AccountHasChanged = true;
            SourceAccount = so.AcctSeedERP__Customer__r.name;
        }
        
        List<AcctSeedERP__Sales_Order__History> fieldHistoryContact = [SELECT NewValue, OldValue, Field, 
                                                                ParentId, Id, CreatedDate, 
         CreatedById FROM AcctSeedERP__Sales_Order__History where field = 'Contact__c'
                                                     and ParentId=:so.id
                                                     order by createddate desc limit 1];
        // && so.show_contact_message__c
        if(!fieldHistoryContact.isEmpty() && so.show_contact_message__c){ // field value has changed and show the message
            ContactHasChanged = true;
            SourceContact = so.Contact__r.name;
        }
        
        if(HasPO && so.Show_SalesOrder_Message__c){ // field value has changed and show the message
            SOLHasChanged = true;
        }
    }
    
    public void ResetFields(){
 
        try{
           so.show_account_message__c = false;
           so.show_contact_message__c = false;
           so.Show_SalesOrder_Message__c = false;
            
           update so; 
            
        }catch(Exception ex){
            system.debug('Exception has occured.');
            system.debug(ex.getMessage());
            
        }
    }
    
    public void hideChangeMessage(){
        showChangeMessage = false;
    }
    
    public void hideAccountMessage(){
        AccountHasChanged = false;
    }
    
    public void hideContactMessage(){
        ContactHasChanged = false;
    }
    
    public void hideSOMessage(){
        SOLHasChanged = false;
    }
    
     public void searchResult(Id SoId){
        attachments = new list<Attachment>();
        
        String queryStr = '';

         
         set<id> opIds = new set<id>();
        for(AcctSeedERP__Sales_order__c ss : [select AcctSeedERP__opportunity__c from AcctSeedERP__Sales_order__c
                                             where id =: so.id]){
            
			opIds.add(ss.AcctSeedERP__opportunity__c);            
        }
        
        if(!opIds.isEmpty()){
            
            queryStr += 'SELECT Id, IsDeleted, ParentId, Name,'+ 
                            'ContentType, Description, LastModifiedDate,'+ 
                            'LastModifiedById, CreatedDate, CreatedById,'+
                            'OwnerId FROM Attachment where (parentId =:SoId or parentId in:opIds) ';
            
            queryStr += ((String.isEmpty(sortWith)) ? '' : 'order by '+sortField+' '+sortProcess+' NULLS LAST ');
            
            
            
            attachments.AddAll((list<Attachment>)Database.query(queryStr));
            
        }else{
            queryStr += 'SELECT Id, IsDeleted, ParentId, Name,'+ 
                            'ContentType, Description, LastModifiedDate,'+ 
                            'LastModifiedById, CreatedDate, CreatedById,'+
                            'OwnerId FROM Attachment where parentId =:SoId ';
            
            queryStr += ((String.isEmpty(sortWith)) ? '' : 'order by '+sortField+' '+sortProcess+' NULLS LAST ');
            
            
            
            attachments.AddAll((list<Attachment>)Database.query(queryStr));
            
        }
    }
    
    public void setSort(String field, String process){
        
        sortProcess = process;
        sortField = field;
        
        SearchResult(so.id);
        
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
        
        string url = '?id='+so.id+'&sfdc.override=1';
        
        //custom attachment page
        PageReference page = new PageReference(
            '/apex/SalesOrderAttachmentPage?pid='+so.id+'&parentname='+so.name+'&retURL=/apex/SalesOrderPage'+url+'&id='+so.id+'&sfdc.override=1'
        );
        
        PageReference page2 = new PageReference(
            '/p/attach/NoteAttach?pid='+so.id+'&parentname='+so.name+'&retURL=/apex/SalesOrderPage'+url+'&id='+so.id+'&sfdc.override=1'
        );
        page2.setRedirect(true);
        
        return page2;
    }
    
    public PageReference newAttachmentTest(){
        
        string url = '?id='+so.id+'&sfdc.override=1';
        
        //custom attachment page
        PageReference page = new PageReference(
            '/apex/SalesOrderAttachmentPage?pid='+so.id+'&parentname='+so.name+'&retURL=/apex/SalesOrderPage'+url+'&id='+so.id+'&sfdc.override=1'
        );
        
        page.setRedirect(true);
        
        return page;
    }
    
    public Pagereference editAttachment(){

        string editId = ApexPages.currentPage().getParameters().get('editId');
        AcctSeedERP__Sales_Order__c SOrder = [select id, AcctSeedERP__Opportunity__c from AcctSeedERP__Sales_Order__c
                                                    where Id =: so.Id limit 1];
        PageReference page = new PageReference('/'+editId+'/e?retURL='+so.id);
        page.setRedirect(true);
        return page;    
    }

    public Pagereference viewAttachment(){
        string viewId = ApexPages.currentPage().getParameters().get('viewId');
        PageReference page = new PageReference('/servlet/servlet.FileDownload?file='+viewId);
        page.setRedirect(true);
        
        return page;
    }
    
    public Pagereference deleteAttachment(){
        
        string deleteId = ApexPages.currentPage().getParameters().get('deleteId');
        
        AcctSeedERP__Sales_Order__c SOrder = [select id, AcctSeedERP__Opportunity__c from AcctSeedERP__Sales_Order__c
                                              where Id =: so.Id limit 1];
       
        if(deleteId != null){
            delete [select id from Attachment where id =:deleteId];
            PageReference page = new PageReference('/'+so.id);
             page.setRedirect(true);
            return page;
        }
        return null;   
    }
    
    public PageREference removeHelperValue(){
        try{
        	so.Stage_Helper__c = null;
        	so.Status_Helper__c = null;
        	update so;
        }catch(Exception ex){
            system.debug('Exception has occured.');
            system.debug(ex.getMessage());
        }
        return null;
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
        
        System.debug('attachmentIDs: ' + attachmentIDs);
        System.debug('attachIds: ' + attachIds);
        System.debug('attachIdsList: ' + attachIdsList);
        System.debug('attachIds: ' + attachIds);
        System.debug('checkAttachments: ' + checkAttachments);
        
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
            System.debug('ex: ' + ex.getMessage());
        }
        
        PageReference page = new PageReference ('/apex/SalesOrderPage?id='+ so.Id);
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
            System.debug('ex: ' + ex.getMessage());
        }
        
        PageReference page = new PageReference ('/apex/SalesOrderPage?id='+so.Id);
        page.setRedirect(true);
        return page;
    }
    
}