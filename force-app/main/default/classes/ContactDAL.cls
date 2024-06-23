/**
 * @description       : DAL Class for Contact
 * @author            : Wishwa Sigera
 * @group             : 
 * @last modified on  : 06-24-2024
 * @last modified by  : Wishwa Sigera
**/
public without sharing class ContactDAL {
    public static final String ACCOUNT_ID = '001dM00000DYNIrQAP'; //for this assigment account id is hard coded. Ideally we should use person account instead of contact, I used contact object as per the assigment.
    /**
    * @description 
    * @author Wishwa Sigera | 06-22-2024 
    * @param phone 
    * @return Contact 
    **/
    public static Contact getContactByPhone(String phone) {
        if(AuthorizationUtil.isAccessible(Contact.SObjectType)){
            List<Contact> contacts = [ SELECT Id, FirstName, LastName, Phone, MailingPostalCode, Monthly_Income__c, Support_Option_Name__c FROM Contact WHERE Phone = :phone WITH SECURITY_ENFORCED];
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, contacts, true);
            return contacts.isEmpty() ? null : contacts[0];
        } 
        throw new AuthorizationException(System.Label.Authorization_Exception_Contact_Access);
    } 

    /**
    * @description Method for update contact record.
    * @author Wishwa Sigera | 06-22-2024 
    * @param record 
    **/
    public static Contact updateContact(Contact record) {
        if (record.Id == null) {
            throw new DALException(System.Label.DALException_Contact_Not_Found);
        }
        
        update record;
        return record;
    }

    /**
    * @description Method for insert contact record.
    * @author Wishwa Sigera | 06-22-2024 
    * @param record 
    * @return Contact 
    **/
    public static Contact insertContact(Contact record) {
        if (AuthorizationUtil.isCreateable(Contact.SObjectType)) {
            record.accountId = ACCOUNT_ID;
            insert record;
            return record;
        } else {
            throw new AuthorizationException(System.Label.Authorization_Exception_Insert_Contact);
        }
    }
}
