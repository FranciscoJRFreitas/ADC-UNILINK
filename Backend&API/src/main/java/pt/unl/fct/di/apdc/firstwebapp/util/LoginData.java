/**
 * The LoginData class is a utility class that represents the data required for a user login, including
 * the username and password.
 */
package pt.unl.fct.di.apdc.firstwebapp.util;

public class LoginData {

    public String username;
    public String password;

    public LoginData() {}
 
    public LoginData(String username, String password) {
        this.username = username;
        this.password = password;
    }

}
