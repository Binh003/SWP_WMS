<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Cập nhật tài khoản" scope="request"/>
<c:set var="activePage" value="users" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 16px;">
    <a href="${pageContext.request.contextPath}/admin/users" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
      Quay lại danh sách tài khoản
    </a>
  </div>
  <div class="subpage-header" style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px;">
    <div class="subpage-header__title">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Cập nhật tài khoản</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Thay đổi thông tin hồ sơ và quyền hạn của thành viên.</p>
    </div>
  </div>

  <div class="profile-layout-grid">
    <!-- Left Column: Form -->
    <div class="premium-card" style="padding: 40px 32px 32px 32px;">
      <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 32px; padding-bottom: 16px; border-bottom: 1px solid var(--card-border);">
        <div style="display: flex; align-items: center; justify-content: center; width: 48px; height: 48px; border-radius: 12px; background: rgba(4, 138, 191, 0.1); color: var(--primary-color);">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
            <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
          </svg>
        </div>
        <div>
          <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">Chỉnh sửa thành viên: <span style="color: var(--primary-color);">${user.username}</span></h3>
          <p style="margin: 4px 0 0 0; font-size: 13px; color: var(--text-secondary);">Cập nhật các thông tin cơ bản hoặc khóa tài khoản.</p>
        </div>
      </div>

      <form method="post" action="${pageContext.request.contextPath}/admin/users" style="display: flex; flex-direction: column; gap: 20px;">
        <input type="hidden" name="action" value="update"/>
        <input type="hidden" name="id" value="${user.id}"/>

        <div class="form-group">
          <label class="form-label">Tên đăng nhập (Không thể thay đổi)</label>
          <input class="subpage-input" value="${user.username}" disabled style="background-color: #f1f5f9; cursor: not-allowed;"/>
        </div>

        <div class="form-group">
          <label class="form-label">Họ và tên</label>
          <input name="fullName" value="${user.fullName}" class="subpage-input" placeholder="Nhập họ và tên" required/>
        </div>

        <div class="form-group">
          <label class="form-label">Email</label>
          <input name="email" type="email" value="${user.email}" class="subpage-input" placeholder="Nhập địa chỉ email" required/>
        </div>

        <div class="form-group">
          <label class="form-label">Mật khẩu mới (Để trống nếu không muốn thay đổi)</label>
          <div style="position: relative;">
            <input id="password" name="password" type="password" class="subpage-input" style="padding-right: 46px;" placeholder="Tối thiểu 8 ký tự (hoa, thường, số)" minlength="8" pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}" title="Mật khẩu phải từ 8 ký tự, bao gồm ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số."/>
            <button type="button" class="password-toggle" onclick="togglePassword('password', 'eyeSvg')" style="position: absolute; right: 14px; top: 50%; transform: translateY(-50%); border: 0; background: transparent; color: #9ca3af; cursor: pointer; padding: 0; display: inline-flex; align-items: center; justify-content: center; transition: color 0.15s ease;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='#9ca3af'">
              <svg id="eyeSvg" class="eye" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 19c-7 0-11-7-11-7a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 7 11 7a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
                <line x1="1" y1="1" x2="23" y2="23" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>
              </svg>
            </button>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">Xác nhận mật khẩu mới</label>
          <div style="position: relative;">
            <input id="confirmPassword" name="confirmPassword" type="password" class="subpage-input" style="padding-right: 46px;" placeholder="Nhập lại mật khẩu mới" minlength="8" pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}" title="Mật khẩu phải từ 8 ký tự, bao gồm ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số."/>
            <button type="button" class="password-toggle" onclick="togglePassword('confirmPassword', 'confirmEyeSvg')" style="position: absolute; right: 14px; top: 50%; transform: translateY(-50%); border: 0; background: transparent; color: #9ca3af; cursor: pointer; padding: 0; display: inline-flex; align-items: center; justify-content: center; transition: color 0.15s ease;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='#9ca3af'">
              <svg id="confirmEyeSvg" class="eye" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 19c-7 0-11-7-11-7a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 7 11 7a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
                <line x1="1" y1="1" x2="23" y2="23" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>
              </svg>
            </button>
          </div>
          <span id="passwordError" style="color: #ef4444; font-size: 13px; margin-top: 6px; display: none;">Mật khẩu xác nhận không khớp</span>
        </div>

        <div class="form-group">
          <label class="form-label">Vai trò thành viên</label>
          <div style="display: flex; gap: 12px; align-items: center; flex-wrap: wrap;">
            <c:forEach var="role" items="${roles}">
              <c:if test="${role.code != 'ADMIN'}">
                <label style="display: inline-flex; align-items: center; gap: 8px; cursor: pointer; background: #ffffff; padding: 8px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-weight: 600; font-size: 14px; transition: all 0.2s;">
                  <input type="radio" name="roleCodes" value="${role.code}" style="cursor: pointer; width: 16px; height: 16px; accent-color: var(--primary-color);"
                    <c:forEach var="ur" items="${user.roles}"><c:if test="${ur.code == role.code}">checked</c:if></c:forEach>
                  />
                  <span>${role.code}</span>
                </label>
              </c:if>
            </c:forEach>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">Trạng thái tài khoản</label>
          <select name="status" class="subpage-input" style="width: 100%; max-width: 250px; background-color: #ffffff; cursor: pointer; border: 1.5px solid var(--card-border); border-radius: 10px; padding: 10px 16px; outline: none; font-size: 14px; font-weight: 600;">
            <option value="ACTIVE" ${user.status == 'ACTIVE' ? 'selected' : ''}>Đang hoạt động</option>
            <option value="LOCKED" ${user.status == 'LOCKED' ? 'selected' : ''}>Bị khóa</option>
            <option value="PENDING" ${user.status == 'PENDING' ? 'selected' : ''}>Chờ phê duyệt</option>
          </select>
        </div>

        <div style="margin-top: 12px; display: flex; gap: 12px; justify-content: flex-end;">
          <a href="${pageContext.request.contextPath}/admin/users" class="premium-btn-outline" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; line-height: 44px; box-sizing: border-box;">Hủy bỏ</a>
          <button type="submit" class="premium-btn-primary">Lưu thay đổi</button>
        </div>
      </form>
    </div>

    <!-- Right Column: Helper info card -->
    <div class="profile-btn-stack">
      <div class="premium-card" style="padding: 24px;">
        <h3 style="margin: 0 0 12px 0; font-size: 16px; font-weight: 700; color: var(--text-primary);">Thông tin phiên hoạt động</h3>
        <p style="margin: 8px 0; font-size: 14px; color: var(--text-secondary);">Trạng thái tài khoản hiện tại: 
          <c:choose>
            <c:when test="${user.status == 'ACTIVE'}">
              <span class="premium-tag premium-tag--success" style="font-size: 11px; margin-left: 6px;">Kích hoạt</span>
            </c:when>
            <c:when test="${user.status == 'LOCKED'}">
              <span class="premium-tag premium-tag--danger" style="font-size: 11px; margin-left: 6px;">Bị khóa</span>
            </c:when>
            <c:otherwise>
              <span class="premium-tag premium-tag--warning" style="font-size: 11px; margin-left: 6px;">Chờ phê duyệt</span>
            </c:otherwise>
          </c:choose>
        </p>
        <p style="margin: 8px 0; font-size: 14px; color: var(--text-secondary);">Vai trò hiện tại: <strong>${not empty user.roles ? user.roles[0].code : 'Chưa có'}</strong></p>
      </div>
    </div>
  </div>
</div>

<script>
function togglePassword(inputId, eyeId) {
  var input = document.getElementById(inputId);
  var eyeSvg = document.getElementById(eyeId);
  if (!input || !eyeSvg) return;
  if (input.type === 'password') {
    input.type = 'text';
    eyeSvg.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/><circle cx="12" cy="12" r="3" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>';
  } else {
    input.type = 'password';
    eyeSvg.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 19c-7 0-11-7-11-7a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 7 11 7a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/><line x1="1" y1="1" x2="23" y2="23" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>';
  }
}

document.querySelector('form').addEventListener('submit', function(e) {
  var pass = document.getElementById('password').value;
  var confirmPass = document.getElementById('confirmPassword').value;
  var errorSpan = document.getElementById('passwordError');
  
  if (pass.length > 0) {
    var strengthRegex = /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}$/;
    if (!strengthRegex.test(pass)) {
      e.preventDefault();
      errorSpan.innerText = 'Mật khẩu phải từ 8 ký tự, bao gồm chữ hoa, chữ thường và chữ số';
      errorSpan.style.display = 'block';
    } else if (pass !== confirmPass) {
      e.preventDefault();
      errorSpan.innerText = 'Mật khẩu xác nhận không khớp';
      errorSpan.style.display = 'block';
    } else {
      errorSpan.style.display = 'none';
    }
  } else {
    errorSpan.style.display = 'none';
  }
});
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
