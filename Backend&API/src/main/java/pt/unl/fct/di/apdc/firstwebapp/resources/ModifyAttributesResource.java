package pt.unl.fct.di.apdc.firstwebapp.resources;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

import javax.ws.rs.Consumes;
import javax.ws.rs.PATCH;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

import com.google.appengine.repackaged.org.apache.commons.codec.digest.DigestUtils;import com.google.cloud.datastore.*;

import com.google.gson.Gson;
import org.apache.commons.lang3.StringUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.ModifyAttributesData;
import pt.unl.fct.di.apdc.firstwebapp.util.UserRole;
import pt.unl.fct.di.apdc.firstwebapp.util.VerifyAction;

@Path("/modify")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class ModifyAttributesResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink2023").build().getService();
    private static final Logger LOG = Logger.getLogger(ModifyAttributesResource.class.getName());

    private final Gson g = new Gson();

    public ModifyAttributesResource() {
    }

    @PATCH
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response modifyAttributes(ModifyAttributesData data, @Context HttpHeaders headers) {
        LOG.fine("Attempt to modify attributes for user:" + data.username);

        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        Key userKey = datastore.newKeyFactory().setKind("User").newKey(data.username);
        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", token.getUsername()))
                .setKind("User Token").newKey(token.username);
        Transaction txn = datastore.newTransaction();

        // Checks input data
        String validationResult = data.validModifyAttributes();
        if (!validationResult.equals("OK"))
            return Response.status(Status.BAD_REQUEST).entity(validationResult).build();


        try {
            Entity user = txn.get(userKey);
            Entity originalToken = txn.get(tokenKey);

            if (user == null) {
                txn.rollback();
                return Response.status(Status.BAD_REQUEST).entity("User not found: " + data.username).build();
            }
            String storedPassword = user.getString("user_pwd");
            String providedPassword = DigestUtils.sha512Hex(data.password);

            if (!storedPassword.equals(providedPassword)) {
                return Response.status(Status.UNAUTHORIZED).entity("Incorrect password for user: " + data.username).build();
            }

            if (!token.tokenID.equals(originalToken.getString("user_token_ID")) || System.currentTimeMillis() > token.expirationDate) {
                txn.rollback();
                return Response.status(Status.UNAUTHORIZED).entity("Session Expired.").build();
            }


            UserRole userRole = UserRole.valueOf(user.getString("user_role"));
            if (StringUtils.isEmpty(data.targetUsername))
                return modifyUserAttributes(user, userRole, data, txn);
            else {

                Key targetUserKey = datastore.newKeyFactory().setKind("User").newKey(data.targetUsername);
                Entity targetUser = txn.get(targetUserKey);

                if (targetUser == null) {
                    txn.rollback();
                    return Response.status(Status.BAD_REQUEST).entity("Target user not found: " + data.username).build();
                }

                UserRole targetUserRole = UserRole.valueOf(targetUser.getString("user_role"));

                if (!canModifyAttributes( userRole, targetUserRole)) {
                    txn.rollback();
                    return Response.status(Status.FORBIDDEN).entity("You do not have the required permissions for this action.").build();
                }

                return modifyUserAttributes(targetUser, targetUserRole, data, txn);
            }
        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    private Entity updateOptionalFields(UserRole userRole, Entity user, ModifyAttributesData data) {
        Entity.Builder userBuilder = Entity.newBuilder(user);

        if (!userRole.equals(UserRole.STUDENT)) {
            if (StringUtils.isNotEmpty(data.displayName)) userBuilder.set("user_displayName", data.displayName);
            if (StringUtils.isNotEmpty(data.email)) userBuilder.set("user_email", data.email);
            if (StringUtils.isNotEmpty(data.role)) userBuilder.set("user_role", data.role);
            if (StringUtils.isNotEmpty(data.activityState)) userBuilder.set("user_state", data.activityState);
        }
        if (StringUtils.isNotEmpty(data.profileVisibility))
            userBuilder.set("user_profileVisibility", data.profileVisibility);
        if (StringUtils.isNotEmpty(data.landlinePhone)) userBuilder.set("user_landlinePhone", data.landlinePhone);
        if (StringUtils.isNotEmpty(data.mobilePhone)) userBuilder.set("user_mobilePhone", data.mobilePhone);
        if (StringUtils.isNotEmpty(data.occupation)) userBuilder.set("user_occupation", data.occupation);
        if (StringUtils.isNotEmpty(data.workplace)) userBuilder.set("user_workplace", data.workplace);
        if (StringUtils.isNotEmpty(data.address)) userBuilder.set("user_address", data.address);
        if (StringUtils.isNotEmpty(data.additionalAddress))
            userBuilder.set("user_additionalAddress", data.additionalAddress);
        if (StringUtils.isNotEmpty(data.locality)) userBuilder.set("user_locality", data.locality);
        if (StringUtils.isNotEmpty(data.postalCode)) userBuilder.set("user_postalCode", data.postalCode);
        if (StringUtils.isNotEmpty(data.taxIdentificationNumber))
            userBuilder.set("user_taxIdentificationNumber", data.taxIdentificationNumber);
        if (StringUtils.isNotEmpty(data.photo)) userBuilder.set("user_photo", data.photo);

        return userBuilder.build();
    }

    private Response modifyUserAttributes(Entity user, UserRole userRole, ModifyAttributesData data, Transaction txn) {

        Entity userUpdated = updateOptionalFields(userRole, user, data);
        txn.put(userUpdated);
        LOG.info("User attributes modified: " + data.username);
        txn.commit();

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("displayName", userUpdated.getString("user_displayName"));
        responseData.put("username", userUpdated.getString("user_username"));
        responseData.put("email", userUpdated.getString("user_email"));
        responseData.put("role", userUpdated.getString("user_role"));
        responseData.put("profileVisibility", userUpdated.getString("user_profileVisibility"));
        responseData.put("state", userUpdated.getString("user_state"));
        responseData.put("landlinePhone", userUpdated.getString("user_landlinePhone"));
        responseData.put("mobilePhone", userUpdated.getString("user_mobilePhone"));
        responseData.put("occupation", userUpdated.getString("user_occupation"));
        responseData.put("workplace", userUpdated.getString("user_workplace"));
        responseData.put("address", userUpdated.getString("user_address"));
        responseData.put("additionalAddress", userUpdated.getString("user_additionalAddress"));
        responseData.put("locality", userUpdated.getString("user_locality"));
        responseData.put("postalCode", userUpdated.getString("user_postalCode"));
        responseData.put("nif", userUpdated.getString("user_taxIdentificationNumber"));
        responseData.put("photo", userUpdated.getString("user_photo"));

        return Response.ok(g.toJson(responseData)).build();
    }

    private boolean canModifyAttributes(UserRole userRole, UserRole targetUserRole) {
        return VerifyAction.canExecute(userRole, targetUserRole, "modify_permissions");
    }
}

