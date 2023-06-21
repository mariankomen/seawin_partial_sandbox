public class PurchaseOrderPDFExtension {
    
    public string headerUrl {get; set;}
    public string footerUrl {get; set;}
    private Id poId {get; set;}
    public AcctSeedERP__Purchase_Order__c po {get; set;}
    public list<AcctSeedERP__Purchase_Order_line__c> lines {get; set;}
    public List<AcctSeed__Account_Payable__c> payable_lines {get; set;}


    public PurchaseOrderPDFExtension(apexpages.StandardController std){
        // soId = std.getId();
        poId = ApexPages.currentPage().getParameters().get('id');
        
        if(poId == null){
            
            poId = (Id)std.getId();
        }
        
        // get the purchase order record
        po = [SELECT Id, Name, Gl_Account_Variable_1__r.Name, 
            Gl_Account_Variable_1__r.Purchase_Order_Header__c, Gl_Account_Variable_1__r.Purchase_Order_Footer__c 
            FROM AcctSeedERP__Purchase_Order__c WHERE id=:poId limit 1];
        
        // get the lines
        lines = new list<AcctSeedERP__Purchase_Order_line__c>();
        
        lines = [SELECT Id, Name, AcctSeedERP__Product__r.name,
                 AcctSeedERP__Product__r.ProductImageURL__c,image__c,
                 AcctSeedERP__Purchase_Order__c, AcctSeedERP__Comment__c, 
                 AcctSeedERP__GL_Account_Variable_1__c, AcctSeedERP__GL_Account_Variable_2__c, 
                 AcctSeedERP__GL_Account_Variable_3__c, AcctSeedERP__GL_Account_Variable_4__c, 
                 AcctSeedERP__Product__c, AcctSeedERP__Project_Task__c, AcctSeedERP__Project__c, 
                 AcctSeedERP__Quantity_Unreceived__c, AcctSeedERP__Quantity__c, AcctSeedERP__Total__c, 
                 AcctSeedERP__Unit_Price__c, AcctSeedERP__Quantity_Received__c, Description__c, Sort_Order__c, 
                 Sales_Order_Line__c, Quantity_Received_Formula__c,
                 AcctSeedERP__Product__r.Product_Image_Short_URL__c,
                 Total_Price__c, Size__c, Quantity_Unreceived_Formula__c, Product_Code__c, Purchase_Price__c, 
                 Quantity_Formula__c FROM AcctSeedERP__Purchase_Order_Line__c where AcctSeedERP__Purchase_Order__c =:poId 
                 order by Sort_Order__c,name,createddate asc];

        



        payable_lines = [SELECT Id, 
                                Name,
                                AcctSeed__Type__c, 
                                Total_Secure__c, 
                                Paid_Date__c, 
                                AcctSeedERP__Purchase_Order__c,
                                AcctSeed__Total__c,
                                AcctSeed__Payee_Reference__c,
                                AcctSeed__Payment_Status__c,
                                AcctSeed__Accounting_Period__r.Name, 
                                AcctSeed__Payee__c, 
                                AcctSeed__Date__c, 
                                AcctSeed__Due_Date__c, 
                                AcctSeed__Paid_Amount__c,  
                                AcctSeed__Balance__c 
                        FROM AcctSeed__Account_Payable__c
                        WHERE AcctSeedERP__Purchase_Order__c=:poId];

        // PDF Logic
        headerUrl = getImageURL(po.Gl_Account_Variable_1__r.Purchase_Order_Header__c);
        footerUrl = getImageURL(po.Gl_Account_Variable_1__r.Purchase_Order_Footer__c);
        
    }


    public string getImageURL(string url){

        try{
            String imageURL = '';
            Matcher imgMatcher = Pattern.compile('<img(.+?)>').matcher(url);
            if(imgMatcher.find()) {
                String imageTag = imgMatcher.group();
                imageURL= imageTag.substringBetween(' src="', '"');
            }
            
            return imageURL.unescapeHtml4();
        }
        catch(Exception e){
            return e.getMessage() + e.getLineNumber();
        }
    }

}