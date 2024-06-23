/**
 * @description       : DAL class for Grant Disbursement.
 * @author            : Wishwa Sigera
 * @group             : 
 * @last modified on  : 06-24-2024
 * @last modified by  : Wishwa Sigera
**/
public without sharing class GrantDisbursementDAL {
    /**
    * @description Method for insert Grant Disbursement records.
    * @author Wishwa Sigera | 06-23-2024 
    * @param records 
    * @return List<Grant_Disbursement__c> 
    **/
    public static List<Grant_Disbursement__c> insertGrantDisbursement(List<Grant_Disbursement__c> records) {
        if (AuthorizationUtil.isCreateable(Grant_Disbursement__c.SObjectType)) {
            insert records;
            return records;
        } else {
            throw new AuthorizationException(System.Label.Authorization_Exception_Insert_Grant_Disbursement);
        }
    }

    /**
    * @description Method for delete Grant Disbursment records.
    * @author Wishwa Sigera | 06-23-2024 
    * @param records 
    **/
    public static void deleteDisbursement(List<Grant_Disbursement__c> records) {
        delete records;
    }

    /**
    * @description Method to get Grant Disbursment by Contact Id.
    * @author Wishwa Sigera | 06-23-2024 
    * @param contactId 
    * @return List<Grant_Disbursement__c> 
    **/
    public static List<Grant_Disbursement__c> getGrantDisbursementByContactId(String contactId) {
        if(AuthorizationUtil.isAccessible(Grant_Disbursement__c.SObjectType)){
            List<Grant_Disbursement__c> existingRecords = [SELECT Id, Disbursed_Amount__c, Disbursed_Date__c, Grant_is_disbursed__c FROM Grant_Disbursement__c WHERE Grant_Applicant__c = :contactId WITH SECURITY_ENFORCED];
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, existingRecords, true);
            return existingRecords;
        } 
        throw new AuthorizationException(System.Label.Authorization_Exception_Access_Grant_Disbursement);
    } 
}