<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Đăng ký - WarehouseManagementSystem(WMS)</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
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
          <img src="${pageContext.request.contextPath}/assets/logo.png" alt="InventoryTracking"/>
        </span>
        <h1>QUẢN TRỊ KHO HÀNG<br/>THÔNG MINH</h1>
        <p>ĐĂNG KÝ</p>
      </div>

      <div class="avatar-frame" aria-hidden="true">
        <span class="floating-square top"></span>
        <span class="floating-square bottom"></span>
        <img class="robot-image" src="${pageContext.request.contextPath}/assets/img_login.png" alt="Robot"/>
      </div>
    </div>

    <div class="login-form-panel">
      <div class="login-form-card">
        <div class="form-heading">
          <span class="heading-logo">
            <img src="${pageContext.request.contextPath}/assets/logo.png" alt="InventoryTracking"/>
          </span>
          <h2 style="font-size: 24px; font-weight: 700; color: #1e293b; margin-top: 10px;">Liên hệ Quản trị viên</h2>
        </div>

        <div style="margin-top: 24px;">
          <p style="font-size: 14px; color: #64748b; line-height: 1.6; margin-bottom: 24px; text-align: center;">
            Hệ thống không hỗ trợ tự ý đăng ký tài khoản. Vui lòng liên hệ với Quản trị viên qua các kênh thông tin dưới đây để được cấp tài khoản:
          </p>

          <div style="display: flex; flex-direction: column; gap: 14px; margin-bottom: 28px;">
            <!-- Email Contact -->
            <div style="display: flex; align-items: center; padding: 12px 16px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; gap: 12px;">
              <div style="width: 36px; height: 36px; border-radius: 8px; background: rgba(2, 138, 191, 0.1); color: #028abf; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                  <polyline points="22,6 12,13 2,6"></polyline>
                </svg>
              </div>
              <div style="flex-grow: 1; min-width: 0;">
                <span style="display: block; font-size: 11px; font-weight: 600; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.5px;">Email hỗ trợ</span>
                <a href="mailto:admin@inventory.local" style="font-size: 14px; font-weight: 600; color: #1e293b; text-decoration: none; word-break: break-all; display: block;">admin@inventory.local</a>
              </div>
              <button onclick="copyText('admin@inventory.local', this)" style="display: flex; align-items: center; gap: 4px; padding: 6px 10px; border: 1px solid #e2e8f0; background: #ffffff; color: #475569; font-size: 12px; font-weight: 600; border-radius: 6px; cursor: pointer; transition: all 0.2s; flex-shrink: 0;">
                <span class="copy-text">Chép</span>
              </button>
            </div>

            <!-- Phone Contact -->
            <div style="display: flex; align-items: center; padding: 12px 16px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; gap: 12px;">
              <div style="width: 36px; height: 36px; border-radius: 8px; background: rgba(2, 138, 191, 0.1); color: #028abf; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
                </svg>
              </div>
              <div style="flex-grow: 1; min-width: 0;">
                <span style="display: block; font-size: 11px; font-weight: 600; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.5px;">Số điện thoại</span>
                <a href="tel:0912345678" style="font-size: 14px; font-weight: 600; color: #1e293b; text-decoration: none; display: block;">0912 345 678</a>
              </div>
              <button onclick="copyText('0912345678', this)" style="display: flex; align-items: center; gap: 4px; padding: 6px 10px; border: 1px solid #e2e8f0; background: #ffffff; color: #475569; font-size: 12px; font-weight: 600; border-radius: 6px; cursor: pointer; transition: all 0.2s; flex-shrink: 0;">
                <span class="copy-text">Chép</span>
              </button>
            </div>
          </div>

          <a href="${pageContext.request.contextPath}/login" class="btn-primary" style="display: flex; align-items: center; justify-content: center; text-decoration: none; box-sizing: border-box; text-align: center;">
            Quay lại Đăng nhập
          </a>
        </div>
      </div>
    </div>
  </section>
</main>

<script>
  function copyText(text, btn) {
    navigator.clipboard.writeText(text).then(() => {
      const copyTextSpan = btn.querySelector('.copy-text');
      btn.style.background = '#ecfdf5';
      btn.style.borderColor = '#a7f3d0';
      btn.style.color = '#065f46';
      copyTextSpan.textContent = 'Đã chép';
      
      setTimeout(() => {
        btn.style.background = '#ffffff';
        btn.style.borderColor = '#e2e8f0';
        btn.style.color = '#475569';
        copyTextSpan.textContent = 'Chép';
      }, 2000);
    }).catch(err => {
      console.error('Không thể sao chép: ', err);
    });
  }
</script>
</body>
</html>
