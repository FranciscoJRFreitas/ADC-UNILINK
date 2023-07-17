/**
 * The LogoutResource class is a Java resource that handles the logout functionality for a web
 * application, using Google Cloud Datastore for data storage.
 */
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

    /**
     * The above function is a Java method that handles a POST request to log out a user by deleting
     * their authentication token from the datastore.
     * 
     * @param headers The `headers` parameter is of type `HttpHeaders` and is used to retrieve the
     * headers of the HTTP request.
     * @return The method is returning a Response object. If the logout is successful, it returns a
     * Response with status code 200 (OK) and the message "Logout successful." If the user is not
     * logged in, it returns a Response with status code 401 (UNAUTHORIZED) and the message "User not
     * logged in."
     */
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
