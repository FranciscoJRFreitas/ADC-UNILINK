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
import java.util.List;

import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.datastoreService;
import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.g;

@Path("/list")
public class ListUsersResource {
    public ListUsersResource() {
    }

    @GET
    @Path("/")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Response listUsers(@Context HttpHeaders headers) {
        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);
        Key userKey = datastoreService.newKeyFactory().setKind("User").newKey(token.username);
        Transaction txn = datastoreService.newTransaction();

        try{
            Entity user = txn.get(userKey);
            UserRole userRole = UserRole.valueOf(user.getString("user_role"));

            Query<Entity> query = getQueryForUserRole(userRole);
            QueryResults<Entity> results = datastoreService.run(query);

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
            case DIRECTOR:
                query = Query.newEntityQueryBuilder()
                        .setKind("User")
                        .setFilter(StructuredQuery.CompositeFilter.and(
                                PropertyFilter.eq("user_role", UserRole.STUDENT.toString()),
                                PropertyFilter.eq("user_role", UserRole.PROF.toString()),
                                PropertyFilter.eq("user_role", UserRole.DIRECTOR.toString())
                        ))
                        .build();
                break;
            case PROF:
                query = Query.newEntityQueryBuilder()
                        .setKind("User")
                        .setFilter(StructuredQuery.CompositeFilter.and(
                                                PropertyFilter.eq("user_role", UserRole.STUDENT.toString()),
                                                PropertyFilter.eq("user_role", UserRole.PROF.toString())))
                        .build();
                break;
            case BACKOFFICE:
            case SU:
                query = Query.newEntityQueryBuilder()
                        .setKind("User")
                        .build();
                break;
            case STUDENT:
            default:
                query = Query.newEntityQueryBuilder()
                        .setKind("User")
                        .setFilter(StructuredQuery.CompositeFilter.and(
                                PropertyFilter.eq("user_role", UserRole.STUDENT.toString()),
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
            if (!loggedUserRole.equals(UserRole.STUDENT) || property.equals("user_username") || property.equals("user_email") || property.equals("user_displayName")) {
                Value<?> value = userEntity.getValue(property);
                builder.add(property, value.get().toString());
            }
        }
        return builder.build();
    }
}


