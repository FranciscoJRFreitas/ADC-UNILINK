package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.appengine.repackaged.org.apache.commons.codec.digest.DigestUtils;
import com.google.cloud.datastore.*;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.ChangePasswordData;

import javax.ws.rs.Consumes;
import javax.ws.rs.PATCH;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import java.util.logging.Logger;

@Path("/changePwd")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class ChangePasswordResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink23").build().getService();
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

            if (!token.tokenID.equals(originalToken.getString("user_tokenID"))|| System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")) {
                txn.rollback();
                return Response.status(Status.UNAUTHORIZED).entity("Session expired.").build();
            }

            Entity updatedUser = Entity.newBuilder(user)
                    .set("user_pwd", DigestUtils.sha512Hex(data.newPwd))
                    .build();

            txn.put(updatedUser);
            try {
                FirebaseAuth firebaseAuth = FirebaseAuth.getInstance();
                UserRecord userRecord = firebaseAuth.getUserByEmail(user.getString("user_email"));

                UserRecord.UpdateRequest request = new UserRecord.UpdateRequest(userRecord.getUid())
                        .setPassword(data.newPwd);

                UserRecord updtUser = firebaseAuth.updateUser(request);
                System.out.println("Password updated successfully for user: " + updtUser.getUid());
            } catch (FirebaseAuthException e) {
                System.err.println("Error updating password: " + e.getMessage());
            }
            txn.commit();
            return Response.ok("{}").build();

        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }
}
