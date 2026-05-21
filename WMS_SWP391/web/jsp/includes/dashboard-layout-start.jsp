<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <jsp:include page="head.jsp"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/subpages.css"/>
  <title>${pageTitle} - WMS_SWP391</title>
  <style>
    .flash { margin: 12px 24px; padding: 12px 16px; border-radius: 8px; font-size: 14px; }
    .flash--success { background: #ecfdf5; color: #047857; border: 1px solid #a7f3d0; }
    .flash--error { background: #fef2f2; color: #b91c1c; border: 1px solid #fecaca; }
    .brand-text { font-weight: 800; color: #048abf; font-size: 1.1rem; }
    .sidebar-nav--links a { display: flex; align-items: center; gap: 10px; width: 100%; padding: 12px 16px; margin-bottom: 4px; border-radius: 10px; color: var(--sidebar-text); text-decoration: none; font-weight: 600; }
    .sidebar-nav--links a:hover, .sidebar-nav--links a.active { background: var(--sidebar-active-bg); color: var(--sidebar-active-text); }
    .home-brand { text-decoration: none; }
  </style>
</head>
<body>
<div class="home-shell">
  <header class="home-topbar">
    <a class="home-brand" href="${pageContext.request.contextPath}/home">
      <span class="brand-text">V-Inventory WMS</span>
    </a>
    <label class="home-search" aria-label="Tìm kiếm">
      <span class="home-search__icon">⌕</span>
      <input type="search" placeholder="Tìm kiếm sản phẩm, mã phiếu..."/>
    </label>
    <div class="home-toolbar">
      <div class="user-menu">
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
      </div>
    </div>
  </header>

  <div class="home-layout">
    <aside class="home-sidebar">
      <nav class="sidebar-nav sidebar-nav--links" aria-label="Điều hướng">
        <a class="${activePage == 'home' ? 'active' : ''}" href="${pageContext.request.contextPath}/home">Bảng điều khiển</a>
        <c:set var="isAdmin" value="false"/>
        <c:forEach var="r" items="${currentUser.roles}">
          <c:if test="${r.code == 'ADMIN'}"><c:set var="isAdmin" value="true"/></c:if>
        </c:forEach>
        <c:if test="${isAdmin}">
          <a class="${activePage == 'users' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/users">Tài khoản</a>
          <a class="${activePage == 'roles' ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/roles">Vai trò</a>
        </c:if>
        <a class="${activePage == 'profile' ? 'active' : ''}" href="${pageContext.request.contextPath}/profile">Hồ sơ</a>
        <a class="${activePage == 'password' ? 'active' : ''}" href="${pageContext.request.contextPath}/change-password">Đổi mật khẩu</a>
        <a href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
      </nav>
    </aside>
    <main class="home-main">
      <jsp:include page="flash.jsp"/>
