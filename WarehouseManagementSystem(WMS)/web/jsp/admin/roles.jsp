<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quản lý vai trò" scope="request"/>
<c:set var="activePage" value="roles" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="margin-bottom: 24px;">
    <div class="subpage-header__title">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Quản lý vai trò & Quyền hạn</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Quản lý danh sách vai trò và phân quyền tương ứng trên hệ thống.</p>
    </div>
  </div>

  <div class="roles-grid">
    <!-- Left Column: Role Selector List -->
    <div class="premium-card role-select-card" style="padding: 24px;">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
        <h3 style="margin: 0; font-size: 16px; font-weight: 700; color: var(--text-primary); display: flex; align-items: center; gap: 8px;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polygon points="12 2 2 7 12 12 22 7 12 2"></polygon>
            <polyline points="2 17 12 22 22 17"></polyline>
            <polyline points="2 12 12 17 22 12"></polyline>
          </svg>
          Vai trò đang hiện có
        </h3>
        <a href="${pageContext.request.contextPath}/admin/roles?action=create" 
           class="premium-btn-primary" 
           style="height: 32px; line-height: 32px; padding: 0 12px; font-size: 12px; border-radius: 8px; text-decoration: none; display: inline-flex; align-items: center; gap: 4px;">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Thêm
        </a>
      </div>
      
      <div class="roles-list" style="display: flex; flex-direction: column; gap: 10px;">
        <c:forEach var="r" items="${roles}">
          <a href="${pageContext.request.contextPath}/admin/roles?id=${r.id}" 
             style="text-decoration: none;"
             class="role-item-link ${r.id == selectedRoleId && !isCreateMode ? 'role-item-link--active' : ''}">
            <span>${r.code}</span>
            <span class="premium-tag ${r.enabled ? 'premium-tag--success' : 'premium-tag--danger'}" style="font-size: 10px; padding: 2px 8px; font-weight: 700;">
              ${r.enabled ? 'Mở' : 'Khóa'}
            </span>
          </a>
        </c:forEach>
      </div>
    </div>

    <!-- Right Column: Detail Editor Form -->
    <div class="premium-card role-detail-card" style="padding: 32px;">
      <c:choose>
        <c:when test="${isCreateMode}">
          <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 28px; padding-bottom: 16px; border-bottom: 1px solid var(--card-border);">
            <div style="display: flex; align-items: center; justify-content: center; width: 44px; height: 44px; border-radius: 10px; background: rgba(5, 150, 105, 0.1); color: #059669;">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
              </svg>
            </div>
            <div>
              <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">Tạo vai trò mới</h3>
              <p style="margin: 4px 0 0 0; font-size: 13px; color: var(--text-secondary);">Thiết lập mã vai trò định danh duy nhất và phân quyền hạn ban đầu.</p>
            </div>
          </div>

          <form method="post" action="${pageContext.request.contextPath}/admin/roles" style="display: flex; flex-direction: column; gap: 20px;">
            <input type="hidden" name="action" value="create"/>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
              <div class="form-group">
                <label class="form-label">Mã vai trò (Chữ in hoa, không cách)</label>
                <input name="code" class="subpage-input" placeholder="Ví dụ: WAREHOUSE_LEAD" required pattern="^[A-Z0-9_]+$" title="Chỉ chứa ký tự chữ in hoa, chữ số và gạch dưới"/>
              </div>

              <div class="form-group">
                <label class="form-label">Tên hiển thị</label>
                <input name="name" class="subpage-input" placeholder="Nhập tên hiển thị" required/>
              </div>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
              <div class="form-group">
                <label class="form-label">Mô tả vai trò</label>
                <input name="description" class="subpage-input" placeholder="Mô tả chức năng của vai trò này"/>
              </div>

              <div class="form-group">
                <label class="form-label">Trạng thái hoạt động</label>
                <div style="display: flex; align-items: center; margin-top: 4px;">
                  <label style="display: inline-flex; align-items: center; gap: 8px; cursor: pointer; background: #ffffff; padding: 8px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-weight: 600; font-size: 14px; transition: all 0.2s;">
                    <input type="checkbox" name="enabled" value="true" checked style="cursor: pointer; width: 16px; height: 16px; accent-color: var(--primary-color);"/>
                    <span>Kích hoạt vai trò này</span>
                  </label>
                </div>
              </div>
            </div>

            <div class="form-group" style="margin-top: 10px;">
              <label class="form-label" style="margin-bottom: 12px;">Quyền hạn chi tiết (Permissions)</label>
              <div class="perm-grid">
                <c:forEach var="p" items="${permissions}">
                  <label class="perm-card-label" style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; padding: 14px; border: 1.5px solid var(--card-border); border-radius: 12px; background: #ffffff; transition: all 0.2s;">
                    <input type="checkbox" name="permissionCodes" value="${p[1]}" style="margin-top: 3px; cursor: pointer; width: 16px; height: 16px; accent-color: var(--primary-color);"/>
                    <div style="flex: 1;">
                      <strong style="color: var(--text-primary); font-size: 13.5px; display: block; margin-bottom: 2px;">${p[1]}</strong>
                      <span style="color: var(--text-secondary); font-size: 12px; line-height: 1.4; display: block;">${p[2]}</span>
                    </div>
                  </label>
                </c:forEach>
              </div>
            </div>

            <div style="margin-top: 12px; display: flex; justify-content: flex-end; gap: 12px;">
              <a href="${pageContext.request.contextPath}/admin/roles" class="premium-btn-secondary" style="height: 44px; line-height: 44px; padding: 0 24px; text-decoration: none; text-align: center;">Hủy bỏ</a>
              <button type="submit" class="premium-btn-primary" style="height: 44px; line-height: 44px; padding: 0 32px;">Tạo vai trò</button>
            </div>
          </form>
        </c:when>

        <c:when test="${selectedRole != null}">
          <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 28px; padding-bottom: 16px; border-bottom: 1px solid var(--card-border);">
            <div style="display: flex; align-items: center; justify-content: center; width: 44px; height: 44px; border-radius: 10px; background: rgba(4, 138, 191, 0.1); color: var(--primary-color);">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
              </svg>
            </div>
            <div>
              <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">Thiết lập vai trò: <span style="color: var(--primary-color);">${selectedRole.code}</span></h3>
              <p style="margin: 4px 0 0 0; font-size: 13px; color: var(--text-secondary);">Thay đổi thông tin mô tả và gán các quyền nghiệp vụ chi tiết.</p>
            </div>
          </div>

          <form method="post" action="${pageContext.request.contextPath}/admin/roles" style="display: flex; flex-direction: column; gap: 20px;">
            <input type="hidden" name="id" value="${selectedRole.id}"/>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
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
              <div style="display: flex; align-items: center;">
                <label style="display: inline-flex; align-items: center; gap: 8px; cursor: pointer; background: #ffffff; padding: 8px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-weight: 600; font-size: 14px; transition: all 0.2s;">
                  <input type="checkbox" name="enabled" value="true" style="cursor: pointer; width: 16px; height: 16px; accent-color: var(--primary-color);" ${selectedRole.enabled ? 'checked' : ''}/>
                  <span>Kích hoạt vai trò này</span>
                </label>
              </div>
            </div>

            <div class="form-group">
              <label class="form-label" style="margin-bottom: 12px;">Quyền hạn chi tiết (Permissions)</label>
              <div class="perm-grid">
                <c:forEach var="p" items="${permissions}">
                  <label class="perm-card-label" style="display: flex; align-items: flex-start; gap: 10px; cursor: pointer; padding: 14px; border: 1.5px solid var(--card-border); border-radius: 12px; background: #ffffff; transition: all 0.2s;">
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

            <div style="margin-top: 12px; display: flex; justify-content: space-between; align-items: center; gap: 12px;">
              <div>
                <c:if test="${selectedRole.code != 'ADMIN'}">
                  <button type="button" class="premium-btn-secondary" 
                          onclick="if(confirm('Bạn có chắc chắn muốn xóa vai trò này? Tất cả các liên kết tài khoản sẽ bị gỡ bỏ.')) { document.getElementById('delete-role-form').submit(); }"
                          style="height: 44px; line-height: 44px; padding: 0 24px; border-color: #ef4444; color: #ef4444; background: transparent;">
                    Xóa vai trò
                  </button>
                </c:if>
              </div>
              <div style="display: flex; gap: 12px;">
                <button type="submit" class="premium-btn-primary" style="height: 44px; line-height: 44px; padding: 0 32px;">Lưu cấu hình</button>
              </div>
            </div>
          </form>

          <form id="delete-role-form" method="post" action="${pageContext.request.contextPath}/admin/roles" style="display: none;">
            <input type="hidden" name="action" value="delete"/>
            <input type="hidden" name="id" value="${selectedRole.id}"/>
          </form>
        </c:when>
        
        <c:otherwise>
          <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 80px 20px; text-align: center; color: var(--text-secondary);">
            <div style="display: flex; align-items: center; justify-content: center; width: 64px; height: 64px; border-radius: 50%; background: #f1f5f9; color: var(--text-tertiary); margin-bottom: 16px;">
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
              </svg>
            </div>
            <h4 style="margin: 0 0 8px 0; font-size: 16px; font-weight: 700; color: var(--text-primary);">Chưa chọn vai trò</h4>
            <p style="margin: 0; font-size: 14px; max-width: 320px; line-height: 1.5;">Vui lòng lựa chọn một vai trò ở danh sách bên trái hoặc nhấn thêm mới để bắt đầu thiết lập.</p>
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</div>

<style>
  .role-item-link {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 18px;
    border-radius: 12px;
    border: 1.5px solid var(--card-border);
    background: #ffffff;
    text-decoration: none;
    color: var(--text-primary);
    transition: all 0.2s;
    font-weight: 600;
  }
  .role-item-link:hover {
    border-color: var(--primary-color) !important;
    background: rgba(4, 138, 191, 0.02) !important;
    transform: translateX(4px);
  }
  .role-item-link--active {
    border-color: var(--primary-color) !important;
    background: rgba(4, 138, 191, 0.04) !important;
  }
  .perm-card-label:hover {
    border-color: var(--primary-color) !important;
    background: rgba(4, 138, 191, 0.02) !important;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.02);
  }
  .perm-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 12px;
  }
  .premium-tag--danger {
    background: rgba(239, 68, 68, 0.1) !important;
    color: #ef4444 !important;
  }
</style>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
