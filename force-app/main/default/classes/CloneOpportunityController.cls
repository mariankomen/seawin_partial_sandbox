public class CloneOpportunityController {

    public Opportunity opp {get; set;}
    public string OppId {get; set;}
    public string createproducts {get; set;}
    
    public CloneOpportunityController(ApexPages.StandardController std){

        string ownerid = ApexPages.currentPage().getParameters().get('ownerid');
        string salesrepid = ApexPages.currentPage().getParameters().get('salesrepid');
        createproducts = ApexPages.currentPage().getParameters().get('createproducts');

        system.debug('Create Products value: ' + createproducts);

        OppId = (String)std.getId();

        String fieldstring = AllFields.Fields('Opportunity', new List<string>()); // second argument is field exceptions
        fieldstring += ', RecordType.Name, Account.AcctSeed__Billing_Terms_Name__c, Account.Deposit__c';

        Opportunity OriginalOpportunity = Database.query('Select ' + fieldstring + ' from Opportunity where id=:OppId Limit 1');

        opp = OriginalOpportunity.clone(false, false, false, false);

        opp.Amount = 0;
        opp.Quote_Submitted_Date__c = null;

        opp.Financial_Clearance__c = false;
        opp.Financial_Clearance_Date__c = null;
        opp.Signed_Sales_Order__c = false;
        opp.Contract_Date__c = null;
        opp.Approval_Package__c = false;
        opp.submittal_approval_date__c = null;
        opp.submittal_submitted_date__c = null;

        opp.IsApproved__c = false;
        opp.Sent_for_Approval__c = false;
        
        opp.Invited__c = false;
        opp.Sent_to_TakeOff_Team__c = false;
        opp.Show_Account_Message__c = false;
        opp.Show_Contact_Message__c = false;
        opp.Show_Opportunity_Message__c = false;
        opp.Task__c = false;
        // opp.Specified_del__c = false;
        opp.Bill_Paid_Amount__c = 0;
        opp.TotalBills__c = 0;
        opp.TotalSalesOrderInOpp__c = 0;
        opp.SyncedQuoteId = null;
        opp.SyncedQuote = null;
        
        Opp.Billing_Terms_Name__c = OriginalOpportunity.Account.AcctSeed__Billing_Terms_Name__c;
        opp.Billing_Deposit__c = OriginalOpportunity.Account.Deposit__c;

        if(salesrepid != null) opp.Sales_Rep_O__c = salesrepid;
        if(ownerid != null) opp.ownerid = ownerid;
        if(opp.Type == 'Template') opp.LeadSource = null;
    }

    public PageReference saveOverride(){

        Pagereference page = null;

        try{
            insert opp;

            if(createproducts == 'yes'){

                // create opportunity lines also
                // 'order by sortorder__c,name,createddate asc];'
                String fieldstring = AllFields.Fields('OpportunityLineItem', 
                new List<string>{'TotalPrice'}); // second argument is field exceptions

                List<OpportunityLineItem> ExistingLines = 
                Database.query('select ' + fieldstring + ' from OpportunityLineItem where'+
                ' OpportunityId =:OppId order by sortorder,name,createddate asc');


                if(!ExistingLines.isEmpty()){
                    List<OpportunityLineItem> ClonedLines = 
                    ExistingLines.deepClone(false, false, false);

                    for(OpportunityLineItem line : ClonedLines){

                        line.OpportunityId = opp.id;
                        line.Size_Error__c = false;
                        //line.Allow_Custom_Image__c = false;
                        //line.Allow_Product_Description_Change__c = false;
                        //line.AlternateImageURL__c = null;

                    }

                    insert ClonedLines;

                }


                

            }

            page = new Pagereference('/'+opp.id);
            page.setRedirect(true);

            return page;
        }catch(Exception ex){

            String errorMsg = ex.getMessage();

            if(!errorMsg.contains('Duplicate opportunity')){

                string OnlyMsg = errorMsg.substringBetween(', ', ':');

                if(OnlyMsg != null){

                    OnlyMsg = OnlyMsg.capitalize();

                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, OnlyMsg);
                    ApexPages.addMessage(myMsg);
                }else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
                    ApexPages.addMessage(myMsg);
                }
            }

            system.debug('Exception has occured: ');
            system.debug(ex.getMessage());
        }

        return page;
    }
}