<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${not empty product}"/>
<c:set var="pageTitle" value="${isEdit ? 'Sửa Sản phẩm' : 'Thêm Sản phẩm'}"/>
<c:set var="activePage" value="products" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="margin-bottom: 24px;">
    <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">${pageTitle}</h2>
    <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">${isEdit ? 'Cập nhật thông tin sản phẩm.' : 'Thêm một sản phẩm mới vào danh mục.'}</p>
  </div>

  <div class="premium-card" style="padding: 32px; max-width: 800px;">
    <form action="${pageContext.request.contextPath}/admin/products" method="post" style="display: flex; flex-direction: column; gap: 24px;">
      <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}"/>
      <c:if test="${isEdit}">
        <input type="hidden" name="id" value="${product.id}"/>
      </c:if>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label for="productLineId" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Dòng sản phẩm <span style="color: #ef4444;">*</span></label>
        <select id="productLineId" name="productLineId" required style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary);">
          <option value="">-- Chọn dòng sản phẩm --</option>
          <c:forEach var="pl" items="${productLines}">
            <option value="${pl.id}" ${isEdit && product.productLineId == pl.id ? 'selected' : ''}>
              ${pl.brand.name} - ${pl.name}
            </option>
          </c:forEach>
        </select>
      </div>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label for="sku" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Mã SKU <span style="color: #ef4444;">*</span></label>
        <input type="text" id="sku" name="sku" value="${isEdit ? product.sku : ''}" required placeholder="Nhập mã SKU (VD: IP15-PM-256)" style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary); font-family: monospace;" />
      </div>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label for="name" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Tên sản phẩm <span style="color: #ef4444;">*</span></label>
        <input type="text" id="name" name="name" value="${isEdit ? product.name : ''}" required placeholder="Nhập tên sản phẩm" style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary);" />
      </div>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
          <label for="unit" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Đơn vị tính <span style="color: #ef4444;">*</span></label>
          <input type="text" id="unit" name="unit" value="${isEdit ? product.unit : 'Chiếc'}" required placeholder="VD: Chiếc, Bộ, Thùng..." style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary);" />
        </div>

        <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
          <label for="price" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Giá bán</label>
          <input type="number" id="price" name="price" value="${isEdit ? product.price : ''}" placeholder="Nhập giá bán (VNĐ)" style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary);" />
        </div>
      </div>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label for="description" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Mô tả</label>
        <textarea id="description" name="description" rows="4" placeholder="Nhập mô tả sản phẩm..." style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary); resize: vertical;">${isEdit ? product.description : ''}</textarea>
      </div>

      <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 8px; border-top: 1px solid var(--card-border); padding-top: 24px;">
        <a href="${pageContext.request.contextPath}/admin/products" class="premium-btn-secondary" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; padding: 0 24px; box-sizing: border-box;">
          Hủy bỏ
        </a>
        <button type="submit" class="premium-btn-primary" style="height: 44px; padding: 0 24px;">
          ${isEdit ? 'Lưu thay đổi' : 'Tạo Sản phẩm'}
        </button>
      </div>
    </form>
  </div>
</div>

<style>
  input:focus, select:focus, textarea:focus { border-color: var(--primary-color) !important; background-color: #ffffff !important; box-shadow: 0 0 0 4px rgba(4, 138, 191, 0.1) !important; }
</style>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
