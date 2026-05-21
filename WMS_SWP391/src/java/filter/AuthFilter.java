package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.WebUtil;

import java.io.IOException;
import java.util.Set;

public class AuthFilter implements Filter {

    private static final Set<String> PUBLIC_PATHS = Set.of(
        "/",
        "/index.jsp",
        "/index.html",
        "/login",
        "/register",
        "/forgot-password",
        "/logout"
    );

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
        throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String path = request.getRequestURI();
        String context = request.getContextPath();
        if (context != null && !context.isEmpty() && path.startsWith(context)) {
            path = path.substring(context.length());
        }
        if (path.isEmpty()) {
            path = "/";
        }

        if (PUBLIC_PATHS.contains(path) || path.startsWith("/css/")) {
            chain.doFilter(req, res);
            return;
        }
        if (WebUtil.currentUser(request) != null) {
            chain.doFilter(req, res);
            return;
        }

        response.sendRedirect(context + "/login");
    }
}
