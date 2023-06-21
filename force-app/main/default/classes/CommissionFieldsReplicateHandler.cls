public class CommissionFieldsReplicateHandler {



    public static List<AcctSeedERP__Sales_Order__c> getSalesOrderRecords(set<Id> soIds){

      List<AcctSeedERP__Sales_Order__c> orders = new List<AcctSeedERP__Sales_Order__c>();

      orders = [
          SELECT
            id,
            Commission_Rate_Sales_Rep__c,
            commission_rate_manufacturer_rep__c,
            commission_rate_referral_sales_rep__c,
            commission_rate_specified_rep__c,
            referral_sales_rep__c,
            Manufacturer_Rep__c,
            Specified_Rep__c,
            Price_Level__c,

            Manufacturer_Rep__r.Price_Level_1_12__c,
            Manufacturer_Rep__r.Price_Level_13_20__c,
            Manufacturer_Rep__r.Price_Level_21_26__c,
            Manufacturer_Rep__r.Price_Level_27_30__c,

            Specified_Rep__r.Specified_Price_Level_1_12__c,
            Specified_Rep__r.Specified_Price_Level_13_20__c,
            Specified_Rep__r.Specified_Price_Level_21_26__c,
            Specified_Rep__r.Specified_Price_Level_27_30__c,

            Sales_Rep_O__r.Price_Level_1_12__c,
            Sales_Rep_O__r.Price_Level_13_20__c,
            Sales_Rep_O__r.Price_Level_21_26__c,
            Sales_Rep_O__r.Man_Rep_Price_Level_1_12__c,
            Sales_Rep_O__r.Man_Rep_Price_Level_13_20__c,
            Sales_Rep_O__r.Man_Rep_Price_Level_21_26__c,


            Sales_Rep_O__r.Price_Level_1_5__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_1_5__c,
            Sales_Rep_O__r.Price_Level_5__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_5__c,
            Sales_Rep_O__r.Price_Level_6__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_6__c,
            Sales_Rep_O__r.Price_Level_7__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_7__c,
            Sales_Rep_O__r.Price_Level_8__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_8__c,
            Sales_Rep_O__r.Price_Level_9_12__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_9_12__c,
            Sales_Rep_O__r.Price_Level_13_16__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_13_16__c,
            Sales_Rep_O__r.Price_Level_17__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_17__c,
            Sales_Rep_O__r.Price_Level_18__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_18__c,
            Sales_Rep_O__r.Price_Level_19__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_19__c,
            Sales_Rep_O__r.Price_Level_20__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_20__c,
            Sales_Rep_O__r.Price_Level_21__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_21__c,
            Sales_Rep_O__r.Price_Level_22__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_22__c,
            Sales_Rep_O__r.Price_Level_23__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_23__c,
            Sales_Rep_O__r.Price_Level_24__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_24__c,
            Sales_Rep_O__r.Price_Level_25__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_25__c,
            Sales_Rep_O__r.Price_Level_26__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_26__c,
            Sales_Rep_O__r.Price_Level_27_30__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_27_30__c,





            referral_sales_rep__r.Ref_Rep_Price_Level_1_12__c,
            referral_sales_rep__r.Ref_Rep_Price_Level_13_20__c,
            referral_sales_rep__r.Ref_Rep_Price_Level_21_26__c,
            referral_sales_rep__r.Ref_Rep_Price_Level_27_30__c
            FROM AcctSeedERP__Sales_Order__c
            WHERE id IN :soIds
          ];

        return orders;
    }


    public static List<Opportunity> getOpportunityData(Set<Id> oppIds){
      List<Opportunity> data = [SELECT Id,
                                      Run_Validation_Rule__c,
                                      Commission_Rate_Manufacturer_Rep__c,
                                      Commission_Rate_Referral_Sales_Rep__c,
                                      Commission_Rate_Sales_Rep__c,
                                      Commission_Rate_Specified_Rep__c,
                                      Manufacturer_Rep__c,
                                      Specified_Rep__c,
                                      Sales_Rep_O__c,
                                      Referral_Sales_Rep__c,
                                      Price_Level__c,

                                      Manufacturer_Rep__r.Price_Level_1_12__c,
                                      Manufacturer_Rep__r.Price_Level_13_20__c,
                                      Manufacturer_Rep__r.Price_Level_21_26__c,
                                      Manufacturer_Rep__r.Price_Level_27_30__c,
                                      
                                      Specified_Rep__r.Specified_Price_Level_1_12__c,
                                      Specified_Rep__r.Specified_Price_Level_13_20__c,
                                      Specified_Rep__r.Specified_Price_Level_21_26__c,
                                      Specified_Rep__r.Specified_Price_Level_27_30__c,
                            
                                      Sales_Rep_O__r.Price_Level_1_5__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_1_5__c,
            Sales_Rep_O__r.Price_Level_5__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_5__c,
            Sales_Rep_O__r.Price_Level_6__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_6__c,
            Sales_Rep_O__r.Price_Level_7__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_7__c,
            Sales_Rep_O__r.Price_Level_8__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_8__c,
            Sales_Rep_O__r.Price_Level_9_12__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_9_12__c,
            Sales_Rep_O__r.Price_Level_13_16__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_13_16__c,
            Sales_Rep_O__r.Price_Level_17__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_17__c,
            Sales_Rep_O__r.Price_Level_18__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_18__c,
            Sales_Rep_O__r.Price_Level_19__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_19__c,
            Sales_Rep_O__r.Price_Level_20__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_20__c,
            Sales_Rep_O__r.Price_Level_21__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_21__c,
            Sales_Rep_O__r.Price_Level_22__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_22__c,
            Sales_Rep_O__r.Price_Level_23__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_23__c,
            Sales_Rep_O__r.Price_Level_24__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_24__c,
            Sales_Rep_O__r.Price_Level_25__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_25__c,
            Sales_Rep_O__r.Price_Level_26__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_26__c,
            Sales_Rep_O__r.Price_Level_27_30__c,
            Sales_Rep_O__r.Man_Spec_Rep_Price_Level_27_30__c,

                                      referral_sales_rep__r.Ref_Rep_Price_Level_1_12__c,
                                      referral_sales_rep__r.Ref_Rep_Price_Level_13_20__c,
                                      referral_sales_rep__r.Ref_Rep_Price_Level_21_26__c,
                                      referral_sales_rep__r.Ref_Rep_Price_Level_27_30__c
                                FROM Opportunity 
                                WHERE Id IN:oppIDs];
      return data;
    }



    /*********************************************************/
    /*                                                       */
    /*                Opportunity Commission Rates           */
    /*                                                       */
    /*********************************************************/

    /*
        Usefull information:
        Sales Rep - Sales_Rep__c object
        Manufacturer Rep - Account object
        Referral Rep - User object
        Specified Rep - Account object

        All of this objects contains rates by Price Level.
        There are 4 different Levels:
        1. 1 - 12
        2. 13 - 20
        3. 21 - 26
        4. 27 - 30

        On Account object could be some misunderstanding in rates.
        Price_Level_1_12__c and etc. its Manufacturer Rep Rates.
        Specified_Price_Level_1_12__c its Specified Rep Rates.
        Also on Account object are Referral_Price_Level_13_20__c those fields, but they are USELESS. Because we take referral rates from USER object.
        Maybe it's already deleted.
        
        Sales Rep rates gets from Sales_Rep__c object:
        Price_Level_1_12__c and etc its default rates if Manufacturer or Specified rep is not filled on Opportunity or Sales Order objects.
        Man_Rep_Price_Level_1_12__c current rates need to use if Opportunity or Sales Order has filled Specified or Manufacture Rep fields


    */

    /*****************************************************************************************************
    *   @method       : assignOpportunityCommissionRates
    *   @description  : executes in trigger after insert, checks filled reps and assign commission rates for opportunity
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public static void assignOpportunityCommissionRates(List<Opportunity> trigger_new){
        Set<Id> opportunityIds = new Set<Id>();

        if(!trigger_new.isEmpty()){
            for(Opportunity opp: trigger_new){
              //Make set of ids from trigger new for query, because we need referenced fields
              opportunityIds.add(opp.Id);
            }

            List<Opportunity> opportunities = getOpportunityData(opportunityIds); //Query method
            List<Opportunity> opportunitiesForUpdate = new List<Opportunity>();
            system.debug(1);
            for(Opportunity opp: opportunities){
                //If price level is not populated, than we can't identify commission rates
                if(opp.Price_Level__c != null){
                  system.debug(2);
                    Integer priceLevel = Integer.valueOf(opp.Price_Level__c.split('\\ ')[1]); //Price level has view: Level 12, we need parse it and get only integer
                    system.debug(3);
                    //Check every rep is it filled
                    if(opp.Sales_Rep_O__c != null){
                        //For sales rep we need to check does opportunity has filled Manufacturer or Specified reps
                        //Because depends on it commission rates for Sales Rep can be different
                        Boolean hasManRep = opp.Manufacturer_Rep__c != null || opp.Specified_Rep__c != null;
                        opp.Commission_Rate_Sales_Rep__c = assignOpportunitySalesRepCommissionRate(opp, priceLevel, hasManRep);
                    }
        
                    if(opp.Manufacturer_Rep__c != null){
                        opp.Commission_Rate_Manufacturer_Rep__c = assignOpportunityManufRepCommissionRate(opp, priceLevel);
                    }
        
                    if(opp.Referral_Sales_Rep__c != null){
                        opp.Commission_Rate_Referral_Sales_Rep__c = assignOpportunityReferralRepCommissionRate(opp, priceLevel);
                    }
        
                    if(opp.Specified_Rep__c != null){
                      opp.Commission_Rate_Specified_Rep__c = assignOpportunitySpecifiedRepCommissionRate(opp, priceLevel);
                    }

                    if(opp.Sales_Rep_O__c != null 
                    || opp.Manufacturer_Rep__c != null
                    || opp.Referral_Sales_Rep__c != null
                    || opp.Specified_Rep__c != null){

                        opportunitiesForUpdate.add(opp);
                    }
                }
            }
            //After going through loop, commission rates fields are populated and we need to update records.
            if(!opportunitiesForUpdate.isEmpty()){
                update opportunitiesForUpdate;

                for(Opportunity opp: opportunitiesForUpdate){
                    CalculateCommissionsHandler.updateExistingCommissions(opp.Id);
                }
            }
            
        }
        
    }

    public static Boolean triggerRunes = true;

    /*****************************************************************************************************
    *   @method       : updateOpportunityCommissionRates
    *   @description  : executes in trigger after update, check changes of reps and if needed recalculate commission rates
    *   @return       : void
    *   @author       : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public static void updateOpportunityCommissionRates(String trigger_new_json, String trigger_old_json){

        //As method runs in trigger context, we receive Trigger.new and Trigger.old maps
        Map<Id, Opportunity> trigger_new = (Map<Id, Opportunity>)JSON.deserialize(trigger_new_json, Map<Id, Opportunity>.class);
        Map<Id, Opportunity> trigger_old = (Map<Id, Opportunity>)JSON.deserialize(trigger_old_json, Map<Id, Opportunity>.class);

        Set<Id> opportunityIds = trigger_new.keySet();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(getOpportunityData(opportunityIds)); //Query refferenced fields of opportunity and making a map
        List<Opportunity> opportunitiesForUpdate = new List<Opportunity>(); //Current list will be used in updating recalculated opportunity records

        for(Id opportunityId: trigger_new.keySet()){
            if(trigger_new.get(opportunityId).Price_Level__c == null) continue;
            Integer priceLevel = Integer.valueOf(trigger_new.get(opportunityId).Price_Level__c.split('\\ ')[1]);

            if(trigger_new.get(opportunityId).Sales_Rep_O__c != trigger_old.get(opportunityId).Sales_Rep_O__c){
                if(trigger_new.get(opportunityId).Sales_Rep_O__c != null){
                    Boolean hasManRep = trigger_new.get(opportunityId).Manufacturer_Rep__c != null || trigger_new.get(opportunityId).Specified_Rep__c != null;
                    opportunityMap.get(opportunityId).Commission_Rate_Sales_Rep__c = assignOpportunitySalesRepCommissionRate(opportunityMap.get(opportunityId), priceLevel, hasManRep);
                }else{
                  opportunityMap.get(opportunityId).Commission_Rate_Sales_Rep__c = null;
                }
            }

            if(trigger_new.get(opportunityId).Manufacturer_Rep__c != trigger_old.get(opportunityId).Manufacturer_Rep__c){
                Boolean isManufactureRepExists = trigger_new.get(opportunityId).Manufacturer_Rep__c != null;
                if(trigger_new.get(opportunityId).Manufacturer_Rep__c != null){
                  opportunityMap.get(opportunityId).Commission_Rate_Manufacturer_Rep__c = assignOpportunityManufRepCommissionRate(opportunityMap.get(opportunityId), priceLevel);
                }else{
                  opportunityMap.get(opportunityId).Commission_Rate_Manufacturer_Rep__c = null;
                }

            }

            if(trigger_new.get(opportunityId).Referral_Sales_Rep__c != trigger_old.get(opportunityId).Referral_Sales_Rep__c){
                if(trigger_new.get(opportunityId).Referral_Sales_Rep__c != null){
                  opportunityMap.get(opportunityId).Commission_Rate_Referral_Sales_Rep__c = assignOpportunityReferralRepCommissionRate(opportunityMap.get(opportunityId), priceLevel);
                }else{
                  opportunityMap.get(opportunityId).Commission_Rate_Referral_Sales_Rep__c = null;
                }
            }

            if(trigger_new.get(opportunityId).Specified_Rep__c != trigger_old.get(opportunityId).Specified_Rep__c){
                Boolean isSpecifiedRepExists = trigger_new.get(opportunityId).Specified_Rep__c != null;
                if(trigger_new.get(opportunityId).Specified_Rep__c != null){
                  opportunityMap.get(opportunityId).Commission_Rate_Specified_Rep__c = assignOpportunitySpecifiedRepCommissionRate(opportunityMap.get(opportunityId), priceLevel);
                }else{
                  opportunityMap.get(opportunityId).Commission_Rate_Specified_Rep__c = null;
                }

            }
            
            if(trigger_new.get(opportunityId).Specified_Rep__c != null || trigger_new.get(opportunityId).Manufacturer_Rep__c != null){
              opportunityMap.get(opportunityId).Commission_Rate_Sales_Rep__c = assignOpportunitySalesRepCommissionRate(opportunityMap.get(opportunityId), priceLevel, true);
            }else{
              opportunityMap.get(opportunityId).Commission_Rate_Sales_Rep__c = assignOpportunitySalesRepCommissionRate(opportunityMap.get(opportunityId), priceLevel, false);
            }

            if(trigger_new.get(opportunityId).Sales_Rep_O__c != trigger_old.get(opportunityId).Sales_Rep_O__c
              || trigger_new.get(opportunityId).Manufacturer_Rep__c != trigger_old.get(opportunityId).Manufacturer_Rep__c
              || trigger_new.get(opportunityId).Referral_Sales_Rep__c != trigger_old.get(opportunityId).Referral_Sales_Rep__c
              || trigger_new.get(opportunityId).Specified_Rep__c != trigger_old.get(opportunityId).Specified_Rep__c
            ){
              opportunitiesForUpdate.add(opportunityMap.get(opportunityId));

            }
        }
        if(!opportunitiesForUpdate.isEmpty()){
            update opportunitiesForUpdate;

            for(Opportunity opp: opportunitiesForUpdate){
              CalculateCommissionsHandler.updateExistingCommissions(opp.Id);
            }
        }

    }

    public static void handleCheckIfPriceLevelChanged(String trigger_new_json, String trigger_old_json){
        Map<Id, Opportunity> trigger_new = (Map<Id, Opportunity>)JSON.deserialize(trigger_new_json, Map<Id, Opportunity>.class);
        Map<Id, Opportunity> trigger_old = (Map<Id, Opportunity>)JSON.deserialize(trigger_old_json, Map<Id, Opportunity>.class);

        List<Opportunity> need_recalculate = new List<Opportunity>();
        for(Id opportunityId:trigger_new.keySet()){
            if(trigger_new.get(opportunityId).Price_Level__c != trigger_old.get(opportunityId).Price_Level__c){
                need_recalculate.add(trigger_new.get(opportunityId));
            }
        }
        if(!need_recalculate.isEmpty()){
            assignOpportunityCommissionRates(need_recalculate);
        }
    }
    public static Decimal assignOpportunitySalesRepCommissionRate(Opportunity opp, Integer priceLevel, Boolean hasManSpecRep){
        Decimal commissionRate = null;

        if(priceLevel >= 1 && priceLevel < 5){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_1_5__c : opp.Sales_Rep_O__r.Price_Level_1_5__c;
        }else if(priceLevel == 5){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_5__c : opp.Sales_Rep_O__r.Price_Level_5__c;
        }else if(priceLevel == 6){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_6__c : opp.Sales_Rep_O__r.Price_Level_6__c;
        }else if(priceLevel == 7){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_7__c : opp.Sales_Rep_O__r.Price_Level_7__c;
        }else if(priceLevel == 8){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_8__c : opp.Sales_Rep_O__r.Price_Level_8__c;
        }else if(priceLevel >= 9 && priceLevel <= 12){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_9_12__c : opp.Sales_Rep_O__r.Price_Level_9_12__c;
        }else if(priceLevel >= 13 && priceLevel <= 16){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_13_16__c : opp.Sales_Rep_O__r.Price_Level_13_16__c;
        }else if(priceLevel == 17){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_17__c : opp.Sales_Rep_O__r.Price_Level_17__c;
        }else if(priceLevel == 18){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_18__c : opp.Sales_Rep_O__r.Price_Level_18__c;
        }else if(priceLevel == 19){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_19__c : opp.Sales_Rep_O__r.Price_Level_19__c;
        }else if(priceLevel == 20){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_20__c : opp.Sales_Rep_O__r.Price_Level_20__c;
        }else if(priceLevel == 21){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_21__c : opp.Sales_Rep_O__r.Price_Level_21__c;
        }else if(priceLevel == 22){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_22__c : opp.Sales_Rep_O__r.Price_Level_22__c;
        }else if(priceLevel == 23){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_23__c : opp.Sales_Rep_O__r.Price_Level_23__c;
        }else if(priceLevel == 24){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_24__c : opp.Sales_Rep_O__r.Price_Level_24__c;
        }else if(priceLevel == 25){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_25__c : opp.Sales_Rep_O__r.Price_Level_25__c;
        }else if(priceLevel == 26){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_26__c : opp.Sales_Rep_O__r.Price_Level_26__c;
        }else if(priceLevel >= 27 && priceLevel <= 30){
            commissionRate = hasManSpecRep ? opp.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_27_30__c : opp.Sales_Rep_O__r.Price_Level_27_30__c;
        }
        return commissionRate;
    }

    public static Decimal assignOpportunityManufRepCommissionRate(Opportunity opp, Integer priceLevel){
        Decimal commissionRate = null;

        if(priceLevel >= 1 && priceLevel <= 12){
            commissionRate = opp.Manufacturer_Rep__r.Price_Level_1_12__c;
        }else if(priceLevel >= 13 && priceLevel <= 20){
            commissionRate = opp.Manufacturer_Rep__r.Price_Level_13_20__c;
        }else if(priceLevel >= 21 && priceLevel <= 26){
            commissionRate = opp.Manufacturer_Rep__r.Price_Level_21_26__c;
        }else if(priceLevel >= 27 && priceLevel <= 30){
            commissionRate = opp.Manufacturer_Rep__r.Price_Level_27_30__c;
        }

        return commissionRate;
    }

    public static Decimal assignOpportunityReferralRepCommissionRate(Opportunity opp, Integer priceLevel){
        Decimal commissionRate = null;

        if(priceLevel >= 1 && priceLevel <= 12){
            commissionRate = opp.referral_sales_rep__r.Ref_Rep_Price_Level_1_12__c;
        }else if(priceLevel >= 13 && priceLevel <= 20){
            commissionRate = opp.referral_sales_rep__r.Ref_Rep_Price_Level_13_20__c;
        }else if(priceLevel >= 21 && priceLevel <= 26){
            commissionRate = opp.referral_sales_rep__r.Ref_Rep_Price_Level_21_26__c;
        }else if(priceLevel >= 27 && priceLevel <= 30){
            commissionRate = opp.referral_sales_rep__r.Ref_Rep_Price_Level_27_30__c;
        }

        return commissionRate;
    }
    public static Decimal assignOpportunitySpecifiedRepCommissionRate(Opportunity opp, Integer priceLevel){
        Decimal commissionRate = null;
        system.debug('opp: '+JSON.serialize(opp));
        if(priceLevel >= 1 && priceLevel <= 12){
            commissionRate = opp.Specified_Rep__r.Specified_Price_Level_1_12__c;
        }else if(priceLevel >= 13 && priceLevel <= 20){
            commissionRate = opp.Specified_Rep__r.Specified_Price_Level_13_20__c;
        }else if(priceLevel >= 21 && priceLevel <= 26){
            commissionRate = opp.Specified_Rep__r.Specified_Price_Level_21_26__c;
        }else if(priceLevel >= 27 && priceLevel <= 30){
            commissionRate = opp.Specified_Rep__r.Specified_Price_Level_27_30__c;
        }

        return commissionRate;
    }



    /*********************************************************/
    /*                                                       */
    /*                Sales Order Commission Rates           */
    /*                                                       */
    /*********************************************************/
    public static Boolean isSOCommissionRateTriggerRun = false;
    public static void assignSalesOrderCommissionRates(List<AcctSeedERP__Sales_Order__c> trigger_new){

        Set<Id> salesOrderIds = new Set<Id>();

        if(!trigger_new.isEmpty()){
            for(AcctSeedERP__Sales_Order__c so: trigger_new){
                salesOrderIds.add(so.Id);
            }
            List<AcctSeedERP__Sales_Order__c> salesOrders = getSalesOrderRecords(salesOrderIds);

            for(AcctSeedERP__Sales_Order__c so: salesOrders){
                if(so.Price_Level__c != null){
                    Integer priceLevel = Integer.valueOf(so.Price_Level__c.split('\\ ')[1]);

                    if(so.Sales_Rep_O__c != null){
                        Boolean hasManRep = so.Manufacturer_Rep__c != null || so.Specified_Rep__c != null;
                        so.Commission_Rate_Sales_Rep__c = assignSalesOrderSalesRepCommissionRate(so, priceLevel, hasManRep);
                    }
        
                    if(so.Manufacturer_Rep__c != null){
                        so.Commission_Rate_Manufacturer_Rep__c = assignSalesOrderManufRepCommissionRate(so, priceLevel);
                    }
        
                    if(so.Referral_Sales_Rep__c != null){
                        so.Commission_Rate_Referral_Sales_Rep__c = assignSalesOrderReferralRepCommissionRate(so, priceLevel);
                    }
        
                    if(so.Specified_Rep__c != null){
                        so.Commission_Rate_Specified_Rep__c = assignSalesOrderSpecifiedRepCommissionRate(so, priceLevel);
                    }

                }
            }
            if(!salesOrders.isEmpty()){
                update salesOrders;

                for(AcctSeedERP__Sales_Order__c so:salesOrders){
                  CalculateCommissionsHandler.updateExistingCommissions(so.Id);
              }
            }
        }
      
    }





    public static void updateSalesOrderCommissionRates(String trigger_new_json, String trigger_old_json){

        Map<Id, AcctSeedERP__Sales_Order__c> trigger_new = (Map<Id, AcctSeedERP__Sales_Order__c>)JSON.deserialize(trigger_new_json, Map<Id, AcctSeedERP__Sales_Order__c>.class);
        Map<Id, AcctSeedERP__Sales_Order__c> trigger_old = (Map<Id, AcctSeedERP__Sales_Order__c>)JSON.deserialize(trigger_old_json, Map<Id, AcctSeedERP__Sales_Order__c>.class);

        system.debug('trigger_new: '+JSON.serialize(trigger_new));
        system.debug('trigger_old: '+JSON.serialize(trigger_old));
        Set<Id> salesOrderIds = trigger_new.keySet();
        Map<Id, AcctSeedERP__Sales_Order__c> salesOrderMap = new Map<Id, AcctSeedERP__Sales_Order__c>(getSalesOrderRecords(salesOrderIds));

        // Map<Id, AcctSeedERP__Sales_Order__c> opportunityMap = new Map<Id, AcctSeedERP__Sales_Order__c>(getSalesOrderRecords(salesOrderIds));
        List<AcctSeedERP__Sales_Order__c> salesOrdersForUpdate = new List<AcctSeedERP__Sales_Order__c>();

        for(Id salesOrderId: salesOrderMap.keySet()){
            if(trigger_new.get(salesOrderId).Price_Level__c == null) continue;
            Integer priceLevel = Integer.valueOf(trigger_new.get(salesOrderId).Price_Level__c.split('\\ ')[1]);

            if(trigger_new.get(salesOrderId).Sales_Rep_O__c != trigger_old.get(salesOrderId).Sales_Rep_O__c){
                if(trigger_new.get(salesOrderId).Sales_Rep_O__c != null){
                    Boolean hasManRep = trigger_new.get(salesOrderId).Manufacturer_Rep__c != null || trigger_new.get(salesOrderId).Specified_Rep__c != null;
                    salesOrderMap.get(salesOrderId).Commission_Rate_Sales_Rep__c = assignSalesOrderSalesRepCommissionRate(salesOrderMap.get(salesOrderId), priceLevel, hasManRep);
                }else{
                  salesOrderMap.get(salesOrderId).Commission_Rate_Sales_Rep__c = null;
                }
            }

            system.debug(1);
            system.debug('trigger_new.get(salesOrderId): '+JSON.serialize(trigger_new.get(salesOrderId)));
            if(trigger_new.get(salesOrderId).Manufacturer_Rep__c != trigger_old.get(salesOrderId).Manufacturer_Rep__c){
              system.debug(2);
                Boolean isManufactureRepExists = trigger_new.get(salesOrderId).Manufacturer_Rep__c != null;
                if(trigger_new.get(salesOrderId).Manufacturer_Rep__c != null){
                  system.debug(3);
                  system.debug('assignSalesOrderManufRepCommissionRate(salesOrderMap.get(salesOrderId), priceLevel): '+assignSalesOrderManufRepCommissionRate(salesOrderMap.get(salesOrderId), priceLevel));
                  salesOrderMap.get(salesOrderId).Commission_Rate_Manufacturer_Rep__c = assignSalesOrderManufRepCommissionRate(salesOrderMap.get(salesOrderId), priceLevel);
                }else{
                  system.debug(4);
                  salesOrderMap.get(salesOrderId).Commission_Rate_Manufacturer_Rep__c = null;
                }

            }

            if(trigger_new.get(salesOrderId).Referral_Sales_Rep__c != trigger_old.get(salesOrderId).Referral_Sales_Rep__c){
                if(trigger_new.get(salesOrderId).Referral_Sales_Rep__c != null){
                  salesOrderMap.get(salesOrderId).Commission_Rate_Referral_Sales_Rep__c = assignSalesOrderReferralRepCommissionRate(salesOrderMap.get(salesOrderId), priceLevel);
                }else{
                  salesOrderMap.get(salesOrderId).Commission_Rate_Referral_Sales_Rep__c = null;
                }
            }

            if(trigger_new.get(salesOrderId).Specified_Rep__c != trigger_old.get(salesOrderId).Specified_Rep__c){
                Boolean isSpecifiedRepExists = trigger_new.get(salesOrderId).Specified_Rep__c != null;
                if(trigger_new.get(salesOrderId).Specified_Rep__c != null){
                  salesOrderMap.get(salesOrderId).Commission_Rate_Specified_Rep__c = assignSalesOrderSpecifiedRepCommissionRate(salesOrderMap.get(salesOrderId), priceLevel);
                }else{
                  salesOrderMap.get(salesOrderId).Commission_Rate_Specified_Rep__c = null;
                }

            }
            
            if(trigger_new.get(salesOrderId).Specified_Rep__c != null || trigger_new.get(salesOrderId).Manufacturer_Rep__c != null){
              salesOrderMap.get(salesOrderId).Commission_Rate_Sales_Rep__c = assignSalesOrderSalesRepCommissionRate(salesOrderMap.get(salesOrderId), priceLevel, true);
            }else{
              salesOrderMap.get(salesOrderId).Commission_Rate_Sales_Rep__c = assignSalesOrderSalesRepCommissionRate(salesOrderMap.get(salesOrderId), priceLevel, false);
            }

            if(trigger_new.get(salesOrderId).Sales_Rep_O__c != trigger_old.get(salesOrderId).Sales_Rep_O__c
              || trigger_new.get(salesOrderId).Manufacturer_Rep__c != trigger_old.get(salesOrderId).Manufacturer_Rep__c
              || trigger_new.get(salesOrderId).Referral_Sales_Rep__c != trigger_old.get(salesOrderId).Referral_Sales_Rep__c
              || trigger_new.get(salesOrderId).Specified_Rep__c != trigger_old.get(salesOrderId).Specified_Rep__c
            ){
              salesOrdersForUpdate.add(salesOrderMap.get(salesOrderId));

            }
        }
        if(!salesOrdersForUpdate.isEmpty()){
            update salesOrdersForUpdate;
            for(AcctSeedERP__Sales_Order__c so:salesOrdersForUpdate){
                CalculateCommissionsHandler.updateExistingCommissions(so.Id);
            }
        }

    }

    public static void handleCheckIfSalesOrderPriceLevelChanged(String trigger_new_json, String trigger_old_json){
        Map<Id, AcctSeedERP__Sales_Order__c> trigger_new = (Map<Id, AcctSeedERP__Sales_Order__c>)JSON.deserialize(trigger_new_json, Map<Id, AcctSeedERP__Sales_Order__c>.class);
        Map<Id, AcctSeedERP__Sales_Order__c> trigger_old = (Map<Id, AcctSeedERP__Sales_Order__c>)JSON.deserialize(trigger_old_json, Map<Id, AcctSeedERP__Sales_Order__c>.class);

        List<AcctSeedERP__Sales_Order__c> need_recalculate = new List<AcctSeedERP__Sales_Order__c>();
        for(Id salesOrderId:trigger_new.keySet()){
            if(trigger_new.get(salesOrderId).Price_Level__c != trigger_old.get(salesOrderId).Price_Level__c){
                need_recalculate.add(trigger_new.get(salesOrderId));
            }
        }
        if(!need_recalculate.isEmpty()){
          assignSalesOrderCommissionRates(need_recalculate);
        }
    }

    public static Decimal assignSalesOrderSalesRepCommissionRate(AcctSeedERP__Sales_Order__c so, Integer priceLevel, Boolean hasManSpecRep){
        Decimal commissionRate = null;

        if(priceLevel >= 1 && priceLevel < 5){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_1_5__c : so.Sales_Rep_O__r.Price_Level_1_5__c;
        }else if(priceLevel == 5){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_5__c : so.Sales_Rep_O__r.Price_Level_5__c;
        }else if(priceLevel == 6){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_6__c : so.Sales_Rep_O__r.Price_Level_6__c;
        }else if(priceLevel == 7){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_7__c : so.Sales_Rep_O__r.Price_Level_7__c;
        }else if(priceLevel == 8){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_8__c : so.Sales_Rep_O__r.Price_Level_8__c;
        }else if(priceLevel >= 9 && priceLevel <= 12){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_9_12__c : so.Sales_Rep_O__r.Price_Level_9_12__c;
        }else if(priceLevel >= 13 && priceLevel <= 16){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_13_16__c : so.Sales_Rep_O__r.Price_Level_13_16__c;
        }else if(priceLevel == 17){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_17__c : so.Sales_Rep_O__r.Price_Level_17__c;
        }else if(priceLevel == 18){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_18__c : so.Sales_Rep_O__r.Price_Level_18__c;
        }else if(priceLevel == 19){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_19__c : so.Sales_Rep_O__r.Price_Level_19__c;
        }else if(priceLevel == 20){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_20__c : so.Sales_Rep_O__r.Price_Level_20__c;
        }else if(priceLevel == 21){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_21__c : so.Sales_Rep_O__r.Price_Level_21__c;
        }else if(priceLevel == 22){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_22__c : so.Sales_Rep_O__r.Price_Level_22__c;
        }else if(priceLevel == 23){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_23__c : so.Sales_Rep_O__r.Price_Level_23__c;
        }else if(priceLevel == 24){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_24__c : so.Sales_Rep_O__r.Price_Level_24__c;
        }else if(priceLevel == 25){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_25__c : so.Sales_Rep_O__r.Price_Level_25__c;
        }else if(priceLevel == 26){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_26__c : so.Sales_Rep_O__r.Price_Level_26__c;
        }else if(priceLevel >= 27 && priceLevel <= 30){
            commissionRate = hasManSpecRep ? so.Sales_Rep_O__r.Man_Spec_Rep_Price_Level_27_30__c : so.Sales_Rep_O__r.Price_Level_27_30__c;
        }
        return commissionRate;

    }

    public static Decimal assignSalesOrderManufRepCommissionRate(AcctSeedERP__Sales_Order__c so, Integer priceLevel){
        Decimal commissionRate = null;

        if(priceLevel >= 1 && priceLevel <= 12){
            commissionRate = so.Manufacturer_Rep__r.Price_Level_1_12__c;
        }else if(priceLevel >= 13 && priceLevel <= 20){
            commissionRate = so.Manufacturer_Rep__r.Price_Level_13_20__c;
        }else if(priceLevel >= 21 && priceLevel <= 26){
            commissionRate = so.Manufacturer_Rep__r.Price_Level_21_26__c;
        }else if(priceLevel >= 27 && priceLevel <= 30){
            commissionRate = so.Manufacturer_Rep__r.Price_Level_27_30__c;
        }

        return commissionRate;
    }

    public static Decimal assignSalesOrderReferralRepCommissionRate(AcctSeedERP__Sales_Order__c so, Integer priceLevel){
        Decimal commissionRate = null;

        if(priceLevel >= 1 && priceLevel <= 12){
            commissionRate = so.referral_sales_rep__r.Ref_Rep_Price_Level_1_12__c;
        }else if(priceLevel >= 13 && priceLevel <= 20){
            commissionRate = so.referral_sales_rep__r.Ref_Rep_Price_Level_13_20__c;
        }else if(priceLevel >= 21 && priceLevel <= 26){
            commissionRate = so.referral_sales_rep__r.Ref_Rep_Price_Level_21_26__c;
        }else if(priceLevel >= 27 && priceLevel <= 30){
            commissionRate = so.referral_sales_rep__r.Ref_Rep_Price_Level_27_30__c;
        }

        return commissionRate;
    }

    public static Decimal assignSalesOrderSpecifiedRepCommissionRate(AcctSeedERP__Sales_Order__c so, Integer priceLevel){
        Decimal commissionRate = null;
        system.debug('so: '+JSON.serialize(so));
        if(priceLevel >= 1 && priceLevel <= 12){
            commissionRate = so.Specified_Rep__r.Specified_Price_Level_1_12__c;
        }else if(priceLevel >= 13 && priceLevel <= 20){
            commissionRate = so.Specified_Rep__r.Specified_Price_Level_13_20__c;
        }else if(priceLevel >= 21 && priceLevel <= 26){
            commissionRate = so.Specified_Rep__r.Specified_Price_Level_21_26__c;
        }else if(priceLevel >= 27 && priceLevel <= 30){
            commissionRate = so.Specified_Rep__r.Specified_Price_Level_27_30__c;
        }

        return commissionRate;
    }
}