package pt.unl.fct.di.apdc.firstwebapp.util;

import org.apache.commons.lang3.StringUtils;

public class RegisterData {

    public String displayName;
    public String username;
    public String email;
    public String password;
    public String confirmPwd;
    public String studentNumber;
    public UserRole role;
    public UserActivityState activityState;
    public UserEducationLevel educationLevel;
    public String birthDate;
    public UserProfileVisibility profileVisibility;
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

    public RegisterData() {
    }

    public RegisterData(String displayName, String username, String email, String password, String confirmPwd, String studentNumber) {
        this.displayName = displayName;
        this.username = username;
        this.email = email;
        this.password = password;
        this.confirmPwd = confirmPwd;
        this.role = UserRole.STUDENT;
        this.activityState = UserActivityState.INACTIVE;
        this.profileVisibility = UserProfileVisibility.PUBLIC;
        this.educationLevel = UserEducationLevel.PE;
        this.studentNumber = studentNumber;
    }

    /*
        StrinUtils checks if is or not empty or not null
            email matches:
            <string>@<string>. …. .<dom>
            password matches:
            ^ - Start of the line
            (?=.*[0-9]) - At least one digit
            (?=.*[a-z]) - At least one lowercase letter
            (?=.*[A-Z]) - At least one uppercase letter
            (?=.*[@#$%^&+=!]) - At least one special character
            (?=\S+$) - No whitespace allowed in the entire string
            .{8,} - At least 8 characters long
            $ - End of the line
         */
    public String validRegistration() {

        if (StringUtils.isAnyEmpty(this.displayName, this.username, this.password, this.confirmPwd, this.email)) {
            return "Missing parameters.";
        } else if (!this.confirmPwd.equals(this.password)) {
            return "Passwords do not match.";
        } else if (!this.email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,}$")) {
            return "Invalid email format.";
        } else if (!this.password.matches("^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=!])(?=\\S+$).{8,}$")) {
            return "Invalid password format.\n\n Password must have:\n At least one digit\n At least one lowercase letter\n At least one uppercase letter\n At least one special character\n No whitespaces\n Be at least 8 characters long";
        } else if (StringUtils.isNotEmpty(this.taxIdentificationNumber) && !this.taxIdentificationNumber.matches("^[0-9]{9}$")) {
            return "Invalid tax identification number format.";
        } else if (StringUtils.isNotEmpty(this.postalCode) && !this.postalCode.matches("^\\d{4}-\\d{3}$")) {
            return "Invalid postal code format.";
        } else if (this.username.matches(".*[.#$\\[\\]].*")) {
            return "Username must not contain the following symbols: '.', '#', '$', '[', or ']'.";
        } else {
            return "OK";
        }
    }

}