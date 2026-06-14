<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Cập nhật Tồn kho"/>
<c:set var="activePage" value="inventories" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 16px;">
    <a href="${pageContext.request.contextPath}/admin/inventories" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
      Quay lại danh sách tồn kho
    </a>
  </div>

  <div class="subpage-header" style="margin-bottom: 24px; display: flex; flex-direction: column; align-items: flex-start; gap: 8px;">
    <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Cập nhật Tồn kho</h2>
    <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Cấu hình mức cảnh báo tồn kho tối thiểu cho SKU <strong>${inventory.product.sku}</strong></p>
  </div>

  <!-- Row 1: Product details and Current Stock side by side -->
  <div class="inventory-grid-row" style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">
    <!-- Product Details Panel -->
    <div class="premium-card" style="padding: 24px; display: flex; flex-direction: column; justify-content: space-between;">
      <div>
        <h3 style="font-size: 14px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px; text-transform: uppercase; letter-spacing: 0.05em;">Thông tin sản phẩm</h3>
        
        <div style="display: flex; gap: 16px; align-items: flex-start;">
          <div style="width: 48px; height: 48px; border-radius: 10px; background: rgba(4, 138, 191, 0.05); border: 1px solid var(--card-border); display: flex; align-items: center; justify-content: center; color: var(--primary-color); flex-shrink: 0;">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
              <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
            </svg>
          </div>
          <div>
            <div style="font-size: 16px; font-weight: 800; color: var(--text-primary); line-height: 1.4;">${inventory.product.name}</div>
            <div style="font-family: monospace; font-size: 12px; color: var(--text-secondary); margin-top: 4px;">SKU: ${inventory.product.sku}</div>
          </div>
        </div>
      </div>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px; background: #f8fafc; padding: 12px; border-radius: 8px; border: 1px solid var(--card-border); margin-top: 16px;">
        <div>
          <div style="font-size: 11px; color: var(--text-secondary); font-weight: 600;">Hãng sản xuất</div>
          <div style="font-size: 13px; font-weight: 700; color: var(--text-primary); margin-top: 2px;">${inventory.product.productLine.brand.name}</div>
        </div>
        <div>
          <div style="font-size: 11px; color: var(--text-secondary); font-weight: 600;">Đơn vị tính</div>
          <div style="font-size: 13px; font-weight: 700; color: var(--text-primary); margin-top: 2px;">${inventory.product.unit}</div>
        </div>
      </div>
    </div>

    <!-- Current Stock Status Panel -->
    <div class="premium-card" style="padding: 24px; display: flex; flex-direction: column; justify-content: space-between;">
      <div>
        <h3 style="font-size: 14px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px; text-transform: uppercase; letter-spacing: 0.05em;">Tồn kho hiện tại</h3>
        
        <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 16px; padding: 8px 0;">
          <div style="text-align: center;">
            <div style="font-size: 44px; font-weight: 800; color: ${inventory.quantityInStock <= inventory.minStockLevel ? '#ef4444' : 'var(--primary-color)'}; line-height: 1;">
              ${inventory.quantityInStock}
            </div>
            <span style="font-size: 13px; font-weight: 600; color: var(--text-secondary); display: block; margin-top: 4px;">${inventory.product.unit} trong kho</span>
          </div>
          
          <div>
            <c:choose>
              <c:when test="${inventory.quantityInStock <= 0}">
                <span class="premium-tag" style="background: rgba(239, 68, 68, 0.12); color: #ef4444; font-size: 11px; padding: 6px 12px; border-radius: 6px; font-weight: 700; display: inline-block;">❌ Đã hết hàng</span>
              </c:when>
              <c:when test="${inventory.quantityInStock <= inventory.minStockLevel}">
                <span class="premium-tag" style="background: rgba(245, 158, 11, 0.12); color: #d97706; font-size: 11px; padding: 6px 12px; border-radius: 6px; font-weight: 700; display: inline-block;">⚠️ Sắp hết hàng</span>
              </c:when>
              <c:otherwise>
                <span class="premium-tag" style="background: rgba(16, 185, 129, 0.12); color: #10b981; font-size: 11px; padding: 6px 12px; border-radius: 6px; font-weight: 700; display: inline-block;">✓ Tồn kho an toàn</span>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>

      <div style="display: grid; grid-template-columns: 1fr; gap: 12px; background: #f8fafc; padding: 12px; border-radius: 8px; border: 1px solid var(--card-border); margin-top: 16px;">
        <div>
          <div style="font-size: 11px; color: var(--text-secondary); font-weight: 600;">Cập nhật lần cuối</div>
          <div style="font-size: 13px; font-weight: 700; color: var(--text-primary); margin-top: 2px;">
            <fmt:formatDate value="${inventory.lastUpdated}" pattern="dd/MM/yyyy HH:mm"/>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Row 2: Form to edit Min Stock Level -->
  <div class="premium-card" style="padding: 32px; margin-bottom: 24px;">
    <h3 style="font-size: 18px; font-weight: 700; color: var(--text-primary); margin: 0 0 20px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px; display: flex; align-items: center; gap: 10px;">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--primary-color)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="3"></circle>
        <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
      </svg>
      Cấu hình Cảnh báo Tồn kho
    </h3>

    <form id="inventoryForm" action="${pageContext.request.contextPath}/admin/inventories" method="post" style="display: flex; flex-direction: column; gap: 24px;">
      <input type="hidden" name="action" value="update"/>
      <input type="hidden" name="productId" value="${inventory.productId}"/>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px; margin-bottom: 0;">
        <label for="minStockLevel" style="font-size: 14px; font-weight: 700; color: var(--text-primary);">Mức tồn kho tối thiểu (Cảnh báo) <span style="color: #ef4444;">*</span></label>
        <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px; line-height: 1.4;">Hệ thống sẽ tự động hiển thị nhãn "Sắp hết hàng" hoặc gửi cảnh báo nếu số lượng tồn kho giảm xuống bằng hoặc dưới mức này.</div>
        <input type="number" id="minStockLevel" name="minStockLevel" value="${inventory.minStockLevel}" required min="0" step="1" style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 16px; outline: none; transition: all 0.2s; color: var(--text-primary);" />
        <span id="minStockLevelError" style="color: #ef4444; font-size: 13px; margin-top: 2px; display: none;">Mức tồn kho tối thiểu không hợp lệ (chỉ nhập số nguyên không âm)</span>
      </div>

      <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 8px; border-top: 1px solid var(--card-border); padding-top: 24px;">
        <a href="${pageContext.request.contextPath}/admin/inventories" class="premium-btn-outline" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; padding: 0 24px; box-sizing: border-box;">
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
  @media (max-width: 768px) {
    .inventory-grid-row {
      grid-template-columns: 1fr !important;
    }
  }
</style>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    const minStockInput = document.getElementById('minStockLevel');
    const minStockError = document.getElementById('minStockLevelError');
    const form = document.getElementById('inventoryForm');

    if (minStockInput) {
      minStockInput.addEventListener('keydown', function(e) {
        if (['e', 'E', '+', '-', '.', ','].includes(e.key)) {
          e.preventDefault();
        }
      });

      minStockInput.addEventListener('paste', function(e) {
        const pasteData = (e.clipboardData || window.clipboardData).getData('text');
        if (!/^\d+$/.test(pasteData)) {
          e.preventDefault();
        }
      });
    }

    if (form && minStockInput && minStockError) {
      form.addEventListener('submit', function(e) {
        const val = minStockInput.value.trim();
        if (val === '') {
          e.preventDefault();
          minStockError.innerText = 'Vui lòng nhập mức tồn kho tối thiểu';
          minStockError.style.display = 'block';
          minStockInput.focus();
          return;
        }
        if (!/^\d+$/.test(val)) {
          e.preventDefault();
          minStockError.innerText = 'Mức tồn kho tối thiểu không hợp lệ (chỉ nhập số nguyên không âm)';
          minStockError.style.display = 'block';
          minStockInput.focus();
          return;
        }
        const num = parseInt(val, 10);
        if (num < 0) {
          e.preventDefault();
          minStockError.innerText = 'Mức tồn kho tối thiểu không được nhỏ hơn 0';
          minStockError.style.display = 'block';
          minStockInput.focus();
          return;
        }
        minStockError.style.display = 'none';
      });
    }
  });
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
