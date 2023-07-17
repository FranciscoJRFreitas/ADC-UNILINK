/**
 * The FirebaseInit class is a ServletContextListener that initializes and configures Firebase in a
 * Java web application.
 */
package pt.unl.fct.di.apdc.firstwebapp.servlets;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

public class FirebaseInit implements ServletContextListener{

    /**
     * The function initializes Firebase in a Java web application.
     * 
     * @param sce The parameter "sce" is of type ServletContextEvent. It represents the event that
     * occurs when the servlet context is initialized. The ServletContextEvent provides access to the
     * ServletContext, which is the main interface for communicating with the servlet container.
     */
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

    /**
     * The function is used to delete the FirebaseApp instance when the servlet context is destroyed.
     * 
     * @param sce The parameter "sce" is of type ServletContextEvent. It represents the event that
     * occurs when the ServletContext is about to be destroyed.
     */
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        FirebaseApp.getInstance().delete();
    }

}
