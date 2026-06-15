<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Bảng điều khiển" scope="request"/>
<c:set var="activePage" value="home" scope="request"/>
<jsp:include page="includes/dashboard-layout-start.jsp"/>

<style>
  /* Local overrides to bypass aggressive browser caching of home.css */
  .hero-panel {
    display: flex !important;
    justify-content: space-between !important;
    align-items: center !important;
    min-height: 240px !important;
    border-radius: 24px !important;
    background: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #0369a1 100%) !important;
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1) !important;
    padding: 0 !important;
    border: 1px solid rgba(255, 255, 255, 0.05) !important;
    position: relative !important;
    overflow: hidden !important;
    margin-bottom: 32px !important;
  }
  .hero-panel__content {
    display: flex !important;
    flex-direction: column !important;
    justify-content: center !important;
    max-width: 680px !important;
    padding: 40px 48px !important;
    min-height: auto !important;
    position: relative !important;
    z-index: 2 !important;
    color: #ffffff !important;
  }
  .hero-panel__greeting {
    font-size: 13.5px !important;
    text-transform: uppercase !important;
    letter-spacing: 2px !important;
    color: #38bdf8 !important;
    font-weight: 700 !important;
    margin-bottom: 8px !important;
    display: inline-block !important;
  }
  .hero-panel h1 {
    font-size: 34px !important;
    font-weight: 800 !important;
    color: #ffffff !important;
    line-height: 1.2 !important;
    letter-spacing: -0.5px !important;
    margin: 0 !important;
  }
  .hero-panel p {
    margin: 12px 0 20px !important;
    color: #cbd5e1 !important;
    font-size: 15px !important;
    line-height: 1.5 !important;
  }
  .hero-panel__meta {
    display: flex !important;
    align-items: center !important;
    gap: 16px !important;
    font-size: 13.5px !important;
    color: #64748b !important;
    flex-wrap: wrap !important;
  }
  .hero-panel__date {
    background: rgba(255, 255, 255, 0.06) !important;
    border: 1px solid rgba(255, 255, 255, 0.1) !important;
    padding: 6px 12px !important;
    border-radius: 8px !important;
    color: #e2e8f0 !important;
    display: inline-flex !important;
    align-items: center !important;
  }
  .hero-panel__divider {
    color: #334155 !important;
  }
  .hero-panel__status {
    display: inline-flex !important;
    align-items: center !important;
    gap: 8px !important;
    color: #cbd5e1 !important;
  }
  .hero-panel__status-dot {
    width: 8px !important;
    height: 8px !important;
    background: #10b981 !important;
    border-radius: 50% !important;
    box-shadow: 0 0 8px #10b981 !important;
    display: inline-block !important;
    animation: pulseStatus 2s infinite !important;
  }
  .hero-panel__illustration {
    padding-right: 48px !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    z-index: 2 !important;
  }
  @media (max-width: 992px) {
    .hero-panel__illustration {
      display: none !important;
    }
  }

  /* Two Column Flexbox Layout for dashboard grid to ensure perfect alignment */
  .dashboard-grid {
    display: flex !important;
    align-items: stretch !important;
    gap: 24px !important;
  }
  .dashboard-grid__left {
    flex: 1.9 !important;
    min-width: 0 !important;
    display: flex !important;
    flex-direction: column !important;
    gap: 32px !important;
  }
  .dashboard-grid__right {
    flex: 1.1 !important;
    min-width: 320px !important;
    display: flex !important;
    flex-direction: column !important;
  }
  .alert-panel-spacer {
    height: 42px !important; /* height of section heading + margin */
  }
  .alert-panel {
    flex-grow: 1 !important;
    align-self: stretch !important;
    display: flex !important;
    flex-direction: column !important;
    justify-content: space-between !important;
    padding: 20px 20px !important;
    margin-top: 0 !important;
  }
  .stock-list {
    flex-grow: 1 !important;
    display: flex !important;
    flex-direction: column !important;
    justify-content: center !important;
    gap: 12px !important;
    margin: 12px 0 !important;
  }

  @media (max-width: 992px) {
    .dashboard-grid {
      flex-direction: column !important;
    }
    .alert-panel-spacer {
      display: none !important;
    }
    .dashboard-grid__right {
      min-width: 100% !important;
    }
  }
</style>

<section class="hero-panel">
  <div class="hero-panel__content">
    <span class="hero-panel__greeting" id="heroGreeting">Chào mừng trở lại,</span>
    <h1>${currentUser.fullName != null ? currentUser.fullName : currentUser.username}</h1>
    <p>Hệ thống quản lý kho thông minh (WMS). Hôm nay bạn muốn xử lý công việc gì?</p>
    <div class="hero-panel__meta">
      <span class="hero-panel__date" id="currentDateDisplay">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 6px; vertical-align: middle;">
          <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
          <line x1="16" y1="2" x2="16" y2="6"></line>
          <line x1="8" y1="2" x2="8" y2="6"></line>
          <line x1="3" y1="10" x2="21" y2="10"></line>
        </svg>
        <span id="dateText">Đang tải ngày...</span>
      </span>
      <span class="hero-panel__divider">|</span>
      <span class="hero-panel__status">
        <span class="hero-panel__status-dot"></span>
        Hệ thống hoạt động bình thường
      </span>
    </div>
  </div>
  <div class="hero-panel__illustration">
    <svg width="160" height="160" viewBox="0 0 240 240" fill="none" xmlns="http://www.w3.org/2000/svg" style="opacity: 0.9;">
      <path d="M120 40L200 80L120 120L40 80L120 40Z" fill="url(#boxGrad1)" />
      <path d="M120 120L200 80V150L120 190V120Z" fill="url(#boxGrad2)" />
      <path d="M40 80L120 120V190L40 150V80Z" fill="url(#boxGrad3)" />
      <g style="filter: drop-shadow(0 10px 15px rgba(0,0,0,0.15));">
        <rect x="150" y="110" width="70" height="50" rx="8" fill="rgba(255, 255, 255, 0.15)" stroke="rgba(255, 255, 255, 0.3)" stroke-width="1.5" style="backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px);"/>
        <line x1="162" y1="125" x2="200" y2="125" stroke="#38bdf8" stroke-width="3" stroke-linecap="round"/>
        <line x1="162" y1="135" x2="185" y2="135" stroke="#10b981" stroke-width="3" stroke-linecap="round"/>
        <line x1="162" y1="145" x2="208" y2="145" stroke="rgba(255,255,255,0.5)" stroke-width="3" stroke-linecap="round"/>
      </g>
      <defs>
        <linearGradient id="boxGrad1" x1="120" y1="40" x2="120" y2="120" gradientUnits="userSpaceOnUse">
          <stop offset="0%" stop-color="#38bdf8" />
          <stop offset="100%" stop-color="#0284c7" />
        </linearGradient>
        <linearGradient id="boxGrad2" x1="160" y1="80" x2="160" y2="190" gradientUnits="userSpaceOnUse">
          <stop offset="0%" stop-color="#0284c7" />
          <stop offset="100%" stop-color="#0369a1" />
        </linearGradient>
        <linearGradient id="boxGrad3" x1="80" y1="80" x2="80" y2="190" gradientUnits="userSpaceOnUse">
          <stop offset="0%" stop-color="#0ea5e9" />
          <stop offset="100%" stop-color="#075985" />
        </linearGradient>
      </defs>
    </svg>
  </div>
</section>

<section class="stats-grid">
  <article class="stat-card stat-card--good">
    <div>
      <p>Tổng sản phẩm tồn kho</p>
      <strong>5,240</strong>
      <span class="trend-badge trend-badge--up">
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><polyline points="23 6 13.5 15.5 8.5 10.5 1 18"></polyline><polyline points="17 6 23 6 23 12"></polyline></svg>
        +2.5% so với tháng trước
      </span>
    </div>
    <div class="stat-card__icon">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <ellipse cx="12" cy="5" rx="9" ry="3"></ellipse>
        <path d="M3 5V19A9 3 0 0 0 21 19V5"></path>
        <path d="M3 12A9 3 0 0 0 21 12"></path>
      </svg>
    </div>
  </article>
  
  <article class="stat-card stat-card--danger">
    <div>
      <p>Sản phẩm sắp hết hàng</p>
      <strong>12</strong>
      <span class="trend-badge trend-badge--down">
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path></svg>
        Cần nhập thêm hàng ngay
      </span>
    </div>
    <div class="stat-card__icon">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
        <line x1="12" y1="9" x2="12" y2="13"></line>
        <line x1="12" y1="17" x2="12.01" y2="17"></line>
      </svg>
    </div>
  </article>

  <article class="stat-card stat-card--neutral">
    <div>
      <p>Giao dịch hôm nay</p>
      <strong>+85</strong>
      <span class="trend-badge trend-badge--neutral">
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 4px;"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
        Cập nhật: 5 phút trước
      </span>
    </div>
    <div class="stat-card__icon">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline>
      </svg>
    </div>
  </article>
</section>

<div class="dashboard-grid">
  <!-- Left Column -->
  <div class="dashboard-grid__left">
    <section class="quick-section">
      <div class="section-heading">
        <h2>Thao tác nhanh</h2>
      </div>

      <div class="quick-grid">
        <a href="${pageContext.request.contextPath}/admin/receipts" class="quick-card">
          <span>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 2v14M19 9l-7 7-7-7M2 22h20"/>
            </svg>
          </span>
          Nhập kho
        </a>
        <a href="${pageContext.request.contextPath}/admin/shipments" class="quick-card">
          <span>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 16V2M5 9l7-7 7 7M2 22h20"/>
            </svg>
          </span>
          Xuất kho
        </a>
        <a href="${pageContext.request.contextPath}/admin/inventories" class="quick-card">
          <span>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
              <polyline points="14 2 14 8 20 8"></polyline>
              <line x1="16" y1="13" x2="8" y2="13"></line>
              <line x1="16" y1="17" x2="8" y2="17"></line>
            </svg>
          </span>
          Kiểm kho
        </a>
        <a href="${pageContext.request.contextPath}/admin/products" class="quick-card">
          <span>
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M12 5v14M5 12h14"/>
            </svg>
          </span>
          Thêm sản phẩm
        </a>
      </div>
    </section>

    <section class="transactions-section">
      <div class="section-heading section-heading--split">
        <h2>Giao dịch gần đây</h2>
        <a href="${pageContext.request.contextPath}/admin/receipts" style="text-decoration: none; font-size: 13px; font-weight: 600; color: var(--primary-color);">Xem tất cả</a>
      </div>

      <div class="transaction-table">
        <div class="transaction-table__head">
          <span>Mã phiếu</span>
          <span>Loại</span>
          <span>Sản phẩm</span>
          <span>Số lượng</span>
          <span>Thời gian</span>
        </div>

        <div class="transaction-row">
          <strong>#NK-8821</strong>
          <div><span class="transaction-badge transaction-badge--in">Nhập kho</span></div>
          <span class="transaction-product" style="font-weight: 600;">iPhone 15 Pro Max</span>
          <span class="transaction-quantity" style="font-weight: 700; color: var(--text-primary);">50</span>
          <span class="transaction-time" style="color: var(--text-secondary);">10:45 AM</span>
        </div>
        <div class="transaction-row">
          <strong>#XK-4523</strong>
          <div><span class="transaction-badge transaction-badge--out">Xuất kho</span></div>
          <span class="transaction-product" style="font-weight: 600;">MacBook Pro M3</span>
          <span class="transaction-quantity" style="font-weight: 700; color: var(--text-primary);">12</span>
          <span class="transaction-time" style="color: var(--text-secondary);">09:12 AM</span>
        </div>
        <div class="transaction-row">
          <strong>#NK-8820</strong>
          <div><span class="transaction-badge transaction-badge--in">Nhập kho</span></div>
          <span class="transaction-product" style="font-weight: 600;">Samsung Galaxy S24</span>
          <span class="transaction-quantity" style="font-weight: 700; color: var(--text-primary);">30</span>
          <span class="transaction-time" style="color: var(--text-secondary);">Hôm qua</span>
        </div>
      </div>
    </section>
  </div>

  <!-- Right Column -->
  <div class="dashboard-grid__right">
    <div class="alert-panel-spacer"></div>
    <section class="alert-panel">
      <div class="alert-panel__title">
        <span>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
            <line x1="12" y1="9" x2="12" y2="13"></line>
            <line x1="12" y1="17" x2="12.01" y2="17"></line>
          </svg>
        </span>
        <h2>Cảnh báo tồn kho thấp</h2>
      </div>

      <div class="stock-list">
        <div class="stock-item">
          <div class="stock-item__header">
            <span class="stock-item__name">iPhone 15 Pro</span>
            <strong class="stock-item__ratio stock-item__ratio--critical">5 / 50 (10%)</strong>
          </div>
          <div class="progress" role="progressbar" aria-valuenow="10" aria-valuemin="0" aria-valuemax="100">
            <div class="progress__bar progress__bar--critical" style="width:10%;"></div>
          </div>
        </div>
        <div class="stock-item">
          <div class="stock-item__header">
            <span class="stock-item__name">MacBook Pro M3</span>
            <strong class="stock-item__ratio stock-item__ratio--critical">2 / 20 (10%)</strong>
          </div>
          <div class="progress" role="progressbar" aria-valuenow="10" aria-valuemin="0" aria-valuemax="100">
            <div class="progress__bar progress__bar--critical" style="width:10%;"></div>
          </div>
        </div>
        <div class="stock-item">
          <div class="stock-item__header">
            <span class="stock-item__name">iPad Air 5</span>
            <strong class="stock-item__ratio stock-item__ratio--warning">8 / 40 (20%)</strong>
          </div>
          <div class="progress" role="progressbar" aria-valuenow="20" aria-valuemin="0" aria-valuemax="100">
            <div class="progress__bar progress__bar--warning" style="width:20%;"></div>
          </div>
        </div>
      </div>

      <a href="${pageContext.request.contextPath}/admin/receipts" class="outline-danger-button" style="text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 8px;">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M12 5v14M5 12h14"/>
        </svg>
        Lập phiếu nhập hàng ngay
      </a>
    </section>
  </div>
</div>

<script>
  document.addEventListener("DOMContentLoaded", function() {
    // Dynamic greeting based on hour
    const hour = new Date().getHours();
    const greetingEl = document.getElementById("heroGreeting");
    if (greetingEl) {
      if (hour >= 5 && hour < 12) {
        greetingEl.textContent = "Chào buổi sáng,";
      } else if (hour >= 12 && hour < 18) {
        greetingEl.textContent = "Chào buổi chiều,";
      } else {
        greetingEl.textContent = "Chào buổi tối,";
      }
    }

    // Dynamic date display
    const dateTextEl = document.getElementById("dateText");
    if (dateTextEl) {
      const days = ["Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"];
      const now = new Date();
      const dayName = days[now.getDay()];
      const dayVal = now.getDate();
      const monthVal = now.getMonth() + 1;
      const day = dayVal < 10 ? '0' + dayVal : dayVal;
      const month = monthVal < 10 ? '0' + monthVal : monthVal;
      const year = now.getFullYear();
      dateTextEl.textContent = dayName + ", ngày " + day + "/" + month + "/" + year;
    }
  });
</script>

<jsp:include page="includes/dashboard-layout-end.jsp"/>
