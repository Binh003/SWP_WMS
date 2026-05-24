<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Đăng ký - WarehouseManagementSystem(WMS)</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css"/>
  <style>
    .flash { margin-bottom: 16px; padding: 12px; border-radius: 8px; font-size: 14px; }
    .flash--success { background: #ecfdf5; color: #047857; }
    .flash--error { background: #fef2f2; color: #b91c1c; }
  </style>
</head>
<body>
<main class="login-page">
  <section class="login-shell" aria-label="Đăng ký tài khoản">
    <div class="login-visual">
      <div class="visual-copy">
        <span class="eyebrow logo-eyebrow">
          <img src="${pageContext.request.contextPath}/assets/inventory-logo.png" alt="InventoryTracking"/>
        </span>
        <h1>QUẢN TRỊ KHO HÀNG<br/>THÔNG MINH</h1>
        <p>ĐĂNG KÝ</p>
      </div>

      <div class="avatar-frame" aria-hidden="true">
        <span class="floating-square top"></span>
        <span class="floating-square bottom"></span>
        <img class="robot-image" src="${pageContext.request.contextPath}/assets/inventory-robot.png" alt="Robot"/>
      </div>
    </div>

    <div class="login-form-panel">
      <div class="login-form-card">
        <div class="form-heading">
          <span class="heading-logo">
            <img src="${pageContext.request.contextPath}/assets/inventory-logo.png" alt="InventoryTracking"/>
          </span>
          <h2>Tạo tài khoản</h2>
        </div>
        <jsp:include page="../includes/flash.jsp"/>

        <form method="post" action="${pageContext.request.contextPath}/register">
          <div class="input-group">
            <span class="input-label">Họ và tên</span>
            <div class="input-wrap">
              <span class="input-icon" aria-hidden="true">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M20 21C20 19.6044 20 18.9067 19.6847 18.3022C19.2618 17.4913 18.5087 16.8393 17.587 16.4831C16.9 16.2174 16.1022 16.2174 14.5066 16.2174H9.49339C7.89781 16.2174 7.09997 16.2174 6.413 16.4831C5.49129 16.8393 4.73819 17.4913 4.31527 18.3022C4 18.9067 4 19.6044 4 21" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>
                  <circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="1.7"/>
                </svg>
              </span>
              <input class="custom-input" type="text" name="fullName" placeholder="Nhập họ và tên" required/>
            </div>
          </div>

          <div class="input-group">
            <span class="input-label">Email / Username</span>
            <div class="input-wrap">
              <span class="input-icon" aria-hidden="true">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M4 6.5C4 5.11929 5.11929 4 6.5 4H17.5C18.8807 4 20 5.11929 20 6.5V17.5C20 18.8807 18.8807 20 17.5 20H6.5C5.11929 20 4 18.8807 4 17.5V6.5Z" stroke="currentColor" stroke-width="1.7"/>
                  <path d="M5.5 6.5L12 12L18.5 6.5" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
              </span>
              <input class="custom-input" type="email" name="email" placeholder="Nhập email đăng ký" required/>
            </div>
          </div>

          <div class="input-group">
            <span class="input-label">Mật khẩu</span>
            <div class="input-wrap">
              <span class="input-icon" aria-hidden="true">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M7.5 10V8.5C7.5 6.01472 9.51472 4 12 4C14.4853 4 16.5 6.01472 16.5 8.5V10" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>
                  <path d="M6.5 10H17.5C18.6046 10 19.5 10.8954 19.5 12V18C19.5 19.1046 18.6046 20 17.5 20H6.5C5.39543 20 4.5 19.1046 4.5 18V12C4.5 10.8954 5.39543 10 6.5 10Z" stroke="currentColor" stroke-width="1.7"/>
                  <path d="M12 14V16" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>
                </svg>
              </span>
              <input id="passwordInput" class="custom-input" type="password" name="password" minlength="6" placeholder="Nhập mật khẩu" required/>
              <button type="button" class="password-toggle" aria-label="Hiện/ẩn mật khẩu" onclick="togglePassword()">
                <svg id="eyeSvg" class="eye" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M17.94 17.94A10.07 10.07 0 0 1 12 19c-7 0-11-7-11-7a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 7 11 7a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
                  <line x1="1" y1="1" x2="23" y2="23" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>
                </svg>
              </button>
            </div>
          </div>

          <button type="submit" class="btn-primary" style="margin-top: 24px;">Đăng ký</button>
        </form>
        <p class="register-note">Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập</a></p>
      </div>
    </div>
  </section>
</main>

<script>
  function togglePassword() {
    var input = document.getElementById('passwordInput');
    var eyeSvg = document.getElementById('eyeSvg');
    if (!input || !eyeSvg) return;
    if (input.type === 'password') {
      input.type = 'text';
      eyeSvg.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/><circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>';
    } else {
      input.type = 'password';
      eyeSvg.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 19c-7 0-11-7-11-7a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 7 11 7a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/><line x1="1" y1="1" x2="23" y2="23" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>';
    }
  }
</script>
</body>
</html>
