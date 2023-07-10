package pt.unl.fct.di.apdc.firstwebapp.resources;

import java.util.logging.Logger;
import javax.ws.rs.*;

import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

import com.google.cloud.datastore.*;
import pt.unl.fct.di.apdc.firstwebapp.util.UserActivityState;


@Path("/activate")
public class ActivationResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink23").build().getService();
    private static final Logger LOG = Logger.getLogger(ActivationResource.class.getName());

    @GET
    @Path("/")
    public Response activateAccount(@QueryParam("token") String token) {
        Query<Entity> query = Query.newEntityQueryBuilder()
                .setKind("User")
                .setFilter(StructuredQuery.PropertyFilter.eq("user_activation_token", token))
                .build();

        QueryResults<Entity> results = datastore.run(query);

        String htmlResponse;

        if (results.hasNext()) {
            Entity user = results.next();
            Entity newUser = Entity.newBuilder(user)
                    .set("user_state", UserActivityState.ACTIVE.toString())
                    .set("user_activation_token", "")
                    .build();

            Transaction txn = datastore.newTransaction();
            try {
                txn.update(newUser);
                txn.commit();
            } finally {
                if (txn.isActive()) txn.rollback();
            }

            htmlResponse = "<!DOCTYPE html>" +
                    "<html lang='en'>" +
                    "<head>" +
                    "<meta charset='UTF-8'>" +
                    "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
                    "<meta http-equiv='Refresh' content='5;url=https://unilink23.oa.r.appspot.com/'>" +
                    "<title>Account Activation</title>" +
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
                    "<h2>Account activated successfully!</h2>" +
                    "<p>You will be redirected to login in 5 seconds.</p>" +
                    "<p>If not, click <a href='https://unilink23.oa.r.appspot.com/'>here</a>.</p>" +
                    "</div>" +
                    "</body></html>";

            return Response.ok(htmlResponse).type(MediaType.TEXT_HTML).build();

        } else {

            htmlResponse = "<!DOCTYPE html>" +
                    "<html lang='en'>" +
                    "<head>" +
                    "<meta charset='UTF-8'>" +
                    "<meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
                    "<title>Account Activation</title>" +
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
                    "    <h2>Account already active!</h2>" +
                    "    <p>To proceed with login, click <a href='https://unilink23.oa.r.appspot.com/'>here</a>.</p>" +
                    "    <p>If this is the first time you click the activation link,</p>" +
                    "    <p>please contact the support team.</p>" +
                    "</div>" +
                    "</body>" +
                    "</html>";

            return Response.status(Status.NOT_FOUND).type(MediaType.TEXT_HTML).entity(htmlResponse).build();
        }
    }

}

