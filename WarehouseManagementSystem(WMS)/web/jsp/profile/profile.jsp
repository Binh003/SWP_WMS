<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Hồ sơ" scope="request"/>
<c:set var="activePage" value="profile" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="display: flex; flex-direction: column; align-items: flex-start; gap: 4px; margin-bottom: 24px;">
    <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Hồ sơ cá nhân</h2>
    <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Thông tin tài khoản đang đăng nhập.</p>
  </div>
  
  <div class="profile-layout-grid">
    <!-- Left Column: User details -->
    <div class="premium-card profile-card">
      <div class="avatar-container">
        <img class="avatar-image" src="${pageContext.request.contextPath}/assets/profile_avatar.png" alt="Avatar"/>
        <span class="status-dot"></span>
      </div>
      
      <div class="profile-info-list">
        <!-- Row 1: Username -->
        <div class="profile-info-row">
          <span class="profile-info-icon">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M20 21C20 19.6044 20 18.9067 19.6847 18.3022C19.2618 17.4913 18.5087 16.8393 17.587 16.4831C16.9 16.2174 16.1022 16.2174 14.5066 16.2174H9.49339C7.89781 16.2174 7.09997 16.2174 6.413 16.4831C5.49129 16.8393 4.73819 17.4913 4.31527 18.3022C4 18.9067 4 19.6044 4 21" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              <circle cx="12" cy="8" r="4" stroke="currentColor" stroke-width="2"/>
            </svg>
          </span>
          <span class="profile-info-label">Username:</span>
          <span class="profile-info-value">${currentUser.username}</span>
        </div>
        
        <!-- Row 2: Họ tên -->
        <div class="profile-info-row">
          <span class="profile-info-icon">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M20 21C20 19.6044 20 18.9067 19.6847 18.3022C19.2618 17.4913 18.5087 16.8393 17.587 16.4831C16.9 16.2174 16.1022 16.2174 14.5066 16.2174H9.49339" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              <path d="M14 19L16 21L21 16" stroke="#10b981" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <circle cx="10" cy="8" r="4" stroke="currentColor" stroke-width="2"/>
            </svg>
          </span>
          <span class="profile-info-label">Họ tên:</span>
          <span class="profile-info-value">${currentUser.fullName}</span>
        </div>
        
        <!-- Row 3: Email -->
        <div class="profile-info-row">
          <span class="profile-info-icon">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M4 4H20C21.1 4 22 4.9 22 6V18C22 19.1 21.1 20 20 20H4C2.9 20 2 19.1 2 18V6C2 4.9 2.9 4 4 4Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M22 6L12 13L2 6" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </span>
          <span class="profile-info-label">Email:</span>
          <span class="profile-info-value">${currentUser.email}</span>
        </div>
        
        <!-- Row 4: Vai trò -->
        <div class="profile-info-row">
          <span class="profile-info-icon">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 15C13.6569 15 15 13.6569 15 12C15 10.3431 13.6569 9 12 9C10.3431 9 9 10.3431 9 12C9 13.6569 10.3431 15 12 15Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <path d="M12 2L15 8L21.5 9L17 14L18.5 21L12 17.5L5.5 21L7 14L2.5 9L9 8L12 2Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </span>
          <span class="profile-info-label">Vai trò:</span>
          <span class="profile-info-value" style="text-transform: uppercase;">
            <c:forEach var="r" items="${currentUser.roles}" varStatus="st">
              ${r.code}<c:if test="${!st.last}">, </c:if>
            </c:forEach>
          </span>
        </div>
      </div>
    </div>
    
    <!-- Right Column: Navigation options & Login Sessions -->
    <div class="profile-btn-stack">
      <div class="premium-card" style="padding: 24px;">
        <div style="display: flex; flex-direction: column; gap: 12px;">
          <!-- Active Button 1: Cài đặt hồ sơ -->
          <a href="${pageContext.request.contextPath}/profile" class="profile-nav-btn profile-nav-btn--active">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 15C13.6569 15 15 13.6569 15 12C15 10.3431 13.6569 9 12 9C10.3431 9 9 10.3431 9 12C9 13.6569 10.3431 15 12 15Z" stroke="currentColor" stroke-width="2"/>
              <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" stroke="currentColor" stroke-width="2"/>
            </svg>
            Cài đặt hồ sơ
          </a>
          
          <!-- Inactive Button 2: Đổi mật khẩu -->
          <a href="${pageContext.request.contextPath}/change-password" class="profile-nav-btn profile-nav-btn--inactive">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M21 2l-2 2m-7.61 7.61a5.5 5.5 0 1 1-7.778 7.778 5.5 5.5 0 0 1 7.777-7.777zm0 0L15.5 7.5m0 0l3 3M15.5 7.5L19 4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            Đổi mật khẩu
          </a>
          

        </div>
      </div>
      
      <!-- Session Card -->
      <div class="session-card">
        <h3>Phiên đăng nhập</h3>
        <p>Đăng nhập gần nhất: 12:35, 23/10/2023</p>
        <p>Địa chỉ IP: 192.168.1.100</p>
      </div>
    </div>
  </div>
</div>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
