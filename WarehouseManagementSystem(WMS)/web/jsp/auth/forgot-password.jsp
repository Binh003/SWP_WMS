<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Quên mật khẩu - WarehouseManagementSystem(WMS)</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css"/>
  <style>
    .flash { margin-bottom: 16px; padding: 12px; border-radius: 8px; font-size: 14px; }
    .flash--success { background: #ecfdf5; color: #047857; }
    .flash--error { background: #fef2f2; color: #b91c1c; }
    .custom-input { width: 100%; padding: 12px 14px; border: 1px solid #e2e8f0; border-radius: 10px; }
    .input-group { margin-bottom: 14px; }
    .input-label { display: block; margin-bottom: 6px; font-size: 14px; color: #475569; }
    .forgot-note { margin-top: 16px; font-size: 14px; color: #64748b; text-align: center; }
    .forgot-note a { color: #047fa9; text-decoration: none; font-weight: 600; }
    .step-hint { font-size: 14px; color: #64748b; margin-bottom: 16px; line-height: 1.5; }
    
    .dev-reset-card {
      margin-top: 20px;
      padding: 16px;
      background: #f8fafc;
      border: 1px dashed #cbd5e1;
      border-radius: 8px;
    }
    .dev-reset-card h4 {
      margin: 0 0 8px 0;
      color: #334155;
      font-size: 13px;
      text-transform: uppercase;
      letter-spacing: 0.05em;
    }
    .dev-link {
      display: inline-block;
      word-break: break-all;
      color: #0284c7;
      text-decoration: underline;
      font-weight: 500;
      font-size: 13px;
    }
  </style>
</head>
<body>
<main class="login-page">
  <section class="login-shell">
    <div class="login-visual">
      <div class="visual-copy">
        <span class="eyebrow logo-eyebrow">V-Inventory</span>
        <h1>KHÔI PHỤC MẬT KHẨU</h1>
        <p>Nhận liên kết qua Email để đặt lại mật khẩu</p>
      </div>
    </div>

    <div class="login-form-panel">
      <div class="login-form-card">
        <div class="form-heading"><h2>Quên mật khẩu</h2></div>
        <jsp:include page="../includes/flash.jsp"/>

        <c:choose>
          <c:when test="${emailSent}">
            <div class="step-hint">
              Hệ thống đã gửi một liên kết đặt lại mật khẩu đến địa chỉ email: <strong>${email}</strong>.<br/>
              Vui lòng kiểm tra hộp thư đến của bạn để tiếp tục.
            </div>

            <!-- Phát triển/Môi trường Test: Hiển thị link reset trực tiếp trên giao diện -->
            <c:if test="${not empty resetLink}">
              <div class="dev-reset-card">
                <h4>Hộp thư giả lập (Môi trường phát triển)</h4>
                <p style="font-size:12px; color:#64748b; margin: 0 0 8px 0;">
                  (Do hệ thống đang chạy local không có cấu hình SMTP, bạn có thể click trực tiếp vào link dưới đây để đổi mật khẩu):
                </p>
                <a href="${resetLink}" class="dev-link">${resetLink}</a>
              </div>
            </c:if>
          </c:when>
          <c:otherwise>
            <p class="step-hint">Nhập địa chỉ email tài khoản của bạn để nhận liên kết khôi phục mật khẩu.</p>
            <form method="post" action="${pageContext.request.contextPath}/forgot-password">
              <div class="input-group">
                <span class="input-label">Email tài khoản</span>
                <input class="custom-input" type="email" name="email" value="${email}" placeholder="example@domain.com" required/>
              </div>
              <button type="submit" class="btn-primary">Gửi liên kết khôi phục</button>
            </form>
          </c:otherwise>
        </c:choose>

        <p class="forgot-note">
          <a href="${pageContext.request.contextPath}/login">Quay lại đăng nhập</a>
        </p>
      </div>
    </div>
  </section>
</main>
</body>
</html>
