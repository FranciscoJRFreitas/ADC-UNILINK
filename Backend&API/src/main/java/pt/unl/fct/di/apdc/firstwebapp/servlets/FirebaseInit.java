package pt.unl.fct.di.apdc.firstwebapp.servlets;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

public class FirebaseInit implements ServletContextListener{

    public void contextInitialized(ServletContextEvent sce) {
        try {
            // Initialize Firebase
            FirebaseOptions options = new FirebaseOptions.Builder()
                    .setCredentials(GoogleCredentials.getApplicationDefault())
                    .setDatabaseUrl("https://unilink23-default-rtdb.europe-west1.firebasedatabase.app")
                    .build();
            FirebaseApp.initializeApp(options);
        } catch (Exception e) {
            // Handle initialization error
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        FirebaseApp.getInstance().delete();
    }

}
