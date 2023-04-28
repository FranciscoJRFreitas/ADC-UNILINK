package pt.unl.fct.di.apdc.firstwebapp.resources;

import java.util.logging.Logger;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import com.google.cloud.datastore.*;

import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.UserActivityState;

@Path("/logout")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class LogoutResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("ai-60313").build().getService();
    private static final Logger LOG = Logger.getLogger(LogoutResource.class.getName());

    public LogoutResource() {
    }

    @POST
    @Path("/")
    public Response logout(AuthToken token) {
        LOG.fine("Attempt to logout user: " + token.getUsername());

        Transaction txn = datastore.newTransaction();
        try {
            Key userKey = datastore.newKeyFactory().setKind("User").newKey(token.getUsername());
            Entity user = txn.get(userKey);

            if (user == null) {
                txn.rollback();
                return Response.status(Status.BAD_REQUEST).entity("User not found.").build();
            }

            // Remove token
            Entity updatedUser = Entity.newBuilder(user)
                    .remove("user_token")
                    .remove("user_token_expiration")
                    .set("user_state", UserActivityState.INACTIVE.toString())
                    .build();

            txn.put(updatedUser);
            txn.commit();
            return Response.ok("Logout successful.").build();

        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }
}
