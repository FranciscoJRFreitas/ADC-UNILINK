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

    public ModifyAttributesData() {
    }

    public ModifyAttributesData(String username, String password) {
        this.username = username;
        this.password = password;
    }

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
