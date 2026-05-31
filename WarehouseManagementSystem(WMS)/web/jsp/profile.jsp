<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Hồ sơ" scope="request"/>
<c:set var="activePage" value="profile" scope="request"/>
<jsp:include page="includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header">
    <h2>Hồ sơ cá nhân</h2>
    <p>Thông tin tài khoản đang đăng nhập.</p>
  </div>
  <div class="premium-card" style="padding:24px;">
    <p><strong>Username:</strong> ${currentUser.username}</p>
    <p><strong>Họ tên:</strong> ${currentUser.fullName}</p>
    <p><strong>Email:</strong> ${currentUser.email}</p>
    <p><strong>Vai trò:</strong>
      <c:forEach var="r" items="${currentUser.roles}" varStatus="st">${r.code}<c:if test="${!st.last}">, </c:if></c:forEach>
    </p>
  </div>
</div>

<jsp:include page="includes/dashboard-layout-end.jsp"/>
