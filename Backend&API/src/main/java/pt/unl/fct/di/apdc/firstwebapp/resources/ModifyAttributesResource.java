/**
 * The ModifyAttributesResource class is a Java resource class that handles requests to modify user
 * attributes in a web application.
 */
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

import com.google.appengine.repackaged.org.apache.commons.codec.digest.DigestUtils;
import com.google.cloud.datastore.*;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.gson.Gson;
import org.apache.commons.lang3.StringUtils;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.ModifyAttributesData;
import pt.unl.fct.di.apdc.firstwebapp.util.UserRole;
import pt.unl.fct.di.apdc.firstwebapp.util.VerifyAction;

import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.*;

@Path("/modify")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class ModifyAttributesResource {

    private static final Logger LOG = Logger.getLogger(ModifyAttributesResource.class.getName());

    public ModifyAttributesResource() {
    }

    /**
     * This function modifies attributes for a user or target user based on their roles and
     * permissions.
     * 
     * @param data The `data` parameter is an object of type `ModifyAttributesData`. It contains the
     * data necessary to modify the attributes of a user. The specific attributes and their values are
     * not provided in the code snippet, but they would be included in the `ModifyAttributesData`
     * class.
     * @param headers The `headers` parameter is of type `HttpHeaders` and is used to access the HTTP
     * headers of the incoming request. It can be used to retrieve information such as the content
     * type, authorization token, etc.
     * @return The method is returning a Response object.
     */
    @PATCH
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response modifyAttributes(ModifyAttributesData data, @Context HttpHeaders headers) {
        LOG.fine("Attempt to modify attributes for user:" + data.username);

        Key userKey = datastoreService.newKeyFactory().setKind("User").newKey(data.username);
        Transaction txn = datastoreService.newTransaction();

        // Checks input data
        String validationResult = data.validModifyAttributes();
        if (!validationResult.equals("OK"))
            return Response.status(Status.BAD_REQUEST).entity(validationResult).build();


        try {
            Entity user = txn.get(userKey);

            UserRole userRole = UserRole.valueOf(user.getString("user_role"));
            if (StringUtils.isEmpty(data.targetUsername))
                return modifyUserAttributes(user, userRole, data, txn);
            else {

                Key targetUserKey = datastoreService.newKeyFactory().setKind("User").newKey(data.targetUsername);
                Entity targetUser = txn.get(targetUserKey);

                if (targetUser == null) {
                    txn.rollback();
                    return Response.status(Status.BAD_REQUEST).entity("Target user not found: " + data.username).build();
                }

                UserRole targetUserRole = UserRole.valueOf(targetUser.getString("user_role"));

                if (!canModifyAttributes(userRole, targetUserRole)) {
                    txn.rollback();
                    return Response.status(Status.FORBIDDEN).entity("You do not have the required permissions for this action.").build();
                }

                return modifyUserAttributes(targetUser, targetUserRole, data, txn);
            }
        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    /**
     * This function updates optional fields of a user entity based on the provided data, taking into
     * account the user's role.
     * 
     * @param userRole The user's role, which can be one of the following values: STUDENT, TEACHER,
     * PARENT, ADMIN.
     * @param user The `user` parameter is an instance of the `Entity` class, which represents a user
     * entity in the system. It contains various attributes and their corresponding values for the
     * user.
     * @param data The `data` parameter is an object of type `ModifyAttributesData` which contains
     * various optional fields that can be updated for a user. These fields include:
     * @return The method returns an updated Entity object.
     */
    private Entity updateOptionalFields(UserRole userRole, Entity user, ModifyAttributesData data) {
        Entity.Builder userBuilder = Entity.newBuilder(user);

        if (!userRole.equals(UserRole.STUDENT)) {
            if (StringUtils.isNotEmpty(data.email)) userBuilder.set("user_email", data.email);
            if (StringUtils.isNotEmpty(data.role)) userBuilder.set("user_role", data.role);
            if (StringUtils.isNotEmpty(data.activityState)) userBuilder.set("user_state", data.activityState);
        }
        if (StringUtils.isNotEmpty(data.displayName)) userBuilder.set("user_displayName", data.displayName);
        if (StringUtils.isNotEmpty(data.educationLevel))
            userBuilder.set("user_educationLevel", data.educationLevel);
        if (StringUtils.isNotEmpty(data.birthDate))
            userBuilder.set("user_birthDate", data.birthDate);
        if (StringUtils.isNotEmpty(data.profileVisibility))
            userBuilder.set("user_profileVisibility", data.profileVisibility);
        if (StringUtils.isNotEmpty(data.landlinePhone)) userBuilder.set("user_landlinePhone", data.landlinePhone);
        if (StringUtils.isNotEmpty(data.mobilePhone)) userBuilder.set("user_mobilePhone", data.mobilePhone);
        if (StringUtils.isNotEmpty(data.occupation)) userBuilder.set("user_occupation", data.occupation);
        if (StringUtils.isNotEmpty(data.course)) userBuilder.set("user_course", data.course);
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

    /**
     * The function modifies user attributes, updates the Firebase database, and returns a response
     * with the updated user data.
     * 
     * @param user The "user" parameter is an instance of the Entity class, which represents a user
     * entity in the system. It contains various attributes of the user such as username, email, role,
     * education level, birth date, profile visibility, state, landline phone, mobile phone,
     * occupation, workplace, address
     * @param userRole The userRole parameter is of type UserRole and represents the role of the user.
     * It is used to determine which optional fields can be modified for the user.
     * @param data The `data` parameter is of type `ModifyAttributesData` and contains the updated
     * attribute values for the user.
     * @param txn The "txn" parameter is of type Transaction and is used to perform atomic operations
     * on the database. It is used to update the user entity and commit the changes in a single
     * transaction.
     * @return The method is returning a Response object.
     */
    private Response modifyUserAttributes(Entity user, UserRole userRole, ModifyAttributesData data, Transaction txn) {

        Entity userUpdated = updateOptionalFields(userRole, user, data);
        txn.put(userUpdated);
        LOG.info("User attributes modified: " + data.username);
        txn.commit();

        DatabaseReference chatRef = firebaseInstance.getReference("chat").child(userUpdated.getString("user_username"));
        chatRef.child("DisplayName").setValueAsync(userUpdated.getString("user_displayName"));

        Map<String, Object> responseData = new HashMap<>();
        responseData.put("displayName", userUpdated.getString("user_displayName"));
        responseData.put("username", userUpdated.getString("user_username"));
        responseData.put("email", userUpdated.getString("user_email"));
        responseData.put("role", userUpdated.getString("user_role"));
        responseData.put("educationLevel", userUpdated.getString("user_educationLevel"));
        responseData.put("birthDate", userUpdated.getString("user_birthDate"));
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
        responseData.put("course", userUpdated.getString("user_course"));
        responseData.put("studentNumber", userUpdated.getString("user_student_number"));

        return Response.ok(g.toJson(responseData)).build();
    }

    /**
     * The function checks if a user with a certain role can modify the attributes of another user with
     * a target role.
     * 
     * @param userRole The user role of the user who is trying to modify the attributes. This parameter
     * represents the role of the user who is performing the action.
     * @param targetUserRole The targetUserRole parameter represents the user role whose attributes are
     * being modified.
     * @return The method is returning a boolean value.
     */
    private boolean canModifyAttributes(UserRole userRole, UserRole targetUserRole) {
        return VerifyAction.canExecute(userRole, targetUserRole, "modify_permissions");
    }
}

