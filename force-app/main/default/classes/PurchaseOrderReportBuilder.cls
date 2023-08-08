/*
    *********************************************************
    Apex Class Name    : PurchaseOrderReportBuilder
    Created Date       : June 14, 2023
    @description       : This is class is used for building csv Purchase Order Reports
    @author            : Marian Lyzhychka
    Modification Log:
    Ver   Date         Author                               Modification
    1.0   14-06-2022   Marian Lyzhychka                    Initial Version
    *********************************************************
*/
public with sharing class PurchaseOrderReportBuilder {
    
    private class PurchaseOrderReportBuilderException extends Exception {}

    public void execute(Boolean isTesting, Id testingOwnerId){
        List<ReportsWrapper> reports = buildReports(isTesting, testingOwnerId);
        sendEmails(reports);
    }
    private List<ReportsWrapper> buildReports(Boolean isTesting, Id testingOwnerId){
        List<ReportsWrapper> usersWithReportsList = new List<ReportsWrapper>();
        Map<Id, List<AcctSeedERP__Purchase_Order__c>> usersWithPurchaseOrders = isTesting ? findOwnersPurchaseOrdersTesting(testingOwnerId) : findOwnersPurchaseOrders();
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, Email FROM User WHERE Id IN:usersWithPurchaseOrders.keySet()]);
        for(Id ownerId: usersWithPurchaseOrders.keySet()){
            String reportOneHeader = 'Purchase Order Name, Sales Order, Vendor, Production Start Date, Estimated Production End Date, Customer\'s ETA \n';
            String reportTwoHeader = 'Purchase Order Name, Sales Order, Vendor, Production Start Date, Estimated Production End Date, Customer\'s ETA \n';

            Boolean hasRecordsForFirstReport = false;
            Boolean hasRecordsForSecondReport = false;
            for(AcctSeedERP__Purchase_Order__c po: usersWithPurchaseOrders.get(ownerId)){
                Date today = System.today();
                Date todayMinusOneMonth = DateTime.now().addMonths(-1).date();
                //First Report
                if (
                    (po.Order_ETA__c >= today && (po.Stage__c == 'Production' || po.Stage__c == 'Confirmation'))
                    ||
                    (po.Order_ETA__c == null && po.Stage__c == 'Production')
                ){
                    reportOneHeader += buildCSVRow(po);
                    hasRecordsForFirstReport = true;
                }

                if(po.Customer_s_ETA__c >= todayMinusOneMonth && (po.Stage__c == 'Production' || po.Stage__c == 'Confirmation')){
                    reportTwoHeader += buildCSVRow(po);
                    hasRecordsForSecondReport = true;
                }
            }

            usersWithReportsList.add(new ReportsWrapper(
                ownerId,
                userMap.get(ownerId).Name,
                userMap.get(ownerId).Email,
                reportOneHeader,
                reportTwoHeader,
                hasRecordsForFirstReport,
                hasRecordsForSecondReport
            ));

        }

        
        return usersWithReportsList;
    }

    private void sendEmails(List<ReportsWrapper> usersWithReportsList){
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();

        for(ReportsWrapper wrap :usersWithReportsList) {

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setSubject('Seawin - Weekly Purchase Order Reports for: '+wrap.userName);
            mail.setToAddresses(new List<String>{wrap.userEmail});

            mail.setHtmlBody('The following POs require your attention:'); 


            List<Messaging.EmailFileAttachment> attachmentsReports = new List<Messaging.EmailFileAttachment>();

            if(wrap.hasRecordsInFirstReport){
                Messaging.EmailFileAttachment reportOneAttachment = new Messaging.EmailFileAttachment();
                reportOneAttachment.setFileName('Report #1.csv');
                reportOneAttachment.setBody(Blob.valueOf(wrap.reportOneCSV));
                attachmentsReports.add(reportOneAttachment);
            }
            
            if(wrap.hasRecordsInSecondReport){
                Messaging.EmailFileAttachment reportTwoAttachment = new Messaging.EmailFileAttachment();
                reportTwoAttachment.setFileName('Report #2.csv');
                reportTwoAttachment.setBody(Blob.valueOf(wrap.reportTwoCSV));
                attachmentsReports.add(reportTwoAttachment);
            }
            
            if(!attachmentsReports.isEmpty()) mail.setFileAttachments(attachmentsReports);

            if(wrap.hasRecordsInFirstReport || wrap.hasRecordsInSecondReport){
                mails.add(mail);
            }

        }

        if(!Test.isRunningTest() && !mails.isEmpty()){
            try{
                Messaging.sendEmail(mails);
            }catch(Exception e){
                System.debug(e.getMessage());
            }
        }
    }
    public String buildCSVRow(AcctSeedERP__Purchase_Order__c po){
        String row = po.Name + ',';
        row += (po.Sales_Order__c != null ? po.Sales_Order__r.Name : ' - ') + ',';
        row += (po.AcctSeedERP__Vendor__c != null ? po.AcctSeedERP__Vendor__r.Name : ' - ') + ',';
        row += (po.Production_Date__c != null ? po.Production_Date__c.format() : ' - ') + ',';
        row += (po.Order_ETA__c != null ? po.Order_ETA__c.format() : ' - ') + ',';
        row += (po.Customer_s_ETA__c != null ? po.Customer_s_ETA__c.format() : ' - ') + ',';
        row += '\n';
        return row;
    }
    /*
        *********************************************************
        @Method Name    : findOwnersPurchaseOrders
        @author         : Marian Lyzhychka
        @description    : method used for searching purchase orders per owner
        @param          :
        @return         : Set<Id>
        ********************************************************
    */
    private Map<Id, List<AcctSeedERP__Purchase_Order__c>> findOwnersPurchaseOrders(){
        List<AcctSeedERP__Purchase_Order__c> purchaseOrders = [SELECT Id, 
                                                                        Name, 
                                                                        Stage__c,
                                                                        Sales_Order__c, 
                                                                        Sales_Order__r.Name, 
                                                                        AcctSeedERP__Vendor__c, 
                                                                        AcctSeedERP__Vendor__r.Name, 
                                                                        Production_Date__c, 
                                                                        Order_ETA__c, 
                                                                        Customer_s_ETA__c, 
                                                                        OwnerId, 
                                                                        Owner.Name 
                                                                        FROM AcctSeedERP__Purchase_Order__c LIMIT 50000];

        Map<Id, List<AcctSeedERP__Purchase_Order__c>> ownerIdWithPurchaseOrderList = new Map<Id, List<AcctSeedERP__Purchase_Order__c>>();

        for(AcctSeedERP__Purchase_Order__c po: purchaseOrders){
            if(!ownerIdWithPurchaseOrderList.containsKey(po.OwnerId)){
                ownerIdWithPurchaseOrderList.put(po.OwnerId, new List<AcctSeedERP__Purchase_Order__c>{po});
            }else{
                ownerIdWithPurchaseOrderList.get(po.OwnerId).add(po);
            }
        }

        return ownerIdWithPurchaseOrderList;
    }

    private Map<Id, List<AcctSeedERP__Purchase_Order__c>> findOwnersPurchaseOrdersTesting(Id ownerId){
        List<AcctSeedERP__Purchase_Order__c> purchaseOrders = [SELECT Id, 
                                                                        Name, 
                                                                        Stage__c,
                                                                        Sales_Order__c, 
                                                                        Sales_Order__r.Name, 
                                                                        AcctSeedERP__Vendor__c, 
                                                                        AcctSeedERP__Vendor__r.Name, 
                                                                        Production_Date__c, 
                                                                        Order_ETA__c, 
                                                                        Customer_s_ETA__c, 
                                                                        OwnerId, 
                                                                        Owner.Name 
                                                                        FROM AcctSeedERP__Purchase_Order__c WHERE OwnerId=:ownerId];

        Map<Id, List<AcctSeedERP__Purchase_Order__c>> ownerIdWithPurchaseOrderList = new Map<Id, List<AcctSeedERP__Purchase_Order__c>>();

        for(AcctSeedERP__Purchase_Order__c po: purchaseOrders){
            if(!ownerIdWithPurchaseOrderList.containsKey(po.OwnerId)){
                ownerIdWithPurchaseOrderList.put(po.OwnerId, new List<AcctSeedERP__Purchase_Order__c>{po});
            }else{
                ownerIdWithPurchaseOrderList.get(po.OwnerId).add(po);
            }
        }

        return ownerIdWithPurchaseOrderList;
    }

    public class ReportsWrapper{
        public Id userId {get;set;}
        public String userName {get;set;}
        public String userEmail {get;set;}
        public String reportOneCSV {get;set;}
        public String reportTwoCSV {get;set;}

        public Boolean hasRecordsInFirstReport {get;set;}
        public Boolean hasRecordsInSecondReport {get;set;}

        public ReportsWrapper(Id userId, String userName, String userEmail, String reportOneCSV, String reportTwoCSV, Boolean hasRecordsInFirstReport, Boolean hasRecordsInSecondReport){
            this.userId = userId;
            this.userName = userName;
            this.userEmail = userEmail;
            this.reportOneCSV = reportOneCSV;
            this.reportTwoCSV = reportTwoCSV;

            this.hasRecordsInFirstReport = hasRecordsInFirstReport;
            this.hasRecordsInSecondReport = hasRecordsInSecondReport;
        }
    }
}