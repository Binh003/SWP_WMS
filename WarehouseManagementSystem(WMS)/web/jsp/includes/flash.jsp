<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:if test="${not empty flashSuccess}">
  <div class="flash flash--success">${flashSuccess}</div>
</c:if>
<c:if test="${not empty flashError}">
  <div class="flash flash--error">${flashError}</div>
</c:if>
