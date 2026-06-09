<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quản lý tài khoản" scope="request"/>
<c:set var="activePage" value="users" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>
<c:set var="canWriteUser" value="${currentUser.hasPermission('USER_WRITE') || currentUser.hasRole('ADMIN')}"/>

<c:set var="pendingCount" value="0"/>
<c:forEach var="u" items="${users}">
  <c:if test="${u.status == 'PENDING'}">
    <c:set var="pendingCount" value="${pendingCount + 1}"/>
  </c:if>
</c:forEach>

<div class="subpage-container">
  <div class="subpage-header" style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px;">
    <div class="subpage-header__title">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0; display: inline-flex; align-items: center; gap: 12px;">
        Quản lý tài khoản
        <c:if test="${pendingCount > 0}">
          <div class="pending-notification-bell" title="Có ${pendingCount} tài khoản đang chờ phê duyệt" style="position: relative; display: inline-flex; cursor: pointer; align-items: center; justify-content: center; width: 36px; height: 36px; border-radius: 50%; background: rgba(245, 158, 11, 0.1); border: 1.5px solid rgba(245, 158, 11, 0.2);" onclick="filterToPending()">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: #d97706; animation: swing 2s infinite ease-in-out;">
              <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
              <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
            </svg>
            <span style="position: absolute; top: -4px; right: -4px; background-color: #ef4444; color: #ffffff; font-size: 10px; font-weight: 800; border-radius: 50%; width: 18px; height: 18px; display: inline-flex; align-items: center; justify-content: center; border: 2px solid #ffffff; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
              ${pendingCount}
            </span>
          </div>
        </c:if>
      </h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Phê duyệt tài khoản và cập nhật phân quyền.</p>
    </div>
    <c:if test="${canWriteUser}">
      <div>
        <a href="${pageContext.request.contextPath}/admin/users?action=create" class="premium-btn-primary" style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; height: 44px; line-height: 44px; box-sizing: border-box;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Thêm thành viên mới
        </a>
      </div>
    </c:if>
  </div>

  <!-- Table card: Danh sách thành viên -->
  <div class="premium-card" style="padding: 32px;">
    <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid var(--card-border);">
      <div style="display: flex; align-items: center; justify-content: center; width: 44px; height: 44px; border-radius: 12px; background: rgba(16, 185, 129, 0.1); color: var(--success-color);">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
          <circle cx="9" cy="7" r="4"></circle>
          <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
          <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
        </svg>
      </div>
      <div>
        <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">Danh sách tài khoản</h3>
        <p style="margin: 4px 0 0 0; font-size: 13px; color: var(--text-secondary);">Quản lý trạng thái và chỉnh sửa thông tin thành viên.</p>
      </div>
    </div>
    
    <!-- Search & Filter Toolbar -->
    <div style="display: flex; gap: 16px; margin-bottom: 24px; flex-wrap: wrap; align-items: center; justify-content: space-between;">
      <div style="display: flex; gap: 12px; flex: 1; min-width: 300px; max-width: 500px; position: relative;">
        <span style="position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: var(--text-secondary); font-size: 16px;">⌕</span>
        <input type="text" id="user-search" placeholder="Tìm kiếm theo Tên tài khoản, Họ tên, Email..." 
               value="<c:out value="${search}"/>"
               style="width: 100%; padding: 10px 16px 10px 40px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background: #ffffff;"
               oninput="onSearchInput()"
               onfocus="this.style.borderColor='var(--primary-color)';" 
               onblur="this.style.borderColor='var(--card-border)';"/>
      </div>
      
      <div style="display: flex; gap: 12px; align-items: center;">
        <div style="display: flex; flex-direction: column; gap: 4px;">
          <select id="filter-role" onchange="submitFilter()" 
                  style="padding: 10px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; font-weight: 600; color: var(--text-primary); outline: none; background: #ffffff; cursor: pointer; transition: all 0.2s;"
                  onfocus="this.style.borderColor='var(--primary-color)';" 
                  onblur="this.style.borderColor='var(--card-border)';">
            <option value="">Tất cả vai trò</option>
            <c:forEach var="r" items="${roles}">
              <option value="${r.code}" ${selectedRole == r.code ? 'selected' : ''}>${r.code}</option>
            </c:forEach>
          </select>
        </div>

        <div style="display: flex; flex-direction: column; gap: 4px;">
          <select id="filter-status" onchange="submitFilter()" 
                  style="padding: 10px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; font-weight: 600; color: var(--text-primary); outline: none; background: #ffffff; cursor: pointer; transition: all 0.2s;"
                  onfocus="this.style.borderColor='var(--primary-color)';" 
                  onblur="this.style.borderColor='var(--card-border)';">
            <option value="">Tất cả trạng thái</option>
            <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>Đang hoạt động</option>
            <option value="LOCKED" ${status == 'LOCKED' ? 'selected' : ''}>Bị khóa</option>
            <option value="PENDING" ${status == 'PENDING' ? 'selected' : ''}>Chờ phê duyệt</option>
          </select>
        </div>
      </div>
    </div>
    
    <div style="overflow-x: auto; margin: 0 -32px; padding: 0 32px;">
      <table class="premium-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Tên tài khoản</th>
            <th>Họ và tên</th>
            <th>Email</th>
            <th>Vai trò</th>
            <th style="width: 180px;">Trạng thái</th>
            <th style="text-align: center; width: 100px;">Hành động</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="u" items="${users}">
            <tr class="user-row">
              <td style="display:none;" class="user-details-data">
                <span class="det-id">${u.id}</span>
                <span class="det-username">${u.username}</span>
                <span class="det-fullname">${u.fullName}</span>
                <span class="det-email">${u.email}</span>
                <span class="det-status">${u.status}</span>
                <div class="det-roles">
                  <c:forEach var="r" items="${u.roles}">
                    <div class="det-role" data-code="${r.code}" data-name="${r.name}" data-desc="${r.description}">
                      <c:forEach var="pc" items="${r.permissionCodes}">
                        <span class="det-perm">${pc}</span>
                      </c:forEach>
                    </div>
                  </c:forEach>
                </div>
              </td>
              <td>#${u.id}</td>
              <td>
                <div style="display: flex; align-items: center; gap: 12px;">
                  <span class="user-menu__avatar user-menu__avatar--letter" style="width: 32px; height: 32px; font-size: 13px; border-radius: 8px; box-shadow: none;">
                    ${u.username.substring(0,1).toUpperCase()}
                  </span>
                  <a href="javascript:openUserDetailModal(${u.id})" style="color: var(--primary-color); text-decoration: none; font-weight: 700; font-size: 14px;" onmouseover="this.style.textDecoration='underline'" onmouseout="this.style.textDecoration='none'">
                    ${u.username}
                  </a>
                </div>
              </td>
              <td>${u.fullName}</td>
              <td>${u.email}</td>
              <td>
                <div style="display: flex; gap: 6px; flex-wrap: wrap;">
                  <c:forEach var="r" items="${u.roles}">
                    <c:choose>
                      <c:when test="${r.code == 'ADMIN'}"><c:set var="roleClass" value="premium-tag--admin"/></c:when>
                      <c:when test="${r.code == 'MANAGER'}"><c:set var="roleClass" value="premium-tag--manager"/></c:when>
                      <c:when test="${r.code == 'STAFF' || r.code == 'WAREHOUSE'}"><c:set var="roleClass" value="premium-tag--staff"/></c:when>
                      <c:otherwise><c:set var="roleClass" value="premium-tag--viewer"/></c:otherwise>
                    </c:choose>
                    <span class="premium-tag ${roleClass}">${r.code}</span>
                  </c:forEach>
                </div>
              </td>
              <td>
                <c:choose>
                  <c:when test="${u.status == 'ACTIVE'}">
                    <span class="premium-tag premium-tag--success" style="font-size: 12px; font-weight: 700; padding: 6px 14px; display: inline-flex; align-items: center; gap: 6px; letter-spacing: 0.02em; border-radius: 8px;">
                      <span style="width: 6px; height: 6px; border-radius: 50%; background-color: currentColor; display: inline-block;"></span>
                      Đang hoạt động
                    </span>
                  </c:when>
                  <c:when test="${u.status == 'LOCKED'}">
                    <span class="premium-tag premium-tag--danger" style="font-size: 12px; font-weight: 700; padding: 6px 14px; display: inline-flex; align-items: center; gap: 6px; letter-spacing: 0.02em; border-radius: 8px;">
                      <span style="width: 6px; height: 6px; border-radius: 50%; background-color: currentColor; display: inline-block;"></span>
                      Bị khóa
                    </span>
                  </c:when>
                  <c:otherwise>
                    <span class="premium-tag premium-tag--warning" style="font-size: 12px; font-weight: 700; padding: 6px 14px; display: inline-flex; align-items: center; gap: 6px; letter-spacing: 0.02em; border-radius: 8px;">
                      <span style="width: 6px; height: 6px; border-radius: 50%; background-color: currentColor; display: inline-block;"></span>
                      Chờ phê duyệt
                    </span>
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
                    <a href="${pageContext.request.contextPath}/admin/users?action=detail&id=${u.id}" class="action-dropdown-item" style="display: flex; align-items: center; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; color: var(--text-primary); text-decoration: none; transition: background 0.15s;">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                        <circle cx="12" cy="12" r="3"></circle>
                      </svg>
                      Xem chi tiết
                    </a>
                    
                    <c:if test="${canWriteUser && u.username != 'admin'}">
                      <a href="${pageContext.request.contextPath}/admin/users?action=edit&id=${u.id}" class="action-dropdown-item" style="display: flex; align-items: center; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; color: var(--text-primary); text-decoration: none; transition: background 0.15s;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                          <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                          <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                        </svg>
                        Chỉnh sửa
                      </a>
                      <c:choose>
                        <c:when test="${u.status == 'PENDING'}">
                          <form method="post" action="${pageContext.request.contextPath}/admin/users" style="margin: 0;">
                            <input type="hidden" name="action" value="toggle"/>
                            <input type="hidden" name="id" value="${u.id}"/>
                            <input type="hidden" name="status" value="ACTIVE"/>
                            <button type="submit" class="action-dropdown-item action-dropdown-item--primary" style="display: flex; align-items: center; width: 100%; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; background: none; border: none; text-align: left; cursor: pointer; transition: background 0.15s;">
                              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                                <polyline points="22 4 12 14.01 9 11.01"></polyline>
                              </svg>
                              Phê duyệt
                            </button>
                          </form>
                          <form method="post" action="${pageContext.request.contextPath}/admin/users" style="margin: 0;">
                            <input type="hidden" name="action" value="toggle"/>
                            <input type="hidden" name="id" value="${u.id}"/>
                            <input type="hidden" name="status" value="LOCKED"/>
                            <button type="submit" class="action-dropdown-item action-dropdown-item--danger" style="display: flex; align-items: center; width: 100%; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; background: none; border: none; text-align: left; cursor: pointer; transition: background 0.15s;">
                              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                              </svg>
                              Từ chối & Khóa
                            </button>
                          </form>
                        </c:when>
                        <c:when test="${u.status == 'ACTIVE'}">
                          <form method="post" action="${pageContext.request.contextPath}/admin/users" style="margin: 0;">
                            <input type="hidden" name="action" value="toggle"/>
                            <input type="hidden" name="id" value="${u.id}"/>
                            <input type="hidden" name="status" value="LOCKED"/>
                            <button type="submit" class="action-dropdown-item action-dropdown-item--danger" style="display: flex; align-items: center; width: 100%; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; background: none; border: none; text-align: left; cursor: pointer; transition: background 0.15s;">
                              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                              </svg>
                              Khóa tài khoản
                            </button>
                          </form>
                        </c:when>
                        <c:otherwise>
                          <form method="post" action="${pageContext.request.contextPath}/admin/users" style="margin: 0;">
                            <input type="hidden" name="action" value="toggle"/>
                            <input type="hidden" name="id" value="${u.id}"/>
                            <input type="hidden" name="status" value="ACTIVE"/>
                            <button type="submit" class="action-dropdown-item action-dropdown-item--primary" style="display: flex; align-items: center; width: 100%; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; background: none; border: none; text-align: left; cursor: pointer; transition: background 0.15s;">
                              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                <path d="M7 11V7a5 5 0 0 1 9.9-1"></path>
                              </svg>
                              Kích hoạt
                            </button>
                          </form>
                        </c:otherwise>
                      </c:choose>
                    </c:if>
                  </div>
                </div>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>

    <!-- Pagination Container -->
    <div class="pagination-container">
      <div class="pagination-info">
        Hiển thị <span style="font-weight: 700; color: var(--text-primary);">${totalCount == 0 ? 0 : (currentPage - 1) * pageSize + 1}</span> - <span style="font-weight: 700; color: var(--text-primary);">${(currentPage * pageSize) > totalCount ? totalCount : (currentPage * pageSize)}</span> trong số <span style="font-weight: 700; color: var(--text-primary);">${totalCount}</span> tài khoản
      </div>
      <div style="display: flex; align-items: center; gap: 16px;">
        <div style="display: flex; align-items: center; gap: 8px;">
          <span style="font-size: 13.5px; color: var(--text-secondary);">Hiển thị:</span>
          <select id="pag-size" class="page-size-selector" onchange="changePageSize(this.value)">
            <option value="5" ${pageSize == 5 ? 'selected' : ''}>5</option>
            <option value="10" ${pageSize == 10 ? 'selected' : ''}>10</option>
            <option value="20" ${pageSize == 20 ? 'selected' : ''}>20</option>
            <option value="50" ${pageSize == 50 ? 'selected' : ''}>50</option>
          </select>
        </div>
        <div id="pag-controls" class="pagination-controls">
          <button class="pagination-btn" ${currentPage == 1 ? 'disabled' : ''} onclick="changePage(${currentPage - 1})">&larr;</button>
          
          <c:set var="startPage" value="${currentPage - 2 < 1 ? 1 : currentPage - 2}"/>
          <c:set var="endPage" value="${currentPage + 2 > totalPages ? totalPages : currentPage + 2}"/>
          
          <c:if test="${startPage > 1}">
            <button class="pagination-btn" onclick="changePage(1)">1</button>
            <c:if test="${startPage > 2}">
              <span style="color: var(--text-secondary); padding: 0 4px;">...</span>
            </c:if>
          </c:if>
          
          <c:forEach var="p" begin="${startPage}" end="${endPage}">
            <button class="pagination-btn ${p == currentPage ? 'active' : ''}" onclick="changePage(${p})">${p}</button>
          </c:forEach>
          
          <c:if test="${endPage < totalPages}">
            <c:if test="${endPage < totalPages - 1}">
              <span style="color: var(--text-secondary); padding: 0 4px;">...</span>
            </c:if>
            <button class="pagination-btn" onclick="changePage(${totalPages})">${totalPages}</button>
          </c:if>
          
          <button class="pagination-btn" ${currentPage == totalPages ? 'disabled' : ''} onclick="changePage(${currentPage + 1})">&rarr;</button>
        </div>
      </div>
    </div>
  </div>
</div>



<style>
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
    font-size: 13px;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    padding: 16px 20px;
    border-bottom: 1.5px solid var(--card-border);
    text-align: left;
    white-space: nowrap;
  }
  .premium-table td {
    padding: 16px 20px;
    border-bottom: 1px solid var(--card-border);
    font-size: 14px;
    color: var(--text-primary);
    vertical-align: middle;
    white-space: nowrap;
  }
  .user-row {
    transition: opacity 0.2s ease, transform 0.2s ease;
  }
  .premium-table tr.user-row:hover td {
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
  .action-dropdown-item--primary {
    color: var(--primary-color) !important;
  }
  .premium-tag--danger {
    background: rgba(239, 68, 68, 0.1) !important;
    color: #ef4444 !important;
  }
  .premium-tag--warning {
    background: rgba(245, 158, 11, 0.1) !important;
    color: #d97706 !important;
  }
  .premium-tag--admin {
    background: rgba(30, 64, 175, 0.1) !important;
    color: #1e40af !important;
  }
  .premium-tag--manager {
    background: rgba(245, 158, 11, 0.1) !important;
    color: #d97706 !important;
  }
  .premium-tag--staff {
    background: rgba(16, 185, 129, 0.1) !important;
    color: #059669 !important;
  }
  .premium-tag--viewer {
    background: rgba(107, 114, 128, 0.1) !important;
    color: #4b5563 !important;
  }
  .action-dropdown-trigger:hover {
    border-color: var(--primary-color) !important;
    color: var(--primary-color) !important;
    background: rgba(4, 138, 191, 0.02) !important;
  }

  /* Pagination Styling */
  .pagination-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 24px;
    padding-top: 20px;
    border-top: 1.5px solid var(--card-border);
    flex-wrap: wrap;
    gap: 16px;
  }
  .pagination-info {
    font-size: 14px;
    color: var(--text-secondary);
  }
  .pagination-controls {
    display: flex;
    align-items: center;
    gap: 6px;
  }
  .pagination-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 36px;
    height: 36px;
    padding: 0 8px;
    border: 1.5px solid var(--card-border);
    border-radius: 8px;
    background: #ffffff;
    color: var(--text-primary);
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
  }
  .pagination-btn:hover:not(:disabled) {
    border-color: var(--primary-color);
    color: var(--primary-color);
    background: rgba(4, 138, 191, 0.02);
  }
  .pagination-btn.active {
    background: var(--primary-color);
    border-color: var(--primary-color);
    color: #ffffff;
  }
  .pagination-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    background: #f8fafc;
  }
  .page-size-selector {
    padding: 8px 12px;
    border: 1.5px solid var(--card-border);
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    color: var(--text-primary);
    outline: none;
    background: #ffffff;
    cursor: pointer;
    transition: all 0.2s;
  }
  .page-size-selector:focus {
    border-color: var(--primary-color);
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
    const searchVal = document.getElementById("user-search").value.trim();
    const statusVal = document.getElementById("filter-status").value;
    const roleVal = document.getElementById("filter-role").value;
    const size = document.getElementById("pag-size").value;

    window.location.href = `${pageContext.request.contextPath}/admin/users?search=` 
      + encodeURIComponent(searchVal) 
      + "&status=" + encodeURIComponent(statusVal) 
      + "&role=" + encodeURIComponent(roleVal) 
      + "&page=1" 
      + "&size=" + size;
  }

  function changePage(page) {
    const searchVal = document.getElementById("user-search").value.trim();
    const statusVal = document.getElementById("filter-status").value;
    const roleVal = document.getElementById("filter-role").value;
    const size = document.getElementById("pag-size").value;

    window.location.href = `${pageContext.request.contextPath}/admin/users?search=` 
      + encodeURIComponent(searchVal) 
      + "&status=" + encodeURIComponent(statusVal) 
      + "&role=" + encodeURIComponent(roleVal) 
      + "&page=" + page 
      + "&size=" + size;
  }

  function changePageSize(size) {
    const searchVal = document.getElementById("user-search").value.trim();
    const statusVal = document.getElementById("filter-status").value;
    const roleVal = document.getElementById("filter-role").value;

    window.location.href = `${pageContext.request.contextPath}/admin/users?search=` 
      + encodeURIComponent(searchVal) 
      + "&status=" + encodeURIComponent(statusVal) 
      + "&role=" + encodeURIComponent(roleVal) 
      + "&page=1" 
      + "&size=" + size;
  }

  document.addEventListener("DOMContentLoaded", function() {
    // Focus search input end of text if there is text
    const searchInput = document.getElementById("user-search");
    if (searchInput && searchInput.value) {
      searchInput.focus();
      const val = searchInput.value;
      searchInput.value = '';
      searchInput.value = val;
    }
  });

  function filterToPending() {
    const statusSelect = document.getElementById("filter-status");
    if (statusSelect) {
      statusSelect.value = "PENDING";
      filterUsersTable();
    }
  }


</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
