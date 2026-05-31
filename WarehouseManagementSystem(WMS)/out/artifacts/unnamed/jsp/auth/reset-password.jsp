<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Đặt lại mật khẩu - WarehouseManagementSystem(WMS)</title>
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
  </style>
</head>
<body>
<main class="login-page">
  <section class="login-shell">
    <div class="login-visual">
      <div class="visual-copy">
        <span class="eyebrow logo-eyebrow">V-Inventory</span>
        <h1>KHÔI PHỤC MẬT KHẨU</h1>
        <p>Đặt mật khẩu mới để bảo mật tài khoản của bạn</p>
      </div>
    </div>

    <div class="login-form-panel">
      <div class="login-form-card">
        <div class="form-heading"><h2>Đặt lại mật khẩu</h2></div>
        <jsp:include page="../includes/flash.jsp"/>

        <p class="step-hint">Vui lòng nhập mật khẩu mới cho tài khoản của bạn.</p>
        <form method="post" action="${pageContext.request.contextPath}/reset-password">
          <input type="hidden" name="token" value="${token}"/>
          
          <div class="input-group">
            <span class="input-label">Mật khẩu mới</span>
            <input class="custom-input" type="password" name="newPassword" minlength="6" placeholder="Tối thiểu 6 ký tự" required/>
          </div>
          
          <div class="input-group">
            <span class="input-label">Xác nhận mật khẩu mới</span>
            <input class="custom-input" type="password" name="confirmPassword" minlength="6" placeholder="Nhập lại mật khẩu mới" required/>
          </div>
          
          <button type="submit" class="btn-primary">Xác nhận đổi mật khẩu</button>
        </form>

        <p class="forgot-note">
          <a href="${pageContext.request.contextPath}/login">Quay lại đăng nhập</a>
        </p>
      </div>
    </div>
  </section>
</main>
</body>
</html>
