public class CopyQuotePDFController {
    /*
    
    public static void copyDocument(Quote quoteData){

        // get the total number of quote documents
        LIST<QuoteDocument> quoteDoc = [select Id, Name, Document, QuoteId from QuoteDocument where 
                                        QuoteId=: quoteData.Id order by createddate desc];
        
        if(quoteData.PDFnumber__c == '' || quoteData.PDFnumber__c == null){ 
        	quoteData.PDFnumber__c = '0';
        }
        
        // if the number of records that were copied is not equal to the number of QuoteDocument records then proceed
        if(Integer.valueOf(quoteData.PDFnumber__c) < quoteDoc.size()){
            
            // get the latest QuoteDocument 
            
            QuoteDocument qDoc = quoteDoc[0];
            
            Attachment attach = new Attachment();
            
            attach.Body = qDoc.Document;
            attach.Name = quoteData.QuoteNumber+'-' + qDoc.Name;
            attach.IsPrivate = false;
            attach.ParentId = quoteData.OpportunityId; // This is the record to which the pdf will be attached
            
            insert attach;
            
            // udpate the PDFnumber field's value

            quoteData.PDFnumber__c = quoteDoc.size()+'';
            
            update quoteData;  
        }
        

        
    }

*/

    public static void pageAction()
    {
        // call
        /*
        Quote quoteDetails = [select Id, Name, QuoteNumber, OpportunityId, PDFnumber__c from Quote 
                              where Id=:apexpages.currentPage().getparameters().get('Id')];
		*/
        //copyDocument(quoteDetails);
        
    }
}