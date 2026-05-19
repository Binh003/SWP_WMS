<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quản lý tài khoản" scope="request"/>
<c:set var="activePage" value="users" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header">
    <div class="subpage-header__title">
      <h2>Quản lý tài khoản</h2>
      <p>Phê duyệt tài khoản và cập nhật phân quyền.</p>
    </div>
  </div>

  <div class="premium-card" style="padding:20px;margin-bottom:24px;">
    <h3>Thêm thành viên</h3>
    <form method="post" action="${pageContext.request.contextPath}/admin/users" class="admin-form">
      <input type="hidden" name="action" value="create"/>
      <div class="form-row">
        <input name="username" placeholder="Username" required/>
        <input name="fullName" placeholder="Họ tên" required/>
        <input name="email" type="email" placeholder="Email" required/>
        <input name="password" type="password" placeholder="Mật khẩu" minlength="6" required/>
      </div>
      <div class="form-row">
        <c:forEach var="role" items="${roles}">
          <label><input type="checkbox" name="roleCodes" value="${role.code}"/> ${role.code}</label>
        </c:forEach>
      </div>
      <button type="submit" class="premium-btn-primary">Tạo tài khoản</button>
    </form>
  </div>

  <div class="premium-card" style="padding:20px;">
    <table class="premium-table" style="width:100%;border-collapse:collapse;">
      <thead>
        <tr>
          <th>ID</th><th>Username</th><th>Họ tên</th><th>Email</th><th>Vai trò</th><th>Trạng thái</th><th>Hành động</th>
        </tr>
      </thead>
      <tbody>
        <c:forEach var="u" items="${users}">
          <tr>
            <td>#${u.id}</td>
            <td><strong>${u.username}</strong></td>
            <td>${u.fullName}</td>
            <td>${u.email}</td>
            <td>
              <c:forEach var="r" items="${u.roles}" varStatus="st">${r.code}<c:if test="${!st.last}">, </c:if></c:forEach>
            </td>
            <td>${u.enabled ? 'ENABLED' : 'DISABLED'}</td>
            <td>
              <form method="post" action="${pageContext.request.contextPath}/admin/users" style="display:inline;">
                <input type="hidden" name="action" value="toggle"/>
                <input type="hidden" name="id" value="${u.id}"/>
                <input type="hidden" name="enabled" value="${!u.enabled}"/>
                <button type="submit">${u.enabled ? 'Khóa' : 'Mở'}</button>
              </form>
            </td>
          </tr>
          <tr>
            <td colspan="7">
              <form method="post" action="${pageContext.request.contextPath}/admin/users" class="inline-edit-form">
                <input type="hidden" name="action" value="update"/>
                <input type="hidden" name="id" value="${u.id}"/>
                <input name="fullName" value="${u.fullName}" required/>
                <input name="email" value="${u.email}" required/>
                <label><input type="checkbox" name="enabled" value="true" ${u.enabled ? 'checked' : ''}/> Enabled</label>
                <c:forEach var="role" items="${roles}">
                  <label>
                    <input type="checkbox" name="roleCodes" value="${role.code}"
                      <c:forEach var="ur" items="${u.roles}"><c:if test="${ur.code == role.code}">checked</c:if></c:forEach>
                    /> ${role.code}
                  </label>
                </c:forEach>
                <button type="submit">Lưu</button>
              </form>
            </td>
          </tr>
        </c:forEach>
      </tbody>
    </table>
  </div>
</div>

<style>
  .form-row { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:12px; }
  .form-row input { padding:8px 10px; border:1px solid #e2e8f0; border-radius:8px; }
  .admin-form label { margin-right:12px; font-size:13px; }
  .premium-table th, .premium-table td { padding:10px; border-bottom:1px solid #e2e8f0; text-align:left; }
  .inline-edit-form { display:flex; flex-wrap:wrap; gap:8px; align-items:center; padding:8px 0; }
</style>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
