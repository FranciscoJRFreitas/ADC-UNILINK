/**
 * The CostumeCORSFilter class is a filter that adds CORS headers to the response to allow cross-origin
 * requests during testing in a local environment.
 */
package pt.unl.fct.di.apdc.firstwebapp.filters;

import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerResponseContext;
import javax.ws.rs.container.ContainerResponseFilter;
import javax.ws.rs.ext.Provider;

@Provider
public class CostumeCORSFilter implements ContainerResponseFilter {

    /**
     * The function adds headers to the response context to enable Cross-Origin Resource Sharing (CORS)
     * in a Java application.
     * 
     * @param requestContext The `ContainerRequestContext` object represents the request context of the
     * incoming HTTP request. It contains information about the request, such as headers, cookies, and
     * request method.
     * @param responseContext The `responseContext` parameter is an object that represents the response
     * being sent back to the client. It contains information such as the response headers, status
     * code, and entity body.
     */
    @Override
    public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext) {
        responseContext.getHeaders().add("Access-Control-Allow-Origin", "*");
        responseContext.getHeaders().add("Access-Control-Allow-Headers", "origin, content-type, accept, authorization");
        responseContext.getHeaders().add("Access-Control-Allow-Credentials", "true");
        responseContext.getHeaders().add("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, HEAD");
        responseContext.getHeaders().add("Access-Control-Max-Age", "1209600");
    }

}
