<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Thêm thành viên" scope="request"/>
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
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Thêm thành viên</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Tạo tài khoản mới và gán vai trò ban đầu.</p>
    </div>
  </div>

  <div class="profile-layout-grid">
    <!-- Left Column: Form -->
    <div class="premium-card" style="padding: 40px 32px 32px 32px;">
      <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 32px; padding-bottom: 16px; border-bottom: 1px solid var(--card-border);">
        <div style="display: flex; align-items: center; justify-content: center; width: 48px; height: 48px; border-radius: 12px; background: rgba(4, 138, 191, 0.1); color: var(--primary-color);">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
            <circle cx="9" cy="7" r="4"></circle>
            <line x1="20" y1="8" x2="20" y2="14"></line>
            <line x1="23" y1="11" x2="17" y2="11"></line>
          </svg>
        </div>
        <div>
          <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">Thông tin tài khoản</h3>
          <p style="margin: 4px 0 0 0; font-size: 13px; color: var(--text-secondary);">Mật khẩu phải từ 8 ký tự, bao gồm chữ hoa, chữ thường và chữ số.</p>
        </div>
      </div>

      <form id="createUserForm" method="post" action="${pageContext.request.contextPath}/admin/users" style="display: flex; flex-direction: column; gap: 20px;">
        <input type="hidden" name="action" value="create"/>

        <div class="form-group">
          <label class="form-label">Tên đăng nhập (Username)</label>
          <input name="username" value="${username}" class="subpage-input" placeholder="Nhập tên đăng nhập" required/>
        </div>

        <div class="form-group">
          <label class="form-label">Họ và tên</label>
          <input name="fullName" value="${fullName}" class="subpage-input" placeholder="Nhập họ và tên" required/>
        </div>

        <div class="form-group">
          <label class="form-label">Email</label>
          <input name="email" type="email" value="${email}" class="subpage-input" placeholder="Nhập địa chỉ email" required/>
        </div>

        <div class="form-group">
          <label class="form-label">Mật khẩu</label>
          <div style="position: relative;">
            <input id="password" name="password" type="password" class="subpage-input" style="padding-right: 46px;" placeholder="Tối thiểu 8 ký tự (hoa, thường, số)" minlength="8" pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}" title="Mật khẩu phải từ 8 ký tự, bao gồm ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số." required/>
            <button type="button" class="password-toggle" onclick="togglePassword('password', 'eyeSvg')" style="position: absolute; right: 14px; top: 50%; transform: translateY(-50%); border: 0; background: transparent; color: #9ca3af; cursor: pointer; padding: 0; display: inline-flex; align-items: center; justify-content: center; transition: color 0.15s ease;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='#9ca3af'">
              <svg id="eyeSvg" class="eye" width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 19c-7 0-11-7-11-7a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 7 11 7a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"/>
                <line x1="1" y1="1" x2="23" y2="23" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"/>
              </svg>
            </button>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">Xác nhận mật khẩu</label>
          <div style="position: relative;">
            <input id="confirmPassword" name="confirmPassword" type="password" class="subpage-input" style="padding-right: 46px;" placeholder="Nhập lại mật khẩu" minlength="8" pattern="(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{8,}" title="Mật khẩu phải từ 8 ký tự, bao gồm ít nhất 1 chữ hoa, 1 chữ thường và 1 chữ số." required/>
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
                    <c:choose>
                      <c:when test="${empty roleCodes}">
                        <c:if test="${role.code == 'WAREHOUSE STAFF'}">checked</c:if>
                      </c:when>
                      <c:otherwise>
                        <c:forEach var="code" items="${roleCodes}"><c:if test="${code == role.code}">checked</c:if></c:forEach>
                      </c:otherwise>
                    </c:choose>
                  />
                  <span>${role.code}</span>
                </label>
              </c:if>
            </c:forEach>
          </div>
        </div>

        <div style="margin-top: 12px; display: flex; gap: 12px; justify-content: flex-end;">
          <a href="${pageContext.request.contextPath}/admin/users" class="premium-btn-outline" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; line-height: 44px; box-sizing: border-box;">Hủy bỏ</a>
          <button type="submit" class="premium-btn-primary">Tạo tài khoản</button>
        </div>
      </form>
    </div>

    <!-- Right Column: Helper / Stack info card -->
    <div class="profile-btn-stack">
      <div class="premium-card" style="padding: 24px;">
        <h3 style="margin: 0 0 12px 0; font-size: 16px; font-weight: 700; color: var(--text-primary);">Quy định phân quyền</h3>
        <p style="margin: 0 0 12px 0; font-size: 14px; color: var(--text-secondary); line-height: 1.6;">Mỗi vai trò (Role) sẽ có các quyền hạn khác nhau trên hệ thống quản lý kho (WMS):</p>
        <ul style="margin: 0; padding-left: 20px; font-size: 13px; color: var(--text-secondary); line-height: 1.8;">
          <li><strong>ADMIN:</strong> Quản trị viên hệ thống.</li>
          <li><strong>WAREHOUSE MANAGER:</strong> Quản lý kho, điều hành xuất nhập, quản lý tồn kho và phê duyệt.</li>
          <li><strong>WAREHOUSE STAFF:</strong> Nhân viên kho, thực hiện kiểm đếm và nhận/xuất hàng.</li>
          <li><strong>PURCHASING STAFF:</strong> Nhân viên mua hàng, quản lý nhà cung cấp và lập phiếu nhập kho.</li>
          <li><strong>SALES STAFF:</strong> Nhân viên bán hàng, lập phiếu xuất bán hàng.</li>
        </ul>
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

document.getElementById('createUserForm').addEventListener('submit', function(e) {
  var pass = document.getElementById('password').value;
  var confirmPass = document.getElementById('confirmPassword').value;
  var errorSpan = document.getElementById('passwordError');
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
});
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
