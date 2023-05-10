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
