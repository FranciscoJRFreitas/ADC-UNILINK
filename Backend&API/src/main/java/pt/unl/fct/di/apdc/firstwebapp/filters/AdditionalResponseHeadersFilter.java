/**
 * The AdditionalResponseHeadersFilter class is a filter that adds additional response headers to allow
 * cross-origin resource sharing (CORS) in a Java web application.
 */
package pt.unl.fct.di.apdc.firstwebapp.filters;
import java.io.IOException;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerResponseContext;
import javax.ws.rs.container.ContainerResponseFilter;
import javax.ws.rs.ext.Provider;

	@Provider
	public class AdditionalResponseHeadersFilter implements ContainerResponseFilter {
	
		public AdditionalResponseHeadersFilter() {}
		
		/**
		 * This function adds headers to the response context to enable cross-origin resource sharing (CORS)
		 * for various HTTP methods and headers.
		 * 
		 * @param requestContext The request context represents the incoming HTTP request. It contains
		 * information such as the request headers, request method, request URI, and request entity.
		 * @param responseContext The response context represents the response that will be sent back to the
		 * client. It contains information such as the response headers and the response entity.
		 */
		@Override
		public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext) throws IOException {
			responseContext.getHeaders().add("Access-Control-Allow-Methods", "HEAD,GET,PUT,POST,DELETE,OPTIONS");
			responseContext.getHeaders().add("Access-Control-Allow-Origin", "*");
			responseContext.getHeaders().add("Access-Control-Allow-Headers", "Content-Type, X-Requested-With");
		}
		
}