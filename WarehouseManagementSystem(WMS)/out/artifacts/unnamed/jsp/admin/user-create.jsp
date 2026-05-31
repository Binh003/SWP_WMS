<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Thêm thành viên" scope="request"/>
<c:set var="activePage" value="users" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
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
          <p style="margin: 4px 0 0 0; font-size: 13px; color: var(--text-secondary);">Mật khẩu nên có ít nhất 6 ký tự.</p>
        </div>
      </div>

      <form method="post" action="${pageContext.request.contextPath}/admin/users" style="display: flex; flex-direction: column; gap: 20px;">
        <input type="hidden" name="action" value="create"/>

        <div class="form-group">
          <label class="form-label">Tên đăng nhập (Username)</label>
          <input name="username" class="subpage-input" placeholder="Nhập tên đăng nhập" required/>
        </div>

        <div class="form-group">
          <label class="form-label">Họ và tên</label>
          <input name="fullName" class="subpage-input" placeholder="Nhập họ và tên" required/>
        </div>

        <div class="form-group">
          <label class="form-label">Email</label>
          <input name="email" type="email" class="subpage-input" placeholder="Nhập địa chỉ email" required/>
        </div>

        <div class="form-group">
          <label class="form-label">Mật khẩu</label>
          <input name="password" type="password" class="subpage-input" placeholder="Nhập mật khẩu (tối thiểu 6 ký tự)" minlength="6" required/>
        </div>

        <div class="form-group">
          <label class="form-label">Vai trò thành viên</label>
          <div style="display: flex; gap: 12px; align-items: center; flex-wrap: wrap;">
            <c:forEach var="role" items="${roles}">
              <label style="display: inline-flex; align-items: center; gap: 8px; cursor: pointer; background: #ffffff; padding: 8px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-weight: 600; font-size: 14px; transition: all 0.2s;">
                <input type="checkbox" name="roleCodes" value="${role.code}" style="cursor: pointer; width: 16px; height: 16px; accent-color: var(--primary-color);"/>
                <span>${role.code}</span>
              </label>
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
          <li><strong>ADMIN:</strong> Quản trị viên, có toàn quyền quản lý hệ thống, cấu hình vai trò, duyệt tài khoản.</li>
          <li><strong>MANAGER:</strong> Quản lý kho, điều hành các hoạt động xuất nhập tồn và kiểm kho.</li>
          <li><strong>STAFF:</strong> Nhân viên kho, thực hiện các thao tác nhập xuất, cập nhật dữ liệu.</li>
          <li><strong>VIEWER:</strong> Chỉ xem thông tin tổng quan, không có quyền chỉnh sửa.</li>
        </ul>
      </div>
    </div>
  </div>
</div>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
