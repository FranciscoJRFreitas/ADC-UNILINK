/**
 * The SearchUsersResource class is a Java resource class that handles searching for users based on a
 * search query and user role.
 */
package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.datastore.StructuredQuery.PropertyFilter;
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
import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

import static pt.unl.fct.di.apdc.firstwebapp.util.LevenshteinDistance.levenshteinDistance;
import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.datastoreService;
import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.g;

@Path("/search")
public class SearchUsersResource {

    private static final Logger LOG = Logger.getLogger(SearchUsersResource.class.getName());
    private static final int MAX_DISTANCE = 2; //Levenshtein algorithm distance
    private static final int MAX_RESULTS_DISPLAYED = 10;

    /**
     * This Java function handles a POST request to search for users based on a search query and the
     * user's role.
     * 
     * @param data The `data` parameter is an object of type `SearchUsersData`. It contains the search
     * query and the username for searching users.
     * @param headers The `headers` parameter is of type `HttpHeaders` and is used to access the HTTP
     * headers of the incoming request. It is annotated with `@Context` to indicate that it should be
     * injected by the JAX-RS runtime.
     * @return The method is returning a Response object with the list of users as the entity body. The
     * response is built using the Response.ok() method, which sets the HTTP status code to 200 (OK)
     * and includes the list of users as the response entity.
     */
    @POST
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Response searchUsers(SearchUsersData data, @Context HttpHeaders headers) {
        LOG.info("Searching: " + data.searchQuery + " " + data.username);
        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        Key userKey = datastoreService.newKeyFactory().setKind("User").newKey(token.username);
        Transaction txn = datastoreService.newTransaction();
        try {
            Entity user = txn.get(userKey);
            String userRoleString = user.getString("user_role");

            UserRole userRole = UserRole.valueOf(userRoleString);

            List<Object> users = getEntitiesForUserRole(userRole, data.searchQuery);
            return Response.ok(users).build();
        } finally {
            if (txn.isActive()) txn.rollback();
        }

    }

    /**
     * The function `getEntitiesForUserRole` returns a list of entities based on the user's role and a
     * search query.
     * 
     * @param userRole The userRole parameter is an enum representing the role of the user. It can have
     * the following values:
     * @param searchQuery The search query is a string that is used to search for entities. It is used
     * to filter the results based on a specific criteria.
     * @return The method is returning a List of Objects.
     */
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

    /**
     * This function builds a query to retrieve entities of kind "User" based on the provided user role
     * and profile visibility filters.
     * 
     * @param userRole The userRole parameter is an enum representing the role of a user. It can have
     * values such as ADMIN, MANAGER, or USER.
     * @param profileVisibility The `profileVisibility` parameter is of type `UserProfileVisibility`
     * and represents the visibility setting of a user's profile. It can have values such as `PUBLIC`,
     * `PRIVATE`, or `FRIENDS_ONLY`, indicating who can view the user's profile information.
     * @return The method is returning a Query object with the specified filters applied.
     */
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

    /**
     * The function performs a fuzzy search on a given query and search query, filtering the results
     * based on a maximum distance and properties to search.
     * 
     * @param query A query object that specifies the criteria for retrieving entities from the
     * datastore.
     * @param searchQuery The search query is a string that represents the user's input for the search.
     * It is used to find matching entities based on the properties specified in the
     * "propertiesToSearch" array.
     * @return The method is returning a List of Entity objects that match the fuzzy search criteria.
     */
    private List<Entity> fuzzySearch(Query<Entity> query, String searchQuery) {
        String[] propertiesToSearch = new String[]{"user_username", "user_displayName"};
        QueryResults<Entity> results = datastoreService.run(query);
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

    /**
     * The function converts an Entity object into a JsonObject, filtering out certain properties based
     * on the logged user's role.
     * 
     * @param userEntity An instance of the Entity class, representing a user entity.
     * @param loggedUserRole The loggedUserRole parameter is of type UserRole and represents the role
     * of the logged-in user.
     * @return The method returns a JsonObject.
     */
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
