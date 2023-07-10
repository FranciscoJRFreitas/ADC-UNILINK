package pt.unl.fct.di.apdc.firstwebapp.resources;


import com.google.cloud.datastore.*;
import com.google.cloud.datastore.Transaction;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import com.google.firebase.database.*;
import com.google.firebase.internal.NonNull;
import com.google.gson.Gson;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;
import com.google.appengine.repackaged.org.apache.commons.codec.digest.DigestUtils;

import pt.unl.fct.di.apdc.firstwebapp.util.VerifyAction;

import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.logging.Logger;

import pt.unl.fct.di.apdc.firstwebapp.resources.ChatResources;


@Path("/remove")
public class RemoveResource {

    private final Datastore datastore = DatastoreOptions.newBuilder().setProjectId("unilink23").build().getService();
    private final Gson g = new Gson();
    private static final Logger LOG = Logger.getLogger(RegisterResource.class.getName());

    public RemoveResource() {
    }

    @DELETE
    @Path("/")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response deleteUser(@QueryParam("targetUsername") String targetUsername, @QueryParam("pwd") String password, @Context HttpHeaders headers) {

        String authTokenHeader = headers.getHeaderString("Authorization");
        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        Key userKey = datastore.newKeyFactory().setKind("User").newKey(token.username);
        Key tokenKey = datastore.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);

        Transaction txn = datastore.newTransaction();
        try {
            Entity user = txn.get(userKey);
            Entity originalToken = txn.get(tokenKey);

            if (user == null) {
                txn.rollback();
                return Response.status(Response.Status.BAD_REQUEST).entity("User not found: " + token.username).build();
            }

            if (originalToken == null) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("Login is required for this action!").build();
            }

            String storedPassword = user.getString("user_pwd");
            String providedPassword = DigestUtils.sha512Hex(password);

            if (!storedPassword.equals(providedPassword))
                return Response.status(Response.Status.UNAUTHORIZED).entity("Incorrect password! You need to verify your identity.").build();

            if (!token.tokenID.equals(originalToken.getString("user_tokenID")) && System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")) {
                txn.rollback();
                return Response.status(Response.Status.UNAUTHORIZED).entity("Session Expired.").build();
            }

            if (!targetUsername.isEmpty()) {

                Key targetUserKey = datastore.newKeyFactory().setKind("User").newKey(targetUsername);
                Entity targetUser = txn.get(targetUserKey);

                if (targetUser == null) {
                    txn.rollback();
                    return Response.status(Response.Status.BAD_REQUEST).entity("Target user not found: " + targetUsername).build();
                }

                String userRole = user.getString("user_role");
                String targetUserRole = targetUser.getString("user_role");
                if (!canDelete(userRole, targetUserRole))
                    return Response.status(Response.Status.UNAUTHORIZED).entity("You do not have the required permissions for this action.").build();

                txn.delete(targetUserKey, tokenKey);
                txn.commit();
                DatabaseReference groupsRef = FirebaseDatabase.getInstance().getReference("chat").child(targetUsername).child("Groups");
                DatabaseReference scheduleRef = FirebaseDatabase.getInstance().getReference("schedule");
                scheduleRef.child(targetUsername).removeValueAsync();

                groupsRef.addListenerForSingleValueEvent(new ValueEventListener() {
                    @Override
                    public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                        for (DataSnapshot childSnapshot : dataSnapshot.getChildren()) {
                            String childKey = childSnapshot.getKey();
                            ChatResources.leaveGroup(childKey, targetUsername);
                        }
                        DatabaseReference chatRef = FirebaseDatabase.getInstance().getReference("chat");
                        chatRef.child(targetUsername).removeValueAsync();

                        try {
                            UserRecord userRecord = FirebaseAuth.getInstance().getUserByEmail(targetUser.getString("user_email"));
                            String uid = userRecord.getUid();
                            DatabaseReference usersRef = FirebaseDatabase.getInstance().getReference("users");
                            usersRef.child(uid).removeValueAsync();
                            FirebaseAuth.getInstance().deleteUser(uid);
                        } catch (FirebaseAuthException e) {
                            throw new RuntimeException(e);
                        }
                    }

                    @Override
                    public void onCancelled(@NonNull DatabaseError databaseError) {
                        // Handle error
                    }

                });
                LOG.info("User deleted: " + targetUsername);
                return Response.ok("{}").build();
            }

            txn.delete(userKey, tokenKey);
            txn.commit();
            DatabaseReference chatRef = FirebaseDatabase.getInstance().getReference("chat").child(token.username).child("Groups");
            DatabaseReference scheduleRef = FirebaseDatabase.getInstance().getReference("schedule");
            scheduleRef.child(token.username).removeValueAsync();
            String email = user.getString("user_email");
            chatRef.addListenerForSingleValueEvent(new ValueEventListener() {
                @Override
                public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                    for (DataSnapshot childSnapshot : dataSnapshot.getChildren()) {
                        String childKey = childSnapshot.getKey();
                        ChatResources.leaveGroup(childKey, token.username);
                    }
                    DatabaseReference chatRef = FirebaseDatabase.getInstance().getReference("chat");
                    chatRef.child(token.username).removeValueAsync();

                    try {
                        UserRecord userRecord = FirebaseAuth.getInstance().getUserByEmail(user.getString("user_email"));
                        String uid = userRecord.getUid();
                        DatabaseReference usersRef = FirebaseDatabase.getInstance().getReference("users");
                        usersRef.child(uid).removeValueAsync();
                        FirebaseAuth.getInstance().deleteUser(uid);
                    } catch (FirebaseAuthException e) {
                        throw new RuntimeException(e);
                    }

                }

                @Override
                public void onCancelled(@NonNull DatabaseError databaseError) {
                    // Handle error
                }
            });
            LOG.info("User deleted: " + token.username);
            return Response.ok("{}").build();

        } finally {
            if (txn.isActive()) txn.rollback();
        }
    }

    private boolean canDelete(String userRole, String targetUserRole) {
        return VerifyAction.canExecute(userRole, targetUserRole, "remove_permissions");
    }

}