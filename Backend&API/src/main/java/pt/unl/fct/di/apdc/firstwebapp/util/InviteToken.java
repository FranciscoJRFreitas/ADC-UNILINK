/**
 * The InviteToken class is used to generate and store invitation tokens for a specific user and group.
 */
package pt.unl.fct.di.apdc.firstwebapp.util;

import java.util.UUID;

public class InviteToken {
    public static final long EXPIRATION_TIME = 1000*60*60*2; //2h

    public String username;
    public String groupId;
    public String tokenID;
    public long creationDate;
    public long expirationDate;

    public InviteToken() {}

    public InviteToken(String username, String groupId) {
        this.username = username;
        this.groupId = groupId;
        this.tokenID = UUID.randomUUID().toString();
        this.creationDate = System.currentTimeMillis();
        this.expirationDate = this.creationDate + AuthToken.EXPIRATION_TIME;
    }
}
