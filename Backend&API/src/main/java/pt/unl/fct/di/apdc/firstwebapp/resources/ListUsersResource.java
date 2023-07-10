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

@Path("/list")
public class ListUsersResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink23").build().getService();
    private final Gson g = new Gson();
    private static final Logger LOG = Logger.getLogger(ListUsersResource.class.getName());

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

        Key userKey = datastore.newKeyFactory().setKind("User").newKey(token.username);
        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);

        Transaction txn = datastore.newTransaction();

        try{
            Entity user = txn.get(userKey);
            Entity originalToken = txn.get(tokenKey);

            if (user == null) {
                txn.rollback();
                return Response.status(Response.Status.BAD_REQUEST).entity("User not found: " + token.username).build();
            }

            if(originalToken == null) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in").build();
            }

            if (!token.tokenID.equals(originalToken.getString("user_tokenID"))|| System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")) {
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
                query = Query.newEntityQueryBuilder()
                        .setKind("User")
                        .build();
                break;
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


