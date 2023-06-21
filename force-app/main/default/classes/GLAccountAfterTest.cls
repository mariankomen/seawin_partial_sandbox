@isTest
public class GLAccountAfterTest {
  @testSetup
  static void CreateData() {
    AcctSeed__Accounting_Variable__c av = new AcctSeed__Accounting_Variable__c(
      Name = 'Seawin USA',
      AcctSeed__Type__c = 'GL Account Variable 1'
    );

    // Create Accounting Period
    AcctSeed__Accounting_Period__c ap = new AcctSeed__Accounting_Period__c();

    Date dates = date.today();

    Integer monthDays = date.daysInMonth(dates.year(), dates.month());

    String Added = dates.month() < 10
      ? '-0' + dates.month()
      : '-' + dates.month();

    ap.Name = dates.year() + Added;
    ap.AcctSeed__Status__c = 'Open';
    ap.AcctSeed__Start_Date__c = Date.newInstance(
      dates.year(),
      dates.month(),
      dates.day()
    );
    ap.AcctSeed__End_Date__c = Date.newInstance(
      dates.year(),
      dates.month(),
      monthDays
    );

    insert ap;

    AcctSeed__GL_Account__c gl = new AcctSeed__GL_Account__c();
    gl.name = 'Test GL Account';
    gl.AcctSeed__Type__c = 'Revenue';
    gl.AcctSeed__Sub_Type_1__c = 'Product Revenue';
    gl.AcctSeed__Sub_Type_2__c = 'Product Family 1';
    gl.AcctSeed__Bank__c = true;

    insert gl;

    AcctSeed__GL_Account__c gl2 = new AcctSeed__GL_Account__c();
    gl2.name = 'Test GL Account 2';
    gl2.AcctSeed__Type__c = 'Balance Sheet';
    gl2.AcctSeed__Sub_Type_1__c = 'Assets';
    gl2.AcctSeed__Sub_Type_2__c = 'Cash';
    gl2.AcctSeed__Bank__c = true;

    insert gl2;

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
  @isTest
  static void OnChangetoBalanceSheet() {
    AcctSeed__GL_Account__c gl = [
      SELECT
        id,
        AcctSeed__Type__c,
        AcctSeed__Sub_Type_1__c,
        AcctSeed__Sub_Type_2__c
      FROM AcctSeed__GL_Account__c
      WHERE name = 'Test GL Account'
      LIMIT 1
    ];

    gl.AcctSeed__Type__c = 'Balance Sheet';
    gl.AcctSeed__Sub_Type_1__c = 'Assets';
    gl.AcctSeed__Sub_Type_2__c = 'Cash';

    update gl;
  }
  @isTest
  static void OnChangetoOther() {
    AcctSeed__GL_Account__c gl = [
      SELECT
        id,
        AcctSeed__Type__c,
        AcctSeed__Sub_Type_1__c,
        AcctSeed__Sub_Type_2__c
      FROM AcctSeed__GL_Account__c
      WHERE name = 'Test GL Account 2'
      LIMIT 1
    ];

    gl.AcctSeed__Type__c = 'Revenue';
    gl.AcctSeed__Sub_Type_1__c = 'Product Revenue';
    gl.AcctSeed__Sub_Type_2__c = 'Product Family 1';

    update gl;
  }
}