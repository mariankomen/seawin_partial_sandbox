@isTest
public class JournalEntryLineRollupTest {
    
    @testSetup static void CreateData(){

            AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',
            AcctSeed__Type__c = 'GL Account Variable 1');

            // Create Accounting Period
            AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();
        
            Date dates = date.today();
            
            Integer monthDays = date.daysInMonth(dates.year(), dates.month());
        
        	String Added = dates.month() < 10 ? '-0' + dates.month() : '-' + dates.month();

            ap.Name = dates.year() + Added;
            ap.AcctSeed__Status__c = 'Open';
            ap.AcctSeed__Start_Date__c = Date.newInstance(dates.year(), dates.month(), dates.day());
            ap.AcctSeed__End_Date__c = Date.newInstance(dates.year(), dates.month(), monthDays);
            
            insert ap;

            AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
            gl.name = 'Test GL Account';
            gl.AcctSeed__Type__c = 'Balance Sheet';
            gl.AcctSeed__Sub_Type_1__c = 'Assets';
            gl.AcctSeed__Sub_Type_2__c = 'Cash';
            gl.AcctSeed__Bank__c = true;
            
            insert gl;

            // Create Ledger
            AcctSeed__Billing_Format__c abf = new AcctSeed__Billing_Format__c();
            
            abf.Name = 'Test PDF Format';
            abf.AcctSeed__Type__c = 'Purchase Order';
            abf.AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF';
            abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
            
            insert abf;
            
            AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
            
            ledger.Name = 'myLedger';
            ledger.AcctSeed__Type__c = 'Transactional';
            ledger.AcctSeed__Billing_Activity_Statement_Format__c = abf.id;
            ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = abf.id;
            ledger.AcctSeed__Default_Bank_Account__c = gl.id;
            ledger.AcctSeed__Default_Billing_Format__c = abf.id; 
            ledger.AcctSeed__Default_Purchase_Order_Format__c = abf.id;
            ledger.AcctSeed__Default_Packing_Slip_Format__c = abf.id;
            
            
            insert ledger;

            // For Journal Entry

            AcctSeed__Journal_Entry__c jl = new AcctSeed__Journal_Entry__c();

            jl.name = 'Test Journal Entry';
            jl.Acctseed__Journal_Date__c = Date.today();
            jl.AcctSeed__status__c = 'Approved';
            jl.AcctSeed__Ledger__c = ledger.id;
            jl.AcctSeed__Accounting_Period__c = ap.id;

            insert jl;

            List<AcctSeed__Journal_Entry_Line__c> jelList = new List<AcctSeed__Journal_Entry_Line__c>();

            AcctSeed__Journal_Entry_Line__c jel = new AcctSeed__Journal_Entry_Line__c();

            jel.AcctSeed__Journal_Entry__c = jl.id;
            jel.AcctSeed__GL_Account_Variable_1__c = av.id;
            jel.AcctSeed__Debit__c = 1;
            //jel.AcctSeed__Credit__c = 1;
            jel.AcctSeed__GL_Account__c = gl.id;

            jelList.add(jel);

            AcctSeed__Journal_Entry_Line__c jel2 = new AcctSeed__Journal_Entry_Line__c();

            jel2.AcctSeed__Journal_Entry__c = jl.id;
            jel2.AcctSeed__GL_Account_Variable_1__c = av.id;
            //jel2.AcctSeed__Debit__c = 1;
            jel2.AcctSeed__Credit__c = 1;
            jel2.AcctSeed__GL_Account__c = gl.id;

            jelList.add(jel2);

            insert jelList;

            
            // For Recurring Journal Entry
            AcctSeed__Recurring_Journal_Entry__c rjl = new AcctSeed__Recurring_Journal_Entry__c();

            rjl.name = 'Test Journal Entry';
            rjl.AcctSeed__Journal_Entry_Frequency__c = 'Monthly'; 
            rjl.AcctSeed__Next_Journal_Entry_Date__c = Date.today();
            rjl.AcctSeed__status__c = 'Active';
            rjl.AcctSeed__Ledger__c = ledger.id;
            //rjl.AcctSeed__Accounting_Period__c = ap.id;
    
            insert rjl;
    
            List<AcctSeed__Recurring_Journal_Entry_Line__c> rjelList = new List<AcctSeed__Recurring_Journal_Entry_Line__c>();
    
            AcctSeed__Recurring_Journal_Entry_Line__c rjel = new AcctSeed__Recurring_Journal_Entry_Line__c();
    
            rjel.AcctSeed__Recurring_Journal_Entry__c = rjl.id;
            rjel.AcctSeed__GL_Account_Variable_1__c = av.id;
            rjel.AcctSeed__Debit__c = 1;
            //rjel.AcctSeed__Credit__c = 1;
            rjel.AcctSeed__GL_Account__c = gl.id;
    
            rjelList.add(rjel);
    
            AcctSeed__Recurring_Journal_Entry_Line__c rjel2 = new AcctSeed__Recurring_Journal_Entry_Line__c();
    
            rjel2.AcctSeed__Recurring_Journal_Entry__c = rjl.id;
            rjel2.AcctSeed__GL_Account_Variable_1__c = av.id;
            //rjel2.AcctSeed__Debit__c = 1;
            rjel2.AcctSeed__Credit__c = 1;
            rjel2.AcctSeed__GL_Account__c = gl.id;
    
            rjelList.add(rjel2);
    
            insert rjelList;
        
    }
    @isTest static void OnUpdate(){
        AcctSeed__GL_Account__c gl = [select name from AcctSeed__GL_Account__c where Name = 'Test GL Account' limit 1];

        // update journal entry lines

        List<AcctSeed__Journal_Entry_Line__c> jels = [select id, AcctSeed__Credit__c, AcctSeed__debit__c from 
        AcctSeed__Journal_Entry_Line__c where AcctSeed__GL_Account__c =:gl.id];

        for(AcctSeed__Journal_Entry_Line__c jel : jels){

            if(jel.AcctSeed__debit__c != null){
                jel.AcctSeed__debit__c = 2;
            }else if(jel.AcctSeed__credit__c != null){
                jel.AcctSeed__credit__c = 2;
            }
        }

        update jels;

        // update recurring journal entry lines

        List<AcctSeed__Recurring_Journal_Entry_Line__c> rjels = [select id, AcctSeed__Credit__c, AcctSeed__debit__c from 
        AcctSeed__Recurring_Journal_Entry_Line__c where AcctSeed__GL_Account__c =:gl.id];

        for(AcctSeed__Recurring_Journal_Entry_Line__c jel : rjels){

            if(jel.AcctSeed__debit__c != null){
                jel.AcctSeed__debit__c = 2;
            }else if(jel.AcctSeed__credit__c != null){
                jel.AcctSeed__credit__c = 2;
            }
        }

        update rjels;
    }
    @isTest static void OnDelete(){
        AcctSeed__GL_Account__c gl = [select name from AcctSeed__GL_Account__c where Name = 'Test GL Account' limit 1];

        // delete journal entry lines
        List<AcctSeed__Journal_Entry_Line__c> jels = [select id, AcctSeed__Credit__c, AcctSeed__debit__c from 
        AcctSeed__Journal_Entry_Line__c where AcctSeed__GL_Account__c =:gl.id];

        delete jels;

        List<AcctSeed__Recurring_Journal_Entry_Line__c> rjels = [select id, AcctSeed__Credit__c, AcctSeed__debit__c from 
        AcctSeed__Recurring_Journal_Entry_Line__c where AcctSeed__GL_Account__c =:gl.id];

        delete rjels;

    }
}