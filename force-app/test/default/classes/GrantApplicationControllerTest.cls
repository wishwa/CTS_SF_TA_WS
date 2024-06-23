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
private class GrantApplicationControllerTest {

    @isTest
    static void submitApplication1Test() {
        try {
            Test.startTest();
            GrantApplicationController.submitApplication('Jhon', 'Smith', '65 81234567', '123456', 1500.00, 'X500SGD_3M');

            List<Contact> contactList = [SELECT Id, FirstName, LastName, Phone, MailingPostalCode, Monthly_Income__c, Support_Option_Name__c FROM Contact WHERE FirstName='Jhon' AND LastName='Smith'];
            Assert.areEqual('X500SGD_3M',contactList[0].Support_Option_Name__c);

            List<Grant_Disbursement__c> existingRecords = [SELECT Id, Disbursed_Amount__c, Disbursed_Date__c, Grant_is_disbursed__c FROM Grant_Disbursement__c WHERE Grant_Applicant__c = :contactList[0].Id];
            Grant_Disbursement__c gd = existingRecords[0];
            gd.Grant_is_disbursed__c = true;
            update gd;

            GrantApplicationController.submitApplication('Jhon', 'Smith', '65 81234567', '123456', 1500.00, 'X200SGD_12M');

            contactList = [SELECT Id, FirstName, LastName, Phone, MailingPostalCode, Monthly_Income__c, Support_Option_Name__c FROM Contact WHERE FirstName='Jhon' AND LastName='Smith'];
            Assert.areEqual('X200SGD_12M', contactList[0].Support_Option_Name__c);
            Test.stopTest();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    @isTest
    static void submitApplication2Test() {
        try {
            Test.startTest();
            GrantApplicationController.submitApplication('Jhon', 'Smith', '65 81234567', '123456', 1500.00, 'X500SGD_3M');

            List<Contact> contactList = [SELECT Id, FirstName, LastName, Phone, MailingPostalCode, Monthly_Income__c, Support_Option_Name__c FROM Contact WHERE FirstName='Jhon' AND LastName='Smith'];
            Assert.areEqual('X500SGD_3M',contactList[0].Support_Option_Name__c);

            GrantApplicationController.submitApplication('Jhon', 'Smith', '65 81234567', '123456', 1500.00, 'X200SGD_12M');

            contactList = [SELECT Id, FirstName, LastName, Phone, MailingPostalCode, Monthly_Income__c, Support_Option_Name__c FROM Contact WHERE FirstName='Jhon' AND LastName='Smith'];
            Assert.areEqual('X200SGD_12M', contactList[0].Support_Option_Name__c);
            Test.stopTest();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    @isTest
    static void submitApplication3Test() {
        try {
            Test.startTest();
            GrantApplicationController.submitApplication('Jhon', 'Smith', '65 81234567', '123456', 1500.00, 'X200SGD_12M');

            List<Contact> contactList = [SELECT Id, FirstName, LastName, Phone, MailingPostalCode, Monthly_Income__c, Support_Option_Name__c FROM Contact WHERE FirstName='Jhon' AND LastName='Smith'];
            Assert.areEqual('X200SGD_12M',contactList[0].Support_Option_Name__c);

            List<Grant_Disbursement__c> existingRecords = [SELECT Id, Disbursed_Amount__c, Disbursed_Date__c, Grant_is_disbursed__c FROM Grant_Disbursement__c WHERE Grant_Applicant__c = :contactList[0].Id];
            
            List<Grant_Disbursement__c>  gdList = new List<Grant_Disbursement__c>();
            for(Integer i = 0; i < 8; i++){
                Grant_Disbursement__c gd = existingRecords[i];
                gd.Grant_is_disbursed__c = true;
                gdList.add(gd);
            }
            update gdList;

            GrantApplicationController.submitApplication('Jhon', 'Smith', '65 81234567', '123456', 1500.00, 'X500SGD_3M');
            Assert.fail('Total disbursed amount exceeds the new support option total expected');
            Test.stopTest();
        } catch (Exception e) {
            System.debug(e.getMessage());
            Assert.areEqual('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    static void submitApplicationExceptionTest() {
        try {
            GrantApplicationController.submitApplication('Jhon', 'Smith', '65 81234567 ', '123456', 1500.00, 'X500SGD_30M');
            Assert.fail('Script-thrown exception expected');
        } catch (Exception e) {
            System.debug(e.getMessage());
            Assert.areEqual('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    static void getAllGrantOptionsTest() {
        try {
            List<Grant_Option__mdt> gOptions = GrantApplicationController.getAllGrantOptions();
            Assert.areEqual(gOptions.size(), 3);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    @isTest
    static void testGetAllGrantOptions_CatchBlock() {
        Test.startTest();

        // Set the flag to true to simulate the exception
        GrantApplicationService.throwException = true;

        try {
            List<Grant_Option__mdt> result = GrantApplicationController.getAllGrantOptions();
            System.assert(false, 'Expected an AuraHandledException to be thrown');
        } catch (AuraHandledException ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }

        // Reset the flag
        GrantApplicationService.throwException = false;

        Test.stopTest();
    }
}