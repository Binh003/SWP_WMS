<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:if test="${not empty flashSuccess}">
  <div class="flash flash--success">${flashSuccess}</div>
</c:if>
<c:if test="${not empty flashError}">
  <div class="flash flash--error">${flashError}</div>
</c:if>

<c:if test="${not empty flashModalError}">
  <div id="flashModalErrorOverlay" style="position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(15, 23, 42, 0.55); backdrop-filter: blur(4px); display: flex; align-items: center; justify-content: center; z-index: 99999; animation: fadeInModal 0.2s ease-out;">
    <div style="background: #ffffff; width: 90%; max-width: 480px; border-radius: 16px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04); overflow: hidden; transform: scale(1); animation: popInModal 0.25s cubic-bezier(0.16, 1, 0.3, 1);">
      <div style="padding: 28px 24px 20px; text-align: center;">
        <div style="width: 56px; height: 56px; border-radius: 50%; background: #fef2f2; color: #ef4444; display: inline-flex; align-items: center; justify-content: center; margin: 0 auto 16px;">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
            <line x1="12" y1="9" x2="12" y2="13"></line>
            <line x1="12" y1="17" x2="12.01" y2="17"></line>
          </svg>
        </div>
        <h3 style="margin: 0 0 10px 0; font-size: 19px; font-weight: 700; color: #0f172a;">Không thể thực hiện xóa</h3>
        <div style="font-size: 14px; color: #475569; line-height: 1.6; background: #f8fafc; padding: 14px 16px; border-radius: 10px; border: 1px solid #e2e8f0; text-align: left;">
          ${flashModalError}
        </div>
      </div>
      <div style="padding: 14px 24px; background: #f8fafc; border-top: 1px solid #e2e8f0; text-align: right;">
        <button type="button" onclick="closeFlashModalError()" style="padding: 10px 24px; font-size: 14px; font-weight: 600; border-radius: 8px; border: none; background: #048abf; color: #ffffff; cursor: pointer; transition: all 0.2s; box-shadow: 0 2px 4px rgba(4, 138, 191, 0.2);"
                onmouseover="this.style.background='#0369a1';"
                onmouseout="this.style.background='#048abf';">
          Đã hiểu
        </button>
      </div>
    </div>
  </div>
  <style>
    @keyframes fadeInModal { from { opacity: 0; } to { opacity: 1; } }
    @keyframes popInModal { from { opacity: 0; transform: scale(0.92); } to { opacity: 1; transform: scale(1); } }
  </style>
  <script>
    function closeFlashModalError() {
      const modal = document.getElementById('flashModalErrorOverlay');
      if (modal) {
        modal.style.opacity = '0';
        modal.style.transition = 'opacity 0.2s ease';
        setTimeout(function() { modal.remove(); }, 200);
      }
    }
  </script>
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

<!-- Global Reusable Confirm Delete Modal -->
<div id="globalConfirmDeleteModalOverlay" style="display: none; position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; background: rgba(15, 23, 42, 0.55); backdrop-filter: blur(4px); align-items: center; justify-content: center; z-index: 99998; animation: fadeInModal 0.2s ease-out;">
  <div style="background: #ffffff; width: 90%; max-width: 450px; border-radius: 16px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04); overflow: hidden; animation: popInModal 0.25s cubic-bezier(0.16, 1, 0.3, 1);">
    <div style="padding: 28px 24px 20px; text-align: center;">
      <div style="width: 56px; height: 56px; border-radius: 50%; background: #fef2f2; color: #ef4444; display: inline-flex; align-items: center; justify-content: center; margin: 0 auto 16px;">
        <svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="3 6 5 6 21 6"></polyline>
          <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
          <line x1="10" y1="11" x2="10" y2="17"></line>
          <line x1="14" y1="11" x2="14" y2="17"></line>
        </svg>
      </div>
      <h3 id="confirmDeleteModalTitle" style="margin: 0 0 10px 0; font-size: 19px; font-weight: 700; color: #0f172a;">Xác nhận xóa</h3>
      <div id="confirmDeleteModalMessage" style="font-size: 14px; color: #475569; line-height: 1.6; background: #f8fafc; padding: 14px 16px; border-radius: 10px; border: 1px solid #e2e8f0; text-align: center;">
        Bạn có chắc chắn muốn xóa mục này?
      </div>
    </div>
    <div style="padding: 14px 24px; background: #f8fafc; border-top: 1px solid #e2e8f0; display: flex; gap: 12px; justify-content: flex-end;">
      <button type="button" onclick="closeConfirmDeleteModal()" style="padding: 10px 20px; font-size: 14px; font-weight: 600; border-radius: 8px; border: 1.5px solid #cbd5e1; background: #ffffff; color: #475569; cursor: pointer; transition: all 0.2s;"
              onmouseover="this.style.background='#f1f5f9';"
              onmouseout="this.style.background='#ffffff';">
        Hủy bỏ
      </button>
      <button type="button" id="confirmDeleteSubmitBtn" style="padding: 10px 20px; font-size: 14px; font-weight: 600; border-radius: 8px; border: none; background: #ef4444; color: #ffffff; cursor: pointer; transition: all 0.2s; box-shadow: 0 2px 4px rgba(239, 68, 68, 0.2);"
              onmouseover="this.style.background='#dc2626';"
              onmouseout="this.style.background='#ef4444';">
        Xác nhận xóa
      </button>
    </div>
  </div>
</div>

<script>
  let pendingDeleteTargetForm = null;

  function showDeleteModal(options) {
    const modal = document.getElementById('globalConfirmDeleteModalOverlay');
    const titleEl = document.getElementById('confirmDeleteModalTitle');
    const msgEl = document.getElementById('confirmDeleteModalMessage');
    const submitBtn = document.getElementById('confirmDeleteSubmitBtn');

    if (!modal) return;

    pendingDeleteTargetForm = options.form || null;
    if (options.title) titleEl.textContent = options.title;
    if (options.message) msgEl.innerHTML = options.message;

    submitBtn.onclick = function() {
      if (pendingDeleteTargetForm) {
        pendingDeleteTargetForm.submit();
      }
      closeConfirmDeleteModal();
    };

    modal.style.display = 'flex';
  }

  function closeConfirmDeleteModal() {
    const modal = document.getElementById('globalConfirmDeleteModalOverlay');
    if (modal) {
      modal.style.display = 'none';
    }
    pendingDeleteTargetForm = null;
  }
</script>
