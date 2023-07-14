package pt.unl.fct.di.apdc.firstwebapp.filters;

import com.google.cloud.datastore.*;
import pt.unl.fct.di.apdc.firstwebapp.util.AuthToken;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.datastoreService;
import static pt.unl.fct.di.apdc.firstwebapp.util.ProjectConfig.g;

public class AuthenticationFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String requestURI = httpRequest.getRequestURI();
        if (requestURI.endsWith("/rest/login/")) {
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
