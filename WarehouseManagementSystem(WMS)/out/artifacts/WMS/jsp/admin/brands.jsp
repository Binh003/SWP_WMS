<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quản lý Hãng" scope="request"/>
<c:set var="activePage" value="brands" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px;">
    <div class="subpage-header__title">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Quản lý Hãng sản xuất</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Quản lý danh sách các nhãn hiệu, thương hiệu sản phẩm.</p>
    </div>
    <c:if test="${currentUser.hasPermission('BRAND_WRITE')}">
    <div>
      <a href="${pageContext.request.contextPath}/admin/brands?action=create" class="premium-btn-primary" style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; height: 44px; line-height: 44px; box-sizing: border-box;">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
        Thêm Hãng mới
      </a>
    </div>
    </c:if>
  </div>

  <div class="premium-card" style="padding: 32px;">
    <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 24px; padding-bottom: 16px; border-bottom: 1px solid var(--card-border);">
      <div style="display: flex; align-items: center; justify-content: center; width: 44px; height: 44px; border-radius: 12px; background: rgba(16, 185, 129, 0.1); color: var(--success-color);">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path>
          <line x1="7" y1="7" x2="7.01" y2="7"></line>
        </svg>
      </div>
      <div>
        <h3 style="margin: 0; font-size: 18px; font-weight: 700; color: var(--text-primary);">Danh sách Hãng</h3>
      </div>
    </div>
    
    <div style="overflow-x: auto; margin: 0 -32px; padding: 0 32px;">
      <table class="premium-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Mã Hãng</th>
            <th>Tên Hãng</th>
            <th>Mô tả</th>
            <c:if test="${currentUser.hasPermission('BRAND_WRITE')}">
            <th style="text-align: center; width: 100px;">Hành động</th>
            </c:if>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="b" items="${brands}">
            <tr class="user-row">
              <td>#${b.id}</td>
              <td><span class="premium-tag premium-tag--manager">${b.code}</span></td>
              <td><strong style="color: var(--text-primary); font-size: 14px;">${b.name}</strong></td>
              <td>${b.description}</td>
              <c:if test="${currentUser.hasPermission('BRAND_WRITE')}">
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
                    <a href="${pageContext.request.contextPath}/admin/brands?action=edit&id=${b.id}" class="action-dropdown-item" style="display: flex; align-items: center; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; color: var(--text-primary); text-decoration: none; transition: background 0.15s;">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                        <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                      </svg>
                      Chỉnh sửa
                    </a>
                    <form method="post" action="${pageContext.request.contextPath}/admin/brands" style="margin: 0;" onsubmit="return confirm('Bạn có chắc chắn muốn xóa hãng này?');">
                      <input type="hidden" name="action" value="delete"/>
                      <input type="hidden" name="id" value="${b.id}"/>
                      <button type="submit" class="action-dropdown-item action-dropdown-item--danger" style="display: flex; align-items: center; width: 100%; gap: 8px; padding: 12px 16px; font-size: 13px; font-weight: 600; background: none; border: none; text-align: left; cursor: pointer; transition: background 0.15s;">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                          <polyline points="3 6 5 6 21 6"></polyline>
                          <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                        </svg>
                        Xóa
                      </button>
                    </form>
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
  .premium-table { width: 100%; border-collapse: collapse; margin-top: 8px; }
  .premium-table th { background: #f8fafc; color: var(--text-secondary); font-weight: 700; font-size: 13px; text-transform: uppercase; letter-spacing: 0.04em; padding: 16px 20px; border-bottom: 1.5px solid var(--card-border); text-align: left; white-space: nowrap; }
  .premium-table td { padding: 16px 20px; border-bottom: 1px solid var(--card-border); font-size: 14px; color: var(--text-primary); vertical-align: middle; white-space: nowrap; }
  .user-row { transition: opacity 0.2s ease, transform 0.2s ease; }
  .premium-table tr.user-row:hover td { background: rgba(4, 138, 191, 0.02); }
  .action-dropdown-item { color: var(--text-primary); }
  .action-dropdown-item:hover { background-color: #f1f5f9; }
  .action-dropdown-item--danger { color: #ef4444 !important; }
  .premium-tag--manager { background: rgba(245, 158, 11, 0.1) !important; color: #d97706 !important; padding: 4px 10px; border-radius: 6px; font-size: 12px; font-weight: 700; }
  .action-dropdown-trigger:hover { border-color: var(--primary-color) !important; color: var(--primary-color) !important; background: rgba(4, 138, 191, 0.02) !important; }
  @keyframes slideDown { from { opacity: 0; transform: translateY(-8px); } to { opacity: 1; transform: translateY(0); } }
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
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
