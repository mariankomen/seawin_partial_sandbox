/**
 * @description       : 
 * @author            : Marian Lyzhychka
 * @group             : 
 * @last modified on  : 07-11-2023
 * @last modified by  : Marian Lyzhychka
**/
@isTest
public with sharing class CreateLabelsControllerTest {
    
    @isTest
    public static void createLabelsControllerPOSHIPTest(){
        ApexPages.currentPage().getParameters().put('recordId', '0001');
        CreateLabelsController ctrl = new CreateLabelsController();
    }
}