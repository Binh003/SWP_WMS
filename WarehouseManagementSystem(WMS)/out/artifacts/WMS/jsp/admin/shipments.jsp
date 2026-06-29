<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Quản lý Xuất kho" scope="request"/>
<c:set var="activePage" value="shipments" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px;">
    <div class="subpage-header__title">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Quản lý Xuất kho</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Danh sách các Phiếu xuất kho đến khách hàng hoặc chi nhánh.</p>
    </div>
    <c:if test="${currentUser.hasPermission('SHIPMENT_WRITE')}">
    <div>
      <a href="${pageContext.request.contextPath}/admin/shipments?action=create" class="premium-btn-primary" style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; height: 44px; line-height: 44px; box-sizing: border-box;">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
        Tạo Phiếu Xuất
      </a>
    </div>
    </c:if>
  </div>

  <!-- Stats/Summary Cards -->
  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 24px; margin-bottom: 28px;">
    
    <!-- Card 1: Pending Pick -->
    <div class="premium-card stats-card" onclick="filterByCard('APPROVED')" style="padding: 24px; display: flex; align-items: center; justify-content: space-between; border-left: 4px solid #f59e0b; background: linear-gradient(135deg, #ffffff, #fefaf0); position: relative; overflow: hidden; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03); cursor: pointer;">
      <div>
        <span style="font-size: 13px; font-weight: 600; color: #78350f; text-transform: uppercase; letter-spacing: 0.05em;">Chờ lấy hàng</span>
        <h3 style="font-size: 32px; font-weight: 800; color: #d97706; margin: 8px 0 4px 0; font-family: system-ui, -apple-system, sans-serif;">${pendingCount}</h3>
        <p style="font-size: 13px; color: #92400e; margin: 0; display: flex; align-items: center; gap: 4px;">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink: 0;"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="8" x2="12" y2="12"></line><line x1="12" y1="16" x2="12.01" y2="16"></line></svg>
          Phiếu xuất kho chờ lấy hàng
        </p>
      </div>
      <div style="width: 56px; height: 56px; border-radius: 12px; background: rgba(245, 158, 11, 0.1); display: flex; align-items: center; justify-content: center; color: #d97706;">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
          <polyline points="14 2 14 8 20 8"></polyline>
          <line x1="9" y1="15" x2="15" y2="15"></line>
          <line x1="12" y1="12" x2="12" y2="18"></line>
        </svg>
      </div>
      <div style="position: absolute; right: -20px; bottom: -20px; width: 100px; height: 100px; border-radius: 50%; background: rgba(245, 158, 11, 0.03); z-index: 0;"></div>
    </div>

    <!-- Card 2: In Progress -->
    <div class="premium-card stats-card" onclick="filterByCard('PICKING')" style="padding: 24px; display: flex; align-items: center; justify-content: space-between; border-left: 4px solid #3b82f6; background: linear-gradient(135deg, #ffffff, #eff6ff); position: relative; overflow: hidden; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03); cursor: pointer;">
      <div>
        <span style="font-size: 13px; font-weight: 600; color: #1e3a8a; text-transform: uppercase; letter-spacing: 0.05em;">Đang xử lý</span>
        <h3 style="font-size: 32px; font-weight: 800; color: #2563eb; margin: 8px 0 4px 0; font-family: system-ui, -apple-system, sans-serif;">${shippingCount}</h3>
        <p style="font-size: 13px; color: #1e40af; margin: 0; display: flex; align-items: center; gap: 4px;">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink: 0;"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
          Đang thực hiện lấy hàng & đóng gói
        </p>
      </div>
      <div style="width: 56px; height: 56px; border-radius: 12px; background: rgba(59, 130, 246, 0.1); display: flex; align-items: center; justify-content: center; color: #2563eb;">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect>
          <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path>
        </svg>
      </div>
      <div style="position: absolute; right: -20px; bottom: -20px; width: 100px; height: 100px; border-radius: 50%; background: rgba(59, 130, 246, 0.03); z-index: 0;"></div>
    </div>

    <!-- Card 3: Completed -->
    <div class="premium-card stats-card" onclick="filterByCard('COMPLETED')" style="padding: 24px; display: flex; align-items: center; justify-content: space-between; border-left: 4px solid #10b981; background: linear-gradient(135deg, #ffffff, #f0fdf4); position: relative; overflow: hidden; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.03); cursor: pointer;">
      <div>
        <span style="font-size: 13px; font-weight: 600; color: #064e3b; text-transform: uppercase; letter-spacing: 0.05em;">Hoàn thành</span>
        <h3 style="font-size: 32px; font-weight: 800; color: #059669; margin: 8px 0 4px 0; font-family: system-ui, -apple-system, sans-serif;">${completedCount}</h3>
        <p style="font-size: 13px; color: #065f46; margin: 0; display: flex; align-items: center; gap: 4px;">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink: 0;"><polyline points="20 6 9 17 4 12"></polyline></svg>
          Đã xuất kho và giao nhận thành công
        </p>
      </div>
      <div style="width: 56px; height: 56px; border-radius: 12px; background: rgba(16, 185, 129, 0.1); display: flex; align-items: center; justify-content: center; color: #059669;">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
          <polyline points="22 4 12 14.01 9 11.01"></polyline>
        </svg>
      </div>
      <div style="position: absolute; right: -20px; bottom: -20px; width: 100px; height: 100px; border-radius: 50%; background: rgba(16, 185, 129, 0.03); z-index: 0;"></div>
    </div>

  </div>

  <!-- Search & Filter Toolbar -->
  <div class="premium-card" style="padding: 20px; margin-bottom: 24px; background: #f8fafc; border: 1.5px solid var(--card-border); border-radius: 12px; display: flex; flex-direction: column; gap: 16px;">
    <!-- Row 1: Search, Status, Creator -->
    <div style="display: flex; gap: 12px; flex-wrap: wrap; align-items: center;">
      <!-- Search -->
      <div style="flex: 2; min-width: 280px; position: relative;">
        <span style="position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--text-secondary); font-size: 16px;">⌕</span>
        <input type="text" id="shipment-search" placeholder="Tìm kiếm theo mã phiếu, nơi nhận, ghi chú..." 
               oninput="filterShipments()"
               value="<c:out value="${search}"/>"
               style="width: 100%; padding: 10px 16px 10px 40px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background: #ffffff; box-sizing: border-box;"
               onfocus="this.style.borderColor='var(--primary-color)';" 
               onblur="this.style.borderColor='var(--card-border)';"/>
      </div>
      
      <!-- Status -->
      <div style="flex: 1; min-width: 160px;">
        <select id="filter-status" onchange="submitFilter()" 
                style="width: 100%; padding: 10px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; font-weight: 600; color: var(--text-primary); outline: none; background: #ffffff; cursor: pointer; transition: all 0.2s; box-sizing: border-box;"
                onfocus="this.style.borderColor='var(--primary-color)';" 
                onblur="this.style.borderColor='var(--card-border)';">
          <option value="ALL" ${selectedStatus == 'ALL' || empty selectedStatus ? 'selected' : ''}>Tất cả trạng thái</option>
          <option value="APPROVED" ${selectedStatus == 'APPROVED' ? 'selected' : ''}>Chờ lấy hàng</option>
          <option value="PICKING" ${selectedStatus == 'PICKING' ? 'selected' : ''}>Lấy & Đóng gói (Picking)</option>
          <option value="COMPLETED" ${selectedStatus == 'COMPLETED' ? 'selected' : ''}>Đã hoàn thành</option>
          <option value="CANCELLED" ${selectedStatus == 'CANCELLED' ? 'selected' : ''}>Đã hủy</option>
        </select>
      </div>

      <!-- Creator -->
      <div style="flex: 1; min-width: 180px;">
        <select id="filter-creator" onchange="submitFilter()" 
                style="width: 100%; padding: 10px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; font-weight: 600; color: var(--text-primary); outline: none; background: #ffffff; cursor: pointer; transition: all 0.2s; box-sizing: border-box;"
                onfocus="this.style.borderColor='var(--primary-color)';" 
                onblur="this.style.borderColor='var(--card-border)';">
          <option value="">Tất cả Người xuất</option>
          <c:forEach var="c" items="${creators}">
            <option value="${c.id}" ${selectedCreatorId == c.id ? 'selected' : ''}>${c.fullName}</option>
          </c:forEach>
        </select>
      </div>
    </div>

    <!-- Row 2: Date Filters + Reset Button -->
    <div style="display: flex; gap: 12px; flex-wrap: wrap; align-items: center;">
      <!-- Start Date -->
      <div style="display: flex; align-items: center; gap: 8px;">
        <span style="font-size: 13px; font-weight: 700; color: var(--text-secondary); white-space: nowrap;">Từ ngày:</span>
        <input type="date" id="filter-start-date" onchange="submitFilter()"
               value="${startDate}"
               style="padding: 8px 12px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 13px; font-weight: 600; color: var(--text-primary); outline: none; background: #ffffff; cursor: pointer; transition: all 0.2s;"
               onfocus="this.style.borderColor='var(--primary-color)';" 
               onblur="this.style.borderColor='var(--card-border)';"/>
      </div>

      <!-- End Date -->
      <div style="display: flex; align-items: center; gap: 8px;">
        <span style="font-size: 13px; font-weight: 700; color: var(--text-secondary); white-space: nowrap;">Đến ngày:</span>
        <input type="date" id="filter-end-date" onchange="submitFilter()"
               value="${endDate}"
               style="padding: 8px 12px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 13px; font-weight: 600; color: var(--text-primary); outline: none; background: #ffffff; cursor: pointer; transition: all 0.2s;"
               onfocus="this.style.borderColor='var(--primary-color)';" 
               onblur="this.style.borderColor='var(--card-border)';"/>
      </div>

      <!-- Clear Button -->
      <c:if test="${not empty search || (not empty selectedStatus && selectedStatus != 'ALL') || not empty selectedCreatorId || not empty startDate || not empty endDate}">
        <div style="margin-left: auto;">
          <button type="button" onclick="clearAllFilters()" class="premium-btn-outline" style="height: 38px !important; padding: 0 16px; font-size: 13px; color: #ef4444; border-color: rgba(239, 68, 68, 0.3); font-weight: 600; border-radius: 8px; transition: all 0.2s;"
                  onmouseover="this.style.background='rgba(239, 68, 68, 0.05)';"
                  onmouseout="this.style.background='transparent';">
            Xóa bộ lọc
          </button>
        </div>
      </c:if>
    </div>
  </div>

  <div class="premium-card" style="padding: 32px;">
    <div style="overflow-x: auto; margin: 0 -32px; padding: 0 32px;">
      <table class="premium-table">
        <thead>
          <tr>
            <th>Mã Phiếu</th>
            <th>Nơi nhận</th>
            <th>Ngày tạo</th>
            <th>Người xuất</th>
            <th>Trạng thái</th>
            <th style="text-align: center; width: 100px;">Hành động</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="s" items="${shipments}">
            <tr class="user-row">
              <td><span class="premium-tag premium-tag--manager" style="font-family: monospace;">${s.shipmentCode}</span></td>
              <td><strong style="color: var(--text-primary); font-size: 14px;">${s.destination}</strong></td>
              <td><fmt:formatDate value="${s.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
              <td>${s.creator.fullName}</td>
              <td>
                <c:choose>
                  <c:when test="${s.status == 'DRAFT'}">
                    <span class="premium-tag" style="background: rgba(100, 116, 139, 0.1); color: #64748b;">Nháp</span>
                  </c:when>
                  <c:when test="${s.status == 'PENDING'}">
                    <span class="premium-tag" style="background: rgba(245, 158, 11, 0.1); color: #d97706;">Chờ lấy hàng</span>
                  </c:when>
                  <c:when test="${s.status == 'APPROVED'}">
                    <span class="premium-tag" style="background: rgba(59, 130, 246, 0.1); color: #3b82f6;">Chờ lấy hàng</span>
                  </c:when>
                  <c:when test="${s.status == 'PICKING'}">
                    <span class="premium-tag" style="background: rgba(168, 85, 247, 0.1); color: #a855f7;">Lấy & Đóng gói</span>
                  </c:when>
                  <c:when test="${s.status == 'COMPLETED'}">
                    <span class="premium-tag" style="background: rgba(16, 185, 129, 0.1); color: #10b981;">Đã hoàn thành</span>
                  </c:when>
                  <c:otherwise>
                    <span class="premium-tag" style="background: rgba(239, 68, 68, 0.1); color: #ef4444;">Đã hủy</span>
                  </c:otherwise>
                </c:choose>
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
                    <a href="${pageContext.request.contextPath}/admin/shipments?action=view&id=${s.id}" class="action-dropdown-item" style="display: flex; align-items: center; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; color: var(--text-primary); text-decoration: none; transition: background 0.15s;">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                        <circle cx="12" cy="12" r="3"></circle>
                      </svg>
                      Xem chi tiết
                    </a>
                    
                    <c:if test="${s.status == 'DRAFT' || s.status == 'PENDING'}">
                      <c:if test="${currentUser.hasPermission('SHIPMENT_WRITE')}">
                        <a href="${pageContext.request.contextPath}/admin/shipments?action=delete&id=${s.id}" class="action-dropdown-item action-dropdown-item--danger" onclick="return confirm('Bạn có chắc chắn muốn xóa phiếu xuất này không? Hành động này không thể hoàn tác.');" style="display: flex; align-items: center; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; color: #ef4444; text-decoration: none; transition: background 0.15s;">
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="3 6 5 6 21 6"></polyline>
                            <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                          </svg>
                          Xóa yêu cầu xuất
                        </a>
                      </c:if>
                    </c:if>
                  </div>
                </div>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty shipments}">
            <tr>
              <td colspan="6" style="text-align: center; color: var(--text-secondary); padding: 32px;">Không tìm thấy phiếu xuất kho nào.</td>
            </tr>
          </c:if>
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
          <c:otherwise>${totalItems}</c:otherwise>
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
  .premium-table { width: 100%; min-width: 900px; border-collapse: collapse; margin-top: 8px; }
  .premium-table th { background: #f8fafc; color: var(--text-secondary); font-weight: 700; font-size: 13px; text-transform: uppercase; letter-spacing: 0.04em; padding: 16px 20px; border-bottom: 1.5px solid var(--card-border); text-align: left; white-space: nowrap; }
  .premium-table td { padding: 16px 20px; border-bottom: 1px solid var(--card-border); font-size: 14px; color: var(--text-primary); vertical-align: middle; white-space: nowrap; }
  .user-row { transition: opacity 0.2s ease, transform 0.2s ease; }
  .premium-table tr.user-row:hover td { background: rgba(4, 138, 191, 0.02); }
  .premium-tag--manager { background: rgba(245, 158, 11, 0.1) !important; color: #d97706 !important; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; }
  .action-dropdown-item {
    color: var(--text-primary);
  }
  .action-dropdown-item:hover {
    background-color: #f1f5f9;
  }
  .action-dropdown-item--danger {
    color: #ef4444 !important;
  }
  .action-dropdown-trigger:hover {
    border-color: var(--primary-color) !important;
    color: var(--primary-color) !important;
    background: rgba(4, 138, 191, 0.02) !important;
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
  
  .stats-card {
    transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  }
  .stats-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 28px rgba(0, 0, 0, 0.06) !important;
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
</style>

<script>
  const urlParams = new URLSearchParams(window.location.search);

  let searchTimeout;
  function filterShipments() {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(() => {
      submitFilter();
    }, 500);
  }

  function submitFilter() {
    const searchVal = document.getElementById("shipment-search").value.trim();
    const statusVal = document.getElementById("filter-status").value;
    const creatorVal = document.getElementById("filter-creator").value;
    const startDateVal = document.getElementById("filter-start-date").value;
    const endDateVal = document.getElementById("filter-end-date").value;
    
    if (searchVal) urlParams.set('search', searchVal); else urlParams.delete('search');
    if (statusVal) urlParams.set('status', statusVal); else urlParams.delete('status');
    if (creatorVal) urlParams.set('creatorId', creatorVal); else urlParams.delete('creatorId');
    if (startDateVal) urlParams.set('startDate', startDateVal); else urlParams.delete('startDate');
    if (endDateVal) urlParams.set('endDate', endDateVal); else urlParams.delete('endDate');
    
    urlParams.set('page', 1);
    window.location.search = urlParams.toString();
  }

  function clearAllFilters() {
    urlParams.delete('search');
    urlParams.delete('status');
    urlParams.delete('creatorId');
    urlParams.delete('startDate');
    urlParams.delete('endDate');
    urlParams.set('page', 1);
    window.location.search = urlParams.toString();
  }

  function filterByCard(status) {
    const statusSelect = document.getElementById("filter-status");
    if (statusSelect) {
      statusSelect.value = status;
      submitFilter();
    }
  }

  function goToPage(page) {
    urlParams.set('page', page);
    window.location.search = urlParams.toString();
  }

  function changeLimit(limit) {
    urlParams.set('limit', limit);
    urlParams.set('page', 1);
    window.location.search = urlParams.toString();
  }

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

  document.addEventListener("DOMContentLoaded", function() {
    // Focus search input end of text if there is text
    const searchInput = document.getElementById("shipment-search");
    if (searchInput && searchInput.value) {
      searchInput.focus();
      const val = searchInput.value;
      searchInput.value = '';
      searchInput.value = val;
    }
  });
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
