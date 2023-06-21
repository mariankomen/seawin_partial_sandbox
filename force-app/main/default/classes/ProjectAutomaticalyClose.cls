public with sharing class ProjectAutomaticalyClose {
    
    // @future
    public static void checkIfProjectAvailableForClosing(String setProjectIds){
        Set<Id> projectIds = (Set<Id>)JSON.deserialize(setProjectIds, Set<Id>.class);

        if(!projectIds.isEmpty()){
            /* Opportunities */
            List<Opportunity> relatedOpportunities = [SELECT Id, StageName, Project__c FROM Opportunity WHERE Project__c IN:projectIds];
            Map<Id, Boolean> availableCloseProjects_OPP = checkProjectOpportunities(relatedOpportunities);

            /* Sales Orders */
            List<AcctSeedERP__Sales_Order__c> relatedSalesOrders = [SELECT Id, Project__c, AcctSeedERP__Status__c FROM AcctSeedERP__Sales_Order__c WHERE Project__c IN:projectIds];
            Map<Id, Boolean> availableCloseProjects_SO = checkProjectSalesOrders(relatedSalesOrders);

            /* Purchase Orders */
            List<AcctSeedERP__Purchase_Order__c> relatedPurchaseOrders = [SELECT Id, Project__c, AcctSeedERP__Status__c FROM AcctSeedERP__Purchase_Order__c WHERE Project__c IN:projectIds];
            Map<Id, Boolean> availableCloseProjects_PO = checkProjectPurchaseOrders(relatedPurchaseOrders);

            Set<Id> availableForUpdating = findAvailableProjectsForClosing(projectIds, availableCloseProjects_OPP, availableCloseProjects_SO, availableCloseProjects_PO);

            if(!availableForUpdating.isEmpty()) {
                List<AcctSeed__Project__c> projects = [SELECT Id, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE Id IN: availableForUpdating];

                for(AcctSeed__Project__c project: projects){
                    project.AcctSeed__Status__c = 'Closed';
                }
    
                update projects;
            }

            Set<Id> projectIdToOpenUpdate = new Set<Id>();
            for(Id projectId: projectIds){
                if(!availableForUpdating.contains(projectId)){
                    projectIdToOpenUpdate.add(projectId);
                }
            }

            if(!projectIdToOpenUpdate.isEmpty()) {
                List<AcctSeed__Project__c> projects = [SELECT Id, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE Id IN: projectIdToOpenUpdate];

                for(AcctSeed__Project__c project: projects){
                    project.AcctSeed__Status__c = 'Open';
                }
    
                update projects;
            }

            
        }
    }

    public static boolean checkIfSingleProjectIsAvailableForClosing(Id projectId){
        if(projectId != null){
            /* Opportunities */
            List<Opportunity> relatedOpportunities = [SELECT Id, StageName, Project__c FROM Opportunity WHERE Project__c =: projectId];
            Map<Id, Boolean> availableCloseProjects_OPP = checkProjectOpportunities(relatedOpportunities);

            /* Sales Orders */
            List<AcctSeedERP__Sales_Order__c> relatedSalesOrders = [SELECT Id, Project__c, AcctSeedERP__Status__c FROM AcctSeedERP__Sales_Order__c WHERE Project__c =: projectId];
            Map<Id, Boolean> availableCloseProjects_SO = checkProjectSalesOrders(relatedSalesOrders);

            /* Purchase Orders */
            List<AcctSeedERP__Purchase_Order__c> relatedPurchaseOrders = [SELECT Id, Project__c, AcctSeedERP__Status__c FROM AcctSeedERP__Purchase_Order__c WHERE Project__c =: projectId];
            Map<Id, Boolean> availableCloseProjects_PO = checkProjectPurchaseOrders(relatedPurchaseOrders);

            Set<Id> availableForUpdating = findAvailableProjectsForClosing(new Set<Id>{projectId}, availableCloseProjects_OPP, availableCloseProjects_SO, availableCloseProjects_PO);

            if(availableForUpdating.isEmpty()){ //If method returns empty map than project can't be closed
                return false;
            }else{
                return true;
            }
        }else{
            return false;
        }
    }

    //Get list of all opportunities related to projects
    //Check if all opportunities have requirement stage
    //Returns Map <Id, Boolean> where id => opportunity id, Boolean - does all opportunities have needed stage
    public static Map<Id, Boolean> checkProjectOpportunities(List<Opportunity> opportunities){
        List<String> availableClosingStages = new List<String>{'Closed Won', 'Closed Lost', 'Not Qualified'};
        Map<Id, List<Opportunity>> projectOpportunities = new Map<Id, List<Opportunity>>();
        Map<Id, Boolean> resultMap = new Map<Id, Boolean>();

        for(Opportunity opp: opportunities){
            if(!projectOpportunities.containsKey(opp.Project__c)){
                projectOpportunities.put(opp.Project__c, new List<Opportunity>{opp});
            }else{
                projectOpportunities.get(opp.Project__c).add(opp);
            }
        }

        for(Id projectId: projectOpportunities.keyset()){
            Boolean allOpportunitiesAvailable = true;
            for(Opportunity opp: projectOpportunities.get(projectId)){
                if(!availableClosingStages.contains(opp.StageName)){
                    allOpportunitiesAvailable = false;
                    break;
                }
            }
            resultMap.put(projectId, allOpportunitiesAvailable);
        }

        return resultMap;
    }

    public static Map<Id, Boolean> checkProjectSalesOrders(List<AcctSeedERP__Sales_Order__c> salesOrders){
        Map<Id, List<AcctSeedERP__Sales_Order__c>> projectSalesOrders = new Map<Id, List<AcctSeedERP__Sales_Order__c>>();
        Map<Id, Boolean> resultMap = new Map<Id, Boolean>();
        for(AcctSeedERP__Sales_Order__c so: salesOrders){
            if(!projectSalesOrders.containsKey(so.Project__c)){
                projectSalesOrders.put(so.Project__c, new List<AcctSeedERP__Sales_Order__c>{so});
            }else{
                projectSalesOrders.get(so.Project__c).add(so);
            }
        }
        
        for(Id projectId: projectSalesOrders.keySet()){
            Boolean allSalesOrdersAvailable = true;
            for(AcctSeedERP__Sales_Order__c so: projectSalesOrders.get(projectId)){
                if(so.AcctSeedERP__Status__c != 'Closed' && so.AcctSeedERP__Status__c != 'Cancelled'){
                    allSalesOrdersAvailable = false;
                    break;
                }
            }
            resultMap.put(projectId, allSalesOrdersAvailable);
        }

        return resultMap;
    }


    public static Map<Id, Boolean> checkProjectPurchaseOrders(List<AcctSeedERP__Purchase_Order__c> purchaseOrders){
        Map<Id, List<AcctSeedERP__Purchase_Order__c>> projectPurchaseOrders = new Map<Id, List<AcctSeedERP__Purchase_Order__c>>();
        Map<Id, Boolean> resultMap = new Map<Id, Boolean>();

        for(AcctSeedERP__Purchase_Order__c po: purchaseOrders){
            if(!projectPurchaseOrders.containsKey(po.Project__c)){
                projectPurchaseOrders.put(po.Project__c, new List<AcctSeedERP__Purchase_Order__c>{po});
            }else{
                projectPurchaseOrders.get(po.Project__c).add(po);
            }
        }

        for(Id projectId: projectPurchaseOrders.keySet()){
            Boolean allPurchaseOrdersAvailable = true;
            for(AcctSeedERP__Purchase_Order__c po: projectPurchaseOrders.get(projectId)){
                if(po.AcctSeedERP__Status__c != 'Closed' && po.AcctSeedERP__Status__c != 'Canceled'){
                    allPurchaseOrdersAvailable = false;
                    break;
                }
            }
            resultMap.put(projectId, allPurchaseOrdersAvailable);
        }

        return resultMap;
    }

    public static Set<Id> findAvailableProjectsForClosing(Set<Id> projectIds, Map<Id, Boolean> opportunityMap, Map<Id, Boolean> salesOrderMap, Map<Id, Boolean> purchaseOrderMap){
        Set<Id> availableForUpdating = new Set<Id>();

        for(Id projectId: projectIds){
            Boolean isProjectAvailableForClosing = true;
            if(opportunityMap.containsKey(projectId)){
                if(opportunityMap.get(projectId) == false) isProjectAvailableForClosing = false;
            }
            if(salesOrderMap.containsKey(projectId)){
                if(salesOrderMap.get(projectId) == false) isProjectAvailableForClosing = false;
            }
            if(purchaseOrderMap.containsKey(projectId)){
                if(purchaseOrderMap.get(projectId) == false) isProjectAvailableForClosing = false;
            }

            if(isProjectAvailableForClosing) availableForUpdating.add(projectId);
        }

        return availableForUpdating;
    }

    public static String prepareSetStrings(List<SObject> data, String controllingField){
        Set<String> setFieldValues = new Set<String>();

        for(SObject sobj: data){
            String fieldV = String.valueOf(sobj.get(controllingField));
            if(fieldV != null) setFieldValues.add(fieldV);
        }

        return JSON.serialize(setFieldValues);
    }
}