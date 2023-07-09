package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.AnomalyData;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;

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

@Path("/anomaly")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class AnomalyResources {
    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink23").build().getService();
    private final Gson g = new Gson();
    private static final Logger LOG = Logger.getLogger(ChangePasswordResource.class.getName());

    public AnomalyResources() {
    }

    @POST
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
        AnomalyData anomaly = new AnomalyData(data.title, data.description, data.coordinates);

        DatabaseReference anomaliesRef = FirebaseDatabase.getInstance().getReference("anomaly");
        Map<String, Object> eventData = new HashMap<>();
        eventData.put("title", anomaly.title);
        eventData.put("description", anomaly.description);
        eventData.put("location", anomaly.coordinates);
        anomaliesRef.child(anomaly.AnoamlyID).setValueAsync(eventData);
        /*Transaction txn = datastore.newTransaction();
        try {
            AnomalyData anomaly = new AnomalyData(data.title, data.description, data.coordinates);
            Key anomalyKey = datastore.newKeyFactory().setKind("Anomaly").newKey(anomaly.AnoamlyID);
            Entity.Builder anomalyBuilder = Entity.newBuilder(anomalyKey)
                    .set("title", anomaly.title)
                    .set("description", anomaly.description)
                    .set("coordinates", anomaly.coordinates);
            txn.add(anomalyBuilder.build());
            txn.commit();
            return Response.ok("{}").build();
        } finally {
            if (txn.isActive()) txn.rollback();
        }*/
        return Response.ok().build();
    }

    @POST
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

        DatabaseReference anomaliesRef = FirebaseDatabase.getInstance().getReference("anomaly");
        anomaliesRef.child(anomalyId).removeValueAsync();
       /* Transaction txn = datastore.newTransaction();
        try {
            Key anomalyKey = datastore.newKeyFactory().setKind("Anomaly").newKey(anomalyId);

            txn.delete(anomalyKey);
            txn.commit();
            return Response.ok("{}").build();
        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }*/
        return Response.ok().build();
    }
}