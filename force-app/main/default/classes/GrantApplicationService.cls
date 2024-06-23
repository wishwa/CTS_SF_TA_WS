/**
 * @description       : Service class for Grant Applications
 * @author            : Wishwa Sigera
 * @group             : 
 * @last modified on  : 06-24-2024
 * @last modified by  : Wishwa Sigera
**/
public with sharing class GrantApplicationService {
    public static Boolean throwException = false;
    
    /**
    * @description This method will help to submit the Grant Application
    * @author Wishwa Sigera | 06-23-2024 
    * @param firstName 
    * @param lastName 
    * @param phone 
    * @param postalCode 
    * @param monthlyIncome 
    * @param supportOption 
    **/
    public static void submitApplication(String firstName, String lastName, String phone, String postalCode, Decimal monthlyIncome, String supportOption) {
        Contact contact = ContactDAL.getContactByPhone(phone);
        Grant_Option__mdt grantOption = GrantOptionDAL.getGrantOptionByDeveloperName(supportOption);
        Boolean isEligible = checkEligibility(monthlyIncome, supportOption);

        if (contact == null) {
            contact = new Contact(
                FirstName = firstName,
                LastName = lastName,
                Phone = phone,
                MailingPostalCode = postalCode,
                Monthly_Income__c = monthlyIncome,
                Support_Option_Name__c = supportOption,
                Is_Eligible__c = isEligible
            );
            contact = ContactDAL.insertContact(contact);

            createDisbursementRecords(contact.Id, grantOption.Amount__c, Integer.valueOf(grantOption.Number_of_Months__c));
        } else {
            contact.FirstName = firstName;
            contact.LastName = lastName;
            contact.MailingPostalCode = postalCode;
            contact.Monthly_Income__c = monthlyIncome;
            contact.Support_Option_Name__c = supportOption;
            contact.Is_Eligible__c = isEligible;
            ContactDAL.updateContact(contact);

            updateGrantDisbursements(contact.Id, supportOption);
        }
    }

    /**
    * @description This method will help to check the eligibility of the Grant application.
    * @author Wishwa Sigera | 06-23-2024 
    * @param monthlyIncome 
    * @param supportOption 
    * @return boolean 
    **/
    public static boolean checkEligibility(Decimal monthlyIncome, String supportOption) {
        Grant_Option__mdt grantOption = GrantOptionDAL.getGrantOptionByDeveloperName(supportOption);
        Grant_Rule__mdt grantRule = GrantRuleDAL.getGrantRuleByDeveloperName(grantOption.Grant_Rule__c);
        Boolean isEligible = false;
        if (monthlyIncome < grantRule.Monthly_Income_Limit__c) {
            isEligible = true;
        }
        return isEligible;
    }

    /**
    * @description Create Grant Disbursement records for given applicant, given amount for given number of next months.
    * @author Wishwa Sigera | 06-22-2024 
    * @param contactId 
    * @param amount 
    * @param months 
    **/
    public static void createDisbursementRecords(Id contactId, Decimal amount, Integer months) {
        List<Grant_Disbursement__c> disbursements = new List<Grant_Disbursement__c>();
        Date firstDisbursementDate = Date.today().toStartOfMonth().addMonths(1);
        for (Integer i = 0; i < months; i++) {
            disbursements.add(new Grant_Disbursement__c(
                Grant_Applicant__c = contactId,
                Disbursed_Amount__c = amount,
                Disbursed_Date__c = firstDisbursementDate.addMonths(i),
                Grant_is_disbursed__c = false
            ));
        }
        if (!disbursements.isEmpty()) {
            GrantDisbursementDAL.insertGrantDisbursement(disbursements);
            System.debug(LoggingLevel.INFO, 'Grant disburse inserted successfully');
        } else {
            System.debug(LoggingLevel.INFO, 'No disbursements to delete');
        }
    }

    public static void updateGrantDisbursements(Id contactId, String supportOption) {
        List<Grant_Disbursement__c> disbursements = new List<Grant_Disbursement__c>();
        List<Grant_Disbursement__c> toDeleteDisbursements = new List<Grant_Disbursement__c>();
        // Fetch existing Grant_Disbursement__c records
        List<Grant_Disbursement__c> existingRecords = GrantDisbursementDAL.getGrantDisbursementByContactId(contactId);
        Grant_Option__mdt grantOption = GrantOptionDAL.getGrantOptionByDeveloperName(supportOption);

        Integer numberOfDisburseMonths = 0;
        Decimal totalDisbursed = 0;
        Date lastDisbursed = null;
        for (Grant_Disbursement__c record : existingRecords) {
            if(record.Grant_is_disbursed__c){
                totalDisbursed += record.Disbursed_Amount__c;
                numberOfDisburseMonths ++;
                if(lastDisbursed == null){
                    lastDisbursed = record.Disbursed_Date__c;
                }else{
                    if(record.Disbursed_Date__c > lastDisbursed){
                        lastDisbursed = record.Disbursed_Date__c;     
                    }
                }
            }else{
                //to delete
                toDeleteDisbursements.add(record);
            }
        }

        if(lastDisbursed == null){
            lastDisbursed = Date.today();
        }

        Integer newMonths = Integer.valueOf(grantOption.Number_of_Months__c);
        Decimal newAmount = grantOption.Amount__c;

        Decimal newTotal = newMonths * newAmount;
        if (totalDisbursed > newTotal) {
            throw new ServiceException('Total disbursed amount exceeds the new support option total.');
        }

        Decimal remainingAmount = newTotal - totalDisbursed;
        Integer remainingMonths = newMonths - numberOfDisburseMonths;
        Date newFirstDisbursementDate = lastDisbursed.toStartOfMonth().addMonths(1);
        for (Integer i = 0; i < remainingMonths; i++) {
            disbursements.add(new Grant_Disbursement__c (
                Grant_Applicant__c = contactId,
                Disbursed_Amount__c = remainingAmount / remainingMonths,
                Disbursed_Date__c = newFirstDisbursementDate.addMonths(i),
                Grant_is_disbursed__c = false
            ));
        }

        if (!disbursements.isEmpty()) {
            GrantDisbursementDAL.insertGrantDisbursement(disbursements);
            System.debug(LoggingLevel.INFO, 'Disbursements created successfully');
        } else {
            System.debug(LoggingLevel.INFO, 'No disbursements to create');
        }

        if (!toDeleteDisbursements.isEmpty()) {
            GrantDisbursementDAL.deleteDisbursement(toDeleteDisbursements);
            System.debug(LoggingLevel.INFO, 'Undisburse grant deleted successfully');
        } else {
            System.debug(LoggingLevel.INFO, 'No disbursements to delete');
        }
    }

    /**
    * @description This method will help to get all Grant Options
    * @author Wishwa Sigera | 06-23-2024 
    * @return List<Grant_Option__mdt> 
    **/
    public static List<Grant_Option__mdt> getAllGrantOptions(){
        if(Test.isRunningTest() && throwException){
             throw new ServiceException('Simulated exception for testing');
        }
        return GrantOptionDAL.getAllOptions();
    }

}
