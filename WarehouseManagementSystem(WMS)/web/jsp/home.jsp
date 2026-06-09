<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Bảng điều khiển" scope="request"/>
<c:set var="activePage" value="home" scope="request"/>
<jsp:include page="includes/dashboard-layout-start.jsp"/>

<section class="hero-panel">
  <div class="hero-panel__content">
    <h1>Quản lý nhập kho nhanh, chính xác, minh bạch</h1>
    <p>Hệ thống Inventory Intelligence giúp tối ưu hóa luồng hàng hóa và giảm thiểu sai sót vận hành lên đến 40%.</p>
  </div>
</section>

<section class="stats-grid">
  <article class="stat-card stat-card--good">
    <div>
      <p>Tổng tồn kho</p>
      <strong>5,240</strong>
      <span>+2.5% so với tháng trước</span>
    </div>
    <span class="stat-card__icon" aria-hidden="true">⛁</span>
  </article>
  <article class="stat-card stat-card--danger">
    <div>
      <p>Hàng sắp hết</p>
      <strong>12</strong>
      <span>Cần nhập hàng ngay</span>
    </div>
    <span class="stat-card__icon" aria-hidden="true">!</span>
  </article>
  <article class="stat-card stat-card--neutral">
    <div>
      <p>Giao dịch hôm nay</p>
      <strong>+85</strong>
      <span>Cập nhật: 5 phút trước</span>
    </div>
    <span class="stat-card__icon" aria-hidden="true">▦</span>
  </article>
</section>

<div class="dashboard-grid">
  <section class="quick-section">
    <div class="section-heading">
      <h2>Thao tác nhanh</h2>
    </div>

    <div class="quick-grid">
      <button class="quick-card" type="button"><span aria-hidden="true">⇣</span>Nhập kho</button>
      <button class="quick-card" type="button"><span aria-hidden="true">✓</span>Kiểm kho</button>
      <button class="quick-card" type="button"><span aria-hidden="true">+</span>Thêm SP</button>
    </div>
  </section>

  <section class="alert-panel">
    <div class="alert-panel__title">
      <span aria-hidden="true">!</span>
      <h2>Cảnh báo tồn kho thấp</h2>
    </div>

    <div class="stock-list">
      <div class="stock-item">
        <div>
          <span>iPhone 15 Pro</span>
          <strong style="color:#c9151b">5 / 50</strong>
        </div>
        <div class="progress" role="progressbar" aria-valuenow="10" aria-valuemin="0" aria-valuemax="100">
          <div class="progress__bar" style="width:10%;background:#c9151b"></div>
        </div>
      </div>
      <div class="stock-item">
        <div>
          <span>MacBook Pro M3</span>
          <strong style="color:#c9151b">2 / 20</strong>
        </div>
        <div class="progress" role="progressbar" aria-valuenow="10" aria-valuemin="0" aria-valuemax="100">
          <div class="progress__bar" style="width:10%;background:#c9151b"></div>
        </div>
      </div>
      <div class="stock-item">
        <div>
          <span>iPad Air 5</span>
          <strong style="color:#f97316">8 / 40</strong>
        </div>
        <div class="progress" role="progressbar" aria-valuenow="20" aria-valuemin="0" aria-valuemax="100">
          <div class="progress__bar" style="width:20%;background:#f97316"></div>
        </div>
      </div>
    </div>

    <button class="outline-danger-button" type="button">Lập phiếu nhập hàng ngay</button>
  </section>

  <section class="transactions-section">
    <div class="section-heading section-heading--split">
      <h2>Giao dịch gần đây</h2>
      <button type="button">Xem tất cả</button>
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
        <span class="transaction-badge transaction-badge--in">Nhập kho</span>
        <span>iPhone 15 Pro Max</span>
        <span>50</span>
        <span>10:45 AM</span>
      </div>

      <div class="transaction-row">
        <strong>#NK-8820</strong>
        <span class="transaction-badge transaction-badge--in">Nhập kho</span>
        <span>Samsung Galaxy S24</span>
        <span>30</span>
        <span>Hôm qua</span>
      </div>
    </div>
  </section>

  <section class="report-card">
    <div>
      <h2>Báo cáo tổng quan</h2>
      <p>Xem xu hướng nhập kho chi tiết theo tuần.</p>
      <button type="button">Mở báo cáo</button>
    </div>
    <div class="report-card__chart" aria-hidden="true">
      <span></span>
      <span></span>
      <span></span>
      <span></span>
      <span></span>
    </div>
  </section>
</div>

<jsp:include page="includes/dashboard-layout-end.jsp"/>
