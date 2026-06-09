<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Quản lý Tồn kho" scope="request"/>
<c:set var="activePage" value="inventories" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px;">
    <div class="subpage-header__title">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Quản lý Tồn kho</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Theo dõi số lượng tồn kho theo SKU và cảnh báo sắp hết hàng.</p>
    </div>
  </div>

  <div class="premium-card" style="padding: 24px; margin-bottom: 24px;">
    <form action="${pageContext.request.contextPath}/admin/inventories" method="get" style="display: flex; gap: 16px; align-items: flex-end; flex-wrap: wrap;">
      <div style="flex: 1; min-width: 200px;">
        <label for="sku" style="display: block; font-size: 13px; font-weight: 600; color: var(--text-secondary); margin-bottom: 8px;">Tìm theo SKU</label>
        <input type="text" id="sku" name="sku" value="${param.sku}" placeholder="Nhập SKU..." style="width: 100%; padding: 10px 14px; border: 1px solid var(--card-border); border-radius: 8px; font-size: 14px; outline: none;">
      </div>
      <div style="flex: 1; min-width: 200px;">
        <label for="brandId" style="display: block; font-size: 13px; font-weight: 600; color: var(--text-secondary); margin-bottom: 8px;">Lọc theo Hãng</label>
        <select id="brandId" name="brandId" style="width: 100%; padding: 10px 14px; border: 1px solid var(--card-border); border-radius: 8px; font-size: 14px; outline: none; background: white;">
          <option value="">Tất cả các Hãng</option>
          <c:forEach var="b" items="${brands}">
            <option value="${b.id}" ${param.brandId == b.id ? 'selected' : ''}>${b.name}</option>
          </c:forEach>
        </select>
      </div>
      <div style="flex: 1; min-width: 200px;">
        <label for="productLineId" style="display: block; font-size: 13px; font-weight: 600; color: var(--text-secondary); margin-bottom: 8px;">Lọc theo Dòng sản phẩm</label>
        <select id="productLineId" name="productLineId" style="width: 100%; padding: 10px 14px; border: 1px solid var(--card-border); border-radius: 8px; font-size: 14px; outline: none; background: white;">
          <option value="">Tất cả các Dòng SP</option>
          <c:forEach var="pl" items="${productLines}">
            <option value="${pl.id}" ${param.productLineId == pl.id ? 'selected' : ''}>${pl.name}</option>
          </c:forEach>
        </select>
      </div>
      <div>
        <button type="submit" class="premium-btn-primary" style="height: 40px; padding: 0 20px; font-size: 14px;">Lọc / Tìm kiếm</button>
      </div>
    </form>
  </div>

  <div class="premium-card" style="padding: 32px;">
    <div style="overflow-x: auto; margin: 0 -32px; padding: 0 32px;">
      <table class="premium-table">
        <thead>
          <tr>
            <th>SKU</th>
            <th>Sản phẩm</th>
            <th style="text-align: right;">Số lượng Tồn</th>
            <th style="text-align: right;">Tồn tối thiểu</th>
            <th>Trạng thái</th>
            <th>Cập nhật lần cuối</th>
            <c:if test="${currentUser.hasPermission('INVENTORY_WRITE')}">
            <th style="text-align: center; width: 100px;">Hành động</th>
            </c:if>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="i" items="${inventories}">
            <tr class="user-row">
              <td><span class="premium-tag premium-tag--manager" style="font-family: monospace;">${i.product.sku}</span></td>
              <td>
                <strong style="color: var(--text-primary); font-size: 14px;">${i.product.name}</strong><br/>
                <small style="color: var(--text-secondary);">${i.product.productLine.brand.name} - ${i.product.productLine.name}</small>
              </td>
              <td style="text-align: right; font-weight: 700; font-size: 16px; ${i.quantityInStock <= i.minStockLevel ? 'color: #ef4444;' : 'color: #10b981;'}">
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
              <td style="color: var(--text-secondary); font-size: 13px;">
                <fmt:formatDate value="${i.lastUpdated}" pattern="dd/MM/yyyy HH:mm"/>
              </td>
              <c:if test="${currentUser.hasPermission('INVENTORY_WRITE')}">
              <td style="text-align: center;">
                <a href="${pageContext.request.contextPath}/admin/inventories?action=edit&productId=${i.productId}" class="action-btn" title="Chỉnh sửa cấu hình tồn kho">
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                    <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                  </svg>
                </a>
              </td>
              </c:if>
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
  select:focus, input:focus { border-color: var(--primary-color) !important; box-shadow: 0 0 0 3px rgba(4, 138, 191, 0.1) !important; }
</style>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
