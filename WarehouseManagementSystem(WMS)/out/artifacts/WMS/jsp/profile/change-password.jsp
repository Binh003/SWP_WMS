<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Đổi mật khẩu" scope="request"/>
<c:set var="activePage" value="password" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px;">
    <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Đổi mật khẩu</h2>
    <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Cập nhật mật khẩu tài khoản của bạn để bảo mật.</p>
  </div>
  
  <div class="profile-layout-grid">
    <!-- Left Column: Change password form -->
    <div class="premium-card" style="padding: 40px 32px 32px 32px;">
      <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 32px; padding-bottom: 16px; border-bottom: 1px solid var(--card-border);">
        <div style="display: flex; align-items: center; justify-content: center; width: 48px; height: 48px; border-radius: 12px; background: rgba(4, 138, 191, 0.1); color: var(--primary-color);">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 22C12 22 20 18 20 12V5L12 2L4 5V12C4 18 12 22 12 22Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </div>
        <div>
          <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">Mật khẩu & Bảo mật</h3>
          <p style="margin: 4px 0 0 0; font-size: 13px; color: var(--text-secondary);">Mật khẩu mới phải từ 8 ký tự, bao gồm chữ hoa, chữ thường và chữ số.</p>
        </div>
      </div>
      
      <form id="changePasswordForm" method="post" action="${pageContext.request.contextPath}/change-password" style="display: flex; flex-direction: column; gap: 20px;">
        <div class="form-group">
          <label class="form-label">Mật khẩu hiện tại</label>
          <input type="password" name="currentPassword" required class="subpage-input" placeholder="Nhập mật khẩu hiện tại"/>
        </div>
        
        <div class="form-group">
          <label class="form-label">Mật khẩu mới</label>
          <input type="password" id="newPassword" name="newPassword" minlength="8" pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}" title="Mật khẩu phải từ 8 ký tự, bao gồm ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số." placeholder="Tối thiểu 8 ký tự (hoa, thường, số)" required class="subpage-input"/>
        </div>
        
        <div class="form-group">
          <label class="form-label">Xác nhận mật khẩu mới</label>
          <input type="password" id="confirmPassword" name="confirmPassword" minlength="8" pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}" title="Mật khẩu phải từ 8 ký tự, bao gồm ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số." placeholder="Nhập lại mật khẩu mới" required class="subpage-input"/>
          <span id="passwordError" style="color: #ef4444; font-size: 13px; margin-top: 6px; display: none;">Mật khẩu xác nhận không khớp</span>
        </div>
        
        <div style="margin-top: 12px; display: flex; gap: 12px; justify-content: flex-end;">
          <a href="${pageContext.request.contextPath}/home" class="premium-btn-outline" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; line-height: 44px; box-sizing: border-box;">Hủy bỏ</a>
          <button type="submit" class="premium-btn-primary">Cập nhật mật khẩu</button>
        </div>
      </form>
    </div>
    
    <!-- Right Column: Navigation options & Login Sessions -->
    <div class="profile-btn-stack">
      <div class="premium-card" style="padding: 24px;">
        <div style="display: flex; flex-direction: column; gap: 12px;">
          <!-- Inactive Button 1: Cài đặt hồ sơ -->
          <a href="${pageContext.request.contextPath}/profile" class="profile-nav-btn profile-nav-btn--inactive">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 15C13.6569 15 15 13.6569 15 12C15 10.3431 13.6569 9 12 9C10.3431 9 9 10.3431 9 12C9 13.6569 10.3431 15 12 15Z" stroke="currentColor" stroke-width="2"/>
              <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" stroke="currentColor" stroke-width="2"/>
            </svg>
            Cài đặt hồ sơ
          </a>
          
          <!-- Active Button 2: Đổi mật khẩu -->
          <a href="${pageContext.request.contextPath}/change-password" class="profile-nav-btn profile-nav-btn--active">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3M15.5 7.5L19 4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            Đổi mật khẩu
          </a>
          
          <!-- Inactive Button 3: Hoạt động -->
          <a href="#" class="profile-nav-btn profile-nav-btn--inactive">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 21a9 9 0 1 0 0-18 9 9 0 0 0 0 18z" stroke="currentColor" stroke-width="2"/>
              <path d="M12 6v6l4 2" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            </svg>
            Hoạt động
          </a>
        </div>
      </div>
      
      <!-- Session Card -->
      <div class="session-card">
        <h3>Phiên đăng nhập</h3>
        <p>Đăng nhập gần nhất: 12:35, 23/10/2023</p>
        <p>Địa chỉ IP: 192.168.1.100</p>
      </div>
    </div>
  </div>
</div>

<script>
document.getElementById('changePasswordForm').addEventListener('submit', function(e) {
  var newPass = document.getElementById('newPassword').value;
  var confirmPass = document.getElementById('confirmPassword').value;
  var errorSpan = document.getElementById('passwordError');
  var strengthRegex = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$/;
  if (!strengthRegex.test(newPass)) {
    e.preventDefault();
    errorSpan.innerText = 'Mật khẩu phải từ 8 ký tự, bao gồm chữ hoa, chữ thường và chữ số';
    errorSpan.style.display = 'block';
  } else if (newPass !== confirmPass) {
    e.preventDefault();
    errorSpan.innerText = 'Mật khẩu xác nhận không khớp';
    errorSpan.style.display = 'block';
  } else {
    errorSpan.style.display = 'none';
  }
});
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
