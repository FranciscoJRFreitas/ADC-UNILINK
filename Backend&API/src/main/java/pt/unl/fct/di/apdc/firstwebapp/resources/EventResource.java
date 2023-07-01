package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
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
import java.util.*;
import java.util.logging.Logger;

@Path("/events")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class EventResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink23").build().getService();
    private static final Logger LOG = Logger.getLogger(EventResource.class.getName());
    private final Gson g = new Gson();

    public EventResource() {

    }

    @POST
    @Path("/add")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
    public Response addEvent(EventData data, @Context HttpHeaders headers) {

        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        String eventID = UUID.randomUUID().toString();

        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);
        Key eventKey = datastore.newKeyFactory().setKind("Event").newKey(eventID);
        Transaction txn = datastore.newTransaction();
        try {
            Entity event = txn.get(eventKey);
            Entity originalToken = txn.get(tokenKey);

            if (event != null) {
                txn.rollback();
                return Response.status(Response.Status.CONFLICT).entity("Event id already exists.").build();
            }

            if (originalToken == null) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in").build();
            }

            event = Entity.newBuilder(eventKey)
                    .set("event_creator", data.creator)
                    .set("event_title", data.title)
                    .set("event_description", data.description)
                    .set("event_start_time", data.startTime)
                    .set("event_end_time", data.endTime)
                    .build();

            Map<String, Object> responseData = new HashMap<>();
            responseData.put("event_title", data.title);
            responseData.put("event_creator", data.creator);
            responseData.put("event_description", data.description);
            responseData.put("event_start_time", data.startTime);
            responseData.put("event_end_time", data.endTime);

            txn.add(event);
            txn.commit();

            return Response.ok(g.toJson(responseData)).build();

        } catch (Exception e) {
            txn.rollback();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    @DELETE
    @Path("/delete")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
    public Response removeEvent(@QueryParam("eventID") String eventID, @Context HttpHeaders headers) {

        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);
        Key eventKey = datastore.newKeyFactory().setKind("Event").newKey(eventID);
        Transaction txn = datastore.newTransaction();
        try {
            Entity originalToken = txn.get(tokenKey);

            if (originalToken == null) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in").build();
            }
            if (!token.tokenID.equals(originalToken.getString("user_tokenID")) || System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("Session Expired.").build();
            }

            txn.delete(eventKey);
            txn.commit();

            return Response.ok().build();

        } catch (Exception e) {
            txn.rollback();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    @GET
    @Path("/get")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    public Response getEvents(@Context HttpHeaders headers) {

        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);


        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);
        Transaction txn = datastore.newTransaction();

        try{
            Entity originalToken = txn.get(tokenKey);

            if(originalToken == null) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in").build();
            }

            if (!token.tokenID.equals(originalToken.getString("user_tokenID"))|| System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("Session Expired.").build();
            }


            Query<Entity> query = Query.newEntityQueryBuilder()
                    .setKind("Event")
                    .setFilter(
                            StructuredQuery.PropertyFilter.eq("event_creator", token.username)
                            ).build();
            QueryResults<Entity> results = datastore.run(query);

            List<Object> loginDates = new ArrayList<>();
            while (results.hasNext()) {
                Entity userEntity = results.next();
                loginDates.add(entityToJsonObject(userEntity));
            }


            return Response.ok(loginDates).build();


        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    private JsonObject entityToJsonObject(Entity userEntity) {
        JsonObjectBuilder builder = Json.createObjectBuilder();

        for (String property : userEntity.getNames()) {

            Value<?> value = userEntity.getValue(property);
            builder.add(property, value.get().toString());
        }
        return builder.build();
    }
}
