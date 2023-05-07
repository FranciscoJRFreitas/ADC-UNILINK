package pt.unl.fct.di.apdc.firstwebapp.resources;

import java.util.logging.Logger;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

import com.google.appengine.repackaged.org.apache.commons.codec.digest.DigestUtils;
import com.google.cloud.Timestamp;
import com.google.cloud.datastore.*;

import pt.unl.fct.di.apdc.firstwebapp.util.RegisterData;
import pt.unl.fct.di.apdc.firstwebapp.util.UserActivityState;
import pt.unl.fct.di.apdc.firstwebapp.util.UserProfileVisibility;
import pt.unl.fct.di.apdc.firstwebapp.util.UserRole;

@Path("/register")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class RegisterResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("ai-60313").build().getService();
    private static final Logger LOG = Logger.getLogger(RegisterResource.class.getName());

    public RegisterResource() {
    } //This class wont be instancialized

    @POST
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response doRegistration(RegisterData data) {
        LOG.fine("Attempt to register user:" + data.username);

        // Checks input data
        String validationResult = data.validRegistration();
        if (!validationResult.equals("OK"))
            return Response.status(Status.BAD_REQUEST).entity(validationResult).build();

        Key userKey = datastore.newKeyFactory().setKind("User").newKey(data.username);
        Transaction txn = datastore.newTransaction();
        try {
            Entity user = txn.get(userKey);

            if (user != null) {
                txn.rollback();
                return Response.status(Status.CONFLICT).entity("User already exists.").build();
            }
            // Set mandatory fields
            Entity.Builder userBuilder = Entity.newBuilder(userKey)
                    .set("user_displayName", data.displayName)
                    .set("user_username", data.username)
                    .set("user_email", data.email)
                    .set("user_pwd", DigestUtils.sha512Hex(data.password))
                    .set("user_role", UserRole.USER.toString())
                    .set("user_creation_time", Timestamp.now())
                    .set("user_profileVisibility", UserProfileVisibility.PUBLIC.toString())
                    .set("user_state", UserActivityState.INACTIVE.toString())
                    .set("user_landlinePhone", "")
                    .set("user_mobilePhone", "")
                    .set("user_occupation", "")
                    .set("user_workplace", "")
                    .set("user_address", "")
                    .set("user_additionalAddress", "")
                    .set("user_locality", "")
                    .set("user_postalCode", "")
                    .set("user_taxIdentificationNumber", "")
                    .set("user_photo", "")
                    ;
            // Set optional fields
            if (data.role != null) userBuilder.set("user_role", data.role.toString());
            if (data.profileVisibility != null) userBuilder.set("user_profileVisibility", data.profileVisibility.toString());
            if (data.activityState != null) userBuilder.set("user_state", data.activityState.toString());
            if (data.landlinePhone != null) userBuilder.set("user_landlinePhone", data.landlinePhone);
            if (data.mobilePhone != null) userBuilder.set("user_mobilePhone", data.mobilePhone);
            if (data.occupation != null) userBuilder.set("user_occupation", data.occupation);
            if (data.workplace != null) userBuilder.set("user_workplace", data.workplace);
            if (data.address != null) userBuilder.set("user_address", data.address);
            if (data.additionalAddress != null) userBuilder.set("user_additionalAddress", data.additionalAddress);
            if (data.locality != null) userBuilder.set("user_locality", data.locality);
            if (data.postalCode != null) userBuilder.set("user_postalCode", data.postalCode);
            if (data.taxIdentificationNumber != null)
                userBuilder.set("user_taxIdentificationNumber", data.taxIdentificationNumber);
            if (data.photo != null) userBuilder.set("user_photo", data.photo);

            user = userBuilder.build();
            txn.add(user);
            LOG.info("User registered: " + data.username);
            txn.commit();
            return Response.ok("{}").build();

        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

}
