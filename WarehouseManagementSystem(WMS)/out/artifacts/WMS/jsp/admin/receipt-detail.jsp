<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Chi tiết Phiếu Nhập"/>
<c:set var="activePage" value="receipts" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div class="subpage-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-end;">
    <div>
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">Chi tiết Phiếu Nhập: <span style="font-family: monospace; color: var(--primary-color);">${receipt.receiptCode}</span></h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Thông tin chi tiết về các sản phẩm đã nhập kho.</p>
    </div>
    <div>
      <a href="${pageContext.request.contextPath}/admin/receipts" class="premium-btn-secondary" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 40px; padding: 0 16px;">
        &larr; Quay lại danh sách
      </a>
    </div>
  </div>

  <!-- Stepper -->
  <c:if test="${receipt.status != 'CANCELLED'}">
    <div class="premium-card" style="padding: 24px 32px; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; position: relative; overflow: hidden;">
      <!-- Connector Line -->
      <div style="position: absolute; top: 50%; left: 10%; right: 10%; height: 4px; background: #e2e8f0; z-index: 1; transform: translateY(-50%);"></div>
      <div style="position: absolute; top: 50%; left: 10%; width: <c:choose>
        <c:when test="${receipt.status == 'DRAFT'}">0%</c:when>
        <c:when test="${receipt.status == 'PENDING_APPROVAL'}">25%</c:when>
        <c:when test="${receipt.status == 'APPROVED'}">50%</c:when>
        <c:when test="${receipt.status == 'RECEIVING'}">75%</c:when>
        <c:when test="${receipt.status == 'COMPLETED'}">100%</c:when>
      </c:choose>; height: 4px; background: var(--primary-color); z-index: 2; transform: translateY(-50%); transition: width 0.5s ease;"></div>
      
      <!-- Steps -->
      <!-- Step 1: DRAFT -->
      <div style="z-index: 3; display: flex; flex-direction: column; align-items: center; gap: 8px;">
        <div style="width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;
          <c:choose>
            <c:when test="${receipt.status == 'DRAFT'}">background: var(--primary-color); color: #ffffff;</c:when>
            <c:otherwise>background: #10b981; color: #ffffff;</c:otherwise>
          </c:choose>">
          <c:choose>
            <c:when test="${receipt.status == 'DRAFT'}">1</c:when>
            <c:otherwise>✓</c:otherwise>
          </c:choose>
        </div>
        <span style="font-size: 13px; font-weight: 600; color: ${receipt.status == 'DRAFT' ? 'var(--primary-color)' : 'var(--text-secondary)'};">Nháp</span>
      </div>
      
      <!-- Step 2: PENDING_APPROVAL -->
      <div style="z-index: 3; display: flex; flex-direction: column; align-items: center; gap: 8px;">
        <div style="width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;
          <c:choose>
            <c:when test="${receipt.status == 'PENDING_APPROVAL'}">background: #d97706; color: #ffffff;</c:when>
            <c:when test="${receipt.status == 'APPROVED' || receipt.status == 'RECEIVING' || receipt.status == 'COMPLETED'}">background: #10b981; color: #ffffff;</c:when>
            <c:otherwise>background: #e2e8f0; color: var(--text-secondary);</c:otherwise>
          </c:choose>">
          <c:choose>
            <c:when test="${receipt.status == 'DRAFT'}">2</c:when>
            <c:when test="${receipt.status == 'PENDING_APPROVAL'}">2</c:when>
            <c:otherwise>✓</c:otherwise>
          </c:choose>
        </div>
        <span style="font-size: 13px; font-weight: 600; color: ${receipt.status == 'PENDING_APPROVAL' ? '#d97706' : 'var(--text-secondary)'};">Chờ duyệt</span>
      </div>
      
      <!-- Step 3: APPROVED -->
      <div style="z-index: 3; display: flex; flex-direction: column; align-items: center; gap: 8px;">
        <div style="width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;
          <c:choose>
            <c:when test="${receipt.status == 'APPROVED'}">background: #3b82f6; color: #ffffff;</c:when>
            <c:when test="${receipt.status == 'RECEIVING' || receipt.status == 'COMPLETED'}">background: #10b981; color: #ffffff;</c:when>
            <c:otherwise>background: #e2e8f0; color: var(--text-secondary);</c:otherwise>
          </c:choose>">
          <c:choose>
            <c:when test="${receipt.status == 'DRAFT' || receipt.status == 'PENDING_APPROVAL' || receipt.status == 'APPROVED'}">3</c:when>
            <c:otherwise>✓</c:otherwise>
          </c:choose>
        </div>
        <span style="font-size: 13px; font-weight: 600; color: ${receipt.status == 'APPROVED' ? '#3b82f6' : 'var(--text-secondary)'};">Đã duyệt</span>
      </div>
      
      <!-- Step 4: RECEIVING -->
      <div style="z-index: 3; display: flex; flex-direction: column; align-items: center; gap: 8px;">
        <div style="width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;
          <c:choose>
            <c:when test="${receipt.status == 'RECEIVING'}">background: #8b5cf6; color: #ffffff;</c:when>
            <c:when test="${receipt.status == 'COMPLETED'}">background: #10b981; color: #ffffff;</c:when>
            <c:otherwise>background: #e2e8f0; color: var(--text-secondary);</c:otherwise>
          </c:choose>">
          <c:choose>
            <c:when test="${receipt.status == 'COMPLETED'}">✓</c:when>
            <c:otherwise>4</c:otherwise>
          </c:choose>
        </div>
        <span style="font-size: 13px; font-weight: 600; color: ${receipt.status == 'RECEIVING' ? '#8b5cf6' : 'var(--text-secondary)'};">Nhận hàng</span>
      </div>
      
      <!-- Step 5: COMPLETED -->
      <div style="z-index: 3; display: flex; flex-direction: column; align-items: center; gap: 8px;">
        <div style="width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;
          <c:choose>
            <c:when test="${receipt.status == 'COMPLETED'}">background: #10b981; color: #ffffff;</c:when>
            <c:otherwise>background: #e2e8f0; color: var(--text-secondary);</c:otherwise>
          </c:choose>">
          5
        </div>
        <span style="font-size: 13px; font-weight: 600; color: ${receipt.status == 'COMPLETED' ? '#10b981' : 'var(--text-secondary)'};">Hoàn thành</span>
      </div>
    </div>
  </c:if>
  
  <c:if test="${receipt.status == 'CANCELLED'}">
    <div class="premium-card" style="padding: 20px; margin-bottom: 24px; background: #fef2f2; border: 1.5px solid #fecaca; border-radius: 12px; display: flex; align-items: center; gap: 12px; color: #ef4444;">
      <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink: 0;">
        <circle cx="12" cy="12" r="10"></circle>
        <line x1="15" y1="9" x2="9" y2="15"></line>
        <line x1="9" y1="9" x2="15" y2="15"></line>
      </svg>
      <div>
        <h4 style="margin: 0; font-size: 15px; font-weight: 700; color: #991b1b;">Yêu cầu nhập kho này đã bị Hủy</h4>
        <p style="margin: 4px 0 0 0; font-size: 13px; color: #b91c1c;">Phiếu nhập này không còn hiệu lực và tồn kho không được cập nhật.</p>
      </div>
    </div>
  </c:if>

  <div style="display: grid; grid-template-columns: 1fr 2fr; gap: 24px;">
    <!-- Info panel -->
    <div style="display: flex; flex-direction: column;">
      <div class="premium-card" style="padding: 24px; align-self: stretch;">
        <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">Thông tin chung</h3>
        
        <div style="display: flex; flex-direction: column; gap: 16px;">
          <div>
            <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Nhà cung cấp</div>
            <div style="font-size: 15px; font-weight: 600; color: var(--text-primary);">${receipt.supplier.name}</div>
          </div>
          
          <div>
            <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Ngày tạo</div>
            <div style="font-size: 14px; color: var(--text-primary);">
              <fmt:formatDate value="${receipt.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
            </div>
          </div>
          
          <div>
            <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Người tạo</div>
            <div style="font-size: 14px; color: var(--text-primary);">${receipt.creator.fullName}</div>
          </div>
          
          <div>
            <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Trạng thái</div>
            <div>
              <c:choose>
                <c:when test="${receipt.status == 'DRAFT'}">
                  <span class="premium-tag" style="background: rgba(100, 116, 139, 0.1); color: #64748b;">Nháp</span>
                </c:when>
                <c:when test="${receipt.status == 'PENDING_APPROVAL'}">
                  <span class="premium-tag" style="background: rgba(245, 158, 11, 0.1); color: #d97706;">Chờ phê duyệt</span>
                </c:when>
                <c:when test="${receipt.status == 'APPROVED'}">
                  <span class="premium-tag" style="background: rgba(59, 130, 246, 0.1); color: #3b82f6;">Đã duyệt</span>
                </c:when>
                <c:when test="${receipt.status == 'RECEIVING'}">
                  <span class="premium-tag" style="background: rgba(139, 92, 246, 0.1); color: #8b5cf6;">Đang nhận hàng</span>
                </c:when>
                <c:when test="${receipt.status == 'COMPLETED'}">
                  <span class="premium-tag" style="background: rgba(16, 185, 129, 0.1); color: #10b981;">Đã hoàn thành</span>
                </c:when>
                <c:otherwise>
                  <span class="premium-tag" style="background: rgba(239, 68, 68, 0.1); color: #ef4444;">Đã hủy</span>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
          
          <c:if test="${not empty receipt.notes}">
          <div>
            <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">Ghi chú</div>
            <div style="font-size: 14px; color: var(--text-primary); background: #f8fafc; padding: 12px; border-radius: 8px; border: 1px solid var(--card-border);">${receipt.notes}</div>
          </div>
          </c:if>
        </div>
      </div>

      <!-- Actions Panel -->
      <c:if test="${receipt.status != 'COMPLETED' && receipt.status != 'CANCELLED'}">
        <div class="premium-card" style="padding: 24px; margin-top: 24px; align-self: stretch;">
          <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">Thao tác nghiệp vụ</h3>
          
          <form action="${pageContext.request.contextPath}/admin/receipts" method="post" id="statusForm" style="display: flex; flex-direction: column; gap: 12px;">
            <input type="hidden" name="action" value="updateStatus"/>
            <input type="hidden" name="id" value="${receipt.id}"/>
            <input type="hidden" name="status" id="nextStatus" value=""/>
            
            <c:choose>
              <c:when test="${receipt.status == 'DRAFT'}">
                <p style="font-size: 13px; color: var(--text-secondary); margin: 0 0 8px 0;">Phiếu nhập đang ở dạng bản nháp. Vui lòng gửi yêu cầu để cấp quản lý phê duyệt.</p>
                <div style="display: flex; gap: 12px;">
                  <button type="submit" onclick="document.getElementById('nextStatus').value='PENDING_APPROVAL'" class="premium-btn-primary" style="flex: 1; height: 40px !important;">
                    Gửi yêu cầu duyệt
                  </button>
                  <button type="submit" onclick="document.getElementById('nextStatus').value='CANCELLED'" class="premium-btn-outline" style="color: #ef4444; border-color: #fecaca; height: 40px !important;">
                    Hủy phiếu
                  </button>
                </div>
              </c:when>
              
              <c:when test="${receipt.status == 'PENDING_APPROVAL'}">
                <c:choose>
                  <c:when test="${currentUser.hasRole('ADMIN') || currentUser.hasRole('WAREHOUSE MANAGER')}">
                    <p style="font-size: 13px; color: var(--text-secondary); margin: 0 0 8px 0;">Phiếu nhập đang chờ phê duyệt. Bạn có quyền duyệt hoặc từ chối phiếu này.</p>
                    <div style="display: flex; gap: 12px;">
                      <button type="submit" onclick="document.getElementById('nextStatus').value='APPROVED'" class="premium-btn-primary" style="flex: 1; height: 40px !important; background: linear-gradient(135deg, #10b981, #059669) !important; box-shadow: 0 4px 14px rgba(16, 185, 129, 0.2) !important;">
                        Phê duyệt phiếu
                      </button>
                      <button type="submit" onclick="document.getElementById('nextStatus').value='CANCELLED'" class="premium-btn-outline" style="color: #ef4444; border-color: #fecaca; height: 40px !important;">
                        Từ chối & Hủy
                      </button>
                    </div>
                  </c:when>
                  <c:otherwise>
                    <div style="background: rgba(245, 158, 11, 0.05); border: 1px solid #fde68a; border-radius: 8px; padding: 12px; font-size: 13px; color: #d97706; text-align: center; font-weight: 600;">
                      Đang chờ Quản lý hoặc Admin phê duyệt...
                    </div>
                  </c:otherwise>
                </c:choose>
              </c:when>
              
              <c:when test="${receipt.status == 'APPROVED'}">
                <p style="font-size: 13px; color: var(--text-secondary); margin: 0 0 8px 0;">Phiếu nhập đã được duyệt. Nhân viên kho bắt đầu thực hiện kiểm đếm và nhận hàng thực tế.</p>
                <div style="display: flex; gap: 12px;">
                  <button type="submit" onclick="document.getElementById('nextStatus').value='RECEIVING'" class="premium-btn-primary" style="flex: 1; height: 40px !important; background: linear-gradient(135deg, #8b5cf6, #7c3aed) !important; box-shadow: 0 4px 14px rgba(139, 92, 246, 0.2) !important;">
                    Bắt đầu nhận hàng
                  </button>
                  <button type="submit" onclick="document.getElementById('nextStatus').value='CANCELLED'" class="premium-btn-outline" style="color: #ef4444; border-color: #fecaca; height: 40px !important;">
                    Hủy phiếu
                  </button>
                </div>
              </c:when>
              
              <c:when test="${receipt.status == 'RECEIVING'}">
                <p style="font-size: 13px; color: var(--text-secondary); margin: 0 0 8px 0;">Đang trong quá trình nhận hàng. Xác nhận sau khi đã cất hàng vào vị trí kệ để chính thức cập nhật tồn kho.</p>
                <div style="display: flex; gap: 12px;">
                  <button type="submit" onclick="document.getElementById('nextStatus').value='COMPLETED'" class="premium-btn-primary" style="flex: 1; height: 40px !important; background: linear-gradient(135deg, #10b981, #059669) !important; box-shadow: 0 4px 14px rgba(16, 185, 129, 0.2) !important;">
                    Hoàn thành cất hàng
                  </button>
                  <button type="submit" onclick="document.getElementById('nextStatus').value='CANCELLED'" class="premium-btn-outline" style="color: #ef4444; border-color: #fecaca; height: 40px !important;">
                    Hủy phiếu
                  </button>
                </div>
              </c:when>
            </c:choose>
          </form>
        </div>
      </c:if>

      <!-- Lịch sử cập nhật -->
      <div class="premium-card" style="padding: 24px; margin-top: 24px; align-self: stretch;">
        <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">Lịch sử cập nhật trạng thái</h3>
        
        <div style="display: flex; flex-direction: column; gap: 16px; position: relative; padding-left: 20px;">
          <!-- Timeline Vertical line -->
          <div style="position: absolute; left: 6px; top: 8px; bottom: 8px; width: 2px; background: #e2e8f0;"></div>
          
          <c:forEach var="log" items="${receipt.history}">
            <div style="position: relative; margin-bottom: 4px;">
              <!-- Dot -->
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
          <c:if test="${empty receipt.history}">
            <p style="font-size: 13px; color: var(--text-secondary); margin: 0; text-align: center;">Chưa có lịch sử cập nhật.</p>
          </c:if>
        </div>
      </div>
    </div>
    
    <!-- Details panel -->
    <div class="premium-card" style="padding: 24px; align-self: start;">
      <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">Sản phẩm nhập kho</h3>
      
      <div style="overflow-x: auto;">
        <table style="width: 100%; border-collapse: collapse;">
          <thead>
            <tr>
              <th style="text-align: left; padding: 12px; border-bottom: 2px solid var(--card-border); font-size: 13px; color: var(--text-secondary);">SKU</th>
              <th style="text-align: left; padding: 12px; border-bottom: 2px solid var(--card-border); font-size: 13px; color: var(--text-secondary);">Tên sản phẩm</th>
              <th style="text-align: right; padding: 12px; border-bottom: 2px solid var(--card-border); font-size: 13px; color: var(--text-secondary);">Đơn vị</th>
              <th style="text-align: right; padding: 12px; border-bottom: 2px solid var(--card-border); font-size: 13px; color: var(--text-secondary);">Số lượng nhập</th>
            </tr>
          </thead>
          <tbody>
            <c:set var="totalItems" value="0"/>
            <c:forEach var="detail" items="${receipt.details}">
              <tr>
                <td style="padding: 12px; border-bottom: 1px solid var(--card-border); font-family: monospace;">${detail.product.sku}</td>
                <td style="padding: 12px; border-bottom: 1px solid var(--card-border); font-weight: 600;">${detail.product.name}</td>
                <td style="padding: 12px; border-bottom: 1px solid var(--card-border); text-align: right;">${detail.product.unit}</td>
                <td style="padding: 12px; border-bottom: 1px solid var(--card-border); text-align: right; font-weight: 700; color: var(--primary-color);">+${detail.quantity}</td>
              </tr>
              <c:set var="totalItems" value="${totalItems + detail.quantity}"/>
            </c:forEach>
          </tbody>
          <tfoot>
            <tr>
              <td colspan="3" style="text-align: right; padding: 16px 12px; font-weight: 700; color: var(--text-primary);">Tổng số lượng nhập:</td>
              <td style="text-align: right; padding: 16px 12px; font-weight: 700; font-size: 16px; color: var(--primary-color);">${totalItems}</td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  </div>
</div>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
