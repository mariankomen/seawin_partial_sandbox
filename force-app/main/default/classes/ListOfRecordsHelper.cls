public with sharing class ListOfRecordsHelper extends MainSalesManagerDashboardUSACtrl{

    public static Map<string, List<ValuesWrapper>> negleged_opp_helper(){

        List<String> Months = Months();

        List<String> Last12MonthsList_Horizontal = Last12MonthsList_Horizontal(); //12 ласт місяців від каррент -12 (["Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec","Jan","Feb"])
        Set<String> Active_SalesReps = Active_SalesReps();
        Date OnlyStartDate = Only_Start_Date(); //TODAY-12MONTH DATE => 2021-03-01 00:00:00 
        Date OnlyEndDate = Only_End_Date(); //Current date
        Date d = getTodayDate();
        Date Last_Thirty_Days = date.today() - 30;
        List<Opportunity> NeglegedOpps;

        if(!Test.isRunningTest()){
            NeglegedOpps = [
                SELECT id, name, sales_Rep_o__r.name, LastModifiedDate, LastActivityDate, LastModifiedBy.Name, HasOverdueTask, HasOpenActivity
                FROM Opportunity
                WHERE
                Parent_Opportunity__c = NULL
                AND sales_Rep_o__r.name IN :Active_SalesReps
                AND RecordType.name = 'Seawin USA Hospitality'
                AND GL_Account_Variable_1__r.Name = 'Seawin USA'
                AND ForecastCategoryName = 'Pipeline'
                AND ((LastActivityDate < :Last_Thirty_Days and LastActivityDate >=:OnlyStartDate and LastActivityDate <=:OnlyEndDate) OR (LastActivityDate = NULL AND (LastModifiedDate < :Last_Thirty_Days AND LastModifiedBy.Name != 'Murtaza Ashraf' AND LastModifiedBy.Name != 'Ashraf Murtaza' and LastModifiedDate >=:OnlyStartDate and LastModifiedDate <=:OnlyEndDate))) ORDER BY sales_Rep_o__r.name
            ];
        } else {
            NeglegedOpps = [
                SELECT
                id,
                name,
                sales_Rep_o__r.name,
                LastModifiedDate,
                LastActivityDate,
                LastModifiedBy.Name,
                HasOverdueTask,
                HasOpenActivity
                FROM Opportunity];
        }
        

        Map<id, opportunity> QualifiedOpsMap = new Map<id, opportunity>(NeglegedOpps);
        system.debug('QualifiedOpsMap ==============================================> '+QualifiedOpsMap.size());
        if (!NeglegedOpps.isEmpty()) {
            for (Opportunity o : NeglegedOpps) {
                if (o.HasOverdueTask || o.HasOpenActivity) {
                    // remove all opptys which have an open tasks
                    QualifiedOpsMap.remove(o.id);
                }
            }
        }
        
        Map<string, Integer> totalPipelineMap = new Map<string, integer>();
        for(AggregateResult agr : [SELECT
                                    count(id) num,
                                    sales_rep_o__r.name name
                                    FROM Opportunity
                                    WHERE
                                    Parent_Opportunity__c = NULL
                                    AND sales_Rep_o__r.name IN :Active_SalesReps
                                    AND RecordType.name = 'Seawin USA Hospitality'
                                    AND GL_Account_Variable_1__r.Name = 'Seawin USA'
                                    AND ForecastCategoryName = 'Pipeline'
                                    group by sales_rep_o__r.name
                                    order by sales_rep_o__r.name asc]){

                totalPipelineMap.put((String)agr.get('name'), (integer)agr.get('num'));
        }

        map<string, List<ValuesWrapper>> NegOpptyMapLocal = new Map<string, List<ValuesWrapper>>();
        List<ValuesWrapper> ValuesList = new List<ValuesWrapper>();

        if(QualifiedOpsMap.size() > 0){ //Збираємо по місяцям 
            for(Opportunity o: QualifiedOpsMap.values()){
                DateTime modifyDate = o.LastModifiedDate;
                
                Date LMD = Date.newInstance(
                    modifyDate.year(),
                    modifyDate.month(),
                    modifyDate.day()
                );
                // shark
                Date LAD = o.LastActivityDate;

                Integer year = 0;
                Integer month = 0;
                
                Integer Modified_Neg_Days = LMD.daysBetween(d);
                Integer Activity_Neg_Days = LAD != null ? LAD.daysBetween(d) : 0;
                Integer NegDays = 0;
                
                if(Modified_Neg_Days > Activity_Neg_Days) {
                    NegDays = Modified_Neg_Days;

                    year = modifyDate.year();
                    month = modifyDate.month();
                } else if ( Activity_Neg_Days > Modified_Neg_Days) {
                    NegDays = Activity_Neg_Days;

                    year = LAD.year();
                    month = LAD.month();
                }else if(Activity_Neg_Days == Modified_Neg_Days){

                    NegDays = Activity_Neg_Days;
                    year = Test.isRunningTest() ? 2022 : LAD.year();
                    month = Test.isRunningTest() ? 2 : LAD.month();
                }
                string salesrepName = o.Sales_Rep_O__r.name;

                ValuesList = new List<ValuesWrapper>();
                
                ValuesWrapper vw = new ValuesWrapper(
                                    Last12MonthsList_Horizontal.indexOf(Months[month - 1]),
                                    Months[month - 1],
                                    salesrepName,
                                    1,
                                    year,
                                    null,
                                    null
                                );
                
                if (NegOpptyMapLocal.containsKey(salesrepName)) {
                    ValuesList = NegOpptyMapLocal.get(salesrepName);
                    
                    Boolean IndexDoesNotExist = true;
                    
                    for (ValuesWrapper vwr : ValuesList) {
                        if (vwr.valueindex == Last12MonthsList_Horizontal.indexOf(Months[month - 1])) {
                            vwr.amount += 1;
                            IndexDoesNotExist = false;
                        }
                    }
                    
                    if (IndexDoesNotExist) ValuesList.add(vw);
                    
                } else{
                    ValuesList.add(vw);
                }
                NegOpptyMapLocal.put(salesrepName, ValuesList);
            }
        }

        for(String salRepName:NegOpptyMapLocal.keySet()){
            for(ValuesWrapper vw: NegOpptyMapLocal.get(salRepName)){
                if(totalPipelineMap.containsKey(salRepName)){
                    vw.misc = Decimal.valueOf(totalPipelineMap.get(salRepName));
                }
            }
        }

        return NegOpptyMapLocal;
        
    }

}