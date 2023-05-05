package pt.unl.fct.di.apdc.firstwebapp.resources;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

import com.google.cloud.Timestamp;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.LoginData;

import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

import com.google.appengine.repackaged.org.apache.commons.codec.digest.DigestUtils;
import com.google.cloud.datastore.*;

import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.UserActivityState;

@Path("/login")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class LoginResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink2023").build().getService();
    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());
    private final Gson g = new Gson();

    @POST
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
    public Response doLogin(LoginData data, @Context HttpServletRequest request, @Context HttpHeaders headers) {
        LOG.fine("Attempt to login user: " + data.username);

        Key ctrskey = createUserStatsKey(data.username);
        Key logKey = createLogKey(data.username);
        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", data.username))
                .setKind("User Token").newKey(data.username);

        Transaction txn = datastore.newTransaction();
        try {

            Query<Entity> queryByUsername = Query.newEntityQueryBuilder()
                    .setKind("User")
                    .setFilter(StructuredQuery.PropertyFilter.eq("user_username", data.username))
                    .build();
            QueryResults<Entity> resultsByUsername = datastore.run(queryByUsername);

            Query<Entity> queryByEmail = Query.newEntityQueryBuilder()
                    .setKind("User")
                    .setFilter(StructuredQuery.PropertyFilter.eq("user_email", data.username))
                    .build();
            QueryResults<Entity> resultsByEmail = datastore.run(queryByEmail);

            Entity user = null;
            if (resultsByUsername.hasNext())
                user = resultsByUsername.next();
            else if (resultsByEmail.hasNext())
                user = resultsByEmail.next();

            if (user == null) {
                LOG.warning("Failed login attempt for username/email: " + data.username);
                return Response.status(Status.FORBIDDEN).build();
            }

            Entity stats = getOrCreateUserStats(txn, ctrskey);
            Entity log = createLogEntity(request, headers, logKey);

            String hashedPWD = user.getString("user_pwd");

            if (hashedPWD.equals(DigestUtils.sha512Hex(data.password))) {

                if (user.getString("user_state").equals(UserActivityState.INACTIVE.toString())) {
                    LOG.warning("No active account: " + data.username);
                    return Response.status(Status.EXPECTATION_FAILED).entity("Email verification needed! Please verify your email inbox and activate your account.").build();
                }

                Entity uStats = updateStatsForSuccessfulLogin(stats, ctrskey);
                return handleSuccessfulLogin(user,  txn, log, uStats, tokenKey);
            } else {
                return handleFailedLogin(data.username, txn, stats, ctrskey);
            }
        } catch (Exception e) {
            txn.rollback();
            LOG.severe("An error occurred during login: " + e);
            return Response.status(Status.INTERNAL_SERVER_ERROR).build();
        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    private Key createUserStatsKey(String username) {
        return datastore.newKeyFactory()
                .addAncestors(PathElement.of("User", username))
                .setKind("UserStats").newKey("counters");
    }

    private Key createLogKey(String username) {
        return datastore.allocateId(datastore.newKeyFactory()
                .addAncestors(PathElement.of("User", username))
                .setKind("UserLog").newKey());
    }

    private Entity getOrCreateUserStats(Transaction txn, Key ctrskey) {
        Entity stats = txn.get(ctrskey);
        if (stats == null) {
            stats = Entity.newBuilder(ctrskey)
                    .set("user_stats_logins", 0L)
                    .set("user_stats_failed", 0L)
                    .set("user_first_login", Timestamp.now()).set("user_last_login", Timestamp.now())
                    .build();
        }
        return stats;
    }

    private Response handleSuccessfulLogin(Entity user, Transaction txn, Entity log,  Entity uStats, Key tokenKey) {

        AuthToken token = new AuthToken(user.getString("user_username"));
        Entity user_token = Entity.newBuilder(tokenKey)
                .set("tokenID", token.tokenID)
                .set("user_token_creation_data", token.creationDate)
                .set("user_token_expiration_data", token.expirationDate)
                .build();

        Map<String, Object> tokenData = new HashMap<>();
        tokenData.put("tokenID", token.tokenID);
        tokenData.put("username", token.username);

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("displayName", user.getString("user_displayName"));
        responseData.put("username", user.getString("user_username"));
        responseData.put("email", user.getString("user_email"));
        responseData.put("role", user.getString("user_role"));
        responseData.put("profileVisibility", user.getString("user_profileVisibility"));
        responseData.put("state", user.getString("user_state"));
        responseData.put("landlinePhone", user.getString("user_landlinePhone"));
        responseData.put("mobilePhone", user.getString("user_mobilePhone"));
        responseData.put("occupation", user.getString("user_occupation"));
        responseData.put("workplace", user.getString("user_workplace"));
        responseData.put("address", user.getString("user_address"));
        responseData.put("additionalAddress", user.getString("user_additionalAddress"));
        responseData.put("locality", user.getString("user_locality"));
        responseData.put("postalCode", user.getString("user_postalCode"));
        responseData.put("nif", user.getString("user_taxIdentificationNumber"));
        responseData.put("photo", user.getString("user_photo"));

        LOG.info("User " + user.getString("user_username") + " logged in successfully.");
        //OP7
        LOG.info("The tokenID for the current session is " + token.tokenID + "\n  Creation time: " + token.creationDate + "\n  Expiration time: " + token.expirationDate);
        txn.put(log, uStats, user_token);
        txn.commit();
        return Response.ok(g.toJson(responseData)).header("Authorization", "Bearer " + g.toJson(tokenData)).build();
    }

    private Entity createLogEntity(HttpServletRequest request, HttpHeaders headers, Key logKey) {
        String cityLatLong = headers.getHeaderString("X-AppEngine-CityLatLong");
        String city = headers.getHeaderString("X-AppEngine-City");
        String country = headers.getHeaderString("X-AppEngine-Country");

        return Entity.newBuilder(logKey)
                .set("user_login_ip", request.getRemoteAddr())
                .set("user_login_host", request.getRemoteHost())
                .set("user_login_latlon",
                        cityLatLong != null
                                ? StringValue.newBuilder(cityLatLong).setExcludeFromIndexes(true).build()
                                : StringValue.newBuilder("").setExcludeFromIndexes(true).build())
                .set("user_login_city", city != null ? city : "")
                .set("user_login_country", country != null ? country : "")
                .set("user_login_time", Timestamp.now())
                .build();
    }

    private Entity updateStatsForSuccessfulLogin(Entity stats, Key ctrskey) {
        return Entity.newBuilder(ctrskey)
                .set("user_stats_logins", 1L + stats.getLong("user_stats_logins"))
                .set("user_stats_failed", 0L)
                .set("user_first_login", stats.getTimestamp("user_first_login"))
                .set("user_last_login", Timestamp.now())
                .build();
    }

    private Response handleFailedLogin(String username, Transaction txn, Entity stats, Key ctrskey) {
        Entity ustats = updateStatsForFailedLogin(stats, ctrskey);
        txn.put(ustats);
        txn.commit();
        LOG.warning("Wrong password for username: " + username);
        return Response.status(Status.FORBIDDEN).build();
    }

    private Entity updateStatsForFailedLogin(Entity stats, Key ctrskey) {
        return Entity.newBuilder(ctrskey)
                .set("user_stats_logins", stats.getLong("user_stats_logins"))
                .set("user_stats_failed", 1L + stats.getLong("user_stats_failed"))
                .set("user_first_login", stats.getTimestamp("user_first_login"))
                .set("user_last_login", stats.getTimestamp("user_last_login"))
                .set("user_last_attempt", Timestamp.now())
                .build();
    }

}

