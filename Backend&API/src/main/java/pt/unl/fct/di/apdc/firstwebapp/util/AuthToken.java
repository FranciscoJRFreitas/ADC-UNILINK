package pt.unl.fct.di.apdc.firstwebapp.util;

import java.util.UUID;

public class AuthToken {

    public static final long EXPIRATION_TIME = 1000*60*60*2; //2h

    public String username;
    public String tokenID;
    public long creationDate;
    public long expirationDate;

    public AuthToken() {}

    public AuthToken(String username) {
        this.username = username;
        this.tokenID = UUID.randomUUID().toString();
        this.creationDate = System.currentTimeMillis();
        this.expirationDate = this.creationDate + AuthToken.EXPIRATION_TIME;
    }

}
