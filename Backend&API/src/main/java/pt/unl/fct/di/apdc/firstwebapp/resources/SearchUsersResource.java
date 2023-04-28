package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.datastore.StructuredQuery.PropertyFilter;
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

@Path("/search")
public class SearchUsersResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("ai-60313").build().getService();
    private static final Logger LOG = Logger.getLogger(SearchUsersResource.class.getName());

    public SearchUsersResource() {
    }

    @POST
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Response searchUsers(SearchUsersData data) {
        LOG.info("Searching: " + data.searchQuery + " " + data.username);

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

            List<Query<Entity>> queries = getQueriesForUserRole(userRole, data.searchQuery);
            List<Object> users = new ArrayList<>();
            for (Query<Entity> query : queries) {
                QueryResults<Entity> results = datastore.run(query);
                while (results.hasNext()) {
                    Entity userEntity = results.next();
                    users.add(entityToJsonObject(userEntity, userRole));
                }
            }
            return Response.ok(users).build();

        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    private List<Query<Entity>> getQueriesForUserRole(UserRole userRole, String searchQuery) {
        List<Query<Entity>> queries = new ArrayList<>();

        switch (userRole) {
            case GBO:
                queries.add(createQuery(UserRole.USER, searchQuery, "user_displayName"));
                queries.add(createQuery(UserRole.USER, searchQuery, "user_username"));
                break;
            case GA:
                queries.add(createQuery(UserRole.USER, searchQuery, "user_displayName"));
                queries.add(createQuery(UserRole.USER, searchQuery, "user_username"));
                queries.add(createQuery(UserRole.GBO, searchQuery, "user_displayName"));
                queries.add(createQuery(UserRole.GBO, searchQuery, "user_username"));
                break;
            case GS:
                queries.add(createQuery(UserRole.USER, searchQuery, "user_displayName"));
                queries.add(createQuery(UserRole.USER, searchQuery, "user_username"));
                queries.add(createQuery(UserRole.GA, searchQuery, "user_displayName"));
                queries.add(createQuery(UserRole.GA, searchQuery, "user_username"));
                queries.add(createQuery(UserRole.GBO, searchQuery, "user_displayName"));
                queries.add(createQuery(UserRole.GBO, searchQuery, "user_username"));
                break;
            case SU:
                queries.add(createQuery(null, searchQuery, "user_displayName"));
                queries.add(createQuery(null, searchQuery, "user_username"));
                break;
            case USER:
            default:
                queries.add(createQuery(UserRole.USER, searchQuery, "user_displayName", UserProfileVisibility.PUBLIC));
                queries.add(createQuery(UserRole.USER, searchQuery, "user_username", UserProfileVisibility.PUBLIC));
                break;
        }
        return queries;
    }

    private Query<Entity> createQuery(UserRole userRole, String searchQuery, String property) {
        return createQuery(userRole, searchQuery, property, null);
    }

    private Query<Entity> createQuery(UserRole userRole, String searchQuery, String property, UserProfileVisibility profileVisibility) {
        EntityQuery.Builder queryBuilder = Query.newEntityQueryBuilder().setKind("User");

        if (userRole != null) {
            return queryBuilder
                    .setFilter(StructuredQuery.CompositeFilter.and(
                            PropertyFilter.ge(property, searchQuery),
                            PropertyFilter.lt(property, searchQuery + "\ufffd"),
                            PropertyFilter.eq("user_role", userRole.toString())))
                    .build();
        }
        if (profileVisibility != null) {
            return queryBuilder
                    .setFilter(StructuredQuery.CompositeFilter.and(
                            PropertyFilter.ge(property, searchQuery),
                            PropertyFilter.lt(property, searchQuery + "\ufffd"),
                            PropertyFilter.eq("user_profileVisibility", profileVisibility.toString())))
                    .build();
        }

        return queryBuilder
                .setFilter(StructuredQuery.CompositeFilter.and(
                        PropertyFilter.ge(property, searchQuery),
                        PropertyFilter.lt(property, searchQuery + "\ufffd")))
                .build();
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
