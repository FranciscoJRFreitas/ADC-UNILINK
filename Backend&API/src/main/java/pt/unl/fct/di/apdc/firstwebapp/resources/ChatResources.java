package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.cloud.datastore.Transaction;
import com.google.firebase.database.*;
import com.google.gson.Gson;
import com.mailjet.client.ClientOptions;
import com.mailjet.client.MailjetClient;
import com.mailjet.client.MailjetRequest;
import com.mailjet.client.MailjetResponse;
import com.mailjet.client.resource.Emailv31;
import org.json.JSONArray;
import org.json.JSONObject;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.Group;
import pt.unl.fct.di.apdc.firstwebapp.util.InviteToken;

import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ws.rs.core.Response.Status;

@Path("/chat")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class ChatResources {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink23").build().getService();

    private final Gson g = new Gson();
    private static final Logger LOG = Logger.getLogger(ChatResources.class.getName());

    public ChatResources() {
    }

    @POST
    @Path("/create")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createGroup(Group group, @Context HttpHeaders headers) {

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
//        DatabaseReference groupForUser = FirebaseDatabase.getInstance().getReference("users");
//        DatabaseReference userRef = groupForUser.child(group.adminID);
//        DatabaseReference groupRef = userRef.child("Groups");

        DatabaseReference chatsRef = FirebaseDatabase.getInstance().getReference("groups");
        DatabaseReference newChatRef = chatsRef.child(group.DisplayName); // Generate a unique ID for the new chat

        // Set the data for the new chat
        newChatRef.child("DisplayName").setValueAsync(group.DisplayName);
        newChatRef.child("description").setValueAsync(group.description);

        DatabaseReference membersRef = FirebaseDatabase.getInstance().getReference("members").child(newChatRef.getKey());
        //when creating a group the creater becomes the admin
        membersRef.child(group.adminID).setValueAsync(true); // Set the creator as a member

        DatabaseReference messagesRef = FirebaseDatabase.getInstance().getReference("messages").child(newChatRef.getKey());
        DatabaseReference newMessageRef = messagesRef.push(); // Generate a unique ID for the new message

        // Set the data for the new message
        //when the group is created put a welcome message in the group
        newMessageRef.child("type").setValueAsync("system");
        newMessageRef.child("name").setValueAsync(group.adminID);
        newMessageRef.child("message").setValueAsync("Welcome to " + group.DisplayName + "!");
        newMessageRef.child("timestamp").setValueAsync(System.currentTimeMillis());

        DatabaseReference chatsByUser = FirebaseDatabase.getInstance().getReference("chat");
        DatabaseReference newChatsForUserRef = chatsByUser.child(token.username);

        Map<String, Object> groupsUpdates = new HashMap<>();
        groupsUpdates.put(group.DisplayName, true);

        newChatsForUserRef.child("Groups").updateChildrenAsync(groupsUpdates);

        return Response.ok("{}").build();
    }

    @POST
    @Path("/invite")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response inviteToGroup(@QueryParam("groupId") String groupId, @QueryParam("userId") String userId, @Context HttpHeaders headers) {
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

        Key userKey = datastore.newKeyFactory().setKind("User").newKey(userId);
        Entity user = datastore.get(userKey);

        if(user == null){
            return Response.status(Status.NOT_FOUND).entity("User not found.").build();
        }

        InviteToken Invtoken = new InviteToken(userId, groupId);
        Transaction txn = datastore.newTransaction();
        try {
            Key invtokenKey = datastore.newKeyFactory().setKind("InviteToken").newKey(Invtoken.tokenID);
            Entity invtoken = Entity.newBuilder(invtokenKey)
                    .set("user", Invtoken.username)
                    .set("groupId", Invtoken.groupId)
                    .build();
            txn.put(invtoken);
            txn.commit();
            String userEmail = user.getString("user_email");

            sendInviteEmail(userEmail, Invtoken.tokenID);

            return Response.ok().build();
        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    @GET
    @Path("/join")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response joinGroup(@QueryParam("token") String token) {
        Transaction txn = datastore.newTransaction();
        try {
            Key tokenkey = datastore.newKeyFactory().setKind("InviteToken").newKey(token);
            Entity invtoken = txn.get(tokenkey);
            if (invtoken == null) {
                return Response.status(Status.FORBIDDEN).build();
            }
            String group = invtoken.getString("groupId");
            String user = invtoken.getString("user");

            DatabaseReference membersRef = FirebaseDatabase.getInstance().getReference("members").child(group);
            membersRef.child(user).setValueAsync(false);
            DatabaseReference chatRef = FirebaseDatabase.getInstance().getReference("chat").child(user).child("Groups");
            chatRef.child(group).setValueAsync(true);

            txn.delete(tokenkey);
            txn.commit();
            return Response.ok().build();
        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    @POST
    @Path("/leave")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response laeveGroup(@QueryParam("groupId") String groupId, @QueryParam("userId") String userId, @Context HttpHeaders headers) {
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

        DatabaseReference membersRef = FirebaseDatabase.getInstance().getReference("members").child(groupId);
        membersRef.child(userId).removeValueAsync();
        DatabaseReference chatRef = FirebaseDatabase.getInstance().getReference("chat").child(userId).child("Groups");
        chatRef.child(groupId).removeValueAsync();
        membersRef.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                if (!dataSnapshot.exists()) {
                    DatabaseReference groupsRef = FirebaseDatabase.getInstance().getReference("groups");
                    groupsRef.child(groupId).removeValueAsync();
                    DatabaseReference messagesRef = FirebaseDatabase.getInstance().getReference("messages");
                    messagesRef.child(groupId).removeValueAsync();
                }
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
            }
        });


        return Response.ok().build();
    }

    public static void leaveGroup(String groupId, String userId) {
        DatabaseReference membersRef = FirebaseDatabase.getInstance().getReference("members").child(groupId);
        membersRef.child(userId).removeValueAsync();
        DatabaseReference chatRef = FirebaseDatabase.getInstance().getReference("chat").child(userId).child("Groups");
        chatRef.child(groupId).removeValueAsync();
        membersRef.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                if (!dataSnapshot.exists()) {
                    DatabaseReference groupsRef = FirebaseDatabase.getInstance().getReference("groups");
                    groupsRef.child(groupId).removeValueAsync();
                    DatabaseReference messagesRef = FirebaseDatabase.getInstance().getReference("messages");
                    messagesRef.child(groupId).removeValueAsync();
                }
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
            }
        });
    }


    private void sendInviteEmail(String email, String Token) {
        String from = "fj.freitas@campus.fct.unl.pt";
        String fromName = "UniLink";
        String subject = "You received an invite";
        String invitationLink = "https://unilink23.oa.r.appspot.com/rest/chat/join?token=" + Token;
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
                "    <h1 class='email-header'>You received an invitation!</h1>" +
                "    <p class='email-text'>Dear User,<br><br>" +
                "    You have received an invitation to join a group.</p>" +
                "    <p class='email-text'>To accept the invitation, please click the button below.</p>" +
                "    <a target='_blank' href='" + invitationLink + "' class='email-button'>Accept Invitation</a>" +
                "    <p class='email-text'>" +
                "        If the button above does not work, you can copy and paste the following link into your browser:<br>" +
                "        <a target='_blank' href='" + invitationLink + "'>" + invitationLink + "</a><br><br>" +
                "        Best regards,<br>" +
                "        Sender" +
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
                                    .put(Emailv31.Message.CUSTOMID, "Invite")));

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