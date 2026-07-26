package service;

import dao.PasswordResetDAO;
import dao.RoleDAO;
import dao.UserDAO;
import model.Role;
import model.User;
import util.EmailUtil;
import util.PasswordUtil;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;

public class AuthService {

    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();
    private final PasswordResetDAO passwordResetDAO = new PasswordResetDAO();

    public static class LoginResult {
        private final User user;
        private final String errorMessage;

        public LoginResult(User user, String errorMessage) {
            this.user = user;
            this.errorMessage = errorMessage;
        }

        public User getUser() {
            return user;
        }

        public String getErrorMessage() {
            return errorMessage;
        }

        public boolean isSuccess() {
            return user != null && errorMessage == null;
        }
    }

    public LoginResult login(String username, String password) throws SQLException {
        User user = userDAO.findByUsername(username);
        if (user == null || !PasswordUtil.matches(password, user.getPasswordHash())) {
            return new LoginResult(null, "Tài khoản hoặc mật khẩu không đúng");
        }
        if (!user.isEnabled()) {
            String errorMsg = "Tài khoản chưa được admin kích hoạt";
            if ("LOCKED".equalsIgnoreCase(user.getStatus())) {
                errorMsg = "Tài khoản đã bị khóa bởi quản trị viên";
            } else if ("PENDING".equalsIgnoreCase(user.getStatus())) {
                errorMsg = "Tài khoản đang chờ phê duyệt từ quản trị viên";
            }
            return new LoginResult(null, errorMsg);
        }
        return new LoginResult(user, null);
    }

    public String processForgotPassword(String email, String baseUrl) throws SQLException, IllegalArgumentException {
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email không được để trống");
        }
        User user = userDAO.findByEmail(email.trim());
        if (user == null) {
            throw new IllegalArgumentException("Email không tồn tại trong hệ thống");
        }
        if (!user.isEnabled()) {
            throw new IllegalArgumentException("Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Admin.");
        }

        String token = UUID.randomUUID().toString();
        Timestamp expiryTime = new Timestamp(System.currentTimeMillis() + 15 * 60 * 1000);
        passwordResetDAO.createToken(user.getId(), token, expiryTime);

        String resetLink = baseUrl + "/reset-password?token=" + token;
        System.out.println("=================================================");
        System.out.println("MÃ KHÔI PHỤC MẬT KHẨU CHO: " + user.getUsername());
        System.out.println("Reset Link: " + resetLink);
        System.out.println("=================================================");

        try {
            EmailUtil.sendResetLink(email, resetLink);
        } catch (Throwable t) {
            System.err.println("Gửi email thật thất bại (Có thể do chưa cấu hình SMTP hoặc thiếu thư viện JAR): " + t.getMessage());
        }

        return resetLink;
    }

    public Long validateResetToken(String token) throws SQLException {
        if (token == null || token.trim().isEmpty()) {
            return null;
        }
        return passwordResetDAO.getUserIdByValidToken(token.trim());
    }

    public void resetPassword(String token, String newPassword, String confirmPassword) throws SQLException, IllegalArgumentException {
        Long userId = validateResetToken(token);
        if (userId == null) {
            throw new IllegalArgumentException("Mã xác minh (token) không hợp lệ hoặc đã hết hạn.");
        }

        if (newPassword == null || newPassword.length() < 8 || !newPassword.matches(".*[a-z].*") || !newPassword.matches(".*[A-Z].*") || !newPassword.matches(".*\\d.*")) {
            throw new IllegalArgumentException("Mật khẩu mới phải từ 8 ký tự, bao gồm chữ hoa, chữ thường và chữ số.");
        }

        if (!newPassword.equals(confirmPassword)) {
            throw new IllegalArgumentException("Mật khẩu xác nhận không khớp.");
        }

        userDAO.updatePassword(userId, PasswordUtil.hash(newPassword));
        passwordResetDAO.markTokenAsUsed(token);
    }

    public void changePassword(long userId, String currentPassword, String newPassword) throws SQLException, IllegalArgumentException {
        User dbUser = userDAO.findById(userId);
        if (dbUser == null || !PasswordUtil.matches(currentPassword, dbUser.getPasswordHash())) {
            throw new IllegalArgumentException("Mật khẩu hiện tại không đúng.");
        }

        if (newPassword == null || newPassword.length() < 8 || !newPassword.matches(".*[a-z].*") || !newPassword.matches(".*[A-Z].*") || !newPassword.matches(".*\\d.*")) {
            throw new IllegalArgumentException("Mật khẩu mới phải từ 8 ký tự, bao gồm chữ hoa, chữ thường và chữ số.");
        }

        userDAO.updatePassword(userId, PasswordUtil.hash(newPassword));
    }

    public boolean register(User user) throws SQLException {
        if (userDAO.existsByUsername(user.getUsername())) {
            return false;
        }

        Role defaultRole = roleDAO.findByCode("WAREHOUSE STAFF");
        if (defaultRole == null) {
            throw new SQLException("Role WAREHOUSE STAFF chưa được seed");
        }

        user.setPasswordHash(PasswordUtil.hash(user.getPasswordHash()));
        user.setEnabled(false);
        user.setRoles(List.of(defaultRole));

        userDAO.insert(user);
        return true;
    }
}
