package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.appengine.repackaged.org.apache.commons.codec.digest.DigestUtils;
import com.google.cloud.Timestamp;
import com.google.cloud.datastore.*;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.mailjet.client.ClientOptions;
import com.mailjet.client.MailjetClient;
import com.mailjet.client.MailjetRequest;
import com.mailjet.client.MailjetResponse;
import com.mailjet.client.resource.Emailv31;
import org.json.JSONArray;
import org.json.JSONObject;
import pt.unl.fct.di.apdc.firstwebapp.util.*;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

@Path("/register")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class RegisterResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink23").build().getService();
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
                return Response.status(Status.CONFLICT).entity("Username already exists.").build();
            }

            Query<Entity> queryByEmail = Query.newEntityQueryBuilder()
                    .setKind("User")
                    .setFilter(StructuredQuery.PropertyFilter.eq("user_email", data.email))
                    .build();
            QueryResults<Entity> resultsByEmail = datastore.run(queryByEmail);

            if (resultsByEmail.hasNext()) {
                txn.rollback();
                return Response.status(Status.CONFLICT).entity("This email is already being used.").build();
            }

            if (data.activityState == null)
                data.activityState = UserActivityState.INACTIVE;

            String token = data.activityState.equals(UserActivityState.ACTIVE) ? "" : UUID.randomUUID().toString();
            if (!token.isEmpty()) {
                sendVerificationEmail(data.email, data.displayName, token);
            }

            // Set mandatory fields
            Entity.Builder userBuilder = Entity.newBuilder(userKey)
                    .set("user_displayName", data.displayName)
                    .set("user_username", data.username)
                    .set("user_email", data.email)
                    .set("user_pwd", DigestUtils.sha512Hex(data.password))
                    .set("user_role", data.role == null ? UserRole.STUDENT.toString() : data.role.toString())
                    .set("user_creation_time", Timestamp.now())
                    .set("user_educationLevel", data.educationLevel == null ? "" : UserEducationLevel.PE.toString())
                    .set("user_birthDate", data.birthDate == null ? "" : data.birthDate)
                    .set("user_profileVisibility", data.profileVisibility == null ? UserProfileVisibility.PUBLIC.toString() : data.profileVisibility.toString())
                    .set("user_state", data.activityState == null ? UserActivityState.INACTIVE.toString() : data.activityState.toString())
                    .set("user_activation_token", token)
                    .set("user_landlinePhone", data.landlinePhone == null ? "" : data.landlinePhone)
                    .set("user_mobilePhone", data.mobilePhone == null ? "" : data.mobilePhone)
                    .set("user_occupation", data.occupation == null ? "" : data.occupation)
                    .set("user_workplace", data.workplace == null ? "" : data.workplace)
                    .set("user_address", data.address == null ? "" : data.address)
                    .set("user_additionalAddress", data.additionalAddress == null ? "" : data.additionalAddress)
                    .set("user_locality", data.locality == null ? "" : data.locality)
                    .set("user_postalCode", data.postalCode == null ? "" : data.postalCode)
                    .set("user_taxIdentificationNumber", data.taxIdentificationNumber == null ? "" : data.taxIdentificationNumber)
                    .set("user_photo", data.photo == null ? "" : data.photo);


            user = userBuilder.build();
            txn.add(user);
            LOG.info("User registered: " + data.username);
            txn.commit();
            initConversations(data.username);

            FirebaseAuth firebaseAuth = FirebaseAuth.getInstance();
            UserRecord.CreateRequest request = new UserRecord.CreateRequest()
                    .setEmail(data.email)
                    .setPassword(data.password);

            UserRecord userRecord = firebaseAuth.createUser(request);
            String uid = userRecord.getUid();

            // Save the UID in the "users" node
            DatabaseReference usersRef = FirebaseDatabase.getInstance().getReference("users");
            usersRef.child(uid).setValueAsync(false);

            System.out.println("New user created: " + uid);

        } catch (FirebaseAuthException e) {
            System.err.println("Error creating user: " + e.getMessage());
        } finally {
            if (txn.isActive()) txn.rollback();
        }
        return Response.ok("{}").build();
    }
        private void initConversations (String username){
            LOG.severe("Inserting data");
            DatabaseReference chatsByUser = FirebaseDatabase.getInstance().getReference("chat");
            DatabaseReference newChatsForUserRef = chatsByUser.child(username); // Generate a unique ID for the new chat
            // Set the data for the new chat
            newChatsForUserRef.child("DM").setValueAsync("DM");
            newChatsForUserRef.child("Groups").setValueAsync("Groups");
            LOG.severe("Inserting data finished");

        }
        private void sendVerificationEmail (String email, String name, String token){
            String from = "fj.freitas@campus.fct.unl.pt";
            String fromName = "UniLink";
            String subject = "Account Activation";
            String activationLink = "https://unilink23.oa.r.appspot.com/rest/activate?token=" + token;
            String htmlContent = "<!DOCTYPE html>" +
                    "<html>" +
                    "<head>" +
                    "<meta charset='utf-8'>" +
                    "<style>" +
                    ".email-container {" +
                    "    font-family: Arial, sans-serif;" +
                    "    max-width: 600px;" +
                    "    margin: auto;" +
                    "    padding: 20px;" +
                    "    background-color: #ffffff;" +
                    "    border: 1px solid #cccccc;" +
                    "    border-radius: 5px;" +
                    "    text-align: center;" +
                    "}" +
                    ".email-container a {" +
                    "    color: #ffffff;" +
                    "}" +
                    ".email-header {" +
                    "    font-size: 1.5em;" +
                    "    font-weight: bold;" +
                    "    color: #333333;" +
                    "}" +
                    ".email-text {" +
                    "    font-size: 1em;" +
                    "    color: #666666;" +
                    "    margin: 20px 0;" +
                    "    text-align: left;" +
                    "}" +
                    ".email-button {" +
                    "    display: inline-block;" +
                    "    font-size: 1em;" +
                    "    font-weight: bold;" +
                    "    color: #f5f5f5;" +
                    "    background-color: #005890;" +
                    "    border-radius: 5px;" +
                    "    padding: 10px 20px;" +
                    "    text-decoration: none;" +
                    "}" +
                    "</style>" +
                    "</head>" +
                    "<body>" +
                    "<div class='email-container'>" +
                    "    <h1 class='email-header'>Welcome to UniLink!</h1>" +
                    "    <p class='email-text'>Dear <b>" + name + "</b>,<br><br>" +
                    "    Thank you for registering with UniLink! </p>" +
                    "    <p class='email-text'>To complete your registration and activate your account, please click the button below." +
                    "    </p>" +

                    "    <a target='_blank' href='" + activationLink + "' class='email-button'>Activate your account</a>" +
                    "    <p class='email-text'>" +
                    "        If the button above does not work, click the activation link <a target='_blank' href='" + activationLink + "'>here</a>.<br><br>" +
                    "        Best regards,<br>" +
                    "        The UniLink Team" +
                    "    </p>" +
                    "</div>" +
                    "</body>" +
                    "</html>";


            MailjetClient client = new MailjetClient("70ea7f6979407b8ba663b6cc22c9a998", "8894516f42fe5ce16edb28200c6e230b", new ClientOptions("v3.1"));
            MailjetRequest request;
            MailjetResponse response;

            try {
                request = new MailjetRequest(Emailv31.resource)
                        .property(Emailv31.MESSAGES, new JSONArray()
                                .put(new JSONObject()
                                        .put(Emailv31.Message.FROM, new JSONObject()
                                                .put("Email", from)
                                                .put("Name", fromName))
                                        .put(Emailv31.Message.TO, new JSONArray()
                                                .put(new JSONObject()
                                                        .put("Email", email)))
                                        .put(Emailv31.Message.SUBJECT, subject)
                                        .put(Emailv31.Message.HTMLPART, htmlContent)
                                        .put(Emailv31.Message.CUSTOMID, "AccountActivation")));

                response = client.post(request);

                if (response.getStatus() != 200) {
                    throw new RuntimeException("Failed to send email. Status: " + response.getStatus());
                }
                LOG.info("Email sent.");
            } catch (Exception e) {
                LOG.log(Level.SEVERE, "Error sending email", e);
                throw new RuntimeException(e);
            }
        }

    }
