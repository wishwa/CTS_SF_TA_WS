/**
 * @description       : Test Class for AuthorizationUtil
 * @author            : Wishwa Sigera
 * @group             : 
 * @last modified on  : 06-23-2024
 * @last modified by  : Wishwa Sigera
**/
@isTest 
private class AuthorizationUtilTest {
    private static final String RESTRICTED_PROFILE_NAME = 'Chatter Free User';
    private static final String RESTRICTED_USER_NAME = 'restricted@agencyx.sg.com';
    private static final SObjectType OBJECT_TYPE = Contact.SObjectType;

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

    private static void checkMothods(Boolean authorized) {
        Assert.areEqual(authorized, AuthorizationUtil.isAccessible(OBJECT_TYPE), 'User is authorised to access the object');
        Assert.areEqual(authorized, AuthorizationUtil.isCreateable(OBJECT_TYPE), 'User is authorised to create the object');
        Assert.areEqual(authorized, AuthorizationUtil.isUpdateable(OBJECT_TYPE), 'User is authorised to update the object');
        Assert.areEqual(authorized, AuthorizationUtil.isDeletable(OBJECT_TYPE), 'User is authorised to delete the object');
    }

    private static User getRestrictedUser() {
        return [SELECT Id FROM User WHERE Username = :RESTRICTED_USER_NAME LIMIT 1];
    }

    @IsTest
    static void testAuthorizedUser() {
        checkMothods(true);
    }

    @IsTest
    static void testRestrictedUser() {
        User restrictedUser = getRestrictedUser();
        System.runAs(restrictedUser) {
            checkMothods(false);
        }
    }
}