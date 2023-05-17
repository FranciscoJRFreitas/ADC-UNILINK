package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.cloud.datastore.*;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import pt.unl.fct.di.apdc.firstwebapp.util.Group;

import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.io.IOException;
import java.util.logging.Logger;

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
    public Response createGroup(Group group, @Context HttpHeaders headers) throws IOException {

        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);

        Entity originalToken = datastore.get(tokenKey);

        if(originalToken == null) {
            return Response.status(Response.Status.UNAUTHORIZED).entity("User not logged in").build();
        }

        if (!token.tokenID.equals(originalToken.getString("user_tokenID")) || System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")){
            return Response.status(Response.Status.UNAUTHORIZED).entity("Session Expired.").build();
        }
//        DatabaseReference groupForUser = FirebaseDatabase.getInstance().getReference("users");
//        DatabaseReference userRef = groupForUser.child(group.adminID);
//        DatabaseReference groupRef = userRef.child("Groups");

        DatabaseReference chatsRef = FirebaseDatabase.getInstance().getReference("chats");
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
        newMessageRef.child("name").setValueAsync(group.adminID);
        newMessageRef.child("message").setValueAsync("Welcome to " + group.DisplayName + "!");
        newMessageRef.child("timestamp").setValueAsync(System.currentTimeMillis());

        return Response.ok("{}").build();
    }

}