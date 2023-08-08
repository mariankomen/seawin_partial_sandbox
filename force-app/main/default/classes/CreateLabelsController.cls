/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-11-2023
 * @last modified by  : Marian Lyzhychka
**/
public with sharing class CreateLabelsController {
    public String recordId {get;set;}


    public CreateLabelsController() {
        recordId = ApexPages.currentPage().getParameters().get('recordId'); //PO or SO Id.
    }
    
}