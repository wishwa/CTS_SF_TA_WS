/**
 * @description       : Controller class for Grant Applicaiton
 * @author            : Wishwa Sigera
 * @group             : 
 * @last modified on  : 06-23-2024
 * @last modified by  : Wishwa Sigera
**/
public with sharing class GrantApplicationController {

    /**
    * @description Controller method for submit grant application.
    * @author Wishwa Sigera | 06-23-2024 
    * @param firstName 
    * @param lastName 
    * @param phone 
    * @param postalCode 
    * @param monthlyIncome 
    * @param supportOption 
    **/
    @AuraEnabled
    public static void submitApplication(String firstName, String lastName, String phone, String postalCode, Decimal monthlyIncome, String supportOption){
        try {
            GrantApplicationService.submitApplication(firstName, lastName, phone, postalCode, monthlyIncome, supportOption);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Controller method to get all grant options.
    * @author Wishwa Sigera | 06-23-2024 
    * @return List<Grant_Option__mdt> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Grant_Option__mdt> getAllGrantOptions(){
        try {
            return GrantApplicationService.getAllGrantOptions();
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
}