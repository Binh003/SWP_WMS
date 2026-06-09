<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Tạo vai trò mới" scope="request"/>
<c:set var="activePage" value="roles" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 16px;">
    <a href="${pageContext.request.contextPath}/admin/roles" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
      Quay lại danh sách vai trò
    </a>
  </div>
  <div class="subpage-header" style="margin-bottom: 24px;">
    <div class="subpage-header__title">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Tạo vai trò mới</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Thiết lập mã vai trò định danh duy nhất và phân quyền hạn ban đầu.</p>
    </div>
  </div>

  <div class="premium-card" style="padding: 32px;">
    <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 28px; padding-bottom: 16px; border-bottom: 1px solid var(--card-border);">
      <div style="display: flex; align-items: center; justify-content: center; width: 44px; height: 44px; border-radius: 10px; background: rgba(5, 150, 105, 0.1); color: #059669;">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
        </svg>
      </div>
      <div>
        <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">Thông tin vai trò</h3>
        <p style="margin: 4px 0 0 0; font-size: 13px; color: var(--text-secondary);">Mã vai trò phải là duy nhất và viết hoa không dấu.</p>
      </div>
    </div>

    <form method="post" action="${pageContext.request.contextPath}/admin/roles" style="display: flex; flex-direction: column; gap: 24px;">
      <input type="hidden" name="action" value="create"/>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <div class="form-group">
          <label class="form-label">Mã vai trò (Chữ in hoa, không cách)</label>
          <input name="code" class="subpage-input" placeholder="Ví dụ: WAREHOUSE_LEAD" required pattern="^[A-Z0-9_]+$" title="Chỉ chứa ký tự chữ in hoa, chữ số và gạch dưới"/>
        </div>

        <div class="form-group">
          <label class="form-label">Tên hiển thị</label>
          <input name="name" class="subpage-input" placeholder="Nhập tên hiển thị vai trò" required/>
        </div>
      </div>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <div class="form-group">
          <label class="form-label">Mô tả vai trò</label>
          <input name="description" class="subpage-input" placeholder="Mô tả tóm tắt chức năng của vai trò"/>
        </div>

        <div class="form-group">
          <label class="form-label">Trạng thái hoạt động</label>
          <div style="display: flex; align-items: center; margin-top: 4px;">
            <label style="display: inline-flex; align-items: center; gap: 8px; cursor: pointer; background: #ffffff; padding: 10px 18px; border: 1.5px solid var(--card-border); border-radius: 10px; font-weight: 600; font-size: 14px; transition: all 0.2s;">
              <input type="checkbox" name="enabled" value="true" checked style="cursor: pointer; width: 16px; height: 16px; accent-color: var(--primary-color);"/>
              <span>Kích hoạt vai trò này</span>
            </label>
          </div>
        </div>
      </div>

      <div class="form-group" style="margin-top: 8px;">
        <label class="form-label" style="margin-bottom: 12px; display: block;">Quyền hạn chi tiết (Permissions)</label>
        <div class="perm-grid">
          <c:forEach var="p" items="${permissions}">
            <label class="perm-card-label" style="display: flex; align-items: flex-start; gap: 12px; cursor: pointer; padding: 14px; border: 1.5px solid var(--card-border); border-radius: 12px; background: #ffffff; transition: all 0.2s;">
              <input type="checkbox" name="permissionCodes" value="${p[1]}" style="margin-top: 3px; cursor: pointer; width: 16px; height: 16px; accent-color: var(--primary-color);"/>
              <div style="flex: 1;">
                <strong style="color: var(--text-primary); font-size: 13.5px; display: block; margin-bottom: 2px;">${p[1]}</strong>
                <span style="color: var(--text-secondary); font-size: 12px; line-height: 1.4; display: block;">${p[2]}</span>
              </div>
            </label>
          </c:forEach>
        </div>
      </div>

      <div style="margin-top: 12px; display: flex; justify-content: flex-end; gap: 12px; border-top: 1px solid var(--card-border); padding-top: 24px;">
        <a href="${pageContext.request.contextPath}/admin/roles" class="premium-btn-secondary" style="height: 44px; line-height: 44px; padding: 0 24px; text-decoration: none; text-align: center; display: inline-flex; align-items: center; justify-content: center; box-sizing: border-box;">Hủy bỏ</a>
        <button type="submit" class="premium-btn-primary" style="height: 44px; line-height: 44px; padding: 0 32px;">Tạo vai trò</button>
      </div>
    </form>
  </div>
</div>

<style>
  .perm-card-label:hover {
    border-color: var(--primary-color) !important;
    background: rgba(4, 138, 191, 0.02) !important;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.02);
  }
  .perm-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 16px;
  }
</style>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
