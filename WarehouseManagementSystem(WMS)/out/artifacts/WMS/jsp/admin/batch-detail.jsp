<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Chi tiết Lô hàng" scope="request"/>
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

  <div class="subpage-header" style="margin-bottom: 24px;">
    <div>
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">Chi tiết Lô hàng: <span style="font-family: monospace; color: var(--primary-color);">${batchCode}</span></h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Danh sách sản phẩm và mã vạch (barcode) thuộc số lô này.</p>
    </div>
  </div>

  <!-- Batch Summary Stats Cards -->
  <c:set var="totalQty" value="0" />
  <c:set var="totalItems" value="0" />
  <c:forEach var="i" items="${batchInventories}">
    <c:set var="totalQty" value="${totalQty + i.quantityInStock}" />
    <c:set var="totalItems" value="${totalItems + 1}" />
  </c:forEach>

  <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 24px;">
    <div class="premium-card" style="padding: 20px; display: flex; align-items: center; gap: 16px;">
      <div style="width: 48px; height: 48px; border-radius: 12px; background: rgba(4, 138, 191, 0.1); color: var(--primary-color); display: flex; align-items: center; justify-content: center;">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
        </svg>
      </div>
      <div>
        <div style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Tổng số mặt hàng khác nhau</div>
        <div style="font-size: 24px; font-weight: 800; color: var(--text-primary); margin-top: 4px;">${totalItems} sản phẩm</div>
      </div>
    </div>

    <div class="premium-card" style="padding: 20px; display: flex; align-items: center; gap: 16px;">
      <div style="width: 48px; height: 48px; border-radius: 12px; background: rgba(16, 185, 129, 0.1); color: #10b981; display: flex; align-items: center; justify-content: center;">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
      </div>
      <div>
        <div style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Tổng số lượng tồn của Lô</div>
        <div style="font-size: 24px; font-weight: 800; color: #10b981; margin-top: 4px;">
          <fmt:formatNumber value="${totalQty}"/> đơn vị
        </div>
      </div>
    </div>
  </div>

  <!-- Products List Table -->
  <div class="premium-card" style="padding: 32px;">
    <div style="overflow-x: auto; margin: 0 -32px; padding: 0 32px;">
      <table class="premium-table">
        <thead>
          <tr>
            <th>SKU</th>
            <th>Sản phẩm</th>
            <th>Mã vạch (Barcode)</th>
            <th style="text-align: right;">Số lượng Tồn</th>
            <th style="text-align: right;">Mức an toàn</th>
            <th>Trạng thái</th>
            <th>Cập nhật lần cuối</th>
            <th style="text-align: center; width: 100px;">Hành động</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="i" items="${batchInventories}">
            <tr class="user-row">
              <td>
                <span class="premium-tag premium-tag--manager" style="font-family: monospace;">${i.product.sku}</span>
              </td>
              <td>
                <strong style="color: var(--primary-color); font-size: 14px;">${i.product.name}</strong><br/>
                <small style="color: var(--text-secondary);">${i.product.productLine.brand.name} - ${i.product.productLine.name}</small>
              </td>
              <td>
                <span style="font-family: monospace; font-weight: 600; color: var(--text-primary);">${i.barcode}</span>
              </td>
              <td style="text-align: right; font-weight: 700; font-size: 15px;" class="${i.quantityInStock <= i.minStockLevel ? 'stock-low' : 'stock-ok'}">
                <fmt:formatNumber value="${i.quantityInStock}"/> ${i.product.unit}
              </td>
              <td style="text-align: right; color: var(--text-secondary);">
                <fmt:formatNumber value="${i.minStockLevel}"/>
              </td>
              <td>
                <c:choose>
                  <c:when test="${i.quantityInStock <= 0}">
                    <span class="premium-tag" style="background: rgba(239, 68, 68, 0.1); color: #ef4444;">Hết hàng</span>
                  </c:when>
                  <c:when test="${i.quantityInStock <= i.minStockLevel}">
                    <span class="premium-tag" style="background: rgba(245, 158, 11, 0.1); color: #d97706;">Sắp hết hàng</span>
                  </c:when>
                  <c:otherwise>
                    <span class="premium-tag" style="background: rgba(16, 185, 129, 0.1); color: #10b981;">Đủ hàng</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td>
                <fmt:formatDate value="${i.lastUpdated}" pattern="dd/MM/yyyy HH:mm"/>
              </td>
              <td style="text-align: center;">
                <a href="${pageContext.request.contextPath}/admin/inventories?action=detail&id=${i.id}" class="premium-btn-outline" style="padding: 6px 12px; font-size: 12px; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; height: auto;">
                  Xem chi tiết
                </a>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty batchInventories}">
            <tr>
              <td colspan="8" style="text-align: center; color: var(--text-secondary); padding: 40px 0;">
                Không tìm thấy sản phẩm nào trong lô hàng này.
              </td>
            </tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </div>
</div>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
