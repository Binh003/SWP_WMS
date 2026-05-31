<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Đăng nhập - WarehouseManagementSystem(WMS)</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css"/>
  <style>
    .flash { margin-bottom: 16px; padding: 12px; border-radius: 8px; font-size: 14px; }
    .flash--success { background: #ecfdf5; color: #047857; }
    .flash--error { background: #fef2f2; color: #b91c1c; }
    .custom-input { width: 100%; padding: 12px 14px; border: 1px solid #e2e8f0; border-radius: 10px; }
  </style>
</head>
<body>
<main class="login-page">
  <section class="login-shell">
    <div class="login-visual">
      <div class="visual-copy">
        <span class="eyebrow logo-eyebrow">V-Inventory</span>
        <h1>QUẢN TRỊ KHO HÀNG THÔNG MINH</h1>
        <p>HỢP NHẤT</p>
      </div>
    </div>

    <div class="login-form-panel">
      <div class="login-form-card">
        <div class="form-heading"><h2>Đăng nhập</h2></div>
        <jsp:include page="includes/flash.jsp"/>

        <form method="post" action="${pageContext.request.contextPath}/login">
          <div class="input-group">
            <span class="input-label">Tài khoản</span>
            <input class="custom-input" type="text" name="username" value="${username}" placeholder="Nhập tài khoản" required/>
          </div>
          <div class="input-group">
            <span class="input-label">Mật khẩu</span>
            <input class="custom-input" type="password" name="password" placeholder="Nhập mật khẩu" required/>
          </div>
          <p style="text-align:right;margin:8px 0 16px;font-size:14px;">
            <a href="${pageContext.request.contextPath}/forgot-password" style="color:#047fa9;text-decoration:none;">Quên mật khẩu?</a>
          </p>
          <button type="submit" class="btn-primary">Đăng nhập</button>
        </form>
        <p class="register-note">Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register">Đăng ký</a></p>
      </div>
    </div>
  </section>
</main>
</body>
</html>
