<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${not empty productLine}"/>
<c:set var="pageTitle" value="${isEdit ? 'Cập nhật Dòng SP' : 'Thêm Dòng SP mới'}" scope="request"/>
<c:set var="activePage" value="product-lines" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 16px;">
    <a href="${pageContext.request.contextPath}/admin/product-lines" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
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
        <div style="display: flex; align-items: center; justify-content: center; width: 48px; height: 48px; border-radius: 12px; background: rgba(59, 130, 246, 0.1); color: #3b82f6;">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <rect x="4" y="4" width="16" height="16" rx="2" ry="2"></rect>
            <rect x="9" y="9" width="6" height="6"></rect>
          </svg>
        </div>
        <div>
          <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">${isEdit ? 'Chỉnh sửa Dòng sản phẩm' : 'Thêm Dòng sản phẩm mới'}</h3>
        </div>
      </div>

      <form method="post" action="${pageContext.request.contextPath}/admin/product-lines" style="display: flex; flex-direction: column; gap: 20px;">
        <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}"/>
        <c:if test="${isEdit}">
          <input type="hidden" name="id" value="${productLine.id}"/>
        </c:if>

        <div class="form-group">
          <label class="form-label">Chọn Hãng (Thương hiệu) <span style="color: red;">*</span></label>
          <select name="brandId" class="subpage-input" required style="cursor: pointer; background: #ffffff;">
            <option value="">-- Chọn Hãng --</option>
            <c:forEach var="b" items="${brands}">
              <option value="${b.id}" ${isEdit && productLine.brandId == b.id ? 'selected' : ''}>${b.name} (${b.code})</option>
            </c:forEach>
          </select>
        </div>

        <div class="form-group">
          <label class="form-label">Mã Dòng SP <span style="color: red;">*</span></label>
          <input name="code" value="${productLine.code}" class="subpage-input" placeholder="Ví dụ: IPHONE, MACBOOK..." required ${isEdit ? 'readonly style="background:#f1f5f9; cursor:not-allowed;"' : ''}/>
        </div>

        <div class="form-group">
          <label class="form-label">Tên Dòng SP <span style="color: red;">*</span></label>
          <input name="name" value="${productLine.name}" class="subpage-input" placeholder="Ví dụ: Apple iPhone" required/>
        </div>

        <div class="form-group">
          <label class="form-label">Mô tả</label>
          <textarea name="description" class="subpage-input" placeholder="Thông tin thêm về dòng sản phẩm" rows="4" style="resize: vertical; padding: 12px 16px;">${productLine.description}</textarea>
        </div>

        <div style="margin-top: 12px; display: flex; gap: 12px; justify-content: flex-end;">
          <a href="${pageContext.request.contextPath}/admin/product-lines" class="premium-btn-outline" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; line-height: 44px; box-sizing: border-box;">Hủy bỏ</a>
          <button type="submit" class="premium-btn-primary">Lưu thay đổi</button>
        </div>
      </form>
    </div>
  </div>
</div>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
