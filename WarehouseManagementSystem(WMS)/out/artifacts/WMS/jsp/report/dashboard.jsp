<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
    gap: 30px;
  }
  
  /* Style cho các Card thống kê nhanh */
  .quick-stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
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
    font-size: 26px;
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
  
  /* Màu sắc của icon các card */
  .icon-blue { background: #eff6ff; color: #3b82f6; }
  .icon-green { background: #f0fdf4; color: #22c55e; }
  .icon-purple { background: #faf5ff; color: #a855f7; }
  .icon-red { background: #fef2f2; color: #ef4444; }
  .alert-pulse {
    animation: alert-glow 1.5s infinite alternate;
  }
  @keyframes alert-glow {
    from { box-shadow: 0 0 4px rgba(239, 68, 68, 0.2); }
    to { box-shadow: 0 0 16px rgba(239, 68, 68, 0.5); border-color: #f87171; }
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
  }
  .report-table tr:hover {
    background: #f8fafc;
  }
  .report-badge {
    padding: 4px 8px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 600;
  }
  .report-badge--danger {
    background: #fef2f2;
    color: #ef4444;
  }
</style>

<div class="report-container">
  
  <!-- Header của module -->
  <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
    <div>
      <h1 style="font-size: 24px; font-weight: 800; color: #0f172a; margin: 0;">Báo cáo phân tích kho hàng</h1>
      <p style="color: #64748b; margin: 4px 0 0; font-size: 14px;">Thống kê tổng quan dữ liệu tồn kho, nhập xuất và sản phẩm bán chạy.</p>
    </div>
    <div>
      <button onclick="window.print()" class="outline-danger-button" style="text-decoration: none; border-color: #cbd5e1; color: #475569; background: white; display: flex; align-items: center; gap: 6px; padding: 10px 16px; border-radius: 10px; font-weight: 600;">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="6 9 6 2 18 2 18 9"></polyline>
          <path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path>
          <rect x="6" y="14" width="12" height="8"></rect>
        </svg>
        In báo cáo
      </button>
    </div>
  </div>

  <!-- Row 1: Thẻ thống kê tổng quan -->
  <div class="quick-stats-grid">
    <!-- Tổng sản phẩm trong danh mục -->
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
    
    <!-- Tổng số lượng hàng trong kho -->
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
    
    <!-- Tổng giá trị kho hàng -->
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
    
    <!-- Cảnh báo hết hàng / Tồn kho thấp -->
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

  <!-- Row 2: Grid Biểu đồ -->
  <div class="charts-main-grid">
    <!-- Chart 1: Nhập vs Xuất theo tháng (Biểu đồ cột chồng hoặc so sánh) -->
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

    <!-- Chart 2: Cơ cấu giá trị tồn kho theo Hãng (Biểu đồ tròn) -->
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

  <!-- Row 3: Biểu đồ phụ & bảng dữ liệu -->
  <div class="charts-main-grid" style="grid-template-columns: 1fr 1.2fr;">
    <!-- Chart 3: Top 5 sản phẩm xuất nhiều nhất -->
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

    <!-- Bảng số liệu phụ lục -->
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
            <!-- Render động bằng JS dựa trên dữ liệu -->
          </tbody>
        </table>
      </div>
    </div>
  </div>

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

    // 2. Nạp dữ liệu từ backend sang Javascript array
    // Biểu đồ Nhập - Xuất theo tháng
    const months = [];
    const inboundValues = [];
    const outboundValues = [];
    <c:forEach var="item" items="${monthlyStats}">
      months.push('Tháng ${item.month}');
      inboundValues.push(${item.inboundValue});
      outboundValues.push(${item.outboundValue});
    </c:forEach>

    // Biểu đồ Cơ cấu Tồn kho theo Hãng
    const brandNames = [];
    const brandValuations = [];
    let totalValuationSum = 0;
    <c:forEach var="item" items="${brandValuation}">
      brandNames.push('${item.brandName}');
      brandValuations.push(${item.valuation});
      totalValuationSum += ${item.valuation};
    </c:forEach>

    // Biểu đồ Top 5 sản phẩm
    const topProductNames = [];
    const topProductQtys = [];
    <c:forEach var="item" items="${topMoving}">
      topProductNames.push('${item.sku} - ${item.productName}');
      topProductQtys.push(${item.quantity});
    </c:forEach>

    // 3. Đổ dữ liệu vào bảng phân bổ Hãng sản xuất
    const brandTableBody = document.getElementById("brandTableBody");
    if (brandTableBody && brandNames.length > 0) {
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
    } else if (brandTableBody) {
      brandTableBody.innerHTML = `<tr><td colspan="3" style="text-align: center; color: #94a3b8;">Chưa có dữ liệu tồn kho</td></tr>`;
    }

    // 4. Vẽ Biểu đồ 1: Nhập vs Xuất theo tháng (Biểu đồ Cột Nhóm)
    const ctxMonthly = document.getElementById('monthlyInboundOutboundChart').getContext('2d');
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

    // 5. Vẽ Biểu đồ 2: Cơ cấu Tồn kho theo Hãng (Biểu đồ Tròn/Doughnut)
    const ctxBrand = document.getElementById('brandValuationChart').getContext('2d');
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

    // 6. Vẽ Biểu đồ 3: Top 5 Sản phẩm xuất nhiều nhất (Biểu đồ ngang)
    const ctxTop = document.getElementById('topMovingProductsChart').getContext('2d');
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
        indexAxis: 'y', // Biến thành biểu đồ cột nằm ngang
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

  });
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
