<%-- 
    Document   : receipt
    Created on : Jun 1, 2026, 7:47:31 AM
    Author     : Admin
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Quản lý Nhập kho" scope="request"/>
<c:set var="activePage" value="receipts" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px;">
    <div class="subpage-header__title">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Quản lý Nhập kho</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Danh sách các Phiếu nhập kho từ Nhà cung cấp.</p>
    </div>
    <c:if test="${currentUser.hasPermission('RECEIPT_WRITE')}">
    <div>
      <a href="${pageContext.request.contextPath}/admin/receipts?action=create" class="premium-btn-primary" style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; height: 44px; line-height: 44px; box-sizing: border-box;">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
        Tạo Phiếu Nhập
      </a>
    </div>
    </c:if>
  </div>

  <div class="premium-card" style="padding: 32px;">
    <div style="overflow-x: auto; margin: 0 -32px; padding: 0 32px;">
      <table class="premium-table">
        <thead>
          <tr>
            <th>Mã Phiếu</th>
            <th>Nhà cung cấp</th>
            <th>Ngày tạo</th>
            <th>Người tạo</th>
            <th>Trạng thái</th>
            <th style="text-align: center; width: 100px;">Chi tiết</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="r" items="${receipts}">
            <tr class="user-row">
              <td><span class="premium-tag premium-tag--manager" style="font-family: monospace;">${r.receiptCode}</span></td>
              <td><strong style="color: var(--text-primary); font-size: 14px;">${r.supplier.name}</strong></td>
              <td><fmt:formatDate value="${r.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
              <td>${r.creator.fullName}</td>
              <td>
                <span class="premium-tag" style="background: rgba(16, 185, 129, 0.1); color: #10b981;">Đã hoàn thành</span>
              </td>
              <td style="text-align: center;">
                <a href="${pageContext.request.contextPath}/admin/receipts?action=view&id=${r.id}" class="action-btn" title="Xem chi tiết">
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                    <circle cx="12" cy="12" r="3"></circle>
                  </svg>
                </a>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>

<style>
  .premium-table { width: 100%; border-collapse: collapse; margin-top: 8px; }
  .premium-table th { background: #f8fafc; color: var(--text-secondary); font-weight: 700; font-size: 13px; text-transform: uppercase; letter-spacing: 0.04em; padding: 16px 20px; border-bottom: 1.5px solid var(--card-border); text-align: left; white-space: nowrap; }
  .premium-table td { padding: 16px 20px; border-bottom: 1px solid var(--card-border); font-size: 14px; color: var(--text-primary); vertical-align: middle; }
  .user-row { transition: opacity 0.2s ease, transform 0.2s ease; }
  .premium-table tr.user-row:hover td { background: rgba(4, 138, 191, 0.02); }
  .premium-tag--manager { background: rgba(245, 158, 11, 0.1) !important; color: #d97706 !important; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; }
  .action-btn { display: inline-flex; align-items: center; justify-content: center; width: 36px; height: 36px; border-radius: 8px; border: 1.5px solid var(--card-border); background: #ffffff; color: var(--text-secondary); cursor: pointer; transition: all 0.2s; }
  .action-btn:hover { border-color: var(--primary-color); color: var(--primary-color); background: rgba(4, 138, 191, 0.02); }
</style>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>