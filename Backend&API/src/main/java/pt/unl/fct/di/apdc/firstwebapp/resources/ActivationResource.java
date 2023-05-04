package pt.unl.fct.di.apdc.firstwebapp.resources;

import java.util.logging.Logger;
import javax.ws.rs.*;

import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

import com.google.cloud.datastore.*;
import pt.unl.fct.di.apdc.firstwebapp.util.UserActivityState;


@Path("/activate")
public class ActivationResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink2023").build().getService();
    private static final Logger LOG = Logger.getLogger(ActivationResource.class.getName());

    @GET
    @Path("/")
    public Response activateAccount(@QueryParam("token") String token) {
        KeyFactory keyFactory = datastore.newKeyFactory().setKind("User");
        Query<Entity> query = Query.newEntityQueryBuilder()
                .setKind("User")
                .setFilter(StructuredQuery.PropertyFilter.eq("user_activation_token", token))
                .build();

        QueryResults<Entity> results = datastore.run(query);
        if (results.hasNext()) {
            Entity user = results.next();
            Key userKey = keyFactory.newKey(user.getString("user_username"));
            Entity newUser = Entity.newBuilder(user)
                    .set("user_state", UserActivityState.ACTIVE.toString())
                    .set("user_activation_token", "")
                    .build();

            Transaction txn = datastore.newTransaction();
            try {
                txn.update(newUser);
                txn.commit();
            } finally {
                if (txn.isActive()) txn.rollback();
            }
            return Response.ok("Account activated successfully!").build();
        } else {
            return Response.status(Status.NOT_FOUND).entity("Activation token not found or already used.").build();
        }
    }
}

