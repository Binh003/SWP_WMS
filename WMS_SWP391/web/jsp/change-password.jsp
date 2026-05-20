<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Đổi mật khẩu" scope="request"/>
<c:set var="activePage" value="password" scope="request"/>
<jsp:include page="includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="premium-card" style="padding:24px;max-width:480px;">
    <h2>Đổi mật khẩu</h2>
    <form method="post" action="${pageContext.request.contextPath}/change-password">
      <label>Mật khẩu hiện tại</label>
      <input type="password" name="currentPassword" required style="width:100%;margin:8px 0 16px;padding:10px;"/>
      <label>Mật khẩu mới</label>
      <input type="password" name="newPassword" minlength="6" required style="width:100%;margin:8px 0 16px;padding:10px;"/>
      <button type="submit" class="premium-btn-primary">Cập nhật</button>
    </form>
  </div>
</div>

<jsp:include page="includes/dashboard-layout-end.jsp"/>
