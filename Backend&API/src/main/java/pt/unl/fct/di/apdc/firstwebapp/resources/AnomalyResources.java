/**
 * The above class is a Java resource class that handles various operations related to anomalies, such
 * as sending, detecting, confirming, rejecting, reviewing, resolving, and deleting anomalies.
 */
package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.Entity;
import com.google.cloud.datastore.Key;
import com.google.cloud.datastore.PathElement;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.AnomalyData;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.*;

@Path("/anomaly")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class AnomalyResources {
    public AnomalyResources() {
    }

    /**
     * This function receives an AnomalyData object, creates a new AnomalyData object with the received
     * data, and stores it in a Firebase database.
     * 
     * @param data AnomalyData object containing the anomaly information such as title, description,
     * coordinates, and sender.
     * @param headers The `headers` parameter is of type `HttpHeaders` and is used to access the HTTP
     * headers of the incoming request. It can be used to retrieve information such as the content
     * type, authorization token, or any other custom headers that were included in the request.
     * @return The method is returning a Response object with a status of 200 (OK).
     */
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/send")
    public Response sendAnomaly(AnomalyData data, @Context HttpHeaders headers) {
        AnomalyData anomaly = new AnomalyData(data.title, data.description, data.coordinates, data.sender);

        DatabaseReference anomaliesRef = firebaseInstance.getReference("anomaly");
        Map<String, Object> anomalyData = new HashMap<>();
        anomalyData.put("timestamp", System.currentTimeMillis());
        anomalyData.put("sender", anomaly.sender);
        anomalyData.put("title", anomaly.title);
        anomalyData.put("description", anomaly.description);
        anomalyData.put("location", anomaly.coordinates);
        anomalyData.put("status", "Detected");
        anomaliesRef.child(anomaly.id).setValueAsync(anomalyData);
        return Response.ok().build();
    }


    /**
     * This Java function detects an anomaly by updating the status of the anomaly in a Firebase
     * database.
     * 
     * @param anomalyId The anomalyId parameter is a string that represents the unique identifier of
     * the anomaly that needs to be detected.
     * @param headers The `headers` parameter is of type `HttpHeaders` and is used to access the HTTP
     * headers of the incoming request. It can be used to retrieve information such as the content
     * type, authorization token, or any custom headers that were included in the request.
     * @return The method is returning a Response object with a status of "OK" (200).
     */
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/detect")
    public Response detectAnomaly(String anomalyId, @Context HttpHeaders headers) {

        Map<String, Object> updates = new HashMap<>();
        updates.put("status", "Detected");

        DatabaseReference anomaliesRef = firebaseInstance.getReference("anomaly");
        anomaliesRef.child(anomalyId).updateChildrenAsync(updates);
        return Response.ok().build();
    }

    /**
     * This function confirms an anomaly by updating its status to "Confirmed" in a Firebase database.
     * 
     * @param anomalyId The anomalyId parameter is a string that represents the unique identifier of
     * the anomaly that needs to be confirmed.
     * @param headers The `headers` parameter is used to access the HTTP headers of the incoming
     * request. It can be used to retrieve information such as the content type, authorization token,
     * or any custom headers that were included in the request.
     * @return The method is returning a Response object with a status of "OK" (200).
     */
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/confirm")
    public Response confirmAnomaly(String anomalyId, @Context HttpHeaders headers) {
        Map<String, Object> updates = new HashMap<>();
        updates.put("status", "Confirmed");

        DatabaseReference anomaliesRef = firebaseInstance.getReference("anomaly");
        anomaliesRef.child(anomalyId).updateChildrenAsync(updates);
        return Response.ok().build();
    }

    /**
     * This function updates the status of an anomaly to "Rejected" in a Firebase database.
     * 
     * @param anomalyId The anomalyId parameter is a string that represents the unique identifier of
     * the anomaly that needs to be rejected.
     * @param headers The `headers` parameter is used to access the HTTP headers of the incoming
     * request. It can be used to retrieve information such as the content type, authorization token,
     * or any custom headers that were included in the request.
     * @return The method is returning a Response object with a status of "OK" (200).
     */
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/reject")
    public Response rejectAnomaly(String anomalyId, @Context HttpHeaders headers) {
        Map<String, Object> updates = new HashMap<>();
        updates.put("status", "Rejected");

        DatabaseReference anomaliesRef = firebaseInstance.getReference("anomaly");
        anomaliesRef.child(anomalyId).updateChildrenAsync(updates);
        return Response.ok().build();
    }

    /**
     * This function updates the status of an anomaly to "In Progress" in a Firebase database.
     * 
     * @param anomalyId The anomalyId parameter is a string that represents the unique identifier of
     * the anomaly being reviewed.
     * @param headers The `headers` parameter is used to access the HTTP headers of the incoming
     * request. It can be used to retrieve information such as authentication tokens, content type, and
     * other metadata associated with the request.
     * @return The method is returning a Response object with a status of "OK" (200).
     */
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/inProgress")
    public Response reviewingAnomaly(String anomalyId, @Context HttpHeaders headers) {
        Map<String, Object> updates = new HashMap<>();
        updates.put("status", "In Progress");

        DatabaseReference anomaliesRef = firebaseInstance.getReference("anomaly");
        anomaliesRef.child(anomalyId).updateChildrenAsync(updates);
        return Response.ok().build();
    }

    /**
     * This function resolves an anomaly by updating its status to "Solved" in a Firebase database.
     * 
     * @param anomalyId The anomalyId parameter is a string that represents the unique identifier of
     * the anomaly that needs to be resolved.
     * @param headers The `headers` parameter is of type `HttpHeaders` and is used to access the HTTP
     * headers of the incoming request. It can be used to retrieve information such as the content
     * type, authorization token, or any custom headers that were included in the request.
     * @return The method is returning a Response object with a status of "OK" (200).
     */
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/resolve")
    public Response resolveAnomaly(String anomalyId, @Context HttpHeaders headers) {
        Map<String, Object> updates = new HashMap<>();
        updates.put("status", "Solved");

        DatabaseReference anomaliesRef = firebaseInstance.getReference("anomaly");
        anomaliesRef.child(anomalyId).updateChildrenAsync(updates);
        return Response.ok().build();
    }

    /**
     * This function deletes an anomaly from a Firebase database based on its ID.
     * 
     * @param anomalyId The anomalyId parameter is a string that represents the unique identifier of
     * the anomaly that needs to be deleted.
     * @param headers The `headers` parameter is used to access the HTTP headers of the request. It can
     * be used to retrieve information such as authentication tokens, content type, etc.
     * @return The method is returning a Response object with a status of "OK" (200).
     */
    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/delete")
    public Response deleteAnomaly(String anomalyId, @Context HttpHeaders headers) {
        DatabaseReference anomaliesRef = firebaseInstance.getReference("anomaly");
        anomaliesRef.child(anomalyId).removeValueAsync();

        return Response.ok().build();
    }
}