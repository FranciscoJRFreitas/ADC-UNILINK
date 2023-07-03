package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
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

        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);

        Transaction txn = datastore.newTransaction();
        try {
            Entity originalToken = txn.get(tokenKey);

            if (originalToken == null) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in").build();
            }

//            if (!token.tokenID.equals(originalToken.getString("user_tokenID")) || System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")) {
//                return Response.status(Response.Status.UNAUTHORIZED).entity("Session Expired.").build();
//            }
            DatabaseReference eventsRef = FirebaseDatabase.getInstance().getReference("events");
            DatabaseReference newEventRef = eventsRef.child(data.groupID).push(); // Generate a unique ID for the new chat

            // Set the data for the new chat
            newEventRef.child("creator").setValueAsync(data.creator);
            newEventRef.child("type").setValueAsync(data.type);
            newEventRef.child("title").setValueAsync(data.title);
            newEventRef.child("description").setValueAsync(data.description);
            newEventRef.child("startTime").setValueAsync(data.startTime);
            newEventRef.child("endTime").setValueAsync(data.endTime);
            newEventRef.child("location").setValueAsync(data.location);

            Map<String, Object> responseData = new HashMap<>();
            responseData.put("event_title", data.title);
            responseData.put("event_type", data.type);
            responseData.put("event_groupID", data.groupID);
            responseData.put("event_creator", data.creator);
            responseData.put("event_description", data.description);
            responseData.put("event_start_time", data.startTime);
            responseData.put("event_end_time", data.endTime);
            responseData.put("event_location", data.location);


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
    public Response removeEvent(@QueryParam("eventID") String eventID,@QueryParam("groupID") String groupID, @Context HttpHeaders headers) {

        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);
        Transaction txn = datastore.newTransaction();
        try {
            Entity originalToken = txn.get(tokenKey);

            if (originalToken == null) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in").build();
            }
//            if (!token.tokenID.equals(originalToken.getString("user_tokenID")) || System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")) {
//                txn.rollback();
//                return Response.status(Response.Status.UNAUTHORIZED).entity("Session Expired.").build();
//            }
            DatabaseReference eventsRef = FirebaseDatabase.getInstance().getReference("events").child(groupID);
            eventsRef.child(eventID).removeValueAsync();

            return Response.ok("{}").build();

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
