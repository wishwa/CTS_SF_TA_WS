/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class GrantApplicationServiceTest {
    private static final String RESTRICTED_PROFILE_NAME = 'Chatter Free User';
    private static final String RESTRICTED_USER_NAME = 'restricted@agencyx.sg.com';

    @TestSetup
    static void setup() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :RESTRICTED_PROFILE_NAME LIMIT 1];
        User restrictedUser = new User(
            ProfileId = profile.Id,
            Username = RESTRICTED_USER_NAME,
            Email = RESTRICTED_USER_NAME,
            Alias = 'FL',
            FirstName = 'fname',
            LastName = 'last',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = UserInfo.getLocale(),
            TimeZoneSidKey = UserInfo.getTimeZone().getID()
        );
        insert restrictedUser;
    }

    private static User getRestrictedUser() {
        return [SELECT Id FROM User WHERE Username = :RESTRICTED_USER_NAME LIMIT 1];
    }
    
    @IsTest
    static void testRestrictedUser() {
        Account account = new Account();
        account.name = 'Acc1';
        insert account;

        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        contact.Phone = '65 81234567';
        contact.MailingPostalCode = '123456';
        contact.Monthly_Income__c = 1500.00;
        contact.Support_Option_Name__c = 'X500SGD_3M';
        insert contact;

        Test.startTest();
        User restrictedUser = getRestrictedUser();
        System.runAs(restrictedUser) {
            try {
                GrantApplicationService.createDisbursementRecords(contact.Id,200,12);
                Assert.fail(System.Label.Authorization_Exception_Insert_Grant_Disbursement);
            } catch (Exception e) {
                Assert.areEqual(System.Label.Authorization_Exception_Insert_Grant_Disbursement, e.getMessage());
            }

            try {
                GrantApplicationService.updateGrantDisbursements(contact.Id,'X200SGD_12M');
                Assert.fail(System.Label.Authorization_Exception_Access_Grant_Disbursement);
            } catch (Exception e) {
                Assert.areEqual(System.Label.Authorization_Exception_Access_Grant_Disbursement, e.getMessage());
            }
        }
        Test.stopTest();
    }
}