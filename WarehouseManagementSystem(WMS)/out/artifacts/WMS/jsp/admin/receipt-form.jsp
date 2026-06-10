<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Tạo Phiếu Nhập Kho"/>
<c:set var="activePage" value="receipts" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="margin-bottom: 24px;">
    <div>
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">Tạo Phiếu Nhập Kho</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Tạo yêu cầu nhập kho mới từ nhà cung cấp.</p>
    </div>
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
          <button type="button" onclick="addRow()" style="height: 32px; padding: 0 16px; font-size: 13px; font-weight: 600; color: var(--primary-color); border: 1.5px solid var(--primary-color); background: rgba(4, 138, 191, 0.05); border-radius: 8px; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; justify-content: center; gap: 4px;" onmouseover="this.style.background='rgba(4, 138, 191, 0.1)'" onmouseout="this.style.background='rgba(4, 138, 191, 0.05)'">
            + Thêm dòng
          </button>
        </div>
        <div style="padding: 16px; display: flex; flex-direction: column; gap: 16px;" id="productRows">
          
          <div class="product-row" style="display: flex; gap: 16px; align-items: flex-end;">
            <div style="flex: 1;">
              <label style="font-size: 13px; font-weight: 600; color: var(--text-secondary); margin-bottom: 8px; display: block;">Sản phẩm (SKU) <span style="color: #ef4444;">*</span></label>
              <select name="productId[]" required style="width: 100%; padding: 10px 14px; border: 1px solid var(--card-border); border-radius: 8px; font-size: 14px; outline: none; background: white;">
                <option value="">-- Chọn Sản phẩm --</option>
                <c:forEach var="p" items="${products}">
                  <option value="${p.id}" ${param.productId == p.id ? 'selected' : ''}>[${p.sku}] ${p.name}</option>
                </c:forEach>
              </select>
            </div>
            <div style="width: 150px;">
              <label style="font-size: 13px; font-weight: 600; color: var(--text-secondary); margin-bottom: 8px; display: block;">Số lượng <span style="color: #ef4444;">*</span></label>
              <input type="number" name="quantity[]" required min="1" value="1" style="width: 100%; padding: 10px 14px; border: 1px solid var(--card-border); border-radius: 8px; font-size: 14px; outline: none; background: white;">
            </div>
            <button type="button" onclick="removeRow(this)" style="color: #ef4444; border: 1.5px solid #fecaca; background: #fef2f2; width: 38px; height: 38px; border-radius: 8px; cursor: pointer; display: none; align-items: center; justify-content: center; transition: all 0.2s; padding: 0; box-sizing: border-box;" onmouseover="this.style.background='#fee2e2'; this.style.borderColor='#ef4444'" onmouseout="this.style.background='#fef2f2'; this.style.borderColor='#fecaca'">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
          </div>

        </div>
      </div>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label for="notes" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Ghi chú</label>
        <textarea id="notes" name="notes" rows="3" placeholder="Nhập ghi chú cho phiếu nhập kho này..." style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary); resize: vertical;"></textarea>
      </div>

      <input type="hidden" id="statusField" name="status" value="DRAFT"/>
      <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 8px; border-top: 1px solid var(--card-border); padding-top: 24px;">
        <a href="${pageContext.request.contextPath}/admin/receipts" class="premium-btn-outline" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; padding: 0 24px; box-sizing: border-box;">
          Hủy bỏ
        </a>
        <button type="submit" onclick="document.getElementById('statusField').value='DRAFT'" class="premium-btn-outline" style="height: 44px; padding: 0 24px; cursor: pointer;">
          Lưu Nháp
        </button>
        <button type="submit" onclick="document.getElementById('statusField').value='PENDING_APPROVAL'" class="premium-btn-primary" style="height: 44px; padding: 0 24px; cursor: pointer;">
          Gửi Yêu Cầu Duyệt
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
