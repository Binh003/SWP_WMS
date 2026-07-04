<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Chi tiết Tồn kho" scope="request"/>
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

  <div class="subpage-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 16px;">
    <div>
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">Chi tiết Tồn kho: <span style="color: var(--primary-color);">${inventory.product.name}</span> (Lô: ${inventory.batchCode})</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Theo dõi chi tiết số lượng xuất nhập và lịch sử cập nhật của mặt hàng này.</p>
    </div>
    <div style="display: flex; gap: 12px;">
      <c:if test="${currentUser.hasPermission('RECEIPT_WRITE')}">
        <a href="${pageContext.request.contextPath}/admin/receipts?action=create&productId=${inventory.productId}" class="premium-btn-primary" style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; height: 40px; padding: 0 16px; background-color: #10b981; border-color: #10b981;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Nhập thêm hàng
        </a>
      </c:if>
      <c:if test="${currentUser.hasPermission('INVENTORY_WRITE')}">
        <a href="${pageContext.request.contextPath}/admin/inventories?action=edit&id=${inventory.id}" class="premium-btn-outline" style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; height: 40px; padding: 0 16px;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
            <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
          </svg>
          Cấu hình tồn kho
        </a>
      </c:if>
    </div>
  </div>

  <div style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 24px; margin-bottom: 24px;">
    <!-- Left Column: Product Info -->
    <div class="premium-card" style="padding: 24px; align-self: start;">
      <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">Thông tin Sản phẩm</h3>
      
      <div style="display: flex; flex-direction: column; gap: 16px;">
        <div style="display: flex; gap: 20px; align-items: flex-start; flex-wrap: wrap;">
          <!-- Product Placeholder/Image -->
          <div style="flex-shrink: 0; width: 100px; height: 100px; border-radius: 10px; border: 1.5px solid var(--card-border); overflow: hidden; background: #f8fafc; display: flex; align-items: center; justify-content: center;">
            <c:choose>
              <c:when test="${not empty inventory.product.imageUrl}">
                <img src="${inventory.product.imageUrl.startsWith('/') ? pageContext.request.contextPath : ''}${inventory.product.imageUrl}" 
                     alt="${inventory.product.name}" 
                     style="width: 100%; height: 100%; object-fit: contain;" />
              </c:when>
              <c:otherwise>
                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="var(--text-secondary)" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
                  <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
                  <line x1="12" y1="22.08" x2="12" y2="12"></line>
                </svg>
              </c:otherwise>
            </c:choose>
          </div>
          
          <div style="flex-grow: 1; display: flex; flex-direction: column; gap: 8px;">
            <div>
              <div style="font-size: 12px; color: var(--text-secondary);">Tên sản phẩm</div>
              <strong style="font-size: 16px; color: var(--text-primary);">${inventory.product.name}</strong>
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
              <div>
                <div style="font-size: 12px; color: var(--text-secondary);">Mã SKU</div>
                <span style="font-family: monospace; font-size: 13px; font-weight: 700; color: var(--text-primary);">${inventory.product.sku}</span>
              </div>
              <div>
                <div style="font-size: 12px; color: var(--text-secondary);">Đơn vị tính</div>
                <span style="font-size: 13px; font-weight: 600; color: var(--text-primary);">${inventory.product.unit}</span>
              </div>
            </div>
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; border-top: 1px solid var(--card-border); padding-top: 16px;">
          <div>
            <div style="font-size: 12px; color: var(--text-secondary); margin-bottom: 2px;">Dòng sản phẩm</div>
            <span class="premium-tag premium-tag--manager" style="font-size: 11px;">${inventory.product.productLine.name}</span>
          </div>
          <div>
            <div style="font-size: 12px; color: var(--text-secondary); margin-bottom: 2px;">Hãng sản xuất</div>
            <span class="premium-tag premium-tag--admin" style="font-size: 11px;">${inventory.product.productLine.brand.name}</span>
          </div>
        </div>

        <div style="border-top: 1px solid var(--card-border); padding-top: 16px;">
          <div style="font-size: 12px; color: var(--text-secondary); margin-bottom: 2px;">Đơn giá bán</div>
          <span style="font-size: 16px; font-weight: 700; color: #10b981;">
            <fmt:formatNumber value="${inventory.product.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
          </span>
        </div>
      </div>
    </div>

    <!-- Right Column: Stock Level Details -->
    <div class="premium-card" style="padding: 24px; align-self: start;">
      <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">Trạng thái tồn kho</h3>
      
      <div style="display: flex; flex-direction: column; gap: 20px;">
        <div style="text-align: center; padding: 20px; background: #f8fafc; border-radius: 12px; border: 1.5px solid var(--card-border);">
          <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 6px; font-weight: 600;">Số lượng tồn trong kho</div>
          <div style="font-size: 36px; font-weight: 800; color: ${totalQuantity <= inventory.minStockLevel ? '#ef4444' : 'var(--primary-color)'};">
            <fmt:formatNumber value="${totalQuantity}"/> ${inventory.product.unit}
          </div>
          <div style="font-size: 12px; margin-top: 8px;">
            <c:choose>
              <c:when test="${totalQuantity <= 0}">
                <span style="color: #ef4444; font-weight: 700; background: rgba(239, 68, 68, 0.1); padding: 4px 8px; border-radius: 6px; display: inline-flex; align-items: center; gap: 4px;">
                  🚫 Đã hết hàng
                </span>
              </c:when>
              <c:when test="${totalQuantity <= inventory.minStockLevel}">
                <span style="color: #d97706; font-weight: 700; background: rgba(245, 158, 11, 0.1); padding: 4px 8px; border-radius: 6px; display: inline-flex; align-items: center; gap: 4px;">
                  ⚠️ Cảnh báo: Sắp hết hàng
                </span>
              </c:when>
              <c:otherwise>
                <span style="color: #10b981; font-weight: 700; background: rgba(16, 185, 129, 0.1); padding: 4px 8px; border-radius: 6px; display: inline-flex; align-items: center; gap: 4px;">
                  ✓ Đủ hàng (An toàn)
                </span>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

        <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">
          <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Mức tồn tối thiểu:</span>
          <span style="font-size: 14px; font-weight: 700; color: var(--text-primary);"><fmt:formatNumber value="${inventory.minStockLevel}"/> ${inventory.product.unit}</span>
        </div>

        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Cập nhật lần cuối:</span>
          <span style="font-size: 13px; font-weight: 600; color: var(--text-primary);">
            <fmt:formatDate value="${inventory.lastUpdated}" pattern="dd/MM/yyyy HH:mm"/>
          </span>
        </div>
      </div>
    </div>
  </div>

  <!-- History Table Section -->
  <div class="premium-card" style="padding: 24px; margin-bottom: 24px;">
    <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px; display: flex; align-items: center; gap: 8px;">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="10"></circle>
        <polyline points="12 6 12 12 16 14"></polyline>
      </svg>
      Lịch sử Cập nhật và Giao dịch Kho (Nhập / Xuất)
    </h3>

    <div style="overflow-x: auto;">
      <table class="history-table">
        <thead>
          <tr>
            <th>Thời gian</th>
            <th>Loại giao dịch</th>
            <th>Mã phiếu</th>
            <th>Đối tác / Nơi giao nhận</th>
            <th style="text-align: right;">Số lượng</th>
            <th>Người thực hiện</th>
            <th>Ghi chú</th>
          </tr>
        </thead>
        <tbody>
          <c:choose>
            <c:when test="${empty historyList}">
              <tr>
                <td colspan="7" style="text-align: center; padding: 32px 0; color: var(--text-secondary); font-style: italic;">
                  Chưa có lịch sử nhập xuất hàng cho sản phẩm này.
                </td>
              </tr>
            </c:when>
            <c:otherwise>
              <c:forEach var="h" items="${historyList}">
                <tr class="history-row">
                  <td style="font-size: 13px; color: var(--text-secondary); font-weight: 600; white-space: nowrap;">
                    <fmt:formatDate value="${h.transactionDate}" pattern="dd/MM/yyyy HH:mm"/>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${h.transactionType == 'IMPORT'}">
                        <span class="premium-tag" style="background: rgba(16, 185, 129, 0.1); color: #10b981; font-weight: 700; font-size: 11px;">Nhập kho (Import)</span>
                      </c:when>
                      <c:otherwise>
                        <span class="premium-tag" style="background: rgba(239, 68, 68, 0.1); color: #ef4444; font-weight: 700; font-size: 11px;">Xuất kho (Export)</span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td>
                    <c:choose>
                      <c:when test="${h.transactionType == 'IMPORT'}">
                        <a href="${pageContext.request.contextPath}/admin/receipts?action=view&id=${h.transactionId}" style="font-family: monospace; font-weight: 700; text-decoration: none; color: var(--primary-color);">
                          ${h.transactionCode}
                        </a>
                      </c:when>
                      <c:otherwise>
                        <a href="${pageContext.request.contextPath}/admin/shipments?action=view&id=${h.transactionId}" style="font-family: monospace; font-weight: 700; text-decoration: none; color: var(--primary-color);">
                          ${h.transactionCode}
                        </a>
                      </c:otherwise>
                    </c:choose>
                  </td>
                  <td style="font-size: 13px; color: var(--text-primary); max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                    ${h.partnerName}
                  </td>
                  <td style="text-align: right; font-weight: 700; font-size: 15px; white-space: nowrap;">
                    <c:choose>
                      <c:when test="${h.transactionType == 'IMPORT'}">
                        <span style="color: #10b981;">+<fmt:formatNumber value="${h.quantity}"/></span>
                      </c:when>
                      <c:otherwise>
                        <span style="color: #ef4444;">-<fmt:formatNumber value="${h.quantity}"/></span>
                      </c:otherwise>
                    </c:choose>
                    <span style="font-size: 12px; color: var(--text-secondary); font-weight: 500; margin-left: 2px;">${inventory.product.unit}</span>
                  </td>
                  <td style="font-size: 13px; color: var(--text-primary); font-weight: 600;">
                    ${h.creatorName}
                  </td>
                  <td style="font-size: 13px; color: var(--text-secondary); max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${h.notes}">
                    <c:choose>
                      <c:when test="${not empty h.notes}">${h.notes}</c:when>
                      <c:otherwise><span style="font-style: italic; color: #cbd5e1;">Không có ghi chú</span></c:otherwise>
                    </c:choose>
                  </td>
                </tr>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </tbody>
      </table>
    </div>
  </div>

  <!-- Itemized Barcodes Section -->
  <div class="premium-card" style="padding: 24px; margin-bottom: 24px;">
    <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px; display: flex; align-items: center; gap: 8px;">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
        <line x1="16" y1="2" x2="16" y2="6"></line>
        <line x1="8" y1="2" x2="8" y2="6"></line>
        <line x1="3" y1="10" x2="21" y2="10"></line>
      </svg>
      Danh sách sản phẩm đơn lẻ (Mã vạch chi tiết) trong lô này
    </h3>
    <div style="overflow-x: auto;">
      <table class="history-table" style="width: 100%; border-collapse: collapse; margin-top: 8px;">
        <thead>
          <tr style="background: #f8fafc; border-bottom: 1.5px solid var(--card-border);">
            <th style="color: var(--text-secondary); font-weight: 700; font-size: 12px; text-transform: uppercase; padding: 14px 16px; text-align: left;">STT</th>
            <th style="color: var(--text-secondary); font-weight: 700; font-size: 12px; text-transform: uppercase; padding: 14px 16px; text-align: left;">Mã vạch (Barcode)</th>
            <th style="color: var(--text-secondary); font-weight: 700; font-size: 12px; text-transform: uppercase; padding: 14px 16px; text-align: left;">Số lượng tồn</th>
            <th style="color: var(--text-secondary); font-weight: 700; font-size: 12px; text-transform: uppercase; padding: 14px 16px; text-align: left;">Trạng thái</th>
            <th style="color: var(--text-secondary); font-weight: 700; font-size: 12px; text-transform: uppercase; padding: 14px 16px; text-align: left;">Cập nhật lần cuối</th>
            <th style="color: var(--text-secondary); font-weight: 700; font-size: 12px; text-transform: uppercase; padding: 14px 16px; text-align: center; width: 120px;">Hành động</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="item" items="${itemizedList}" varStatus="loop">
            <tr class="history-row" style="border-bottom: 1px solid var(--card-border);">
              <td style="padding: 14px 16px; font-weight: 600; color: var(--text-secondary);">${loop.index + 1}</td>
              <td style="padding: 14px 16px; vertical-align: middle;">
                <div style="display: flex; flex-direction: column; gap: 4px; align-items: flex-start;">
                  <img src="${pageContext.request.contextPath}/admin/barcode?code=${item.barcode}" alt="Barcode" style="height: 32px; max-width: 180px; object-fit: contain; background: #ffffff; border: 1px solid var(--card-border); padding: 2px; border-radius: 4px;" />
                  <span style="font-family: monospace; font-size: 11px; font-weight: 700; color: var(--text-secondary); letter-spacing: 0.5px;">${item.barcode}</span>
                </div>
              </td>
              <td style="padding: 14px 16px;">${item.quantityInStock} ${item.product.unit}</td>
              <td style="padding: 14px 16px;">
                <c:choose>
                  <c:when test="${item.quantityInStock > 0}">
                    <span class="premium-tag" style="background: rgba(16, 185, 129, 0.1); color: #10b981; padding: 4px 10px; border-radius: 6px; font-weight: 700;">Trong kho</span>
                  </c:when>
                  <c:otherwise>
                    <span class="premium-tag" style="background: rgba(239, 68, 68, 0.1); color: #ef4444; padding: 4px 10px; border-radius: 6px; font-weight: 700;">Đã xuất kho</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td style="padding: 14px 16px; color: var(--text-secondary); font-size: 13px;">
                <fmt:formatDate value="${item.lastUpdated}" pattern="dd/MM/yyyy HH:mm"/>
              </td>
              <td style="padding: 14px 16px; text-align: center;">
                <div class="action-dropdown-container" style="position: relative; display: inline-block; text-align: left;">
                  <button type="button" class="action-dropdown-trigger" onclick="toggleDropdown(this)" style="display: inline-flex; align-items: center; justify-content: center; width: 36px; height: 36px; border-radius: 8px; border: 1.5px solid var(--card-border); background: #ffffff; color: var(--text-secondary); cursor: pointer; transition: all 0.2s; padding: 0; box-shadow: 0 1px 2px rgba(0,0,0,0.05);">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <circle cx="12" cy="12" r="1.5"></circle>
                      <circle cx="12" cy="5" r="1.5"></circle>
                      <circle cx="12" cy="19" r="1.5"></circle>
                    </svg>
                  </button>
                  <div class="action-dropdown-menu" style="display: none; position: absolute; right: 0; top: 40px; background: #ffffff; border: 1.5px solid var(--card-border); border-radius: 10px; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08); z-index: 100; min-width: 150px; overflow: hidden; animation: slideDown 0.15s ease-out;">
                    <a href="${pageContext.request.contextPath}/admin/inventories?action=detail&id=${item.id}" class="action-dropdown-item" style="display: flex; align-items: center; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; text-decoration: none; transition: background 0.15s;">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"></circle>
                        <line x1="12" y1="8" x2="12" y2="12"></line>
                        <line x1="12" y1="16" x2="12.01" y2="16"></line>
                      </svg>
                      Xem chi tiết
                    </a>
                  </div>
                </div>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>

<style>
  .premium-tag--manager { background: rgba(245, 158, 11, 0.1) !important; color: #d97706 !important; padding: 4px 10px; border-radius: 6px; font-weight: 700; }
  .premium-tag--admin { background: rgba(30, 64, 175, 0.1) !important; color: #1e40af !important; padding: 4px 10px; border-radius: 6px; font-weight: 700; }
  
  .history-table { width: 100%; border-collapse: collapse; margin-top: 8px; }
  .history-table th { background: #f8fafc; color: var(--text-secondary); font-weight: 700; font-size: 12px; text-transform: uppercase; letter-spacing: 0.04em; padding: 14px 16px; border-bottom: 1.5px solid var(--card-border); text-align: left; }
  .history-table td { padding: 14px 16px; border-bottom: 1px solid var(--card-border); font-size: 14px; color: var(--text-primary); vertical-align: middle; }
  .history-row { transition: background-color 0.2s ease; }
  .history-table tr.history-row:hover td { background: rgba(4, 138, 191, 0.02); }

  .action-dropdown-item { color: var(--text-primary); }
  .action-dropdown-item:hover { background-color: #f1f5f9; }
  .action-dropdown-trigger:hover { border-color: var(--primary-color) !important; color: var(--primary-color) !important; background: rgba(4, 138, 191, 0.02) !important; }
  @keyframes slideDown { from { opacity: 0; transform: translateY(-8px); } to { opacity: 1; transform: translateY(0); } }
</style>

<script>
  function toggleDropdown(button) {
    event.stopPropagation();
    const currentMenu = button.nextElementSibling;
    document.querySelectorAll('.action-dropdown-menu').forEach(menu => {
      if (menu !== currentMenu) menu.style.display = 'none';
    });
    currentMenu.style.display = currentMenu.style.display === 'block' ? 'none' : 'block';
  }
  document.addEventListener('click', function(event) {
    if (!event.target.closest('.action-dropdown-container')) {
      document.querySelectorAll('.action-dropdown-menu').forEach(menu => {
        menu.style.display = 'none';
      });
    }
  });
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
