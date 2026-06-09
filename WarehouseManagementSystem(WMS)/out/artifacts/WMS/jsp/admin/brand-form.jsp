<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${not empty brand}"/>
<c:set var="pageTitle" value="${isEdit ? 'Cập nhật Hãng' : 'Thêm Hãng mới'}" scope="request"/>
<c:set var="activePage" value="brands" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 16px;">
    <a href="${pageContext.request.contextPath}/admin/brands" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
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
        <div style="display: flex; align-items: center; justify-content: center; width: 48px; height: 48px; border-radius: 12px; background: rgba(4, 138, 191, 0.1); color: var(--primary-color);">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path>
            <line x1="7" y1="7" x2="7.01" y2="7"></line>
          </svg>
        </div>
        <div>
          <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">${isEdit ? 'Chỉnh sửa Hãng' : 'Thêm Hãng mới'}</h3>
          <p style="margin: 4px 0 0 0; font-size: 13px; color: var(--text-secondary);">Nhập thông tin chi tiết về hãng sản xuất.</p>
        </div>
      </div>

      <form method="post" action="${pageContext.request.contextPath}/admin/brands" style="display: flex; flex-direction: column; gap: 20px;">
        <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}"/>
        <c:if test="${isEdit}">
          <input type="hidden" name="id" value="${brand.id}"/>
        </c:if>

        <div class="form-group">
          <label class="form-label">Mã Hãng <span style="color: red;">*</span></label>
          <input name="code" value="${brand.code}" class="subpage-input" placeholder="Ví dụ: APL, SS..." required ${isEdit ? 'readonly style="background:#f1f5f9; cursor:not-allowed;"' : ''}/>
        </div>

        <div class="form-group">
          <label class="form-label">Tên Hãng <span style="color: red;">*</span></label>
          <input name="name" value="${brand.name}" class="subpage-input" placeholder="Ví dụ: Apple, Samsung..." required/>
        </div>

        <div class="form-group">
          <label class="form-label">Mô tả</label>
          <textarea name="description" class="subpage-input" placeholder="Thông tin thêm về hãng" rows="4" style="resize: vertical; padding: 12px 16px;">${brand.description}</textarea>
        </div>

        <div style="margin-top: 12px; display: flex; gap: 12px; justify-content: flex-end;">
          <a href="${pageContext.request.contextPath}/admin/brands" class="premium-btn-outline" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; line-height: 44px; box-sizing: border-box;">Hủy bỏ</a>
          <button type="submit" class="premium-btn-primary">Lưu thay đổi</button>
        </div>
      </form>
    </div>
  </div>
</div>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
