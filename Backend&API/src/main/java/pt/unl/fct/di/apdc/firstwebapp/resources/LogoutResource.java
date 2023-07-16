package pt.unl.fct.di.apdc.firstwebapp.resources;

import java.util.logging.Logger;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import com.google.cloud.datastore.*;

import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;

import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.datastoreService;
import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.g;

@Path("/logout")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class LogoutResource {
    private static final Logger LOG = Logger.getLogger(LogoutResource.class.getName());

    public LogoutResource() {
    }

    @POST
    @Path("/")
    public Response logout(@Context HttpHeaders headers) {

        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        LOG.fine("Attempt to logout user: " + token.username);

        Key tokenKey = datastoreService.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);

        Transaction txn = datastoreService.newTransaction();
        try {
            Entity originalToken = txn.get(tokenKey);

            if (originalToken == null) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in.").build();
            }

            long activeLogins = originalToken.getLong("user_active_logins");

            if (activeLogins < 2L)
                txn.delete(tokenKey);
            else {
                Entity updatedToken = Entity.newBuilder(originalToken).set("user_active_logins", activeLogins - 1L).build();
                txn.put(updatedToken);
            }

            txn.commit();
            return Response.ok("Logout successful.").build();

        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

}
