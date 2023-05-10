package pt.unl.fct.di.apdc.firstwebapp.resources;


import com.google.cloud.datastore.*;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import com.google.appengine.repackaged.org.apache.commons.codec.digest.DigestUtils;

import pt.unl.fct.di.apdc.firstwebapp.util.VerifyAction;

import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;


@Path("/remove")
public class RemoveResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink23").build().getService();
    private final Gson g = new Gson();
    private static final Logger LOG = Logger.getLogger(RegisterResource.class.getName());

    public RemoveResource() {
    }

    @DELETE
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response deleteUser(@QueryParam("targetUsername") String targetUsername, @QueryParam("pwd") String password, @Context HttpHeaders headers) {

        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        Key userKey = datastore.newKeyFactory().setKind("User").newKey(token.username);
        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);

        Transaction txn = datastore.newTransaction();
        try {
            Entity user = txn.get(userKey);
            Entity originalToken = txn.get(tokenKey);

            if (user == null) {
                txn.rollback();
                return Response.status(Response.Status.BAD_REQUEST).entity("User not found: " + token.username).build();
            }

            if(originalToken == null) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("Login is required for this action!").build();
            }

            String storedPassword = user.getString("user_pwd");
            String providedPassword = DigestUtils.sha512Hex(password);

            if (!storedPassword.equals(providedPassword))
                return Response.status(Response.Status.UNAUTHORIZED).entity("Incorrect password! You need to verify your identity.").build();

            if (!token.tokenID.equals(originalToken.getString("user_tokenID")) && System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("Session Expired.").build();
            }

            if (!targetUsername.isEmpty()) {

                Key targetUserKey = datastore.newKeyFactory().setKind("User").newKey(targetUsername);
                Entity targetUser = txn.get(targetUserKey);

                if (targetUser == null) {
                    txn.rollback();
                    return Response.status(Response.Status.BAD_REQUEST).entity("Target user not found: " + targetUsername).build();
                }

                String userRole = user.getString("user_role");
                String targetUserRole = targetUser.getString("user_role");
                if (!canDelete(userRole, targetUserRole))
                    return Response.status(Response.Status.UNAUTHORIZED).entity("You do not have the required permissions for this action.").build();

                txn.delete(targetUserKey, tokenKey);
                txn.commit();
                LOG.info("User deleted: " + targetUsername);
                return Response.ok("{}").build();
            }

            txn.delete(userKey, tokenKey);
            txn.commit();
            LOG.info("User deleted: " + token.username);
            return Response.ok("{}").build();

        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    private boolean canDelete(String userRole, String targetUserRole) {
        return VerifyAction.canExecute(userRole, targetUserRole, "remove_permissions");
    }

}