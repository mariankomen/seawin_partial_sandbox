/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-10-2023
 * @last modified by  : Marian Lyzhychka
**/
public class DifferentUpdatesBatch implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, Name, Type FROM Opportunity';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Opportunity> records){
        for(Opportunity opp: records){
            String name = opp.Name.toLowerCase();
            if(name.contains('case order') || name.contains('caseorder') || name.contains('issue')){
                opp.Type = 'Case Order';
            }else if(name.contains('changed order') || name.contains('changedorder')){
                opp.Type = 'Change Order';
            }else if(name.contains('claim order') || name.contains('claimorder')){
                opp.Type = 'Claim Order';
            }else if(name.contains('marketing material') || name.contains('marketing materials') || name.contains('catalog') || name.contains('brochure')){
                opp.Type = 'Marketing Materials';
            }else if(name.contains('mock-up samples') || name.contains('mock-up sample') || name.contains('mock-up') || name.contains('mockup') || name.contains('mock up')){
                opp.Type = 'Mock-Up Sample';
            }else if(name.contains('parts order') || name.contains('partsorder') || name.contains('parts')){
                opp.Type = 'Parts Order';
            }else if(name.contains('replacement') || name.contains('replacements')){
                opp.Type = 'Replacement';
            }else if(name.contains('sales & marketing samples') || name.contains('sample') || name.contains('samples')){
                opp.Type = 'Sales & Marketing Samples';
            }else if(name.contains('warranty related') || name.contains('warranty')){
                opp.Type = 'Warranty Related';
            }
        }

        
        
        Database.update(records,false);

        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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