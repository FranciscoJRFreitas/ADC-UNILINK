package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.datastore.StructuredQuery.PropertyFilter;
import pt.unl.fct.di.apdc.firstwebapp.util.RemoveData;
import pt.unl.fct.di.apdc.firstwebapp.util.UserRole;
import org.apache.commons.codec.digest.DigestUtils;

import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;

@Path("/remove")
public class RemoveResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("ai-60313").build().getService();
    private static final Logger LOG = Logger.getLogger(RegisterResource.class.getName());

    public RemoveResource() {
    }

    @POST
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response deleteUser(RemoveData data) {

        Transaction txn = datastore.newTransaction();
        try {

            Key userKey = datastore.newKeyFactory().setKind("User").newKey(data.username);
            Entity user = txn.get(userKey);

            if (user == null) {
                txn.rollback();
                return Response.status(Response.Status.BAD_REQUEST).entity("User not found: " + data.username).build();
            }

            String storedPassword = user.getString("user_pwd");
            String providedPassword = DigestUtils.sha512Hex(data.password);

            if (!storedPassword.equals(providedPassword))
                return Response.status(Response.Status.UNAUTHORIZED).entity("Incorrect password for user: " + data.username).build();

            String storedToken = user.getString("user_token");
            long storedTokenExpiration = user.getLong("user_token_expiration");
            if (!storedToken.equals(data.token) || System.currentTimeMillis() > storedTokenExpiration) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("Session Expired.").build();
            }

            if (!data.targetUsername.isEmpty()) {

                Key targetUserKey = datastore.newKeyFactory().setKind("User").newKey(data.targetUsername);
                Entity targetUser = txn.get(targetUserKey);

                if (targetUser == null) {
                    txn.rollback();
                    return Response.status(Response.Status.BAD_REQUEST).entity("Target user not found: " + data.targetUsername).build();
                }

                String userRole = user.getString("user_role");
                String targetUserRole = targetUser.getString("user_role");
                if (!canDelete(userRole, targetUserRole, data))
                    return Response.status(Response.Status.UNAUTHORIZED).entity("You do not have the required permissions for this action.").build();

                txn.delete(targetUserKey);
                txn.commit();
                LOG.info("User deleted: " + data.targetUsername);
                return Response.ok("{}").build();
            }

            txn.delete(userKey);
            txn.commit();
            LOG.info("User deleted: " + (data.targetUsername == null ? data.username : data.targetUsername));
            return Response.ok("{}").build();

        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    private boolean canDelete(String userRole, String targetUserRole, RemoveData data) {
        switch (UserRole.valueOf(userRole)) {
            case USER:
                return data.username.equals(data.targetUsername);
            case GBO:
                return targetUserRole.equals(UserRole.USER.toString()) || data.username.equals(data.targetUsername);
            case GA:
                return targetUserRole.equals(UserRole.USER.toString()) || targetUserRole.equals(UserRole.GBO.toString()) || data.username.equals(data.targetUsername);
            case GS:
                return !targetUserRole.equals(UserRole.SU.toString()) || data.username.equals(data.targetUsername);
            case SU:
                return true;
            default:
                return false;
        }
    }

}

