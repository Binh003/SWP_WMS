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
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="7" style="text-align: center; color: #64748b; padding: 24px;">Không tìm thấy lịch sử nhập kho nào phù hợp với bộ lọc ngày đã chọn.</td>
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
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="7" style="text-align: center; color: #64748b; padding: 24px;">Không tìm thấy lịch sử xuất kho nào phù hợp với bộ lọc ngày đã chọn.</td>
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
                <th>Mã vạch (Barcode)</th>
                <th>Mã lô (Batch)</th>
                <th>SKU</th>
                <th>Tên sản phẩm</th>
                <th style="text-align: right;">Đơn giá</th>
                <th style="text-align: right;">Lượng tồn kho</th>
                <th style="text-align: right;">Định mức tối thiểu</th>
                <th>Trạng thái</th>
              </tr>
            </thead>
            <tbody>
              <c:choose>
                <c:when test="${not empty inventoryReport}">
                  <c:forEach var="item" items="${inventoryReport}">
                    <c:set var="isLow" value="${item.minStockLevel > 0 && item.quantityInStock <= item.minStockLevel}"/>
                    <tr>
                      <td><code><c:out value="${item.barcode}"/></code></td>
                      <td><code><c:out value="${item.batchCode}"/></code></td>
                      <td><c:out value="${item.sku}"/></td>
                      <td><strong><c:out value="${item.productName}"/></strong></td>
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
                    </tr>
                  </c:forEach>
                </c:when>
                <c:otherwise>
                  <tr>
                    <td colspan="10" style="text-align: center; color: #64748b; padding: 24px;">Không tìm thấy dữ liệu nào phù hợp với bộ lọc đã chọn.</td>
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
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
