<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quản lý tài khoản" scope="request"/>
<c:set var="activePage" value="users" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px;">
    <div class="subpage-header__title">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Quản lý tài khoản</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Phê duyệt tài khoản và cập nhật phân quyền.</p>
    </div>
    <div>
      <a href="${pageContext.request.contextPath}/admin/users?action=create" class="premium-btn-primary" style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; height: 44px; line-height: 44px; box-sizing: border-box;">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
        Thêm thành viên mới
      </a>
    </div>
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
              <td>#${u.id}</td>
              <td>
                <div style="display: flex; align-items: center; gap: 12px;">
                  <span class="user-menu__avatar user-menu__avatar--letter" style="width: 32px; height: 32px; font-size: 13px; border-radius: 8px; box-shadow: none;">
                    ${u.username.substring(0,1).toUpperCase()}
                  </span>
                  <strong style="color: var(--text-primary); font-size: 14px;">${u.username}</strong>
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
                <span class="premium-tag ${u.enabled ? 'premium-tag--success' : 'premium-tag--danger'}" style="font-size: 12px; font-weight: 700; padding: 6px 14px; display: inline-flex; align-items: center; gap: 6px; letter-spacing: 0.02em; border-radius: 8px;">
                  <span style="width: 6px; height: 6px; border-radius: 50%; background-color: currentColor; display: inline-block;"></span>
                  ${u.enabled ? 'Đang hoạt động' : 'Bị khóa'}
                </span>
              </td>
              <td style="text-align: center; vertical-align: middle;">
                <c:choose>
                  <c:when test="${u.username == 'admin'}">
                    <div style="display: inline-flex; align-items: center; justify-content: center; width: 36px; height: 36px; border-radius: 8px; border: 1.5px dashed var(--card-border); background: #f8fafc; color: var(--text-secondary);" title="Tài khoản Admin hệ thống (Không thể chỉnh sửa)">
                      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                      </svg>
                    </div>
                  </c:when>
                  <c:otherwise>
                    <div class="action-dropdown-container" style="position: relative; display: inline-block; text-align: left;">
                      <button type="button" class="action-dropdown-trigger" onclick="toggleDropdown(this)" style="display: inline-flex; align-items: center; justify-content: center; width: 36px; height: 36px; border-radius: 8px; border: 1.5px solid var(--card-border); background: #ffffff; color: var(--text-secondary); cursor: pointer; transition: all 0.2s; padding: 0; box-shadow: 0 1px 2px rgba(0,0,0,0.05);">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                          <circle cx="12" cy="12" r="1.5"></circle>
                          <circle cx="12" cy="5" r="1.5"></circle>
                          <circle cx="12" cy="19" r="1.5"></circle>
                        </svg>
                      </button>
                      
                      <div class="action-dropdown-menu" style="display: none; position: absolute; right: 0; top: 40px; background: #ffffff; border: 1.5px solid var(--card-border); border-radius: 10px; box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08); z-index: 100; min-width: 160px; overflow: hidden; animation: slideDown 0.15s ease-out;">
                        <a href="${pageContext.request.contextPath}/admin/users?action=edit&id=${u.id}" class="action-dropdown-item" style="display: flex; align-items: center; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; color: var(--text-primary); text-decoration: none; transition: background 0.15s;">
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                            <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                          </svg>
                          Chỉnh sửa
                        </a>
                        <form method="post" action="${pageContext.request.contextPath}/admin/users" style="margin: 0;">
                          <input type="hidden" name="action" value="toggle"/>
                          <input type="hidden" name="id" value="${u.id}"/>
                          <input type="hidden" name="enabled" value="${!u.enabled}"/>
                          <button type="submit" class="action-dropdown-item ${u.enabled ? 'action-dropdown-item--danger' : 'action-dropdown-item--primary'}" style="display: flex; align-items: center; width: 100%; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; background: none; border: none; text-align: left; cursor: pointer; transition: background 0.15s;">
                            <c:choose>
                              <c:when test="${u.enabled}">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                  <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                  <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                                </svg>
                                Khóa tài khoản
                              </c:when>
                              <c:otherwise>
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                  <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                  <path d="M7 11V7a5 5 0 0 1 9.9-1"></path>
                                </svg>
                                Kích hoạt
                              </c:otherwise>
                            </c:choose>
                          </button>
                        </form>
                      </div>
                    </div>
                  </c:otherwise>
                </c:choose>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>

<style>
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
</style>

<script>
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
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
