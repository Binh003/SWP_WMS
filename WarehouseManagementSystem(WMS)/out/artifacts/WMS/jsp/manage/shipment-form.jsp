<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Yêu Cầu Xuất Kho"/>
<c:set var="activePage" value="shipments" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 16px;">
    <a href="${pageContext.request.contextPath}/manage/shipments" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
      Quay lại danh sách
    </a>
  </div>

  <div class="subpage-header" style="margin-bottom: 24px;">
    <div class="subpage-header__title" style="text-align: left !important;">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0; text-align: left !important;">Yêu Cầu Xuất Kho</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0; text-align: left !important;">Xuất hàng hóa. Hệ thống sẽ kiểm tra số lượng tồn kho trước khi cho phép xuất.</p>
    </div>
  </div>

  <div class="premium-card" style="padding: 32px; max-width: 800px;">
    <form action="${pageContext.request.contextPath}/manage/shipments" method="post" novalidate style="display: flex; flex-direction: column; gap: 24px;" onsubmit="return validateShipment()">
      <input type="hidden" name="action" value="create"/>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
          <label for="shipmentCode" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Mã Phiếu Xuất <span style="color: #ef4444;">*</span></label>
          <input type="text" id="shipmentCode" name="shipmentCode" value="${generatedCode}" readonly style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; background-color: #f1f5f9; color: var(--text-secondary); font-family: monospace;" />
        </div>

        <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
          <label for="destination" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Nơi nhận (Khách hàng/Chi nhánh) <span style="color: #ef4444;">*</span></label>
          <input type="text" id="destination" name="destination" placeholder="VD: Cửa hàng Q1..." style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary);" />
        </div>
      </div>

      <div style="border: 1px solid var(--card-border); border-radius: 10px; overflow: hidden; margin-top: 8px;">
        <div style="background: #f8fafc; padding: 14px 16px; border-bottom: 1px solid var(--card-border); display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
          <div>
            <span style="font-weight: 700; font-size: 14px; color: var(--text-primary); display: block;">Chi tiết sản phẩm xuất</span>
            <span style="font-size: 12px; color: var(--text-secondary);">Chọn sản phẩm và số lượng cần xuất</span>
          </div>
          <button type="button" onclick="addRow()" style="height: 32px; padding: 0 16px; font-size: 13px; font-weight: 600; color: var(--primary-color); border: 1.5px solid var(--primary-color); background: rgba(4, 138, 191, 0.05); border-radius: 8px; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; justify-content: center; gap: 4px;" onmouseover="this.style.background='rgba(4, 138, 191, 0.1)'" onmouseout="this.style.background='rgba(4, 138, 191, 0.05)'">
            + Thêm dòng
          </button>
        </div>
        <div style="padding: 16px; display: flex; flex-direction: column; gap: 16px;" id="productRows">
          
          <div class="product-row" style="display: flex; gap: 16px; align-items: flex-end; flex-wrap: wrap;">
            <div style="flex: 1; min-width: 260px;">
              <label style="font-size: 13px; font-weight: 600; color: var(--text-secondary); margin-bottom: 8px; display: block;">Sản phẩm (SKU) <span style="color: #ef4444;">*</span></label>
              <select name="productId[]" onchange="updateMaxQty(this)" style="width: 100%; padding: 10px 14px; border: 1px solid var(--card-border); border-radius: 8px; font-size: 14px; outline: none; background: white;">
                <option value="">-- Chọn Sản phẩm --</option>
                <c:forEach var="p" items="${products}">
                  <c:set var="stock" value="0"/>
                  <c:forEach var="inv" items="${inventories}">
                    <c:if test="${inv.productId == p.id}">
                      <c:set var="stock" value="${stock + inv.quantityInStock}"/>
                    </c:if>
                  </c:forEach>
                  <option value="${p.id}" data-stock="${stock}" ${stock == 0 ? 'disabled' : ''}>[${p.sku}] ${p.name} (Tồn: ${stock})</option>
                </c:forEach>
              </select>
            </div>

            <div style="width: 140px;">
              <label style="font-size: 13px; font-weight: 600; color: var(--text-secondary); margin-bottom: 8px; display: block;">Số lượng <span style="color: #ef4444;">*</span></label>
              <input type="number" name="quantity[]" value="1" oninput="checkInputQty(this)" onchange="checkInputQty(this)" style="width: 100%; padding: 10px 14px; border: 1px solid var(--card-border); border-radius: 8px; font-size: 14px; outline: none; background: white;">
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
        <a href="${pageContext.request.contextPath}/manage/shipments" class="premium-btn-outline" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; padding: 0 24px; box-sizing: border-box;">
          Hủy bỏ
        </a>
        <button type="submit" onclick="document.getElementById('statusField').value='PENDING'" class="premium-btn-primary" style="height: 44px; padding: 0 24px; cursor: pointer;">
          Gửi Yêu Cầu Xuất Kho
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
    const option = selectElem.options[selectElem.selectedIndex];
    const stock = option ? option.getAttribute('data-stock') : null;
    const inputQty = selectElem.closest('.product-row').querySelector('input[name="quantity[]"]');
    if (stock !== null && stock !== '') {
      inputQty.setAttribute('data-stock', stock);
      inputQty.placeholder = "Max: " + stock;
      checkInputQty(inputQty);
    }
  }

  function checkInputQty(inputElem) {
    const stockStr = inputElem.getAttribute('data-stock');
    if (stockStr !== null && stockStr !== '') {
      const maxStock = parseInt(stockStr) || 0;
      const val = parseInt(inputElem.value) || 0;
      if (val > maxStock) {
        showCustomAlert("Số lượng xuất (" + val + ") vượt quá số lượng tồn kho khả dụng (" + maxStock + ").");
        inputElem.value = maxStock;
      }
    }
  }

  function addRow() {
    const container = document.getElementById('productRows');
    const firstRow = container.querySelector('.product-row');
    const newRow = firstRow.cloneNode(true);
    
    newRow.querySelector('select[name="productId[]"]').value = '';
    const inputQty = newRow.querySelector('input[name="quantity[]"]');
    inputQty.value = '1';
    inputQty.removeAttribute('data-stock');
    inputQty.placeholder = '';
    
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
    const destination = document.getElementById('destination').value.trim();
    if (!destination) {
        showCustomAlert("Vui lòng nhập Nơi nhận (Khách hàng/Chi nhánh)!");
        return false;
    }

    const selects = document.querySelectorAll('select[name="productId[]"]');
    const quantities = document.querySelectorAll('input[name="quantity[]"]');
    
    let productMap = new Map();
    
    for (let i = 0; i < selects.length; i++) {
        if (!selects[i].value) {
            showCustomAlert("Vui lòng chọn sản phẩm ở tất cả các dòng!");
            return false;
        }
        
        let pId = selects[i].value;
        let qty = parseInt(quantities[i].value) || 0;
        let option = selects[i].options[selects[i].selectedIndex];
        let stock = parseInt(option.getAttribute('data-stock')) || 0;
        let prodName = option.text ? option.text.split('(Tồn:')[0] : '';
        
        if (qty <= 0) {
            showCustomAlert("Số lượng xuất cho sản phẩm " + prodName + " phải lớn hơn 0!");
            return false;
        }
        
        if (qty > stock) {
            showCustomAlert("Số lượng xuất (" + qty + ") vượt quá tồn kho khả dụng (" + stock + ") của sản phẩm " + prodName + "!");
            quantities[i].value = stock;
            return false;
        }
        
        if (productMap.has(pId)) {
            productMap.set(pId, {
                qty: productMap.get(pId).qty + qty,
                stock: stock,
                prodName: prodName
            });
        } else {
            productMap.set(pId, {qty: qty, stock: stock, prodName: prodName});
        }
    }
    
    for (let [pId, data] of productMap) {
        if (data.qty > data.stock) {
            showCustomAlert("Tổng số lượng xuất (" + data.qty + ") vượt quá tồn kho khả dụng (" + data.stock + ") cho sản phẩm " + data.prodName + "!");
            return false;
        }
    }
    return true;
  }

  function showCustomAlert(msg) {
    const modal = document.getElementById("customAlertModal");
    const msgEl = document.getElementById("customAlertMessage");
    if (modal && msgEl) {
        msgEl.textContent = msg;
        modal.style.display = "flex";
        document.body.style.overflow = "hidden";
    }
  }

  document.addEventListener("DOMContentLoaded", function() {
    const closeBtn = document.getElementById("closeCustomAlertBtn");
    const modal = document.getElementById("customAlertModal");
    if (closeBtn && modal) {
        closeBtn.addEventListener("click", function() {
            modal.style.display = "none";
            document.body.style.overflow = "auto";
        });
        
        window.addEventListener("click", function(event) {
            if (event.target === modal) {
                modal.style.display = "none";
                document.body.style.overflow = "auto";
            }
        });
    }
  });
</script>

<!-- Custom Alert Modal -->
<div id="customAlertModal" style="display: none; position: fixed; z-index: 99999; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(15, 23, 42, 0.4); backdrop-filter: blur(4px); transition: all 0.3s ease; justify-content: center; align-items: center;">
  <div style="background-color: #ffffff; padding: 30px; border-radius: 16px; border: 1px solid var(--card-border); width: 90%; max-width: 420px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04); position: relative; animation: modalFadeIn 0.2s ease; display: flex; flex-direction: column; align-items: center; gap: 16px; text-align: center;">
    <div style="width: 50px; height: 50px; border-radius: 50%; background: #fffbeb; border: 2px solid #f59e0b; color: #f59e0b; display: flex; align-items: center; justify-content: center; font-size: 24px; font-weight: bold;">
      ⚠️
    </div>
    <h3 style="font-size: 16px; font-weight: 800; color: #1e293b; margin: 0; text-transform: uppercase; letter-spacing: 0.5px;">Cảnh báo</h3>
    <p id="customAlertMessage" style="font-size: 14px; color: #64748b; line-height: 1.5; margin: 0; font-weight: 600;"></p>
    <button id="closeCustomAlertBtn" style="margin-top: 8px; width: 100%; height: 40px; border-radius: 8px; border: none; background: #048abf; color: #ffffff; font-weight: 700; font-size: 13px; cursor: pointer; transition: opacity 0.2s;" onmouseover="this.style.opacity='0.9'" onmouseout="this.style.opacity='1'">
      Đồng ý
    </button>
  </div>
</div>

<style>
@keyframes modalFadeIn {
  from { opacity: 0; transform: translateY(-20px); }
  to { opacity: 1; transform: translateY(0); }
}
</style>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
