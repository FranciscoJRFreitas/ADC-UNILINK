package pt.unl.fct.di.apdc.firstwebapp.resources;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.*;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.io.*;
import java.util.logging.Logger;
import java.io.FileInputStream;


@Path("/chat")
@Produces(MediaType.APPLICATION_JSON + ";charset=utf-8")
public class ChatResources {

    private final Gson g = new Gson();
    private static final Logger LOG = Logger.getLogger(ChatResources.class.getName());

    public ChatResources() {
    }

    @POST
    @Path("/create")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response createGroup(Group group) throws IOException{

        initialize();
        LOG.severe("Initialized");
        DatabaseReference chatsRef = FirebaseDatabase.getInstance().getReference("chats");
        DatabaseReference newChatRef = chatsRef.push(); // Generate a unique ID for the new chat
        LOG.severe("chatsRefCreated");
        // Set the data for the new chat
        newChatRef.child("groupID").setValueAsync(newChatRef.getKey());
        newChatRef.child("DisplayName").setValueAsync(group.DisplayName);
        newChatRef.child("description").setValueAsync(group.description);
        LOG.severe("chatsRefCreated not null");
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

    public void initialize() throws IOException {

        LOG.severe("initializing...");
        FileInputStream serviceAccount =
                new FileInputStream("Backend&API/src/main/java/pt/unl/fct/di/apdc/firstwebapp/resources/unilink23-firebase-adminsdk-a3nn3-d8beef1a33.json");
        LOG.severe("initializing... 2");
        LOG.severe(serviceAccount.toString());
        FirebaseOptions options = new FirebaseOptions.Builder()
                .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                .setDatabaseUrl("https://unilink23-default-rtdb.europe-west1.firebasedatabase.app")
                .build();
        LOG.severe("initializing... !!");
        FirebaseApp.initializeApp(options);
    }
}