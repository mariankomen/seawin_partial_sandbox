public class KitInventoryHandler {

    public static void Process(List<AcctSeed__Product_Part__c> data){

        map<id, AcctSeed__Product_Part__c> pMap = new map<id, AcctSeed__Product_Part__c>();

        for(AcctSeed__Product_Part__c p : data){

            pMap.put(p.Kit_Product__c, p);
        }

        if(pMap.size() > 0){

            Map<id, list<decimal>> inventoryMap = InventoryCalculationHelper.Calculate(pMap.keyset());

            List<Product2> products = [select id, kit_available_quantity__c from product2 where id in:pMap.keyset()];

            List<Product2> Updatables = new List<Product2>();

            if(!products.isEmpty()){

                for(product2 p : products){

                    List<Decimal> inventory = inventoryMap.containsKey(p.id) ? inventoryMap.get(p.id) : new List<Decimal>();

                    if(!inventory.isEmpty()){

                        p.kit_available_quantity__c = inventory[0];
                        Updatables.add(p);

                    }
                }

                try{

                    if(!Updatables.isEmpty()) update products;

                }catch(Exception ex){

                    system.debug(ex.getMessage());
                }
            }
        }
    }
}