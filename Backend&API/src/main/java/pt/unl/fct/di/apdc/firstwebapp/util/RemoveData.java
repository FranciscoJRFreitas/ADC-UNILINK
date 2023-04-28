package pt.unl.fct.di.apdc.firstwebapp.util;

public class RemoveData {

    public String username;
    public String password;
    public String targetUsername;
    public String token;

    public RemoveData() {}

    public RemoveData(String username, String password, String targetUsername, String token) {
        this.username = username;
        this.password = password;
        this.targetUsername = targetUsername;
        this.token = token;
    }

}
