<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Chi tiết Sản phẩm"/>
<c:set var="activePage" value="products" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 16px;">
    <a href="${pageContext.request.contextPath}/admin/products" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
      Quay lại danh sách
    </a>
  </div>

  <div class="subpage-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-end;">
    <div>
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">Chi tiết Sản phẩm: <span style="color: var(--primary-color);">${product.name}</span></h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Xem chi tiết thông số sản phẩm và tình trạng tồn kho hiện tại.</p>
    </div>
    <c:if test="${currentUser.hasPermission('PRODUCT_WRITE')}">
      <div>
        <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${product.id}" class="premium-btn-primary" style="display: inline-flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; height: 40px; padding: 0 16px;">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
            <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
          </svg>
          Chỉnh sửa sản phẩm
        </a>
      </div>
    </c:if>
  </div>

  <div style="display: grid; grid-template-columns: 1.5fr 1fr; gap: 24px;">
    <!-- Left Column: Product Information -->
    <div class="premium-card" style="padding: 24px; align-self: start;">
      <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">Thông tin sản phẩm</h3>
      
      <div style="display: flex; flex-direction: column; gap: 16px;">
        <div style="display: flex; gap: 24px; margin-bottom: 8px; align-items: flex-start; flex-wrap: wrap;">
          <!-- Product Image -->
          <div style="flex-shrink: 0; width: 140px; height: 140px; border-radius: 12px; border: 1.5px solid var(--card-border); overflow: hidden; background: #f8fafc; display: flex; align-items: center; justify-content: center;">
            <c:choose>
              <c:when test="${not empty product.imageUrl}">
                <img src="${product.imageUrl.startsWith('/') ? pageContext.request.contextPath : ''}${product.imageUrl}" 
                     style="width: 100%; height: 100%; object-fit: cover;" />
              </c:when>
              <c:otherwise>
                <!-- Fallback icon -->
                <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="var(--text-secondary)" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
                  <polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline>
                  <line x1="12" y1="22.08" x2="12" y2="12"></line>
                </svg>
              </c:otherwise>
            </c:choose>
          </div>
          
          <!-- Key Info -->
          <div style="flex-grow: 1; min-width: 200px; display: flex; flex-direction: column; gap: 12px;">
            <div>
              <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 2px;">Tên sản phẩm</div>
              <div style="font-size: 18px; font-weight: 700; color: var(--text-primary);">${product.name}</div>
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
              <div>
                <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 2px;">Mã SKU</div>
                <div style="font-family: monospace; font-size: 14px; font-weight: 700; color: var(--text-primary);">${product.sku}</div>
              </div>
              <div>
                <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 2px;">Đơn vị tính</div>
                <div style="font-size: 14px; font-weight: 600; color: var(--text-primary);">${product.unit}</div>
              </div>
            </div>
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
          <div>
            <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Dòng sản phẩm</div>
            <div>
              <a href="${pageContext.request.contextPath}/admin/product-lines?action=view&id=${product.productLine.id}" class="premium-tag premium-tag--manager" style="font-size: 12px; text-decoration: none; display: inline-block;">
                ${product.productLine.name}
              </a>
            </div>
          </div>
          <div>
            <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Hãng sản xuất</div>
            <div>
              <a href="${pageContext.request.contextPath}/admin/brands?action=view&id=${product.productLine.brand.id}" class="premium-tag premium-tag--admin" style="font-size: 12px; text-decoration: none; display: inline-block;">
                ${product.productLine.brand.name}
              </a>
            </div>
          </div>
        </div>

        <div>
          <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Đơn giá bán</div>
          <div style="font-size: 18px; font-weight: 700; color: #10b981;">
            <c:choose>
              <c:when test="${not empty product.price}">
                <fmt:formatNumber value="${product.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
              </c:when>
              <c:otherwise><span style="color: var(--text-secondary); font-style: italic;">Chưa thiết lập</span></c:otherwise>
            </c:choose>
          </div>
        </div>

        <div>
          <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Mô tả chi tiết</div>
          <div style="font-size: 14px; color: var(--text-primary); background: #f8fafc; padding: 12px; border-radius: 8px; border: 1px solid var(--card-border); line-height: 1.5; min-height: 80px;">
            <c:choose>
              <c:when test="${not empty product.description}">${product.description}</c:when>
              <c:otherwise><span style="color: var(--text-secondary); font-style: italic;">Không có mô tả chi tiết cho sản phẩm này.</span></c:otherwise>
            </c:choose>
          </div>
        </div>

        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px; border-top: 1px solid var(--card-border); padding-top: 16px;">
          <div>
            <div style="font-size: 12px; color: var(--text-secondary); margin-bottom: 2px;">Ngày tạo hệ thống</div>
            <div style="font-size: 13px; color: var(--text-primary);">
              <fmt:formatDate value="${product.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
            </div>
          </div>
          <div>
            <div style="font-size: 12px; color: var(--text-secondary); margin-bottom: 2px;">Ngày cập nhật cuối</div>
            <div style="font-size: 13px; color: var(--text-primary);">
              <fmt:formatDate value="${product.updatedAt}" pattern="dd/MM/yyyy HH:mm"/>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Right Column: Inventory Status -->
    <div class="premium-card" style="padding: 24px; align-self: start;">
      <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">Trạng thái tồn kho</h3>
      
      <c:choose>
        <c:when test="${not empty inventory}">
          <div style="display: flex; flex-direction: column; gap: 20px;">
            <div style="text-align: center; padding: 24px; background: #f8fafc; border-radius: 12px; border: 1px solid var(--card-border);">
              <div style="font-size: 14px; color: var(--text-secondary); margin-bottom: 8px; font-weight: 600;">Số lượng tồn kho thực tế</div>
              <div style="font-size: 40px; font-weight: 800; color: ${inventory.quantityInStock <= inventory.minStockLevel ? '#ef4444' : 'var(--primary-color)'};">
                ${inventory.quantityInStock}
              </div>
              <div style="font-size: 13px; margin-top: 8px;">
                <c:choose>
                  <c:when test="${inventory.quantityInStock <= inventory.minStockLevel}">
                    <span style="color: #ef4444; font-weight: 700; background: rgba(239, 68, 68, 0.1); padding: 4px 8px; border-radius: 6px; display: inline-flex; align-items: center; gap: 4px;">
                      ⚠️ Cảnh báo: Dưới mức tối thiểu!
                    </span>
                  </c:when>
                  <c:otherwise>
                    <span style="color: #10b981; font-weight: 700; background: rgba(16, 185, 129, 0.1); padding: 4px 8px; border-radius: 6px; display: inline-flex; align-items: center; gap: 4px;">
                      ✓ Tồn kho an toàn
                    </span>
                  </c:otherwise>
                </c:choose>
              </div>
            </div>

            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">
              <span style="font-size: 14px; color: var(--text-secondary);">Mức tồn kho tối thiểu:</span>
              <span style="font-size: 15px; font-weight: 700; color: var(--text-primary);">${inventory.minStockLevel}</span>
            </div>

            <div style="display: flex; justify-content: space-between; align-items: center;">
              <span style="font-size: 14px; color: var(--text-secondary);">Cập nhật tồn kho cuối:</span>
              <span style="font-size: 14px; font-weight: 600; color: var(--text-primary);">
                <fmt:formatDate value="${inventory.lastUpdated}" pattern="dd/MM/yyyy HH:mm"/>
              </span>
            </div>
            
            <c:if test="${currentUser.hasPermission('INVENTORY_WRITE')}">
              <div style="margin-top: 12px;">
                <a href="${pageContext.request.contextPath}/admin/inventories?action=edit&productId=${product.id}" class="premium-btn-outline" style="display: flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; width: 100%; box-sizing: border-box; height: 40px;">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                    <path d="M18.5 2.5a2.121 2.121 0 1 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                  </svg>
                  Cập nhật cấu hình tồn kho
                </a>
              </div>
            </c:if>
          </div>
        </c:when>
        <c:otherwise>
          <div style="text-align: center; padding: 24px; color: var(--text-secondary); font-style: italic;">
            Chưa có thông tin tồn kho cho sản phẩm này.
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</div>

<style>
  .premium-tag--manager { background: rgba(245, 158, 11, 0.1) !important; color: #d97706 !important; padding: 4px 10px; border-radius: 6px; }
  .premium-tag--admin { background: rgba(30, 64, 175, 0.1) !important; color: #1e40af !important; padding: 4px 10px; border-radius: 6px; }
</style>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
