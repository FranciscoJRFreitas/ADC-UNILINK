/**
 * The RemoveData class is a utility class that holds information about a user's username, password,
 * and the target username to be removed.
 */
package pt.unl.fct.di.apdc.firstwebapp.util;

public class RemoveData {

    public String username;
    public String password;
    public String targetUsername;

    public RemoveData() {}

    public RemoveData(String username, String password, String targetUsername) {
        this.username = username;
        this.password = password;
        this.targetUsername = targetUsername;
    }

}
