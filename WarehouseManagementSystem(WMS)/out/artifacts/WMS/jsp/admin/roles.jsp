<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quản lý vai trò" scope="request"/>
<c:set var="activePage" value="roles" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>
<c:set var="canWriteRole" value="${currentUser.hasPermission('ROLE_WRITE') || currentUser.hasRole('ADMIN')}"/>

<div class="subpage-container">
  <div class="subpage-header" style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px;">
    <div class="subpage-header__title">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Quản lý vai trò</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Quản lý danh sách vai trò và phân quyền tương ứng trên hệ thống.</p>
    </div>
    <c:if test="${canWriteRole}">
      <div>
        <a href="${pageContext.request.contextPath}/admin/roles?action=create" class="premium-btn-primary" style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; height: 44px; line-height: 44px; box-sizing: border-box;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Thêm vai trò mới
        </a>
      </div>
    </c:if>
  </div>

  <div class="premium-card" style="padding: 24px;">
    <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid var(--card-border);">
      <div style="display: flex; align-items: center; justify-content: center; width: 44px; height: 44px; border-radius: 12px; background: rgba(4, 138, 191, 0.1); color: var(--primary-color);">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polygon points="12 2 2 7 12 12 22 7 12 2"></polygon>
          <polyline points="2 17 12 22 22 17"></polyline>
          <polyline points="2 12 12 17 22 12"></polyline>
        </svg>
      </div>
      <div>
        <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">Danh sách vai trò & Quyền hạn</h3>
        <p style="margin: 4px 0 0 0; font-size: 13px; color: var(--text-secondary);">Thiết lập quyền nghiệp vụ cho từng nhóm đối tượng người dùng.</p>
      </div>
    </div>

    <!-- Search & Filter Toolbar -->
    <div style="display: flex; gap: 16px; margin-bottom: 24px; flex-wrap: wrap; align-items: center; justify-content: space-between;">
      <div style="display: flex; gap: 12px; flex: 1; min-width: 300px; max-width: 500px; position: relative;">
        <span style="position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--text-secondary); font-size: 16px;">⌕</span>
        <input type="text" id="role-search" placeholder="Tìm kiếm theo Mã, Tên vai trò, Quyền hạn..." 
               value="<c:out value="${search}"/>"
               style="width: 100%; padding: 10px 16px 10px 40px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background: #ffffff;"
               oninput="onSearchInput()"
               onfocus="this.style.borderColor='var(--primary-color)';" 
               onblur="this.style.borderColor='var(--card-border)';"/>
      </div>
      
      <div style="display: flex; gap: 12px; align-items: center;">
        <div style="display: flex; flex-direction: column; gap: 4px;">
          <select id="filter-status" onchange="submitFilter()" 
                  style="padding: 10px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; font-weight: 600; color: var(--text-primary); outline: none; background: #ffffff; cursor: pointer; transition: all 0.2s;"
                  onfocus="this.style.borderColor='var(--primary-color)';" 
                  onblur="this.style.borderColor='var(--card-border)';">
            <option value="">Tất cả trạng thái</option>
            <option value="active" ${status == 'active' ? 'selected' : ''}>Đang hoạt động</option>
            <option value="locked" ${status == 'locked' ? 'selected' : ''}>Bị khóa</option>
          </select>
        </div>
      </div>
    </div>

    <div style="overflow-x: auto; margin: 0 -24px; padding: 0 24px;">
      <table class="premium-table">
        <thead>
          <tr>
            <th style="width: 60px;">ID</th>
            <th style="width: 140px;">Mã vai trò</th>
            <th style="width: 180px;">Mô tả</th>
            <th style="width: 140px;">Trạng thái</th>
            <th style="text-align: center; width: 100px;">Hành động</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="r" items="${roles}">
            <tr class="role-row">
              <td>#${r.id}</td>
              <td style="display:none;" class="role-details-data">
                <span class="det-id">${r.id}</span>
                <span class="det-code">${r.code}</span>
                <span class="det-name">${r.name}</span>
                <span class="det-desc">${r.description}</span>
                <span class="det-enabled">${r.enabled}</span>
                <div class="det-permissions">
                  <c:forEach var="pc" items="${r.permissionCodes}">
                    <span class="det-perm">${pc}</span>
                  </c:forEach>
                </div>
              </td>
              <td>
                <a href="javascript:openRoleDetailModal(${r.id})" style="text-decoration: none; font-weight: 700; color: var(--primary-color);" onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                  <span class="premium-tag" style="background: rgba(4, 138, 191, 0.08); color: var(--primary-color); font-weight: 700; border: 1px solid rgba(4, 138, 191, 0.15); font-size: 13px; padding: 4px 10px; border-radius: 6px; cursor: pointer;">
                    ${r.code}
                  </span>
                </a>
              </td>
              <td class="desc-cell">
                <div style="color: var(--text-secondary); max-width: 180px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                  ${r.description}
                </div>
                <c:if test="${not empty r.description}">
                  <div class="desc-popup">
                    ${r.description}
                  </div>
                </c:if>
              </td>
              <td>
                <span class="premium-tag ${r.enabled ? 'premium-tag--success' : 'premium-tag--danger'}" style="font-size: 12px; font-weight: 700; padding: 6px 14px; display: inline-flex; align-items: center; gap: 6px; letter-spacing: 0.02em; border-radius: 8px;">
                  <span style="width: 6px; height: 6px; border-radius: 50%; background-color: currentColor; display: inline-block;"></span>
                  ${r.enabled ? 'Đang hoạt động' : 'Bị khóa'}
                </span>
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
                  
                  <div class="action-dropdown-menu" style="display: none; position: absolute; right: 0; top: 40px; background: #ffffff; border: 1.5px solid var(--card-border); border-radius: 10px; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08); z-index: 100; min-width: 150px; overflow: hidden; animation: slideDown 0.15s ease-out;">
                    <a href="${pageContext.request.contextPath}/admin/roles?action=detail&id=${r.id}" class="action-dropdown-item" style="display: flex; align-items: center; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; color: var(--text-primary); text-decoration: none; transition: background 0.15s;">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"></circle>
                        <line x1="12" y1="16" x2="12" y2="12"></line>
                        <line x1="12" y1="8" x2="12.01" y2="8"></line>
                      </svg>
                      Xem chi tiết
                    </a>
                    <c:if test="${canWriteRole && r.code != 'ADMIN'}">
                      <a href="${pageContext.request.contextPath}/admin/roles?action=edit&id=${r.id}" class="action-dropdown-item" style="display: flex; align-items: center; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; color: var(--text-primary); text-decoration: none; transition: background 0.15s;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                          <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                          <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                        </svg>
                        Chỉnh sửa
                      </a>
                    </c:if>
                    <c:if test="${canWriteRole}">
                      <c:if test="${r.code != 'ADMIN'}">
                        <form id="toggle-role-form-${r.id}" method="post" action="${pageContext.request.contextPath}/admin/roles" style="margin: 0;">
                          <input type="hidden" name="action" value="toggle-status"/>
                          <input type="hidden" name="id" value="${r.id}"/>
                          <input type="hidden" name="enabled" value="${not r.enabled}"/>
                          <c:choose>
                            <c:when test="${r.enabled}">
                              <button type="button" class="action-dropdown-item action-dropdown-item--danger" 
                                      onclick="if(confirm('Bạn có chắc chắn muốn không kích hoạt vai trò này?')) { document.getElementById('toggle-role-form-${r.id}').submit(); }"
                                      style="display: flex; align-items: center; width: 100%; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; background: none; border: none; text-align: left; cursor: pointer; transition: background 0.15s;">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                  <circle cx="12" cy="12" r="10"></circle>
                                  <line x1="4.93" y1="4.93" x2="19.07" y2="19.07"></line>
                                </svg>
                                Không kích hoạt
                              </button>
                            </c:when>
                            <c:otherwise>
                              <button type="button" class="action-dropdown-item action-dropdown-item--success" 
                                      onclick="if(confirm('Bạn có chắc chắn muốn kích hoạt vai trò này?')) { document.getElementById('toggle-role-form-${r.id}').submit(); }"
                                      style="display: flex; align-items: center; width: 100%; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; background: none; border: none; text-align: left; cursor: pointer; transition: background 0.15s;">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                  <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                                  <polyline points="22 4 12 14.01 9 11.01"></polyline>
                                </svg>
                                Kích hoạt
                              </button>
                            </c:otherwise>
                          </c:choose>
                        </form>
                      </c:if>
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
          <c:when test="${totalCount == 0}">0</c:when>
          <c:otherwise>${(currentPage - 1) * pageSize + 1}</c:otherwise>
        </c:choose>
        đến 
        <c:choose>
          <c:when test="${currentPage * pageSize > totalCount}">${totalCount}</c:when>
          <c:otherwise>${currentPage * pageSize}</c:otherwise>
        </c:choose>
        trong số <strong>${totalCount}</strong> vai trò
      </div>

      <div style="display: flex; align-items: center; gap: 16px;">
        <!-- Limit selector -->
        <div style="display: flex; align-items: center; gap: 8px;">
          <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Số dòng:</span>
          <select id="pag-size" onchange="changePageSize(this.value)" style="padding: 6px 12px; border: 1.5px solid var(--card-border); border-radius: 8px; font-size: 13px; font-weight: 600; color: var(--text-primary); outline: none; background: #ffffff; cursor: pointer;">
            <option value="5" ${pageSize == 5 ? 'selected' : ''}>5</option>
            <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
            <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
            <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
          </select>
        </div>

        <!-- Pagination Buttons -->
        <div style="display: flex; gap: 6px;">
          <button onclick="changePage(1)" ${currentPage == 1 ? 'disabled' : ''} class="pagination-btn" title="Trang đầu">
            &laquo;
          </button>
          
          <button onclick="changePage(${currentPage - 1})" ${currentPage == 1 ? 'disabled' : ''} class="pagination-btn" title="Trang trước">
            &lsaquo;
          </button>

          <c:forEach var="p" begin="${currentPage - 2 < 1 ? 1 : currentPage - 2}" end="${currentPage + 2 > totalPages ? totalPages : currentPage + 2}">
            <button onclick="changePage(${p})" class="pagination-btn ${p == currentPage ? 'pagination-btn--active' : ''}">
              ${p}
            </button>
          </c:forEach>

          <button onclick="changePage(${currentPage + 1})" ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''} class="pagination-btn" title="Trang sau">
            &rsaquo;
          </button>

          <button onclick="changePage(${totalPages})" ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''} class="pagination-btn" title="Trang cuối">
            &raquo;
          </button>
        </div>
      </div>
    </div>

  </div>
</div>



<style>
  /* Override layout classes to bypass browser CSS cache and expand container */
  .subpage-container {
    max-width: 100% !important;
  }
  .home-main {
    padding: 16px 20px !important;
  }
  .premium-card {
    padding: 24px !important;
  }

  /* Base Table styling */
  .premium-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 8px;
  }
  .premium-table th {
    background: #f8fafc;
    color: var(--text-secondary);
    font-weight: 700;
    font-size: 14px;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    padding: 18px 20px;
    border-bottom: 1.5px solid var(--card-border);
    text-align: left;
    white-space: nowrap;
  }
  .premium-table td {
    padding: 18px 20px;
    border-bottom: 1px solid var(--card-border);
    font-size: 15px;
    color: var(--text-primary);
    vertical-align: middle;
  }
  .desc-cell {
    position: relative;
  }
  .desc-popup {
    display: none;
    position: absolute;
    left: 80%;
    top: 50%;
    transform: translateY(-50%);
    background: #1e293b;
    color: #ffffff;
    padding: 8px 12px;
    border-radius: 6px;
    font-size: 13px;
    z-index: 1000;
    width: max-content;
    max-width: 280px;
    white-space: normal;
    word-break: break-word;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    pointer-events: none;
    line-height: 1.4;
  }
  .desc-popup::before {
    content: "";
    position: absolute;
    right: 100%;
    top: 50%;
    transform: translateY(-50%);
    border-width: 6px;
    border-style: solid;
    border-color: transparent #1e293b transparent transparent;
  }
  .desc-cell:hover .desc-popup {
    display: block;
  }
  .role-row {
    transition: opacity 0.2s ease, transform 0.2s ease;
  }
  .premium-table tr.role-row:hover td {
    background: rgba(4, 138, 191, 0.02);
  }
  .action-dropdown-item {
    color: var(--text-primary);
  }
  .action-dropdown-item:hover {
    background-color: #f1f5f9;
  }
  .action-dropdown-item--danger {
    color: #ef4444 !important;
  }
  .action-dropdown-item--success {
    color: #10b981 !important;
  }
  .premium-tag--danger {
    background: rgba(239, 68, 68, 0.1) !important;
    color: #ef4444 !important;
  }
  .action-dropdown-trigger:hover {
    border-color: var(--primary-color) !important;
    color: var(--primary-color) !important;
    background: rgba(4, 138, 191, 0.02) !important;
  }

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

  /* Premium Modal Style */
  .premium-modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 9999;
    align-items: center;
    justify-content: center;
  }
  .premium-modal-backdrop {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(15, 23, 42, 0.4);
    backdrop-filter: blur(6px);
    animation: fadeIn 0.2s ease-out;
  }
  .premium-modal-content {
    position: relative;
    width: 100%;
    max-width: 600px;
    background: #ffffff;
    border-radius: 16px;
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
    border: 1px solid var(--card-border);
    z-index: 1;
    overflow: hidden;
    animation: scaleUp 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
    display: flex;
    flex-direction: column;
    max-height: 85vh;
  }
  .premium-modal-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 20px 24px;
    border-bottom: 1.5px solid var(--card-border);
    background: #f8fafc;
  }
  .premium-modal-title {
    margin: 0;
    font-size: 18px;
    font-weight: 700;
    color: var(--text-primary);
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .premium-modal-close {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    font-size: 24px;
    font-weight: 300;
    border-radius: 8px;
    border: none;
    background: transparent;
    color: var(--text-secondary);
    cursor: pointer;
    transition: all 0.2s;
  }
  .premium-modal-close:hover {
    background: #e2e8f0;
    color: var(--text-primary);
  }
  .premium-modal-body {
    padding: 24px;
    overflow-y: auto;
    flex: 1;
  }
  .premium-modal-footer {
    padding: 16px 24px;
    border-top: 1.5px solid var(--card-border);
    background: #f8fafc;
    display: flex;
    justify-content: flex-end;
    gap: 12px;
  }
  .detail-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 18px;
    margin-bottom: 24px;
  }
  .detail-item {
    display: flex;
    flex-direction: column;
    gap: 4px;
  }
  .detail-label {
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: var(--text-secondary);
    font-weight: 700;
  }
  .detail-value {
    font-size: 14.5px;
    font-weight: 600;
    color: var(--text-primary);
  }
  .detail-value-full {
    grid-column: span 2;
  }

  @keyframes slideDown {
    from {
      opacity: 0;
      transform: translateY(-8px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }
  @keyframes scaleUp {
    from { opacity: 0; transform: scale(0.95); }
    to { opacity: 1; transform: scale(1); }
  }
</style>

<script>
  // Permission descriptions lookup
  const permissionNames = {
    "BRAND_READ": "Xem danh sách Hãng sản xuất",
    "BRAND_WRITE": "Thêm/Sửa/Xóa Hãng sản xuất",
    "SUPPLIER_READ": "Xem danh sách Nhà cung cấp",
    "SUPPLIER_WRITE": "Thêm/Sửa/Xóa Nhà cung cấp",
    "PRODUCT_LINE_READ": "Xem danh sách Dòng sản phẩm",
    "PRODUCT_LINE_WRITE": "Thêm/Sửa/Xóa Dòng sản phẩm",
    "PRODUCT_READ": "Xem danh sách Sản phẩm",
    "PRODUCT_WRITE": "Quản lý Sản phẩm",
    "INVENTORY_READ": "Xem Tồn kho sản phẩm",
    "INVENTORY_WRITE": "Quản lý cấu hình Tồn kho",
    "RECEIPT_READ": "Xem Phiếu Nhập kho",
    "RECEIPT_WRITE": "Tạo Phiếu Nhập kho",
    "SHIPMENT_READ": "Xem Phiếu Xuất kho",
    "SHIPMENT_WRITE": "Tạo Phiếu Xuất kho"
  };

  function toggleDropdown(button) {
    event.stopPropagation();
    const currentMenu = button.nextElementSibling;
    
    // Close other dropdowns first
    document.querySelectorAll('.action-dropdown-menu').forEach(menu => {
      if (menu !== currentMenu) {
        menu.style.display = 'none';
      }
    });
    
    if (currentMenu.style.display === 'block') {
      currentMenu.style.display = 'none';
    } else {
      currentMenu.style.display = 'block';
    }
  }

  // Close dropdowns when clicking outside
  document.addEventListener('click', function(event) {
    if (!event.target.closest('.action-dropdown-container')) {
      document.querySelectorAll('.action-dropdown-menu').forEach(menu => {
        menu.style.display = 'none';
      });
    }
  });

  // Server-side Pagination & Filtering redirection
  let searchTimeout;
  function onSearchInput() {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
      submitFilter();
    }, 500);
  }

  function submitFilter() {
    const searchVal = document.getElementById("role-search").value.trim();
    const statusVal = document.getElementById("filter-status").value;
    const size = document.getElementById("pag-size").value;

    window.location.href = `${pageContext.request.contextPath}/admin/roles?search=` 
      + encodeURIComponent(searchVal) 
      + "&status=" + encodeURIComponent(statusVal) 
      + "&page=1" 
      + "&size=" + size;
  }

  function changePage(page) {
    const searchVal = document.getElementById("role-search").value.trim();
    const statusVal = document.getElementById("filter-status").value;
    const size = document.getElementById("pag-size").value;

    window.location.href = `${pageContext.request.contextPath}/admin/roles?search=` 
      + encodeURIComponent(searchVal) 
      + "&status=" + encodeURIComponent(statusVal) 
      + "&page=" + page 
      + "&size=" + size;
  }

  function changePageSize(size) {
    const searchVal = document.getElementById("role-search").value.trim();
    const statusVal = document.getElementById("filter-status").value;

    window.location.href = `${pageContext.request.contextPath}/admin/roles?search=` 
      + encodeURIComponent(searchVal) 
      + "&status=" + encodeURIComponent(statusVal) 
      + "&page=1" 
      + "&size=" + size;
  }

  document.addEventListener("DOMContentLoaded", function() {
    // Focus search input end of text if there is text
    const searchInput = document.getElementById("role-search");
    if (searchInput && searchInput.value) {
      searchInput.focus();
      const val = searchInput.value;
      searchInput.value = '';
      searchInput.value = val;
    }
  });



  // Initialize
  document.addEventListener("DOMContentLoaded", function() {
    // No-op
  });
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
