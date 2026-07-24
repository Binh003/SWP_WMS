<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" scope="page"/>
<c:set var="pageTitle" value="Báo cáo thống kê" scope="request"/>
<c:set var="activePage" value="reports" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<!-- Tải thư viện Chart.js qua CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
  .report-container {
    padding: 12px 0 24px;
    display: flex;
    flex-direction: column;
    gap: 24px;
  }
  
  /* Style cho các Tab báo cáo */
  .report-tabs {
    display: flex;
    gap: 8px;
    border-bottom: 2px solid #e2e8f0;
    padding-bottom: 0px;
    margin-bottom: 8px;
  }
  .report-tab-btn {
    padding: 12px 20px;
    font-size: 14px;
    font-weight: 700;
    color: #64748b;
    background: none;
    border: none;
    border-bottom: 3px solid transparent;
    cursor: pointer;
    transition: all 0.2s ease;
    display: flex;
    align-items: center;
    gap: 8px;
    text-decoration: none;
  }
  .report-tab-btn:hover {
    color: #0f172a;
  }
  .report-tab-btn.active {
    color: #3b82f6;
    border-bottom-color: #3b82f6;
  }

  /* Style cho Form bộ lọc */
  .filter-card {
    background: #ffffff;
    border-radius: 16px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.02);
    padding: 20px;
    display: flex;
    flex-wrap: wrap;
    align-items: flex-end;
    gap: 16px;
    margin-bottom: 8px;
  }
  .filter-group {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }
  .filter-group label {
    font-size: 13px;
    font-weight: 600;
    color: #475569;
  }
  .filter-input {
    padding: 8px 12px;
    border: 1px solid #cbd5e1;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    color: #1e293b;
    outline: none;
    transition: border-color 0.2s;
    background-color: #f8fafc;
  }
  .filter-input:focus {
    border-color: #3b82f6;
    background-color: #ffffff;
  }
  .filter-btn {
    padding: 9px 20px;
    background: #3b82f6;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
    display: inline-flex;
    align-items: center;
    gap: 8px;
  }
  .filter-btn:hover {
    background: #2563eb;
  }

  /* Style cho các Card thống kê nhanh */
  .quick-stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 20px;
  }
  .report-stat-card {
    background: #ffffff;
    border-radius: 16px;
    padding: 20px 24px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
    border: 1px solid #e2e8f0;
    display: flex;
    align-items: center;
    justify-content: space-between;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
  }
  .report-stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 30px rgba(0, 0, 0, 0.08);
  }
  .report-stat-card__info p {
    margin: 0 0 6px;
    font-size: 13px;
    font-weight: 600;
    color: #64748b;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }
  .report-stat-card__info strong {
    font-size: 24px;
    font-weight: 800;
    color: #0f172a;
    line-height: 1;
  }
  .report-stat-card__icon {
    width: 48px;
    height: 48px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  
  .icon-blue { background: #eff6ff; color: #3b82f6; }
  .icon-green { background: #f0fdf4; color: #22c55e; }
  .icon-purple { background: #faf5ff; color: #a855f7; }
  .icon-red { background: #fef2f2; color: #ef4444; }
  
  .alert-pulse {
    animation: alert-glow 1.5s infinite alternate;
  }
  @keyframes alert-glow {
    from { box-shadow: 0 0 4px rgba(239, 68, 68, 0.2); }
    to { box-shadow: 0 0 16px rgba(239, 68, 68, 0.4); border-color: #f87171; }
  }

  /* Style cho Grid Biểu đồ */
  .charts-main-grid {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 24px;
  }
  @media (max-width: 1024px) {
    .charts-main-grid {
      grid-template-columns: 1fr;
    }
  }
  
  .chart-card {
    background: #ffffff;
    border-radius: 16px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
    padding: 24px;
    display: flex;
    flex-direction: column;
    min-height: 380px;
  }
  .chart-card__header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    border-bottom: 1px solid #f1f5f9;
    padding-bottom: 12px;
  }
  .chart-card__header h3 {
    margin: 0;
    font-size: 16px;
    font-weight: 700;
    color: #1e293b;
    display: flex;
    align-items: center;
    gap: 8px;
  }
  .chart-card__canvas-container {
    flex-grow: 1;
    position: relative;
    width: 100%;
    height: 100%;
    min-height: 280px;
  }

  /* Tab chi tiết / Bảng số liệu */
  .details-section {
    background: #ffffff;
    border-radius: 16px;
    border: 1px solid #e2e8f0;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.04);
    padding: 24px;
  }
  .details-section__header {
    margin-bottom: 20px;
    border-bottom: 1px solid #f1f5f9;
    padding-bottom: 12px;
  }
  .details-section__header h3 {
    margin: 0;
    font-size: 16px;
    font-weight: 700;
    color: #1e293b;
  }
  .table-responsive {
    overflow-x: auto;
    margin-top: 15px;
  }
  .report-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
  }
  .report-table th {
    background: #f8fafc;
    color: #475569;
    font-weight: 600;
    text-align: left;
    padding: 12px 16px;
    border-bottom: 2px solid #e2e8f0;
  }
  .report-table td {
    padding: 12px 16px;
    border-bottom: 1px solid #f1f5f9;
    color: #334155;
    vertical-align: middle;
  }
  .report-table tr:hover {
    background: #f8fafc;
  }
  .report-badge {
    padding: 4px 8px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 600;
    display: inline-block;
  }
  .report-badge--danger {
    background: #fef2f2;
    color: #ef4444;
  }

  /* Style cho Bản in */
  @media print {
    .report-tabs, .filter-card, button, .outline-danger-button {
      display: none !important;
    }
    .report-container {
      padding: 0;
    }
    .report-stat-card {
      border: 1px solid #cbd5e1 !important;
      box-shadow: none !important;
    }
    .chart-card, .details-section {
      border: 1px solid #cbd5e1 !important;
      box-shadow: none !important;
      page-break-inside: avoid;
    }
  }

  /* Pagination Buttons styling */
  .pagination-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-width: 36px;
    height: 36px;
    padding: 0 8px;
    font-size: 14px;
    font-weight: 600;
    border: 1.5px solid var(--card-border);
    background: #ffffff;
    color: var(--text-secondary);
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s;
  }
  .pagination-btn:hover:not(:disabled) {
    border-color: var(--primary-color);
    color: var(--primary-color);
    background: rgba(4, 138, 191, 0.02);
  }
  .pagination-btn--active {
    background: var(--primary-color) !important;
    color: #ffffff !important;
    border-color: var(--primary-color) !important;
  }
  .pagination-btn:disabled {
    opacity: 0.5;
    cursor: not-allowed;
    background: #f8fafc;
  }
</style>

<div class="report-container">
  
  <!-- Header của module -->
  <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px; margin-bottom: 8px;">
    <div>
      <h1 style="font-size: 24px; font-weight: 800; color: #0f172a; margin: 0;">Báo cáo phân tích kho hàng</h1>
      <p style="color: #64748b; margin: 4px 0 0; font-size: 14px;">Thống kê chi tiết xuất kho, nhập kho và dữ liệu tồn kho thực tế.</p>
    </div>
    <div style="display: flex; gap: 8px; align-items: center;">
      <button onclick="window.print()" class="outline-danger-button" style="margin: 0; text-decoration: none; border: 1px solid #cbd5e1; color: #475569; background: white; display: inline-flex; align-items: center; justify-content: center; gap: 6px; padding: 0 16px; height: 42px; border-radius: 10px; font-weight: 600; cursor: pointer; white-space: nowrap; box-sizing: border-box;">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="6 9 6 2 18 2 18 9"></polyline>
          <path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path>
          <rect x="6" y="14" width="12" height="8"></rect>
        </svg>
        In báo cáo
      </button>
      <c:if test="${reportType != 'overview'}">
        <a href="?action=export&reportType=${reportType}&startDate=${startDate}&endDate=${endDate}&sku=${param.sku}&brandId=${param.brandId}&productLineId=${param.productLineId}" class="filter-btn" style="margin: 0; text-decoration: none; border: 1px solid transparent; display: inline-flex; align-items: center; justify-content: center; gap: 6px; padding: 0 16px; height: 42px; border-radius: 10px; font-weight: 600; background: #10b981; color: white; white-space: nowrap; box-sizing: border-box;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
            <polyline points="14 2 14 8 20 8"></polyline>
            <line x1="16" y1="13" x2="8" y2="13"></line>
            <line x1="16" y1="17" x2="8" y2="17"></line>
          </svg>
          Xuất Excel
        </a>
      </c:if>
    </div>
  </div>

  <!-- Navigation Tabs -->
  <div class="report-tabs">
    <a href="?reportType=overview" class="report-tab-btn ${reportType == 'overview' ? 'active' : ''}">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9"></rect><rect x="14" y="3" width="7" height="5"></rect><rect x="14" y="12" width="7" height="9"></rect><rect x="3" y="16" width="7" height="5"></rect></svg>
      Tổng quan
    </a>
    <a href="?reportType=inbound" class="report-tab-btn ${reportType == 'inbound' ? 'active' : ''}">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v14M19 9l-7 7-7-7M2 22h20"/></svg>
      Nhập kho (Inbound)
    </a>
    <a href="?reportType=outbound" class="report-tab-btn ${reportType == 'outbound' ? 'active' : ''}">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 16V2M5 9l7-7 7 7M2 22h20"/></svg>
      Xuất kho (Outbound)
    </a>
    <a href="?reportType=inventory" class="report-tab-btn ${reportType == 'inventory' ? 'active' : ''}">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="5" rx="9" ry="3"></ellipse><path d="M3 5V19A9 3 0 0 0 21 19V5"></path><path d="M3 12A9 3 0 0 0 21 12"></path></svg>
      Tồn kho (Inventory)
    </a>
    <a href="?reportType=nxt" class="report-tab-btn ${reportType == 'nxt' ? 'active' : ''}">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M16 3h5v5M4 20L21 3M21 20h-5v-5M3 3l18 17"/></svg>
      Nhập Xuất Tồn
    </a>
  </div>

  <!-- Form Bộ lọc Ngày tháng cho Nhập kho & Xuất kho & Nhập Xuất Tồn -->
  <c:if test="${reportType == 'inbound' || reportType == 'outbound' || reportType == 'nxt'}">
    <form method="GET" action="" class="filter-card" style="display: flex; flex-wrap: wrap; gap: 16px; align-items: flex-end;">
      <input type="hidden" name="reportType" value="${reportType}" />
      <div class="filter-group" style="flex: 1; min-width: 140px;">
        <label>Từ ngày</label>
        <input type="date" name="startDate" class="filter-input" value="${startDate}" style="width: 100%;" required />
      </div>
      <div class="filter-group" style="flex: 1; min-width: 140px;">
        <label>Đến ngày</label>
        <input type="date" name="endDate" class="filter-input" value="${endDate}" style="width: 100%;" required />
      </div>
      
      <c:if test="${reportType == 'nxt'}">
        <div class="filter-group" style="flex: 1.5; min-width: 180px;">
          <label>Tìm theo SKU/Tên sản phẩm</label>
          <input type="text" name="sku" class="filter-input" value="${param.sku}" placeholder="Nhập SKU hoặc Tên..." style="width: 100%;" />
        </div>
        <div class="filter-group" style="flex: 1.2; min-width: 150px;">
          <label>Hãng sản xuất</label>
          <select name="brandId" class="filter-input" style="width: 100%; background: #f8fafc; cursor: pointer;">
            <option value="">Tất cả các Hãng</option>
            <c:forEach var="b" items="${brands}">
              <option value="${b.id}" ${param.brandId == b.id ? 'selected' : ''}>${b.name}</option>
            </c:forEach>
          </select>
        </div>
        <div class="filter-group" style="flex: 1.2; min-width: 150px;">
          <label>Dòng sản phẩm</label>
          <select name="productLineId" class="filter-input" style="width: 100%; background: #f8fafc; cursor: pointer;">
            <option value="">Tất cả các Dòng SP</option>
            <c:forEach var="pl" items="${productLines}">
              <option value="${pl.id}" ${param.productLineId == pl.id ? 'selected' : ''}>${pl.name}</option>
            </c:forEach>
          </select>
        </div>
      </c:if>
      
      <div style="display: flex; gap: 8px;">
        <button type="submit" class="filter-btn">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
          Lọc dữ liệu
        </button>
        <c:if test="${reportType == 'nxt' && (not empty param.sku || not empty param.brandId || not empty param.productLineId)}">
          <a href="?reportType=nxt&startDate=${startDate}&endDate=${endDate}" class="filter-btn" style="background: #ef4444; text-decoration: none; display: inline-flex; align-items: center; justify-content: center;">Xóa lọc phụ</a>
        </c:if>
      </div>
    </form>
  </c:if>

  <!-- NỘI DUNG TỪNG TAB -->
  <c:choose>
    
    <%-- ==================== TAB 1: TỔNG QUAN (OVERVIEW) ==================== --%>
    <c:when test="${reportType == 'overview'}">
      <!-- Thẻ thống kê tổng quan -->
      <div class="quick-stats-grid">
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Danh mục sản phẩm</p>
            <strong>${overview.totalProducts}</strong>
          </div>
          <div class="report-stat-card__icon icon-blue">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
              <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
              <line x1="12" y1="22.08" x2="12" y2="12"></line>
            </svg>
          </div>
        </div>
        
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng lượng hàng tồn</p>
            <strong>${overview.totalInventoryItems}</strong>
          </div>
          <div class="report-stat-card__icon icon-green">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <ellipse cx="12" cy="5" rx="9" ry="3"></ellipse>
              <path d="M3 5V19A9 3 0 0 0 21 19V5"></path>
              <path d="M3 12A9 3 0 0 0 21 12"></path>
            </svg>
          </div>
        </div>
        
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng giá trị kho</p>
            <strong id="valuationText" data-raw="${overview.totalInventoryValue}">0 đ</strong>
          </div>
          <div class="report-stat-card__icon icon-purple">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="12" y1="1" x2="12" y2="23"></line>
              <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
            </svg>
          </div>
        </div>
        
        <div class="report-stat-card ${overview.lowStockCount > 0 ? 'alert-pulse' : ''}" style="${overview.lowStockCount > 0 ? 'border-color: #fee2e2;' : ''}">
          <div class="report-stat-card__info">
            <p>Tồn kho dưới hạn mức</p>
            <strong style="${overview.lowStockCount > 0 ? 'color: #ef4444;' : ''}">${overview.lowStockCount}</strong>
          </div>
          <div class="report-stat-card__icon icon-red">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
              <line x1="12" y1="9" x2="12" y2="13"></line>
              <line x1="12" y1="17" x2="12.01" y2="17"></line>
            </svg>
          </div>
        </div>
      </div>

      <!-- Grid Biểu đồ chính -->
      <div class="charts-main-grid">
        <div class="chart-card">
          <div class="chart-card__header">
            <h3>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="color: #3b82f6;">
                <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline>
              </svg>
              Giá trị Giao dịch Nhập - Xuất kho trong năm (VND)
            </h3>
          </div>
          <div class="chart-card__canvas-container">
            <canvas id="monthlyInboundOutboundChart"></canvas>
          </div>
        </div>

        <div class="chart-card">
          <div class="chart-card__header">
            <h3>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="color: #a855f7;">
                <path d="M21.21 15.89A10 10 0 1 1 8 2.83"></path>
                <path d="M22 12A10 10 0 0 0 12 2v10z"></path>
              </svg>
              Cơ cấu Tồn kho theo Hãng
            </h3>
          </div>
          <div class="chart-card__canvas-container" style="display: flex; align-items: center; justify-content: center;">
            <canvas id="brandValuationChart" style="max-height: 270px; max-width: 270px;"></canvas>
          </div>
        </div>
      </div>

      <!-- Biểu đồ phụ & bảng dữ liệu -->
      <div class="charts-main-grid" style="grid-template-columns: 1fr 1.2fr;">
        <div class="chart-card">
          <div class="chart-card__header">
            <h3>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="color: #f97316;">
                <line x1="18" y1="20" x2="18" y2="10"></line>
                <line x1="12" y1="20" x2="12" y2="4"></line>
                <line x1="6" y1="20" x2="6" y2="14"></line>
              </svg>
              Top 5 sản phẩm xuất kho nhiều nhất
            </h3>
          </div>
          <div class="chart-card__canvas-container">
            <canvas id="topMovingProductsChart"></canvas>
          </div>
        </div>

        <div class="details-section">
          <div class="details-section__header">
            <h3>Bảng phân bổ giá trị tồn kho theo Hãng</h3>
          </div>
          <div class="table-responsive">
            <table class="report-table">
              <thead>
                <tr>
                  <th>Tên Hãng</th>
                  <th style="text-align: right;">Giá trị tồn kho</th>
                  <th style="text-align: right;">Tỷ lệ (%)</th>
                </tr>
              </thead>
              <tbody id="brandTableBody">
                <!-- Render động bằng JS -->
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </c:when>

    <%-- ==================== TAB 2: NHẬP KHO (INBOUND) ==================== --%>
    <c:when test="${reportType == 'inbound'}">
      <!-- Thẻ thống kê nhanh cho Nhập kho -->
      <div class="quick-stats-grid">
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng số phiếu nhập</p>
            <strong><c:out value="${totalInboundReceipts}"/></strong>
          </div>
          <div class="report-stat-card__icon icon-blue">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path></svg>
          </div>
        </div>
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng lượng hàng nhập</p>
            <strong><fmt:formatNumber value="${totalInboundQty}" pattern="#,##0"/></strong>
          </div>
          <div class="report-stat-card__icon icon-green">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
          </div>
        </div>
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng giá trị nhập</p>
            <strong><fmt:formatNumber value="${totalInboundVal}" type="currency" currencyCode="VND"/></strong>
          </div>
          <div class="report-stat-card__icon icon-purple">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
          </div>
        </div>
      </div>

      <!-- Bảng báo cáo Nhập kho chi tiết -->
      <div class="details-section">
        <div class="details-section__header">
          <h3>Báo cáo chi tiết lịch sử Nhập kho <c:if test="${not empty startDate}">từ ${startDate}</c:if> <c:if test="${not empty endDate}">đến ${endDate}</c:if></h3>
        </div>
        <div class="table-responsive">
          <table class="report-table">
            <thead>
              <tr>
                <th>Mã phiếu</th>
                <th>Ngày nhập</th>
                <th>Nhà cung cấp</th>
                <th>Người lập</th>
                <th>Trạng thái</th>
                <th style="text-align: right;">Tổng số lượng</th>
                <th style="text-align: right;">Tổng giá trị nhập</th>
                <th style="text-align: center;">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty inboundReport}">
                  <c:forEach var="item" items="${inboundReport}">
                    <tr>
                      <td><strong>#<c:out value="${item.code}"/></strong></td>
                      <td><fmt:formatDate value="${item.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                      <td><c:out value="${item.supplierName}"/></td>
                      <td><c:out value="${item.creatorName}"/></td>
                      <td>
                        <span class="report-badge" style="background: rgba(59, 130, 246, 0.1); color: #3b82f6; font-weight: bold;">
                          <c:out value="${item.status}"/>
                        </span>
                      </td>
                      <td style="text-align: right; font-weight: 600;"><fmt:formatNumber value="${item.totalQty}" pattern="#,##0"/></td>
                      <td style="text-align: right; font-weight: 700; color: #1e293b;"><fmt:formatNumber value="${item.totalVal}" type="currency" currencyCode="VND"/></td>
                      <td style="text-align: center;">
                        <button type="button" onclick="openReceiptDetailModal('${item.id}')" title="Xem chi tiết phiếu nhập kho" style="padding: 6px 14px; background: rgba(59, 130, 246, 0.08); color: #2563eb; border: 1.5px solid rgba(59, 130, 246, 0.25); border-radius: 8px; font-weight: 700; font-size: 13px; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s;" onmouseover="this.style.background='#2563eb'; this.style.color='#ffffff';" onmouseout="this.style.background='rgba(59, 130, 246, 0.08)'; this.style.color='#2563eb';">
                          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                          Xem chi tiết
                        </button>
                      </td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="8" style="text-align: center; color: #64748b; padding: 24px;">Không tìm thấy lịch sử nhập kho nào phù hợp với bộ lọc ngày đã chọn.</td>
                  </tr>
                </c:otherwise>
              </c:choose>
            </tbody>
          </table>
        </div>
        <!-- Pagination Toolbar -->
        <c:if test="${totalItems > 0}">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 24px; padding-top: 16px; border-top: 1.5px solid var(--card-border); flex-wrap: wrap; gap: 16px;">
            <div style="font-size: 14px; color: var(--text-secondary); font-weight: 600;">
              Hiển thị 
              <c:choose>
                <c:when test="${totalItems == 0}">0</c:when>
                <c:otherwise>${(currentPage - 1) * limit + 1}</c:otherwise>
              </c:choose>
              đến 
              <c:choose>
                <c:when test="${currentPage * limit > totalItems}">${totalItems}</c:when>
                <c:otherwise>${currentPage * limit}</c:otherwise>
              </c:choose>
              trong số <strong>${totalItems}</strong> bản ghi
            </div>

            <div style="display: flex; align-items: center; gap: 16px;">
              <!-- Limit selector -->
              <div style="display: flex; align-items: center; gap: 8px;">
                <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Số dòng:</span>
                <select onchange="changeLimit(this.value)" style="padding: 6px 12px; border: 1.5px solid var(--card-border); border-radius: 8px; font-size: 14px; font-weight: 600; color: var(--text-primary); outline: none; background: #ffffff; cursor: pointer; height: 36px; box-sizing: border-box;">
                  <option value="5" ${limit == 5 ? 'selected' : ''}>5</option>
                  <option value="10" ${limit == 10 ? 'selected' : ''}>10</option>
                  <option value="20" ${limit == 20 ? 'selected' : ''}>20</option>
                  <option value="50" ${limit == 50 ? 'selected' : ''}>50</option>
                </select>
              </div>

              <!-- Pagination Buttons -->
              <div style="display: flex; gap: 6px;">
                <button onclick="goToPage(1)" ${currentPage == 1 ? 'disabled' : ''} class="pagination-btn" title="Trang đầu">
                  &laquo;
                </button>
                <button onclick="goToPage(${currentPage - 1})" ${currentPage == 1 ? 'disabled' : ''} class="pagination-btn" title="Trang trước">
                  &lsaquo;
                </button>
                <c:forEach var="p" begin="${currentPage - 2 < 1 ? 1 : currentPage - 2}" end="${currentPage + 2 > totalPages ? totalPages : currentPage + 2}">
                  <button onclick="goToPage(${p})" class="pagination-btn ${p == currentPage ? 'pagination-btn--active' : ''}">
                    ${p}
                  </button>
                </c:forEach>
                <button onclick="goToPage(${currentPage + 1})" ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''} class="pagination-btn" title="Trang sau">
                  &rsaquo;
                </button>
                <button onclick="goToPage(${totalPages})" ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''} class="pagination-btn" title="Trang cuối">
                  &raquo;
                </button>
              </div>
            </div>
          </div>
        </c:if>
      </div>
    </c:when>

    <%-- ==================== TAB 3: XUẤT KHO (OUTBOUND) ==================== --%>
    <c:when test="${reportType == 'outbound'}">
      <!-- Thẻ thống kê nhanh cho Xuất kho -->
      <div class="quick-stats-grid">
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng số phiếu xuất</p>
            <strong><c:out value="${totalOutboundShipments}"/></strong>
          </div>
          <div class="report-stat-card__icon icon-blue">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path></svg>
          </div>
        </div>
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng lượng hàng xuất</p>
            <strong><fmt:formatNumber value="${totalOutboundQty}" pattern="#,##0"/></strong>
          </div>
          <div class="report-stat-card__icon icon-green">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
          </div>
        </div>
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng giá trị xuất</p>
            <strong><fmt:formatNumber value="${totalOutboundVal}" type="currency" currencyCode="VND"/></strong>
          </div>
          <div class="report-stat-card__icon icon-purple">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
          </div>
        </div>
      </div>

      <!-- Bảng báo cáo Xuất kho chi tiết -->
      <div class="details-section">
        <div class="details-section__header">
          <h3>Báo cáo chi tiết lịch sử Xuất kho <c:if test="${not empty startDate}">từ ${startDate}</c:if> <c:if test="${not empty endDate}">đến ${endDate}</c:if></h3>
        </div>
        <div class="table-responsive">
          <table class="report-table">
            <thead>
              <tr>
                <th>Mã phiếu</th>
                <th>Ngày xuất</th>
                <th>Địa điểm nhận</th>
                <th>Người lập</th>
                <th>Trạng thái</th>
                <th style="text-align: right;">Tổng số lượng</th>
                <th style="text-align: right;">Tổng giá trị xuất</th>
                <th style="text-align: center;">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty outboundReport}">
                  <c:forEach var="item" items="${outboundReport}">
                    <tr>
                      <td><strong>#<c:out value="${item.code}"/></strong></td>
                      <td><fmt:formatDate value="${item.createdAt}" pattern="dd/MM/yyyy HH:mm"/></td>
                      <td><c:out value="${item.destination}"/></td>
                      <td><c:out value="${item.creatorName}"/></td>
                      <td>
                        <span class="report-badge" style="background: rgba(16, 185, 129, 0.1); color: #10b981; font-weight: bold;">
                          <c:out value="${item.status}"/>
                        </span>
                      </td>
                      <td style="text-align: right; font-weight: 600;"><fmt:formatNumber value="${item.totalQty}" pattern="#,##0"/></td>
                      <td style="text-align: right; font-weight: 700; color: #1e293b;"><fmt:formatNumber value="${item.totalVal}" type="currency" currencyCode="VND"/></td>
                      <td style="text-align: center;">
                        <button type="button" onclick="openShipmentDetailModal('${item.id}')" title="Xem chi tiết phiếu xuất kho" style="padding: 6px 14px; background: rgba(16, 185, 129, 0.08); color: #059669; border: 1.5px solid rgba(16, 185, 129, 0.25); border-radius: 8px; font-weight: 700; font-size: 13px; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s;" onmouseover="this.style.background='#059669'; this.style.color='#ffffff';" onmouseout="this.style.background='rgba(16, 185, 129, 0.08)'; this.style.color='#059669';">
                          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                          Xem chi tiết
                        </button>
                      </td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="8" style="text-align: center; color: #64748b; padding: 24px;">Không tìm thấy lịch sử xuất kho nào phù hợp với bộ lọc ngày đã chọn.</td>
                  </tr>
                </c:otherwise>
              </c:choose>
            </tbody>
          </table>
        </div>
        <!-- Pagination Toolbar -->
        <c:if test="${totalItems > 0}">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 24px; padding-top: 16px; border-top: 1.5px solid var(--card-border); flex-wrap: wrap; gap: 16px;">
            <div style="font-size: 14px; color: var(--text-secondary); font-weight: 600;">
              Hiển thị 
              <c:choose>
                <c:when test="${totalItems == 0}">0</c:when>
                <c:otherwise>${(currentPage - 1) * limit + 1}</c:otherwise>
              </c:choose>
              đến 
              <c:choose>
                <c:when test="${currentPage * limit > totalItems}">${totalItems}</c:when>
                <c:otherwise>${currentPage * limit}</c:otherwise>
              </c:choose>
              trong số <strong>${totalItems}</strong> bản ghi
            </div>

            <div style="display: flex; align-items: center; gap: 16px;">
              <!-- Limit selector -->
              <div style="display: flex; align-items: center; gap: 8px;">
                <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Số dòng:</span>
                <select onchange="changeLimit(this.value)" style="padding: 6px 12px; border: 1.5px solid var(--card-border); border-radius: 8px; font-size: 14px; font-weight: 600; color: var(--text-primary); outline: none; background: #ffffff; cursor: pointer; height: 36px; box-sizing: border-box;">
                  <option value="5" ${limit == 5 ? 'selected' : ''}>5</option>
                  <option value="10" ${limit == 10 ? 'selected' : ''}>10</option>
                  <option value="20" ${limit == 20 ? 'selected' : ''}>20</option>
                  <option value="50" ${limit == 50 ? 'selected' : ''}>50</option>
                </select>
              </div>

              <!-- Pagination Buttons -->
              <div style="display: flex; gap: 6px;">
                <button onclick="goToPage(1)" ${currentPage == 1 ? 'disabled' : ''} class="pagination-btn" title="Trang đầu">
                  &laquo;
                </button>
                <button onclick="goToPage(${currentPage - 1})" ${currentPage == 1 ? 'disabled' : ''} class="pagination-btn" title="Trang trước">
                  &lsaquo;
                </button>
                <c:forEach var="p" begin="${currentPage - 2 < 1 ? 1 : currentPage - 2}" end="${currentPage + 2 > totalPages ? totalPages : currentPage + 2}">
                  <button onclick="goToPage(${p})" class="pagination-btn ${p == currentPage ? 'pagination-btn--active' : ''}">
                    ${p}
                  </button>
                </c:forEach>
                <button onclick="goToPage(${currentPage + 1})" ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''} class="pagination-btn" title="Trang sau">
                  &rsaquo;
                </button>
                <button onclick="goToPage(${totalPages})" ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''} class="pagination-btn" title="Trang cuối">
                  &raquo;
                </button>
              </div>
            </div>
          </div>
        </c:if>
      </div>
    </c:when>

    <%-- ==================== TAB 4: TỒN KHO (INVENTORY) ==================== --%>
    <c:when test="${reportType == 'inventory'}">
      <!-- Thẻ thống kê nhanh cho Tồn kho -->
      <div class="quick-stats-grid">
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng mặt hàng</p>
            <strong><c:out value="${totalInvProductsCount}"/></strong>
          </div>
          <div class="report-stat-card__icon icon-blue">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path></svg>
          </div>
        </div>
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng số lượng tồn</p>
            <strong><fmt:formatNumber value="${totalInvQty}" pattern="#,##0"/></strong>
          </div>
          <div class="report-stat-card__icon icon-green">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="5" rx="9" ry="3"></ellipse><path d="M3 5V19A9 3 0 0 0 21 19V5"></path></svg>
          </div>
        </div>
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng giá trị tồn kho</p>
            <strong><fmt:formatNumber value="${totalInvVal}" type="currency" currencyCode="VND"/></strong>
          </div>
          <div class="report-stat-card__icon icon-purple">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
        </div>
      </div>
    </div>

      <!-- Bảng tồn kho chi tiết -->
      <div class="details-section">
        <div class="details-section__header">
          <h3>Báo cáo chi tiết lượng hàng tồn kho thực tế</h3>
        </div>
        <div class="table-responsive">
          <table class="report-table">
            <thead>
              <tr>
                <th>Tên sản phẩm</th>
                <th>Mã lô (Batch)</th>
                <th>SKU</th>
                <th style="text-align: right;">Đơn giá</th>
                <th style="text-align: right;">Lượng tồn kho</th>
                <th style="text-align: right;">Định mức tối thiểu</th>
                <th>Trạng thái</th>
                <th style="text-align: center;">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty inventoryReport}">
                  <c:forEach var="item" items="${inventoryReport}">
                    <c:set var="isLow" value="${item.minStockLevel > 0 && item.quantityInStock <= item.minStockLevel}"/>
                    <tr>
                      <td><strong><c:out value="${item.productName}"/></strong></td>
                      <td><code><c:out value="${item.batchCode}"/></code></td>
                      <td><c:out value="${item.sku}"/></td>
                      <td style="text-align: right; font-weight: 500;"><fmt:formatNumber value="${item.price}" type="currency" currencyCode="VND"/></td>
                      <td style="text-align: right; font-weight: 700; color: ${isLow ? '#ef4444' : '#1e293b'};">
                        <fmt:formatNumber value="${item.quantityInStock}" pattern="#,##0"/>
                      </td>
                      <td style="text-align: right; color: #64748b;"><fmt:formatNumber value="${item.minStockLevel}" pattern="#,##0"/></td>
                      <td>
                        <c:choose>
                          <c:when test="${isLow}">
                            <span class="report-badge report-badge--danger">Tồn kho thấp</span>
                          </c:when>
                          <c:otherwise>
                            <span class="report-badge" style="background: #e6fbf1; color: #10b981;">Đủ hàng</span>
                          </c:otherwise>
                        </c:choose>
                      </td>
                      <td style="text-align: center;">
                        <button type="button" onclick="openInventoryDetailModal('${item.productId}', '${item.batchCode}')" title="Xem chi tiết tồn kho sản phẩm" style="padding: 6px 14px; background: rgba(109, 40, 217, 0.08); color: #6d28d9; border: 1.5px solid rgba(109, 40, 217, 0.25); border-radius: 8px; font-weight: 700; font-size: 13px; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s;" onmouseover="this.style.background='#6d28d9'; this.style.color='#ffffff';" onmouseout="this.style.background='rgba(109, 40, 217, 0.08)'; this.style.color='#6d28d9';">
                          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                          Xem chi tiết
                        </button>
                      </td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="8" style="text-align: center; color: #64748b; padding: 24px;">Không tìm thấy thông tin tồn kho.</td>
                  </tr>
                </c:otherwise>
              </c:choose>
            </tbody>
          </table>
        </div>
        <!-- Pagination Toolbar -->
        <c:if test="${totalItems > 0}">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 24px; padding-top: 16px; border-top: 1.5px solid var(--card-border); flex-wrap: wrap; gap: 16px;">
            <div style="font-size: 14px; color: var(--text-secondary); font-weight: 600;">
              Hiển thị 
              <c:choose>
                <c:when test="${totalItems == 0}">0</c:when>
                <c:otherwise>${(currentPage - 1) * limit + 1}</c:otherwise>
              </c:choose>
              đến 
              <c:choose>
                <c:when test="${currentPage * limit > totalItems}">${totalItems}</c:when>
                <c:otherwise>${currentPage * limit}</c:otherwise>
              </c:choose>
              trong số <strong>${totalItems}</strong> bản ghi
            </div>

            <div style="display: flex; align-items: center; gap: 16px;">
              <!-- Limit selector -->
              <div style="display: flex; align-items: center; gap: 8px;">
                <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Số dòng:</span>
                <select onchange="changeLimit(this.value)" style="padding: 6px 12px; border: 1.5px solid var(--card-border); border-radius: 8px; font-size: 14px; font-weight: 600; color: var(--text-primary); outline: none; background: #ffffff; cursor: pointer; height: 36px; box-sizing: border-box;">
                  <option value="5" ${limit == 5 ? 'selected' : ''}>5</option>
                  <option value="10" ${limit == 10 ? 'selected' : ''}>10</option>
                  <option value="20" ${limit == 20 ? 'selected' : ''}>20</option>
                  <option value="50" ${limit == 50 ? 'selected' : ''}>50</option>
                </select>
              </div>

              <!-- Pagination Buttons -->
              <div style="display: flex; gap: 6px;">
                <button onclick="goToPage(1)" ${currentPage == 1 ? 'disabled' : ''} class="pagination-btn" title="Trang đầu">
                  &laquo;
                </button>
                <button onclick="goToPage(${currentPage - 1})" ${currentPage == 1 ? 'disabled' : ''} class="pagination-btn" title="Trang trước">
                  &lsaquo;
                </button>
                <c:forEach var="p" begin="${currentPage - 2 < 1 ? 1 : currentPage - 2}" end="${currentPage + 2 > totalPages ? totalPages : currentPage + 2}">
                  <button onclick="goToPage(${p})" class="pagination-btn ${p == currentPage ? 'pagination-btn--active' : ''}">
                    ${p}
                  </button>
                </c:forEach>
                <button onclick="goToPage(${currentPage + 1})" ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''} class="pagination-btn" title="Trang sau">
                  &rsaquo;
                </button>
                <button onclick="goToPage(${totalPages})" ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''} class="pagination-btn" title="Trang cuối">
                  &raquo;
                </button>
              </div>
            </div>
          </div>
        </c:if>
      </div>
    </c:when>

    <%-- ==================== TAB 5: NHẬP XUẤT TỒN (NXT) ==================== --%>
    <c:when test="${reportType == 'nxt'}">
      <!-- Thẻ thống kê nhanh cho Nhập Xuất Tồn -->
      <div class="quick-stats-grid">
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng Tồn Đầu Kỳ</p>
            <strong><fmt:formatNumber value="${totalBeg}" pattern="#,##0"/></strong>
          </div>
          <div class="report-stat-card__icon icon-blue">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><ellipse cx="12" cy="5" rx="9" ry="3"></ellipse><path d="M3 5V19A9 3 0 0 0 21 19V5"></path></svg>
          </div>
        </div>
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng Nhập Trong Kỳ</p>
            <strong><fmt:formatNumber value="${totalIn}" pattern="#,##0"/></strong>
          </div>
          <div class="report-stat-card__icon icon-green">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v14M19 9l-7 7-7-7M2 22h20"/></svg>
          </div>
        </div>
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng Xuất Trong Kỳ</p>
            <strong><fmt:formatNumber value="${totalOut}" pattern="#,##0"/></strong>
          </div>
          <div class="report-stat-card__icon icon-red">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 16V2M5 9l7-7 7 7M2 22h20"/></svg>
          </div>
        </div>
        <div class="report-stat-card">
          <div class="report-stat-card__info">
            <p>Tổng Tồn Cuối Kỳ</p>
            <strong><fmt:formatNumber value="${totalEnd}" pattern="#,##0"/></strong>
            <div style="font-size: 11px; color: #64748b; margin-top: 4px; font-weight: 600;">
              Trị giá: <fmt:formatNumber value="${totalValueEnd}" type="currency" currencyCode="VND"/>
            </div>
          </div>
          <div class="report-stat-card__icon icon-purple">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
          </div>
        </div>
      </div>

      <!-- Bảng chi tiết -->
      <div class="details-section">
        <div class="details-section__header">
          <h3>Báo cáo Tổng hợp Nhập Xuất Tồn kho chi tiết</h3>
        </div>
        <div class="table-responsive">
          <table class="report-table">
            <thead>
              <tr>
                <th>SKU</th>
                <th>Tên sản phẩm</th>
                <th>Hãng / Dòng SP</th>
                <th>Đơn vị</th>
                <th style="text-align: right;">Đơn giá</th>
                <th style="text-align: right; background-color: #eff6ff;">Tồn đầu</th>
                <th style="text-align: right; background-color: #f0fdf4;">Nhập kho</th>
                <th style="text-align: right; background-color: #fef2f2;">Xuất kho</th>
                <th style="text-align: right; background-color: #faf5ff;">Tồn cuối</th>
                <th style="text-align: right;">Giá trị tồn cuối</th>
                <th style="text-align: center;">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty nxtReport}">
                  <c:forEach var="item" items="${nxtReport}">
                    <tr>
                      <td><code><c:out value="${item.sku}"/></code></td>
                      <td><strong><c:out value="${item.productName}"/></strong></td>
                      <td>
                        <small style="color: #64748b;"><c:out value="${item.brandName}"/> - <c:out value="${item.productLineName}"/></small>
                      </td>
                      <td><c:out value="${item.unit}"/></td>
                      <td style="text-align: right; font-weight: 500;"><fmt:formatNumber value="${item.price}" type="currency" currencyCode="VND"/></td>
                      <td style="text-align: right; font-weight: 600; background-color: #eff6ff;"><fmt:formatNumber value="${item.beginningQty}" pattern="#,##0"/></td>
                      <td style="text-align: right; font-weight: 600; background-color: #f0fdf4; color: #16a34a;">+<fmt:formatNumber value="${item.inboundQty}" pattern="#,##0"/></td>
                      <td style="text-align: right; font-weight: 600; background-color: #fef2f2; color: #dc2626;">-<fmt:formatNumber value="${item.outboundQty}" pattern="#,##0"/></td>
                      <td style="text-align: right; font-weight: 700; background-color: #faf5ff; color: #1e293b;"><fmt:formatNumber value="${item.endingQty}" pattern="#,##0"/></td>
                      <td style="text-align: right; font-weight: 700; color: #4f46e5;">
                        <fmt:formatNumber value="${item.endingQty * item.price}" type="currency" currencyCode="VND"/>
                      </td>
                      <td style="text-align: center;">
                        <button type="button" onclick="openNXTDetailModal('${item.productId}')" title="Xem lịch sử nhập xuất tồn của sản phẩm" style="padding: 6px 14px; background: rgba(79, 70, 229, 0.08); color: #4f46e5; border: 1.5px solid rgba(79, 70, 229, 0.25); border-radius: 8px; font-weight: 700; font-size: 13px; cursor: pointer; display: inline-flex; align-items: center; gap: 6px; transition: all 0.2s;" onmouseover="this.style.background='#4f46e5'; this.style.color='#ffffff';" onmouseout="this.style.background='rgba(79, 70, 229, 0.08)'; this.style.color='#4f46e5';">
                          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                          Xem chi tiết
                        </button>
                      </td>
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="11" style="text-align: center; color: #64748b; padding: 24px;">Không tìm thấy dữ liệu nào phù hợp với bộ lọc đã chọn.</td>
                  </tr>
                </c:otherwise>
              </c:choose>
            </tbody>
          </table>
        </div>
        <!-- Pagination Toolbar -->
        <c:if test="${totalItems > 0}">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 24px; padding-top: 16px; border-top: 1.5px solid var(--card-border); flex-wrap: wrap; gap: 16px;">
            <div style="font-size: 14px; color: var(--text-secondary); font-weight: 600;">
              Hiển thị 
              <c:choose>
                <c:when test="${totalItems == 0}">0</c:when>
                <c:otherwise>${(currentPage - 1) * limit + 1}</c:otherwise>
              </c:choose>
              đến 
              <c:choose>
                <c:when test="${currentPage * limit > totalItems}">${totalItems}</c:when>
                <c:otherwise>${currentPage * limit}</c:otherwise>
              </c:choose>
              trong số <strong>${totalItems}</strong> bản ghi
            </div>

            <div style="display: flex; align-items: center; gap: 16px;">
              <!-- Limit selector -->
              <div style="display: flex; align-items: center; gap: 8px;">
                <span style="font-size: 13px; color: var(--text-secondary); font-weight: 600;">Số dòng:</span>
                <select onchange="changeLimit(this.value)" style="padding: 6px 12px; border: 1.5px solid var(--card-border); border-radius: 8px; font-size: 14px; font-weight: 600; color: var(--text-primary); outline: none; background: #ffffff; cursor: pointer; height: 36px; box-sizing: border-box;">
                  <option value="5" ${limit == 5 ? 'selected' : ''}>5</option>
                  <option value="10" ${limit == 10 ? 'selected' : ''}>10</option>
                  <option value="20" ${limit == 20 ? 'selected' : ''}>20</option>
                  <option value="50" ${limit == 50 ? 'selected' : ''}>50</option>
                </select>
              </div>

              <!-- Pagination Buttons -->
              <div style="display: flex; gap: 6px;">
                <button onclick="goToPage(1)" ${currentPage == 1 ? 'disabled' : ''} class="pagination-btn" title="Trang đầu">
                  &laquo;
                </button>
                <button onclick="goToPage(${currentPage - 1})" ${currentPage == 1 ? 'disabled' : ''} class="pagination-btn" title="Trang trước">
                  &lsaquo;
                </button>
                <c:forEach var="p" begin="${currentPage - 2 < 1 ? 1 : currentPage - 2}" end="${currentPage + 2 > totalPages ? totalPages : currentPage + 2}">
                  <button onclick="goToPage(${p})" class="pagination-btn ${p == currentPage ? 'pagination-btn--active' : ''}">
                    ${p}
                  </button>
                </c:forEach>
                <button onclick="goToPage(${currentPage + 1})" ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''} class="pagination-btn" title="Trang sau">
                  &rsaquo;
                </button>
                <button onclick="goToPage(${totalPages})" ${currentPage == totalPages || totalPages == 0 ? 'disabled' : ''} class="pagination-btn" title="Trang cuối">
                  &raquo;
                </button>
              </div>
            </div>
          </div>
        </c:if>
      </div>
    </c:when>
  </c:choose>

</div>

<!-- Cấu hình và Vẽ Biểu đồ -->
<script>
  document.addEventListener("DOMContentLoaded", function() {
    // 1. Định dạng Tiền tệ cho các thẻ số liệu
    const valuationEl = document.getElementById("valuationText");
    if (valuationEl) {
      const rawVal = parseFloat(valuationEl.getAttribute("data-raw"));
      valuationEl.textContent = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(rawVal);
    }

    // 2. Nạp dữ liệu từ backend sang Javascript array (chỉ khi ở tab overview)
    const months = [];
    const inboundValues = [];
    const outboundValues = [];
    <c:forEach var="item" items="${monthlyStats}">
      months.push('Tháng ${item.month}');
      inboundValues.push(${item.inboundValue});
      outboundValues.push(${item.outboundValue});
    </c:forEach>

    const brandNames = [];
    const brandValuations = [];
    let totalValuationSum = 0;
    <c:forEach var="item" items="${brandValuation}">
      brandNames.push('${item.brandName}');
      brandValuations.push(${item.valuation});
      totalValuationSum += ${item.valuation};
    </c:forEach>

    const topProductNames = [];
    const topProductQtys = [];
    <c:forEach var="item" items="${topMoving}">
      topProductNames.push('${item.sku} - ${item.productName}');
      topProductQtys.push(${item.quantity});
    </c:forEach>

    // 3. Đổ dữ liệu vào bảng phân bổ Hãng sản xuất
    const brandTableBody = document.getElementById("brandTableBody");
    if (brandTableBody) {
      if (brandNames.length > 0) {
        brandNames.forEach((name, index) => {
          const val = brandValuations[index];
          const percent = totalValuationSum > 0 ? ((val / totalValuationSum) * 100).toFixed(1) : 0;
          const formattedVal = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(val);
          
          const tr = document.createElement("tr");
          tr.innerHTML = `
            <td><strong>\${name}</strong></td>
            <td style="text-align: right; font-weight: 600;">\${formattedVal}</td>
            <td style="text-align: right;"><span class="report-badge" style="background: #f1f5f9; color: #475569; font-weight: 700;">\${percent}%</span></td>
          `;
          brandTableBody.appendChild(tr);
        });
      } else {
        brandTableBody.innerHTML = `<tr><td colspan="3" style="text-align: center; color: #94a3b8;">Chưa có dữ liệu tồn kho</td></tr>`;
      }
    }

    // 4. Vẽ Biểu đồ 1: Nhập vs Xuất theo tháng (Biểu đồ Cột Nhóm)
    const canvasMonthly = document.getElementById('monthlyInboundOutboundChart');
    if (canvasMonthly) {
      const ctxMonthly = canvasMonthly.getContext('2d');
      new Chart(ctxMonthly, {
        type: 'bar',
        data: {
          labels: months,
          datasets: [
            {
              label: 'Giá trị Nhập kho',
              data: inboundValues,
              backgroundColor: 'rgba(59, 130, 246, 0.85)',
              borderColor: '#3b82f6',
              borderWidth: 1,
              borderRadius: 6,
            },
            {
              label: 'Giá trị Xuất kho',
              data: outboundValues,
              backgroundColor: 'rgba(239, 68, 68, 0.85)',
              borderColor: '#ef4444',
              borderWidth: 1,
              borderRadius: 6,
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              position: 'top',
              labels: {
                boxWidth: 12,
                font: { weight: 600, family: 'Inter, sans-serif' }
              }
            },
            tooltip: {
              callbacks: {
                label: function(context) {
                  let label = context.dataset.label || '';
                  if (label) {
                    label += ': ';
                  }
                  if (context.parsed.y !== null) {
                    label += new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(context.parsed.y);
                  }
                  return label;
                }
              }
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              ticks: {
                callback: function(value) {
                  return new Intl.NumberFormat('vi-VN', { notation: 'compact', compactDisplay: 'short' }).format(value) + ' đ';
                }
              }
            }
          }
        }
      });
    }

    // 5. Vẽ Biểu đồ 2: Cơ cấu Tồn kho theo Hãng (Biểu đồ Tròn/Doughnut)
    const canvasBrand = document.getElementById('brandValuationChart');
    if (canvasBrand) {
      const ctxBrand = canvasBrand.getContext('2d');
      new Chart(ctxBrand, {
        type: 'doughnut',
        data: {
          labels: brandNames,
          datasets: [{
            data: brandValuations,
            backgroundColor: [
              '#3b82f6', // Blue
              '#10b981', // Green
              '#a855f7', // Purple
              '#f59e0b', // Yellow/Orange
              '#ec4899', // Pink
              '#64748b'  // Slate
            ],
            borderWidth: 2,
            borderColor: '#ffffff'
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              position: 'bottom',
              labels: {
                boxWidth: 12,
                font: { size: 11, weight: 600, family: 'Inter, sans-serif' }
              }
            },
            tooltip: {
              callbacks: {
                label: function(context) {
                  const value = context.parsed;
                  const formattedVal = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(value);
                  const percent = totalValuationSum > 0 ? ((value / totalValuationSum) * 100).toFixed(1) : 0;
                  return ` ${context.label}: ${formattedVal} (${percent}%)`;
                }
              }
            }
          },
          cutout: '65%'
        }
      });
    }

    // 6. Vẽ Biểu đồ 3: Top 5 Nhân tố/Sản phẩm xuất nhiều nhất (Biểu đồ ngang)
    const canvasTop = document.getElementById('topMovingProductsChart');
    if (canvasTop) {
      const ctxTop = canvasTop.getContext('2d');
      new Chart(ctxTop, {
        type: 'bar',
        data: {
          labels: topProductNames,
          datasets: [{
            label: 'Số lượng xuất (cái/bộ/chiếc)',
            data: topProductQtys,
            backgroundColor: 'rgba(249, 115, 22, 0.85)',
            borderColor: '#f97316',
            borderWidth: 1,
            borderRadius: 6
          }]
        },
        options: {
          indexAxis: 'y',
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: false
            }
          },
          scales: {
            x: {
              beginAtZero: true,
              ticks: {
                stepSize: 1
              }
            },
            y: {
              ticks: {
                font: { size: 10, weight: 600, family: 'Inter, sans-serif' }
              }
            }
          }
        }
      });
    }

    // Hỗ trợ phân trang
    window.goToPage = function(page) {
      const urlParams = new URLSearchParams(window.location.search);
      urlParams.set('page', page);
      window.location.search = urlParams.toString();
    }

    window.changeLimit = function(limit) {
      const urlParams = new URLSearchParams(window.location.search);
      urlParams.set('limit', limit);
      urlParams.set('page', 1);
      window.location.search = urlParams.toString();
    }
  });

  // Modal Chi tiết Phiếu Nhập & Phiếu Xuất kho
  function formatCurrency(amount) {
    return new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount || 0);
  }

  function formatBatchCode(batchText) {
    if (!batchText || batchText.trim() === '') return '-';
    const batches = batchText.split(',').map(b => b.trim()).filter(b => b.length > 0);
    if (batches.length === 0) return '-';
    return '<div style="display: flex; flex-direction: column; gap: 4px; align-items: flex-start;">' +
           batches.map(b => '<span style="color: #6d28d9; font-weight: 700; font-family: monospace; background: rgba(109, 40, 217, 0.08); padding: 2px 8px; border-radius: 4px; display: inline-block; white-space: nowrap;">' + b + '</span>').join('') +
           '</div>';
  }

  function generateBarcodeSvg(barcodeText, idx) {
    if (!barcodeText || barcodeText.trim() === '') return '<span style="color: #94a3b8; font-size: 11px;">-</span>';
    const codes = barcodeText.split(',').map(c => c.trim()).filter(c => c.length > 0);
    if (codes.length === 0) return '<span style="color: #94a3b8; font-size: 11px;">-</span>';

    const renderBox = (code) => {
      return '<div style="display: inline-flex; flex-direction: column; align-items: center; padding: 4px 10px; border: 1.5px solid #cbd5e1; border-radius: 8px; background: #ffffff; box-shadow: 0 1px 2px rgba(0,0,0,0.04); white-space: nowrap;">' +
             '  <svg width="64" height="20" viewBox="0 0 64 20">' +
             '    <rect x="2" y="2" width="2" height="16" fill="#1e293b"/>' +
             '    <rect x="6" y="2" width="1" height="16" fill="#1e293b"/>' +
             '    <rect x="9" y="2" width="3" height="16" fill="#1e293b"/>' +
             '    <rect x="14" y="2" width="1" height="16" fill="#1e293b"/>' +
             '    <rect x="17" y="2" width="2" height="16" fill="#1e293b"/>' +
             '    <rect x="21" y="2" width="4" height="16" fill="#1e293b"/>' +
             '    <rect x="27" y="2" width="1" height="16" fill="#1e293b"/>' +
             '    <rect x="30" y="2" width="2" height="16" fill="#1e293b"/>' +
             '    <rect x="34" y="2" width="3" height="16" fill="#1e293b"/>' +
             '    <rect x="39" y="2" width="1" height="16" fill="#1e293b"/>' +
             '    <rect x="42" y="2" width="2" height="16" fill="#1e293b"/>' +
             '    <rect x="46" y="2" width="4" height="16" fill="#1e293b"/>' +
             '    <rect x="52" y="2" width="1" height="16" fill="#1e293b"/>' +
             '    <rect x="55" y="2" width="2" height="16" fill="#1e293b"/>' +
             '  </svg>' +
             '  <span style="font-size: 10px; font-family: monospace; color: #475569; font-weight: 700; margin-top: 2px;">' + code + '</span>' +
             '</div>';
    };

    if (codes.length <= 2) {
      return '<div style="display: flex; flex-direction: column; gap: 6px; align-items: center; justify-content: center; padding: 4px 0;">' +
             codes.map(renderBox).join('') +
             '</div>';
    }

    const visibleCodes = codes.slice(0, 2);
    const hiddenCodes = codes.slice(2);
    const hiddenCount = hiddenCodes.length;
    const totalCount = codes.length;
    const randomSuffix = Math.floor(Math.random() * 100000);
    const containerId = 'extraBarcodes_' + (idx !== undefined ? idx : randomSuffix);
    const btnId = 'btnToggleBarcode_' + (idx !== undefined ? idx : randomSuffix);

    return '<div style="display: flex; flex-direction: column; gap: 6px; align-items: center; justify-content: center; padding: 4px 0;">' +
           visibleCodes.map(renderBox).join('') +
           '  <div id="' + containerId + '" style="display: none; flex-direction: column; gap: 6px; align-items: center;">' +
           hiddenCodes.map(renderBox).join('') +
           '  </div>' +
           '  <button type="button" id="' + btnId + '" onclick="toggleBarcodeExpand(\'' + containerId + '\', \'' + btnId + '\', ' + hiddenCount + ', ' + totalCount + ')" style="padding: 4px 10px; border: 1.5px solid #bfdbfe; background: #eff6ff; color: #2563eb; border-radius: 8px; font-size: 11px; font-weight: 700; cursor: pointer; display: inline-flex; align-items: center; gap: 4px; margin-top: 2px; transition: all 0.2s; white-space: nowrap;" onmouseover="this.style.background=\'#dbeafe\';" onmouseout="this.style.background=\'#eff6ff\';">' +
           '    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6"/></svg>' +
           '    +' + hiddenCount + ' mã khác (Xem tất cả ' + totalCount + ' mã)' +
           '  </button>' +
           '</div>';
  }

  window.toggleBarcodeExpand = function(containerId, btnId, hiddenCount, totalCount) {
    const container = document.getElementById(containerId);
    const btn = document.getElementById(btnId);
    if (!container || !btn) return;

    if (container.style.display === 'none' || container.style.display === '') {
      container.style.display = 'flex';
      btn.innerHTML = '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M18 15l-6-6-6 6"/></svg> Thu gọn';
      btn.style.background = '#f1f5f9';
      btn.style.color = '#475569';
      btn.style.borderColor = '#cbd5e1';
    } else {
      container.style.display = 'none';
      btn.innerHTML = '<svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6"/></svg> +' + hiddenCount + ' mã khác (Xem tất cả ' + totalCount + ' mã)';
      btn.style.background = '#eff6ff';
      btn.style.color = '#2563eb';
      btn.style.borderColor = '#bfdbfe';
    }
  };

  // 1. Modal Chi tiết Phiếu Nhập kho
  window.openReceiptDetailModal = function(receiptId) {
    const modal = document.getElementById('receiptDetailModal');
    if (!modal) return;

    modal.style.display = 'flex';
    setTimeout(() => {
      modal.style.opacity = '1';
      const card = modal.querySelector('.receipt-modal-card');
      if (card) card.style.transform = 'scale(1)';
    }, 10);

    fetch('${pageContext.request.contextPath}/manage/reports?action=apiReceiptDetail&id=' + receiptId)
      .then(response => {
        if (!response.ok) throw new Error('HTTP error ' + response.status);
        return response.json();
      })
      .then(data => {
        if (data.error) {
          alert('Lỗi: ' + data.error);
          closeReceiptDetailModal();
          return;
        }

        document.getElementById('modalReceiptCodeHeader').innerText = '#' + data.code;
        document.getElementById('modalReceiptCode').innerText = '#' + data.code;
        document.getElementById('modalCreatedAt').innerText = data.createdAt || '-';
        document.getElementById('modalSupplierName').innerText = data.supplierName || '-';
        document.getElementById('modalCreatorName').innerText = data.creatorName || '-';
        document.getElementById('modalTotalVal').innerText = formatCurrency(data.totalVal);

        const statusContainer = document.getElementById('modalStatusContainer');
        let badgeClass = 'rgba(59, 130, 246, 0.12)';
        let badgeColor = '#2563eb';
        if (data.status === 'COMPLETED') {
          badgeClass = 'rgba(16, 185, 129, 0.12)';
          badgeColor = '#10b981';
        } else if (data.status === 'CANCELLED') {
          badgeClass = 'rgba(239, 68, 68, 0.12)';
          badgeColor = '#ef4444';
        }
        statusContainer.innerHTML = '<span class="report-badge" style="background: ' + badgeClass + '; color: ' + badgeColor + '; font-weight: 800; padding: 4px 10px; border-radius: 6px; font-size: 12px; display: inline-block;">' + (data.status || '') + '</span>';

        const details = data.details || [];
        document.getElementById('modalProductCountSummary').innerText = details.length + ' mặt hàng, tổng ' + (data.totalQty || 0) + ' cái';

        const tbody = document.getElementById('modalDetailsTableBody');
        tbody.innerHTML = '';
        if (details.length === 0) {
          tbody.innerHTML = '<tr><td colspan="9" style="text-align: center; color: #94a3b8; padding: 20px;">Không có chi tiết sản phẩm nào.</td></tr>';
        } else {
          details.forEach((d, idx) => {
            const tr = document.createElement('tr');
            tr.style.borderBottom = '1px solid #f1f5f9';
            tr.innerHTML = 
              '<td style="padding: 12px 14px; text-align: center; color: #64748b; font-weight: 600;">' + (idx + 1) + '</td>' +
              '<td style="padding: 12px 14px; font-weight: 600; color: #475569;">' + (d.sku || '-') + '</td>' +
              '<td style="padding: 12px 14px; font-weight: 700; color: #0f172a;">' + (d.productName || '-') + '</td>' +
              '<td style="padding: 12px 14px; color: #475569;">' + (d.unit || '-') + '</td>' +
              '<td style="padding: 12px 14px;">' + formatBatchCode(d.batchCode) + '</td>' +
              '<td style="padding: 12px 14px; text-align: center;">' + generateBarcodeSvg(d.barcode, 'rcpt_' + idx) + '</td>' +
              '<td style="padding: 12px 14px; text-align: right; font-weight: 700; color: #0f172a;">' + d.quantity + '</td>' +
              '<td style="padding: 12px 14px; text-align: right; color: #334155;">' + formatCurrency(d.price) + '</td>' +
              '<td style="padding: 12px 14px; text-align: right; font-weight: 700; color: #0f172a;">' + formatCurrency(d.totalVal) + '</td>';
            tbody.appendChild(tr);
          });
        }

        const imgContainer = document.getElementById('modalInvoiceImageContainer');
        if (data.invoiceImage && data.invoiceImage.trim() !== '') {
          imgContainer.innerHTML = '<a href="${pageContext.request.contextPath}/uploads/' + data.invoiceImage + '" target="_blank">' +
                                   '  <img src="${pageContext.request.contextPath}/uploads/' + data.invoiceImage + '" style="max-width: 220px; max-height: 160px; border-radius: 8px; border: 1px solid #cbd5e1; object-fit: cover; box-shadow: 0 2px 4px rgba(0,0,0,0.05);" alt="Ảnh hóa đơn"/>' +
                                   '</a>';
        } else {
          imgContainer.innerHTML = '<div style="color: #94a3b8; font-size: 13px; font-style: italic;">Không có ảnh hóa đơn đính kèm</div>';
        }

        const btnGo = document.getElementById('btnGoToOriginalPage');
        btnGo.href = '${pageContext.request.contextPath}/manage/receipts?action=view&id=' + receiptId;
      })
      .catch(err => {
        console.error(err);
        alert('Đã xảy ra lỗi khi tải thông tin chi tiết phiếu nhập kho.');
        closeReceiptDetailModal();
      });
  };

  window.closeReceiptDetailModal = function() {
    const modal = document.getElementById('receiptDetailModal');
    if (!modal) return;
    modal.style.opacity = '0';
    const card = modal.querySelector('.receipt-modal-card');
    if (card) card.style.transform = 'scale(0.95)';
    setTimeout(() => { modal.style.display = 'none'; }, 250);
  };

  window.printReceiptDetailModal = function() {
    const printContent = document.getElementById('receiptModalBody').innerHTML;
    const codeHeader = document.getElementById('modalReceiptCodeHeader').innerText;
    const printWindow = window.open('', '_blank', 'width=900,height=700');
    printWindow.document.write('<html><head><title>Chi tiết Phiếu Nhập kho ' + codeHeader + '</title>');
    printWindow.document.write('<style>body { font-family: system-ui, sans-serif; padding: 24px; color: #0f172a; } table { width: 100%; border-collapse: collapse; margin-top: 16px; font-size: 13px; } th, td { border: 1px solid #cbd5e1; padding: 10px 12px; text-align: left; } th { background: #f8fafc; font-weight: bold; }</style></head><body>');
    printWindow.document.write('<h2 style="margin-bottom: 20px; border-bottom: 2px solid #2563eb; padding-bottom: 8px;">Chi tiết Phiếu Nhập kho ' + codeHeader + '</h2>');
    printWindow.document.write(printContent);
    printWindow.document.write('</body></html>');
    printWindow.document.close();
    printWindow.focus();
    setTimeout(() => { printWindow.print(); printWindow.close(); }, 250);
  };

  // 2. Modal Chi tiết Phiếu Xuất kho
  window.openShipmentDetailModal = function(shipmentId) {
    const modal = document.getElementById('shipmentDetailModal');
    if (!modal) return;

    modal.style.display = 'flex';
    setTimeout(() => {
      modal.style.opacity = '1';
      const card = modal.querySelector('.shipment-modal-card');
      if (card) card.style.transform = 'scale(1)';
    }, 10);

    fetch('${pageContext.request.contextPath}/manage/reports?action=apiShipmentDetail&id=' + shipmentId)
      .then(response => {
        if (!response.ok) throw new Error('HTTP error ' + response.status);
        return response.json();
      })
      .then(data => {
        if (data.error) {
          alert('Lỗi: ' + data.error);
          closeShipmentDetailModal();
          return;
        }

        document.getElementById('modalShipmentCodeHeader').innerText = '#' + data.code;
        document.getElementById('modalShipmentCode').innerText = '#' + data.code;
        document.getElementById('modalShipmentCreatedAt').innerText = data.createdAt || '-';
        document.getElementById('modalDestination').innerText = data.destination || '-';
        document.getElementById('modalShipmentCreatorName').innerText = data.creatorName || '-';
        document.getElementById('modalShipmentTotalVal').innerText = formatCurrency(data.totalVal);

        const statusContainer = document.getElementById('modalShipmentStatusContainer');
        let badgeClass = 'rgba(16, 185, 129, 0.12)';
        let badgeColor = '#10b981';
        if (data.status === 'CANCELLED') {
          badgeClass = 'rgba(239, 68, 68, 0.12)';
          badgeColor = '#ef4444';
        } else if (data.status === 'DRAFT' || data.status === 'PENDING') {
          badgeClass = 'rgba(245, 158, 11, 0.12)';
          badgeColor = '#d97706';
        }
        statusContainer.innerHTML = '<span class="report-badge" style="background: ' + badgeClass + '; color: ' + badgeColor + '; font-weight: 800; padding: 4px 10px; border-radius: 6px; font-size: 12px; display: inline-block;">' + (data.status || '') + '</span>';

        const details = data.details || [];
        document.getElementById('modalShipmentProductCountSummary').innerText = details.length + ' mặt hàng, tổng ' + (data.totalQty || 0) + ' cái';

        const tbody = document.getElementById('modalShipmentDetailsTableBody');
        tbody.innerHTML = '';
        if (details.length === 0) {
          tbody.innerHTML = '<tr><td colspan="9" style="text-align: center; color: #94a3b8; padding: 20px;">Không có chi tiết sản phẩm nào.</td></tr>';
        } else {
          details.forEach((d, idx) => {
            const tr = document.createElement('tr');
            tr.style.borderBottom = '1px solid #f1f5f9';
            tr.innerHTML = 
              '<td style="padding: 12px 14px; text-align: center; color: #64748b; font-weight: 600;">' + (idx + 1) + '</td>' +
              '<td style="padding: 12px 14px; font-weight: 600; color: #475569;">' + (d.sku || '-') + '</td>' +
              '<td style="padding: 12px 14px; font-weight: 700; color: #0f172a;">' + (d.productName || '-') + '</td>' +
              '<td style="padding: 12px 14px; color: #475569;">' + (d.unit || '-') + '</td>' +
              '<td style="padding: 12px 14px;">' + formatBatchCode(d.batchCode) + '</td>' +
              '<td style="padding: 12px 14px; text-align: center;">' + generateBarcodeSvg(d.barcode, 'shpm_' + idx) + '</td>' +
              '<td style="padding: 12px 14px; text-align: right; font-weight: 700; color: #0f172a;">' + d.quantity + '</td>' +
              '<td style="padding: 12px 14px; text-align: right; color: #334155;">' + formatCurrency(d.price) + '</td>' +
              '<td style="padding: 12px 14px; text-align: right; font-weight: 700; color: #0f172a;">' + formatCurrency(d.totalVal) + '</td>';
            tbody.appendChild(tr);
          });
        }

        const notesElem = document.getElementById('modalShipmentNotes');
        notesElem.innerText = data.notes && data.notes.trim() !== '' ? data.notes : 'Không có ghi chú';

        const btnGo = document.getElementById('btnGoToOriginalShipmentPage');
        btnGo.href = '${pageContext.request.contextPath}/manage/shipments?action=view&id=' + shipmentId;
      })
      .catch(err => {
        console.error(err);
        alert('Đã xảy ra lỗi khi tải thông tin chi tiết phiếu xuất kho.');
        closeShipmentDetailModal();
      });
  };

  window.closeShipmentDetailModal = function() {
    const modal = document.getElementById('shipmentDetailModal');
    if (!modal) return;
    modal.style.opacity = '0';
    const card = modal.querySelector('.shipment-modal-card');
    if (card) card.style.transform = 'scale(0.95)';
    setTimeout(() => { modal.style.display = 'none'; }, 250);
  };

  window.printShipmentDetailModal = function() {
    const printContent = document.getElementById('shipmentModalBody').innerHTML;
    const codeHeader = document.getElementById('modalShipmentCodeHeader').innerText;
    const printWindow = window.open('', '_blank', 'width=900,height=700');
    printWindow.document.write('<html><head><title>Chi tiết Phiếu Xuất kho ' + codeHeader + '</title>');
    printWindow.document.write('<style>body { font-family: system-ui, sans-serif; padding: 24px; color: #0f172a; } table { width: 100%; border-collapse: collapse; margin-top: 16px; font-size: 13px; } th, td { border: 1px solid #cbd5e1; padding: 10px 12px; text-align: left; } th { background: #f8fafc; font-weight: bold; }</style></head><body>');
    printWindow.document.write('<h2 style="margin-bottom: 20px; border-bottom: 2px solid #10b981; padding-bottom: 8px;">Chi tiết Phiếu Xuất kho ' + codeHeader + '</h2>');
    printWindow.document.write(printContent);
    printWindow.document.write('</body></html>');
    printWindow.document.close();
    printWindow.focus();
    setTimeout(() => { printWindow.print(); printWindow.close(); }, 250);
  };

  document.addEventListener('click', function(e) {
    const rcptModal = document.getElementById('receiptDetailModal');
    if (rcptModal && e.target === rcptModal) closeReceiptDetailModal();

    const shpmModal = document.getElementById('shipmentDetailModal');
    if (shpmModal && e.target === shpmModal) closeShipmentDetailModal();

    const invModal = document.getElementById('inventoryDetailModal');
    if (invModal && e.target === invModal) closeInventoryDetailModal();

    const nxtModal = document.getElementById('nxtDetailModal');
    if (nxtModal && e.target === nxtModal) closeNXTDetailModal();
  });

  // 3. Modal Chi tiết Tồn kho
  window.openInventoryDetailModal = function(productId, batchCode) {
    const modal = document.getElementById('inventoryDetailModal');
    if (!modal) return;

    modal.style.display = 'flex';
    setTimeout(() => {
      modal.style.opacity = '1';
      const card = modal.querySelector('.inventory-modal-card');
      if (card) card.style.transform = 'scale(1)';
    }, 10);

    let url = '${pageContext.request.contextPath}/manage/reports?action=apiInventoryDetail&productId=' + productId;
    if (batchCode && batchCode !== 'null') {
      url += '&batchCode=' + encodeURIComponent(batchCode);
    }

    fetch(url)
      .then(response => {
        if (!response.ok) throw new Error('HTTP error ' + response.status);
        return response.json();
      })
      .then(data => {
        if (data.error) {
          alert('Lỗi: ' + data.error);
          closeInventoryDetailModal();
          return;
        }

        document.getElementById('modalInvProductNameHeader').innerText = data.productName || '-';
        document.getElementById('modalInvSKU').innerText = data.sku || '-';
        document.getElementById('modalInvProductName').innerText = data.productName || '-';
        document.getElementById('modalInvBrandLine').innerText = (data.brandName || '-') + ' / ' + (data.productLineName || '-');
        document.getElementById('modalInvUnit').innerText = data.unit || '-';
        document.getElementById('modalInvPrice').innerText = formatCurrency(data.price);
        document.getElementById('modalInvBatchCode').innerText = data.batchCode || '-';
        document.getElementById('modalInvQtyInStock').innerText = (data.quantityInStock || 0).toLocaleString();
        document.getElementById('modalInvMinStock').innerText = (data.minStockLevel || 0).toLocaleString();
        document.getElementById('modalInvTotalVal').innerText = formatCurrency(data.totalVal);

        const statusContainer = document.getElementById('modalInvStatusContainer');
        let isLow = (data.status === 'Tồn kho thấp');
        statusContainer.innerHTML = '<span class="report-badge" style="background: ' + (isLow ? 'rgba(239, 68, 68, 0.12)' : 'rgba(16, 185, 129, 0.12)') + '; color: ' + (isLow ? '#ef4444' : '#10b981') + '; font-weight: 800; padding: 4px 10px; border-radius: 6px; font-size: 12px; display: inline-block;">' + (data.status || '') + '</span>';

        const barcodeContainer = document.getElementById('modalInvBarcodeContainer');
        barcodeContainer.innerHTML = generateBarcodeSvg(data.barcode, 'inv_detail_mod');

        const btnGo = document.getElementById('btnGoToOriginalInvPage');
        btnGo.href = '${pageContext.request.contextPath}/manage/inventories?action=list&sku=' + encodeURIComponent(data.sku || '');
      })
      .catch(err => {
        console.error(err);
        alert('Đã xảy ra lỗi khi tải thông tin chi tiết tồn kho.');
        closeInventoryDetailModal();
      });
  };

  window.closeInventoryDetailModal = function() {
    const modal = document.getElementById('inventoryDetailModal');
    if (!modal) return;
    modal.style.opacity = '0';
    const card = modal.querySelector('.inventory-modal-card');
    if (card) card.style.transform = 'scale(0.95)';
    setTimeout(() => { modal.style.display = 'none'; }, 250);
  };

  window.printInventoryDetailModal = function() {
    const printContent = document.getElementById('inventoryModalBody').innerHTML;
    const nameHeader = document.getElementById('modalInvProductNameHeader').innerText;
    const printWindow = window.open('', '_blank', 'width=900,height=700');
    printWindow.document.write('<html><head><title>Chi tiết Tồn Kho - ' + nameHeader + '</title>');
    printWindow.document.write('<style>body { font-family: system-ui, sans-serif; padding: 24px; color: #0f172a; } table { width: 100%; border-collapse: collapse; margin-top: 16px; font-size: 13px; } th, td { border: 1px solid #cbd5e1; padding: 10px 12px; text-align: left; } th { background: #f8fafc; font-weight: bold; }</style></head><body>');
    printWindow.document.write('<h2 style="margin-bottom: 20px; border-bottom: 2px solid #6d28d9; padding-bottom: 8px;">Chi tiết Tồn Kho - ' + nameHeader + '</h2>');
    printWindow.document.write(printContent);
    printWindow.document.write('</body></html>');
    printWindow.document.close();
    printWindow.focus();
    setTimeout(() => { printWindow.print(); printWindow.close(); }, 250);
  };

  // 4. Modal Chi tiết Nhập Xuất Tồn (NXT)
  window.openNXTDetailModal = function(productId) {
    const modal = document.getElementById('nxtDetailModal');
    if (!modal) return;

    modal.style.display = 'flex';
    setTimeout(() => {
      modal.style.opacity = '1';
      const card = modal.querySelector('.nxt-modal-card');
      if (card) card.style.transform = 'scale(1)';
    }, 10);

    const startDate = document.getElementById('startDate') ? document.getElementById('startDate').value : '';
    const endDate = document.getElementById('endDate') ? document.getElementById('endDate').value : '';
    let url = '${pageContext.request.contextPath}/manage/reports?action=apiNXTDetail&productId=' + productId +
              '&startDate=' + encodeURIComponent(startDate) + '&endDate=' + encodeURIComponent(endDate);

    fetch(url)
      .then(response => {
        if (!response.ok) throw new Error('HTTP error ' + response.status);
        return response.json();
      })
      .then(data => {
        if (data.error) {
          alert('Lỗi: ' + data.error);
          closeNXTDetailModal();
          return;
        }

        document.getElementById('modalNXTProductNameHeader').innerText = data.productName || '-';
        document.getElementById('modalNXTSKU').innerText = data.sku || '-';
        document.getElementById('modalNXTProductName').innerText = data.productName || '-';
        document.getElementById('modalNXTBrandLine').innerText = (data.brandName || '-') + ' / ' + (data.productLineName || '-');
        document.getElementById('modalNXTUnit').innerText = data.unit || '-';
        document.getElementById('modalNXTPrice').innerText = formatCurrency(data.price);
        document.getElementById('modalNXTDateRange').innerText = (data.startDate || '-') + '  ➔  ' + (data.endDate || '-');

        document.getElementById('modalNXTBeginningQty').innerText = (data.beginningQty || 0).toLocaleString();
        document.getElementById('modalNXTInboundQty').innerText = '+' + (data.inboundQty || 0).toLocaleString();
        document.getElementById('modalNXTOutboundQty').innerText = '-' + (data.outboundQty || 0).toLocaleString();
        document.getElementById('modalNXTEndingQty').innerText = (data.endingQty || 0).toLocaleString();
        document.getElementById('modalNXTEndingVal').innerText = formatCurrency(data.endingVal);

        const txs = data.transactions || [];
        document.getElementById('modalNXTTransactionCountSummary').innerText = txs.length + ' giao dịch trong kỳ';

        const tbody = document.getElementById('modalNXTTransactionsTableBody');
        tbody.innerHTML = '';
        if (txs.length === 0) {
          tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: #94a3b8; padding: 20px;">Không có giao dịch nhập/xuất kho nào trong kỳ báo cáo này.</td></tr>';
        } else {
          txs.forEach((tx, idx) => {
            const tr = document.createElement('tr');
            tr.style.borderBottom = '1px solid #f1f5f9';
            const isInbound = (tx.type === 'NHẬP KHO');
            const typeBadge = isInbound ?
              '<span class="report-badge" style="background: rgba(16, 185, 129, 0.12); color: #10b981; font-weight: 800; padding: 4px 10px; border-radius: 6px; font-size: 11px;">+ NHẬP KHO</span>' :
              '<span class="report-badge" style="background: rgba(239, 68, 68, 0.12); color: #ef4444; font-weight: 800; padding: 4px 10px; border-radius: 6px; font-size: 11px;">- XUẤT KHO</span>';

            tr.innerHTML = 
              '<td style="padding: 12px 14px; text-align: center; color: #64748b; font-weight: 600;">' + (idx + 1) + '</td>' +
              '<td style="padding: 12px 14px;">' + typeBadge + '</td>' +
              '<td style="padding: 12px 14px; font-weight: 800; font-family: monospace; color: #0f172a;">#' + (tx.code || '-') + '</td>' +
              '<td style="padding: 12px 14px; color: #475569;">' + (tx.createdAt || '-') + '</td>' +
              '<td style="padding: 12px 14px; font-weight: 600; color: #334155;">' + (tx.partnerName || '-') + '</td>' +
              '<td style="padding: 12px 14px; text-align: right; font-weight: 800; color: ' + (isInbound ? '#16a34a' : '#dc2626') + ';">' + (isInbound ? '+' : '-') + tx.quantity + '</td>' +
              '<td style="padding: 12px 14px; text-align: center; color: #64748b; font-weight: 600;">' + (tx.status || '-') + '</td>';
            tbody.appendChild(tr);
          });
        }
      })
      .catch(err => {
        console.error(err);
        alert('Đã xảy ra lỗi khi tải chi tiết nhập xuất tồn.');
        closeNXTDetailModal();
      });
  };

  window.closeNXTDetailModal = function() {
    const modal = document.getElementById('nxtDetailModal');
    if (!modal) return;
    modal.style.opacity = '0';
    const card = modal.querySelector('.nxt-modal-card');
    if (card) card.style.transform = 'scale(0.95)';
    setTimeout(() => { modal.style.display = 'none'; }, 250);
  };

  window.printNXTDetailModal = function() {
    const printContent = document.getElementById('nxtModalBody').innerHTML;
    const nameHeader = document.getElementById('modalNXTProductNameHeader').innerText;
    const printWindow = window.open('', '_blank', 'width=900,height=700');
    printWindow.document.write('<html><head><title>Chi tiết Nhập Xuất Tồn - ' + nameHeader + '</title>');
    printWindow.document.write('<style>body { font-family: system-ui, sans-serif; padding: 24px; color: #0f172a; } table { width: 100%; border-collapse: collapse; margin-top: 16px; font-size: 13px; } th, td { border: 1px solid #cbd5e1; padding: 10px 12px; text-align: left; } th { background: #f8fafc; font-weight: bold; }</style></head><body>');
    printWindow.document.write('<h2 style="margin-bottom: 20px; border-bottom: 2px solid #4f46e5; padding-bottom: 8px;">Chi tiết Nhập Xuất Tồn - ' + nameHeader + '</h2>');
    printWindow.document.write(printContent);
    printWindow.document.write('</body></html>');
    printWindow.document.close();
    printWindow.focus();
    setTimeout(() => { printWindow.print(); printWindow.close(); }, 250);
  };
</script>

<!-- Modal Chi tiết Phiếu Nhập kho HTML -->
<div id="receiptDetailModal" class="receipt-modal-backdrop" style="display: none; position: fixed; inset: 0; z-index: 9999; background: rgba(15, 23, 42, 0.65); backdrop-filter: blur(4px); align-items: center; justify-content: center; opacity: 0; transition: opacity 0.25s ease;">
  <div class="receipt-modal-card" style="background: #ffffff; width: 95%; max-width: 920px; max-height: 90vh; border-radius: 16px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); display: flex; flex-direction: column; overflow: hidden; transform: scale(0.95); transition: transform 0.25s ease;">
    <div style="display: flex; align-items: center; justify-content: space-between; padding: 20px 24px; border-bottom: 1px solid var(--card-border, #e2e8f0); background: #ffffff;">
      <div style="display: flex; align-items: center; gap: 10px; font-size: 18px; font-weight: 700; color: #0f172a;">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <polyline points="19 12 12 19 5 12"></polyline>
        </svg>
        <span>Chi tiết Phiếu Nhập kho: <span id="modalReceiptCodeHeader" style="color: #2563eb; font-family: monospace;">#PN-00000000</span></span>
      </div>
      <button type="button" onclick="closeReceiptDetailModal()" style="border: none; background: #f1f5f9; color: #64748b; width: 32px; height: 32px; border-radius: 8px; font-size: 18px; font-weight: 700; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.2s;" onmouseover="this.style.background='#e2e8f0'; this.style.color='#0f172a';" onmouseout="this.style.background='#f1f5f9'; this.style.color='#64748b';">✕</button>
    </div>
    <div id="receiptModalBody" style="padding: 24px; overflow-y: auto; flex: 1;">
      <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px 24px; margin-bottom: 24px;">
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px 24px;">
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">MÃ PHIẾU</div>
            <div id="modalReceiptCode" style="font-size: 14px; font-weight: 800; color: #0f172a; font-family: monospace;">#PN-00000000</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">NGÀY NHẬP</div>
            <div id="modalCreatedAt" style="font-size: 14px; font-weight: 700; color: #0f172a;">-</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">NHÀ CUNG CẤP</div>
            <div id="modalSupplierName" style="font-size: 14px; font-weight: 700; color: #0f172a;">-</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">NGƯỜI LẬP</div>
            <div id="modalCreatorName" style="font-size: 14px; font-weight: 700; color: #0f172a;">-</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">TRẠNG THÁI</div>
            <div id="modalStatusContainer">
              <span class="report-badge" style="background: rgba(59, 130, 246, 0.12); color: #2563eb; font-weight: 800; padding: 4px 10px; border-radius: 6px; font-size: 12px; display: inline-block;">-</span>
            </div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">TỔNG GIÁ TRỊ NHẬP</div>
            <div id="modalTotalVal" style="font-size: 17px; font-weight: 800; color: #2563eb;">0 đ</div>
          </div>
        </div>
      </div>
      <div>
        <h4 style="font-size: 15px; font-weight: 700; color: #0f172a; margin: 0 0 14px 0;">Danh sách sản phẩm nhập (<span id="modalProductCountSummary">0 mặt hàng</span>)</h4>
        <div style="overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 10px;">
          <table style="width: 100%; border-collapse: collapse; font-size: 13px; text-align: left;">
            <thead>
              <tr style="background: #f8fafc; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 700;">
                <th style="padding: 12px 14px; text-align: center; width: 45px;">STT</th>
                <th style="padding: 12px 14px;">SKU</th>
                <th style="padding: 12px 14px;">Tên sản phẩm</th>
                <th style="padding: 12px 14px;">Đơn vị</th>
                <th style="padding: 12px 14px;">Mã lô (Batch)</th>
                <th style="padding: 12px 14px; text-align: center;">Mã vạch (Barcode)</th>
                <th style="padding: 12px 14px; text-align: right;">Số lượng</th>
                <th style="padding: 12px 14px; text-align: right;">Đơn giá</th>
                <th style="padding: 12px 14px; text-align: right;">Thành tiền</th>
              </tr>
            </thead>
            <tbody id="modalDetailsTableBody"></tbody>
          </table>
        </div>
      </div>
      <div style="margin-top: 24px; padding-top: 20px; border-top: 1px solid #f1f5f9;">
        <h4 style="font-size: 14px; font-weight: 700; color: #0f172a; margin: 0 0 10px 0;">Ảnh hóa đơn yêu cầu:</h4>
        <div id="modalInvoiceImageContainer"></div>
      </div>
    </div>
    <div style="display: flex; align-items: center; justify-content: space-between; padding: 16px 24px; border-top: 1px solid #e2e8f0; background: #ffffff;">
      <button type="button" onclick="printReceiptDetailModal()" style="display: inline-flex; align-items: center; gap: 8px; padding: 10px 18px; border: 1.5px solid #cbd5e1; background: #ffffff; color: #334155; border-radius: 10px; font-size: 14px; font-weight: 700; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background='#f8fafc';" onmouseout="this.style.background='#ffffff';">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
        In chi tiết
      </button>
      <div style="display: flex; align-items: center; gap: 12px;">
        <button type="button" onclick="closeReceiptDetailModal()" style="padding: 10px 20px; border: 1.5px solid #cbd5e1; background: #ffffff; color: #334155; border-radius: 10px; font-size: 14px; font-weight: 700; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background='#f8fafc';" onmouseout="this.style.background='#ffffff';">Đóng</button>
        <a id="btnGoToOriginalPage" href="#" class="premium-btn-primary" style="display: inline-flex; align-items: center; justify-content: center; height: 42px; padding: 0 20px; background: #2563eb; color: #ffffff; text-decoration: none; border-radius: 10px; font-size: 14px; font-weight: 700; transition: all 0.2s;">Đến trang quản lý gốc</a>
      </div>
    </div>
  </div>
</div>

<!-- Modal Chi tiết Phiếu Xuất kho HTML -->
<div id="shipmentDetailModal" class="shipment-modal-backdrop" style="display: none; position: fixed; inset: 0; z-index: 9999; background: rgba(15, 23, 42, 0.65); backdrop-filter: blur(4px); align-items: center; justify-content: center; opacity: 0; transition: opacity 0.25s ease;">
  <div class="shipment-modal-card" style="background: #ffffff; width: 95%; max-width: 920px; max-height: 90vh; border-radius: 16px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); display: flex; flex-direction: column; overflow: hidden; transform: scale(0.95); transition: transform 0.25s ease;">
    <div style="display: flex; align-items: center; justify-content: space-between; padding: 20px 24px; border-bottom: 1px solid var(--card-border, #e2e8f0); background: #ffffff;">
      <div style="display: flex; align-items: center; gap: 10px; font-size: 18px; font-weight: 700; color: #0f172a;">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <line x1="12" y1="19" x2="12" y2="5"></line>
          <polyline points="5 12 12 5 19 12"></polyline>
        </svg>
        <span>Chi tiết Phiếu Xuất kho: <span id="modalShipmentCodeHeader" style="color: #10b981; font-family: monospace;">#PX-00000000</span></span>
      </div>
      <button type="button" onclick="closeShipmentDetailModal()" style="border: none; background: #f1f5f9; color: #64748b; width: 32px; height: 32px; border-radius: 8px; font-size: 18px; font-weight: 700; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.2s;" onmouseover="this.style.background='#e2e8f0'; this.style.color='#0f172a';" onmouseout="this.style.background='#f1f5f9'; this.style.color='#64748b';">✕</button>
    </div>
    <div id="shipmentModalBody" style="padding: 24px; overflow-y: auto; flex: 1;">
      <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px 24px; margin-bottom: 24px;">
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px 24px;">
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">MÃ PHIẾU</div>
            <div id="modalShipmentCode" style="font-size: 14px; font-weight: 800; color: #0f172a; font-family: monospace;">#PX-00000000</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">NGÀY XUẤT</div>
            <div id="modalShipmentCreatedAt" style="font-size: 14px; font-weight: 700; color: #0f172a;">-</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">ĐỊA ĐIỂM NHẬN</div>
            <div id="modalDestination" style="font-size: 14px; font-weight: 700; color: #0f172a;">-</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">NGƯỜI LẬP</div>
            <div id="modalShipmentCreatorName" style="font-size: 14px; font-weight: 700; color: #0f172a;">-</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">TRẠNG THÁI</div>
            <div id="modalShipmentStatusContainer">
              <span class="report-badge" style="background: rgba(16, 185, 129, 0.12); color: #10b981; font-weight: 800; padding: 4px 10px; border-radius: 6px; font-size: 12px; display: inline-block;">-</span>
            </div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">TỔNG GIÁ TRỊ XUẤT</div>
            <div id="modalShipmentTotalVal" style="font-size: 17px; font-weight: 800; color: #10b981;">0 đ</div>
          </div>
        </div>
      </div>
      <div>
        <h4 style="font-size: 15px; font-weight: 700; color: #0f172a; margin: 0 0 14px 0;">Danh sách sản phẩm xuất (<span id="modalShipmentProductCountSummary">0 mặt hàng</span>)</h4>
        <div style="overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 10px;">
          <table style="width: 100%; border-collapse: collapse; font-size: 13px; text-align: left;">
            <thead>
              <tr style="background: #f8fafc; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 700;">
                <th style="padding: 12px 14px; text-align: center; width: 45px;">STT</th>
                <th style="padding: 12px 14px;">SKU</th>
                <th style="padding: 12px 14px;">Tên sản phẩm</th>
                <th style="padding: 12px 14px;">Đơn vị</th>
                <th style="padding: 12px 14px;">Mã lô (Batch)</th>
                <th style="padding: 12px 14px; text-align: center;">Mã vạch (Barcode)</th>
                <th style="padding: 12px 14px; text-align: right;">Số lượng</th>
                <th style="padding: 12px 14px; text-align: right;">Đơn giá</th>
                <th style="padding: 12px 14px; text-align: right;">Thành tiền</th>
              </tr>
            </thead>
            <tbody id="modalShipmentDetailsTableBody"></tbody>
          </table>
        </div>
      </div>
      <div style="margin-top: 24px; padding-top: 20px; border-top: 1px solid #f1f5f9;">
        <h4 style="font-size: 14px; font-weight: 700; color: #0f172a; margin: 0 0 6px 0;">Ghi chú xuất kho:</h4>
        <div id="modalShipmentNotes" style="font-size: 13px; color: #475569; font-style: italic;">Không có ghi chú</div>
      </div>
    </div>
    <div style="display: flex; align-items: center; justify-content: space-between; padding: 16px 24px; border-top: 1px solid #e2e8f0; background: #ffffff;">
      <button type="button" onclick="printShipmentDetailModal()" style="display: inline-flex; align-items: center; gap: 8px; padding: 10px 18px; border: 1.5px solid #cbd5e1; background: #ffffff; color: #334155; border-radius: 10px; font-size: 14px; font-weight: 700; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background='#f8fafc';" onmouseout="this.style.background='#ffffff';">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
        In chi tiết
      </button>
      <div style="display: flex; align-items: center; gap: 12px;">
        <button type="button" onclick="closeShipmentDetailModal()" style="padding: 10px 20px; border: 1.5px solid #cbd5e1; background: #ffffff; color: #334155; border-radius: 10px; font-size: 14px; font-weight: 700; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background='#f8fafc';" onmouseout="this.style.background='#ffffff';">Đóng</button>
        <a id="btnGoToOriginalShipmentPage" href="#" class="premium-btn-primary" style="display: inline-flex; align-items: center; justify-content: center; height: 42px; padding: 0 20px; background: #10b981; color: #ffffff; text-decoration: none; border-radius: 10px; font-size: 14px; font-weight: 700; transition: all 0.2s;">Đến trang quản lý gốc</a>
      </div>
    </div>
  </div>
</div>

<!-- Modal Chi tiết Tồn kho HTML -->
<div id="inventoryDetailModal" class="inventory-modal-backdrop" style="display: none; position: fixed; inset: 0; z-index: 9999; background: rgba(15, 23, 42, 0.65); backdrop-filter: blur(4px); align-items: center; justify-content: center; opacity: 0; transition: opacity 0.25s ease;">
  <div class="inventory-modal-card" style="background: #ffffff; width: 95%; max-width: 900px; max-height: 90vh; border-radius: 16px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); display: flex; flex-direction: column; overflow: hidden; transform: scale(0.95); transition: transform 0.25s ease;">
    <div style="display: flex; align-items: center; justify-content: space-between; padding: 20px 24px; border-bottom: 1px solid var(--card-border, #e2e8f0); background: #ffffff;">
      <div style="display: flex; align-items: center; gap: 10px; font-size: 18px; font-weight: 700; color: #0f172a;">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#6d28d9" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
        </svg>
        <span>Chi tiết Tồn kho: <span id="modalInvProductNameHeader" style="color: #6d28d9;">-</span></span>
      </div>
      <button type="button" onclick="closeInventoryDetailModal()" style="border: none; background: #f1f5f9; color: #64748b; width: 32px; height: 32px; border-radius: 8px; font-size: 18px; font-weight: 700; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.2s;" onmouseover="this.style.background='#e2e8f0'; this.style.color='#0f172a';" onmouseout="this.style.background='#f1f5f9'; this.style.color='#64748b';">✕</button>
    </div>
    <div id="inventoryModalBody" style="padding: 24px; overflow-y: auto; flex: 1;">
      <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 20px 24px; margin-bottom: 24px;">
        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px 24px;">
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">MÃ SKU</div>
            <div id="modalInvSKU" style="font-size: 14px; font-weight: 800; color: #0f172a; font-family: monospace;">-</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">TÊN SẢN PHẨM</div>
            <div id="modalInvProductName" style="font-size: 14px; font-weight: 700; color: #0f172a;">-</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">HÃNG / DÒNG SP</div>
            <div id="modalInvBrandLine" style="font-size: 14px; font-weight: 700; color: #0f172a;">-</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">ĐƠN VỊ TÍNH</div>
            <div id="modalInvUnit" style="font-size: 14px; font-weight: 700; color: #0f172a;">-</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">ĐƠN GIÁ</div>
            <div id="modalInvPrice" style="font-size: 14px; font-weight: 700; color: #0f172a;">0 đ</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">MÃ LÔ (BATCH CODE)</div>
            <div id="modalInvBatchCode" style="font-size: 14px; font-weight: 800; color: #6d28d9; font-family: monospace;">-</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">LƯỢNG TỒN THỰC TẾ</div>
            <div id="modalInvQtyInStock" style="font-size: 18px; font-weight: 800; color: #0f172a;">0</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">ĐỊNH MỨC TỐI THIỂU</div>
            <div id="modalInvMinStock" style="font-size: 14px; font-weight: 700; color: #64748b;">0</div>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">TRẠNG THÁI CẢNH BÁO</div>
            <div id="modalInvStatusContainer">
              <span class="report-badge" style="background: rgba(16, 185, 129, 0.12); color: #10b981; font-weight: 800; padding: 4px 10px; border-radius: 6px; font-size: 12px; display: inline-block;">-</span>
            </div>
          </div>
          <div style="grid-column: span 3; border-top: 1px solid #e2e8f0; padding-top: 12px; margin-top: 4px; display: flex; align-items: center; justify-content: space-between;">
            <div style="font-size: 12px; font-weight: 700; color: #64748b; text-transform: uppercase; letter-spacing: 0.05em;">TỔNG GIÁ TRỊ TỒN KHO:</div>
            <div id="modalInvTotalVal" style="font-size: 18px; font-weight: 800; color: #6d28d9;">0 đ</div>
          </div>
        </div>
      </div>
      <div>
        <h4 style="font-size: 15px; font-weight: 700; color: #0f172a; margin: 0 0 12px 0;">Danh sách mã vạch sản phẩm (Barcodes) đang lưu trong kho:</h4>
        <div id="modalInvBarcodeContainer" style="padding: 16px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; display: flex; justify-content: center;"></div>
      </div>
    </div>
    <div style="display: flex; align-items: center; justify-content: space-between; padding: 16px 24px; border-top: 1px solid #e2e8f0; background: #ffffff;">
      <button type="button" onclick="printInventoryDetailModal()" style="display: inline-flex; align-items: center; gap: 8px; padding: 10px 18px; border: 1.5px solid #cbd5e1; background: #ffffff; color: #334155; border-radius: 10px; font-size: 14px; font-weight: 700; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background='#f8fafc';" onmouseout="this.style.background='#ffffff';">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
        In chi tiết
      </button>
      <div style="display: flex; align-items: center; gap: 12px;">
        <button type="button" onclick="closeInventoryDetailModal()" style="padding: 10px 20px; border: 1.5px solid #cbd5e1; background: #ffffff; color: #334155; border-radius: 10px; font-size: 14px; font-weight: 700; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background='#f8fafc';" onmouseout="this.style.background='#ffffff';">Đóng</button>
        <a id="btnGoToOriginalInvPage" href="#" class="premium-btn-primary" style="display: inline-flex; align-items: center; justify-content: center; height: 42px; padding: 0 20px; background: #6d28d9; color: #ffffff; text-decoration: none; border-radius: 10px; font-size: 14px; font-weight: 700; transition: all 0.2s;">Đến trang quản lý tồn kho</a>
      </div>
    </div>
  </div>
</div>

<!-- Modal Chi tiết Nhập Xuất Tồn HTML -->
<div id="nxtDetailModal" class="nxt-modal-backdrop" style="display: none; position: fixed; inset: 0; z-index: 9999; background: rgba(15, 23, 42, 0.65); backdrop-filter: blur(4px); align-items: center; justify-content: center; opacity: 0; transition: opacity 0.25s ease;">
  <div class="nxt-modal-card" style="background: #ffffff; width: 95%; max-width: 950px; max-height: 90vh; border-radius: 16px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); display: flex; flex-direction: column; overflow: hidden; transform: scale(0.95); transition: transform 0.25s ease;">
    <div style="display: flex; align-items: center; justify-content: space-between; padding: 20px 24px; border-bottom: 1px solid var(--card-border, #e2e8f0); background: #ffffff;">
      <div style="display: flex; align-items: center; gap: 10px; font-size: 18px; font-weight: 700; color: #0f172a;">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#4f46e5" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <line x1="12" y1="1" x2="12" y2="23"></line>
          <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
        </svg>
        <span>Chi tiết Nhập Xuất Tồn: <span id="modalNXTProductNameHeader" style="color: #4f46e5;">-</span></span>
      </div>
      <button type="button" onclick="closeNXTDetailModal()" style="border: none; background: #f1f5f9; color: #64748b; width: 32px; height: 32px; border-radius: 8px; font-size: 18px; font-weight: 700; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.2s;" onmouseover="this.style.background='#e2e8f0'; this.style.color='#0f172a';" onmouseout="this.style.background='#f1f5f9'; this.style.color='#64748b';">✕</button>
    </div>
    <div id="nxtModalBody" style="padding: 24px; overflow-y: auto; flex: 1;">
      <!-- Product header bar -->
      <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; padding: 16px 20px; margin-bottom: 20px; display: grid; grid-template-columns: repeat(5, 1fr); gap: 16px;">
        <div>
          <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase;">SKU</div>
          <div id="modalNXTSKU" style="font-size: 13px; font-weight: 800; color: #0f172a; font-family: monospace;">-</div>
        </div>
        <div>
          <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase;">TÊN SẢN PHẨM</div>
          <div id="modalNXTProductName" style="font-size: 13px; font-weight: 700; color: #0f172a;">-</div>
        </div>
        <div>
          <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase;">HÃNG / DÒNG</div>
          <div id="modalNXTBrandLine" style="font-size: 13px; font-weight: 700; color: #0f172a;">-</div>
        </div>
        <div>
          <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase;">ĐƠN GIÁ</div>
          <div id="modalNXTPrice" style="font-size: 13px; font-weight: 700; color: #0f172a;">0 đ</div>
        </div>
        <div>
          <div style="font-size: 11px; font-weight: 700; color: #64748b; text-transform: uppercase;">KỲ BÁO CÁO</div>
          <div id="modalNXTDateRange" style="font-size: 12px; font-weight: 700; color: #4f46e5;">-</div>
        </div>
      </div>

      <!-- NXT summary cards -->
      <div style="display: grid; grid-template-columns: repeat(5, 1fr); gap: 14px; margin-bottom: 24px;">
        <div style="background: #eff6ff; border: 1.5px solid #bfdbfe; border-radius: 10px; padding: 14px; text-align: center;">
          <div style="font-size: 11px; font-weight: 700; color: #2563eb; text-transform: uppercase;">TỒN ĐẦU KỲ</div>
          <div id="modalNXTBeginningQty" style="font-size: 20px; font-weight: 800; color: #1e40af; margin-top: 4px;">0</div>
        </div>
        <div style="background: #f0fdf4; border: 1.5px solid #bbf7d0; border-radius: 10px; padding: 14px; text-align: center;">
          <div style="font-size: 11px; font-weight: 700; color: #16a34a; text-transform: uppercase;">NHẬP TRONG KỲ</div>
          <div id="modalNXTInboundQty" style="font-size: 20px; font-weight: 800; color: #15803d; margin-top: 4px;">+0</div>
        </div>
        <div style="background: #fef2f2; border: 1.5px solid #fecaca; border-radius: 10px; padding: 14px; text-align: center;">
          <div style="font-size: 11px; font-weight: 700; color: #dc2626; text-transform: uppercase;">XUẤT TRONG KỲ</div>
          <div id="modalNXTOutboundQty" style="font-size: 20px; font-weight: 800; color: #b91c1c; margin-top: 4px;">-0</div>
        </div>
        <div style="background: #faf5ff; border: 1.5px solid #e9d5ff; border-radius: 10px; padding: 14px; text-align: center;">
          <div style="font-size: 11px; font-weight: 700; color: #7c3aed; text-transform: uppercase;">TỒN CUỐI KỲ</div>
          <div id="modalNXTEndingQty" style="font-size: 20px; font-weight: 800; color: #6d28d9; margin-top: 4px;">0</div>
        </div>
        <div style="background: #f8fafc; border: 1.5px solid #cbd5e1; border-radius: 10px; padding: 14px; text-align: center;">
          <div style="font-size: 11px; font-weight: 700; color: #475569; text-transform: uppercase;">TRỊ GIÁ TỒN CUỐI</div>
          <div id="modalNXTEndingVal" style="font-size: 15px; font-weight: 800; color: #4f46e5; margin-top: 6px;">0 đ</div>
        </div>
      </div>

      <!-- Transaction history table -->
      <div>
        <h4 style="font-size: 15px; font-weight: 700; color: #0f172a; margin: 0 0 14px 0;">Lịch sử phát sinh Nhập / Xuất kho (<span id="modalNXTTransactionCountSummary">0 giao dịch</span>)</h4>
        <div style="overflow-x: auto; border: 1px solid #e2e8f0; border-radius: 10px;">
          <table style="width: 100%; border-collapse: collapse; font-size: 13px; text-align: left;">
            <thead>
              <tr style="background: #f8fafc; border-bottom: 2px solid #e2e8f0; color: #475569; font-weight: 700;">
                <th style="padding: 12px 14px; text-align: center; width: 45px;">STT</th>
                <th style="padding: 12px 14px;">Loại giao dịch</th>
                <th style="padding: 12px 14px;">Mã phiếu</th>
                <th style="padding: 12px 14px;">Ngày phát sinh</th>
                <th style="padding: 12px 14px;">Đối tác (NCC / Điểm nhận)</th>
                <th style="padding: 12px 14px; text-align: right;">Số lượng phát sinh</th>
                <th style="padding: 12px 14px; text-align: center;">Trạng thái</th>
              </tr>
            </thead>
            <tbody id="modalNXTTransactionsTableBody"></tbody>
          </table>
        </div>
      </div>
    </div>
    <div style="display: flex; align-items: center; justify-content: space-between; padding: 16px 24px; border-top: 1px solid #e2e8f0; background: #ffffff;">
      <button type="button" onclick="printNXTDetailModal()" style="display: inline-flex; align-items: center; gap: 8px; padding: 10px 18px; border: 1.5px solid #cbd5e1; background: #ffffff; color: #334155; border-radius: 10px; font-size: 14px; font-weight: 700; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background='#f8fafc';" onmouseout="this.style.background='#ffffff';">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
        In chi tiết
      </button>
      <button type="button" onclick="closeNXTDetailModal()" style="padding: 10px 24px; border: 1.5px solid #cbd5e1; background: #ffffff; color: #334155; border-radius: 10px; font-size: 14px; font-weight: 700; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background='#f8fafc';" onmouseout="this.style.background='#ffffff';">Đóng</button>
    </div>
  </div>
</div>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
