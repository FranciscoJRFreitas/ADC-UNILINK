/**
 * The MediaResourceServlet class is a Java servlet that handles file uploads and downloads from Google
 * Cloud Storage (GCS).
 */
package pt.unl.fct.di.apdc.firstwebapp.servlets;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Collections;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.cloud.storage.Acl;
import com.google.cloud.storage.Blob;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;


@SuppressWarnings("serial")
public class MediaResourceServlet extends HttpServlet {

	  // The `doGet` method in the `MediaResourceServlet` class is responsible for handling HTTP GET
	  // requests. It retrieves a file from Google Cloud Storage (GCS) and returns it in the HTTP
	  // response.
	  /**
	   * Retrieves a file from GCS and returns it in the http response.
	   * If the request path is /gcs/Foo/Bar this will be interpreted as
	   * a request to read the GCS file named Bar in the bucket Foo.
	   */
	  @Override
	  public void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
	        // Download file from a specified bucket. The request must have the form /gcs/<bucket>/<object>
	    	Storage storage = StorageOptions.getDefaultInstance().getService();
	        // Parse the request URL
	    	Path objectPath = Paths.get(req.getPathInfo());
	        if ( objectPath.getNameCount() != 2 ) {
	          throw new IllegalArgumentException("The URL is not formed as expected. " +
	              "Expecting /gcs/<bucket>/<object>");
	        }
	        // Get the bucket and the object names
	    	String bucketName = objectPath.getName(0).toString();
	    	String srcFilename = objectPath.getName(1).toString();
	    	
	        Blob blob = storage.get(BlobId.of(bucketName, srcFilename));
	        
	        // Download object to the output stream. See Google's documentation.
	        resp.setContentType(blob.getContentType());
	        blob.downloadTo(resp.getOutputStream());
	  }

	  /**
	   * This function handles a POST request to upload a file to Google Cloud Storage.
	   * 
	   * @param req The `req` parameter is an instance of the `HttpServletRequest` class, which represents
	   * the request made by the client to the server. It contains information such as the request method,
	   * headers, parameters, and input stream.
	   * @param resp The `resp` parameter is an instance of the `HttpServletResponse` class, which
	   * represents the response that will be sent back to the client. It is used to send data back to the
	   * client, such as the response status code, headers, and the response body. In this code snippet,
	   * the
	   */
	  @Override
	  public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
	        // Upload file to specified bucket. The request must have the form /gcs/<bucket>/<object>
	    	Path objectPath = Paths.get(req.getPathInfo());
	        if ( objectPath.getNameCount() != 2 ) {
	          throw new IllegalArgumentException("The URL is not formed as expected. " +
	              "Expecting /gcs/<bucket>/<object>");
	        }
	        // Get the bucket and object from the URL 
	    	String bucketName = objectPath.getName(0).toString();
	    	String srcFilename = objectPath.getName(1).toString();
	    	
	    	// Upload to Google Cloud Storage (see Google's documentation)
	    	Storage storage = StorageOptions.getDefaultInstance().getService();
	        BlobId blobId = BlobId.of(bucketName, srcFilename);
	        BlobInfo blobInfo = BlobInfo.newBuilder(blobId)
	        							.setAcl(Collections.singletonList(Acl.newBuilder(Acl.User.ofAllUsers(),Acl.Role.READER).build()))
	        							.setContentType(req.getContentType())
	        							.build();
	        // The following is deprecated since it is better to upload directly to GCS from the client
	        Blob blob = storage.create(blobInfo, req.getInputStream());
	  }
	
}