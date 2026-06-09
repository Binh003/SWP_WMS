<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Chi tiết Nhà cung cấp" scope="request"/>
<c:set var="activePage" value="suppliers" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 20px;">
    <a href="${pageContext.request.contextPath}/admin/suppliers" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
      Quay lại danh sách nhà cung cấp
    </a>
  </div>

  <div class="subpage-header" style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 28px;">
    <div class="subpage-header__title">
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0;">Thông tin chi tiết Nhà cung cấp</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Xem thông tin liên lạc và chi tiết hồ sơ nhà cung cấp.</p>
    </div>
    <div>
      <c:if test="${currentUser.hasPermission('SUPPLIER_WRITE')}">
        <a href="${pageContext.request.contextPath}/admin/suppliers?action=edit&id=${supplier.id}" class="premium-btn-primary" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; font-size: 14px; font-weight: 600; padding: 10px 20px; border-radius: 10px; background: var(--primary-color); color: #ffffff; transition: opacity 0.2s;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
            <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
          </svg>
          Chỉnh sửa nhà cung cấp
        </a>
      </c:if>
    </div>
  </div>

  <div class="profile-layout-grid" style="display: grid; grid-template-columns: 1fr 2fr; gap: 28px; align-items: start;">
    <!-- Left Column: Summary Card -->
    <div class="premium-card" style="padding: 32px; background: #ffffff; border: 1.5px solid var(--card-border); border-radius: 16px;">
      <div style="display: flex; flex-direction: column; align-items: center; text-align: center; margin-bottom: 24px; padding-bottom: 24px; border-bottom: 1.5px solid var(--card-border);">
        <div style="width: 80px; height: 80px; font-size: 32px; border-radius: 20px; font-weight: 800; display: flex; align-items: center; justify-content: center; background: var(--sidebar-active-bg); color: var(--primary-color); margin-bottom: 16px; text-transform: uppercase;">
          ${supplier.name.substring(0, 1)}
        </div>
        <h3 style="margin: 0 0 6px 0; font-size: 20px; font-weight: 700; color: var(--text-primary);"><c:out value="${supplier.name}"/></h3>
        <span class="premium-tag premium-tag--manager" style="font-weight: 700; font-family: monospace; font-size: 13px; padding: 4px 10px; border-radius: 6px;"><c:out value="${supplier.code}"/></span>
      </div>

      <div style="display: flex; flex-direction: column; gap: 16px;">
        <div>
          <span style="font-size: 12px; color: var(--text-secondary); text-transform: uppercase; font-weight: 700; display: block; margin-bottom: 4px;">ID Hệ thống</span>
          <span style="font-size: 15px; font-weight: 600; color: var(--text-primary);">#${supplier.id}</span>
        </div>
      </div>
    </div>

    <!-- Right Column: Detail Information -->
    <div class="premium-card" style="padding: 32px; background: #ffffff; border: 1.5px solid var(--card-border); border-radius: 16px;">
      <h3 style="margin: 0 0 24px 0; font-size: 18px; font-weight: 700; color: var(--text-primary); display: flex; align-items: center; gap: 10px; padding-bottom: 16px; border-bottom: 1.5px solid var(--card-border);">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
        </svg>
        Thông tin liên hệ
      </h3>

      <div style="display: flex; flex-direction: column; gap: 20px;">
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
          <div>
            <span style="font-size: 13px; color: var(--text-secondary); font-weight: 700; display: block; margin-bottom: 6px; text-transform: uppercase;">Mã Nhà cung cấp</span>
            <span class="premium-tag premium-tag--manager" style="font-size: 14px; font-weight: 700; padding: 6px 12px; border-radius: 6px; font-family: monospace;">${supplier.code}</span>
          </div>

          <div>
            <span style="font-size: 13px; color: var(--text-secondary); font-weight: 700; display: block; margin-bottom: 6px; text-transform: uppercase;">Tên Nhà cung cấp</span>
            <span style="font-size: 16px; font-weight: 700; color: var(--text-primary);"><c:out value="${supplier.name}"/></span>
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
          <div>
            <span style="font-size: 13px; color: var(--text-secondary); font-weight: 700; display: block; margin-bottom: 6px; text-transform: uppercase;">Số điện thoại</span>
            <span style="font-size: 15px; font-weight: 600; color: var(--text-primary);">
              <c:choose>
                <c:when test="${not empty supplier.phone}">
                  <c:out value="${supplier.phone}"/>
                </c:when>
                <c:otherwise>
                  <span style="color: var(--text-secondary); font-style: italic;">Chưa cập nhật</span>
                </c:otherwise>
              </c:choose>
            </span>
          </div>

          <div>
            <span style="font-size: 13px; color: var(--text-secondary); font-weight: 700; display: block; margin-bottom: 6px; text-transform: uppercase;">Địa chỉ Email</span>
            <span style="font-size: 15px; font-weight: 600; color: var(--text-primary);">
              <c:choose>
                <c:when test="${not empty supplier.email}">
                  <c:out value="${supplier.email}"/>
                </c:when>
                <c:otherwise>
                  <span style="color: var(--text-secondary); font-style: italic;">Chưa cập nhật</span>
                </c:otherwise>
              </c:choose>
            </span>
          </div>
        </div>

        <div>
          <span style="font-size: 13px; color: var(--text-secondary); font-weight: 700; display: block; margin-bottom: 6px; text-transform: uppercase;">Địa chỉ văn phòng</span>
          <p style="margin: 0; font-size: 15px; color: var(--text-primary); line-height: 1.6; background: #f8fafc; padding: 16px; border-radius: 12px; border: 1.5px solid var(--card-border);">
            <c:choose>
              <c:when test="${not empty supplier.address}">
                <c:out value="${supplier.address}"/>
              </c:when>
              <c:otherwise>
                <span style="color: var(--text-secondary); font-style: italic;">Chương có thông tin địa chỉ nhà cung cấp.</span>
              </c:otherwise>
            </c:choose>
          </p>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; margin-top: 10px; padding-top: 20px; border-top: 1.5px solid var(--card-border);">
          <div>
            <span style="font-size: 12px; color: var(--text-secondary); font-weight: 700; display: block; margin-bottom: 4px; text-transform: uppercase;">Ngày tạo</span>
            <span style="font-size: 14px; font-weight: 600; color: var(--text-primary);">
              <fmt:formatDate value="${supplier.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
            </span>
          </div>
          <div>
            <span style="font-size: 12px; color: var(--text-secondary); font-weight: 700; display: block; margin-bottom: 4px; text-transform: uppercase;">Cập nhật lần cuối</span>
            <span style="font-size: 14px; font-weight: 600; color: var(--text-primary);">
              <fmt:formatDate value="${supplier.updatedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
