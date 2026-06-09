<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Cập nhật Tồn kho"/>
<c:set var="activePage" value="inventories" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="margin-bottom: 24px;">
    <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">Cập nhật Tồn kho</h2>
    <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Điều chỉnh số lượng tồn hoặc cảnh báo tối thiểu cho SKU <strong>${inventory.product.sku}</strong></p>
  </div>

  <div class="premium-card" style="padding: 32px; max-width: 600px;">
    <form action="${pageContext.request.contextPath}/admin/inventories" method="post" style="display: flex; flex-direction: column; gap: 24px;">
      <input type="hidden" name="action" value="update"/>
      <input type="hidden" name="productId" value="${inventory.productId}"/>

      <div style="background: #f8fafc; padding: 16px; border-radius: 10px; border: 1px solid var(--card-border); margin-bottom: 8px;">
        <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Sản phẩm</div>
        <div style="font-size: 16px; font-weight: 700; color: var(--text-primary);">${inventory.product.name}</div>
        <div style="font-size: 14px; color: var(--text-secondary); margin-top: 4px;">Hãng: ${inventory.product.productLine.brand.name} | Đơn vị: ${inventory.product.unit}</div>
      </div>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label for="quantityInStock" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Số lượng hiện tại trong kho <span style="color: #ef4444;">*</span></label>
        <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">(Lưu ý: Số lượng này sau này sẽ được cập nhật tự động bằng Phiếu Nhập)</div>
        <input type="number" id="quantityInStock" name="quantityInStock" value="${inventory.quantityInStock}" required min="0" style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 16px; outline: none; transition: all 0.2s; color: var(--text-primary);" />
      </div>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label for="minStockLevel" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Mức tồn kho tối thiểu (Cảnh báo) <span style="color: #ef4444;">*</span></label>
        <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Hệ thống sẽ báo "Sắp hết hàng" nếu tồn kho nhỏ hơn hoặc bằng số này.</div>
        <input type="number" id="minStockLevel" name="minStockLevel" value="${inventory.minStockLevel}" required min="0" style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 16px; outline: none; transition: all 0.2s; color: var(--text-primary);" />
      </div>

      <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 8px; border-top: 1px solid var(--card-border); padding-top: 24px;">
        <a href="${pageContext.request.contextPath}/admin/inventories" class="premium-btn-secondary" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; padding: 0 24px; box-sizing: border-box;">
          Hủy bỏ
        </a>
        <button type="submit" class="premium-btn-primary" style="height: 44px; padding: 0 24px;">
          Lưu thay đổi
        </button>
      </div>
    </form>
  </div>
</div>

<style>
  input:focus { border-color: var(--primary-color) !important; background-color: #ffffff !important; box-shadow: 0 0 0 4px rgba(4, 138, 191, 0.1) !important; }
</style>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
