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

  <div class="premium-card" style="padding: 32px;">
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
               style="width: 100%; padding: 10px 16px 10px 40px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background: #ffffff;"
               oninput="filterRolesTable()"
               onfocus="this.style.borderColor='var(--primary-color)';" 
               onblur="this.style.borderColor='var(--card-border)';"/>
      </div>
      
      <div style="display: flex; gap: 12px; align-items: center;">
        <div style="display: flex; flex-direction: column; gap: 4px;">
          <select id="filter-status" onchange="filterRolesTable()" 
                  style="padding: 10px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; font-weight: 600; color: var(--text-primary); outline: none; background: #ffffff; cursor: pointer; transition: all 0.2s;"
                  onfocus="this.style.borderColor='var(--primary-color)';" 
                  onblur="this.style.borderColor='var(--card-border)';">
            <option value="">Tất cả trạng thái</option>
            <option value="active">Đang hoạt động</option>
            <option value="locked">Bị khóa</option>
          </select>
        </div>
      </div>
    </div>

    <div style="overflow-x: auto; margin: 0 -32px; padding: 0 32px;">
      <table class="premium-table">
        <thead>
          <tr>
            <th style="width: 80px;">ID</th>
            <th style="width: 200px;">Mã vai trò</th>
            <th style="width: 220px;">Tên hiển thị</th>
            <th>Mô tả</th>
            <th>Quyền hạn được gán</th>
            <th style="width: 160px;">Trạng thái</th>
            <c:if test="${canWriteRole}">
              <th style="text-align: center; width: 100px;">Hành động</th>
            </c:if>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="r" items="${roles}">
            <tr class="role-row">
              <td>#${r.id}</td>
              <td>
                <span class="premium-tag" style="background: rgba(4, 138, 191, 0.08); color: var(--primary-color); font-weight: 700; border: 1px solid rgba(4, 138, 191, 0.15); font-size: 13px; padding: 4px 10px; border-radius: 6px;">
                  ${r.code}
                </span>
              </td>
              <td><strong style="color: var(--text-primary); font-size: 14px;">${r.name}</strong></td>
              <td style="color: var(--text-secondary); max-width: 240px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="${r.description}">${r.description}</td>
              <td>
                <div style="display: flex; gap: 4px; flex-wrap: wrap; max-width: 480px; padding: 4px 0;">
                  <c:choose>
                    <c:when test="${not empty r.permissionCodes}">
                      <c:forEach var="pc" items="${r.permissionCodes}">
                        <span class="premium-tag premium-tag--viewer" style="font-size: 11px; font-weight: 600; padding: 3px 8px; border-radius: 6px; background: rgba(100, 116, 139, 0.08); color: #475569; border: 1px solid rgba(100, 116, 139, 0.15);">
                          ${pc}
                        </span>
                      </c:forEach>
                    </c:when>
                    <c:otherwise>
                      <span style="color: var(--text-tertiary); font-style: italic; font-size: 13px;">Chưa phân quyền</span>
                    </c:otherwise>
                  </c:choose>
                </div>
              </td>
              <td>
                <span class="premium-tag ${r.enabled ? 'premium-tag--success' : 'premium-tag--danger'}" style="font-size: 12px; font-weight: 700; padding: 6px 14px; display: inline-flex; align-items: center; gap: 6px; letter-spacing: 0.02em; border-radius: 8px;">
                  <span style="width: 6px; height: 6px; border-radius: 50%; background-color: currentColor; display: inline-block;"></span>
                  ${r.enabled ? 'Đang hoạt động' : 'Bị khóa'}
                </span>
              </td>
              <c:if test="${canWriteRole}">
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
                      <a href="${pageContext.request.contextPath}/admin/roles?action=edit&id=${r.id}" class="action-dropdown-item" style="display: flex; align-items: center; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; color: var(--text-primary); text-decoration: none; transition: background 0.15s;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                          <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                          <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                        </svg>
                        Chỉnh sửa
                      </a>
                      <c:if test="${r.code != 'ADMIN'}">
                        <form id="delete-role-form-${r.id}" method="post" action="${pageContext.request.contextPath}/admin/roles" style="margin: 0;">
                          <input type="hidden" name="action" value="delete"/>
                          <input type="hidden" name="id" value="${r.id}"/>
                          <button type="button" class="action-dropdown-item action-dropdown-item--danger" 
                                  onclick="if(confirm('Bạn có chắc chắn muốn xóa vai trò này? Tất cả các liên kết tài khoản sẽ bị gỡ bỏ.')) { document.getElementById('delete-role-form-${r.id}').submit(); }"
                                  style="display: flex; align-items: center; width: 100%; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; background: none; border: none; text-align: left; cursor: pointer; transition: background 0.15s;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                              <polyline points="3 6 5 6 21 6"></polyline>
                              <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                              <line x1="10" y1="11" x2="10" y2="17"></line>
                              <line x1="14" y1="11" x2="14" y2="17"></line>
                            </svg>
                            Xóa vai trò
                          </button>
                        </form>
                      </c:if>
                    </div>
                  </div>
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
  .premium-tag--danger {
    background: rgba(239, 68, 68, 0.1) !important;
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

  function filterRolesTable() {
    const searchVal = document.getElementById("role-search").value.toLowerCase().trim();
    const statusVal = document.getElementById("filter-status").value;

    document.querySelectorAll(".role-row").forEach(row => {
      // 1. Search text match (Code, Name, Description, Permissions)
      const codeText = row.querySelector(".premium-tag").textContent.toLowerCase();
      const nameText = row.querySelector("strong").textContent.toLowerCase();
      const descText = row.cells[3].textContent.toLowerCase();
      
      // Let's gather all permission tags text
      let permText = "";
      row.querySelectorAll(".premium-tag--viewer").forEach(tag => {
        permText += tag.textContent.toLowerCase() + " ";
      });
      
      const matchesSearch = !searchVal || 
                            codeText.includes(searchVal) || 
                            nameText.includes(searchVal) || 
                            descText.includes(searchVal) ||
                            permText.includes(searchVal);

      // 2. Status filter match
      let matchesStatus = !statusVal;
      if (statusVal) {
        const statusText = row.querySelector(".premium-tag--success, .premium-tag--danger").textContent.trim().toLowerCase();
        if (statusVal === "active" && statusText.includes("hoạt động")) {
          matchesStatus = true;
        } else if (statusVal === "locked" && statusText.includes("khóa")) {
          matchesStatus = true;
        }
      }

      // Show/hide row
      if (matchesSearch && matchesStatus) {
        row.style.display = "";
        row.style.opacity = "1";
      } else {
        row.style.display = "none";
        row.style.opacity = "0";
      }
    });
  }
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
