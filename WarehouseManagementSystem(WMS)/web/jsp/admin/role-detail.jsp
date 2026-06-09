<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Chi tiết vai trò" scope="request"/>
<c:set var="activePage" value="roles" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 20px;">
    <a href="${pageContext.request.contextPath}/admin/roles" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
      Quay lại danh sách vai trò
    </a>
  </div>

  <div class="subpage-header" style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 28px;">
    <div class="subpage-header__title">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Thông tin chi tiết vai trò</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Xem mã vai trò, thông tin mô tả và danh sách quyền hạn chi tiết.</p>
    </div>
    <div>
      <c:if test="${currentUser.hasRole('ADMIN') || currentUser.hasPermission('ROLE_WRITE')}">
        <c:if test="${selectedRole.code != 'ADMIN'}">
          <a href="${pageContext.request.contextPath}/admin/roles?action=edit&id=${selectedRole.id}" class="premium-btn-primary" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; font-size: 14px; font-weight: 600; padding: 10px 20px; border-radius: 10px; background: var(--primary-color); color: #ffffff; transition: opacity 0.2s;">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
              <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
            </svg>
            Chỉnh sửa vai trò
          </a>
        </c:if>
      </c:if>
    </div>
  </div>

  <div class="profile-layout-grid" style="display: grid; grid-template-columns: 1fr 2fr; gap: 28px; align-items: start;">
    <!-- Left Column: Role Details -->
    <div class="premium-card" style="padding: 32px; background: #ffffff; border: 1.5px solid var(--card-border); border-radius: 16px;">
      <div style="display: flex; flex-direction: column; align-items: center; text-align: center; margin-bottom: 24px; padding-bottom: 24px; border-bottom: 1.5px solid var(--card-border);">
        <div style="width: 80px; height: 80px; font-size: 32px; border-radius: 20px; font-weight: 800; display: flex; align-items: center; justify-content: center; background: var(--sidebar-active-bg); color: var(--primary-color); margin-bottom: 16px; text-transform: uppercase;">
          ${selectedRole.code.substring(0, 1)}
        </div>
        <h3 style="margin: 0 0 6px 0; font-size: 20px; font-weight: 700; color: var(--text-primary);"><c:out value="${selectedRole.name}"/></h3>
        <span class="premium-tag" style="background: rgba(4, 138, 191, 0.08); color: var(--primary-color); font-weight: 700; font-family: monospace; font-size: 13px; padding: 4px 10px; border-radius: 6px;">${selectedRole.code}</span>
      </div>

      <div style="display: flex; flex-direction: column; gap: 16px;">
        <div>
          <span style="font-size: 12px; color: var(--text-secondary); text-transform: uppercase; font-weight: 700; display: block; margin-bottom: 4px;">ID Vai trò</span>
          <span style="font-size: 15px; font-weight: 600; color: var(--text-primary);">#${selectedRole.id}</span>
        </div>
        <div>
          <span style="font-size: 12px; color: var(--text-secondary); text-transform: uppercase; font-weight: 700; display: block; margin-bottom: 4px;">Mô tả vai trò</span>
          <span style="font-size: 14.5px; line-height: 1.4; font-weight: 500; color: var(--text-primary);"><c:out value="${selectedRole.description != null ? selectedRole.description : 'Không có mô tả.'}"/></span>
        </div>
        <div>
          <span style="font-size: 12px; color: var(--text-secondary); text-transform: uppercase; font-weight: 700; display: block; margin-bottom: 6px;">Trạng thái hoạt động</span>
          <c:choose>
            <c:when test="${selectedRole.enabled}">
              <span class="premium-tag premium-tag--success" style="font-size: 12px; font-weight: 700; padding: 6px 14px; display: inline-flex; align-items: center; gap: 6px; border-radius: 8px;">
                <span style="width: 6px; height: 6px; border-radius: 50%; background-color: currentColor; display: inline-block;"></span>
                Đang hoạt động
              </span>
            </c:when>
            <c:otherwise>
              <span class="premium-tag premium-tag--danger" style="font-size: 12px; font-weight: 700; padding: 6px 14px; display: inline-flex; align-items: center; gap: 6px; border-radius: 8px;">
                <span style="width: 6px; height: 6px; border-radius: 50%; background-color: currentColor; display: inline-block;"></span>
                Bị khóa
              </span>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>

    <!-- Right Column: Permissions List -->
    <div class="premium-card" style="padding: 32px; background: #ffffff; border: 1.5px solid var(--card-border); border-radius: 16px;">
      <h3 style="margin: 0 0 20px 0; font-size: 18px; font-weight: 700; color: var(--text-primary); display: flex; align-items: center; gap: 10px;">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
          <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
        </svg>
        Danh sách quyền hạn được cấp (${selectedRole.permissionCodes.size()})
      </h3>

      <!-- Map of friendly descriptions -->
      <script>
        const permissionNames = {
          "BRAND_READ": "Xem danh sách Hãng sản xuất",
          "BRAND_WRITE": "Thêm/Sửa/Xóa Hãng sản xuất",
          "SUPPLIER_READ": "Xem danh sách Nhà cung cấp",
          "SUPPLIER_WRITE": "Thêm/Sửa/Xóa Nhà cung cấp",
          "PRODUCT_LINE_READ": "Xem danh sách Dòng sản phẩm",
          "PRODUCT_LINE_WRITE": "Thêm/Sửa/Xóa Dòng sản phẩm",
          "PRODUCT_READ": "Xem danh sách Sản phẩm",
          "PRODUCT_WRITE": "Quản lý Sản phẩm",
          "INVENTORY_READ": "Xem Tồn kho sản phẩm",
          "INVENTORY_WRITE": "Quản lý cấu hình Tồn kho",
          "RECEIPT_READ": "Xem Phiếu Nhập kho",
          "RECEIPT_WRITE": "Tạo Phiếu Nhập kho",
          "SHIPMENT_READ": "Xem Phiếu Xuất kho",
          "SHIPMENT_WRITE": "Tạo Phiếu Xuất kho"
        };
      </script>

      <div id="role-perms-container" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 12px;">
        <c:choose>
          <c:when test="${selectedRole.permissionCodes.size() == 0}">
            <span style="color: var(--text-secondary); font-style: italic; font-size: 14px; grid-column: span 2; text-align: center; padding: 16px;">Vai trò này chưa được gán bất kỳ quyền hạn nào.</span>
          </c:when>
          <c:otherwise>
            <c:forEach var="pc" items="${selectedRole.permissionCodes}">
              <div class="perm-card" data-perm-code="${pc}" style="padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; background: #f8fafc; display: flex; flex-direction: column; gap: 4px;">
                <strong style="color: var(--text-primary); font-size: 13.5px; font-family: monospace;">${pc}</strong>
                <span class="perm-desc" style="color: var(--text-secondary); font-size: 11.5px; line-height: 1.3;">Quyền nghiệp vụ hệ thống</span>
              </div>
            </c:forEach>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    document.querySelectorAll(".perm-card").forEach(card => {
      const code = card.getAttribute("data-perm-code");
      const descEl = card.querySelector(".perm-desc");
      if (descEl && permissionNames[code]) {
        descEl.textContent = permissionNames[code];
      }
    });
  });
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
