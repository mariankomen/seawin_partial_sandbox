/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-05-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class TransferOptionalProductsController {

    public TransferOptionalProductsController(ApexPages.StandardSetController controller) {

        List<OpportunityLineItem> selected = controller.getSelected();
        system.debug(selected.size());
    }
}