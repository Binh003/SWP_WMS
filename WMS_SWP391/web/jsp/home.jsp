<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Bảng điều khiển" scope="request"/>
<c:set var="activePage" value="home" scope="request"/>
<jsp:include page="includes/dashboard-layout-start.jsp"/>

<section class="hero-panel">
  <div class="hero-panel__content">
    <h1>Quản lý xuất nhập kho nhanh, chính xác, minh bạch</h1>
    <p>Hệ thống Inventory Intelligence giúp tối ưu hóa luồng hàng hóa.</p>
  </div>
</section>

<section class="stats-grid">
  <article class="stat-card stat-card--good">
    <div><p>Tổng tồn kho</p><strong>5,240</strong><span>+2.5% so với tháng trước</span></div>
  </article>
  <article class="stat-card stat-card--danger">
    <div><p>Hàng sắp hết</p><strong>12</strong><span>Cần nhập hàng ngay</span></div>
  </article>
  <article class="stat-card stat-card--neutral">
    <div><p>Giao dịch hôm nay</p><strong>+85</strong><span>Cập nhật: 5 phút trước</span></div>
  </article>
</section>

<jsp:include page="includes/dashboard-layout-end.jsp"/>
