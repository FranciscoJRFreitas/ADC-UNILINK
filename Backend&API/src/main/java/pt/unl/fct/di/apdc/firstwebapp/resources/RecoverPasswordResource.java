/**
 * The RecoverPasswordResource class is a Java resource class that handles the password recovery
 * functionality for a web application.
 */
package pt.unl.fct.di.apdc.firstwebapp.resources;

import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import com.google.appengine.repackaged.org.apache.commons.codec.digest.DigestUtils;
import com.google.cloud.datastore.*;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import com.mailjet.client.ClientOptions;
import com.mailjet.client.MailjetClient;
import com.mailjet.client.MailjetRequest;
import com.mailjet.client.MailjetResponse;
import com.mailjet.client.resource.Emailv31;
import org.json.JSONArray;
import org.json.JSONObject;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.RecoverPwdHTMLLoader;
import pt.unl.fct.di.apdc.firstwebapp.util.UserActivityState;

import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.datastoreService;


@Path("/recoverPwd")
public class RecoverPasswordResource {
    private static final Logger LOG = Logger.getLogger(ActivationResource.class.getName());

    /**
     * The `recoverAccount` function in Java is used to recover a user's account by updating the
     * password reset token and sending a verification email.
     * 
     * @param username The `username` parameter is used to identify the user whose account needs to be
     * recovered. It can be either the username or the email address associated with the user's
     * account.
     * @return The method is returning a Response object. The response can have different status codes
     * and entities depending on the conditions in the code.
     */
    @POST
    @Path("/")
    public Response recoverAccount(@QueryParam("username") String username) {
        Query<Entity> queryByUsername = Query.newEntityQueryBuilder()
                .setKind("User")
                .setFilter(StructuredQuery.PropertyFilter.eq("user_username", username))
                .build();
        QueryResults<Entity> resultsByUsername = datastoreService.run(queryByUsername);

        Query<Entity> queryByEmail = Query.newEntityQueryBuilder()
                .setKind("User")
                .setFilter(StructuredQuery.PropertyFilter.eq("user_email", username))
                .build();
        QueryResults<Entity> resultsByEmail = datastoreService.run(queryByEmail);

        Entity user = null;
        if (resultsByUsername.hasNext())
            user = resultsByUsername.next();
        else if (resultsByEmail.hasNext())
            user = resultsByEmail.next();

        if (user == null) {
            return Response.status(Response.Status.NOT_FOUND).entity("User not found. Verify your username or email.").build();
        }

        if (user.getString("user_state").equals(UserActivityState.INACTIVE.toString())) {
            LOG.warning("No active account: " + username);
            return Response.status(Response.Status.EXPECTATION_FAILED).entity("Your account is still not active. Please verify your email inbox, before trying to recover the password.").build();
        }

        AuthToken token = new AuthToken(username);

        Entity newUser = Entity.newBuilder(user)
                .set("password_reset_token", token.tokenID)
                .build();

        Transaction txn = datastoreService.newTransaction();
        try {
            txn.update(newUser);
            txn.commit();
        } finally {
            if (txn.isActive()) txn.rollback();
        }

        sendVerificationEmail(newUser.getString("user_email"), newUser.getString("user_displayName"), token.tokenID);

        return Response.ok("{}").build();
    }

    /**
     * The function `sendVerificationEmail` sends a verification email with a password recovery link to
     * a specified email address.
     * 
     * @param email The email address of the recipient to whom the verification email will be sent.
     * @param name The name of the user who requested the password reset.
     * @param token The token is a unique identifier that is generated when a user requests a password
     * reset. It is used to verify the user's identity and allow them to reset their password.
     */
    private void sendVerificationEmail(String email, String name, String token) {
        String from = "fj.freitas@campus.fct.unl.pt";
        String fromName = "UniLink";
        String subject = "Account Recovery";
        String activationLink = "https://unilink23.oa.r.appspot.com/rest/recoverPwd?token=" + token;
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
                "    <h1 class='email-header'>Recover password!</h1>" +
                "    <p class='email-text'>Dear <b>" + name + "</b>,<br><br>" +
                "    You requested a password reset.</p>" +
                "    <p class='email-text'>To recover you account, please click the button below." +
                "    </p>" +

                "    <a target='_blank' href='" + activationLink + "' class='email-button'>Recover your account</a>" +
                "    <p class='email-text'>" +
                "        If the button above does not work, click the recovery link <a target='_blank' href='" + activationLink + "'>here</a>.<br><br>" +
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

    /**
     * This function is used to recover a user account by checking if a given password reset token
     * exists in the datastore and returning an appropriate response.
     * 
     * @param token The `token` parameter is a query parameter that is used to identify the user
     * account that needs to be recovered. It is passed as a string value in the URL query string.
     * @return The method is returning a Response object. If the query results have a next entity, it
     * returns a Response with the HTML response generated by the
     * `RecoverPwdHTMLLoader.loadHTML(token)` method. If the query results do not have a next entity,
     * it returns a Response with an HTML error message.
     */
    @GET
    @Path("/")
    public Response recoverUserAccount(@QueryParam("token") String token) {
        Query<Entity> query = Query.newEntityQueryBuilder()
                .setKind("User")
                .setFilter(StructuredQuery.PropertyFilter.eq("password_reset_token", token))
                .build();

        QueryResults<Entity> results = datastoreService.run(query);

        String htmlResponse;

        if (results.hasNext()) {
            htmlResponse = RecoverPwdHTMLLoader.loadHTML(token);
            return Response.ok(htmlResponse).type(MediaType.TEXT_HTML).build();
        } else {
            htmlResponse = "<!DOCTYPE html>" +
                    "<html lang='en'>" +
                    "<head>" +
                    "<meta charset='UTF-8'>" +
                    "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
                    "<title>Account Recovery Error</title>" +
                    "<style>" +
                    "body {" +
                    "    font-family: Arial, sans-serif;" +
                    "    text-align: center;" +
                    "    background-color: #f0f0f0;" +
                    "    display: flex;" +
                    "    justify-content: center;" +
                    "    align-items: center;" +
                    "    height: 100vh;" +
                    "    margin: 0;" +
                    "}" +
                    ".card {" +
                    "    background-color: #f3f3f3;" +
                    "    border-radius: 10px;" +
                    "    padding: 30px;" +
                    "    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);" +
                    "    width: 450px;" +
                    "    max-width: 500px;" +
                    "}" +
                    "h2 {" +
                    "    color: #2ABD5B;" +
                    "    font-size: 2.0em;" +
                    "    margin-bottom: 40px;" +
                    "}" +
                    "p {" +
                    "    line-height: 1.1;" +
                    "    font-family: \"Times New Roman\",serif;" +
                    "    font-size: 1.1em;" +
                    "}" +
                    "a {" +
                    "    color: #0080FF;" +
                    "}" +
                    "</style>" +
                    "</head>" +
                    "<body>" +
                    "<div class='card'>" +
                    "    <h2>There was an error while recovering your account!</h2>" +
                    "    <p>Please try again.</p>" +
                    "    <p>If the error persists,</p>" +
                    "    <p>please contact the support team.</p>" +
                    "</div>" +
                    "</body>" +
                    "</html>";

            return Response.status(Response.Status.NOT_FOUND).type(MediaType.TEXT_HTML).entity(htmlResponse).build();
        }
    }

    /**
     * The above function is a Java method that handles a POST request to reset a user's password,
     * updating the password in the database and redirecting the user to a login page.
     * 
     * @param token The "token" parameter is used to identify the user who is requesting a password
     * reset. It is typically generated and sent to the user's email when they initiate the password
     * reset process. The token serves as a temporary authentication mechanism to ensure that only the
     * user who requested the reset can actually reset their password
     * @param password The "password" parameter is the new password that the user wants to set for
     * their account.
     * @param confirmPassword The "confirmPassword" parameter is used to confirm the new password
     * entered by the user. It is used to ensure that the user has entered the correct password by
     * comparing it with the "password" parameter.
     * @return The method is returning a Response object with an HTML response. The HTML response
     * contains a message indicating that the password was reset successfully and provides a link to
     * the login page. The response is of type MediaType.TEXT_HTML.
     */
    @POST
    @Path("/resetPassword/")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    public Response resetPassword(@FormParam("token") String token, @FormParam("password") String password, @FormParam("confirmPassword") String confirmPassword) {
        Query<Entity> query = Query.newEntityQueryBuilder()
                .setKind("User")
                .setFilter(StructuredQuery.PropertyFilter.eq("password_reset_token", token))
                .build();

        QueryResults<Entity> results = datastoreService.run(query);

        Entity user = results.next();

        Entity newUser = Entity.newBuilder(user)
                .set("password_reset_token", "")
                .set("user_pwd", DigestUtils.sha512Hex(password))
                .build();

        String email = newUser.getString("user_email");

        try {
            FirebaseAuth firebaseAuth = FirebaseAuth.getInstance();

            UserRecord userRecord = firebaseAuth.getUserByEmail(email);

            UserRecord.UpdateRequest updateRequest = new UserRecord.UpdateRequest(userRecord.getUid())
                    .setPassword(password);
            firebaseAuth.updateUser(updateRequest);

            System.out.println("User password updated: " + email);
        } catch (FirebaseAuthException e) {
            e.printStackTrace();
        }

        Transaction txn = datastoreService.newTransaction();
        try {
            txn.update(newUser);
            txn.commit();
        } finally {
            if (txn.isActive()) txn.rollback();
        }

        String htmlResponse = "<!DOCTYPE html>" +
                "<html lang='en'>" +
                "<head>" +
                "<meta charset='UTF-8'>" +
                "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
                "<meta http-equiv='Refresh' content='5;url=https://unilink23.oa.r.appspot.com/'>" +
                "<title>Password Reset Successfully</title>" +
                "<style>" +
                "body {" +
                "    font-family: Arial, sans-serif;" +
                "    text-align: center;" +
                "    background-color: #f0f0f0;" +
                "    display: flex;" +
                "    justify-content: center;" +
                "    align-items: center;" +
                "    height: 100vh;" +
                "    margin: 0;" +
                "}" +
                ".card {" +
                "    background-color: #f3f3f3;" +
                "    border-radius: 10px;" +
                "    padding: 30px;" +
                "    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);" +
                "    width: 450px;" +
                "    max-width: 500px;" +
                "}" +
                "h2 {" +
                "    color: #2ABD5B;" +
                "    font-size: 2.0em;" +
                "    margin-bottom: 40px;" +
                "}" +
                "p {" +
                "    line-height: 1.1;" +
                "    font-family: \"Times New Roman\",serif;" +
                "    font-size: 1.1em;" +
                "}" +
                "a {" +
                "    color: #0080FF;" +
                "}" +
                "</style>" +
                "</head>" +
                "<body>" +
                "<div class='card'>" +
                "    <h2>Password was reset!</h2>" +
                "    <p>Thank you for your patience.</p>" +
                "<p>You will be redirected to login in 5 seconds.</p>" +
                "<p>If not, click <a href='https://unilink23.oa.r.appspot.com/'>here</a>.</p>" +
                "</div>" +
                "</body>" +
                "</html>";

        return Response.ok(htmlResponse).type(MediaType.TEXT_HTML).build();
    }

}



