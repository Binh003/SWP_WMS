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
    .step-hint { font-size: 13px; color: #64748b; margin-bottom: 16px; }
  </style>
</head>
<body>
<main class="login-page">
  <section class="login-shell">
    <div class="login-visual">
      <div class="visual-copy">
        <span class="eyebrow logo-eyebrow">V-Inventory</span>
        <h1>KHÔI PHỤC MẬT KHẨU</h1>
        <p>Xác minh tài khoản để đặt mật khẩu mới</p>
      </div>
    </div>

    <div class="login-form-panel">
      <div class="login-form-card">
        <div class="form-heading"><h2>Quên mật khẩu</h2></div>
        <jsp:include page="includes/flash.jsp"/>

        <c:choose>
          <c:when test="${resetStep == 2}">
            <p class="step-hint">Tài khoản <strong>${username}</strong> đã được xác minh. Nhập mật khẩu mới.</p>
            <form method="post" action="${pageContext.request.contextPath}/forgot-password">
              <input type="hidden" name="action" value="reset"/>
              <div class="input-group">
                <span class="input-label">Mật khẩu mới</span>
                <input class="custom-input" type="password" name="newPassword" minlength="6" placeholder="Ít nhất 6 ký tự" required/>
              </div>
              <div class="input-group">
                <span class="input-label">Xác nhận mật khẩu</span>
                <input class="custom-input" type="password" name="confirmPassword" minlength="6" placeholder="Nhập lại mật khẩu" required/>
              </div>
              <button type="submit" class="btn-primary">Đặt lại mật khẩu</button>
            </form>
          </c:when>
          <c:otherwise>
            <p class="step-hint">Nhập tài khoản và email đã đăng ký để xác minh.</p>
            <form method="post" action="${pageContext.request.contextPath}/forgot-password">
              <input type="hidden" name="action" value="verify"/>
              <div class="input-group">
                <span class="input-label">Tài khoản</span>
                <input class="custom-input" type="text" name="username" value="${username}" placeholder="Nhập tài khoản" required/>
              </div>
              <div class="input-group">
                <span class="input-label">Email</span>
                <input class="custom-input" type="email" name="email" value="${email}" placeholder="Nhập email đăng ký" required/>
              </div>
              <button type="submit" class="btn-primary">Tiếp tục</button>
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
