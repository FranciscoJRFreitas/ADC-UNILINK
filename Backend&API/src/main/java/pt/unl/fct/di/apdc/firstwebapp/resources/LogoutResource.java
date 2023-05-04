package pt.unl.fct.di.apdc.firstwebapp.resources;

import java.util.logging.Logger;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import com.google.cloud.datastore.*;

import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;

@Path("/logout")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class LogoutResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink2023").build().getService();
    private final Gson g = new Gson();
    private static final Logger LOG = Logger.getLogger(LogoutResource.class.getName());

    public LogoutResource() {
    }

    @POST
    @Path("/")
    public Response logout(@Context HttpHeaders headers) {

        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        LOG.fine("Attempt to logout user: " + token.getUsername());

        Key userKey = datastore.newKeyFactory().setKind("User").newKey(token.getUsername());
        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", token.getUsername()))
                .setKind("User Token").newKey(token.username);
        Transaction txn = datastore.newTransaction();
        try {
            Entity user = txn.get(userKey);
            Entity originalToken = txn.get(tokenKey);

            if(user == null || !token.tokenID.equals(originalToken.getString(""))) {
                txn.rollback();
                return Response.status(Status.FORBIDDEN).build();
            }

            if(originalToken.getLong("user_token_expiration_data") < System.currentTimeMillis()) {
                txn.rollback();
                return Response.status(Status.METHOD_NOT_ALLOWED).build();
            }
            // Remove token
            txn.delete(tokenKey);
            txn.commit();
            return Response.ok("Logout successful.").build();

        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }
}
