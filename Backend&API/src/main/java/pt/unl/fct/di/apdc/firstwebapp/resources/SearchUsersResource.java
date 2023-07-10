package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.datastore.StructuredQuery.PropertyFilter;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.*;
import org.apache.commons.lang3.StringUtils;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;
import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

import static pt.unl.fct.di.apdc.firstwebapp.util.LevenshteinDistance.levenshteinDistance;

@Path("/search")
public class SearchUsersResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink23").build().getService();
    private static final Logger LOG = Logger.getLogger(SearchUsersResource.class.getName());
    private static final int MAX_DISTANCE = 2; //Levenshtein algorithm distance
    private static final int MAX_RESULTS_DISPLAYED = 10;
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

            if (originalToken == null) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in").build();
            }

            if (!token.tokenID.equals(originalToken.getString("user_tokenID")) || System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("Session Expired.").build();
            }

            UserRole userRole = UserRole.valueOf(user.getString("user_role"));

            List<Object> users = getEntitiesForUserRole(userRole, data.searchQuery);

            return Response.ok(users).build();

        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    private List<Object> getEntitiesForUserRole(UserRole userRole, String searchQuery) {
        List<Query<Entity>> queries = new ArrayList<>();

        switch (userRole) {
            case PROF:
                queries.add(buildQuery(UserRole.STUDENT, null));
                queries.add(buildQuery(UserRole.PROF, null));
                break;
            case DIRECTOR:
                queries.add(buildQuery(UserRole.DIRECTOR, null));
                queries.add(buildQuery(UserRole.PROF, null));
                queries.add(buildQuery(UserRole.STUDENT, null));
                break;
            case BACKOFFICE:
                queries.add(buildQuery(null, null));
                break;
            case SU:
                queries.add(buildQuery(null, null));
                break;
            case STUDENT:
            default:
                queries.add(buildQuery(UserRole.STUDENT, UserProfileVisibility.PUBLIC));
                break;
        }

        List<Entity> results = new ArrayList<>();
        for (Query<Entity> query : queries) {
            results.addAll(fuzzySearch(query, searchQuery));
        }

        List<Object> users = new ArrayList<>();
        for (Entity entity : results) {
            users.add(entityToJsonObject(entity, userRole));
        }

        return users;
    }

    private Query<Entity> buildQuery(UserRole userRole, UserProfileVisibility profileVisibility) {
        EntityQuery.Builder queryBuilder = Query.newEntityQueryBuilder().setKind("User");
        List<StructuredQuery.Filter> filters = new ArrayList<>();

        if (userRole != null) {
            filters.add(PropertyFilter.eq("user_role", userRole.toString()));
        }
        if (profileVisibility != null) {
            filters.add(PropertyFilter.eq("user_profileVisibility", profileVisibility.toString()));
        }

        if (!filters.isEmpty())
            for (StructuredQuery.Filter filter : filters)
                queryBuilder.setFilter(StructuredQuery.CompositeFilter.and(filter));

        return queryBuilder.build();
    }

    private List<Entity> fuzzySearch(Query<Entity> query, String searchQuery) {
        String[] propertiesToSearch = new String[]{"user_username", "user_displayName"};
        QueryResults<Entity> results = datastore.run(query);
        List<Entity> filteredResults = new ArrayList<>();
        int counter = 0;

        while (results.hasNext() && counter < MAX_RESULTS_DISPLAYED) {
            Entity result = results.next();

            if (Arrays.stream(propertiesToSearch)
                    .anyMatch(property -> {
                        String propertyValue = result.getString(property);
                        return (searchQuery != null && !searchQuery.trim().isEmpty()) &&
                                (levenshteinDistance(searchQuery.trim().toLowerCase(), propertyValue.trim().toLowerCase()) <= MAX_DISTANCE
                                        || searchQuery.trim().toLowerCase().contains(propertyValue.trim().toLowerCase())
                                        || propertyValue.trim().toLowerCase().contains(searchQuery.trim().toLowerCase()));
                    })) {
                filteredResults.add(result);
                counter++;
            }
        }

        return filteredResults;
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
