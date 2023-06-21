public class OpportunityStageHandler {
  public static void CreateSO(LIST<AcctSeedERP__Sales_Order__c> data) {
    Map<Id, AcctSeedERP__Sales_Order__c> OppID = new Map<Id, AcctSeedERP__Sales_Order__c>();

    for (AcctSeedERP__Sales_Order__c so : data) {
      if (so.AcctSeedERP__Opportunity__c != null) {
        OppID.put(so.AcctSeedERP__Opportunity__c, so);
      }
    }
    LIST<Opportunity> oppList = new List<Opportunity>();
    if (OppID.size() > 0) {
      oppList = [
        SELECT id, name, TotalSalesOrderInOpp__c
        FROM Opportunity
        WHERE Id IN :OppID.keyset()
      ];
    }
    if (!oppList.isEmpty()) {
      for (Opportunity op : oppList) {
        if (op.TotalSalesOrderInOpp__c == null)
          op.TotalSalesOrderInOpp__c = 0;
        op.TotalSalesOrderInOpp__c++;
      }
      update oppList;
    }
  }

  public static void UpdateSO(
    LIST<AcctSeedERP__Sales_Order__c> oldData,
    LIST<AcctSeedERP__Sales_Order__c> newData
  ) {
    Map<Id, AcctSeedERP__Sales_Order__c> OppNewID = new Map<Id, AcctSeedERP__Sales_Order__c>();
    Map<Id, AcctSeedERP__Sales_Order__c> OppOldID = new Map<Id, AcctSeedERP__Sales_Order__c>();
    integer i = 0;

    for (AcctSeedERP__Sales_Order__c soNew : newData) {
      if (
        soNew.AcctSeedERP__Opportunity__c !=
        oldData[i].AcctSeedERP__Opportunity__c
      ) {
        //Means there is an old Opp only which needs to be decremented
        if (soNew.AcctSeedERP__Opportunity__c == null) {
          OppOldID.put(oldData[i].AcctSeedERP__Opportunity__c, oldData[i]);
        } else if (oldData[i].AcctSeedERP__Opportunity__c == null) {
          //Means there is a new Opp only which needs to be incremented
          OppNewID.put(soNew.AcctSeedERP__Opportunity__c, soNew);
        } else {
          //Means there is a new & old Opp which needs to be incremented & decremented respectively
          OppNewID.put(soNew.AcctSeedERP__Opportunity__c, soNew);
          OppOldID.put(oldData[i].AcctSeedERP__Opportunity__c, oldData[i]);
        }
      }
      i++;
    }

    LIST<Opportunity> oppListToBIncremented = new List<Opportunity>();
    LIST<Opportunity> oppListToBDecremented = new List<Opportunity>();

    if (OppNewID.size() > 0) {
      oppListToBIncremented = [
        SELECT id, name, TotalSalesOrderInOpp__c
        FROM Opportunity
        WHERE Id IN :OppNewID.keyset()
      ];
    }
    if (OppOldID.size() > 0) {
      oppListToBDecremented = [
        SELECT id, name, TotalSalesOrderInOpp__c
        FROM Opportunity
        WHERE Id IN :OppOldID.keyset()
      ];
    }

    if (!oppListToBIncremented.isEmpty()) {
      for (Opportunity op : oppListToBIncremented) {
        if (op.TotalSalesOrderInOpp__c == null)
          op.TotalSalesOrderInOpp__c = 0;
        op.TotalSalesOrderInOpp__c++;
      }
      update oppListToBIncremented;
    }
    if (!oppListToBDecremented.isEmpty()) {
      for (Opportunity op : oppListToBDecremented) {
        if (op.TotalSalesOrderInOpp__c > 0)
          op.TotalSalesOrderInOpp__c--;
      }
      update oppListToBDecremented;
    }
  }

  public static void DeleteSo(LIST<AcctSeedERP__Sales_Order__c> data) {
    Map<Id, AcctSeedERP__Sales_Order__c> OppID = new Map<Id, AcctSeedERP__Sales_Order__c>();

    for (AcctSeedERP__Sales_Order__c so : data) {
      if (so.AcctSeedERP__Opportunity__c != null) {
        OppID.put(so.AcctSeedERP__Opportunity__c, so);
      }
    }

    LIST<Opportunity> oppList = new List<Opportunity>();

    oppList = [
      SELECT id, name, TotalSalesOrderInOpp__c
      FROM Opportunity
      WHERE Id IN :OppID.keyset()
    ];

    if (!oppList.isEmpty()) {
      for (Opportunity op : oppList) {
        if (op.TotalSalesOrderInOpp__c > 0)
          op.TotalSalesOrderInOpp__c--;
      }
      update oppList;
    }
  }
}