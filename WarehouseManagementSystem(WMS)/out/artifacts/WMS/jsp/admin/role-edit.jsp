<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Thiết lập vai trò" scope="request"/>
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
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Thiết lập vai trò</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Thay đổi thông tin hiển thị và gán các quyền hạn chi tiết cho vai trò này.</p>
    </div>
  </div>

  <div class="premium-card" style="padding: 32px;">
    <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 28px; padding-bottom: 16px; border-bottom: 1px solid var(--card-border);">
      <div style="display: flex; align-items: center; justify-content: center; width: 44px; height: 44px; border-radius: 10px; background: rgba(4, 138, 191, 0.1); color: var(--primary-color);">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
        </svg>
      </div>
      <div>
        <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">Vai trò: <span style="color: var(--primary-color);">${selectedRole.code}</span></h3>
        <p style="margin: 4px 0 0 0; font-size: 13px; color: var(--text-secondary);">Thiết lập mô tả, trạng thái hoạt động và các phân quyền cụ thể.</p>
      </div>
    </div>

    <form method="post" action="${pageContext.request.contextPath}/admin/roles" style="display: flex; flex-direction: column; gap: 24px;">
      <input type="hidden" name="id" value="${selectedRole.id}"/>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <div class="form-group">
          <label class="form-label">Tên hiển thị</label>
          <input name="name" value="${selectedRole.name}" class="subpage-input" placeholder="Nhập tên hiển thị" required/>
        </div>

        <div class="form-group">
          <label class="form-label">Mô tả vai trò</label>
          <input name="description" value="${selectedRole.description}" class="subpage-input" placeholder="Mô tả chức năng của vai trò này"/>
        </div>
      </div>

      <div class="form-group">
        <label class="form-label">Trạng thái hoạt động</label>
        <div style="display: flex; align-items: center; margin-top: 4px;">
          <label style="display: inline-flex; align-items: center; gap: 8px; cursor: pointer; background: #ffffff; padding: 10px 18px; border: 1.5px solid var(--card-border); border-radius: 10px; font-weight: 600; font-size: 14px; transition: all 0.2s;">
            <input type="checkbox" name="enabled" value="true" style="cursor: pointer; width: 16px; height: 16px; accent-color: var(--primary-color);" ${selectedRole.enabled ? 'checked' : ''}/>
            <span>Kích hoạt vai trò này</span>
          </label>
        </div>
      </div>

      <div class="form-group" style="margin-top: 8px;">
        <label class="form-label" style="margin-bottom: 12px; display: block;">Quyền hạn chi tiết (Permissions)</label>
        <div class="perm-grid">
          <c:forEach var="p" items="${permissions}">
            <label class="perm-card-label" style="display: flex; align-items: flex-start; gap: 12px; cursor: pointer; padding: 14px; border: 1.5px solid var(--card-border); border-radius: 12px; background: #ffffff; transition: all 0.2s;">
              <input type="checkbox" name="permissionCodes" value="${p[1]}" style="margin-top: 3px; cursor: pointer; width: 16px; height: 16px; accent-color: var(--primary-color);"
                <c:forEach var="pc" items="${selectedRole.permissionCodes}">
                  <c:if test="${pc == p[1]}">checked</c:if>
                </c:forEach>
              />
              <div style="flex: 1;">
                <strong style="color: var(--text-primary); font-size: 13.5px; display: block; margin-bottom: 2px;">${p[1]}</strong>
                <span style="color: var(--text-secondary); font-size: 12px; line-height: 1.4; display: block;">${p[2]}</span>
              </div>
            </label>
          </c:forEach>
        </div>
      </div>

      <div style="margin-top: 12px; display: flex; justify-content: flex-end; align-items: center; border-top: 1px solid var(--card-border); padding-top: 24px; gap: 12px;">
        <div style="display: flex; gap: 12px;">
          <a href="${pageContext.request.contextPath}/admin/roles" class="premium-btn-secondary" style="height: 44px; line-height: 44px; padding: 0 24px; text-decoration: none; text-align: center; display: inline-flex; align-items: center; justify-content: center; box-sizing: border-box;">Hủy bỏ</a>
          <button type="submit" class="premium-btn-primary" style="height: 44px; line-height: 44px; padding: 0 32px;">Lưu cấu hình</button>
        </div>
      </div>
    </form>

    <form id="delete-role-form" method="post" action="${pageContext.request.contextPath}/admin/roles" style="display: none;">
      <input type="hidden" name="action" value="delete"/>
      <input type="hidden" name="id" value="${selectedRole.id}"/>
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
