<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${not empty supplier}"/>
<c:set var="pageTitle" value="${isEdit ? 'Cập nhật NCC' : 'Thêm NCC mới'}" scope="request"/>
<c:set var="activePage" value="suppliers" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 16px;">
    <a href="${pageContext.request.contextPath}/admin/suppliers" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
      Quay lại danh sách
    </a>
  </div>
  
  <div class="profile-layout-grid">
    <div class="premium-card" style="padding: 40px 32px 32px 32px;">
      <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 32px; padding-bottom: 16px; border-bottom: 1px solid var(--card-border);">
        <div style="display: flex; align-items: center; justify-content: center; width: 48px; height: 48px; border-radius: 12px; background: rgba(245, 158, 11, 0.1); color: var(--warning-color);">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="11" width="18" height="10" rx="2" ry="2"></rect>
            <circle cx="12" cy="5" r="2"></circle>
            <path d="M12 7v4"></path>
          </svg>
        </div>
        <div>
          <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">${isEdit ? 'Chỉnh sửa Nhà cung cấp' : 'Thêm Nhà cung cấp mới'}</h3>
        </div>
      </div>

      <form method="post" action="${pageContext.request.contextPath}/admin/suppliers" style="display: flex; flex-direction: column; gap: 20px;">
        <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}"/>
        <c:if test="${isEdit}">
          <input type="hidden" name="id" value="${supplier.id}"/>
        </c:if>

        <div class="form-group">
          <label class="form-label">Mã NCC <span style="color: red;">*</span></label>
          <input name="code" value="${supplier.code}" class="subpage-input" placeholder="Ví dụ: NCC01" required ${isEdit ? 'readonly style="background:#f1f5f9; cursor:not-allowed;"' : ''}/>
        </div>

        <div class="form-group">
          <label class="form-label">Tên Nhà cung cấp <span style="color: red;">*</span></label>
          <input name="name" value="${supplier.name}" class="subpage-input" placeholder="Nhập tên đối tác" required/>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
          <div class="form-group">
            <label class="form-label">Số điện thoại</label>
            <input name="phone" value="${supplier.phone}" class="subpage-input" placeholder="Ví dụ: 0987654321"/>
          </div>
          <div class="form-group">
            <label class="form-label">Email</label>
            <input type="email" name="email" value="${supplier.email}" class="subpage-input" placeholder="Ví dụ: contact@ncc.com"/>
          </div>
        </div>

        <div class="form-group">
          <label class="form-label">Địa chỉ</label>
          <textarea name="address" class="subpage-input" placeholder="Nhập địa chỉ nhà cung cấp" rows="3" style="resize: vertical; padding: 12px 16px;">${supplier.address}</textarea>
        </div>

        <div style="margin-top: 12px; display: flex; gap: 12px; justify-content: flex-end;">
          <a href="${pageContext.request.contextPath}/admin/suppliers" class="premium-btn-outline" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; line-height: 44px; box-sizing: border-box;">Hủy bỏ</a>
          <button type="submit" class="premium-btn-primary">Lưu thay đổi</button>
        </div>
      </form>
    </div>
  </div>
</div>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
