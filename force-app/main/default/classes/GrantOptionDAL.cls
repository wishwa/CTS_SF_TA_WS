/**
 * @description       : 
 * @author            : Wishwa Sigera
 * @group             : 
 * @last modified on  : 06-23-2024
 * @last modified by  : Wishwa Sigera
**/

public with sharing class GrantOptionDAL {
    /**
    * @description This method will help to get the grant option by developer name.
    * @author Wishwa Sigera | 06-22-2024 
    * @param name Developer name of the grant rule
    * @return Grant_Option__mdt 
    **/
    public static Grant_Option__mdt getGrantOptionByDeveloperName(String name){
        Grant_Option__mdt grantOption = Grant_Option__mdt.getInstance(name);
        return grantOption;
    }

    /**
    * @description This method will help to get all the grant options.
    * @author Wishwa Sigera | 06-22-2024 
    * @return List<Grant_Option__mdt> 
    **/
    public static List<Grant_Option__mdt> getAllOptions(){
        List<Grant_Option__mdt> grantOptions = Grant_Option__mdt.getAll().values();
        return grantOptions;
    }
}