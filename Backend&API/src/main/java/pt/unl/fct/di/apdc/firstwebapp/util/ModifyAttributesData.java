/**
 * The class ModifyAttributesData is a utility class in Java that represents data for modifying user
 * attributes and provides a method for validating the data.
 */
package pt.unl.fct.di.apdc.firstwebapp.util;

import org.apache.commons.lang3.StringUtils;

public class ModifyAttributesData {

    public String username;
    public String email;
    public String password;
    public String displayName;
    public String targetUsername;
    public String role;
    public String activityState;
    public String educationLevel;
    public String birthDate;
    public String profileVisibility;
    public String landlinePhone;
    public String mobilePhone;
    public String occupation;
    public String workplace;
    public String address;
    public String additionalAddress;
    public String locality;
    public String postalCode;
    public String taxIdentificationNumber;
    public String photo;
    public String course;
    public String studentNumber;


    public ModifyAttributesData() {
    }

    public ModifyAttributesData(String username, String password) {
        this.username = username;
        this.password = password;
    }

    /**
     * The function checks if the username and password parameters are not empty, and if the email
     * parameter is not empty and has a valid format.
     * 
     * @return The method is returning a string. The possible return values are "Missing parameters.",
     * "Invalid email format.", or "OK".
     */
    public String validModifyAttributes() {
        if (StringUtils.isAnyEmpty(this.username, this.password)) {
            return "Missing parameters.";
        } else if (StringUtils.isNotEmpty(this.email) && !this.email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,}$")) {
            return "Invalid email format.";
        } else {
            return "OK";
        }
    }
}
