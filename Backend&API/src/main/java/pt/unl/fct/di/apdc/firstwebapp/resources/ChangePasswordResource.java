package pt.unl.fct.di.apdc.firstwebapp.resources;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

import com.google.appengine.repackaged.org.apache.commons.codec.digest.DigestUtils;
import com.google.cloud.datastore.*;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.ChangePasswordData;

@Path("/changePwd")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class ChangePasswordResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink2023").build().getService();
    private final Gson g = new Gson();
    private static final Logger LOG = Logger.getLogger(ChangePasswordResource.class.getName());

    public ChangePasswordResource() {
    }

    @PATCH
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response changePassword(ChangePasswordData data, @Context HttpHeaders headers) {
        LOG.fine("Attempt to change password for user: " + data.username);

        String validationResult = data.validChangePassword();
        if (!validationResult.equals("OK"))
            return Response.status(Status.BAD_REQUEST).entity(validationResult).build();

        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        Key userKey = datastore.newKeyFactory().setKind("User").newKey(data.username);
        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);
        Transaction txn = datastore.newTransaction();
        try {
            Entity user = txn.get(userKey);
            Entity originalToken = txn.get(tokenKey);

            if (user == null) {
                txn.rollback();
                return Response.status(Status.BAD_REQUEST).entity("User not found.").build();
            }

            if(originalToken == null) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in").build();
            }
            String storedPassword = user.getString("user_pwd");
            String providedPassword = DigestUtils.sha512Hex(data.currentPwd);

            if (!storedPassword.equals(providedPassword)) {
                txn.rollback();
                return Response.status(Status.UNAUTHORIZED).entity("Incorrect current password.").build();
            }

            if (!token.tokenID.equals(originalToken.getString("tokenID"))|| System.currentTimeMillis() > originalToken.getLong("user_token_expiration_data")) {
                txn.rollback();
                return Response.status(Status.UNAUTHORIZED).entity("Session expired.").build();
            }
            AuthToken newToken = new AuthToken(data.username);
            Entity user_token = Entity.newBuilder(tokenKey)
                    .set("tokenID", newToken.tokenID)
                    .set("user_token_creation_data", newToken.creationDate)
                    .set("user_token_expiration_data", newToken.expirationDate)
                    .build();

            Map<String, Object> tokenData = new HashMap<>();
            tokenData.put("tokenID", newToken.tokenID);
            tokenData.put("username", newToken.username);

            Entity updatedUser = Entity.newBuilder(user)
                    .set("user_pwd", DigestUtils.sha512Hex(data.newPwd))
                    .build();

            txn.put(updatedUser, user_token);
            txn.commit();
            return Response.ok("{}").header("Authorization", "Bearer " + g.toJson(tokenData)).build();

        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }
}
