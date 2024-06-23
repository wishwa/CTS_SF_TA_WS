/**
 * @description       : Utility Class for the Autorization.  
 * @author            : Wishwa Sigera
 * @group             : 
 * @last modified on  : 06-23-2024
 * @last modified by  : Wishwa Sigera
**/
public with sharing class AuthorizationUtil {
    /**
    * @description This method will help to check the accessibilty of the given Sobject type
    * @author Wishwa Sigera | 06-22-2024 
    * @param sobjectType 
    * @return Boolean 
    **/
    public static Boolean isAccessible(SObjectType sobjectType) {
        return (sobjectType != null) && sobjectType.getDescribe().isAccessible();
    }

    /**
    * @description This method will help to check the ability to create record of the given Sobject type
    * @author Wishwa Sigera | 06-22-2024 
    * @param sobjectType 
    * @return Boolean 
    **/
    public static Boolean isCreateable(SObjectType sobjectType) {
        return (sobjectType != null) && sobjectType.getDescribe().isCreateable();
    }

    /**
    * @description This method will help to check the ability to update record of the given Sobject type
    * @author Wishwa Sigera | 06-22-2024 
    * @param sobjectType 
    * @return Boolean 
    **/
    public static Boolean isUpdateable(SObjectType sobjectType) {
        return (sobjectType != null) && sobjectType.getDescribe().isUpdateable();
    }

    /**
    * @description This method will help to check the ability to delete record of the given Sobject type
    * @author Wishwa Sigera | 06-22-2024 
    * @param sobjectType 
    * @return Boolean 
    **/
    public static Boolean isDeletable(SObjectType sobjectType) {
        return (sobjectType != null) && sobjectType.getDescribe().isDeletable();
    }
}