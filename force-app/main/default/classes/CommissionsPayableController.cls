public class CommissionsPayableController {
  public set<id> IDs { get; set; }
  public String soId { get; set; }
  public AcctSeedERP__Sales_Order__c so { get; set; }
  public Opportunity opportunityRecord {get;set;}
  public List<Sales_Order_Commissions__c> commissions { get; set; }
  public Id parentRecordId {get;set;}
  public String sobjectType {get;set;}
  public Boolean isLines { get; set; }
  public Boolean AlreadyPaid { get; set; }

  public String PayType { get; set; }
  public String depositbill { get; set; }
  public Decimal Amount {
    get {
      if (Amount == null) {
        Amount = 0.00;
      }
      return Amount;
    }
    set;
  }

  public list<Wrapper> SOCWrapper { get; set; }

  public AcctSeed__Account_Payable__c temp { get; set; } // temp record for date fields
  //public AcctSeedERP__Purchase_Order__c poRecord {get; set;}

  public AcctSeed__Account_Payable_Line__c paylineTemp { get; set; }

  public CommissionsPayableController() {
    
    paylineTemp = new AcctSeed__Account_Payable_Line__c();
    temp = new AcctSeed__Account_Payable__c();
    SOCWrapper = new List<Wrapper>();
    temp.AcctSeed__Date__c = Date.today(); // issue date
    temp.AcctSeed__Due_Date__c = Date.today();
    // due date
    AlreadyPaid = false;

    commissions = new List<Sales_Order_Commissions__c>();

    soId = ApexPages.currentPage().getParameters().get('id');
    integer count = Integer.valueOf(
      ApexPages.currentPage().getParameters().get('count')
    );
    Id recordId = (Id)soId;
    parentRecordId = recordId;
    sobjectType = String.valueOf(recordId.getSobjectType());

    if(sobjectType == 'Opportunity'){
      opportunityRecord = [SELECT Id, Name, AccountId, Account.AcctSeed__Default_Expense_GL_Account__c FROM Opportunity WHERE Id=:recordId LIMIT 1];
    }else if(sobjectType == 'AcctSeedERP__Sales_Order__c'){
      so = [
        SELECT id, name, AcctSeedERP__Customer__c, 
        AcctSeedERP__Customer__r.AcctSeed__Default_Expense_GL_Account__c,
        AcctSeedERP__Ledger__c, AcctSeedERP__Opportunity__c, AcctSeedERP__Opportunity__r.Name
        FROM AcctSeedERP__Sales_Order__c
        WHERE id = :soId
        LIMIT 1
      ];
    }
    
    



    List<AcctSeed__GL_Account__c> commissionsGlAccount = 
    [select id from AcctSeed__GL_Account__c where name = '6610-Commissions' Limit 1];

    paylineTemp.AcctSeed__Expense_GL_Account__c = !commissionsGlAccount.isEmpty() ? commissionsGlAccount[0].Id : null;

    IDs = new Set<Id>();

    for (integer i = 0; i < count; i++) {
      Id sub = Id.ValueOf(
        ApexPages.currentPage().getParameters().get('id' + i)
      );
      IDs.add(sub);
    }

    // IF sales rep team THEN owner AS payee => employee
    // IF sales rep individual THEN sales rep company AS payee => vendor
    // IF referral sales rep THEN related contact AS payee => contact
    // IF manufacturer rep THEN itself AS payee => vendor

    // Owner__c, Sales_Rep_Company_Name__c, 
    

    // IDs contains all the ids for selected sales order commissions which are to be paid

    if (!IDs.isEmpty()) {
      String fields = AllFields.Fields(
        'Sales_Order_Commissions__c',
        new List<String>()
      );

      fields += ',Billing_Cash_Receipt__r.Name, Billing_Credit_Memo__r.Name, owner__r.name, referral_sales_rep__r.name, ';
      fields += 'manufacturer_rep__r.name, specified_rep__r.name ';

      commissions = Database.query(
        'Select ' +
        fields +
        ' From Sales_Order_Commissions__c where Id in:IDs'
      );
    }

    if (commissions.isEmpty()) {
      isLines = false;
    } else {
      isLines = true;

      // make a map of the associated billing lines
      list<AcctSeed__Account_Payable__c> pybs = new List<AcctSeed__Account_Payable__c>([SELECT Id,
                                                                                                Name,
                                                                                                AcctSeed__Total__c,
                                                                                                Sales_Order_Commissions__c
                                                                                        FROM AcctSeed__Account_Payable__c
                                                                                        WHERE (Sales_Order__c =: parentRecordId
                                                                                        OR Opportunity__c =: parentRecordId)
                                                                                        AND AcctSeed__Type__c = 'Invoice'
                                                                                        AND Sales_Order_Commissions__c in:IDs ]
                                                                                      );
      map<id, Decimal> pybsMap = new Map<id, Decimal>();
      if (!pybs.IsEmpty()) {
        // make a map with key as sol id and value as bol
        for (AcctSeed__Account_Payable__c pyb : pybs) {

          Decimal Total = pyb.AcctSeed__Total__c;

          if (pybsMap.containsKey(pyb.Sales_Order_Commissions__c)) {
            decimal existingTotal = pybsMap.get(
              pyb.Sales_Order_Commissions__c
              );

              Total += existingTotal;

            pybsMap.put(pyb.Sales_Order_Commissions__c, Total);
          } else {
            pybsMap.put(pyb.Sales_Order_Commissions__c, Total);
          }
        }
      }
      // sales order commissions
      Integer paidItems = 0;
      map<id, Sales_Order_Commissions__c> commissionsMap = new map<id, Sales_Order_Commissions__c>(commissions);

      for(Sales_Order_Commissions__c item : commissions){

        Decimal ExistingPayableTotal = pybsMap.get(item.id);

        if (ExistingPayableTotal >= item.Commission_Amount__c) {
          commissionsMap.remove(item.id);
        }
      }

        if(commissionsMap.size() > 0){

          for (Sales_Order_Commissions__c line : commissionsMap.values()) {
            // get the paying record for the current pol to fill paidAmount and UnpaidAmount
            Decimal TotalPayable = pybsMap.get(line.id);

            Decimal PaidAmount = 0.00;
            Decimal UnPaidAmount = 0.00;
            Decimal PayAmount = 0.00;

            if (TotalPayable != null && TotalPayable != 0) {
              PaidAmount = TotalPayable;
              UnPaidAmount = 0.00;

              // remove from linesMap if all has been billed for the sol
              UnPaidAmount = line.Commission_Amount__c - PaidAmount;
            } else {
              UnPaidAmount = line.Commission_Amount__c;
            }
            
            socWrapper.add(
              new Wrapper(line, PaidAmount, UnPaidAmount, PayAmount, 0, line.Role__c, 
              (line.Referral_Sales_Rep__c != null ? line.referral_sales_rep__r.Name : 
              line.Owner__c != null ? line.Owner__r.Name : line.Manufacturer_Rep__r.Name))
            );
          }
      }else{

        AlreadyPaid = true;
      }
    }
  }

  public PageReference createPayable(){

      String payeReference = sobjectType == 'Opportunity' ? opportunityRecord.Name + ' - ' + System.Now().formatLong() 
                          : sobjectType == 'AcctSeedERP__Sales_Order__c' && so.AcctSeedERP__Opportunity__c != null ? so.AcctSeedERP__Opportunity__r.Name + ' - ' + System.Now().formatLong()
                          : sobjectType == 'AcctSeedERP__Sales_Order__c' && so.AcctSeedERP__Opportunity__c == null ? so.Name + ' - ' + System.Now().formatLong() : '';

                          system.debug('payeReference: '+payeReference);
    List<AcctSeed__Account_Payable__c> payables = new List<AcctSeed__Account_Payable__c>();
    
    //list<AcctSeed__Billing_Format__c> format = [select id from AcctSeed__Billing_Format__c where Name = 'Default Billing Product' limit 1];
    
    SavePoint sp = Database.setSavepoint();
    try{
        
        // construct accounting period  
        // Name = year-month
        Date enteredDate = temp.AcctSeed__date__c;
        String acctperiodDate = enteredDate.year() + ((enteredDate.month() < 10) ? '-0' : '-') + enteredDate.month();
        // get the current accounting period which is open
        list<AcctSeed__Accounting_Period__c> acctPeriod = [SELECT AcctSeed__Status__c, Name, Id, AcctSeed__End_Date__c, 
                                                           AcctSeed__Start_Date__c 
                                                           FROM AcctSeed__Accounting_Period__c where 
                                                           Name =:acctperiodDate and AcctSeed__Status__c = 'Open' limit 1];
        
        if(acctPeriod.IsEmpty()){
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error, 
                                                       'No Accounting Period has been set up for this Issue/Payable Date'+ 
                                                       ' or the Accounting Period status is closed. Please first set up'+ 
                                                       ' Accounting Period for this date in Accounting Seed.'));
            return null;
        }

        map<id, AcctSeed__Account_Payable__c> SOCtoPayableMap = new map<id, AcctSeed__Account_Payable__c>();

        Id rtId = Schema.SObjectType.AcctSeed__Account_Payable__c.getRecordTypeInfosByName().get('Commission Payable').getRecordTypeId();

        for(Wrapper w : socWrapper){
          AcctSeed__Account_Payable__c payable = new AcctSeed__Account_Payable__c();
          
          payable.AcctSeed__Accounting_Period__c = (!acctPeriod.IsEmpty()) ? acctPeriod[0].id : null; 
          payable.AcctSeed__Date__c  = temp.AcctSeed__date__c;
          payable.AcctSeed__Due_Date__c = temp.AcctSeed__Due_Date__c;
          payable.AcctSeed__Status__c = 'Approved';
          payable.AcctSeed__Ledger__c = sobjectType == 'AcctSeedERP__Sales_Order__c' ? so.AcctSeedERP__Ledger__c : null;
          payable.sales_Order__c = sobjectType == 'AcctSeedERP__Sales_Order__c' ? parentRecordId : null;
          payable.Opportunity__c = sobjectType == 'Opportunity' ? parentRecordId : so.AcctSeedERP__Opportunity__c;
          payable.sales_order_commissions__c = w.soc.id;
          payable.Manufacturer_Rep__c = w.soc.Manufacturer_Rep__c;
          payable.referral_sales_rep__c = w.soc.Referral_Sales_Rep__c;
          payable.Specified_Rep__c = w.soc.Specified_Rep__c;
          payable.owner__c = w.soc.Owner__c;
          payable.recordtypeId = rtId;

          // payable payee assignment
          // Referral_Sales_Rep__c,Owner__c,Sales_Rep_Company_Name__c,Manufacturer_Rep__c
          
          payable.AcctSeed__Vendor__c = w.soc.Sales_Rep_Company_Name__c != null ? w.soc.Sales_Rep_Company_Name__c : 
          w.soc.Manufacturer_Rep__c != null ? w.soc.Manufacturer_Rep__c : 
          w.soc.Specified_Rep__c != null ? w.soc.Specified_Rep__c : null;
            
          payable.AcctSeed__Employee__c = w.soc.Owner__c != null ? w.soc.Owner__c : 
          w.soc.referral_sales_rep__c != null ? w.soc.referral_sales_rep__c : null;
          

          
          String ref = sobjectType == 'Opportunity' ? opportunityRecord.Name + ' - ' + System.Now()
            : sobjectType == 'AcctSeedERP__Sales_Order__c' && so.AcctSeedERP__Opportunity__c != null ? so.AcctSeedERP__Opportunity__r.Name + ' - ' + System.Now()
            : sobjectType == 'AcctSeedERP__Sales_Order__c' && so.AcctSeedERP__Opportunity__c == null ? so.Name + ' - ' + System.Now() : '';

          payable.AcctSeed__Payee_Reference__c = ref;

          payable.Pay_Type__c = (payType == 'percent') ? 'Percent' : 'Amount';

          Datetime nowIs = System.Now();
          Datetime nowPlusOneSec = System.now().addSeconds(1);
          while(nowIs != nowPlusOneSec){
            nowIs = system.now();
          }
          payables.add(payable);  
        }
                
        insert payables;
        map<id, AcctSeed__Account_Payable__c> payableMap = new 
        map<id, AcctSeed__Account_Payable__c>(payables);

        list<AcctSeed__Account_Payable_Line__c> paylines = new list<AcctSeed__Account_Payable_Line__c>();
        // now insert the billing lines
        for(AcctSeed__Account_Payable__c payb : [select id, sales_order__r.GL_Account_Variable_1__c,Sales_Order_Commissions__c
        from AcctSeed__Account_Payable__c where id in:payableMap.keyset()]){

          SOCtoPayableMap.put(payb.sales_order_commissions__c, payb);
        }
        
        for(Wrapper w : socWrapper){
            AcctSeed__Account_Payable__c paybl = SOCtoPayableMap.get(w.soc.id);

                if(paybl == null) continue;

                AcctSeed__Account_Payable_Line__c payline = new AcctSeed__Account_Payable_Line__c();

                payline.AcctSeed__Account_Payable__c = paybl.id;
                payline.AcctSeed__Amount__c = w.PayAmountHidden.setScale(2, System.RoundingMode.HALF_EVEN);
                payline.AcctSeed__Date__c = date.today();
                payline.AcctSeed__Expense_GL_Account__c = paylineTemp.AcctSeed__Expense_GL_Account__c;
                payline.AcctSeed__GL_Account_Variable_1__c = paybl.sales_order__r.GL_Account_Variable_1__c;
                payline.AcctSeed__Product__c = null;
                payline.AcctSeed__Quantity__c = 1;
                payline.Item_description__c = 'Commission Payment to the ' + w.role + ' : ' + w.holder;
                
                paylines.add(payline);             
        }
        insert paylines;

        PageReference page = new PageReference('/'+payables[0].id+'/e?retURL='+payables[0].id);

        if(payables.size() > 1){

          String PayablesIdString = '';
                
                integer k = 0;
                for(AcctSeed__Account_Payable__c pybl : payables){
                    
                  PayablesIdString += '&id' + k + '=' + pybl.id;
                    k++;
                    
                }

          page = new PageReference('/apex/NewPayablesPage?sfdc.tabName=01r63000000OfUJ&count=' +
          payables.size()+ '' + PayablesIdString + '&soId=' + parentRecordId);

        }
      
        page.setRedirect(true);
        
        return page;
    }catch(Exception ex){
        
        Database.rollback(sp);
        String errorMsg = ex.getMessage();

        string TruncatedMsg = errorMsg.substringBetween(', ', ':');

        if(TruncatedMsg != null){

          TruncatedMsg = TruncatedMsg.capitalize();

            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, TruncatedMsg);
            ApexPages.addMessage(myMsg);
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg);
            ApexPages.addMessage(myMsg);
        }
        system.debug(ex.getMessage());
        
    }
    
    return null;
}

  public class Wrapper {
    public Sales_Order_Commissions__c soc { get; set; }
    public Decimal paidAmount { get; set; }
    public Decimal unpaidAmount { get; set; }
    public Decimal payTypeVal { get; set; }
    public Decimal PayAmount { get; set; }
    public Decimal PayAmountHidden { get; set; }
    public string role {get; set;}
    public string holder {get; set;}

    public wrapper(
      Sales_Order_Commissions__c line,
      Decimal bt,
      Decimal ut,
      Decimal btm,
      decimal hiddenmount,
      string r,
      String h
    ) {
      soc = line;
      paidAmount = bt;
      unpaidAmount = ut;
      payTypeVal = unpaidAmount == 0 ? null : 100;
      payAmount = btm;
      payAmountHidden = hiddenmount;
      role = r;
      holder = h;
    }
  }
}