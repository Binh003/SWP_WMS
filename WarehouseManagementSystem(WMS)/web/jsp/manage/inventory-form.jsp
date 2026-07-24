<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Cấu hình Cảnh báo Tồn kho"/>
<c:set var="activePage" value="inventories" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 16px;">
    <a href="${pageContext.request.contextPath}/manage/inventories" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
      Quay lại danh sách tồn kho
    </a>
  </div>

  <div class="subpage-header" style="margin-bottom: 24px; display: flex; flex-direction: column; align-items: flex-start; gap: 8px;">
    <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Cấu hình Cảnh báo Tồn kho</h2>
    <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Cấu hình mức cảnh báo tồn kho tối thiểu cho SKU <strong>${inventory.product.sku}</strong></p>
  </div>

  <!-- Form to edit Min Stock Level -->
  <div class="premium-card" style="padding: 32px; margin-bottom: 24px;">
    <h3 style="font-size: 18px; font-weight: 700; color: var(--text-primary); margin: 0 0 20px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px; display: flex; align-items: center; gap: 10px;">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--primary-color)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="3"></circle>
        <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
      </svg>
      Cấu hình Cảnh báo Tồn kho
    </h3>

    <form id="inventoryForm" action="${pageContext.request.contextPath}/manage/inventories" method="post" style="display: flex; flex-direction: column; gap: 24px;">
      <input type="hidden" name="action" value="update"/>
      <input type="hidden" name="id" value="${inventory.id}"/>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px; margin-bottom: 0;">
        <label for="minStockLevel" style="font-size: 14px; font-weight: 700; color: var(--text-primary);">Mức tồn kho tối thiểu (Cảnh báo) <span style="color: #ef4444;">*</span></label>
        <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px; line-height: 1.4;">Hệ thống sẽ tự động hiển thị nhãn "Sắp hết hàng" hoặc gửi cảnh báo nếu số lượng tồn kho giảm xuống bằng hoặc dưới mức này.</div>
        <input type="number" id="minStockLevel" name="minStockLevel" value="${inventory.minStockLevel}" required min="0" step="1" style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 16px; outline: none; transition: all 0.2s; color: var(--text-primary);" />
        <span id="minStockLevelError" style="color: #ef4444; font-size: 13px; margin-top: 2px; display: none;">Mức tồn kho tối thiểu không hợp lệ (chỉ nhập số nguyên không âm)</span>
      </div>

      <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 8px; border-top: 1px solid var(--card-border); padding-top: 24px;">
        <a href="${pageContext.request.contextPath}/manage/inventories" class="premium-btn-outline" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; padding: 0 24px; box-sizing: border-box;">
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
