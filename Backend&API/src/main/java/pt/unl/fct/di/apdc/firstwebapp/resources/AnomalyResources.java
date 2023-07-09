package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.AnomalyData;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import com.google.cloud.Timestamp;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

@Path("/anomaly")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class AnomalyResources {
    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink23").build().getService();
    private final Gson g = new Gson();
    private static final Logger LOG = Logger.getLogger(ChangePasswordResource.class.getName());

    public AnomalyResources() {
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/send")
    public Response sendAnomaly(AnomalyData data, @Context HttpHeaders headers) {
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
        AnomalyData anomaly = new AnomalyData(data.title, data.description, data.coordinates, data.sender);

        DatabaseReference anomaliesRef = FirebaseDatabase.getInstance().getReference("anomaly");
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

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/detect")
    public Response detectAnomaly(String anomalyId, @Context HttpHeaders headers) {
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

        Map<String, Object> updates = new HashMap<>();
        updates.put("status", "Detected");

        DatabaseReference anomaliesRef = FirebaseDatabase.getInstance().getReference("anomaly");
        anomaliesRef.child(anomalyId).updateChildrenAsync(updates);
        return Response.ok().build();
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/confirm")
    public Response confirmAnomaly(String anomalyId, @Context HttpHeaders headers) {
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
        Map<String, Object> updates = new HashMap<>();
        updates.put("status", "Confirmed");

        DatabaseReference anomaliesRef = FirebaseDatabase.getInstance().getReference("anomaly");
        anomaliesRef.child(anomalyId).updateChildrenAsync(updates);
        return Response.ok().build();
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/reject")
    public Response rejectAnomaly(String anomalyId, @Context HttpHeaders headers) {
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
        Map<String, Object> updates = new HashMap<>();
        updates.put("status", "Rejected");

        DatabaseReference anomaliesRef = FirebaseDatabase.getInstance().getReference("anomaly");
        anomaliesRef.child(anomalyId).updateChildrenAsync(updates);
        return Response.ok().build();
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/inProgress")
    public Response reviewingAnomaly(String anomalyId, @Context HttpHeaders headers) {
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

        Map<String, Object> updates = new HashMap<>();
        updates.put("status", "In Progress");

        DatabaseReference anomaliesRef = FirebaseDatabase.getInstance().getReference("anomaly");
        anomaliesRef.child(anomalyId).updateChildrenAsync(updates);
        return Response.ok().build();
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/resolve")
    public Response resolveAnomaly(String anomalyId, @Context HttpHeaders headers) {
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

        Map<String, Object> updates = new HashMap<>();
        updates.put("status", "Solved");

        DatabaseReference anomaliesRef = FirebaseDatabase.getInstance().getReference("anomaly");
        anomaliesRef.child(anomalyId).updateChildrenAsync(updates);
        return Response.ok().build();
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Path("/delete")
    public Response deleteAnomaly(String anomalyId, @Context HttpHeaders headers) {
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

        DatabaseReference anomaliesRef = FirebaseDatabase.getInstance().getReference("anomaly");
        anomaliesRef.child(anomalyId).removeValueAsync();

        return Response.ok().build();
    }
}