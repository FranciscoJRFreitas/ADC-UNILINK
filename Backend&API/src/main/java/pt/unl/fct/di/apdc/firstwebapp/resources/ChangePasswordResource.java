/**
 * The ChangePasswordResource class is a Java resource class that handles requests to change a user's
 * password.
 */
package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.appengine.repackaged.org.apache.commons.codec.digest.DigestUtils;
import com.google.cloud.datastore.Entity;
import com.google.cloud.datastore.Key;
import com.google.cloud.datastore.PathElement;
import com.google.cloud.datastore.Transaction;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
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

import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.datastoreService;
import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.g;

@Path("/changePwd")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class ChangePasswordResource {
    private static final Logger LOG = Logger.getLogger(ChangePasswordResource.class.getName());

    public ChangePasswordResource() {
    }

    /**
     * The above function is a PATCH endpoint in a Java web service that allows users to change their
     * password, with validation and authentication checks.
     * 
     * @param data ChangePasswordData object that contains the username, currentPwd, and newPwd fields.
     * @param headers The `headers` parameter is of type `HttpHeaders` and is used to access the HTTP
     * headers of the incoming request. It is annotated with `@Context` to indicate that it should be
     * injected by the JAX-RS runtime.
     * @return The method is returning a Response object. The response can have different status codes
     * and entities depending on the conditions in the code. Here are the possible return scenarios:
     */
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

        Key userKey = datastoreService.newKeyFactory().setKind("User").newKey(data.username);
        Key tokenKey = datastoreService.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);
        Transaction txn = datastoreService.newTransaction();
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
