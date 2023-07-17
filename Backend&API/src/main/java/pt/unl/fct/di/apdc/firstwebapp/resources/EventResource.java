/**
 * The EventResource class is a Java resource class that handles HTTP requests related to events, such
 * as adding and deleting events.
 */
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

import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.*;

@Path("/events")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class EventResource {

    private static final Logger LOG = Logger.getLogger(EventResource.class.getName());

    public EventResource() {

    }

    /**
     * This Java function adds an event to a Firebase Realtime Database and returns the event data in
     * JSON format.
     * 
     * @param data The "data" parameter is an object of type EventData. It contains the following
     * properties:
     * @param headers The `headers` parameter is used to access the HTTP headers of the incoming
     * request. It is annotated with `@Context` to indicate that it should be injected by the JAX-RS
     * runtime.
     * @return The method is returning a Response object.
     */
    @POST
    @Path("/add")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
    public Response addEvent(EventData data, @Context HttpHeaders headers) {

        DatabaseReference eventsRef = firebaseInstance.getReference("events");
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

    /**
     * This function removes an event from a Firebase database based on the event ID and group ID
     * provided.
     * 
     * @param eventID The eventID parameter is a string that represents the unique identifier of the
     * event that needs to be deleted.
     * @param groupID The groupID parameter is used to identify the group to which the event belongs.
     * @param headers The `headers` parameter is used to access the HTTP headers of the request. It is
     * of type `HttpHeaders` and can be used to retrieve information such as the authorization token,
     * content type, etc.
     * @return The method is returning a Response object with a status of "OK" (200).
     */
    @DELETE
    @Path("/delete")
    public Response removeEvent(@QueryParam("eventID") String eventID, @QueryParam("groupID") String groupID, @Context HttpHeaders headers) {
        DatabaseReference eventsRef = firebaseInstance.getReference("events").child(groupID);
        eventsRef.child(eventID).removeValueAsync();
        return Response.ok().build();
    }

}
