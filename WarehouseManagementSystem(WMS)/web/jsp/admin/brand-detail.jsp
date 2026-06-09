<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Chi tiết Hãng sản xuất" scope="request"/>
<c:set var="activePage" value="brands" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 20px;">
    <a href="${pageContext.request.contextPath}/admin/brands" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
      Quay lại danh sách hãng
    </a>
  </div>

  <div class="subpage-header" style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 28px;">
    <div class="subpage-header__title">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Thông tin chi tiết Hãng</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Xem thông tin hồ sơ và lịch sử khởi tạo nhãn hiệu.</p>
    </div>
    <div>
      <c:if test="${currentUser.hasPermission('BRAND_WRITE')}">
        <a href="${pageContext.request.contextPath}/admin/brands?action=edit&id=${brand.id}" class="premium-btn-primary" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; font-size: 14px; font-weight: 600; padding: 10px 20px; border-radius: 10px; background: var(--primary-color); color: #ffffff; transition: opacity 0.2s;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
            <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
          </svg>
          Chỉnh sửa hãng
        </a>
      </c:if>
    </div>
  </div>

  <div class="profile-layout-grid" style="display: grid; grid-template-columns: 1fr 2fr; gap: 28px; align-items: start;">
    <!-- Left Column: Summary Card -->
    <div class="premium-card" style="padding: 32px; background: #ffffff; border: 1.5px solid var(--card-border); border-radius: 16px;">
      <div style="display: flex; flex-direction: column; align-items: center; text-align: center; margin-bottom: 24px; padding-bottom: 24px; border-bottom: 1.5px solid var(--card-border);">
        <div style="width: 80px; height: 80px; font-size: 32px; border-radius: 20px; font-weight: 800; display: flex; align-items: center; justify-content: center; background: var(--sidebar-active-bg); color: var(--primary-color); margin-bottom: 16px; text-transform: uppercase;">
          ${brand.name.substring(0, 1)}
        </div>
        <h3 style="margin: 0 0 6px 0; font-size: 20px; font-weight: 700; color: var(--text-primary);"><c:out value="${brand.name}"/></h3>
        <span class="premium-tag premium-tag--manager" style="font-weight: 700; font-family: monospace; font-size: 13px; padding: 4px 10px; border-radius: 6px;"><c:out value="${brand.code}"/></span>
      </div>

      <div style="display: flex; flex-direction: column; gap: 16px;">
        <div>
          <span style="font-size: 12px; color: var(--text-secondary); text-transform: uppercase; font-weight: 700; display: block; margin-bottom: 4px;">ID Hệ thống</span>
          <span style="font-size: 15px; font-weight: 600; color: var(--text-primary);">#${brand.id}</span>
        </div>
      </div>
    </div>

    <!-- Right Column: Detail Information -->
    <div class="premium-card" style="padding: 32px; background: #ffffff; border: 1.5px solid var(--card-border); border-radius: 16px;">
      <h3 style="margin: 0 0 24px 0; font-size: 18px; font-weight: 700; color: var(--text-primary); display: flex; align-items: center; gap: 10px; padding-bottom: 16px; border-bottom: 1.5px solid var(--card-border);">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
          <line x1="16" y1="2" x2="16" y2="6"></line>
          <line x1="8" y1="2" x2="8" y2="6"></line>
          <line x1="3" y1="10" x2="21" y2="10"></line>
        </svg>
        Thông tin mở rộng
      </h3>

      <div style="display: flex; flex-direction: column; gap: 20px;">
        <div>
          <span style="font-size: 13px; color: var(--text-secondary); font-weight: 700; display: block; margin-bottom: 6px; text-transform: uppercase;">Mã Hãng sản xuất</span>
          <span class="premium-tag premium-tag--manager" style="font-size: 14px; font-weight: 700; padding: 6px 12px; border-radius: 6px; font-family: monospace;">${brand.code}</span>
        </div>

        <div>
          <span style="font-size: 13px; color: var(--text-secondary); font-weight: 700; display: block; margin-bottom: 6px; text-transform: uppercase;">Tên Hãng sản xuất</span>
          <span style="font-size: 16px; font-weight: 700; color: var(--text-primary);"><c:out value="${brand.name}"/></span>
        </div>

        <div>
          <span style="font-size: 13px; color: var(--text-secondary); font-weight: 700; display: block; margin-bottom: 6px; text-transform: uppercase;">Mô tả chi tiết</span>
          <p style="margin: 0; font-size: 15px; color: var(--text-primary); line-height: 1.6; background: #f8fafc; padding: 16px; border-radius: 12px; border: 1.5px solid var(--card-border);">
            <c:choose>
              <c:when test="${not empty brand.description}">
                <c:out value="${brand.description}"/>
              </c:when>
              <c:otherwise>
                <span style="color: var(--text-secondary); font-style: italic;">Không có thông tin mô tả cho hãng sản xuất này.</span>
              </c:otherwise>
            </c:choose>
          </p>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-top: 10px; padding-top: 20px; border-top: 1.5px solid var(--card-border);">
          <div>
            <span style="font-size: 12px; color: var(--text-secondary); font-weight: 700; display: block; margin-bottom: 4px; text-transform: uppercase;">Ngày tạo</span>
            <span style="font-size: 14px; font-weight: 600; color: var(--text-primary);">
              <fmt:formatDate value="${brand.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
            </span>
          </div>
          <div>
            <span style="font-size: 12px; color: var(--text-secondary); font-weight: 700; display: block; margin-bottom: 4px; text-transform: uppercase;">Cập nhật lần cuối</span>
            <span style="font-size: 14px; font-weight: 600; color: var(--text-primary);">
              <fmt:formatDate value="${brand.updatedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
