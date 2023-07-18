/**
 * The `AuthenticationFilter` class is a Java filter that checks if a user is authenticated before
 * allowing access to certain paths in a web application.
 */
package pt.unl.fct.di.apdc.firstwebapp.filters;

import com.google.cloud.datastore.*;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Set;

import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.datastoreService;
import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.g;

public class AuthenticationFilter implements Filter {

    private static final List<String> ALLOWED_PATHS = List.of("/rest/login", "/rest/register", "/rest/recoverPwd", "/rest/activate", "/rest/chat/join");

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {

    }

    /**
     * This function is a filter that checks if a request is allowed based on the requested path and
     * authentication token.
     * 
     * @param request The `request` parameter is of type `ServletRequest` and represents the incoming
     * request from the client. It contains information such as the request method, headers,
     * parameters, and body.
     * @param response The "response" parameter is the ServletResponse object that represents the
     * response to be sent back to the client. It is used to send data back to the client, such as HTML
     * content or error messages.
     * @param chain The `chain` parameter is an object of type `FilterChain`. It is used to invoke the
     * next filter in the chain or the servlet if there are no more filters. The `doFilter` method of
     * the `FilterChain` interface is called to pass the request and response objects to the next
     */
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length()).replaceAll("/+$", "");

        boolean allowedPath = false;
        for (String p : ALLOWED_PATHS) {
            if (path.startsWith(p)) {
                allowedPath = true;
                break;
            }
        }

        if (allowedPath) {
            chain.doFilter(request, response);
            return;
        }

        String authTokenHeader = httpRequest.getHeader("Authorization");
        if (authTokenHeader == null || !authTokenHeader.startsWith("Bearer ")) {
            ((HttpServletResponse) response).sendError(HttpServletResponse.SC_UNAUTHORIZED, "Authorization header must be provided");
            return;
        }

        String authToken = authTokenHeader.substring("Bearer".length()).trim();
        AuthToken token = g.fromJson(authToken, AuthToken.class);

        Key tokenKey = datastoreService.newKeyFactory().addAncestor(PathElement.of("User", token.username))
                .setKind("User Token").newKey(token.username);

        Entity originalToken = datastoreService.get(tokenKey);

        if (originalToken == null) {
            ((HttpServletResponse) response).sendError(HttpServletResponse.SC_UNAUTHORIZED, "User not logged in");
            return;
        }

        if (!token.tokenID.equals(originalToken.getString("user_tokenID")) || System.currentTimeMillis() > originalToken.getLong("user_token_expiration_date")) {
            ((HttpServletResponse) response).sendError(HttpServletResponse.SC_UNAUTHORIZED, "Session Expired.");
            return;
        }

        // Continue request processing
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
