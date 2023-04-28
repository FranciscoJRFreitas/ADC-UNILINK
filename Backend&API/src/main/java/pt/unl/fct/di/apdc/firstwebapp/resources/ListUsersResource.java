package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.datastore.StructuredQuery.PropertyFilter;
import com.google.appengine.repackaged.org.apache.commons.codec.digest.DigestUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.*;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Path("/list")
public class ListUsersResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("ai-60313").build().getService();
    private static final Logger LOG = Logger.getLogger(ListUsersResource.class.getName());

    public ListUsersResource() {
    }

    @POST
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Response listUsers(ListUsersData data) {

        Transaction txn = datastore.newTransaction();
        try {

            Key userKey = datastore.newKeyFactory().setKind("User").newKey(data.username);
            Entity user = txn.get(userKey);

            if (user == null) {
                txn.rollback();
                return Response.status(Response.Status.BAD_REQUEST).entity("User not found: " + data.username).build();
            }

            String storedToken = user.getString("user_token");
            long storedTokenExpiration = user.getLong("user_token_expiration");
            if (!storedToken.equals(data.token) || System.currentTimeMillis() > storedTokenExpiration) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("Session Expired.").build();
            }

            UserRole userRole = UserRole.valueOf(user.getString("user_role"));

            Query<Entity> query = getQueryForUserRole(userRole);
            QueryResults<Entity> results = datastore.run(query);

            List<Object> users = new ArrayList<>();
            while (results.hasNext()) {
                Entity userEntity = results.next();
                users.add(entityToJsonObject(userEntity, userRole));
            }
            return Response.ok(users).build();

        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    private Query<Entity> getQueryForUserRole(UserRole userRole) {
        Query<Entity> query;
        switch (userRole) {
            case GBO:
                query = Query.newEntityQueryBuilder()
                        .setKind("User")
                        .setFilter(PropertyFilter.eq("user_role", UserRole.USER.toString()))
                        .build();
                break;
            case GA:
                query = Query.newEntityQueryBuilder()
                        .setKind("User")
                        .setFilter(StructuredQuery.CompositeFilter.and(
                                PropertyFilter.eq("user_role", UserRole.USER.toString()),
                                PropertyFilter.eq("user_role", UserRole.GBO.toString())))
                        .build();
                break;
            case GS:
                query = Query.newEntityQueryBuilder()
                        .setKind("User")
                        .setFilter(StructuredQuery.CompositeFilter.and(
                                                PropertyFilter.eq("user_role", UserRole.USER.toString()),
                                                PropertyFilter.eq("user_role", UserRole.GA.toString()),
                                                PropertyFilter.eq("user_role", UserRole.GBO.toString())))
                        .build();
                break;
            case SU:
                query = Query.newEntityQueryBuilder()
                        .setKind("User")
                        .build();
                break;
            case USER:
            default:
                query = Query.newEntityQueryBuilder()
                        .setKind("User")
                        .setFilter(StructuredQuery.CompositeFilter.and(
                                PropertyFilter.eq("user_role", UserRole.USER.toString()),
                                PropertyFilter.eq("user_state", UserActivityState.ACTIVE.toString()),
                                PropertyFilter.eq("user_profileVisibility", UserProfileVisibility.PUBLIC.toString())))
                        .build();
                break;
        }
        return query;
    }

    private JsonObject entityToJsonObject(Entity userEntity, UserRole loggedUserRole) {
        JsonObjectBuilder builder = Json.createObjectBuilder();

        for (String property : userEntity.getNames()) {
            // Displaying the "user_username", "user_email", and "user_displayName" properties when the loggedUserRole is equal to UserRole.USER
            if (!loggedUserRole.equals(UserRole.USER) || property.equals("user_username") || property.equals("user_email") || property.equals("user_displayName")) {
                Value<?> value = userEntity.getValue(property);
                builder.add(property, value.get().toString());
            }
        }
        return builder.build();
    }
}


