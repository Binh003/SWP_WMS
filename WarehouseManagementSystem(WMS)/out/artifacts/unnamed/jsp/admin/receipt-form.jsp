<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Tạo Phiếu Nhập Kho"/>
<c:set var="activePage" value="receipts" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="margin-bottom: 24px;">
    <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">Tạo Phiếu Nhập Kho</h2>
    <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Nhập hàng từ nhà cung cấp vào kho. Số lượng tồn kho sẽ tự động tăng lên sau khi lưu.</p>
  </div>

  <div class="premium-card" style="padding: 32px; max-width: 800px;">
    <form action="${pageContext.request.contextPath}/admin/receipts" method="post" style="display: flex; flex-direction: column; gap: 24px;">
      <input type="hidden" name="action" value="create"/>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
          <label for="receiptCode" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Mã Phiếu Nhập <span style="color: #ef4444;">*</span></label>
          <input type="text" id="receiptCode" name="receiptCode" value="${generatedCode}" required readonly style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; background-color: #f1f5f9; color: var(--text-secondary); font-family: monospace;" />
        </div>

        <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
          <label for="supplierId" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Nhà cung cấp <span style="color: #ef4444;">*</span></label>
          <select id="supplierId" name="supplierId" required style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary);">
            <option value="">-- Chọn Nhà cung cấp --</option>
            <c:forEach var="s" items="${suppliers}">
              <option value="${s.id}">${s.name}</option>
            </c:forEach>
          </select>
        </div>
      </div>

      <div style="border: 1px solid var(--card-border); border-radius: 10px; overflow: hidden; margin-top: 8px;">
        <div style="background: #f8fafc; padding: 12px 16px; border-bottom: 1px solid var(--card-border); font-weight: 600; font-size: 14px; display: flex; justify-content: space-between; align-items: center;">
          <span>Chi tiết sản phẩm nhập</span>
          <button type="button" onclick="addRow()" class="premium-btn-secondary" style="height: 32px; padding: 0 12px; font-size: 13px;">+ Thêm dòng</button>
        </div>
        <div style="padding: 16px; display: flex; flex-direction: column; gap: 16px;" id="productRows">
          
          <div class="product-row" style="display: flex; gap: 16px; align-items: flex-end;">
            <div style="flex: 1;">
              <label style="font-size: 13px; font-weight: 600; color: var(--text-secondary); margin-bottom: 8px; display: block;">Sản phẩm (SKU) <span style="color: #ef4444;">*</span></label>
              <select name="productId[]" required style="width: 100%; padding: 10px 14px; border: 1px solid var(--card-border); border-radius: 8px; font-size: 14px; outline: none; background: white;">
                <option value="">-- Chọn Sản phẩm --</option>
                <c:forEach var="p" items="${products}">
                  <option value="${p.id}">[${p.sku}] ${p.name}</option>
                </c:forEach>
              </select>
            </div>
            <div style="width: 150px;">
              <label style="font-size: 13px; font-weight: 600; color: var(--text-secondary); margin-bottom: 8px; display: block;">Số lượng <span style="color: #ef4444;">*</span></label>
              <input type="number" name="quantity[]" required min="1" value="1" style="width: 100%; padding: 10px 14px; border: 1px solid var(--card-border); border-radius: 8px; font-size: 14px; outline: none; background: white;">
            </div>
            <button type="button" onclick="removeRow(this)" class="action-btn" style="color: #ef4444; border-color: #fecaca; background: #fef2f2; width: 42px; height: 42px; display: none;">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
            </button>
          </div>

        </div>
      </div>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label for="notes" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Ghi chú</label>
        <textarea id="notes" name="notes" rows="3" placeholder="Nhập ghi chú cho phiếu nhập kho này..." style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary); resize: vertical;"></textarea>
      </div>

      <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 8px; border-top: 1px solid var(--card-border); padding-top: 24px;">
        <a href="${pageContext.request.contextPath}/admin/receipts" class="premium-btn-secondary" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; padding: 0 24px; box-sizing: border-box;">
          Hủy bỏ
        </a>
        <button type="submit" class="premium-btn-primary" style="height: 44px; padding: 0 24px;">
          Lưu Phiếu Nhập
        </button>
      </div>
    </form>
  </div>
</div>

<style>
  input:focus, select:focus, textarea:focus { border-color: var(--primary-color) !important; background-color: #ffffff !important; box-shadow: 0 0 0 4px rgba(4, 138, 191, 0.1) !important; }
  .action-btn:hover { background: #fee2e2 !important; border-color: #ef4444 !important; }
</style>

<script>
  function addRow() {
    const container = document.getElementById('productRows');
    const firstRow = container.querySelector('.product-row');
    const newRow = firstRow.cloneNode(true);
    
    // Reset values
    newRow.querySelector('select').value = '';
    newRow.querySelector('input[type="number"]').value = '1';
    
    // Show delete button
    newRow.querySelector('button').style.display = 'inline-flex';
    
    // Make sure first row delete button is also visible if there are > 1 rows
    firstRow.querySelector('button').style.display = 'inline-flex';
    
    container.appendChild(newRow);
  }

  function removeRow(btn) {
    const container = document.getElementById('productRows');
    const rows = container.querySelectorAll('.product-row');
    if (rows.length > 1) {
      btn.closest('.product-row').remove();
    }
    // If only 1 row left, hide its delete button
    const remainingRows = container.querySelectorAll('.product-row');
    if (remainingRows.length === 1) {
      remainingRows[0].querySelector('button').style.display = 'none';
    }
  }
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
