<%-- 
    Document   : receipt-detail
    Created on : Jun 1, 2026, 7:44:54 AM
    Author     : Admin
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Chi tiết Phiếu Nhập"/>
<c:set var="activePage" value="receipts" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-end;">
    <div>
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">Chi tiết Phiếu Nhập: <span style="font-family: monospace; color: var(--primary-color);">${receipt.receiptCode}</span></h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Thông tin chi tiết về các sản phẩm đã nhập kho.</p>
    </div>
    <div>
      <a href="${pageContext.request.contextPath}/admin/receipts" class="premium-btn-secondary" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 40px; padding: 0 16px;">
        &larr; Quay lại danh sách
      </a>
    </div>
  </div>

  <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
    <!-- Info panel -->
    <div class="premium-card" style="padding: 24px; align-self: start;">
      <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">Thông tin chung</h3>
      
      <div style="display: flex; flex-direction: column; gap: 16px;">
        <div>
          <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Nhà cung cấp</div>
          <div style="font-size: 15px; font-weight: 600; color: var(--text-primary);">${receipt.supplier.name}</div>
        </div>
        
        <div>
          <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Ngày tạo</div>
          <div style="font-size: 14px; color: var(--text-primary);">
            <fmt:formatDate value="${receipt.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
          </div>
        </div>
        
        <div>
          <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Người tạo</div>
          <div style="font-size: 14px; color: var(--text-primary);">${receipt.creator.fullName}</div>
        </div>
        
        <div>
          <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Trạng thái</div>
          <div>
            <span class="premium-tag" style="background: rgba(16, 185, 129, 0.1); color: #10b981;">Đã hoàn thành</span>
          </div>
        </div>
        
        <c:if test="${not empty receipt.notes}">
        <div>
          <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Ghi chú</div>
          <div style="font-size: 14px; color: var(--text-primary); background: #f8fafc; padding: 12px; border-radius: 8px; border: 1px solid var(--card-border);">${receipt.notes}</div>
        </div>
        </c:if>
      </div>
    </div>
    
    <!-- Details panel -->
    <div class="premium-card" style="padding: 24px; align-self: start;">
      <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">Sản phẩm nhập kho</h3>
      
      <div style="overflow-x: auto;">
        <table style="width: 100%; border-collapse: collapse;">
          <thead>
            <tr>
              <th style="text-align: left; padding: 12px; border-bottom: 2px solid var(--card-border); font-size: 13px; color: var(--text-secondary);">SKU</th>
              <th style="text-align: left; padding: 12px; border-bottom: 2px solid var(--card-border); font-size: 13px; color: var(--text-secondary);">Tên sản phẩm</th>
              <th style="text-align: right; padding: 12px; border-bottom: 2px solid var(--card-border); font-size: 13px; color: var(--text-secondary);">Đơn vị</th>
              <th style="text-align: right; padding: 12px; border-bottom: 2px solid var(--card-border); font-size: 13px; color: var(--text-secondary);">Số lượng nhập</th>
            </tr>
          </thead>
          <tbody>
            <c:set var="totalItems" value="0"/>
            <c:forEach var="detail" items="${receipt.details}">
              <tr>
                <td style="padding: 12px; border-bottom: 1px solid var(--card-border); font-family: monospace;">${detail.product.sku}</td>
                <td style="padding: 12px; border-bottom: 1px solid var(--card-border); font-weight: 600;">${detail.product.name}</td>
                <td style="padding: 12px; border-bottom: 1px solid var(--card-border); text-align: right;">${detail.product.unit}</td>
                <td style="padding: 12px; border-bottom: 1px solid var(--card-border); text-align: right; font-weight: 700; color: #10b981;">+${detail.quantity}</td>
              </tr>
              <c:set var="totalItems" value="${totalItems + detail.quantity}"/>
            </c:forEach>
          </tbody>
          <tfoot>
            <tr>
              <td colspan="3" style="text-align: right; padding: 16px 12px; font-weight: 700; color: var(--text-primary);">Tổng số lượng nhập:</td>
              <td style="text-align: right; padding: 16px 12px; font-weight: 700; font-size: 16px; color: var(--primary-color);">${totalItems}</td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  </div>
</div>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>