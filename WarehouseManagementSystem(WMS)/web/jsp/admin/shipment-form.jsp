<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Tạo Phiếu Xuất Kho"/>
<c:set var="activePage" value="shipments" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 16px;">
    <a href="${pageContext.request.contextPath}/admin/shipments" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
      Quay lại danh sách
    </a>
  </div>

  <div class="subpage-header" style="margin-bottom: 24px;">
    <div class="subpage-header__title" style="text-align: left !important;">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0; text-align: left !important;">Tạo Phiếu Xuất Kho</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0; text-align: left !important;">Xuất hàng hóa. Hệ thống sẽ kiểm tra số lượng tồn kho trước khi cho phép xuất.</p>
    </div>
  </div>

  <div class="premium-card" style="padding: 32px; max-width: 800px;">
    <form action="${pageContext.request.contextPath}/admin/shipments" method="post" style="display: flex; flex-direction: column; gap: 24px;" onsubmit="return validateShipment()">
      <input type="hidden" name="action" value="create"/>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
          <label for="shipmentCode" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Mã Phiếu Xuất <span style="color: #ef4444;">*</span></label>
          <input type="text" id="shipmentCode" name="shipmentCode" value="${generatedCode}" required readonly style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; background-color: #f1f5f9; color: var(--text-secondary); font-family: monospace;" />
        </div>

        <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
          <label for="destination" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Nơi nhận (Khách hàng/Chi nhánh) <span style="color: #ef4444;">*</span></label>
          <input type="text" id="destination" name="destination" required placeholder="VD: Cửa hàng Q1..." style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary);" />
        </div>
      </div>

      <div style="border: 1px solid var(--card-border); border-radius: 10px; overflow: hidden; margin-top: 8px;">
        <div style="background: #f8fafc; padding: 12px 16px; border-bottom: 1px solid var(--card-border); font-weight: 600; font-size: 14px; display: flex; justify-content: space-between; align-items: center;">
          <span>Chi tiết sản phẩm xuất</span>
          <button type="button" onclick="addRow()" style="height: 32px; padding: 0 16px; font-size: 13px; font-weight: 600; color: var(--primary-color); border: 1.5px solid var(--primary-color); background: rgba(4, 138, 191, 0.05); border-radius: 8px; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; justify-content: center; gap: 4px;" onmouseover="this.style.background='rgba(4, 138, 191, 0.1)'" onmouseout="this.style.background='rgba(4, 138, 191, 0.05)'">
            + Thêm dòng
          </button>
        </div>
        <div style="padding: 16px; display: flex; flex-direction: column; gap: 16px;" id="productRows">
          
          <div class="product-row" style="display: flex; gap: 16px; align-items: flex-end;">
            <div style="flex: 1;">
              <label style="font-size: 13px; font-weight: 600; color: var(--text-secondary); margin-bottom: 8px; display: block;">Sản phẩm (SKU) <span style="color: #ef4444;">*</span></label>
              <select name="productId[]" required onchange="updateMaxQty(this)" style="width: 100%; padding: 10px 14px; border: 1px solid var(--card-border); border-radius: 8px; font-size: 14px; outline: none; background: white;">
                <option value="">-- Chọn Sản phẩm --</option>
                <c:forEach var="p" items="${products}">
                  <c:set var="stock" value="0"/>
                  <c:forEach var="inv" items="${inventories}">
                    <c:if test="${inv.productId == p.id}">
                      <c:set var="stock" value="${inv.quantityInStock}"/>
                    </c:if>
                  </c:forEach>
                  <option value="${p.id}" data-stock="${stock}" ${stock == 0 ? 'disabled' : ''}>[${p.sku}] ${p.name} (Tồn: ${stock})</option>
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
        <textarea id="notes" name="notes" rows="3" placeholder="Nhập ghi chú cho phiếu xuất kho này..." style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary); resize: vertical;"></textarea>
      </div>

      <input type="hidden" id="statusField" name="status" value="PENDING"/>
      <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 8px; border-top: 1px solid var(--card-border); padding-top: 24px;">
        <a href="${pageContext.request.contextPath}/admin/shipments" class="premium-btn-outline" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; padding: 0 24px; box-sizing: border-box;">
          Hủy bỏ
        </a>
        <button type="submit" onclick="document.getElementById('statusField').value='PENDING'" class="premium-btn-primary" style="height: 44px; padding: 0 24px; cursor: pointer;">
          Gửi Yêu Cầu Duyệt
        </button>
      </div>
    </form>
  </div>
</div>

<style>
  input:focus, select:focus, textarea:focus { border-color: var(--primary-color) !important; background-color: #ffffff !important; box-shadow: 0 0 0 4px rgba(4, 138, 191, 0.1) !important; }
  select option[disabled] { color: #9ca3af; }
</style>

<script>
  function updateMaxQty(selectElem) {
    const stock = selectElem.options[selectElem.selectedIndex].getAttribute('data-stock');
    const inputQty = selectElem.closest('.product-row').querySelector('input[type="number"]');
    if (stock) {
      inputQty.max = stock;
      inputQty.placeholder = "Max: " + stock;
      if (parseInt(inputQty.value) > parseInt(stock)) {
          inputQty.value = stock;
      }
    }
  }

  function addRow() {
    const container = document.getElementById('productRows');
    const firstRow = container.querySelector('.product-row');
    const newRow = firstRow.cloneNode(true);
    
    newRow.querySelector('select').value = '';
    newRow.querySelector('input[type="number"]').value = '1';
    newRow.querySelector('input[type="number"]').removeAttribute('max');
    newRow.querySelector('input[type="number"]').placeholder = '';
    
    newRow.querySelector('button').style.display = 'inline-flex';
    firstRow.querySelector('button').style.display = 'inline-flex';
    
    container.appendChild(newRow);
  }

  function removeRow(btn) {
    const container = document.getElementById('productRows');
    const rows = container.querySelectorAll('.product-row');
    if (rows.length > 1) {
      btn.closest('.product-row').remove();
    }
    const remainingRows = container.querySelectorAll('.product-row');
    if (remainingRows.length === 1) {
      remainingRows[0].querySelector('button').style.display = 'none';
    }
  }

  function validateShipment() {
    const selects = document.querySelectorAll('select[name="productId[]"]');
    const quantities = document.querySelectorAll('input[name="quantity[]"]');
    
    let productMap = new Map();
    
    for (let i = 0; i < selects.length; i++) {
        if (!selects[i].value) continue;
        
        let pId = selects[i].value;
        let qty = parseInt(quantities[i].value) || 0;
        let stock = parseInt(selects[i].options[selects[i].selectedIndex].getAttribute('data-stock')) || 0;
        
        if (qty <= 0) {
            alert("Số lượng xuất phải lớn hơn 0");
            return false;
        }
        
        if (productMap.has(pId)) {
            productMap.set(pId, {
                qty: productMap.get(pId).qty + qty,
                stock: stock
            });
        } else {
            productMap.set(pId, {qty: qty, stock: stock});
        }
    }
    
    // Check total
    for (let [pId, data] of productMap) {
        if (data.qty > data.stock) {
            alert("Lỗi: Tổng số lượng xuất (" + data.qty + ") vượt quá số lượng tồn kho (" + data.stock + ") cho sản phẩm đã chọn.");
            return false;
        }
    }
    return true;
  }
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
