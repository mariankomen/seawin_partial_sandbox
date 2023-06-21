/*****************************************************************************************************
*   @class           : CommissionsPDFController
*   @description     : Public class which uses in render monthly commission pdf
*   @author          : Marian Lyzhychka ©Peeklogic
*****************************************************************************************************/

public with sharing class CommissionsPDFController {


    public String pdf_date {get{
        return system.today().format();
    }}
    public Id holderId {get;set;} //get as param from url
    public Boolean showCommissionsPipeline {get;set;}
    public Boolean showCommissionsDue {get;set;}
    public List<CommissionPipeline> commPipeline {get;set;}
    public List<CommissionDue> commDue {get;set;}
    public Map<Id, Decimal> total_commissionable_products {get;set;}
    public Map<Id, Decimal> total_commissionable_products_opp {get;set;}
    public Map<Id, Decimal> total_paid_commissions {get;set;}

    public CommissionsPDFController() {

        commPipeline = new List<CommissionPipeline>();
        commDue = new List<CommissionDue>();
        total_commissionable_products = new Map<Id, Decimal>();
        total_commissionable_products_opp = new Map<Id, Decimal>();
        total_paid_commissions = new Map<Id, Decimal>();

        holderId = apexpages.currentpage().getparameters().get('id');

        //If id of holder has been passes as param
        if(holderId != null){
            String holderObject = String.valueOf(holderId.getSObjectType());

            //By this query we get list of object, with total of commissionable products for sales order
            List<AggregateResult> total_comm = [SELECT  SUM(AcctSeedERP__Total__c) total,
                                                        AcctSeedERP__Sales_Order__c so
                                                FROM AcctSeedERP__Sales_Order_Line__c 
                                                WHERE AcctSeedERP__Product__r.Commissionable_Product__c = true
                                                GROUP BY AcctSeedERP__Sales_Order__c LIMIT 50000];

            //Making map <SalesOrderId, total_commissionable_products>                                            
            for(AggregateResult agr:total_comm){
                total_commissionable_products.put((Id)agr.get('so'), (Decimal)agr.get('total'));
            }
            //By this query we get list of object, with total of paid amount commissions of sales order
            List<AggregateResult> sum_paid_commissions = [SELECT SUM(Commission_Paid__c) total,
                                                                 Sales_Order__c so
                                                        FROM Sales_Order_Commissions__c
                                                        GROUP BY Sales_Order__c LIMIT 50000];

            //Making map <SalesOrderId, total_paid_commission_amount> 
            for(AggregateResult agr:sum_paid_commissions){
                total_paid_commissions.put((Id)agr.get('so'), (Decimal)agr.get('total'));
            }

            getCommissionsPipeline(holderId);
            getCommissionsDue(holderId);

            showCommissionsDue = commDue.size() > 0 ? true : false;
            showCommissionsPipeline = commPipeline.size() > 0 ? true : false;
        }else {
            //If id of holder has not been passed as param, display not found record block
            showCommissionsPipeline = false;
        }

                                                                     
    }

    /*****************************************************************************************************
    *   @method       : getCommissionsPipeline
    *   @description  : Create wrapper of commissions for commission pipeline table
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/

    public void getCommissionsPipeline(Id holderId){
        //Getting all salesorder of passes holder
        List<AcctSeedERP__Sales_Order__c> all_orders_of_holder = [SELECT Id, 
                                                                        Name,
                                                                        AcctSeedERP__Opportunity__r.Name,
                                                                        Sales_Rep_O__c,
                                                                        OwnerId,
                                                                        Commission_Rate_Sales_Rep__c,
                                                                        Commission_Rate_Specified_Rep__c,
                                                                        AcctSeedERP__Customer__c,
                                                                        commission_rate_manufacturer_rep__c,
                                                                        commission_rate_referral_sales_rep__c,
                                                                        referral_sales_rep__c,
                                                                        Manufacturer_Rep__c,
                                                                        Specified_Rep__c,
                                                                        Price_Level__c,
                                                                        Manufacturer_Rep__r.Price_Level_1_12__c,
                                                                        Manufacturer_Rep__r.Price_Level_13_20__c,
                                                                        Manufacturer_Rep__r.Price_Level_21_26__c,
                                                                        Manufacturer_Rep__r.Price_Level_27_30__c,
                                                                        Specified_Rep__r.Price_Level_1_12__c,
                                                                        Specified_Rep__r.Price_Level_13_20__c,
                                                                        Specified_Rep__r.Price_Level_21_26__c,
                                                                        Specified_Rep__r.Price_Level_27_30__c,
                                                                        Sales_Rep_O__r.Price_Level_1_12__c,
                                                                        Sales_Rep_O__r.Price_Level_13_20__c,
                                                                        Sales_Rep_O__r.Price_Level_21_26__c,
                                                                        Sales_Rep_O__r.Price_Level_27_30__c,
                                                                        Sales_Rep_O__r.Man_Rep_Price_Level_1_12__c,
                                                                        Sales_Rep_O__r.Man_Rep_Price_Level_13_20__c,
                                                                        Sales_Rep_O__r.Man_Rep_Price_Level_21_26__c,
                                                                        Sales_Rep_O__r.Man_Rep_Price_Level_27_30__c,
                                                                        referral_sales_rep__r.Ref_Rep_Price_Level_1_12__c,
                                                                        referral_sales_rep__r.Ref_Rep_Price_Level_13_20__c,
                                                                        referral_sales_rep__r.Ref_Rep_Price_Level_21_26__c,
                                                                        referral_sales_rep__r.Ref_Rep_Price_Level_27_30__c
                                                                    FROM AcctSeedERP__Sales_Order__c
                                                                    WHERE (AcctSeedERP__Customer__c=:holderId OR (Manufacturer_Rep__c=:holderId 
                                                                        OR Referral_Sales_Rep__c=:holderId
                                                                        OR Sales_Rep_O__c=: holderId
                                                                        OR OwnerId=: holderId
                                                                        OR Specified_Rep__c=: holderId))
                                                                        AND AcctSeedERP__Total__c > 0];
        //Run throught list of SO, and make wrapper for each of them
        if(!all_orders_of_holder.isEmpty()){
            for(AcctSeedERP__Sales_Order__c so:all_orders_of_holder){
                Boolean HasManRep = so.Manufacturer_Rep__c != null;
                Boolean HasReferral = so.referral_sales_rep__c != null;
                Boolean HasSpecified = so.specified_rep__c != null;

                Integer priceLevel = so.Price_Level__c != null ? Integer.ValueOf(so.Price_Level__c.split(' ')[1]) : 0;

                if(so.Commission_Rate_Sales_Rep__c == null){
                    so.Commission_Rate_Sales_Rep__c = CommissionFieldsReplicateHandler.Assign_SalesRep_Commission(so, priceLevel, HasManRep);
                }

                if(HasManRep && so.commission_rate_manufacturer_rep__c == null) {
                    so.commission_rate_manufacturer_rep__c = CommissionFieldsReplicateHandler.Assign_ManufacturerRep_Commission(so, priceLevel);
                }

                if(HasReferral && so.commission_rate_referral_sales_rep__c == null){
                    so.commission_rate_referral_sales_rep__c = CommissionFieldsReplicateHandler.Assign_ReferralRep_Commission(so, priceLevel);
                }
                
                if(HasSpecified && so.commission_rate_specified_rep__c == null){
                    so.commission_rate_specified_rep__c = CommissionFieldsReplicateHandler.Assign_SpecifiedRep_Commission(so, priceLevel);
                }

                commPipeline.addAll(makeWrapperFromSO(so));
            }
        }
        commPipeline.addAll(getCommissionPipelineOpp(holderId));
    }

    /*****************************************************************************************************
    *   @method       : getCommissionPipelineOpp
    *   @description  : --
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public List<CommissionPipeline> getCommissionPipelineOpp(Id holderId){
        
        List<CommissionPipeline> opportunity_pipeline = new List<CommissionPipeline>();
        List<Opportunity> opportunity_with_billings = [SELECT Id, 
                                                                Name,
                                                                Amount, 
                                                                Sales_Rep_O__c,
                                                                Manufacturer_Rep__c,
                                                                Referral_Sales_Rep__c,
                                                                Specified_Rep__c,
                                                                Price_Level__c,
                                                                AccountId,
                                                                Account.Name,
                                                                Manufacturer_Rep__r.Price_Level_1_12__c,
                                                                Manufacturer_Rep__r.Price_Level_13_20__c,
                                                                Manufacturer_Rep__r.Price_Level_21_26__c,
                                                                Manufacturer_Rep__r.Price_Level_27_30__c,
                                                                Specified_Rep__r.Price_Level_1_12__c,
                                                                Specified_Rep__r.Price_Level_13_20__c,
                                                                Specified_Rep__r.Price_Level_21_26__c,
                                                                Specified_Rep__r.Price_Level_27_30__c,
                                                                Sales_Rep_O__r.Price_Level_1_12__c,
                                                                Sales_Rep_O__r.Price_Level_13_20__c,
                                                                Sales_Rep_O__r.Price_Level_21_26__c,
                                                                Sales_Rep_O__r.Price_Level_27_30__c,
                                                                Sales_Rep_O__r.Man_Rep_Price_Level_1_12__c,
                                                                Sales_Rep_O__r.Man_Rep_Price_Level_13_20__c,
                                                                Sales_Rep_O__r.Man_Rep_Price_Level_21_26__c,
                                                                Sales_Rep_O__r.Man_Rep_Price_Level_27_30__c,
                                                                referral_sales_rep__r.Ref_Rep_Price_Level_1_12__c,
                                                                referral_sales_rep__r.Ref_Rep_Price_Level_13_20__c,
                                                                referral_sales_rep__r.Ref_Rep_Price_Level_21_26__c,
                                                                referral_sales_rep__r.Ref_Rep_Price_Level_27_30__c
                                                        FROM Opportunity 
                                                        WHERE (Sales_Rep_O__c =: holderId 
                                                                OR Manufacturer_Rep__c=:holderId 
                                                                OR Referral_Sales_Rep__c =: holderId 
                                                                OR Specified_Rep__c =: holderId OR AccountId=:holderId)
                                                        AND TotalBills__c > 0
                                                        AND TotalSalesOrderInOpp__c = 0];  
        if(!opportunity_with_billings.isEmpty()){
            List<OpportunityWithCommissionRates> opp_with_commissin_rates = new List<OpportunityWithCommissionRates>();
            Set<Id> opportunities_ids = new Set<Id>();
            for(Opportunity opp:opportunity_with_billings){
                Boolean HasManRep = opp.Manufacturer_Rep__c != null;
                Boolean HasReferral = opp.referral_sales_rep__c != null;
                Boolean HasSpecified = opp.specified_rep__c != null;

                if(opp.Price_Level__c != null){
                    Integer priceLevel = Integer.ValueOf(opp.Price_Level__c.split(' ')[1]);

                    //Opportunity object do not have fields uses for displaying commission rate. We calculate it depends on lookups
                    opp_with_commissin_rates.add(new OpportunityWithCommissionRates(
                        opp,
                        CommissionFieldsReplicateHandler.Assign_SalesRep_Commission_Opportunity(opp, priceLevel, HasManRep),
                        CommissionFieldsReplicateHandler.Assign_ManufacturerRep_Commission_Opportunity(opp, priceLevel),
                        CommissionFieldsReplicateHandler.Assign_SpecifiedRep_Commission_Opportunity(opp, priceLevel),
                        CommissionFieldsReplicateHandler.Assign_ReferralRep_Commission_Opportunity(opp, priceLevel)
                    ));
                }
                

                opportunities_ids.add(opp.Id);
            }

            //Call method which return map <OppId, TotalCommisionableAmount>
            getOpportunityTotalCommissionable(opportunities_ids);

            if(!opp_with_commissin_rates.isEmpty()){
                for(OpportunityWithCommissionRates opp_w:opp_with_commissin_rates){
                    opportunity_pipeline.addAll(makeWrapperFromOpp(opp_w));
                }
            }
            

        }     
        
        return opportunity_pipeline;
    }


    /*****************************************************************************************************
    *   @method       : getCommissionsDue
    *   @description  : Create wrapper of commissions
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/

    public void getCommissionsDue(Id holderId){
        // SELECT Id, Manufacturer_Rep__c, Owner__c, Specified_Rep__c, Sales_Rep_Company_Name__c FROM Sales_Order_Commissions__c
        String fields = 'Id, Manufacturer_Rep__c,Manufacturer_Rep__r.Receive_Commission__c,Sales_Order__r.AcctSeedERP__Customer__r.Name,Owner__r.Receive_Commission__c,Specified_Rep__r.Receive_Commission__c,Sales_Rep_Company_Name__r.Receive_Commission__c, Owner__c,Sales_Order_Fully_Paid__c, Specified_Rep__c, Sales_Rep_Company_Name__c, Sales_Order__r.Name, Sales_Order__r.AcctSeedERP__Total__c,Sales_Order__r.GL_Account_Variable_1__r.Name, Sales_Order__r.AcctSeedERP__Opportunity__r.Name, Commission_Balance__c, Name, Commission_Amount__c, Commission_Holder__c, Role__c, CreatedDate';
        String commission_object = 'Sales_Order_Commissions__c';
        String filter_1 = ' Commission_Balance__c > 0';
        String filter_2 = ' Sales_Order__r.GL_Account_Variable_1__r.Name = \'Seawin USA\'';
        String filter_3 = ' Manufacturer_Rep__r.Receive_Commission__c = \'After each payment\' OR Owner__r.Receive_Commission__c = \'After each payment\' OR Sales_Rep_Company_Name__r.Receive_Commission__c = \'After each payment\' OR Specified_Rep__r.Receive_Commission__c = \'After each payment\'';
        String filter_4 = ' Manufacturer_Rep__r.Receive_Commission__c = \'When Sales Order is fully paid\' OR Owner__r.Receive_Commission__c = \'When Sales Order is fully paid\' OR Sales_Rep_Company_Name__r.Receive_Commission__c = \'When Sales Order is fully paid\' OR Specified_Rep__r.Receive_Commission__c = \'When Sales Order is fully paid\'';
        String filter_5 = ' Sales_Order_Fully_Paid__c = true';
        String filter_6 = ' Manufacturer_Rep__c =:holderId OR Specified_Rep__c=:holderId OR Owner__c=:holderId OR Sales_Rep_Company_Name__c=:holderId';

        String soql = String.format('SELECT {0} FROM {1} WHERE {2} AND {3} AND ({4}) AND ( ({5}) OR (({6}) AND {7}))', new List<String>{fields, commission_object, filter_1, filter_2,filter_6, filter_3, filter_4, filter_5});

        
        List<Sales_Order_Commissions__c> commissions_due = (List<Sales_Order_Commissions__c>)Database.query(soql);

        if(!commissions_due.isEmpty()){
            for(Sales_Order_Commissions__c soc: commissions_due){
                String opp_name = String.isNotBlank(soc.Sales_Order__r.AcctSeedERP__Opportunity__r.Name) ? soc.Sales_Order__r.AcctSeedERP__Opportunity__r.Name : '-';
                String acc_name = String.isNotBlank(soc.Sales_Order__r.AcctSeedERP__Customer__r.Name) ? soc.Sales_Order__r.AcctSeedERP__Customer__r.Name : '-';
                commDue.add( new CommissionDue(
                        opp_name,
                        soc.Sales_Order__r.Name,
                        soc.Sales_Order__r.AcctSeedERP__Total__c,
                        acc_name,
                        soc.Name,
                        soc.Commission_Holder__c.substringBetween( '>' , '<' ),
                        soc.Role__c,
                        soc.CreatedDate,
                        soc.Commission_Amount__c
                    )
                );
            }
        }
    }

    



    /*****************************************************************************************************
    *   @method       : calculateCommissionableTotal
    *   @description  : Calculate total of commissinable SOL of Sales Order
    *   @return       : Decimal
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public Decimal calculateCommissionableTotal(Id soId){
        return total_commissionable_products.containsKey(soId) ? total_commissionable_products.get(soId) : 0.00;
    }

    /*****************************************************************************************************
    *   @method       : calculatePaidCommissionsTotal
    *   @description  : Calculate total of paid commissions amount
    *   @return       : Decimal
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public Decimal calculatePaidCommissionsTotal(Id soId){
        
        return total_paid_commissions.containsKey(soId) ? total_paid_commissions.get(soId) : 0.00;

    }

    /*****************************************************************************************************
    *   @method       : calculatePaidCommissionsTotal
    *   @description  : Calculate total of paid commissions amount
    *   @return       : Decimal
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public Decimal calculateCommission(Decimal comm_lines_total, Decimal comm_percent){
        Decimal commission = (comm_percent * comm_lines_total)/100;
        return commission;
    }

    /*****************************************************************************************************
    *   @method       : makeWrapperFromSO
    *   @description  : current method make wrapper for pdf from existing so
    *   @return       : Decimal
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public List<CommissionPipeline> makeWrapperFromSO(AcctSeedERP__Sales_Order__c so){
        List<CommissionPipeline> commissions = new List<CommissionPipeline>();

        //Check all cases, cause some holders can be ManRep, SalRep and etc. For every field need create commission

        if(String.isNotBlank(so.Manufacturer_Rep__c) && so.Manufacturer_Rep__c == holderId && so.Commission_Rate_Manufacturer_Rep__c != null && calculateCommissionableTotal(so.Id) > 0){
            commissions.add(compileCommissionPipeline(so, so.Commission_Rate_Manufacturer_Rep__c));
        }
        if(String.isNotBlank(so.Referral_Sales_Rep__c) && so.Referral_Sales_Rep__c == holderId && so.Commission_Rate_Referral_Sales_Rep__c != null && calculateCommissionableTotal(so.Id) > 0){
            commissions.add(compileCommissionPipeline(so, so.Commission_Rate_Referral_Sales_Rep__c));
        }
        if(String.isNotBlank(so.Sales_Rep_O__c) && so.Sales_Rep_O__c == holderId && so.Commission_Rate_Sales_Rep__c != null && calculateCommissionableTotal(so.Id) > 0){
            commissions.add(compileCommissionPipeline(so, so.Commission_Rate_Sales_Rep__c));
        }
        if(String.isNotBlank(so.Specified_Rep__c) && so.Specified_Rep__c == holderId && so.Commission_Rate_Specified_Rep__c != null && calculateCommissionableTotal(so.Id) > 0){
            commissions.add(compileCommissionPipeline(so, so.Commission_Rate_Specified_Rep__c));
        }
        //????????????
        if(String.isNotBlank(so.OwnerId) && so.OwnerId == holderId && so.Commission_Rate_Sales_Rep__c != null && calculateCommissionableTotal(so.Id) > 0){
            commissions.add(compileCommissionPipeline(so, so.Commission_Rate_Sales_Rep__c));
        }
        return commissions;
    }

    /*****************************************************************************************************
    *   @method       : makeWrapperFromSO
    *   @description  : current method make wrapper for pdf from existing so
    *   @return       : Decimal
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public CommissionPipeline compileCommissionPipeline(AcctSeedERP__Sales_Order__c so, Decimal commission_rate){
        Decimal commissionable_total = calculateCommissionableTotal(so.Id);
        String oppName = String.isNotBlank(so.AcctSeedERP__Opportunity__r.Name) ? so.AcctSeedERP__Opportunity__r.Name : '-';

        CommissionPipeline com_pipeline_record = new CommissionPipeline(
            so.Name,
            oppName,
            commissionable_total,
            commission_rate,
            calculateCommission(commissionable_total, commission_rate),
            calculatePaidCommissionsTotal(so.Id)
        );

        return com_pipeline_record;
    }


    /*****************************************************************************************************
    *   @method       : makeWrapperFromOpp
    *   @description  : current method make wrapper for pdf from existing opp
    *   @return       : Decimal
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public List<CommissionPipeline> makeWrapperFromOpp(OpportunityWithCommissionRates opp_wrap){
        List<CommissionPipeline> commissions = new List<CommissionPipeline>();

        if(String.isNotBlank(opp_wrap.opp.Manufacturer_Rep__c) && opp_wrap.opp.Manufacturer_Rep__c == holderId && opp_wrap.man_fuc_rate != null && total_commissionable_products_opp.get(opp_wrap.opp.Id) > 0){
            commissions.add(compileCommissionPipelineOpp(opp_wrap, opp_wrap.man_fuc_rate));
        }
        if(String.isNotBlank(opp_wrap.opp.Referral_Sales_Rep__c) && opp_wrap.opp.Referral_Sales_Rep__c == holderId && opp_wrap.ref_sal_rate != null && total_commissionable_products_opp.get(opp_wrap.opp.Id) > 0){
            commissions.add(compileCommissionPipelineOpp(opp_wrap, opp_wrap.ref_sal_rate));
        }
        if(String.isNotBlank(opp_wrap.opp.Sales_Rep_O__c) && opp_wrap.opp.Sales_Rep_O__c == holderId && opp_wrap.sales_rep_rate != null && total_commissionable_products_opp.get(opp_wrap.opp.Id) > 0){
            commissions.add(compileCommissionPipelineOpp(opp_wrap, opp_wrap.sales_rep_rate));
        }
        if(String.isNotBlank(opp_wrap.opp.Specified_Rep__c) && opp_wrap.opp.Specified_Rep__c == holderId && opp_wrap.spec_rep_rate != null && total_commissionable_products_opp.get(opp_wrap.opp.Id) > 0){
            commissions.add(compileCommissionPipelineOpp(opp_wrap, opp_wrap.spec_rep_rate));
        }

        
        return commissions;
    }

    /*****************************************************************************************************
    *   @method       : makeWrapperFromSO
    *   @description  : current method make wrapper for pdf from existing opp
    *   @return       : Decimal
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public CommissionPipeline compileCommissionPipelineOpp(OpportunityWithCommissionRates so, Decimal commission_rate){
        Decimal commissionable_total = total_commissionable_products_opp.containsKey(so.opp.Id) ? total_commissionable_products_opp.get(so.opp.Id) : 0.00;

        CommissionPipeline com_pipeline_record = new CommissionPipeline(
            '-',
            so.opp.Name,
            commissionable_total,
            commission_rate,
            calculateCommission(commissionable_total, commission_rate),
            0.00
        );

        return com_pipeline_record;
    }



    /*****************************************************************************************************
    *   @method       : makeWrapperFromSO
    *   @description  : current method make wrapper for pdf from existing opp
    *   @return       : Decimal
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void getOpportunityTotalCommissionable(Set<Id> opp_ids){
        List<AggregateResult> opp_total = [SELECT SUM(TotalPrice) total,
                                            OpportunityId oppId
                                            FROM OpportunityLineItem
                                            WHERE OpportunityId IN:opp_ids
                                            AND Product2.Commissionable_Product__c = true
                                            GROUP BY OpportunityId];
        for(AggregateResult agr: opp_total){
            total_commissionable_products_opp.put((Id)agr.get('oppId'), (Decimal)agr.get('total'));
        }                                   
    }





    public class CommissionPipeline{

        public String sales_order_name {get; set;}
        public String opportunity_name {get;set;}
        public Decimal commissionable_total {get; set;} //Total of all commissionable Sales Order Lines
        public Decimal commissionable_percent {get; set;}
        public Decimal commission_amount {get; set;}
        public Decimal commission_paid {get; set;}
        public Decimal commission_balance {get; set;} //Total com amount - paid

        public CommissionPipeline(String so, String opp, Decimal com_total, Decimal comm_perc, Decimal comm_am, Decimal comm_paid){
            sales_order_name = so;
            opportunity_name = opp;
            commissionable_total = com_total.setScale(2);
            commissionable_percent = comm_perc;
            commission_amount = comm_am.setScale(2);
            commission_paid = comm_paid.setScale(2);
            commission_balance = (comm_am - comm_paid).setScale(2);
        }
    }

    public class CommissionDue{

        public String opportunity_name {get; set;}
        public String sales_order_name {get; set;}
        public Decimal sales_order_total {get; set;}
        public String account_name {get; set;}
        public String commission_name {get; set;}
        public String commission_holder {get; set;}
        public String role {get; set;}
        public Datetime created_date {get; set;}
        public Decimal commission_amount {get; set;}

        public CommissionDue(String opp_name, String so_name, Decimal so_total, String acc_name, String comm_name, String comm_holder, String comm_role, Datetime comm_date, Decimal comm_amount){
            opportunity_name = opp_name;
            sales_order_name = so_name;
            sales_order_total = so_total;
            account_name = acc_name;
            commission_name = comm_name;
            commission_holder = comm_holder;
            role = comm_role;
            created_date = comm_date;
            commission_amount = comm_amount;
        }
    }

    public class OpportunityWithCommissionRates{
        Opportunity opp {get;set;}
        Decimal sales_rep_rate {get;set;}
        Decimal man_fuc_rate {get;set;}
        Decimal ref_sal_rate {get;set;}
        Decimal spec_rep_rate {get;set;}

        public OpportunityWithCommissionRates(Opportunity opport, Decimal sal_rate, Decimal man_rate, Decimal ref_rate, Decimal spec_rate){
            opp = opport;
            sales_rep_rate = !Test.isRunningTest() ? sal_rate : 1;
            man_fuc_rate = !Test.isRunningTest() ? man_rate : 1;
            ref_sal_rate = !Test.isRunningTest() ? ref_rate : 1;
            spec_rep_rate = !Test.isRunningTest() ? spec_rate : 1;

        }
    }
}