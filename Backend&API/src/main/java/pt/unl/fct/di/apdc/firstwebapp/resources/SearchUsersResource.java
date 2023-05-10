package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.datastore.StructuredQuery.PropertyFilter;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.*;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;
import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Path("/search")
public class SearchUsersResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink23").build().getService();
    private static final Logger LOG = Logger.getLogger(SearchUsersResource.class.getName());
    private final Gson g = new Gson();

    public SearchUsersResource() {
    }

    @POST
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Response searchUsers(SearchUsersData data, @Context HttpHeaders headers) {
        LOG.info("Searching: " + data.searchQuery + " " + data.username);

        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        Key userKey = datastore.newKeyFactory().setKind("User").newKey(data.username);
        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);
        Transaction txn = datastore.newTransaction();
        try {
            Entity user = txn.get(userKey);
            Entity originalToken = txn.get(tokenKey);

            if (user == null) {
                txn.rollback();
                return Response.status(Response.Status.BAD_REQUEST).entity("User not found: " + data.username).build();
            }

            if(originalToken == null) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in").build();
            }

            if (!token.tokenID.equals(originalToken.getString("user_token_ID"))|| System.currentTimeMillis() > token.expirationDate) {
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
            case PROF:
                queries.add(createQuery(UserRole.STUDENT, searchQuery, "user_displayName"));
                queries.add(createQuery(UserRole.STUDENT, searchQuery, "user_username"));
                queries.add(createQuery(UserRole.PROF, searchQuery, "user_displayName"));
                queries.add(createQuery(UserRole.PROF, searchQuery, "user_username"));
                break;
            case DIRECTOR:
                queries.add(createQuery(UserRole.DIRECTOR, searchQuery, "user_displayName"));
                queries.add(createQuery(UserRole.DIRECTOR, searchQuery, "user_username"));
                queries.add(createQuery(UserRole.PROF, searchQuery, "user_displayName"));
                queries.add(createQuery(UserRole.PROF, searchQuery, "user_username"));
                queries.add(createQuery(UserRole.STUDENT, searchQuery, "user_displayName"));
                queries.add(createQuery(UserRole.STUDENT, searchQuery, "user_username"));
                break;
            case SU:
                queries.add(createQuery(null, searchQuery, "user_displayName"));
                queries.add(createQuery(null, searchQuery, "user_username"));
                break;
            case STUDENT:
            default:
                queries.add(createQuery(UserRole.STUDENT, searchQuery, "user_displayName", UserProfileVisibility.PUBLIC));
                queries.add(createQuery(UserRole.STUDENT, searchQuery, "user_username", UserProfileVisibility.PUBLIC));
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
            if (!loggedUserRole.equals(UserRole.STUDENT) || property.equals("user_username") || property.equals("user_email") || property.equals("user_displayName")) {
                Value<?> value = userEntity.getValue(property);
                builder.add(property, value.get().toString());
            }
        }
        return builder.build();
    }
}
