<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Quản lý vai trò" scope="request"/>
<c:set var="activePage" value="roles" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header">
    <div class="subpage-header__title">
      <h2>Quản lý vai trò & quyền</h2>
      <p>Gán permission cho từng role.</p>
    </div>
  </div>

  <div class="premium-card" style="padding:20px;">
    <form method="get" action="${pageContext.request.contextPath}/admin/roles" style="margin-bottom:16px;">
      <label>Chọn vai trò:</label>
      <select name="id" onchange="this.form.submit()">
        <c:forEach var="r" items="${roles}">
          <option value="${r.id}" ${r.id == selectedRoleId ? 'selected' : ''}>${r.code}</option>
        </c:forEach>
      </select>
    </form>

    <c:if test="${selectedRole != null}">
      <form method="post" action="${pageContext.request.contextPath}/admin/roles">
        <input type="hidden" name="id" value="${selectedRole.id}"/>
        <div class="form-row">
          <label>Tên</label>
          <input name="name" value="${selectedRole.name}" required/>
        </div>
        <div class="form-row">
          <label>Mô tả</label>
          <input name="description" value="${selectedRole.description}"/>
        </div>
        <div class="form-row">
          <label><input type="checkbox" name="enabled" value="true" ${selectedRole.enabled ? 'checked' : ''}/> Kích hoạt</label>
        </div>
        <h4>Permissions</h4>
        <div class="perm-grid">
          <c:forEach var="p" items="${permissions}">
            <label>
              <input type="checkbox" name="permissionCodes" value="${p[1]}"
                <c:forEach var="pc" items="${selectedRole.permissionCodes}">
                  <c:if test="${pc == p[1]}">checked</c:if>
                </c:forEach>
              /> ${p[1]} - ${p[2]}
            </label>
          </c:forEach>
        </div>
        <button type="submit" class="premium-btn-primary">Lưu vai trò</button>
      </form>
    </c:if>
  </div>
</div>

<style>
  .form-row { margin-bottom:12px; }
  .form-row input { width:100%; max-width:420px; padding:8px; border:1px solid #e2e8f0; border-radius:8px; }
  .perm-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:8px; margin:12px 0 20px; }
</style>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
