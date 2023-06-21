public class DifferentUpdatesBatch implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM Opportunity WHERE StageName !=\'Closed Won\' AND StageName !=\'Closed Lost\' AND StageName !=\'Not Qualified\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> records){
        Opportunity opp = records[0];
        List<OpportunityLineItem> line_items = [SELECT Id, SortOrder FROM OpportunityLineItem WHERE OpportunityId=:opp.Id ORDER BY SortOrder];
        if(!line_items.isEmpty()){
            Integer sort_order = line_items[line_items.size() - 1].SortOrder != null ? line_items[line_items.size() - 1].SortOrder : 1;

            for(OpportunityLineItem oli:line_items){
                if(oli.SortOrder == null){
                    oli.SortOrder = sort_order;
                    sort_order++;
                }
            }
            Database.update(line_items, false);
        }
    }

    public void finish(Database.BatchableContext bc){
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {'testsalesforce840@gmail.com'};
        email.setSubject('Update sort order finished');
        email.setSenderDisplayName('SeaWin Batch Processing');
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('FINISHED');
        
        Messaging.SendEmailResult [] r = !Test.isRunningTest() ? Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}) : null;
    }
}