<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Chi tiết sản phẩm đơn lẻ" scope="request"/>
<c:set var="activePage" value="inventories" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 16px;">
    <a href="${pageContext.request.contextPath}/admin/inventories?action=batchDetail&id=${inventory.id}" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
      Quay lại chi tiết lô hàng
    </a>
  </div>

  <div class="subpage-header" style="margin-bottom: 24px;">
    <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">Chi tiết sản phẩm đơn lẻ</h2>
    <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Thông tin chi tiết về sản phẩm đơn lẻ có mã vạch duy nhất trong hệ thống.</p>
  </div>

  <div style="display: grid; grid-template-columns: 1.2fr 1.8fr; gap: 24px; margin-bottom: 24px;">
    <!-- Left Column: Product Image and Media Info -->
    <div class="premium-card" style="padding: 24px; display: flex; flex-direction: column; align-items: center; justify-content: flex-start; text-align: center;">
      <div style="width: 100%; max-width: 280px; height: 280px; border-radius: 16px; border: 2px dashed var(--card-border); background: #f8fafc; overflow: hidden; display: flex; align-items: center; justify-content: center; margin-bottom: 20px;">
        <c:choose>
          <c:when test="${not empty inventory.product.imageUrl}">
            <img src="${inventory.product.imageUrl.startsWith('/') ? pageContext.request.contextPath : ''}${inventory.product.imageUrl}" 
                 alt="${inventory.product.name}" 
                 style="width: 100%; height: 100%; object-fit: contain;" />
          </c:when>
          <c:otherwise>
            <div style="display: flex; flex-direction: column; align-items: center; gap: 12px; color: var(--text-secondary);">
              <svg width="64" height="64" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
                <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
                <line x1="12" y1="22.08" x2="12" y2="12"></line>
              </svg>
              <span style="font-size: 13px; font-weight: 500;">Không có hình ảnh</span>
            </div>
          </c:otherwise>
        </c:choose>
      </div>

      <h3 style="font-size: 18px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">${inventory.product.name}</h3>
      <span class="premium-tag premium-tag--manager" style="font-family: monospace; font-size: 13px; margin-bottom: 16px;">SKU: ${inventory.product.sku}</span>
      
      <div style="width: 100%; border-top: 1px solid var(--card-border); padding-top: 16px; display: flex; flex-direction: column; gap: 12px; text-align: left;">
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Hãng sản xuất:</span>
          <span style="font-size: 13px; font-weight: 700; color: var(--text-primary);">${inventory.product.productLine.brand.name}</span>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Dòng sản phẩm:</span>
          <span style="font-size: 13px; font-weight: 700; color: var(--text-primary);">${inventory.product.productLine.name}</span>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Đơn giá bán:</span>
          <span style="font-size: 15px; font-weight: 700; color: #10b981;">
            <fmt:formatNumber value="${inventory.product.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
          </span>
        </div>
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Đơn vị tính:</span>
          <span style="font-size: 13px; font-weight: 700; color: var(--text-primary);">${inventory.product.unit}</span>
        </div>
      </div>
    </div>

    <!-- Right Column: Serialization and Stock details -->
    <div class="premium-card" style="padding: 24px;">
      <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 20px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px; display: flex; align-items: center; gap: 8px;">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
          <line x1="16" y1="2" x2="16" y2="6"></line>
          <line x1="8" y1="2" x2="8" y2="6"></line>
          <line x1="3" y1="10" x2="21" y2="10"></line>
        </svg>
        Thông tin định danh sản phẩm đơn lẻ
      </h3>

      <div style="display: grid; grid-template-columns: 1fr; gap: 20px;">
        <!-- Barcode display -->
        <div style="background: #f8fafc; border-radius: 12px; border: 1.5px solid var(--card-border); padding: 24px; display: flex; flex-direction: column; align-items: center; gap: 16px;">
          <div style="font-size: 12px; color: var(--text-secondary); font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; align-self: flex-start;">MÃ VẠCH CHI TIẾT (BARCODE)</div>
          
          <div style="background: #ffffff; border-radius: 8px; border: 1px solid var(--card-border); padding: 16px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 8px; width: 100%; max-width: 360px; box-shadow: 0 1px 3px rgba(0,0,0,0.02);">
            <img src="${pageContext.request.contextPath}/admin/barcode?code=${inventory.barcode}" alt="Barcode ${inventory.barcode}" style="max-width: 100%; height: auto;" />
            <strong style="font-family: monospace; font-size: 16px; color: var(--text-primary); letter-spacing: 2px; margin-top: 4px;">${inventory.barcode}</strong>
          </div>
        </div>

        <!-- Detail table specs -->
        <div style="display: flex; flex-direction: column; gap: 16px;">
          <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">
            <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Mã số lô (Batch Code):</span>
            <span class="premium-tag" style="background: rgba(16, 185, 129, 0.1); color: #10b981; font-weight: 700; border-radius: 6px;">${inventory.batchCode}</span>
          </div>

          <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">
            <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Số lượng trong kho:</span>
            <span style="font-size: 14px; font-weight: 700; color: var(--text-primary);">${inventory.quantityInStock} ${inventory.product.unit}</span>
          </div>

          <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">
            <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Trạng thái lưu kho:</span>
            <c:choose>
              <c:when test="${inventory.quantityInStock > 0}">
                <span class="premium-tag" style="background: rgba(16, 185, 129, 0.1); color: #10b981; padding: 4px 10px; border-radius: 6px; font-weight: 700;">Đang ở trong kho</span>
              </c:when>
              <c:otherwise>
                <span class="premium-tag" style="background: rgba(239, 68, 68, 0.1); color: #ef4444; padding: 4px 10px; border-radius: 6px; font-weight: 700;">Đã xuất kho</span>
              </c:otherwise>
            </c:choose>
          </div>

          <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">
            <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Mức tồn kho tối thiểu của nhóm:</span>
            <span style="font-size: 14px; font-weight: 600; color: var(--text-secondary);">${inventory.minStockLevel} ${inventory.product.unit}</span>
          </div>

          <div style="display: flex; justify-content: space-between; align-items: center;">
            <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Cập nhật hệ thống lần cuối:</span>
            <span style="font-size: 13px; font-weight: 600; color: var(--text-primary);">
              <fmt:formatDate value="${inventory.lastUpdated}" pattern="dd/MM/yyyy HH:mm"/>
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
