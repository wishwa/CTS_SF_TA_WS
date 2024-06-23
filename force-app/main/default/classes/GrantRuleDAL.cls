/**
 * @description       : DAL class for the Grant rules
 * @author            : Wishwa Sigera
 * @group             : 
 * @last modified on  : 06-23-2024
 * @last modified by  : Wishwa Sigera
**/
public with sharing class GrantRuleDAL {
    /**
    * @description This method will help to get the grant rule by developer name.
    * @author Wishwa Sigera | 06-22-2024 
    * @param name Developer name of the grant rule
    * @return Grant_Rule__mdt 
    **/
    public static Grant_Rule__mdt getGrantRuleByDeveloperName(String name){
        Grant_Rule__mdt grantRule = Grant_Rule__mdt.getInstance(name);
        return grantRule;
    }
}