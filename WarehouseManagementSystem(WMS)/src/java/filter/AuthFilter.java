package filter;

import model.User;
import util.SessionKeys;
import util.WebUtil;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
        throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String path = req.getRequestURI().substring(req.getContextPath().length());

        if (isPublic(path)) {
            chain.doFilter(request, response);
            return;
        }

        User user = WebUtil.currentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Verify if user is still valid and password hash matches the database
        try {
            dao.UserDAO userDAO = new dao.UserDAO();
            User freshUser = userDAO.findById(user.getId());
            if (freshUser == null || !freshUser.isEnabled() || !freshUser.getPasswordHash().equals(user.getPasswordHash())) {
                req.getSession().invalidate();
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            
            // Cập nhật session user để luôn có danh sách roles/permissions mới nhất
            req.getSession().setAttribute(util.SessionKeys.CURRENT_USER, freshUser);
            user = freshUser;
            
        } catch (java.sql.SQLException ex) {
            req.getServletContext().log("Database verification error in AuthFilter: " + ex.getMessage(), ex);
        }

        if (path.startsWith("/manage/")) {
            boolean isAdmin = WebUtil.isAdmin(user);
            boolean hasAccess = isAdmin;

            if (!isAdmin) {
                if (path.startsWith("/manage/users")) {
                    hasAccess = user.hasPermission("USER_READ") || user.hasPermission("USER_WRITE");
                } else if (path.startsWith("/manage/roles")) {
                    hasAccess = user.hasPermission("ROLE_READ") || user.hasPermission("ROLE_WRITE") || user.hasPermission("PERMISSION_READ");
                } else if (path.startsWith("/manage/brands")) {
                    hasAccess = user.hasPermission("BRAND_READ") || user.hasPermission("BRAND_WRITE");
                } else if (path.startsWith("/manage/suppliers")) {
                    hasAccess = user.hasPermission("SUPPLIER_READ") || user.hasPermission("SUPPLIER_WRITE");
                } else if (path.startsWith("/manage/product-lines")) {
                    hasAccess = user.hasPermission("PRODUCT_LINE_READ") || user.hasPermission("PRODUCT_LINE_WRITE");
                } else if (path.startsWith("/manage/products")) {
                    hasAccess = user.hasPermission("PRODUCT_READ") || user.hasPermission("PRODUCT_WRITE");
                } else if (path.startsWith("/manage/inventories")) {
                    hasAccess = user.hasPermission("INVENTORY_READ") || user.hasPermission("INVENTORY_WRITE");
                } else if (path.startsWith("/manage/receipts")) {
                    hasAccess = user.hasPermission("RECEIPT_READ") || user.hasPermission("RECEIPT_WRITE");
                } else if (path.startsWith("/manage/shipments")) {
                    hasAccess = user.hasPermission("SHIPMENT_READ") || user.hasPermission("SHIPMENT_WRITE");
                } else if (path.startsWith("/manage/reports")) {
                    hasAccess = user.hasPermission("REPORT_READ");
                } else if (path.startsWith("/manage/barcode")) {
                    hasAccess = true;
                }
            }

            if (!hasAccess) {
                resp.sendRedirect(req.getContextPath() + "/home");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    private boolean isPublic(String path) {
        if (path.equals("/") || path.equals("/index.jsp")) {
            return true;
        }
        return path.equals("/login")
            || path.equals("/register")
            || path.equals("/forgot-password")
            || path.equals("/reset-password")
            || path.startsWith("/css/")
            || path.endsWith(".css")
            || path.endsWith(".js")
            || path.endsWith(".png")
            || path.endsWith(".jpg")
            || path.endsWith(".svg");
    }
}
