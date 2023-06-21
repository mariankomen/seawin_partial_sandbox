public class GLAccountAfterHandler {
  public static void Changes(
    List<AcctSeed__GL_Account__c> od,
    List<AcctSeed__GL_Account__c> nd
  ) {
    set<id> AddIds = new Set<id>();
    set<id> RemoveIds = new Set<id>();

    Integer i = 0;
    for (AcctSeed__GL_Account__c gl : nd) {
      if (
        gl.AcctSeed__Type__c != od[i].AcctSeed__Type__c &&
        gl.AcctSeed__Type__c == 'Balance Sheet'
      ) {
        AddIds.add(gl.id);
      } else if (
        gl.AcctSeed__Type__c != od[i].AcctSeed__Type__c &&
        od[i].AcctSeed__Type__c == 'Balance Sheet'
      ) {
        RemoveIds.add(gl.id);
      }

      i++;
    }

    // remove the amount from all gl accounts if their type has been changed from
    // balance sheet to any other

    if (!RemoveIds.isEmpty()) {
      List<AcctSeed__GL_Account__c> gls = [
        SELECT id, amount__c
        FROM AcctSeed__GL_Account__c
        WHERE id IN :RemoveIds
      ];

      if (!gls.isEmpty()) {
        for (AcctSeed__GL_Account__c gl : gls) {
          gl.amount__c = 0;
        }

        update gls;
      }
    }

    if (!AddIds.isEmpty()) {
      // keep only the Balance Sheet type gl accounts
      List<AcctSeed__GL_Account__c> gls = [
        SELECT id, amount__c
        FROM AcctSeed__GL_Account__c
        WHERE id IN :AddIds
      ];

      if (!gls.isEmpty()) {
        map<id, AcctSeed__GL_Account__c> glsMap = new Map<id, AcctSeed__GL_Account__c>(
          gls
        );
        map<Id, Decimal> ValuesMap = new Map<Id, Decimal>();

        // calculate the sum of credit and debit for jels
        List<AggregateResult> agrsJEL = [
          SELECT
            SUM(AcctSeed__Credit__c) credit,
            SUM(AcctSeed__Debit__c) debit,
            AcctSeed__GL_Account__c glId
          FROM AcctSeed__Journal_Entry_Line__c
          WHERE AcctSeed__GL_Account__c IN :glsMap.keySet()
          GROUP BY AcctSeed__GL_Account__c
        ];

        for (AggregateResult agr : agrsJEL) {
          decimal credit = agr.get('credit') == null
            ? 0
            : (Decimal) agr.get('credit');
          decimal debit = agr.get('debit') == null
            ? 0
            : (Decimal) agr.get('debit');

          decimal amount = credit + debit;

          ValuesMap.put((Id) agr.get('glId'), amount);
        }

        // calculate the sum of credit and debit for recurring jels
        List<AggregateResult> agrsRJEL = [
          SELECT
            SUM(AcctSeed__Credit__c) credit,
            SUM(AcctSeed__Debit__c) debit,
            AcctSeed__GL_Account__c glId
          FROM AcctSeed__Recurring_Journal_Entry_Line__c
          WHERE AcctSeed__GL_Account__c IN :glsMap.keySet()
          GROUP BY AcctSeed__GL_Account__c
        ];

        for (AggregateResult agr : agrsRJEL) {
          Decimal Amount = 0;

          decimal credit = agr.get('credit') == null
            ? 0
            : (Decimal) agr.get('credit');
          decimal debit = agr.get('debit') == null
            ? 0
            : (Decimal) agr.get('debit');

          if (ValuesMap.containsKey((Id) agr.get('glId'))) {
            Decimal PreviousAmount = ValuesMap.get((Id) agr.get('glId'));

            Amount = PreviousAmount + credit + debit;
          } else {
            Amount = credit + debit;
          }

          ValuesMap.put((Id) agr.get('glId'), Amount);
        }

        for (AcctSeed__GL_Account__c gl : gls) {
          Decimal TotalAmount = ValuesMap.get(gl.id);

          if (TotalAmount == null) {
            gl.amount__c = 0;
          } else {
            gl.amount__c = TotalAmount;
          }
        }

        update gls;
      }
    }
  }
}