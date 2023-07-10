package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.*;

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

        Entity originalToken = datastore.get(tokenKey);

        if (originalToken == null) {
            return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in").build();
        }

        if (!token.tokenID.equals(originalToken.getString("user_tokenID")) || System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")) {
            return Response.status(Response.Status.UNAUTHORIZED).entity("Session Expired.").build();
        }

            DatabaseReference eventsRef = FirebaseDatabase.getInstance().getReference("events");
         // Generate a unique ID for the new chat
        String eventId = eventsRef.child(data.groupID).push().getKey();
            // Set the data for the new chat
        Map<String, Object> eventData = new HashMap<>();
        eventData.put("id", eventId);
        eventData.put("creator", data.creator);
        eventData.put("type", data.type);
        eventData.put("title", data.title);
        eventData.put("description", data.description);
        eventData.put("startTime", data.startTime);
        eventData.put("endTime", data.endTime);
        eventData.put("location", data.location);
        eventsRef.child(data.groupID).child(eventId).setValueAsync(eventData); // Generate a unique ID for the new chat

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

    }

    @DELETE
    @Path("/delete")
    public Response removeEvent(@QueryParam("eventID") String eventID,@QueryParam("groupID") String groupID, @Context HttpHeaders headers) {
        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);

        Entity originalToken = datastore.get(tokenKey);

        if (originalToken == null) {
            return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in").build();
        }

        if (!token.tokenID.equals(originalToken.getString("user_tokenID")) || System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")) {
            return Response.status(Response.Status.UNAUTHORIZED).entity("Session Expired.").build();
        }
        DatabaseReference eventsRef = FirebaseDatabase.getInstance().getReference("events").child(groupID);
        eventsRef.child(eventID).removeValueAsync();

        return Response.ok().build();
    }

}
