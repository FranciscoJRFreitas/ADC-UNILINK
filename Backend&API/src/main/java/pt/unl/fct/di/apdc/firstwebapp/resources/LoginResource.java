/**
 * The LoginResource class is a Java resource class that handles user login functionality for a web
 * application.
 */
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

import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.datastoreService;
import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.g;

@Path("/login")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class LoginResource {
    private static final Logger LOG = Logger.getLogger(LoginResource.class.getName());

    /**
     * The above function is a Java method that handles user login by checking the provided credentials
     * against the stored user data in a datastore and returning an appropriate response.
     * 
     * @param data The `data` parameter is an object of type `LoginData` which contains the login
     * credentials entered by the user. It includes the `username` and `password` fields.
     * @param request The `request` parameter is of type `HttpServletRequest` and represents the HTTP
     * request made by the client. It contains information such as the request method, headers, and
     * body.
     * @param headers The `headers` parameter is of type `HttpHeaders` and represents the HTTP headers
     * of the request. It can be used to access and manipulate the headers sent in the request.
     * @return The method is returning a Response object. The specific response returned depends on the
     * logic and conditions within the method. The possible responses that can be returned are:
     */
    @POST
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
    public Response doLogin(LoginData data, @Context HttpServletRequest request, @Context HttpHeaders headers) {
        LOG.fine("Attempt to login user: " + data.username);

        Key ctrskey = createUserStatsKey(data.username);
        Key logKey = createLogKey(data.username);

        Transaction txn = datastoreService.newTransaction();
        try {

            Query<Entity> queryByUsername = Query.newEntityQueryBuilder()
                    .setKind("User")
                    .setFilter(StructuredQuery.PropertyFilter.eq("user_username", data.username))
                    .build();
            QueryResults<Entity> resultsByUsername = datastoreService.run(queryByUsername);

            Query<Entity> queryByEmail = Query.newEntityQueryBuilder()
                    .setKind("User")
                    .setFilter(StructuredQuery.PropertyFilter.eq("user_email", data.username))
                    .build();
            QueryResults<Entity> resultsByEmail = datastoreService.run(queryByEmail);

            Entity user = null;
            if (resultsByUsername.hasNext())
                user = resultsByUsername.next();
            else if (resultsByEmail.hasNext())
                user = resultsByEmail.next();

            if (user == null) {
                LOG.warning("Failed login attempt for username/email: " + data.username);
                return Response.status(Status.NOT_FOUND).entity("Invalid login credentials. Please try again.").build();
            }
            String username = user.getString("user_username");
            Key tokenKey = datastoreService.newKeyFactory().addAncestor(PathElement.of("User", username))
                    .setKind("User Token").newKey(username);

            Entity stats = getOrCreateUserStats(txn, ctrskey);
            Entity log = createLogEntity(request, headers, logKey);

            String hashedPWD = user.getString("user_pwd");

            if (hashedPWD.equals(DigestUtils.sha512Hex(data.password))) {

                if (user.getString("user_state").equals(UserActivityState.INACTIVE.toString())) {
                    LOG.warning("No active account: " + data.username);
                    return Response.status(Status.EXPECTATION_FAILED).entity("Email verification needed! Please verify your email inbox and activate your account.").build();
                }

                Entity uStats = updateStatsForSuccessfulLogin(stats, ctrskey);
                return handleSuccessfulLogin(user, txn, log, uStats, tokenKey);
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

    /**
     * The function `createUserStatsKey` creates a new key for a user's statistics entity in a
     * datastore, using the username as an ancestor and "UserStats" as the kind.
     * 
     * @param username The username parameter is a string that represents the username of the user for
     * whom the user statistics key is being created.
     * @return The method is returning a private Key object.
     */
    private Key createUserStatsKey(String username) {
        return datastoreService.newKeyFactory()
                .addAncestors(PathElement.of("User", username))
                .setKind("UserStats").newKey("counters");
    }

    /**
     * The function creates a new key for a user log entity in the datastore.
     * 
     * @param username The username parameter is a string that represents the username of the user for
     * whom the log key is being created.
     * @return The method is returning a private Key object.
     */
    private Key createLogKey(String username) {
        return datastoreService.allocateId(datastoreService.newKeyFactory()
                .addAncestors(PathElement.of("User", username))
                .setKind("UserLog").newKey());
    }

    /**
     * The function retrieves or creates a user's statistics entity in a transaction.
     * 
     * @param txn The "txn" parameter is a transaction object that is used to perform operations on the
     * datastore. It allows for atomicity and consistency when making multiple changes to the
     * datastore.
     * @param ctrskey The `ctrskey` parameter is a `Key` object that represents the key of the entity
     * in the datastore. It is used to retrieve or create the entity for user statistics.
     * @return The method is returning an Entity object.
     */
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

    /**
     * This function handles a successful login by creating an authentication token, retrieving user
     * data, and returning a response with the user's information and the token.
     * 
     * @param user The "user" parameter is an Entity object that represents the user who successfully
     * logged in. It contains various properties such as "user_displayName", "user_username",
     * "user_email", etc., which hold the user's information.
     * @param txn The "txn" parameter is an instance of the Transaction class, which is used to perform
     * operations on the datastore within a transaction. It allows you to read and write entities
     * atomically, ensuring consistency and isolation.
     * @param log The `log` parameter is an `Entity` object representing the log entry for the user's
     * login activity. It contains information such as the user's username, login time, and IP address.
     * @param uStats uStats is an Entity object that represents the user's statistics or activity data.
     * It is used to store information related to the user's login activity, such as the number of
     * active logins.
     * @param tokenKey The tokenKey parameter is a Key object that represents the key of the entity in
     * the datastore where the token information is stored.
     * @return The method is returning a Response object.
     */
    private Response handleSuccessfulLogin(Entity user, Transaction txn, Entity log, Entity uStats, Key tokenKey) {

        Entity originalToken = txn.get(tokenKey);
        AuthToken token;
        Entity user_token;

        if(originalToken == null) {
            token = new AuthToken(user.getString("user_username"));
            user_token = Entity.newBuilder(tokenKey)
                    .set("user_tokenID", token.tokenID)
                    .set("user_token_creation_date", token.creationDate)
                    .set("user_token_expiration_date", token.expirationDate)
                    .set("user_active_logins", 1L)
                    .build();

        } else {
            token = new AuthToken(user.getString("user_username"), originalToken.getString("user_tokenID"));
            user_token = Entity.newBuilder(tokenKey)
                    .set("user_tokenID", token.tokenID)
                    .set("user_token_creation_date", originalToken.getLong("user_token_creation_date"))
                    .set("user_token_expiration_date", token.expirationDate)
                    .set("user_active_logins", 1L + originalToken.getLong("user_active_logins"))
                    .build();
        }

        String tokenString = token.tokenID + "|" + token.username;

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("displayName", user.getString("user_displayName"));
        responseData.put("username", user.getString("user_username"));
        responseData.put("email", user.getString("user_email"));
        responseData.put("role", user.getString("user_role"));
        responseData.put("studentNumber", user.getString("user_student_number"));
        responseData.put("birthDate", user.getString("user_birthDate"));
        responseData.put("educationLevel", user.getString("user_educationLevel"));
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
        responseData.put("creationTime", user.getTimestamp("user_creation_time"));
        responseData.put("course", user.getString("user_course"));

        LOG.info("User " + user.getString("user_username") + " logged in successfully.");
        LOG.info("The tokenID for the current session is " + token.tokenID + "\n  Creation time: " + token.creationDate + "\n  Expiration time: " + token.expirationDate);
        txn.put(log, uStats, user_token);
        txn.commit();
        return Response.ok(g.toJson(responseData)).header("Authorization", "Bearer " + tokenString).build();
    }

    /**
     * The function creates an entity with various properties based on the request, headers, and a
     * given key.
     * 
     * @param request The `HttpServletRequest` object represents the HTTP request made by the client.
     * It contains information such as the request method, headers, parameters, and body.
     * @param headers The `headers` parameter is an instance of the `HttpHeaders` class, which
     * represents the HTTP headers of a request. It contains methods to retrieve specific header values
     * based on their names.
     * @param logKey The logKey parameter is the key that will be used to identify the log entity in
     * the datastore. It is of type Key.
     * @return The method is returning an Entity object.
     */
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

    /**
     * The function updates the statistics of a user after a successful login.
     * 
     * @param stats The "stats" parameter is an Entity object that represents the current statistics of
     * a user. It contains properties such as "user_stats_logins", "user_stats_failed",
     * "user_first_login", and "user_last_login".
     * @param ctrskey The `ctrskey` parameter is a Key object that represents the key of the entity
     * that needs to be updated. It is used to specify the entity that needs to be modified in the
     * datastore.
     * @return The method is returning an updated Entity object with the updated login statistics.
     */
    private Entity updateStatsForSuccessfulLogin(Entity stats, Key ctrskey) {
        return Entity.newBuilder(ctrskey)
                .set("user_stats_logins", 1L + stats.getLong("user_stats_logins"))
                .set("user_stats_failed", 0L)
                .set("user_first_login", stats.getTimestamp("user_first_login"))
                .set("user_last_login", Timestamp.now())
                .build();
    }

    /**
     * The function handles a failed login attempt by updating the user's statistics, logging the
     * event, and returning a forbidden response.
     * 
     * @param username The username of the user who failed to login.
     * @param txn txn is an instance of the Transaction class, which is used to perform operations on
     * the datastore within a transaction. It is used to update the user statistics entity and commit
     * the changes to the datastore.
     * @param stats The "stats" parameter is an instance of the "Entity" class, which represents an
     * entity in the datastore. It likely contains information about the user's login statistics, such
     * as the number of failed login attempts.
     * @param ctrskey The `ctrskey` parameter is a `Key` object that represents the key of the entity
     * that stores the login attempt counter for the user.
     * @return The method is returning a Response object with a status of FORBIDDEN.
     */
    private Response handleFailedLogin(String username, Transaction txn, Entity stats, Key ctrskey) {
        Entity ustats = updateStatsForFailedLogin(stats, ctrskey);
        txn.put(ustats);
        txn.commit();
        LOG.warning("Wrong password for username: " + username);
        return Response.status(Status.FORBIDDEN).build();
    }

    /**
     * The function updates the statistics for a failed login attempt in an entity.
     * 
     * @param stats An Entity object that contains the current statistics for a user.
     * @param ctrskey The `ctrskey` parameter is a Key object that represents the key of the entity
     * that needs to be updated. It is used to specify the entity that will be updated in the
     * datastore.
     * @return The method is returning an updated Entity object.
     */
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

