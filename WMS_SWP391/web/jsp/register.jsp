<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <title>Đăng ký - WarehouseManagementSystem(WMS)</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/register.css"/>
  <style>
    .custom-input { width: 100%; padding: 12px 14px; border: 1px solid #e2e8f0; border-radius: 10px; margin-bottom: 12px; }
  </style>
</head>
<body>
<main class="login-page register-page">
  <section class="login-shell">
    <div class="login-visual">
      <div class="visual-copy"><h1>ĐĂNG KÝ TÀI KHOẢN</h1></div>
    </div>
    <div class="login-form-panel register-form-panel">
      <div class="login-form-card">
        <h2>Tạo tài khoản</h2>
        <jsp:include page="includes/flash.jsp"/>
        <form method="post" action="${pageContext.request.contextPath}/register">
          <label>Họ và tên</label>
          <input class="custom-input" name="fullName" required/>
          <label>Email / Username</label>
          <input class="custom-input" name="email" type="email" required/>
          <label>Mật khẩu</label>
          <input class="custom-input" name="password" type="password" minlength="6" required/>
          <button type="submit" class="btn-primary">Đăng ký</button>
        </form>
        <p class="register-note">Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập</a></p>
      </div>
    </div>
  </section>
</main>
</body>
</html>
