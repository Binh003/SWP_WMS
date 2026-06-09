<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:if test="${not empty flashSuccess}">
  <div class="flash flash--success">${flashSuccess}</div>
</c:if>
<c:if test="${not empty flashError}">
  <div class="flash flash--error">${flashError}</div>
</c:if>

<c:if test="${not empty flashSuccess or not empty flashError}">
  <script>
    (function() {
      function initFlashTimeout() {
        const flashes = document.querySelectorAll(".flash");
        flashes.forEach(function(flash) {
          setTimeout(function() {
            flash.style.transition = "all 0.5s ease-in-out";
            flash.style.opacity = "0";
            flash.style.transform = "translateY(-10px)";
            setTimeout(function() {
              flash.style.display = "none";
            }, 500);
          }, 5000);
        });
      }
      if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", initFlashTimeout);
      } else {
        initFlashTimeout();
      }
    })();
  </script>
</c:if>
