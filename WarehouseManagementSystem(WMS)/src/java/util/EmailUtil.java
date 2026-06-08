package util;

import java.util.Properties;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public final class EmailUtil {

    // Cấu hình SMTP của Gmail (Hoặc thay bằng SMTP nhà cung cấp khác)
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final String SMTP_PORT = "587"; // Cổng TLS của Gmail
    
    // TODO: Thay đổi 2 thông tin dưới đây bằng tài khoản của bạn để gửi được mail thật
     private static final String FROM_EMAIL = "sea31082003@gmail.com";
     private static final String APP_PASSWORD = "fjuh vbha bckg qcqu"; // Mật khẩu ứng dụng (không phải mật khẩu thường)
//    private static final String FROM_EMAIL = "";
//    private static final String APP_PASSWORD = "";
    private EmailUtil() {}

    /**
     * Gửi email chứa liên kết đặt lại mật khẩu cho người dùng.
     */
    public static void sendResetLink(String toEmail, String resetLink) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true"); // Bắt buộc dùng mã hóa TLS

        // Tạo session kết nối SMTP
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
            }
        });

        // Tạo nội dung mail
        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(FROM_EMAIL));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject("[V-Inventory] Yeu cau khoi phuc mat khau tai khoan");

        String htmlContent = """
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e2e8f0; border-radius: 8px;">
                <h2 style="color: #0ea5e9; text-align: center;">V-Inventory WMS</h2>
                <hr style="border: 0; border-top: 1px solid #e2e8f0; margin: 20px 0;"/>
                <p>Xin chào,</p>
                <p>Chúng tôi nhận được yêu cầu khôi phục mật khẩu cho tài khoản liên kết với email này.</p>
                <p>Vui lòng click vào nút bên dưới để tiến hành đổi mật khẩu mới (Liên kết có hiệu lực trong vòng <b>15 phút</b>):</p>
                <div style="text-align: center; margin: 30px 0;">
                    <a href="%s" style="background-color: #0ea5e9; color: white; padding: 12px 24px; text-decoration: none; font-weight: bold; border-radius: 6px; display: inline-block;">Đổi mật khẩu mới</a>
                </div>
                <p style="font-size: 13px; color: #64748b;">
                    Hoặc copy liên kết sau vào trình duyệt nếu nút bấm không hoạt động:<br/>
                    <a href="%s" style="color: #0ea5e9;">%s</a>
                </p>
                <hr style="border: 0; border-top: 1px solid #e2e8f0; margin: 20px 0;"/>
                <p style="font-size: 12px; color: #94a3b8; text-align: center;">Nếu bạn không yêu cầu hành động này, vui lòng bỏ qua email.</p>
            </div>
            """.formatted(resetLink, resetLink, resetLink);

        message.setContent(htmlContent, "text/html; charset=UTF-8");

        // Tiến hành gửi
        Transport.send(message);
    }
}
