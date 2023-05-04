package pt.unl.fct.di.apdc.firstwebapp.resources;

import java.util.logging.Logger;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import java.util.concurrent.Executors;


import com.google.appengine.repackaged.org.apache.commons.codec.digest.DigestUtils;
import com.google.cloud.Timestamp;
import com.google.cloud.datastore.*;

import pt.unl.fct.di.apdc.firstwebapp.util.RegisterData;
import pt.unl.fct.di.apdc.firstwebapp.util.UserActivityState;
import pt.unl.fct.di.apdc.firstwebapp.util.UserProfileVisibility;
import pt.unl.fct.di.apdc.firstwebapp.util.UserRole;
import java.util.UUID;
import javax.mail.*;
import javax.mail.internet.*;
import java.util.Properties;


@Path("/register")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class RegisterResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink2023").build().getService();
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

            String token = UUID.randomUUID().toString();

            // Set mandatory fields
            Entity.Builder userBuilder = Entity.newBuilder(userKey)
                    .set("user_displayName", data.displayName)
                    .set("user_username", data.username)
                    .set("user_email", data.email)
                    .set("user_pwd", DigestUtils.sha512Hex(data.password))
                    .set("user_role", UserRole.STUDENT.toString())
                    .set("user_creation_time", Timestamp.now())
                    .set("user_profileVisibility", UserProfileVisibility.PUBLIC.toString())
                    .set("user_state", UserActivityState.INACTIVE.toString())
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

            Executors.newCachedThreadPool().submit(() -> sendVerificationEmail(data.email, token));

            return Response.ok("{}").build();

        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    private void sendVerificationEmail(String email, String token) {
        String from = "unilink2023test@gmail.com";
        String subject = "Account Activation";
        String activationLink = "https://localhost:8080/rest/activate?token=" + token;

        String content = "Please click the following link to activate your account: <a href='" + activationLink + "'>Activate your account</a>";

        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com"); // SMTP server for Gmail
        props.put("mail.smtp.port", "587"); // Port for TLS/STARTTLS
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");


        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(from, "UniTest2023?");
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(email));
            message.setSubject(subject);
            message.setContent(content, "text/html");
            Transport.send(message);
        } catch (MessagingException e) {
            throw new RuntimeException(e);
        }
    }


}
