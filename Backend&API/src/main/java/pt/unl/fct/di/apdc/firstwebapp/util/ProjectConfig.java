package pt.unl.fct.di.apdc.firstwebapp.util;

import com.google.cloud.datastore.Datastore;
import com.google.cloud.datastore.DatastoreOptions;
import com.google.firebase.database.FirebaseDatabase;
import com.google.gson.Gson;

public class ProjectConfig {
    public static final String projectId = "unilink23";
    public static final Datastore datastoreService = DatastoreOptions.newBuilder().setProjectId(projectId).build().getService();
    public static final Gson g = new Gson();
    public static final FirebaseDatabase firebaseInstance = FirebaseDatabase.getInstance();
}
