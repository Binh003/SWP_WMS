<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Chi tiết Phiếu Xuất"/>
<c:set var="activePage" value="shipments" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<style>
@media print {
  .home-topbar, .home-sidebar, #openHistoryBtn, .subpage-header, .no-print, [style*="margin-bottom: 16px;"] {
    display: none !important;
  }
  
  body, .home-shell, .home-layout, .home-main, .subpage-container {
    background: #ffffff !important;
    padding: 0 !important;
    margin: 0 !important;
    border: none !important;
  }
  
  .print-section {
    border: none !important;
    box-shadow: none !important;
    padding: 0 !important;
    margin: 0 !important;
    background: #ffffff !important;
  }
}
</style>

<div class="subpage-container">
  <!-- Back link -->
  <div style="margin-bottom: 16px;">
    <a href="${pageContext.request.contextPath}/admin/shipments" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: #475569; font-size: 14px; font-weight: 500; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='#475569'">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
      Quay lại danh sách
    </a>
  </div>

  <div class="subpage-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-end;">
    <div>
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">Chi tiết Phiếu Xuất: <span style="font-family: monospace; color: var(--primary-color);">${shipment.shipmentCode}</span></h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Thông tin chi tiết về các sản phẩm đã xuất kho.</p>
    </div>
    <div style="display: flex; gap: 12px; align-items: center;">
      <button type="button" id="openHistoryBtn" class="premium-btn-secondary" style="display: inline-flex; align-items: center; justify-content: center; height: 40px; padding: 0 16px; font-weight: 600; cursor: pointer; gap: 6px; border: 1.5px solid var(--card-border); background: #ffffff; border-radius: 8px; font-size: 13px; color: var(--text-primary); transition: all 0.2s;" onmouseover="this.style.background='#f8fafc'; this.style.borderColor='var(--primary-color)';" onmouseout="this.style.background='#ffffff'; this.style.borderColor='var(--card-border)';">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
        Lịch sử cập nhật
      </button>
    </div>
  </div>

  <!-- Stepper -->
  <c:if test="${shipment.status != 'CANCELLED'}">
    <div class="premium-card" style="padding: 24px 32px; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; position: relative; overflow: hidden;">
      <!-- Connector Line Container -->
      <div style="position: absolute; left: 107px; right: 107px; top: 50%; height: 4px; transform: translateY(-50%); z-index: 1;">
        <!-- Background line -->
        <div style="width: 100%; height: 100%; background: #e2e8f0;"></div>
        <!-- Active line -->
        <div style="position: absolute; top: 0; left: 0; height: 100%; background: var(--primary-color); z-index: 2; transition: width 0.5s ease; width: <c:choose>
          <c:when test="${shipment.status == 'DRAFT' || shipment.status == 'PENDING' || shipment.status == 'APPROVED'}">0%</c:when>
          <c:when test="${shipment.status == 'PICKING'}">50%</c:when>
          <c:when test="${shipment.status == 'COMPLETED'}">100%</c:when>
        </c:choose>;"></div>
      </div>
      
      <!-- Steps -->
      <!-- Step 1: APPROVED -->
      <div style="z-index: 3; display: flex; flex-direction: column; align-items: center; gap: 8px; width: 150px; text-align: center; flex-shrink: 0;">
        <div style="width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;
          <c:choose>
            <c:when test="${shipment.status == 'PENDING' || shipment.status == 'DRAFT' || shipment.status == 'APPROVED'}">background: #d97706; color: #ffffff;</c:when>
            <c:otherwise>background: #10b981; color: #ffffff;</c:otherwise>
          </c:choose>">
          <c:choose>
            <c:when test="${shipment.status == 'PENDING' || shipment.status == 'DRAFT' || shipment.status == 'APPROVED'}">1</c:when>
            <c:otherwise>✓</c:otherwise>
          </c:choose>
        </div>
        <span style="font-size: 13px; font-weight: 600; color: ${shipment.status == 'PENDING' || shipment.status == 'DRAFT' || shipment.status == 'APPROVED' ? '#d97706' : 'var(--text-secondary)'};">Tạo phiếu xuất</span>
      </div>
      
      <!-- Step 2: PICKING -->
      <div style="z-index: 3; display: flex; flex-direction: column; align-items: center; gap: 8px; width: 150px; text-align: center; flex-shrink: 0;">
        <div style="width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;
          <c:choose>
            <c:when test="${shipment.status == 'PICKING'}">background: #a855f7; color: #ffffff;</c:when>
            <c:when test="${shipment.status == 'COMPLETED'}">background: #10b981; color: #ffffff;</c:when>
            <c:otherwise>background: #e2e8f0; color: var(--text-secondary);</c:otherwise>
          </c:choose>">
          <c:choose>
            <c:when test="${shipment.status == 'COMPLETED'}">✓</c:when>
            <c:otherwise>2</c:otherwise>
          </c:choose>
        </div>
        <span style="font-size: 13px; font-weight: 600; color: ${shipment.status == 'PICKING' ? '#a855f7' : 'var(--text-secondary)'};">Lấy & Đóng gói</span>
      </div>
      
      <!-- Step 3: COMPLETED -->
      <div style="z-index: 3; display: flex; flex-direction: column; align-items: center; gap: 8px; width: 150px; text-align: center; flex-shrink: 0;">
        <div style="width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;
          <c:choose>
            <c:when test="${shipment.status == 'COMPLETED'}">background: #10b981; color: #ffffff;</c:when>
            <c:otherwise>background: #e2e8f0; color: var(--text-secondary);</c:otherwise>
          </c:choose>">
          3
        </div>
        <span style="font-size: 13px; font-weight: 600; color: ${shipment.status == 'COMPLETED' ? '#10b981' : 'var(--text-secondary)'};">Xác nhận xuất kho</span>
      </div>
    </div>
  </c:if>
  
  <c:if test="${shipment.status == 'CANCELLED'}">
    <div class="premium-card" style="padding: 20px; margin-bottom: 24px; background: #fef2f2; border: 1.5px solid #fecaca; border-radius: 12px; display: flex; align-items: center; gap: 12px; color: #ef4444;">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink: 0;">
        <circle cx="12" cy="12" r="10"></circle>
        <line x1="15" y1="9" x2="9" y2="15"></line>
        <line x1="9" y1="9" x2="15" y2="15"></line>
      </svg>
      <div>
        <h4 style="margin: 0; font-size: 15px; font-weight: 700; color: #991b1b;">Yêu cầu xuất kho này đã bị Hủy</h4>
        <p style="margin: 4px 0 0 0; font-size: 13px; color: #b91c1c;">Phiếu xuất này không còn hiệu lực. Tồn kho đã được hoàn trả lại (nếu từng hoàn thành).</p>
      </div>
    </div>
  </c:if>

  <!-- Hidden status form (always available) -->
  <c:if test="${shipment.status != 'COMPLETED' && shipment.status != 'CANCELLED'}">
    <form action="${pageContext.request.contextPath}/admin/shipments" method="post" id="statusForm" enctype="multipart/form-data" style="display:none;">
      <input type="hidden" name="action" value="updateStatus"/>
      <input type="hidden" name="id" value="${shipment.id}"/>
      <input type="hidden" name="status" id="nextStatus" value=""/>
    </form>
  </c:if>

  <c:if test="${shipment.status == 'COMPLETED'}">
    <!-- Beautiful Print-Ready Goods Shipment Note Document -->
    <div class="premium-card print-section" style="padding: 40px; margin-bottom: 24px; background: #ffffff; border: 2px solid #cbd5e1; border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.05); position: relative; overflow: hidden;">
      
      <!-- Header: Title and Company Info -->
      <div style="border-bottom: 2px solid #cbd5e1; padding-bottom: 20px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-start;">
        <div>
          <h2 style="font-size: 26px; font-weight: 800; color: #1e293b; margin: 0; text-transform: uppercase; letter-spacing: 0.5px;">PHIẾU XUẤT KHO THÀNH CÔNG</h2>
          <p style="font-size: 13px; color: #64748b; margin: 4px 0 0 0; font-weight: 600;">Số phiếu: <span style="font-family: monospace; font-size: 14px; color: #0f172a; background: #f1f5f9; padding: 2px 6px; border-radius: 4px;">${shipment.shipmentCode}</span></p>
        </div>
        <div style="text-align: right;">
          <p style="font-size: 12px; color: #64748b; margin: 4px 0 0 0;">Ngày xuất kho: 
            <span style="font-weight: 600; color: #334155;">
              <c:choose>
                <c:when test="${not empty shipment.getShippedAt()}">
                  <fmt:formatDate value="${shipment.getShippedAt()}" pattern="dd/MM/yyyy HH:mm"/>
                </c:when>
                <c:otherwise>
                  <fmt:formatDate value="${shipment.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                </c:otherwise>
              </c:choose>
            </span>
          </p>
        </div>
      </div>

      <!-- Metadata Fields (Grid) -->
      <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-bottom: 30px; background: #f8fafc; padding: 20px; border-radius: 12px; border: 1px solid #e2e8f0;">
        <div>
          <div style="margin-bottom: 12px;">
            <span style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700; display: block;">Nơi nhận</span>
            <span style="font-size: 14px; font-weight: 700; color: #0f172a;">${shipment.destination}</span>
          </div>
          <div>
            <span style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700; display: block;">Người lập yêu cầu (Sales)</span>
            <span style="font-size: 14px; font-weight: 600; color: #334155;">${shipment.creator.fullName}</span>
          </div>
        </div>
        <div>
          <div>
            <span style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700; display: block;">Nhân viên xuất kho (Thủ kho)</span>
            <span style="font-size: 14px; font-weight: 600; color: #334155;">
              <c:choose>
                <c:when test="${not empty shipment.getWarehouseStaff()}">
                  ${shipment.getWarehouseStaff().fullName}
                </c:when>
                <c:otherwise>
                  <span style="color: #94a3b8; font-style: italic;">Chưa thực hiện</span>
                </c:otherwise>
              </c:choose>
            </span>
          </div>
        </div>
      </div>

      <!-- Product List Table -->
      <h3 style="font-size: 15px; font-weight: 700; color: #1e293b; margin: 0 0 12px 0; text-transform: uppercase;">Chi tiết danh sách hàng thực xuất</h3>
      <table style="width: 100%; border-collapse: collapse; margin-bottom: 30px; font-size: 13px;">
        <thead>
          <tr style="background: #f1f5f9; border-bottom: 2px solid #cbd5e1; text-align: left;">
            <th style="padding: 10px 12px; font-weight: 700; color: #475569;">#</th>
            <th style="padding: 10px 12px; font-weight: 700; color: #475569;">Mã sản phẩm</th>
            <th style="padding: 10px 12px; font-weight: 700; color: #475569;">Tên sản phẩm</th>
            <th style="padding: 10px 12px; font-weight: 700; color: #475569; text-align: right;">Đơn vị</th>
            <th style="padding: 10px 12px; font-weight: 700; color: #475569; text-align: right; width: 150px;">Số lượng thực xuất</th>
          </tr>
        </thead>
        <tbody>
          <c:set var="totalItemsDoc" value="0"/>
          <c:forEach var="detail" items="${shipment.details}" varStatus="status">
            <tr style="border-bottom: 1px solid #e2e8f0;">
              <td style="padding: 10px 12px; color: #64748b;">${status.index + 1}</td>
              <td style="padding: 10px 12px; font-family: monospace; font-weight: 600; color: #0f172a;">${detail.product.sku}</td>
              <td style="padding: 10px 12px; font-weight: 600; color: #334155;">${detail.product.name}</td>
              <td style="padding: 10px 12px; text-align: right; color: #64748b;">${detail.product.unit}</td>
              <td style="padding: 10px 12px; text-align: right; font-weight: 800; color: #ef4444; font-size: 14px;">-${detail.quantity}</td>
            </tr>
            <c:set var="totalItemsDoc" value="${totalItemsDoc + detail.quantity}"/>
          </c:forEach>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="4" style="text-align: right; padding: 12px; font-weight: 700; color: #475569;">Tổng số lượng xuất:</td>
            <td style="text-align: right; padding: 12px; font-weight: 800; font-size: 15px; color: #ef4444;">${totalItemsDoc}</td>
          </tr>
        </tfoot>
      </table>

      <!-- Evidence Images (Inside Document) -->
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; margin-bottom: 30px;">
        <c:if test="${not empty shipment.deliveryNoteImage}">
          <div>
            <h3 style="font-size: 14px; font-weight: 700; color: #1e293b; margin: 0 0 8px 0; text-transform: uppercase;">Biên bản bàn giao ký nhận</h3>
            <div style="border: 1px solid #cbd5e1; border-radius: 8px; padding: 4px; background: #ffffff; height: 160px; display: inline-flex; align-items: center; justify-content: center; cursor: pointer; overflow: hidden; max-width: 100%;" onclick="openLightbox('${pageContext.request.contextPath}${shipment.deliveryNoteImage}')">
              <img src="${pageContext.request.contextPath}${shipment.deliveryNoteImage}" alt="Biên bản giao hàng" style="max-width: 100%; max-height: 100%; object-fit: contain; border-radius: 4px;">
            </div>
          </div>
        </c:if>
        <c:if test="${not empty shipment.shippingImages}">
          <div>
            <h3 style="font-size: 14px; font-weight: 700; color: #1e293b; margin: 0 0 8px 0; text-transform: uppercase;">Ảnh bốc xếp hàng làm bằng chứng</h3>
            <div style="display: flex; gap: 8px; flex-wrap: wrap;">
              <c:forEach var="img" items="${shipment.shippingImagesList}">
                <div style="border: 1px solid #cbd5e1; border-radius: 8px; padding: 4px; background: #ffffff; width: 75px; height: 75px; display: flex; align-items: center; justify-content: center; cursor: pointer; overflow: hidden;" onclick="openLightbox('${pageContext.request.contextPath}${img}')">
                  <img src="${pageContext.request.contextPath}${img}" alt="Ảnh xếp xe" style="max-width: 100%; max-height: 100%; object-fit: contain; border-radius: 4px;">
                </div>
              </c:forEach>
            </div>
          </div>
        </c:if>
      </div>

      <!-- Signature section for print -->
      <div style="margin-top: 50px; display: flex; justify-content: space-around; text-align: center; font-size: 14px;">
        <div style="width: 200px;">
          <span style="font-weight: 700; display: block; margin-bottom: 60px; text-transform: uppercase; color: #475569;">Người lập phiếu</span>
          <span style="color: #64748b; font-size: 12px;">(Ký, ghi rõ họ tên)</span>
          <div style="margin-top: 15px; font-weight: 600; color: #0f172a;">${shipment.creator.fullName}</div>
        </div>
        <div style="width: 200px;">
          <span style="font-weight: 700; display: block; margin-bottom: 60px; text-transform: uppercase; color: #475569;">Nhân viên xuất kho (Thủ kho)</span>
          <span style="color: #64748b; font-size: 12px;">(Ký, ghi rõ họ tên)</span>
          <div style="margin-top: 15px; font-weight: 600; color: #0f172a;">
            <c:choose>
              <c:when test="${not empty shipment.getWarehouseStaff()}">
                ${shipment.getWarehouseStaff().fullName}
              </c:when>
              <c:otherwise>
                <span style="color: #94a3b8; font-style: italic;">.....................................</span>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>

      <!-- Action Panel on the bottom right of document card (non-printing) -->
      <div style="margin-top: 30px; border-top: 1.5px solid #cbd5e1; padding-top: 20px; display: flex; justify-content: flex-end;" class="no-print">
        <button type="button" onclick="window.print()" class="premium-btn-outline" style="height: 38px !important; padding: 0 16px; font-size: 13px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; cursor: pointer; border: 1px solid var(--card-border); border-radius: 8px; background: transparent; color: var(--text-primary);">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
          In Phiếu Xuất Kho
        </button>
      </div>

    </div>
  </c:if>

  <c:if test="${shipment.status != 'COMPLETED'}">
  <!-- Actions & Evidence Images Panel -->
  <div class="premium-card" style="padding: 24px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px;">

    <!-- Header Section -->
    <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1.5px solid var(--card-border); padding-bottom: 12px; margin-bottom: 4px; flex-wrap: wrap; gap: 12px;">
      <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0; display: flex; align-items: center; gap: 8px;">
        <c:choose>
          <c:when test="${shipment.status == 'PICKING'}">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--primary-color)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
            Bằng chứng & Ảnh giao nhận
          </c:when>
          <c:otherwise>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--primary-color)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22c5.523 0 10-4.477 10-10S17.523 2 12 2 2 6.477 2 12s4.477 10 10 10z"></path><path d="M12 6v6l4 2"></path></svg>
            Thao tác xử lý
          </c:otherwise>
        </c:choose>
      </h3>
      
      <!-- Right-aligned action buttons -->
      <c:if test="${shipment.status != 'COMPLETED' && shipment.status != 'CANCELLED'}">
        <c:choose>
          <c:when test="${shipment.status == 'DRAFT'}">
            <div style="display: flex; gap: 8px;">
              <button type="submit" form="statusForm" onclick="document.getElementById('nextStatus').value='PENDING'" class="premium-btn-primary" style="height: 36px !important; padding: 0 16px; font-size: 13px; font-weight: 600;">
                Gửi yêu cầu duyệt
              </button>
              <c:if test="${currentUser.hasPermission('SHIPMENT_WRITE')}">
                <a href="${pageContext.request.contextPath}/admin/shipments?action=delete&id=${shipment.id}" 
                   class="premium-btn-outline" 
                   onclick="return confirm('Bạn có chắc chắn muốn xóa phiếu xuất nháp này không? Hành động này không thể hoàn tác.');"
                   style="display: inline-flex; align-items: center; justify-content: center; height: 36px !important; padding: 0 16px; font-size: 13px; text-decoration: none; color: #ef4444; border-color: rgba(239, 68, 68, 0.4); font-weight: 600; border-radius: 8px; transition: all 0.2s;"
                   onmouseover="this.style.background='rgba(239, 68, 68, 0.05)'; this.style.borderColor='#ef4444';"
                   onmouseout="this.style.background='transparent'; this.style.borderColor='rgba(239, 68, 68, 0.4)';">
                  Xóa phiếu nháp
                </a>
              </c:if>
              <button type="submit" form="statusForm" onclick="document.getElementById('nextStatus').value='CANCELLED'" class="premium-btn-outline" style="color: #64748b; border-color: var(--card-border); height: 36px !important; padding: 0 16px; font-size: 13px; font-weight: 600;">
                Hủy phiếu
              </button>
            </div>
          </c:when>
          <c:when test="${shipment.status == 'PENDING' || shipment.status == 'APPROVED'}">
            <c:choose>
              <c:when test="${currentUser.hasRole('ADMIN') || currentUser.hasRole('WAREHOUSE STAFF')}">
                <div style="display: flex; gap: 8px;">
                  <button type="submit" form="statusForm" onclick="document.getElementById('nextStatus').value='PICKING'" class="premium-btn-primary" style="height: 36px !important; padding: 0 16px; font-size: 13px; background: linear-gradient(135deg, #a855f7, #9333ea) !important; box-shadow: 0 4px 14px rgba(168, 85, 247, 0.2) !important;">
                    Bắt đầu lấy & đóng gói
                  </button>
                  <button type="submit" form="statusForm" onclick="document.getElementById('nextStatus').value='CANCELLED'" class="premium-btn-outline" style="color: #ef4444; border-color: #fecaca; height: 36px !important; padding: 0 16px; font-size: 13px;">
                    Hủy phiếu
                  </button>
                </div>
              </c:when>
              <c:otherwise>
                <div style="background: rgba(59, 130, 246, 0.05); border: 1px solid #bfdbfe; border-radius: 6px; padding: 6px 12px; font-size: 12px; color: #1d4ed8; font-weight: 600;">
                  Chờ Nhân viên kho (Warehouse Staff) thực hiện lấy hàng & đóng gói...
                </div>
              </c:otherwise>
            </c:choose>
          </c:when>

          <c:when test="${shipment.status == 'PICKING'}">
            <c:choose>
              <c:when test="${currentUser.hasRole('ADMIN') || currentUser.hasRole('WAREHOUSE STAFF')}">
                <div style="display: flex; gap: 8px;">
                  <button type="submit" form="statusForm" onclick="document.getElementById('nextStatus').value='COMPLETED'" class="premium-btn-primary" style="height: 36px !important; padding: 0 16px; font-size: 13px; background: linear-gradient(135deg, #10b981, #059669) !important; box-shadow: 0 4px 14px rgba(16, 185, 129, 0.2) !important;">
                    Xác nhận xuất kho
                  </button>
                  <button type="submit" form="statusForm" onclick="document.getElementById('nextStatus').value='CANCELLED'" class="premium-btn-outline" style="color: #ef4444; border-color: #fecaca; height: 36px !important; padding: 0 16px; font-size: 13px;">
                    Hủy phiếu
                  </button>
                </div>
              </c:when>
              <c:otherwise>
                <div style="background: rgba(168, 85, 247, 0.05); border: 1px solid #e9d5ff; border-radius: 6px; padding: 6px 12px; font-size: 12px; color: #7e22ce; font-weight: 600;">
                  Nhân viên kho (Warehouse Staff) đang thực hiện lấy hàng và đóng gói sản phẩm...
                </div>
              </c:otherwise>
            </c:choose>
          </c:when>
        </c:choose>
      </c:if>
    </div>

    <c:if test="${shipment.status == 'PICKING'}">
      <!-- Images Grid -->
      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px;">
        <!-- Card 1: Ảnh phiếu giao hàng (Delivery Note) -->
        <div style="background: #ffffff; border: 1px solid var(--card-border); padding: 16px; border-radius: 10px; display: flex; flex-direction: column; gap: 12px;">
          <div style="font-size: 13px; font-weight: 600; color: var(--text-secondary);">Biên bản/Phiếu giao hàng có chữ ký</div>
          <c:choose>
            <c:when test="${not empty shipment.deliveryNoteImage}">
              <div style="position: relative; overflow: hidden; border-radius: 8px; border: 1.5px solid var(--card-border); padding: 4px; background: #f8fafc; display: flex; align-items: center; justify-content: center; height: 160px;">
                <a href="javascript:void(0)" onclick="openLightbox('${pageContext.request.contextPath}${shipment.deliveryNoteImage}')" style="display: block; width: 100%; height: 100%; text-align: center;">
                  <img src="${pageContext.request.contextPath}${shipment.deliveryNoteImage}" alt="Phiếu giao hàng" style="height: 100%; max-width: 100%; object-fit: contain; border-radius: 6px; transition: transform 0.2s;" onmouseover="this.style.transform='scale(1.03)'" onmouseout="this.style.transform='scale(1.0)'">
                </a>
              </div>
            </c:when>
            <c:otherwise>
              <div id="deliveryNoteUploadSection" style="background: rgba(4, 138, 191, 0.03); border: 1.5px dashed var(--primary-color); padding: 12px; border-radius: 8px; display: flex; flex-direction: column; gap: 6px;">
                <label style="font-size: 12px; font-weight: 700; color: var(--primary-color); display: block; margin: 0;">
                  Tải lên phiếu giao hàng đã ký nhận (Tùy chọn)
                </label>
                <input type="file" name="deliveryNoteImageFile" id="deliveryNoteImageInput" form="statusForm" accept="image/*" style="font-size: 12px; width: 100%;">
              </div>
            </c:otherwise>
          </c:choose>
        </div>

        <!-- Card 2: Ảnh xếp hàng lên xe (Shipping Images) -->
        <div style="background: #ffffff; border: 1px solid var(--card-border); padding: 16px; border-radius: 10px; display: flex; flex-direction: column; gap: 12px;">
          <div style="font-size: 13px; font-weight: 600; color: var(--text-secondary);">Ảnh xếp hàng/xác thực giao nhận</div>
          <c:choose>
            <c:when test="${not empty shipment.shippingImages}">
              <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; background: #f8fafc; padding: 8px; border-radius: 8px; border: 1.5px solid var(--card-border); height: 160px; overflow-y: auto;">
                <c:forEach var="img" items="${shipment.shippingImagesList}">
                  <div style="position: relative; overflow: hidden; border-radius: 6px; border: 1px solid var(--card-border); padding: 2px; background: #ffffff; display: flex; align-items: center; justify-content: center; height: 65px;">
                    <a href="javascript:void(0)" onclick="openLightbox('${pageContext.request.contextPath}${img}')" style="display: block; width: 100%; height: 100%; text-align: center;">
                      <img src="${pageContext.request.contextPath}${img}" alt="Ảnh xếp xe" style="height: 100%; max-width: 100%; object-fit: contain; border-radius: 4px; transition: transform 0.2s;" onmouseover="this.style.transform='scale(1.05)'" onmouseout="this.style.transform='scale(1.0)'">
                    </a>
                  </div>
                </c:forEach>
              </div>
            </c:when>
            <c:otherwise>
              <div id="shippingImagesUploadSection" style="background: rgba(139, 92, 246, 0.03); border: 1.5px dashed #8b5cf6; padding: 12px; border-radius: 8px; display: flex; flex-direction: column; gap: 6px;">
                <label style="font-size: 12px; font-weight: 700; color: #8b5cf6; display: block; margin: 0;">
                  Ảnh bốc hàng/xếp hàng lên xe (Tùy chọn, tối đa 4 ảnh)
                </label>
                <input type="file" name="shippingImagesFiles" id="shippingImagesInput" form="statusForm" accept="image/*" multiple style="font-size: 12px; width: 100%;">
              </div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </c:if>
  </div>

  <!-- Combined Information & Products Card -->
  <div class="premium-card" style="padding: 24px; margin-bottom: 24px;">
    
    <!-- Metadata Grid -->
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; background: #f8fafc; border: 1.5px solid var(--card-border); border-radius: 12px; padding: 20px; margin-bottom: 24px;">
      <!-- Destination -->
      <div style="display: flex; align-items: flex-start; gap: 12px;">
        <div style="background: rgba(4, 138, 191, 0.08); padding: 8px; border-radius: 8px; color: var(--primary-color);">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
        </div>
        <div>
          <div style="font-size: 11px; color: var(--text-secondary); margin-bottom: 2px; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 700;">Nơi nhận</div>
          <div style="font-size: 14px; font-weight: 600; color: var(--text-primary);">${shipment.destination}</div>
        </div>
      </div>
      
      <!-- Created Date -->
      <div style="display: flex; align-items: flex-start; gap: 12px;">
        <div style="background: rgba(4, 138, 191, 0.08); padding: 8px; border-radius: 8px; color: var(--primary-color);">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect><line x1="16" y1="2" x2="16" y2="6"></line><line x1="8" y1="2" x2="8" y2="6"></line><line x1="3" y1="10" x2="21" y2="10"></line></svg>
        </div>
        <div>
          <div style="font-size: 11px; color: var(--text-secondary); margin-bottom: 2px; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 700;">Ngày tạo</div>
          <div style="font-size: 14px; font-weight: 600; color: var(--text-primary);">
            <fmt:formatDate value="${shipment.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
          </div>
        </div>
      </div>
      
      <!-- Creator -->
      <div style="display: flex; align-items: flex-start; gap: 12px;">
        <div style="background: rgba(4, 138, 191, 0.08); padding: 8px; border-radius: 8px; color: var(--primary-color);">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
        </div>
        <div>
          <div style="font-size: 11px; color: var(--text-secondary); margin-bottom: 2px; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 700;">Người xuất</div>
          <div style="font-size: 14px; font-weight: 600; color: var(--text-primary);">${shipment.creator.fullName}</div>
        </div>
      </div>
      
      <!-- Status -->
      <div style="display: flex; align-items: flex-start; gap: 12px;">
        <div style="background: rgba(4, 138, 191, 0.08); padding: 8px; border-radius: 8px; color: var(--primary-color);">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 14 14"></polyline></svg>
        </div>
        <div>
          <div style="font-size: 11px; color: var(--text-secondary); margin-bottom: 2px; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 700;">Trạng thái</div>
          <div style="margin-top: 2px;">
            <c:choose>
              <c:when test="${shipment.status == 'DRAFT'}">
                <span class="premium-tag" style="background: rgba(100, 116, 139, 0.1); color: #64748b; font-weight: 600;">Nháp</span>
              </c:when>
              <c:when test="${shipment.status == 'PENDING'}">
                <span class="premium-tag" style="background: rgba(245, 158, 11, 0.1); color: #d97706; font-weight: 600;">Chờ lấy hàng</span>
              </c:when>
              <c:when test="${shipment.status == 'APPROVED'}">
                <span class="premium-tag" style="background: rgba(59, 130, 246, 0.1); color: #3b82f6; font-weight: 600;">Chờ lấy hàng</span>
              </c:when>
              <c:when test="${shipment.status == 'PICKING'}">
                <span class="premium-tag" style="background: rgba(168, 85, 247, 0.1); color: #a855f7; font-weight: 600;">Lấy & Đóng gói</span>
              </c:when>
              <c:when test="${shipment.status == 'COMPLETED'}">
                <span class="premium-tag" style="background: rgba(16, 185, 129, 0.1); color: #10b981; font-weight: 600;">Đã hoàn thành</span>
              </c:when>
              <c:otherwise>
                <span class="premium-tag" style="background: rgba(239, 68, 68, 0.1); color: #ef4444; font-weight: 600;">Đã hủy</span>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Notes -->
    <c:if test="${not empty shipment.notes}">
      <div style="background: rgba(248, 250, 252, 0.6); border: 1.5px dashed var(--card-border); border-radius: 8px; padding: 14px 18px; margin-bottom: 24px;">
        <span style="font-size: 13px; font-weight: 600; color: var(--text-secondary); display: block; margin-bottom: 4px;">Ghi chú:</span>
        <span style="font-size: 14px; color: var(--text-primary); line-height: 1.5;">${shipment.notes}</span>
      </div>
    </c:if>

    <!-- Product list -->
    <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px; display: flex; align-items: center; gap: 8px;">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--primary-color)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
      Danh sách sản phẩm xuất kho
    </h3>
    
    <div style="overflow-x: auto;">
      <table style="width: 100%; border-collapse: collapse;">
        <thead>
          <tr>
            <th style="text-align: left; padding: 12px 16px; border-bottom: 2px solid var(--card-border); font-size: 13px; color: var(--text-secondary); font-weight: 600;">SKU</th>
            <th style="text-align: left; padding: 12px 16px; border-bottom: 2px solid var(--card-border); font-size: 13px; color: var(--text-secondary); font-weight: 600;">Tên sản phẩm</th>
            <th style="text-align: right; padding: 12px 16px; border-bottom: 2px solid var(--card-border); font-size: 13px; color: var(--text-secondary); font-weight: 600;">Đơn vị</th>
            <th style="text-align: right; padding: 12px 16px; border-bottom: 2px solid var(--card-border); font-size: 13px; color: var(--text-secondary); font-weight: 600;">Số lượng xuất</th>
          </tr>
        </thead>
        <tbody>
          <c:set var="totalItems" value="0"/>
          <c:forEach var="detail" items="${shipment.details}">
            <tr style="transition: background 0.2s;" onmouseover="this.style.background='#f8fafc'" onmouseout="this.style.background='transparent'">
              <td style="padding: 12px 16px; border-bottom: 1px solid var(--card-border); font-family: monospace; font-size: 13px; color: var(--text-secondary);">${detail.product.sku}</td>
              <td style="padding: 12px 16px; border-bottom: 1px solid var(--card-border); font-weight: 600; color: var(--text-primary);">${detail.product.name}</td>
              <td style="padding: 12px 16px; border-bottom: 1px solid var(--card-border); text-align: right; color: var(--text-secondary);">${detail.product.unit}</td>
              <td style="padding: 12px 16px; border-bottom: 1px solid var(--card-border); text-align: right; font-weight: 700; color: #ef4444;">-${detail.quantity}</td>
            </tr>
            <c:set var="totalItems" value="${totalItems + detail.quantity}"/>
          </c:forEach>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="3" style="text-align: right; padding: 16px 12px; font-weight: 700; color: var(--text-secondary);">Tổng số lượng xuất:</td>
            <td style="text-align: right; padding: 16px 12px; font-weight: 800; font-size: 16px; color: var(--primary-color);">${totalItems}</td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
  </c:if>
</div>

<!-- History Modal -->
<div id="historyModal" class="modal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(15, 23, 42, 0.4); backdrop-filter: blur(4px); transition: all 0.3s ease;">
  <div class="modal-content" style="background-color: #ffffff; margin: 10% auto; padding: 24px; border-radius: 12px; border: 1px solid var(--card-border); width: 90%; max-width: 600px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04); position: relative; animation: modalFadeIn 0.3s ease;">
    <span id="closeHistoryModal" style="position: absolute; right: 20px; top: 16px; font-size: 24px; font-weight: bold; color: var(--text-secondary); cursor: pointer; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">&times;</span>
    <h3 style="font-size: 18px; font-weight: 700; color: var(--text-primary); margin: 0 0 20px 0; padding-bottom: 12px; border-bottom: 1.5px solid var(--card-border); display: flex; align-items: center; gap: 8px;">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--primary-color)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
      Lịch sử cập nhật trạng thái
    </h3>
    
    <div style="max-height: 400px; overflow-y: auto; padding-right: 8px; display: flex; flex-direction: column; gap: 16px; position: relative; padding-left: 20px;">
      <div style="position: absolute; left: 6px; top: 8px; bottom: 8px; width: 2px; background: #e2e8f0;"></div>
      
      <c:forEach var="log" items="${shipment.history}">
        <div style="position: relative; margin-bottom: 4px;">
          <div style="position: absolute; left: -19px; top: 5px; width: 10px; height: 10px; border-radius: 50%; background: var(--primary-color); border: 2px solid #ffffff; box-shadow: 0 0 0 2px rgba(4, 138, 191, 0.2);"></div>
          
          <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 4px;">
            <span style="font-weight: 700; font-size: 13px; color: var(--text-primary);">${log.updater.fullName}</span>
            <span style="font-size: 11px; color: var(--text-secondary); font-family: monospace;">
              <fmt:formatDate value="${log.changedAt}" pattern="dd/MM/yyyy HH:mm:ss"/>
            </span>
          </div>
          <p style="margin: 0; font-size: 13px; color: var(--text-secondary); line-height: 1.4;">
            ${log.notes}
          </p>
        </div>
      </c:forEach>
      <c:if test="${empty shipment.history}">
        <div style="padding: 30px; text-align: center; color: var(--text-secondary); font-size: 13px;">
          Chưa có lịch sử cập nhật.
        </div>
      </c:if>
    </div>
  </div>
</div>

<!-- Image Lightbox Modal -->
<div id="imageLightbox" style="display: none; position: fixed; z-index: 2000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(15, 23, 42, 0.85); backdrop-filter: blur(8px); justify-content: center; align-items: center;">
  <span id="closeLightbox" style="position: absolute; right: 24px; top: 24px; font-size: 36px; font-weight: bold; color: #ffffff; cursor: pointer; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='#ffffff'">&times;</span>
  <img id="lightboxImage" src="" alt="Ảnh phóng to" style="max-width: 90%; max-height: 90%; object-fit: contain; border-radius: 8px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5); animation: zoomIn 0.25s ease;">
</div>

<style>
@keyframes modalFadeIn {
  from { opacity: 0; transform: translateY(-20px); }
  to { opacity: 1; transform: translateY(0); }
}
@keyframes zoomIn {
  from { transform: scale(0.9); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}
</style>

<script>
function openLightbox(src) {
    const lightbox = document.getElementById('imageLightbox');
    const lightboxImg = document.getElementById('lightboxImage');
    if (lightbox && lightboxImg) {
        lightboxImg.src = src;
        lightbox.style.display = 'flex';
        document.body.style.overflow = "hidden";
    }
}

document.addEventListener("DOMContentLoaded", function() {
    const statusForm = document.getElementById("statusForm");
    const nextStatus = document.getElementById("nextStatus");
    const deliveryNoteInput = document.getElementById("deliveryNoteImageInput");
    const shippingImagesInput = document.getElementById("shippingImagesInput");
    


    // Modal controls
    const historyModal = document.getElementById("historyModal");
    const openHistoryBtn = document.getElementById("openHistoryBtn");
    const closeHistoryModal = document.getElementById("closeHistoryModal");
    
    if (openHistoryBtn && historyModal) {
        openHistoryBtn.addEventListener("click", function() {
            historyModal.style.display = "block";
            document.body.style.overflow = "hidden";
        });
    }
    
    if (closeHistoryModal && historyModal) {
        closeHistoryModal.addEventListener("click", function() {
            historyModal.style.display = "none";
            document.body.style.overflow = "auto";
        });
    }
    
    window.addEventListener("click", function(event) {
        if (event.target === historyModal) {
            historyModal.style.display = "none";
            document.body.style.overflow = "auto";
        }
    });

    // Lightbox Modal Controls
    const lightbox = document.getElementById('imageLightbox');
    const closeLightbox = document.getElementById('closeLightbox');
    const lightboxImg = document.getElementById('lightboxImage');
    
    if (closeLightbox && lightbox) {
        closeLightbox.addEventListener("click", function() {
            lightbox.style.display = 'none';
            if (!historyModal || historyModal.style.display !== "block") {
                document.body.style.overflow = "auto";
            }
        });
    }
    
    if (lightbox) {
        lightbox.addEventListener("click", function(event) {
            if (event.target !== lightboxImg && event.target !== closeLightbox) {
                lightbox.style.display = 'none';
                if (!historyModal || historyModal.style.display !== "block") {
                    document.body.style.overflow = "auto";
                }
            }
        });
    }
});
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
