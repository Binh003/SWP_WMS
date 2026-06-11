<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Quản lý Sản phẩm" scope="request"/>
<c:set var="activePage" value="products" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px;">
    <div class="subpage-header__title">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Quản lý Sản phẩm</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Quản lý danh sách các mặt hàng theo SKU.</p>
    </div>
    <c:if test="${currentUser.hasPermission('PRODUCT_WRITE')}">
    <div>
      <a href="${pageContext.request.contextPath}/admin/products?action=create" class="premium-btn-primary" style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; height: 44px; line-height: 44px; box-sizing: border-box;">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
        Thêm Sản phẩm
      </a>
    </div>
    </c:if>
  </div>

  <div class="premium-card" style="padding: 32px;">
    <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid var(--card-border);">
      <div style="display: flex; align-items: center; justify-content: center; width: 44px; height: 44px; border-radius: 12px; background: rgba(59, 130, 246, 0.1); color: #3b82f6;">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
          <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
          <line x1="12" y1="22.08" x2="12" y2="12"></line>
        </svg>
      </div>
      <div>
        <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">Danh sách Sản phẩm</h3>
      </div>
    </div>
    
    <div style="overflow-x: auto; margin: 0 -32px; padding: 0 32px;">
      <table class="premium-table">
        <thead>
          <tr>
            <th style="width: 60px; text-align: center;">Ảnh</th>
            <th>SKU</th>
            <th>Tên Sản phẩm</th>
            <th>Dòng SP / Hãng</th>
            <th>Đơn vị</th>
            <th>Giá bán</th>
            <th style="text-align: center; width: 100px;">Hành động</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="p" items="${products}">
            <tr class="user-row">
              <td style="text-align: center; vertical-align: middle; padding: 12px 16px;">
                <c:choose>
                  <c:when test="${not empty p.imageUrl}">
                    <img src="${p.imageUrl.startsWith('/') ? pageContext.request.contextPath : ''}${p.imageUrl}" 
                         style="width: 44px; height: 44px; border-radius: 8px; border: 1px solid var(--card-border); object-fit: cover;" />
                  </c:when>
                  <c:otherwise>
                    <div style="width: 44px; height: 44px; border-radius: 8px; border: 1px solid var(--card-border); background: #f8fafc; display: inline-flex; align-items: center; justify-content: center; color: var(--text-secondary);">
                      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
                        <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
                        <line x1="12" y1="22.08" x2="12" y2="12"></line>
                      </svg>
                    </div>
                  </c:otherwise>
                </c:choose>
              </td>
              <td><span class="premium-tag premium-tag--manager" style="font-family: monospace;">${p.sku}</span></td>
              <td>
                <strong style="color: var(--text-primary); font-size: 14px;">${p.name}</strong><br/>
                <small style="color: var(--text-secondary); display: block; max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${p.description}">${p.description}</small>
              </td>
              <td>
                <span style="font-weight: 600;">${p.productLine.name}</span><br/>
                <span class="premium-tag premium-tag--admin" style="margin-top: 4px; display: inline-block; padding: 2px 6px;">${p.productLine.brand.name}</span>
              </td>
              <td>${p.unit}</td>
              <td style="font-weight: 600; color: #10b981;">
                <c:if test="${not empty p.price}">
                  <fmt:formatNumber value="${p.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </c:if>
              </td>
              <td style="text-align: center; vertical-align: middle;">
                <div class="action-dropdown-container" style="position: relative; display: inline-block; text-align: left;">
                  <button type="button" class="action-dropdown-trigger" onclick="toggleDropdown(this)" style="display: inline-flex; align-items: center; justify-content: center; width: 36px; height: 36px; border-radius: 8px; border: 1.5px solid var(--card-border); background: #ffffff; color: var(--text-secondary); cursor: pointer; transition: all 0.2s; padding: 0; box-shadow: 0 1px 2px rgba(0,0,0,0.05);">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <circle cx="12" cy="12" r="1.5"></circle>
                      <circle cx="12" cy="5" r="1.5"></circle>
                      <circle cx="12" cy="19" r="1.5"></circle>
                    </svg>
                  </button>
                  <div class="action-dropdown-menu" style="display: none; position: absolute; right: 0; top: 40px; background: #ffffff; border: 1.5px solid var(--card-border); border-radius: 10px; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08); z-index: 100; min-width: 160px; overflow: hidden; animation: slideDown 0.15s ease-out;">
                    <a href="${pageContext.request.contextPath}/admin/products?action=view&id=${p.id}" class="action-dropdown-item" style="display: flex; align-items: center; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; color: var(--text-primary); text-decoration: none; transition: background 0.15s;">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                        <circle cx="12" cy="12" r="3"></circle>
                      </svg>
                      Xem chi tiết
                    </a>
                    <c:if test="${currentUser.hasPermission('PRODUCT_WRITE')}">
                      <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${p.id}" class="action-dropdown-item" style="display: flex; align-items: center; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; color: var(--text-primary); text-decoration: none; transition: background 0.15s;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                          <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                          <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                        </svg>
                        Chỉnh sửa
                      </a>
                      <form method="post" action="${pageContext.request.contextPath}/admin/products" style="margin: 0;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?');">
                        <input type="hidden" name="action" value="delete"/>
                        <input type="hidden" name="id" value="${p.id}"/>
                        <button type="submit" class="action-dropdown-item action-dropdown-item--danger" style="display: flex; align-items: center; width: 100%; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; background: none; border: none; text-align: left; cursor: pointer; transition: background 0.15s;">
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="3 6 5 6 21 6"></polyline>
                            <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                          </svg>
                          Xóa
                        </button>
                      </form>
                    </c:if>
                  </div>
                </div>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>

    <!-- Pagination Toolbar -->
    <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 24px; padding-top: 16px; border-top: 1.5px solid var(--card-border); flex-wrap: wrap; gap: 16px;">
      <div style="font-size: 14px; color: var(--text-secondary); font-weight: 600;">
        Hiển thị 
        <c:choose>
          <c:when test="${totalItems == 0}">0</c:when>
          <c:otherwise>${(currentPage - 1) * limit + 1}</c:otherwise>
        </c:choose>
        đến 
        <c:choose>
          <c:when test="${currentPage * limit > totalItems}">${totalItems}</c:when>
          <c:otherwise>${currentPage * limit}</c:otherwise>
        </c:choose>
        trong số <strong>${totalItems}</strong> bản ghi
      </div>

      <div style="display: flex; align-items: center; gap: 16px;">
        <!-- Limit selector -->
        <div style="display: flex; align-items: center; gap: 8px;">
          <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Số dòng:</span>
          <select onchange="changeLimit(this.value)" style="padding: 6px 12px; border: 1.5px solid var(--card-border); border-radius: 8px; font-size: 13px; font-weight: 600; color: var(--text-primary); outline: none; background: #ffffff; cursor: pointer;">
            <option value="5" ${limit == 5 ? 'selected' : ''}>5</option>
            <option value="10" ${limit == 10 ? 'selected' : ''}>10</option>
            <option value="20" ${limit == 20 ? 'selected' : ''}>20</option>
            <option value="50" ${limit == 50 ? 'selected' : ''}>50</option>
          </select>
        </div>

        <!-- Pagination Buttons -->
        <div style="display: flex; gap: 6px;">
          <button onclick="goToPage(1)" ${currentPage == 1 ? 'disabled' : ''} class="pagination-btn" title="Trang đầu">
            &laquo;
          </button>
          
          <button onclick="goToPage(${currentPage - 1})" ${currentPage == 1 ? 'disabled' : ''} class="pagination-btn" title="Trang trước">
            &lsaquo;
          </button>

          <c:forEach var="p" begin="${currentPage - 2 < 1 ? 1 : currentPage - 2}" end="${currentPage + 2 > totalPages ? totalPages : currentPage + 2}">
            <button onclick="goToPage(${p})" class="pagination-btn ${p == currentPage ? 'pagination-btn--active' : ''}">
              ${p}
            </button>
          </c:forEach>

          <button onclick="goToPage(${currentPage + 1})" ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''} class="pagination-btn" title="Trang sau">
            &rsaquo;
          </button>

          <button onclick="goToPage(${totalPages})" ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''} class="pagination-btn" title="Trang cuối">
            &raquo;
          </button>
        </div>
      </div>
    </div>
  </div>
</div>

<style>
  .premium-table { width: 100%; min-width: 1000px; border-collapse: collapse; margin-top: 8px; }
  .premium-table th { background: #f8fafc; color: var(--text-secondary); font-weight: 700; font-size: 13px; text-transform: uppercase; letter-spacing: 0.04em; padding: 16px 20px; border-bottom: 1.5px solid var(--card-border); text-align: left; white-space: nowrap; }
  .premium-table td { padding: 16px 20px; border-bottom: 1px solid var(--card-border); font-size: 14px; color: var(--text-primary); vertical-align: middle; white-space: nowrap; }
  .user-row { transition: opacity 0.2s ease, transform 0.2s ease; }
  .premium-table tr.user-row:hover td { background: rgba(4, 138, 191, 0.02); }
  .action-dropdown-item { color: var(--text-primary); }
  .action-dropdown-item:hover { background-color: #f1f5f9; }
  .action-dropdown-item--danger { color: #ef4444 !important; }
  .premium-tag--manager { background: rgba(245, 158, 11, 0.1) !important; color: #d97706 !important; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; }
  .premium-tag--admin { background: rgba(30, 64, 175, 0.1) !important; color: #1e40af !important; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; }
  .action-dropdown-trigger:hover { border-color: var(--primary-color) !important; color: var(--primary-color) !important; background: rgba(4, 138, 191, 0.02) !important; }
  @keyframes slideDown { from { opacity: 0; transform: translateY(-8px); } to { opacity: 1; transform: translateY(0); } }

  /* Pagination Buttons styling */
  .pagination-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 32px;
    height: 32px;
    padding: 0 6px;
    font-size: 13px;
    font-weight: 600;
    border: 1.5px solid var(--card-border);
    background: #ffffff;
    color: var(--text-secondary);
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s;
  }
  .pagination-btn:hover:not(:disabled) {
    border-color: var(--primary-color);
    color: var(--primary-color);
    background: rgba(4, 138, 191, 0.02);
  }
  .pagination-btn--active {
    background: var(--primary-color) !important;
    color: #ffffff !important;
    border-color: var(--primary-color) !important;
  }
  .pagination-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    background: #f8fafc;
  }
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

  const urlParams = new URLSearchParams(window.location.search);
  
  function goToPage(page) {
    urlParams.set('page', page);
    window.location.search = urlParams.toString();
  }

  function changeLimit(limit) {
    urlParams.set('limit', limit);
    urlParams.set('page', 1);
    window.location.search = urlParams.toString();
  }
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
