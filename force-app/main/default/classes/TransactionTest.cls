@isTest
public class TransactionTest {
    
    @testSetup static void CreateData(){

            AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c(Name = 'Seawin USA',
            AcctSeed__Type__c = 'GL Account Variable 1');
        
        	insert av;

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
        
            Account acct = new Account();
            
            acct.Name = 'myAccount';
            acct.Type = 'Customer';
            acct.AcctSeed__GL_Account_Variable_1__c = av.id;
            
            insert acct;
			
        	list<AcctSeed__GL_Account__c> glList = new list<AcctSeed__GL_Account__c>();
        
            AcctSeed__GL_Account__c gl_normal = new AcctSeed__GL_Account__c();
            
            gl_normal.name = 'GL Account First';
            gl_normal.AcctSeed__type__c = 'Balance Sheet';
            gl_normal.AcctSeed__Sub_Type_1__c = 'Liabilities';
            gl_normal.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
            gl_normal.AcctSeed__Active__c = true;
            gl_normal.GL_Account_Variable_1__c = av.id;
            
            glList.add(gl_normal);
            
                    
            // ledger creation
            AcctSeed__GL_Account__c gl_checked = new AcctSeed__GL_Account__c();
            gl_checked.name = 'glaccount';
            gl_checked.AcctSeed__Type__c = 'Expense';
            gl_checked.AcctSeed__Sub_Type_1__c = 'Facilities';
            gl_checked.AcctSeed__Sub_Type_2__c = 'Rent';
            gl_checked.AcctSeed__Bank__c = true;
            gl_checked.GL_Account_Variable_1__c = av.id;
            
            glList.add(gl_checked);
            
            AcctSeed__GL_Account__c vch = new AcctSeed__GL_Account__c();
            vch.name = '2010-Vouchers Payable';
            vch.AcctSeed__Type__c = 'Balance Sheet';
            vch.AcctSeed__Sub_Type_1__c = 'Liabilities';
            vch.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
            vch.AcctSeed__Active__c = true;
            vch.GL_Account_Variable_1__c = av.id;
            
            glList.add(vch);
            
            AcctSeed__GL_Account__c vch1 = new AcctSeed__GL_Account__c();
            vch1.name = '2010-Vouchers Payable1';
            vch1.AcctSeed__Type__c = 'Balance Sheet';
            vch1.AcctSeed__Sub_Type_1__c = 'Liabilities';
            vch1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
            vch1.AcctSeed__Active__c = true;
            vch1.GL_Account_Variable_1__c = av.id;
            
            glList.add(vch1);
            
            AcctSeed__GL_Account__c vch2 = new AcctSeed__GL_Account__c();
            vch2.name = '2010-Vouchers Payable2';
            vch2.AcctSeed__Type__c = 'Balance Sheet';
            vch2.AcctSeed__Sub_Type_1__c = 'Liabilities';
            vch2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
            vch2.AcctSeed__Active__c = true;
            vch2.GL_Account_Variable_1__c = av.id;
            
            glList.add(vch2);
            
            AcctSeed__GL_Account__c vch3 = new AcctSeed__GL_Account__c();
            vch3.name = '2010-Vouchers Payable3';
            vch3.AcctSeed__Type__c = 'Balance Sheet';
            vch3.AcctSeed__Sub_Type_1__c = 'Liabilities';
            vch3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
            vch3.AcctSeed__Active__c = true;
            vch3.GL_Account_Variable_1__c = av.id;
            
            glList.add(vch3);
            
            AcctSeed__GL_Account__c gl1 = new AcctSeed__GL_Account__c();
            gl1.name = '2010-Vouchers Payable1';
            gl1.AcctSeed__Type__c = 'Balance Sheet';
            gl1.AcctSeed__Sub_Type_1__c = 'Liabilities';
            gl1.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
            gl1.AcctSeed__Active__c = true;
            gl1.GL_Account_Variable_1__c = av.id;
            
            glList.add(gl1);
            
            AcctSeed__GL_Account__c gl2 = new AcctSeed__GL_Account__c();
            gl2.name = '2010-Vouchers Payable2';
            gl2.AcctSeed__Type__c = 'Balance Sheet';
            gl2.AcctSeed__Sub_Type_1__c = 'Liabilities';
            gl2.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
            gl2.AcctSeed__Active__c = true;
            gl2.GL_Account_Variable_1__c = av.id;
            
            glList.add(gl2);
            
            AcctSeed__GL_Account__c gl3 = new AcctSeed__GL_Account__c();
            gl3.name = '2010-Vouchers Payable3';
            gl3.AcctSeed__Type__c = 'Balance Sheet';
            gl3.AcctSeed__Sub_Type_1__c = 'Liabilities';
            gl3.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
            gl3.AcctSeed__Active__c = true;
            gl3.GL_Account_Variable_1__c = av.id;
            
            glList.add(gl3);
            
            AcctSeed__GL_Account__c gl4 = new AcctSeed__GL_Account__c();
            gl4.name = '2010-Vouchers Payable4';
            gl4.AcctSeed__Type__c = 'Balance Sheet';
            gl4.AcctSeed__Sub_Type_1__c = 'Liabilities';
            gl4.AcctSeed__Sub_Type_2__c = 'Current Liabilities';
            gl4.AcctSeed__Active__c = true;
            gl4.GL_Account_Variable_1__c = av.id;
            
            glList.add(gl4);
            
            insert glList;

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
            ledger.AcctSeed__Default_Bank_Account__c = gl_checked.id;
            ledger.AcctSeed__Default_Billing_Format__c = abf.id; 
            ledger.AcctSeed__Default_Purchase_Order_Format__c = abf.id;
            ledger.AcctSeed__Default_Packing_Slip_Format__c = abf.id;
            
            
            insert ledger;
        
                    // Create Accounting Settings
            AcctSeed__Accounting_Settings__c custm = new AcctSeed__Accounting_Settings__c();
        
            custm.AcctSeed__Vouchers_Payable_GL_Account__c = glList[3].id;
            custm.AcctSeed__AP_Control_GL_Account__c= glList[6].id; 
            custm.AcctSeed__AR_Control_GL_Account__c = glList[4].id;
            custm.AcctSeed__Current_Year_Earnings_GL_Account__c = glList[7].id; 
            custm.AcctSeed__Default_Ledger__c = ledger.id; 
            custm.AcctSeed__Retained_Earnings_GL_Account__c = glList[8].id;
            custm.AcctSeed__Revenue_GL_Account__c = glList[5].id; 
            custm.AcctSeed__Unapplied_Cash_GL_Account__c = glList[9].id;
                
                
            insert custm;
        
            // create product
            Product2 prod = new Product2();
            
            prod.Name = 'myProduct';
            prod.ProductCode = 'ABC123';
            prod.AcctSeed__Unit_Cost__c = 100;
            prod.IsActive = true;
            prod.AcctSeed__Inventory_Type__c = 'Purchased';
            prod.AcctSeed__Expense_GL_Account__c = gl_normal.id;
            prod.AcctSeed__Inventory_GL_Account__c = gl_normal.id;
            prod.AcctSeed__Revenue_GL_Account__c = gl_normal.id;
            prod.Type__c = 'Product';
            
            insert prod;
        
            Id pricebookId = Test.getStandardPricebookId();
            
            // create standard price book entry
            PricebookEntry pbe = new PricebookEntry();
            
            pbe.Pricebook2Id = pricebookId;
            pbe.Product2Id = prod.Id;
            pbe.UnitPrice = 100;
            pbe.IsActive = true;
            
            insert pbe;
            
        	// create a sales order
            AcctSeedERP__Sales_Order__c salesorder = new AcctSeedERP__Sales_Order__c(); 
            
            //salesorder.name = 'testSalesOrder';
            salesorder.AcctSeedERP__Customer__c = acct.Id;
            salesorder.AcctSeedERP__Status__c = 'Open';
            salesorder.AcctSeedERP__Ledger__c = ledger.id;
            salesorder.GL_Account_Variable_1__c = av.Id;
            
            insert salesorder;
        
            AcctSeedERP__Sales_Order_Line__c soline = new AcctSeedERP__Sales_Order_Line__c(); 
            
            soline.AcctSeedERP__Sales_Order__c = salesorder.id;
            soline.AcctSeedERP__Unit_Price__c = 1;
            soline.AcctSeedERP_Description__c = 'This is salesorder line item';
            soline.AcctSeedERP__Product__c = prod.id;
            soline.AcctSeedERP__Quantity_Ordered__c = 1;
        
        	insert soline;

        	// Create Billing
        	AcctSeed__Billing__c billing = new AcctSeed__Billing__c();
        
            billing.AcctSeed__Status__c = 'Approved';
            billing.AcctSeed__PDF_Email_Status__c = 'Unsent';
            billing.AcctSeed__Billing_Format__c = abf.id;
            billing.AcctSeedERP__Sales_Order__c = salesorder.id; 
            billing.AcctSeed__Date__c = Date.Today();
            billing.AcctSeed__Due_Date2__c = Date.Today();
            billing.AcctSeed__Ledger__c = salesorder.AcctSeedERP__Ledger__c;
            billing.AcctSeed__Opportunity__c = salesorder.AcctSeedERP__Opportunity__c;
            billing.AcctSeed__Customer__c = salesorder.AcctSeedERP__Customer__c;
            billing.AcctSeed__Accounting_Period__c = ap.id;
    
            insert billing;
            
            AcctSeed__Billing_Line__c bline = new AcctSeed__Billing_Line__c();
            bline.AcctSeed__Billing__c = billing.id;
            bline.AcctSeed__Date__c = date.today();
            bline.AcctSeed__Hours_Units__c = 1;
            bline.AcctSeed__Product__c = prod.id;
            bline.AcctSeedERP__Sales_Order_Line__c = soline.id;
            bline.AcctSeed__Rate__c = soline.AcctSeedERP__Unit_Price__c;
            bline.Item_Description__c = soline.Item_Description__c;
            
            insert bline;
        
        	AcctSeed__Cash_Receipt__c cash_receipt = new AcctSeed__Cash_Receipt__c();
        	cash_receipt.AcctSeed__Amount__c = 1;
            cash_receipt.AcctSeed__Account__c = salesorder.AcctSeedERP__Customer__c;
            cash_receipt.AcctSeed__Receipt_Date__c = Date.today();
            cash_receipt.AcctSeed__Payment_Reference__c = 'Test Reference Number';
        
        	insert cash_receipt;
        
        	AcctSeed__Billing_Cash_Receipt__c billing_cash = new AcctSeed__Billing_Cash_Receipt__c();
        	billing_cash.AcctSeed__Billing__c = billing.id;
        	billing_cash.AcctSeed__Applied_Amount__c = 1;
            billing_cash.AcctSeed__Cash_Receipt__c = cash_receipt.id;
        
        	insert billing_cash;
   
            /*
            AcctSeed__Transaction__c trnc = new AcctSeed__Transaction__c();
        
            trnc.AcctSeed__Amount__c = 1;
            trnc.AcctSeed__GL_Account__c = gl.id;
        
            insert trnc;
			*/
    }
    
    @isTest static void runTests(){
        List<AcctSeed__Transaction__c> trnc = [select id, AcctSeed__GL_Account__r.GL_Account_Variable_1__c,
                                         AcctSeed__GL_Account_Variable_1__c from
                                              AcctSeed__Transaction__c];
        
        for(AcctSeed__Transaction__c t : trnc){
            
            System.assertEquals(t.AcctSeed__GL_Account__r.GL_Account_Variable_1__c, 
                            t.AcctSeed__GL_Account_Variable_1__c);
        }
    }
}