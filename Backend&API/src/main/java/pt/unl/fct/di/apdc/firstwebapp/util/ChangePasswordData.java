/**
 * The ChangePasswordData class is a utility class that represents the data needed to change a user's
 * password and provides a method to validate the data.
 */
package pt.unl.fct.di.apdc.firstwebapp.util;

import org.apache.commons.lang3.StringUtils;

public class ChangePasswordData {
    public String username;
    public String currentPwd;
    public String newPwd;
    public String confirmPwd;

    public ChangePasswordData() {
    }

    public ChangePasswordData(String username, String currentPwd, String newPwd, String confirmPwd) {
        this.username = username;
        this.currentPwd = currentPwd;
        this.newPwd = newPwd;
        this.confirmPwd = confirmPwd;
    }

    /**
     * The function checks if the username, current password, new password, and confirm password fields
     * are not empty and if the new password matches the confirm password.
     * 
     * @return The method is returning a string. If any of the conditions are met, it will return an
     * error message. If all conditions are met, it will return "OK".
     */
    public String validChangePassword() {
        if (StringUtils.isEmpty(this.username)) {
            return "Missing or empty username.";
        }
        if (StringUtils.isEmpty(this.currentPwd)) {
            return "Missing or empty current password.";
        }
        if (StringUtils.isEmpty(this.newPwd)) {
            return "Missing or empty new password.";
        }
        if (StringUtils.isEmpty(this.confirmPwd)) {
            return "Missing or empty confirm password.";
        }
        if (!this.newPwd.equals(confirmPwd)) {
            return "New password and confirm password do not match.";
        }
        return "OK";
    }
}
