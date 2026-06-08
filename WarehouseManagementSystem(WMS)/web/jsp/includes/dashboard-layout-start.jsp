<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <jsp:include page="head.jsp"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/subpages.css?v=3"/>
  <title>${pageTitle} - WarehouseManagementSystem(WMS)</title>
  <style>
    .flash { margin: 12px 24px; padding: 12px 16px; border-radius: 8px; font-size: 14px; }
    .flash--success { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; }
    .flash--error { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
    .brand-text { font-weight: 800; color: #048abf; font-size: 1.1rem; }
    .sidebar-nav--links a { display: flex; align-items: center; gap: 10px; width: 100%; padding: 12px 16px; margin-bottom: 4px; border-radius: 10px; color: var(--sidebar-text); text-decoration: none; font-weight: 600; }
    .sidebar-nav--links a:hover, .sidebar-nav--links a.active { background: var(--sidebar-active-bg); color: var(--sidebar-active-text); }
    .home-brand {
      text-decoration: none;
      display: flex !important;
      align-items: center !important;
      justify-content: center !important;
      padding: 0 16px !important;
    }
    
    /* Collapsed brand styling */
    .home-shell--collapsed .home-topbar {
      grid-template-columns: 80px 1fr auto;
    }
    .home-shell--collapsed .home-brand {
      width: 80px;
      padding: 0 !important;
      border-right: 1px solid #e2e8f0;
      justify-content: center !important;
    }
    .home-shell--collapsed .brand-text-long {
      display: none;
    }
    .home-shell--collapsed .brand-text-short {
      display: inline-block;
      font-size: 1.5rem;
      font-weight: 900;
      color: #048abf;
    }
    .brand-text-short {
      display: none;
    }
    
    /* Collapsed sidebar nav links styling */
    .home-layout--collapsed .sidebar-nav--links a {
      justify-content: center;
      padding: 12px 0;
      gap: 0;
    }
    .sidebar-nav--links a span {
      opacity: 1;
      transition: opacity 0.2s ease, width 0.2s ease, margin 0.2s ease;
      white-space: nowrap;
    }
    .home-layout--collapsed .sidebar-nav--links a span {
      opacity: 0;
      width: 0;
      margin: 0;
      padding: 0;
      overflow: hidden;
      pointer-events: none;
      display: inline-block;
    }
    
    /* Rotate toggle icon */
    .home-layout--collapsed .sidebar-toggle svg {
      transform: rotate(180deg);
    }
    
    /* Smooth transitions for all collapsed/expanded elements */
    .home-topbar, .home-brand, .brand-text, .home-sidebar, .sidebar-nav--links a {
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .sidebar-toggle svg {
      transition: transform 0.3s ease;
    }
  </style>
</head>
<body>
<div class="home-shell" id="homeShell">
  <script>
    if (localStorage.getItem('sidebar-collapsed') === 'true') {
      document.getElementById('homeShell').classList.add('home-shell--collapsed');
    }
  </script>
  <header class="home-topbar">
    <a class="home-brand" href="${pageContext.request.contextPath}/home">
      <img src="${pageContext.request.contextPath}/assets/logo.png" alt="V-Inventory" style="height: 50px; width: auto; object-fit: contain; max-width: 100%;"/>
    </a>
    <label class="home-search" aria-label="Tìm kiếm">
      <span class="home-search__icon">⌕</span>
      <input type="search" placeholder="Tìm kiếm sản phẩm, mã phiếu..."/>
    </label>
    <div class="home-toolbar">
      <div class="user-menu" tabindex="0">
        <div class="user-menu__trigger">
          <span class="user-menu__text">
            <strong>${currentUser.username}</strong>
            <span>
              <c:forEach var="r" items="${currentUser.roles}" varStatus="st">
                ${r.code}<c:if test="${!st.last}">, </c:if>
              </c:forEach>
            </span>
          </span>
          <span class="user-menu__avatar user-menu__avatar--letter">
            ${currentUser.username.substring(0,1).toUpperCase()}
          </span>
          <span class="user-menu__caret" aria-hidden="true">▼</span>
        </div>
        
        <div class="user-dropdown">
          <a href="${pageContext.request.contextPath}/profile" class="user-dropdown__item">
            <svg class="item-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M20 21C20 19.6044 20 18.9067 19.6847 18.3022C19.2618 17.4913 18.5087 16.8393 17.587 16.4831C16.9 16.2174 16.1022 16.2174 14.5066 16.2174H9.49339C7.89781 16.2174 7.09997 16.2174 6.413 16.4831C5.49129 16.8393 4.73819 17.4913 4.31527 18.3022C4 18.9067 4 19.6044 4 21" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              <circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="2"/>
            </svg>
            Hồ sơ cá nhân
          </a>
          <a href="${pageContext.request.contextPath}/change-password" class="user-dropdown__item">
            <svg class="item-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M7.5 10V8.5C7.5 6.01472 9.51472 4 12 4C14.4853 4 16.5 6.01472 16.5 8.5V10" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              <path d="M6.5 10H17.5C18.6046 10 19.5 10.8954 19.5 12V18C19.5 19.1046 18.6046 20 17.5 20H6.5C5.39543 20 4.5 19.1046 4.5 18V12C4.5 10.8954 5.39543 10 6.5 10Z" stroke="currentColor" stroke-width="2"/>
              <circle cx="12" cy="15" r="1.5" fill="currentColor"/>
            </svg>
            Đổi mật khẩu
          </a>
          <div class="user-dropdown__divider"></div>
          <a href="${pageContext.request.contextPath}/logout" class="user-dropdown__item user-dropdown__item--danger">
            <svg class="item-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M16 17L21 12L16 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M21 12H9" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M9 21H5C3.89543 21 3 20.1046 3 19V5C3 3.89543 3.89543 3 5 3H9" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            Đăng xuất
          </a>
        </div>
      </div>
    </div>
  </header>

  <div class="home-layout" id="homeLayout">
    <script>
      if (localStorage.getItem('sidebar-collapsed') === 'true') {
        document.getElementById('homeLayout').classList.add('home-layout--collapsed');
      }
    </script>
    <aside class="home-sidebar" id="homeSidebar">
      <button type="button" class="sidebar-toggle" id="sidebarToggle" aria-label="Thu gọn/Mở rộng">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="15 18 9 12 15 6"></polyline>
        </svg>
      </button>
      <nav class="sidebar-nav sidebar-nav--links" aria-label="Điều hướng">
        <a class="${activePage == 'home' ? 'active' : ''}" href="${pageContext.request.contextPath}/home">
          <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <rect x="3" y="3" width="7" height="9"></rect>
            <rect x="14" y="3" width="7" height="5"></rect>
            <rect x="14" y="12" width="7" height="9"></rect>
            <rect x="3" y="16" width="7" height="5"></rect>
          </svg>
          <span>Bảng điều khiển</span>
        </a>
        <c:set var="isAdmin" value="${currentUser.hasRole('ADMIN')}"/>
        
        <c:set var="canManageUsers" value="${isAdmin || currentUser.hasPermission('USER_READ') || currentUser.hasPermission('USER_WRITE')}"/>
        <c:set var="canManageRoles" value="${isAdmin || currentUser.hasPermission('ROLE_READ') || currentUser.hasPermission('ROLE_WRITE') || currentUser.hasPermission('PERMISSION_READ')}"/>
        
        <c:set var="canViewBrands" value="${isAdmin || currentUser.hasPermission('BRAND_READ') || currentUser.hasPermission('BRAND_WRITE')}"/>
        <c:set var="canViewSuppliers" value="${isAdmin || currentUser.hasPermission('SUPPLIER_READ') || currentUser.hasPermission('SUPPLIER_WRITE')}"/>
        <c:set var="canViewProductLines" value="${isAdmin || currentUser.hasPermission('PRODUCT_LINE_READ') || currentUser.hasPermission('PRODUCT_LINE_WRITE')}"/>
        <c:set var="canViewProducts" value="${isAdmin || currentUser.hasPermission('PRODUCT_READ') || currentUser.hasPermission('PRODUCT_WRITE')}"/>
        <c:set var="canViewInventories" value="${isAdmin || currentUser.hasPermission('INVENTORY_READ') || currentUser.hasPermission('INVENTORY_WRITE')}"/>
        
        <c:if test="${canManageUsers}">
          <a class="${activePage == 'users' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/users">
            <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
              <circle cx="9" cy="7" r="4"></circle>
              <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
              <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
            </svg>
            <span>Quản lý tài khoản</span>
          </a>
        </c:if>

        <c:if test="${canManageRoles}">
          <a class="${activePage == 'roles' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/roles">
            <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
            </svg>
            <span>Quản lý vai trò</span>
          </a>
        </c:if>

        <c:if test="${canViewBrands}">
          <a class="${activePage == 'brands' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/brands">
            <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path>
              <line x1="7" y1="7" x2="7.01" y2="7"></line>
            </svg>
            <span>Quản lý Hãng</span>
          </a>
        </c:if>

        <c:if test="${canViewSuppliers}">
          <a class="${activePage == 'suppliers' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/suppliers">
            <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="11" width="18" height="10" rx="2" ry="2"></rect>
              <circle cx="12" cy="5" r="2"></circle>
              <path d="M12 7v4"></path>
            </svg>
            <span>Nhà cung cấp</span>
          </a>
        </c:if>

        <c:if test="${canViewProductLines}">
          <a class="${activePage == 'product-lines' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/product-lines">
            <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="4" y="4" width="16" height="16" rx="2" ry="2"></rect>
              <rect x="9" y="9" width="6" height="6"></rect>
            </svg>
            <span>Dòng sản phẩm</span>
          </a>
        </c:if>

        <c:if test="${canViewProducts}">
          <a class="${activePage == 'products' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/products">
            <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
              <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
              <line x1="12" y1="22.08" x2="12" y2="12"></line>
            </svg>
            <span>Quản lý Sản phẩm</span>
          </a>
        </c:if>

        <c:if test="${canViewInventories}">
          <a class="${activePage == 'inventories' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/inventories">
            <svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21.21 15.89A10 10 0 1 1 8 2.83"></path>
              <path d="M22 12A10 10 0 0 0 12 2v10z"></path>
            </svg>
            <span>Quản lý Tồn kho</span>
          </a>
        </c:if>
      </nav>
    </aside>
    <main class="home-main">
      <jsp:include page="flash.jsp"/>
