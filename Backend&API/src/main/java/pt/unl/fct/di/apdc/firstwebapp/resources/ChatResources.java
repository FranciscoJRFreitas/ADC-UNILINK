package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.api.gax.paging.Page;
import com.google.cloud.datastore.*;
import com.google.cloud.datastore.Transaction;
import com.google.cloud.storage.*;
import com.google.cloud.storage.Blob;
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
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.ws.rs.core.Response.Status;

import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.datastoreService;
import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.firebaseInstance;


@Path("/chat")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class ChatResources {
    private final Gson g = new Gson();
    private static final Logger LOG = Logger.getLogger(ChatResources.class.getName());

    public ChatResources() {
    }

    /**
     * This function creates multiple groups and invites participants to each group.
     * 
     * @param groups A list of Group objects that contain information about the groups to be created.
     * @param headers The `headers` parameter is of type `HttpHeaders` and is used to access the HTTP
     * headers of the incoming request. It can be used to retrieve information such as authentication
     * tokens, content type, etc.
     * @return The method is returning a Response object with a status code of 200 (OK) and an empty
     * JSON object as the response body.
     */
    @POST
    @Path("/create-multiple")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createMultipleGroups(List<Group> groups, @Context HttpHeaders headers) {
        for (Group group : groups) {
            Response response = createGroup(group, headers);
            // no caso the algum grupo não tenha sucesso a ser criado
            if (response.getStatus() != Response.Status.OK.getStatusCode()) {
                return response;
            }
            //se teve sucesso a criar o grupo adicionar os participantes
            List<String> participants = group.participants;
            for (String participant : participants) {
                inviteToGroup(group.DisplayName, participant, headers);
            }
        }

        return Response.ok("{}").build();
    }


    /**
     * This function creates a new group in the database and checks if the group already exists before
     * creating it.
     * 
     * @param group The "group" parameter is an object of type Group, which contains information about
     * the group being created. It likely includes properties such as the group name, description, and
     * admin ID.
     * @param headers The `headers` parameter is used to access the HTTP headers of the incoming
     * request. It is of type `HttpHeaders` and can be used to retrieve information such as the content
     * type, authorization token, etc.
     * @return The method is returning a Response object.
     */
    @POST
    @Path("/create")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createGroup(Group group, @Context HttpHeaders headers) {
        Key userKey = datastoreService.newKeyFactory().setKind("User").newKey(group.adminID);
        Entity admin = datastoreService.get(userKey);
        if (admin == null) {
            return Response.status(Status.NOT_FOUND).entity("AdminId doesnt exist").build();
        }

        DatabaseReference chatsRef = firebaseInstance.getReference("groups");
        DatabaseReference newChatRef = chatsRef.push(); // Generate a unique ID for the new chat

        // Check if the group already exists
        newChatRef.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                if (!dataSnapshot.exists()) {
                    createNewGroup(group, newChatRef);
                }
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                // Handle any errors that occurred
            }
        });

        return Response.ok("{}").build();
    }

    /**
     * The function creates a new group chat, sets the necessary data for the group and its first
     * message, and updates the user's chat list with the new group.
     * 
     * @param group The "group" parameter is an object that contains information about the group being
     * created. It has the following properties:
     * @param newChatRef The DatabaseReference object that points to the location where the new
     * chat/group will be created in the Firebase Realtime Database.
     */
    private void createNewGroup(Group group, DatabaseReference newChatRef) {
        // Set the data for the new chat
        newChatRef.child("DisplayName").setValueAsync(group.DisplayName);
        newChatRef.child("description").setValueAsync(group.description);

        DatabaseReference membersRef = firebaseInstance.getReference("members").child(newChatRef.getKey());
        // When creating a group, the creator becomes the admin
        membersRef.child(group.adminID).setValueAsync(true); // Set the creator as a member

        DatabaseReference messagesRef = firebaseInstance.getReference("messages").child(newChatRef.getKey());
        DatabaseReference newMessageRef = messagesRef.push(); // Generate a unique ID for the new message

        // Set the data for the new message
        // When the group is created, put a welcome message in the group
        newMessageRef.child("containsFile").setValueAsync(false);
        newMessageRef.child("name").setValueAsync(group.adminID);
        newMessageRef.child("displayName").setValueAsync(group.adminID);
        newMessageRef.child("message").setValueAsync("Welcome to " + group.DisplayName + "!");
        newMessageRef.child("timestamp").setValueAsync(System.currentTimeMillis());
        newMessageRef.child("isSystemMessage").setValueAsync(true);
        newMessageRef.child("isEdited").setValueAsync(false);

        DatabaseReference chatsByUser = firebaseInstance.getReference("chat");
        DatabaseReference newChatsForUserRef = chatsByUser.child(group.adminID);

        Map<String, Object> groupsUpdates = new HashMap<>();
        groupsUpdates.put(newChatRef.getKey(), true);

        newChatsForUserRef.child("Groups").updateChildrenAsync(groupsUpdates);
    }


    /**
     * This function deletes a group and its associated data from a Firebase database.
     * 
     * @param groupId The groupId parameter is a String that represents the unique identifier of the
     * group that needs to be deleted.
     * @param headers The `headers` parameter is of type `HttpHeaders` and is used to retrieve
     * information from the HTTP request headers. It can be used to access headers such as
     * `Content-Type`, `Authorization`, etc.
     * @return The method is returning a Response object.
     */
    @DELETE
    @Path("/delete/{groupId}")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response deleteGroup(@PathParam("groupId") String groupId, @Context HttpHeaders headers) {
        DatabaseReference chatsRef = firebaseInstance.getReference("groups");
        DatabaseReference deletedChatRef = chatsRef.child(groupId);

        // Check if the group exists
        if (deletedChatRef == null) {
            return Response.status(Response.Status.NOT_FOUND).entity("Group not found.").build();
        }

        DatabaseReference membersRef = firebaseInstance.getReference("members").child(groupId);

        // Retrieve all members of the group
        membersRef.addValueEventListener(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                for (DataSnapshot memberSnapshot : dataSnapshot.getChildren()) {
                    String memberId = memberSnapshot.getKey();

                    DatabaseReference memberChatsRef = firebaseInstance.getReference("chat").child(memberId);
                    DatabaseReference memberGroupsRef = memberChatsRef.child("Groups");

                    // Remove the group from each member's chats
                    memberGroupsRef.child(groupId).removeValueAsync();
                }

                // Delete the group and its associated data
                DatabaseReference eventsRef = firebaseInstance.getReference("events");
                eventsRef.child(groupId).removeValueAsync();
                deletedChatRef.removeValueAsync();
                membersRef.removeValueAsync();
                DatabaseReference messagesRef = firebaseInstance.getReference("messages").child(groupId);
                messagesRef.removeValueAsync();
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                // Handle any errors
            }
        });

        return Response.ok("{}").build();
    }


    /**
     * The `inviteToGroup` function handles the invitation process for a user to join a group,
     * including authentication, checking token expiration, creating an invite token, and sending an
     * email invitation.
     * 
     * @param groupId The `groupId` parameter is a string that represents the ID of the group to which
     * the user is being invited.
     * @param userId The `userId` parameter is a string that represents the unique identifier of the
     * user to whom the invitation is being sent.
     * @param headers The `headers` parameter is of type `HttpHeaders` and is used to retrieve the
     * headers from the HTTP request.
     * @return The method is returning a Response object. The response can have different status codes
     * and entities depending on the conditions in the code.
     */
    @POST
    @Path("/invite")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response inviteToGroup(@QueryParam("groupId") String groupId, @QueryParam("userId") String userId, @Context HttpHeaders headers) {
        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        Key tokenKey = datastoreService.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);

        Entity originalToken = datastoreService.get(tokenKey);

        if (originalToken == null) {
            return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in").build();
        }

        if (!token.tokenID.equals(originalToken.getString("user_tokenID")) || System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")) {
            return Response.status(Response.Status.UNAUTHORIZED).entity("Session Expired.").build();
        }

        Key userKey = datastoreService.newKeyFactory().setKind("User").newKey(userId);
        Entity user = datastoreService.get(userKey);

        if (user == null) {
            return Response.status(Status.NOT_FOUND).entity("User not found.").build();
        }

        InviteToken Invtoken = new InviteToken(userId, groupId);
        Transaction txn = datastoreService.newTransaction();
        try {
            Key invtokenKey = datastoreService.newKeyFactory().setKind("InviteToken").newKey(Invtoken.tokenID);
            Entity invtoken = Entity.newBuilder(invtokenKey)
                    .set("user", Invtoken.username)
                    .set("groupId", Invtoken.groupId)
                    .build();
            txn.put(invtoken);
            txn.commit();
            String userEmail = user.getString("user_email");
            String userDisplayName = user.getString("user_displayName");
            String invitedByDispName = datastoreService.get(datastoreService.newKeyFactory().setKind("User").newKey(token.username)).getString("user_displayName");

            sendInviteEmail(groupId, userDisplayName, userEmail, userId, Invtoken.tokenID, invitedByDispName);

            return Response.ok().build();
        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    /**
     * The function allows a user to join a group by using an invite token and updates the database
     * accordingly.
     * 
     * @param token The "token" parameter is a string that represents an invite token. It is used to
     * identify and validate the invitation to join a group.
     * @return The method is returning a Response object. If the invtoken is null, it returns a
     * Response with status code 403 (FORBIDDEN). If the invtoken is not null, it performs some
     * operations and returns a Response with status code 200 (OK).
     */
    @GET
    @Path("/join")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response joinGroup(@QueryParam("token") String token) {
        Transaction txn = datastoreService.newTransaction();
        try {
            Key tokenkey = datastoreService.newKeyFactory().setKind("InviteToken").newKey(token);
            Entity invtoken = txn.get(tokenkey);
            if (invtoken == null) {
                return Response.status(Status.FORBIDDEN).build();
            }
            String group = invtoken.getString("groupId");
            String user = invtoken.getString("user");

            DatabaseReference membersRef = firebaseInstance.getReference("members").child(group);
            membersRef.child(user).setValueAsync(false);
            DatabaseReference chatRef = firebaseInstance.getReference("chat").child(user).child("Groups");
            chatRef.child(group).setValueAsync(true);

            txn.delete(tokenkey);
            txn.commit();
            return Response.ok().build();
        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    /**
     * This Java function handles a POST request to leave a group, checking authentication, removing
     * the user from the group, and deleting the group if there are no more members.
     * 
     * @param groupId The `groupId` parameter is a string that represents the ID of the group from
     * which the user wants to leave.
     * @param userId The `userId` parameter is a string that represents the unique identifier of the
     * user who wants to leave the group.
     * @param headers The `headers` parameter is of type `HttpHeaders` and is used to access the HTTP
     * headers of the request.
     * @return The method is returning a Response object.
     */
    @POST
    @Path("/leave")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response laeveGroup(@QueryParam("groupId") String groupId, @QueryParam("userId") String userId, @Context HttpHeaders headers) {
        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        Key tokenKey = datastoreService.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);

        Entity originalToken = datastoreService.get(tokenKey);

        if (originalToken == null) {
            return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in").build();
        }

        if (!token.tokenID.equals(originalToken.getString("user_tokenID")) || System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")) {
            return Response.status(Response.Status.UNAUTHORIZED).entity("Session Expired.").build();
        }

        DatabaseReference membersRef = firebaseInstance.getReference("members").child(groupId);
        membersRef.child(userId).removeValueAsync();
        DatabaseReference chatRef = firebaseInstance.getReference("chat").child(userId).child("Groups");
        chatRef.child(groupId).removeValueAsync();
        membersRef.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                if (!dataSnapshot.exists()) {
                    DatabaseReference groupsRef = firebaseInstance.getReference("groups");
                    groupsRef.child(groupId).removeValueAsync();
                    DatabaseReference messagesRef = firebaseInstance.getReference("messages");
                    messagesRef.child(groupId).removeValueAsync();
                }
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
            }
        });


        return Response.ok().build();
    }

    /**
     * The function deletes all blobs (files) in a specified folder in a Google Cloud Storage bucket.
     * 
     * @param folderPath The folderPath parameter is a string that represents the path of the folder
     * you want to delete. It should be the relative path of the folder within the bucket. For example,
     * if the folder you want to delete is located at the root of the bucket, the folderPath would be
     * an empty string ("
     */
    public static void deleteFolder(String folderPath) {
        Storage storage = StorageOptions.getDefaultInstance().getService();
        String bucketName = "unilink23.appspot.com";
        Bucket bucket = storage.get(bucketName);

        // List the blobs in the folder
        Page<Blob> blobs = bucket.list(Storage.BlobListOption.prefix(folderPath));
        for (Blob blob : blobs.iterateAll()) {
            blob.delete();
            System.out.println("Deleted blob: " + blob.getName());
        }
    }

    /**
     * The function `leaveGroup` removes a user from a group, deletes the group if it no longer exists,
     * and deletes associated messages and folders.
     * 
     * @param groupId The unique identifier of the group that the user wants to leave.
     * @param userId The userId parameter represents the unique identifier of the user who wants to
     * leave the group.
     */
    public static void leaveGroup(String groupId, String userId) {
        DatabaseReference membersRef = firebaseInstance.getReference("members").child(groupId);
        membersRef.child(userId).removeValueAsync();
        DatabaseReference chatRef = firebaseInstance.getReference("chat").child(userId).child("Groups");
        chatRef.child(groupId).removeValueAsync();

        DatabaseReference groupsRef = firebaseInstance.getReference("groups");
        DatabaseReference messagesRef = firebaseInstance.getReference("messages");
        //DatabaseReference eventsRef = firebaseInstance.getReference("events");
        //eventsRef.child(groupId).removeValueAsync();

        groupsRef.child(groupId).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                if (!dataSnapshot.exists()) {
                    String groupPicturesPath = "GroupPictures/" + groupId;
                    String groupAttachmentsPath = "GroupAttachments/" + groupId;

                    messagesRef.child(groupId).removeValueAsync();
                    groupsRef.child(groupId).removeValueAsync();

                    LOG.info("Deleting folder: " + groupPicturesPath);
                    deleteFolder(groupPicturesPath);

                    LOG.info("Deleting folder: " + groupAttachmentsPath);
                    deleteFolder(groupAttachmentsPath);
                }
            }

            @Override
            public void onCancelled(DatabaseError databaseError) {
                Logger.getLogger("LeaveGroup").severe("Error: " + databaseError.getMessage());
            }
        });
    }

    /**
     * The function `sendInviteEmail` sends an invitation email to a user to join a group, including
     * the group's display name and a link to accept the invitation.
     * 
     * @param groupId The ID of the group for which the invitation is being sent.
     * @param userDisplayName The display name of the user who will receive the invitation email.
     * @param email The email address of the user to whom the invitation email will be sent.
     * @param userId The `userId` parameter is the unique identifier of the user who is being invited
     * to join the group.
     * @param token The token is a unique identifier that is generated for each invitation. It is used
     * to verify the authenticity of the invitation when the recipient accepts it.
     * @param invitedBy The name of the user who is sending the invitation.
     */
    private void sendInviteEmail(String groupId, String userDisplayName, String email, String userId, String token, String invitedBy) {

        // Retrieve displayName and description from Realtime Database
        DatabaseReference groupRef = firebaseInstance.getReference("groups").child(groupId);
        groupRef.addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(DataSnapshot dataSnapshot) {
                if (dataSnapshot.exists()) {
                    String groupDisplayName = dataSnapshot.child("DisplayName").getValue(String.class);

                    Map<String, Object> inviteData = new HashMap<>();
                    inviteData.put("inviteToken", token);
                    inviteData.put("groupName", groupDisplayName);
                    inviteData.put("invitedBy", invitedBy);

                    DatabaseReference invitesRef = firebaseInstance.getReference("invites").child(groupId).child(userId);
                    invitesRef.updateChildrenAsync(inviteData);

                    // Update the email content with displayName and description
                    String from = "fj.freitas@campus.fct.unl.pt";
                    String fromName = "UniLink";
                    String subject = "Invited for a group!";
                    String invitationLink = "https://unilink23.oa.r.appspot.com/rest/chat/join?token=" + token;
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
                            ".email-text a{" +
                            "      font-size: 1em;" +
                            "      color: #005890;" +
                            "      margin: 20px 0;" +
                            "      text-align: left;" +
                            "    }" +
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
                            "    <p class='email-text'>Dear " + userDisplayName + ",<br><br>" +
                            "    You have received an invitation to join " + groupDisplayName + ".</p>" +
                            "    <p class='email-text'>To accept the invitation to join this group, please click the button below.</p>" +
                            "    <a target='_blank' href='" + invitationLink + "' class='email-button'>Accept Invitation</a>" +
                            "    <p class='email-text'>" +
                            "        If the button above does not work, you can copy and paste the following link directly into your browser:<br>" +
                            "        <a target='_blank' href='" + invitationLink + "'>" + invitationLink + "</a><br><br>" +
                            "        Best regards,<br>" +
                            "        UniLink" +
                            "    </p>" +
                            "</div>" +
                            "</body>" +
                            "</html>";

                    // Send email
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
                } else {
                    // Handle error: group node does not exist
                    LOG.warning("Group node does not exist in the database.");
                }
            }

            @Override
            public void onCancelled(DatabaseError error) {
                // Handle error: read operation canceled
                LOG.severe("Error reading group information from the database: " + error.getMessage());
            }
        });
    }


}