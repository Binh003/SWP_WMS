package util;

import model.User;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

public final class WebUtil {

    private WebUtil() {}

    public static User currentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        return (User) session.getAttribute(SessionKeys.CURRENT_USER);
    }

    public static void setFlashSuccess(HttpServletRequest request, String message) {
        request.getSession(true).setAttribute(SessionKeys.FLASH_SUCCESS, message);
    }

    public static void setFlashError(HttpServletRequest request, String message) {
        request.getSession(true).setAttribute(SessionKeys.FLASH_ERROR, message);
    }

    public static void consumeFlash(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return;
        }
        Object success = session.getAttribute(SessionKeys.FLASH_SUCCESS);
        Object error = session.getAttribute(SessionKeys.FLASH_ERROR);
        if (success != null) {
            request.setAttribute("flashSuccess", success);
            session.removeAttribute(SessionKeys.FLASH_SUCCESS);
        }
        if (error != null) {
            request.setAttribute("flashError", error);
            session.removeAttribute(SessionKeys.FLASH_ERROR);
        }
    }

    public static void redirect(HttpServletRequest request, HttpServletResponse response, String path)
        throws IOException {
        response.sendRedirect(request.getContextPath() + path);
    }

    public static String param(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        return value == null ? "" : value.trim();
    }

    public static boolean isAdmin(User user) {
        return user != null && user.hasRole("ADMIN");
    }

    public static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
