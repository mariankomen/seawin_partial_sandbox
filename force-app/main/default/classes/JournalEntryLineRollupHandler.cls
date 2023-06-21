public class JournalEntryLineRollupHandler {


    public static void Rollup(List<AcctSeed__Journal_Entry_Line__c> jels, List<AcctSeed__Recurring_Journal_Entry_Line__c> rjels){

        set<id> glIds = new set<id>();

        // jels
        for(AcctSeed__Journal_Entry_Line__c jel : jels){

                if(jel.AcctSeed__GL_Account__c != null){
                    glIds.add(jel.AcctSeed__GL_Account__c);
                }
        }

        // rjels
        for(AcctSeed__Recurring_Journal_Entry_Line__c rjel : rjels){

            if(rjel.AcctSeed__GL_Account__c != null){
                glIds.add(rjel.AcctSeed__GL_Account__c);
            }
        }

        // keep only the Balance Sheet type gl accounts
        List<AcctSeed__GL_Account__c> gls = [select id, amount__c from
                                                        AcctSeed__GL_Account__c where id in:glIds
                                                        and AcctSeed__Type__c = 'Balance Sheet'];

        if(!gls.isEmpty()){

            map<id, AcctSeed__GL_Account__c> glsMap = new map<id, AcctSeed__GL_Account__c>(gls);
            map<Id, Decimal> ValuesMap = new map<Id, Decimal>();

            // calculate the sum of credit and debit for jels
            List<AggregateResult> agrsJEL = [select SUM(AcctSeed__Credit__c) credit, SUM(AcctSeed__Debit__c) debit, 
                    AcctSeed__GL_Account__c glId 
                    from AcctSeed__Journal_Entry_Line__c where AcctSeed__GL_Account__c in: glsMap.keySet()
                    group by AcctSeed__GL_Account__c];

            for(AggregateResult agr : agrsJEL){

                decimal credit = agr.get('credit') == null ? 0 : (Decimal)agr.get('credit');
                decimal debit = agr.get('debit') == null ? 0 : (Decimal)agr.get('debit');

                decimal amount = credit + debit;

                ValuesMap.put((Id)agr.get('glId'), amount);
            }

            // calculate the sum of credit and debit for recurring jels
            List<AggregateResult> agrsRJEL = [select SUM(AcctSeed__Credit__c) credit, SUM(AcctSeed__Debit__c) debit, 
                    AcctSeed__GL_Account__c glId 
                    from AcctSeed__Recurring_Journal_Entry_Line__c where AcctSeed__GL_Account__c in: glsMap.keySet()
                    group by AcctSeed__GL_Account__c];

            for(AggregateResult agr : agrsRJEL){

                Decimal Amount = 0;

                decimal credit = agr.get('credit') == null ? 0 : (Decimal)agr.get('credit');
                decimal debit = agr.get('debit') == null ? 0 : (Decimal)agr.get('debit');

                if(ValuesMap.containsKey((Id)agr.get('glId'))){

                    Decimal PreviousAmount = ValuesMap.get((Id)agr.get('glId'));

                    Amount = PreviousAmount + credit + debit;

                }else{
                    Amount = credit + debit;
                }

                ValuesMap.put((Id)agr.get('glId'), Amount);
            }

            for(AcctSeed__GL_Account__c gl : gls){

                Decimal TotalAmount = ValuesMap.get(gl.id);

                if(TotalAmount == null){

                    gl.amount__c = 0;

                }else{

                    gl.amount__c = TotalAmount;
                }
            }

            update gls;
        }
    }
}