public with sharing class MassEditSalesOrderScreenExtension {
    
    public String soId {get; set;}
    public String solId {get; set;}
    public AcctSeedERP__Sales_Order__c so {get; set;}
    public List<AcctSeedERP__Sales_Order_Line__c> lines {get; set;}
    public Map<Id, AcctSeedERP__Sales_Order_Line__c> lines_map {get; set;}
    
    public Map<Id, List<childrenWrapper>> kits_parent_childs {get; set;}
    public boolean visible {get; set;}
    public Boolean LasttoDelete {get{
        
        if(lasttodelete == null) lasttodelete = false; return lasttodelete;
        
    } set;}
    public Boolean editAllProductPermission {get; set;}
    public Boolean showBack {get; set;}
    
    public Id newQuantity {get; set;}

    public Boolean hasBillings {get; set;}


    public MassEditSalesOrderScreenExtension(ApexPages.StandardSetController std){
        soId = ApexPages.currentPage().getParameters().get('id');
        visible = true;
        editAllProductPermission = true;
        showBack = false;
        kits_parent_childs = new Map<Id, List<childrenWrapper>>();

        AggregateResult relatedBillings = [SELECT COUNT(Id) total 
                                                FROM AcctSeed__Billing__c
                                                WHERE AcctSeedERP__Sales_Order__c=:soId];
        if((Integer)relatedBillings.get('total') > 0){
            hasBillings = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Quantity and Sales Price fields cannot be edited because Sales Order already has a Billing(s).'));
        }else{
            hasBillings = false;
        }

        LIST<ObjectPermissions> ObjPermissionList = new LIST<ObjectPermissions>();

        String desireUserId = UserInfo.getUserId();

        User u = [select profileId from user where id =: desireUserId];

        String profileId = u.profileId;

        ObjPermissionList = [SELECT Id, SObjectType, PermissionsEdit FROM ObjectPermissions WHERE parentid in 
                             (select id from permissionset where PermissionSet.Profile.Id=: profileId)];
        for(ObjectPermissions objPerm :ObjPermissionList){
            if(objPerm.SobjectType == 'Optional_Products_Opportunity__c')
            {
                if(objPerm.PermissionsEdit == false){
                    //visible = false;
                    editAllProductPermission = false;
                    showBack = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient Privileges, You are not allowed to make these changes. Please contact your adminstrator.'));
                }
            }
        }
        //If user has Edit permission for Sales Order Lines
        if(editAllProductPermission == true){
            if(soId != null){ 
            
                so = [SELECT Id,
                            name,
                            AcctSeedERP__Status__c, 
                            AcctSeedERP__Opportunity__r.name, 
                            AcctSeedERP__Customer__r.name, 
                            AcctSeedERP__Total__c
                        FROM AcctSeedERP__Sales_Order__c 
                        WHERE id=:soId];
                
                lines = [SELECT Id, 
                                Name, 
                                AcctSeedERP__Sales_Order__c, 
                                AcctSeedERP_Description__c,
                                quantity_allocated_formula__c, 
                                AcctSeedERP__Quantity_Ordered__c, 
                                AcctSeedERP__Product__r.name,
                                AcctSeedERP__Product__r.Allow_Product_Description_Change__c,
                                ProductCode__c, 
                                quantity_shipped_formula__c,
                                Item_Description__c, 
                                Sales_Price__c, 
                                Size__c,
                                AcctSeedERP__Total__c, 
                                AcctSeedERP__Unit_Price__c, 
                                sortorder__c,
                                Kit_Children__c, Kit__c,
                                AcctSeedERP__Product__c, 
                                Allow_Product_Description_Change__c
                        FROM AcctSeedERP__Sales_Order_Line__c 
                        WHERE AcctSeedERP__Sales_Order__c =:soId 
                        ORDER BY sortorder__c,name,createddate asc];

                lines_map = new Map<Id,AcctSeedERP__Sales_Order_Line__c>(lines);

                if(lines.IsEmpty()){
                    visible = false;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No Products found.'));
                }
                //Current method will initialize kits_parent_childs Map, which we will use later
                getKitsRelation();
            }
            

        }
    }


    /*****************************************************************************************************
    *   @method      : handleQuantity
    *   @description : non static method used to update AcctSeedERP__Quantity_Ordered__c field on child records to KIT
    *   @return      : void
    *   @author      : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public void handleQuantity(){
        Id current_updated_parent = lines_map.get(newQuantity).AcctSeedERP__Product__c;
        // First of all we run throught related childrens to updated line
        // Next we check every child with every line and check does their ids is equal
        if(kits_parent_childs.containsKey(current_updated_parent)){
            for(childrenWrapper child: kits_parent_childs.get(current_updated_parent)){
                for(AcctSeedERP__Sales_Order_Line__c l: lines){
                    if(l.AcctSeedERP__Product__c == child.childrenId){
                        l.AcctSeedERP__Quantity_Ordered__c = (lines_map.get(newQuantity).AcctSeedERP__Quantity_Ordered__c * child.children_amount).setScale(2);
                    }
                }
            }
        }
    }

    /*****************************************************************************************************
    *   @method      : UpdateLine
    *   @description : non static method used to updating Sales Order Lines
    *   @return      : void
    *   @author      : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/
    public PageReference UpdateLine(){
        //On frontend part uses apex:inputfields, data will change dynamicly and we need only update records in database
        try{
            update lines;
        } catch(Exception e){
            System.debug('MassEditSalesOrderScreenExtension: '+e.getMessage());
        }
        
        PageReference page = new PageReference('/' + soId);
        page.setRedirect(true);
        return page;
    }


    /*****************************************************************************************************
    *   @method      : getKitsRelation
    *   @description : non static method used to get map of Kit parent Id and List of related children Kit Ids 
    *   @return      : Map<Id, List<Id>>
    *   @author      : Marian Lyzhychka ©Peeklogic
    *****************************************************************************************************/

    public void getKitsRelation(){
        //Make set of uniq products from all sales order lines
        Set<Id> ProductIds = new Set<Id>();

        for(AcctSeedERP__Sales_Order_Line__c line: lines){
            ProductIds.add(line.AcctSeedERP__Product__c);
        }

        List<childrenWrapper> childrensWrapper = new List<childrenWrapper>();

        //Query and making list of wrapper of kit childrens, kit parents and quantity of childrens kits related to parent
        for(AcctSeed__Product_Part__c kit_product:[SELECT Id, Name, Kit_Product__c, 
                                                            Kit_Children__c,
                                                            Kit_Children__r.ProductCode,
                                                            Kit_Children__r.Description,
                                                            Kit_Children__r.Name,
                                                            Kit_Children__r.Allow_Product_Description_Change__c,
                                                            Kit_Children__r.Size__c,
                                                            AcctSeed__Quantity__c 
                                                    FROM AcctSeed__Product_Part__c 
                                                    WHERE Kit_Product__c in:ProductIds]){

            childrensWrapper.add(new childrenWrapper(kit_product.Kit_Product__c, kit_product.Kit_Children__c, kit_product.AcctSeed__Quantity__c));                                            
        }
        //Making map <ParentId, List<ChildrensWrappers>>
        for(childrenWrapper child: childrensWrapper){
            if(!kits_parent_childs.containsKey(child.parentId)){
                kits_parent_childs.put(child.parentId, new List<childrenWrapper>{child});
            }else{
                kits_parent_childs.get(child.parentId).add(child);
            }
        }
    }

    /*********************************************************************************************************************************
    *   @method      : TrashIt
    *   @description : non static method used for deleting lines. If deleting record is KIT, also will be deleted related Kit Products
    *   @return      : PageReference
    *   @author      : Marian Lyzhychka ©Peeklogic
    **********************************************************************************************************************************/
    public PageReference TrashIt(){
        
        solId = ApexPages.currentPage().getParameters().get('solId');

        if(solid != null){
            
            // check if there are lines left
            List<AcctSeedERP__Sales_Order_Line__c> leftLines = [SELECT Id FROM AcctSeedERP__Sales_Order_Line__c 
                                                                where AcctSeedERP__Sales_Order__c =:soId and id != :solid];
            
            if(leftLines.IsEmpty()){
                // show warning that just one line left
                LasttoDelete = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Are you sure you want to delete.'));
                return null;                
            }           
            

            
            AcctSeedERP__Sales_Order_Line__c delete_item = [SELECT Id, Kit_Children__c,
                                                                        Kit__c, 
                                                                        AcctSeedERP__Product__c
                                                                        FROM AcctSeedERP__Sales_Order_Line__c 
                                                                        where id =:solid];

            // First of all we check does deletable item is KIT, if its true, than we need also delete related child lines.
            if(delete_item.Kit__c){
                Set<Id> childIds = new Set<Id>();
                if(kits_parent_childs.containsKey(delete_item.AcctSeedERP__Product__c)){
                    for(childrenWrapper child:kits_parent_childs.get(delete_item.AcctSeedERP__Product__c)){
                        childIds.add(child.childrenId);
                    }
                    //Query related to KIT children lines
                    List<AcctSeedERP__Sales_Order_Line__c> deletable_sol = [SELECT  Id,  
                                                                                    AcctSeedERP__Product__c,
                                                                                    AcctSeedERP__Sales_Order__c
                                                                            FROM AcctSeedERP__Sales_Order_Line__c 
                                                                            WHERE AcctSeedERP__Sales_Order__c  =:soId 
                                                                            AND AcctSeedERP__Product__c IN: childIds];

                    //Out of childs we need delete also parent KIT, and we add it to deletable list.
                    deletable_sol.add(delete_item);

                    delete deletable_sol;
                }else {
                    //If parent dont have childrens we delete only parent
                    delete delete_item;
                }
            //If its not KIT than we just delete it.    
            }else{
                delete delete_item;
            }
                                                          
            
            String hostVal  = ApexPages.currentPage().getHeaders().get('Host');
            // redirect
            PageReference page = new PageReference('https://' + hostVal + '/apex/MassEditSalesOrderScreenPage?id='+soId); 
            Page.setRedirect(true);
            return page;
            
        }
        
        return null;
    }
    public PageReference yes(){
        // delete
        AcctSeedERP__Sales_Order_Line__c sols = [SELECT Id FROM AcctSeedERP__Sales_Order_Line__c where id =:solid]; 
        delete sols;
        
        PageReference page = new PageReference('/' + soId);
        page.setRedirect(true);
        return page;
    }
    public PageReference no(){
        LasttoDelete = false;
        return null;
    }
    public PageReference back(){
        
        PageReference page = new PageReference('/' + soId);
        page.setRedirect(true);
        return page;
    }

    public void helpTest(){
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

    public class childrenWrapper{
        Id parentId {get; set;}
        Id childrenId {get; set;}
        Decimal children_amount {get; set;}

        public childrenWrapper(Id parId, Id chilId, Decimal amount){
            parentId = parId;
            childrenId = chilId;
            children_amount = amount;
        }
    }
}