<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Chi tiết Phiếu Nhập"/>
<c:set var="activePage" value="receipts" scope="request"/>
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
    <!-- Back link styled like image -->
    <div style="margin-bottom: 16px;">
        <a href="${pageContext.request.contextPath}/manage/receipts" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: #475569; font-size: 14px; font-weight: 500; transition: color 0.2s;" onmouseover="this.style.color = 'var(--primary-color)'" onmouseout="this.style.color = '#475569'">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="19" y1="12" x2="5" y2="12"></line>
            <polyline points="12 19 5 12 12 5"></polyline>
            </svg>
            Quay lại danh sách
        </a>
    </div>

    <div class="subpage-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-end;">
        <div>
            <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">Chi tiết Phiếu Nhập: <span style="font-family: monospace; color: var(--primary-color);">${receipt.receiptCode}</span></h2>
            <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Thông tin chi tiết về các sản phẩm đã nhập kho.</p>
        </div>
        <div style="display: flex; gap: 12px; align-items: center;">
            <button type="button" id="openHistoryBtn" class="premium-btn-secondary" style="display: inline-flex; align-items: center; justify-content: center; height: 40px; padding: 0 16px; font-weight: 600; cursor: pointer; gap: 6px; border: 1.5px solid var(--card-border); background: #ffffff; border-radius: 8px; font-size: 13px; color: var(--text-primary); transition: all 0.2s;" onmouseover="this.style.background = '#f8fafc'; this.style.borderColor = 'var(--primary-color)';" onmouseout="this.style.background = '#ffffff'; this.style.borderColor = 'var(--card-border)';">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
                Lịch sử cập nhật
            </button>
        </div>
    </div>

    <!-- Stepper -->
    <c:if test="${receipt.status != 'CANCELLED'}">
        <div class="premium-card no-print" style="padding: 24px 32px; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; position: relative; overflow: hidden;">
            <!-- Connector Line Container -->
            <div style="position: absolute; left: 77px; right: 77px; top: 50%; height: 4px; transform: translateY(-50%); z-index: 1;">
                <!-- Background line -->
                <div style="width: 100%; height: 100%; background: #e2e8f0;"></div>
                <!-- Active line -->
                <div style="position: absolute; top: 0; left: 0; height: 100%; background: var(--primary-color); z-index: 2; transition: width 0.5s ease; width: <c:choose>
                         <c:when test="${receipt.status == 'DRAFT' || receipt.status == 'PENDING_APPROVAL'}">0%</c:when>
                         <c:when test="${receipt.status == 'APPROVED'}">25%</c:when>
                         <c:when test="${receipt.status == 'RECEIVING'}">50%</c:when>
                         <c:when test="${receipt.status == 'RECEIVED'}">75%</c:when>
                         <c:when test="${receipt.status == 'COMPLETED'}">100%</c:when>
                     </c:choose>;"></div>
            </div>

            <!-- Steps -->
            <!-- Step 1: PENDING_APPROVAL -->
            <div style="z-index: 3; display: flex; flex-direction: column; align-items: center; gap: 8px; width: 95px; text-align: center; flex-shrink: 0;">
                <div style="width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;
                     <c:choose>
                         <c:when test="${receipt.status == 'PENDING_APPROVAL' || receipt.status == 'DRAFT'}">background: #d97706; color: #ffffff;</c:when>
                         <c:when test="${receipt.status == 'APPROVED' || receipt.status == 'RECEIVING' || receipt.status == 'RECEIVED' || receipt.status == 'COMPLETED'}">background: #10b981; color: #ffffff;</c:when>
                         <c:otherwise>background: #e2e8f0; color: var(--text-secondary);</c:otherwise>
                     </c:choose>">
                    <c:choose>
                        <c:when test="${receipt.status == 'PENDING_APPROVAL' || receipt.status == 'DRAFT'}">1</c:when>
                        <c:otherwise>✓</c:otherwise>
                    </c:choose>
                </div>
                <span style="font-size: 12px; font-weight: 600; color: ${receipt.status == 'PENDING_APPROVAL' ? '#d97706' : 'var(--text-secondary)'};">Chờ duyệt</span>
            </div>

            <!-- Step 2: APPROVED -->
            <div style="z-index: 3; display: flex; flex-direction: column; align-items: center; gap: 8px; width: 95px; text-align: center; flex-shrink: 0;">
                <div style="width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;
                     <c:choose>
                         <c:when test="${receipt.status == 'APPROVED'}">background: #3b82f6; color: #ffffff;</c:when>
                         <c:when test="${receipt.status == 'RECEIVING' || receipt.status == 'RECEIVED' || receipt.status == 'COMPLETED'}">background: #10b981; color: #ffffff;</c:when>
                         <c:otherwise>background: #e2e8f0; color: var(--text-secondary);</c:otherwise>
                     </c:choose>">
                    <c:choose>
                        <c:when test="${receipt.status == 'DRAFT' || receipt.status == 'PENDING_APPROVAL' || receipt.status == 'APPROVED'}">2</c:when>
                        <c:otherwise>✓</c:otherwise>
                    </c:choose>
                </div>
                <span style="font-size: 12px; font-weight: 600; color: ${receipt.status == 'APPROVED' ? '#3b82f6' : 'var(--text-secondary)'};">Đã duyệt</span>
            </div>

            <!-- Step 3: RECEIVING -->
            <div style="z-index: 3; display: flex; flex-direction: column; align-items: center; gap: 8px; width: 95px; text-align: center; flex-shrink: 0;">
                <div style="width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;
                     <c:choose>
                         <c:when test="${receipt.status == 'RECEIVING'}">background: #8b5cf6; color: #ffffff;</c:when>
                         <c:when test="${receipt.status == 'RECEIVED' || receipt.status == 'COMPLETED'}">background: #10b981; color: #ffffff;</c:when>
                         <c:otherwise>background: #e2e8f0; color: var(--text-secondary);</c:otherwise>
                     </c:choose>">
                    <c:choose>
                        <c:when test="${receipt.status == 'RECEIVED' || receipt.status == 'COMPLETED'}">✓</c:when>
                        <c:otherwise>3</c:otherwise>
                    </c:choose>
                </div>
                <span style="font-size: 12px; font-weight: 600; color: ${receipt.status == 'RECEIVING' ? '#8b5cf6' : 'var(--text-secondary)'};">Nhận hàng</span>
            </div>

            <!-- Step 4: RECEIVED -->
            <div style="z-index: 3; display: flex; flex-direction: column; align-items: center; gap: 8px; width: 95px; text-align: center; flex-shrink: 0;">
                <div style="width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;
                     <c:choose>
                         <c:when test="${receipt.status == 'RECEIVED'}">background: #4f46e5; color: #ffffff;</c:when>
                         <c:when test="${receipt.status == 'COMPLETED'}">background: #10b981; color: #ffffff;</c:when>
                         <c:otherwise>background: #e2e8f0; color: var(--text-secondary);</c:otherwise>
                     </c:choose>">
                    <c:choose>
                        <c:when test="${receipt.status == 'COMPLETED'}">✓</c:when>
                        <c:otherwise>4</c:otherwise>
                    </c:choose>
                </div>
                <span style="font-size: 12px; font-weight: 600; color: ${receipt.status == 'RECEIVED' ? '#4f46e5' : 'var(--text-secondary)'};">Đã nhận hàng</span>
            </div>

            <!-- Step 5: COMPLETED -->
            <div style="z-index: 3; display: flex; flex-direction: column; align-items: center; gap: 8px; width: 95px; text-align: center; flex-shrink: 0;">
                <div style="width: 36px; height: 36px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 14px;
                     <c:choose>
                         <c:when test="${receipt.status == 'COMPLETED'}">background: #10b981; color: #ffffff;</c:when>
                         <c:otherwise>background: #e2e8f0; color: var(--text-secondary);</c:otherwise>
                     </c:choose>">
                    5
                </div>
                <span style="font-size: 12px; font-weight: 600; color: ${receipt.status == 'COMPLETED' ? '#10b981' : 'var(--text-secondary)'};">Hoàn thành</span>
            </div>
        </div>
    </c:if>

    <c:if test="${receipt.status == 'CANCELLED'}">
        <div class="premium-card no-print" style="padding: 20px; margin-bottom: 24px; background: #fef2f2; border: 1.5px solid #fecaca; border-radius: 12px; display: flex; align-items: center; gap: 12px; color: #ef4444;">
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

    <!-- Các form cập nhật trạng thái -->
    <c:if test="${receipt.status != 'COMPLETED'
                  && receipt.status != 'CANCELLED'}">

          <!-- Form nhận hàng, duyệt và hoàn thành -->
          <form action="${pageContext.request.contextPath}/manage/receipts?action=updateStatus&id=${receipt.id}"
                method="post"
                id="statusForm"
                enctype="multipart/form-data"
                style="display:none;">

              <input type="hidden"
                     name="action"
                     value="updateStatus"/>

              <input type="hidden"
                     name="id"
                     value="${receipt.id}"/>

              <input type="hidden"
                     name="status"
                     id="nextStatus"
                     value="${receipt.status == 'RECEIVING' ? 'RECEIVED' : ''}"/>

              <input type="file" id="statusFormReceivingImagesInput" name="receivingImagesFiles" accept="image/*" multiple style="display:none;">

              <c:if test="${receipt.status == 'RECEIVING'}">
                  <c:forEach var="detail" items="${receipt.details}">
                      <div id="hiddenInputs_${detail.id}" class="hidden-detail-inputs" data-detail-id="${detail.id}" data-product-name="${detail.product.name}" data-product-id="${detail.productId}">
                          <input type="hidden" id="actualQuantityHidden_${detail.id}" name="actualQuantity_${detail.id}" class="receiving-quantity-input" value="${detail.quantity}">
                          <input type="hidden" id="batchCode_${detail.id}" name="batchCode_${detail.id}" class="receiving-batch-input" value="${detail.batchCode}">
                          <c:forTokens var="bc" items="${detail.barcode}" delims=",">
                              <input type="hidden" name="barcode_${detail.id}" class="receiving-barcode-input" value="${bc}">
                          </c:forTokens>
                      </div>
                  </c:forEach>
              </c:if>
          </form>

          <!-- Form hủy riêng, không chứa barcode -->
          <form action="${pageContext.request.contextPath}/manage/receipts"
                method="post"
                id="cancelReceiptForm"
                style="display:none;">

              <input type="hidden"
                     name="action"
                     value="cancelReceipt"/>

              <input type="hidden"
                     name="id"
                     value="${receipt.id}"/>
          </form>

    </c:if>

    <c:if test="${receipt.status == 'RECEIVED' || receipt.status == 'COMPLETED'}">
        <!-- Beautiful Print-Ready Goods Receipt Note Document -->
        <div class="premium-card print-section" style="padding: 40px; margin-bottom: 24px; background: #ffffff; border: 2px solid #cbd5e1; border-radius: 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.05); position: relative; overflow: hidden;">

            <!-- Header: Title and Company Info -->
            <div style="border-bottom: 2px solid #cbd5e1; padding-bottom: 20px; margin-bottom: 24px; display: flex; justify-content: space-between; align-items: flex-start;">
                <div>
                    <h2 style="font-size: 26px; font-weight: 800; color: #1e293b; margin: 0; text-transform: uppercase; letter-spacing: 0.5px;">PHIẾU NHẬP KHO</h2>
                    <p style="font-size: 13px; color: #64748b; margin: 4px 0 0 0; font-weight: 600;">Số phiếu: <span style="font-family: monospace; font-size: 14px; color: #0f172a; background: #f1f5f9; padding: 2px 6px; border-radius: 4px;">${receipt.receiptCode}</span></p>
                </div>
                <div style="text-align: right;">
                    <p style="font-size: 12px; color: #64748b; margin: 4px 0 0 0;">Ngày nhận hàng: 
                        <span style="font-weight: 600; color: #334155;">
                            <c:choose>
                                <c:when test="${not empty receipt.getReceivedAt()}">
                                    <fmt:formatDate value="${receipt.getReceivedAt()}" pattern="dd/MM/yyyy HH:mm"/>
                                </c:when>
                                <c:otherwise>
                                    <fmt:formatDate value="${receipt.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
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
                        <span style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700; display: block;">Nhà cung cấp</span>
                        <span style="font-size: 14px; font-weight: 700; color: #0f172a;">${receipt.supplier.name}</span>
                    </div>
                    <div>
                        <span style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700; display: block;">Người tạo đơn nhập (Sales)</span>
                        <span style="font-size: 14px; font-weight: 600; color: #334155;">${receipt.creator.fullName}</span>
                    </div>
                </div>
                <div>
                    <div style="margin-bottom: 12px;">
                        <span style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700; display: block;">Người xác nhận (Director)</span>
                        <span style="font-size: 14px; font-weight: 600; color: #334155;">
                            <c:choose>
                                <c:when test="${not empty receipt.getConfirmer()}">
                                    ${receipt.getConfirmer().fullName}
                                </c:when>
                                <c:otherwise>
                                    <span style="color: #94a3b8; font-style: italic;">Chưa xác nhận</span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                    <div>
                        <span style="font-size: 11px; text-transform: uppercase; color: #64748b; font-weight: 700; display: block;">Người nhận hàng (Thủ kho)</span>
                        <span style="font-size: 14px; font-weight: 600; color: #334155;">
                            <c:choose>
                                <c:when test="${not empty receipt.getReceiver()}">
                                    ${receipt.getReceiver().fullName}
                                </c:when>
                                <c:otherwise>
                                    <span style="color: #94a3b8; font-style: italic;">Chưa nhận hàng</span>
                                </c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>
            </div>

            <!-- Product List Table -->
            <h3 style="font-size: 15px; font-weight: 700; color: #1e293b; margin: 0 0 12px 0; text-transform: uppercase;">
                Chi tiết danh sách hàng thực nhận
            </h3>

            <div style="overflow-x: auto; margin-bottom: 30px;">
                <table style="width: 100%; min-width: 1050px; border-collapse: collapse; font-size: 13px;">
                    <thead>
                        <tr style="background: #f1f5f9; border-bottom: 2px solid #cbd5e1; text-align: left;">
                            <th style="padding: 10px 12px; font-weight: 700; color: #475569;">#</th>
                            <th style="padding: 10px 12px; font-weight: 700; color: #475569;">Mã sản phẩm</th>
                            <th style="padding: 10px 12px; font-weight: 700; color: #475569;">Tên sản phẩm</th>
                            <th style="padding: 10px 12px; font-weight: 700; color: #475569; text-align: right;">Đơn vị</th>
                            <th style="padding: 10px 12px; font-weight: 700; color: #475569; text-align: right; width: 150px;">Số lượng thực nhận</th>
                            <th style="padding: 10px 12px; font-weight: 700; color: #475569; min-width: 190px;">Batch Code</th>
                            <th style="padding: 10px 12px; font-weight: 700; color: #475569; min-width: 280px;">Barcode từng sản phẩm</th>
                        </tr>
                    </thead>

                    <tbody>
                        <c:forEach var="detail" items="${receipt.details}" varStatus="status">
                            <tr style="border-bottom: 1px solid #e2e8f0; vertical-align: top;">
                                <td style="padding: 10px 12px; color: #64748b;">${status.index + 1}</td>
                                <td style="padding: 10px 12px; font-family: monospace; font-weight: 600; color: #0f172a;">${detail.product.sku}</td>
                                <td style="padding: 10px 12px; font-weight: 600; color: #334155;">${detail.product.name}</td>
                                <td style="padding: 10px 12px; text-align: right; color: #64748b;">${detail.product.unit}</td>
                                <td style="padding: 10px 12px; text-align: right; font-weight: 800; color: #10b981; font-size: 14px;">+${detail.quantity}</td>

                                <td style="padding: 10px 12px; text-align: center;">
                                    <c:choose>
                                        <c:when test="${not empty detail.batchCode}">
                                            <div class="render-batch-svg" data-batch="${detail.batchCode}"></div>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #94a3b8; font-style: italic;">Chưa có</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td style="padding: 10px 12px; text-align: center;">
                                    <div class="render-barcode-svg" data-barcode="${detail.barcode}" data-id="doc_${detail.id}" data-product-name="<c:out value='${detail.product.name}'/>" data-quantity="${detail.quantity}" data-detail-id="${detail.id}"></div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <!-- Evidence Images (Inside Document) -->
            <c:if test="${not empty receipt.receivingImages}">
                <h3 style="font-size: 15px; font-weight: 700; color: #1e293b; margin: 0 0 12px 0; text-transform: uppercase;">Ảnh hàng hóa nhận kho làm bằng chứng</h3>
                <div style="display: flex; gap: 12px; flex-wrap: wrap; margin-bottom: 30px;">
                    <c:forEach var="img" items="${receipt.receivingImagesList}">
                        <div style="border: 1px solid #cbd5e1; border-radius: 8px; padding: 4px; background: #ffffff; width: 120px; height: 120px; display: flex; align-items: center; justify-content: center; cursor: pointer; overflow: hidden;" onclick="openLightbox('${pageContext.request.contextPath}${img}')">
                            <img src="${pageContext.request.contextPath}${img}" alt="Ảnh bằng chứng" style="max-width: 100%; max-height: 100%; object-fit: contain; border-radius: 4px;">
                        </div>
                    </c:forEach>
                </div>
            </c:if>

            <div style="margin-top: 50px; display: flex; justify-content: space-between; text-align: center; font-size: 14px;">
                <div style="width: 250px; white-space: nowrap;">
                    <span style="font-weight: 700; display: block; margin-bottom: 75px; text-transform: uppercase; color: #475569;">Người tạo đơn</span>
                    <div style="font-weight: 600; color: #0f172a;">${receipt.creator.fullName}</div>
                </div>
                <div style="width: 250px; white-space: nowrap;">
                    <span style="font-weight: 700; display: block; margin-bottom: 75px; text-transform: uppercase; color: #475569;">Người xác nhận (Phê duyệt)</span>
                    <div style="font-weight: 600; color: #0f172a;">
                        <c:choose>
                            <c:when test="${not empty receipt.getConfirmer()}">
                                ${receipt.getConfirmer().fullName}
                            </c:when>
                            <c:otherwise>
                                <span style="color: #94a3b8; font-style: italic;">.....................................</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div style="width: 250px; white-space: nowrap;">
                    <span style="font-weight: 700; display: block; margin-bottom: 75px; text-transform: uppercase; color: #475569;">Người nhận hàng (Thủ kho)</span>
                    <div style="font-weight: 600; color: #0f172a;">
                        <c:choose>
                            <c:when test="${not empty receipt.getReceiver()}">
                                ${receipt.getReceiver().fullName}
                            </c:when>
                            <c:otherwise>
                                <span style="color: #94a3b8; font-style: italic;">.....................................</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <!-- Action Panel on the bottom right of document card (non-printing) -->
            <div style="margin-top: 30px; display: flex; justify-content: flex-end; gap: 10px; border-top: 1.5px solid #cbd5e1; padding-top: 20px;" class="no-print">
                <c:if test="${receipt.status == 'RECEIVED' && (currentUser.hasRole('ADMIN') || currentUser.hasRole('WAREHOUSE STAFF'))}">
                    <button type="submit" form="statusForm" onclick="document.getElementById('nextStatus').value = 'COMPLETED'" class="premium-btn-primary" style="height: 38px !important; padding: 0 16px; font-size: 13px; font-weight: 600; background: linear-gradient(135deg, #10b981, #059669) !important; box-shadow: 0 4px 14px rgba(16, 185, 129, 0.2) !important; display: inline-flex; align-items: center; gap: 6px; cursor: pointer; border: none; border-radius: 8px; color: white;">
                        Hoàn Thành
                    </button>
                    <button type="button"
                            onclick="cancelReceipt()"
                            class="premium-btn-outline"
                            style="color: #ef4444;
                            border-color: #fecaca;
                            height: 36px !important;
                            padding: 0 16px;
                            font-size: 13px;">
                        Hủy phiếu
                    </button>
                </c:if>
                <button type="button" onclick="window.print()" class="premium-btn-outline" style="height: 38px !important; padding: 0 16px; font-size: 13px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; cursor: pointer; border: 1px solid var(--card-border); border-radius: 8px; background: transparent; color: var(--text-primary);">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 6 2 18 2 18 9"></polyline><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path><rect x="6" y="14" width="12" height="8"></rect></svg>
                    In Phiếu Nhập Kho
                </button>
            </div>

        </div>
    </c:if>

    <c:if test="${receipt.status != 'RECEIVED' && receipt.status != 'COMPLETED'}">
        <!-- Actions & Evidence Images Panel -->
        <!-- Actions & Evidence Images Panel -->
        <div class="premium-card no-print" style="padding: 24px; margin-bottom: 24px; display: flex; flex-direction: column; gap: 20px;">

            <!-- Header Section (Title + Align Right Buttons) -->
            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1.5px solid var(--card-border); padding-bottom: 12px; margin-bottom: 4px; flex-wrap: wrap; gap: 12px;">
                <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0; display: flex; align-items: center; gap: 8px;">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="var(--primary-color)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
                    <c:choose>
                        <c:when test="${receipt.status == 'DRAFT' || receipt.status == 'PENDING_APPROVAL' || receipt.status == 'APPROVED'}">
                            Hình ảnh chứng từ
                        </c:when>
                        <c:otherwise>
                            Hình ảnh chứng từ & Bằng chứng
                        </c:otherwise>
                    </c:choose>
                </h3>

                <!-- Right-aligned action buttons -->
                <c:if test="${receipt.status != 'COMPLETED' && receipt.status != 'CANCELLED'}">
                    <c:choose>
                        <c:when test="${receipt.status == 'DRAFT'}">
                            <div style="display: flex; gap: 8px;">
                                <button type="submit" form="statusForm" onclick="document.getElementById('nextStatus').value = 'PENDING_APPROVAL'" class="premium-btn-primary" style="height: 36px !important; padding: 0 16px; font-size: 13px; font-weight: 600;">
                                    Gửi yêu cầu duyệt
                                </button>
                                <c:if test="${currentUser.hasPermission('RECEIPT_WRITE')}">
                                    <a href="${pageContext.request.contextPath}/manage/receipts?action=delete&id=${receipt.id}" 
                                       class="premium-btn-outline" 
                                       onclick="return confirm('Bạn có chắc chắn muốn xóa phiếu nhập nháp này không? Hành động này không thể hoàn tác.');"
                                       style="display: inline-flex; align-items: center; justify-content: center; height: 36px !important; padding: 0 16px; font-size: 13px; text-decoration: none; color: #ef4444; border-color: rgba(239, 68, 68, 0.4); font-weight: 600; border-radius: 8px; transition: all 0.2s;"
                                       onmouseover="this.style.background = 'rgba(239, 68, 68, 0.05)'; this.style.borderColor = '#ef4444';"
                                       onmouseout="this.style.background = 'transparent'; this.style.borderColor = 'rgba(239, 68, 68, 0.4)';">
                                        Xóa phiếu nháp
                                    </a>
                                </c:if>
                                <button type="button"
                                        onclick="cancelReceipt()"
                                        class="premium-btn-outline"
                                        style="color: #ef4444;
                                        border-color: #fecaca;
                                        height: 36px !important;
                                        padding: 0 16px;
                                        font-size: 13px;">
                                    Hủy phiếu
                                </button>
                            </div>
                        </c:when>

                        <c:when test="${receipt.status == 'PENDING_APPROVAL'}">
                            <c:choose>
                                <c:when test="${currentUser.hasRole('ADMIN') || currentUser.hasRole('DIRECTOR')}">
                                    <div style="display: flex; gap: 8px;">
                                        <button type="submit" form="statusForm" onclick="document.getElementById('nextStatus').value = 'APPROVED'" class="premium-btn-primary" style="height: 36px !important; padding: 0 16px; font-size: 13px; background: linear-gradient(135deg, #10b981, #059669) !important; box-shadow: 0 4px 14px rgba(16, 185, 129, 0.2) !important;">
                                            Phê duyệt phiếu
                                        </button>
                                        <button type="button"
                                                onclick="cancelReceipt()"
                                                class="premium-btn-outline"
                                                style="color: #ef4444;
                                                border-color: #fecaca;
                                                height: 36px !important;
                                                padding: 0 16px;
                                                font-size: 13px;">
                                            Từ chối & Hủy
                                        </button>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="background: rgba(245, 158, 11, 0.05); border: 1px solid #fde68a; border-radius: 6px; padding: 6px 12px; font-size: 12px; color: #d97706; font-weight: 600;">
                                        Đang chờ Giám đốc hoặc Admin phê duyệt...
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:when>

                        <c:when test="${receipt.status == 'APPROVED'}">
                            <c:choose>
                                <c:when test="${currentUser.hasRole('ADMIN') || currentUser.hasRole('WAREHOUSE STAFF')}">
                                    <div style="display: flex; gap: 8px;">
                                        <button type="submit" form="statusForm" onclick="document.getElementById('nextStatus').value = 'RECEIVING'" class="premium-btn-primary" style="height: 36px !important; padding: 0 16px; font-size: 13px; background: linear-gradient(135deg, #8b5cf6, #7c3aed) !important; box-shadow: 0 4px 14px rgba(139, 92, 246, 0.2) !important;">
                                            Bắt đầu nhận hàng
                                        </button>
                                        <button type="button"
                                                onclick="cancelReceipt()"
                                                class="premium-btn-outline"
                                                style="color: #ef4444;
                                                border-color: #fecaca;
                                                height: 36px !important;
                                                padding: 0 16px;
                                                font-size: 13px;">
                                            Hủy phiếu
                                        </button>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="background: rgba(59, 130, 246, 0.05); border: 1px solid #bfdbfe; border-radius: 6px; padding: 6px 12px; font-size: 12px; color: #1d4ed8; font-weight: 600;">
                                        Chờ Nhân viên kho (Warehouse Staff) thực hiện nhận hàng...
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:when>

                        <c:when test="${receipt.status == 'RECEIVING'}">
                            <c:choose>
                                <c:when test="${currentUser.hasRole('ADMIN') || currentUser.hasRole('WAREHOUSE STAFF')}">
                                    <div style="display: flex; gap: 8px;">
                                        <button type="submit" form="statusForm" onclick="document.getElementById('nextStatus').value = 'RECEIVED'" class="premium-btn-primary" style="height: 36px !important; padding: 0 16px; font-size: 13px; background: linear-gradient(135deg, #4f46e5, #4338ca) !important; box-shadow: 0 4px 14px rgba(79, 70, 229, 0.2) !important;">
                                            Tạo đơn nhận hàng thành công (Xác nhận)
                                        </button>
                                        <button type="button"
                                                onclick="cancelReceipt()"
                                                class="premium-btn-outline"
                                                style="color: #ef4444;
                                                border-color: #fecaca;
                                                height: 36px !important;
                                                padding: 0 16px;
                                                font-size: 13px;">
                                            Hủy phiếu
                                        </button>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="background: rgba(139, 92, 246, 0.05); border: 1px solid #ddd6fe; border-radius: 6px; padding: 6px 12px; font-size: 12px; color: #6d28d9; font-weight: 600;">
                                        Nhân viên kho (Warehouse Staff) đang thực hiện kiểm tra và nhận hàng...
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:when>

                        <c:when test="${receipt.status == 'RECEIVED'}">
                            <c:choose>
                                <c:when test="${currentUser.hasRole('ADMIN') || currentUser.hasRole('WAREHOUSE STAFF')}">
                                    <div style="display: flex; gap: 8px;">
                                        <button type="submit" form="statusForm" onclick="document.getElementById('nextStatus').value = 'COMPLETED'" class="premium-btn-primary" style="height: 36px !important; padding: 0 16px; font-size: 13px; background: linear-gradient(135deg, #10b981, #059669) !important; box-shadow: 0 4px 14px rgba(16, 185, 129, 0.2) !important;">
                                            Hoàn Thành
                                        </button>
                                        <button type="button"
                                                onclick="cancelReceipt()"
                                                class="premium-btn-outline"
                                                style="color: #ef4444;
                                                border-color: #fecaca;
                                                height: 36px !important;
                                                padding: 0 16px;
                                                font-size: 13px;">
                                            Hủy phiếu
                                        </button>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div style="background: rgba(79, 70, 229, 0.05); border: 1px solid #c7d2fe; border-radius: 6px; padding: 6px 12px; font-size: 12px; color: #4338ca; font-weight: 600;">
                                        Chờ Nhân viên kho thực hiện cất hàng và hoàn thành nhập kho...
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:when>
                    </c:choose>
                </c:if>
            </div>

            <!-- Images Grid -->
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 20px;">
                <!-- Card 1: Ảnh hóa đơn -->
                <div style="background: #ffffff; border: 1px solid var(--card-border); padding: 16px; border-radius: 10px; display: flex; flex-direction: column; gap: 12px;">
                    <div style="font-size: 13px; font-weight: 600; color: var(--text-secondary);">Ảnh hóa đơn yêu cầu nhập kho</div>
                    <c:choose>
                        <c:when test="${not empty receipt.invoiceImage}">
                            <div style="position: relative; overflow: hidden; border-radius: 8px; border: 1.5px solid var(--card-border); padding: 4px; background: #f8fafc; display: flex; align-items: center; justify-content: center; height: 160px;">
                                <a href="javascript:void(0)" onclick="openLightbox('${pageContext.request.contextPath}${receipt.invoiceImage}')" style="display: block; width: 100%; height: 100%; text-align: center;">
                                    <img src="${pageContext.request.contextPath}${receipt.invoiceImage}" alt="Ảnh hóa đơn" style="height: 100%; max-width: 100%; object-fit: contain; border-radius: 6px; transition: transform 0.2s;" onmouseover="this.style.transform = 'scale(1.03)'" onmouseout="this.style.transform = 'scale(1.0)'">
                                </a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div style="height: 160px; display: flex; align-items: center; justify-content: center; border: 1.5px dashed var(--card-border); border-radius: 8px; text-align: center; color: var(--text-secondary); font-size: 13px; background: #f8fafc;">
                                Chưa có ảnh hóa đơn
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <c:if test="${receipt.status != 'COMPLETED' && receipt.status != 'CANCELLED'}">
                        <form action="${pageContext.request.contextPath}/manage/receipts" method="post" enctype="multipart/form-data" style="display: flex; flex-direction: column; gap: 8px;">
                            <input type="hidden" name="action" value="updateInvoiceImage"/>
                            <input type="hidden" name="id" value="${receipt.id}"/>
                            <div style="display: flex; flex-direction: column; gap: 6px;">
                                <input type="file" name="invoiceImageFile" accept="image/*" required style="font-size: 12px; width: 100%;">
                                <button type="submit" class="premium-btn-secondary" style="height: 32px; font-size: 12px; display: inline-flex; align-items: center; justify-content: center; width: 100%; border-radius: 6px; background: rgba(4, 138, 191, 0.05); border: 1.5px solid var(--primary-color); color: var(--primary-color); font-weight: 600; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background = 'var(--primary-color)'; this.style.color = '#fff';" onmouseout="this.style.background = 'rgba(4, 138, 191, 0.05)'; this.style.color = 'var(--primary-color)';">
                                    Cập nhật ảnh hóa đơn
                                </button>
                            </div>
                        </form>
                    </c:if>
                </div>

                <!-- Card 2: Ảnh hàng hóa đã nhận (Bằng chứng) -->
                <c:if test="${receipt.status == 'RECEIVING' || receipt.status == 'RECEIVED' || receipt.status == 'COMPLETED' || not empty receipt.receivingImages}">
                    <div style="background: #ffffff; border: 1px solid var(--card-border); padding: 16px; border-radius: 10px; display: flex; flex-direction: column; gap: 12px;">
                        <div style="font-size: 13px; font-weight: 600; color: var(--text-secondary);">Ảnh hàng hóa đã nhận (Bằng chứng)</div>
                        <c:choose>
                            <c:when test="${not empty receipt.receivingImages}">
                                <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; background: #f8fafc; padding: 8px; border-radius: 8px; border: 1.5px solid var(--card-border); max-height: 180px; overflow-y: auto;">
                                    <c:forEach var="img" items="${receipt.receivingImagesList}">
                                        <div style="position: relative; border-radius: 6px; border: 1px solid var(--card-border); padding: 2px; background: #ffffff; display: flex; align-items: center; justify-content: center; height: 75px;">
                                            <a href="javascript:void(0)" onclick="openLightbox('${pageContext.request.contextPath}${img}')" style="display: block; width: 100%; height: 100%; text-align: center;">
                                                <img src="${pageContext.request.contextPath}${img}" alt="Ảnh nhận hàng" style="height: 100%; max-width: 100%; object-fit: contain; border-radius: 4px; transition: transform 0.2s;" onmouseover="this.style.transform = 'scale(1.05)'" onmouseout="this.style.transform = 'scale(1.0)'">
                                            </a>
                                            <c:if test="${receipt.status == 'RECEIVING' || receipt.status == 'RECEIVED'}">
                                                <a href="${pageContext.request.contextPath}/manage/receipts?action=deleteReceivingImage&id=${receipt.id}&imageUrl=${img}"
                                                   onclick="return confirm('Bạn có chắc chắn muốn xóa ảnh bằng chứng này không?');"
                                                   title="Xóa ảnh bằng chứng này"
                                                   style="position: absolute; top: -6px; right: -6px; width: 22px; height: 22px; border-radius: 50%; background: #ef4444; color: #ffffff; display: flex; align-items: center; justify-content: center; text-decoration: none; font-size: 14px; font-weight: bold; line-height: 1; z-index: 10; box-shadow: 0 2px 4px rgba(0,0,0,0.25);"
                                                   onmouseover="this.style.background = '#dc2626'" onmouseout="this.style.background = '#ef4444'">
                                                    &times;
                                                </a>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div style="height: 120px; display: flex; align-items: center; justify-content: center; border: 1.5px dashed var(--card-border); border-radius: 8px; text-align: center; color: var(--text-secondary); font-size: 13px; background: #f8fafc;">
                                    Chưa có ảnh nhận hàng (bằng chứng)
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <c:if test="${receipt.status == 'RECEIVING' || receipt.status == 'RECEIVED'}">
                            <form action="${pageContext.request.contextPath}/manage/receipts" method="post" enctype="multipart/form-data" style="display: flex; flex-direction: column; gap: 8px;" id="updateReceivingImagesForm">
                                <input type="hidden" name="action" value="updateReceivingImages"/>
                                <input type="hidden" name="id" value="${receipt.id}"/>
                                <div style="display: flex; flex-direction: column; gap: 6px; margin-top: 4px;">
                                    <label style="font-size: 12px; font-weight: 600; color: var(--text-secondary);">
                                        <c:choose>
                                            <c:when test="${not empty receipt.receivingImages}">Tải thêm / Bổ sung ảnh bằng chứng:</c:when>
                                            <c:otherwise>Tải lên ảnh nhận hàng làm bằng chứng:</c:otherwise>
                                        </c:choose>
                                    </label>
                                    <input type="file" name="receivingImagesFiles" id="updateReceivingImagesInput" accept="image/*" multiple style="font-size: 12px; width: 100%;">
                                    <button type="submit" class="premium-btn-secondary" style="height: 32px; font-size: 12px; display: inline-flex; align-items: center; justify-content: center; width: 100%; border-radius: 6px; background: rgba(139, 92, 246, 0.05); border: 1.5px solid #8b5cf6; color: #8b5cf6; font-weight: 600; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background = '#8b5cf6'; this.style.color = '#fff';" onmouseout="this.style.background = 'rgba(139, 92, 246, 0.05)'; this.style.color = '#8b5cf6';">
                                        <c:choose>
                                            <c:when test="${not empty receipt.receivingImages}">+ Tải thêm ảnh bằng chứng</c:when>
                                            <c:otherwise>Tải lên ảnh nhận hàng</c:otherwise>
                                        </c:choose>
                                    </button>
                                </div>
                            </form>
                        </c:if>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <!-- Combined Information & Products Card -->
    <div class="premium-card no-print" style="padding: 24px; margin-bottom: 24px;">

        <!-- Metadata Grid (General Information) -->
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; background: #f8fafc; border: 1.5px solid var(--card-border); border-radius: 12px; padding: 20px; margin-bottom: 24px;">
            <!-- Supplier -->
            <div style="display: flex; align-items: flex-start; gap: 12px;">
                <div style="background: rgba(4, 138, 191, 0.08); padding: 8px; border-radius: 8px; color: var(--primary-color);">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                </div>
                <div>
                    <div style="font-size: 11px; color: var(--text-secondary); margin-bottom: 2px; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 700;">Nhà cung cấp</div>
                    <div style="font-size: 14px; font-weight: 600; color: var(--text-primary);">${receipt.supplier.name}</div>
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
                        <fmt:formatDate value="${receipt.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                    </div>
                </div>
            </div>

            <!-- Creator -->
            <div style="display: flex; align-items: flex-start; gap: 12px;">
                <div style="background: rgba(4, 138, 191, 0.08); padding: 8px; border-radius: 8px; color: var(--primary-color);">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                </div>
                <div>
                    <div style="font-size: 11px; color: var(--text-secondary); margin-bottom: 2px; text-transform: uppercase; letter-spacing: 0.5px; font-weight: 700;">Người tạo</div>
                    <div style="font-size: 14px; font-weight: 600; color: var(--text-primary);">${receipt.creator.fullName}</div>
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
                            <c:when test="${receipt.status == 'DRAFT'}">
                                <span class="premium-tag" style="background: rgba(100, 116, 139, 0.1); color: #64748b; font-weight: 600;">Nháp</span>
                            </c:when>
                            <c:when test="${receipt.status == 'PENDING_APPROVAL'}">
                                <span class="premium-tag" style="background: rgba(245, 158, 11, 0.1); color: #d97706; font-weight: 600;">Chờ phê duyệt</span>
                            </c:when>
                            <c:when test="${receipt.status == 'APPROVED'}">
                                <span class="premium-tag" style="background: rgba(59, 130, 246, 0.1); color: #3b82f6; font-weight: 600;">Đã duyệt</span>
                            </c:when>
                            <c:when test="${receipt.status == 'RECEIVING'}">
                                <span class="premium-tag" style="background: rgba(139, 92, 246, 0.1); color: #8b5cf6; font-weight: 600;">Đang nhận hàng</span>
                            </c:when>
                            <c:when test="${receipt.status == 'RECEIVED'}">
                                <span class="premium-tag" style="background: rgba(79, 70, 229, 0.1); color: #4f46e5; font-weight: 600;">Đã nhận hàng</span>
                            </c:when>
                            <c:when test="${receipt.status == 'COMPLETED'}">
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

        <!-- Notes if present -->
        <c:if test="${not empty receipt.notes}">
            <div style="background: rgba(248, 250, 252, 0.6); border: 1.5px dashed var(--card-border); border-radius: 8px; padding: 14px 18px; margin-bottom: 24px;">
                <span style="font-size: 13px; font-weight: 600; color: var(--text-secondary); display: block; margin-bottom: 4px;">Ghi chú:</span>
                <span style="font-size: 14px; color: var(--text-primary); line-height: 1.5;">${receipt.notes}</span>
            </div>
        </c:if>

        <!-- Product list Section -->
        <h3 style="font-size: 16px; font-weight: 700; color: var(--text-primary); margin: 0 0 16px 0; border-bottom: 1px solid var(--card-border); padding-bottom: 12px; display: flex; align-items: center; gap: 8px;">
            Danh sách sản phẩm nhập kho
        </h3>

        <c:set var="showTrackingCodes" value="${receipt.status == 'RECEIVING' || receipt.status == 'RECEIVED' || receipt.status == 'COMPLETED'}"/>
        <c:set var="canEditReceiving" value="${receipt.status == 'RECEIVING' && (currentUser.hasRole('ADMIN') || currentUser.hasRole('WAREHOUSE STAFF'))}"/>

        <div style="overflow-x: auto;">
            <table style="width: 100%; border-collapse: collapse;">
                <thead>
                    <tr>
                        <th style="text-align:left;padding:12px 16px;border-bottom:2px solid var(--card-border);font-size:13px;color:var(--text-secondary);">SKU</th>
                        <th style="text-align:left;padding:12px 16px;border-bottom:2px solid var(--card-border);font-size:13px;color:var(--text-secondary);">Tên sản phẩm</th>
                        <th style="text-align:right;padding:12px 16px;border-bottom:2px solid var(--card-border);font-size:13px;color:var(--text-secondary);">Đơn vị</th>
                        <th style="text-align:right;padding:12px 16px;border-bottom:2px solid var(--card-border);font-size:13px;color:var(--text-secondary);min-width:190px;">Số lượng nhập</th>
                            <c:if test="${showTrackingCodes}">
                            <th style="text-align:left;padding:12px 16px;border-bottom:2px solid var(--card-border);font-size:13px;color:var(--text-secondary);min-width:230px;">Batch Code</th>
                            <th style="text-align:left;padding:12px 16px;border-bottom:2px solid var(--card-border);font-size:13px;color:var(--text-secondary);min-width:340px;">Barcode từng sản phẩm</th>
                            </c:if>
                    </tr>
                </thead>
                <tbody>
                    <c:set var="totalItems" value="0"/>
                    <c:forEach var="detail" items="${receipt.details}">
                        <tr>
                            <td style="padding:12px 16px;border-bottom:1px solid var(--card-border);font-family:monospace;">${detail.product.sku}</td>
                            <td style="padding:12px 16px;border-bottom:1px solid var(--card-border);font-weight:600;">${detail.product.name}</td>
                            <td style="padding:12px 16px;border-bottom:1px solid var(--card-border);text-align:right;">${detail.product.unit}</td>
                            <td style="padding:12px 16px;border-bottom:1px solid var(--card-border);text-align:right;">
                                <c:choose>
                                    <c:when test="${canEditReceiving}">
                                        <div style="display:flex;justify-content:flex-end;align-items:center;gap:8px;">
                                            <span style="font-size:12px;">Yêu cầu: ${detail.quantity} → Thực nhận:</span>
                                            <input type="number" id="actualQuantity_${detail.id}" name="actualQuantity_${detail.id}" form="statusForm" value="${detail.quantity}" min="1" required class="receiving-quantity-input" data-detail-id="${detail.id}" style="width:80px;padding:6px 8px;border:1.5px solid var(--primary-color);border-radius:6px;">
                                        </div>
                                    </c:when>
                                    <c:otherwise>+${detail.quantity}</c:otherwise>
                                </c:choose>
                            </td>

                            <c:if test="${showTrackingCodes}">
                                <td style="padding:12px 16px;border-bottom:1px solid var(--card-border);vertical-align:middle;">
                                    <c:choose>
                                        <c:when test="${canEditReceiving}">
                                            <input type="text" id="batchCodeInput_${detail.id}" name="batchCode_${detail.id}" form="statusForm" value="${not empty detail.batchCode ? detail.batchCode : ('BAT-'.concat(receipt.receiptCode).concat('-').concat(detail.id))}" placeholder="Nhập Batch Code..." style="font-family:monospace;font-size:12px;padding:4px 8px;border-radius:6px;border:1.5px solid #c084fc;background:#faf5ff;color:#6b21a8;font-weight:700;width:170px;" onchange="const hiddenB = document.getElementById('batchCode_${detail.id}'); if(hiddenB) hiddenB.value = this.value.trim();">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="render-batch-svg" data-batch="${detail.batchCode}"></div>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="padding:12px 16px;border-bottom:1px solid var(--card-border);vertical-align:middle;">
                                    <c:choose>
                                        <c:when test="${canEditReceiving}">
                                            <div style="display:flex;align-items:center;justify-content:space-between;gap:8px;flex-wrap:wrap;">
                                                <span id="badge_barcode_${detail.id}" style="display:inline-block;font-family:monospace;font-size:11px;padding:4px 8px;border-radius:6px;background:#eff6ff;color:#1d4ed8;font-weight:700;border:1px solid #bfdbfe;">
                                                    Barcode: ${not empty detail.barcode ? 'Đã khởi tạo' : 'Đang khởi tạo...'}
                                                </span>
                                                <button type="button" onclick="openReceivingModal('${detail.id}', '<c:out value="${detail.product.name}"/>', '${detail.productId}')" style="padding:5px 12px;border:1.5px solid #2563eb;background:#eff6ff;color:#2563eb;border-radius:8px;font-size:12px;font-weight:700;cursor:pointer;display:inline-flex;align-items:center;gap:6px;transition:all 0.2s;" onmouseover="this.style.background='#dbeafe';" onmouseout="this.style.background='#eff6ff';">
                                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg>
                                                    Tạo / Sửa Batch & Barcode
                                                </button>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                             <div class="render-barcode-svg" data-barcode="${detail.barcode}" data-id="tbl_${detail.id}" data-product-name="${detail.product.name}" data-quantity="${detail.quantity}" data-detail-id="${detail.id}"></div>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </c:if>
                        </tr>
                        <c:set var="totalItems" value="${totalItems + detail.quantity}"/>
                    </c:forEach>
                </tbody>
                <tfoot><tr>
                        <td colspan="${showTrackingCodes ? 5 : 3}" style="text-align:right;padding:16px 12px;font-weight:700;">Tổng số lượng nhập:</td>
                        <td style="text-align:right;padding:16px 12px;font-weight:800;color:var(--primary-color);">+${totalItems}</td>
                    </tr></tfoot>
            </table>
        </div>
    </div>
</c:if>

<!-- Popup Modal Cấu hình Batch Code & Barcode (Dành cho bước 3 Nhận hàng) -->
<div id="receivingConfigModal" style="display: none; position: fixed; inset: 0; z-index: 9999; background: rgba(15, 23, 42, 0.65); backdrop-filter: blur(4px); align-items: center; justify-content: center; opacity: 0; transition: opacity 0.25s ease;">
    <div style="background: #ffffff; width: 95%; max-width: 680px; max-height: 85vh; border-radius: 16px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25); display: flex; flex-direction: column; overflow: hidden; animation: modalFadeIn 0.25s ease;">
        <!-- Header -->
        <div style="padding: 18px 24px; border-bottom: 1px solid var(--card-border); display: flex; justify-content: space-between; align-items: center; background: #f8fafc;">
            <div>
                <h3 id="modalProductName" style="margin: 0; font-size: 16px; font-weight: 800; color: #0f172a;">Tên sản phẩm</h3>
                <span id="modalQuantityInfo" style="font-size: 12px; color: #64748b; font-weight: 600; margin-top: 2px; display: block;">Số lượng thực nhận: 0</span>
            </div>
            <button type="button" onclick="closeReceivingModal()" style="border: none; background: #e2e8f0; color: #64748b; width: 32px; height: 32px; border-radius: 8px; font-size: 18px; font-weight: 700; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.2s;" onmouseover="this.style.background='#cbd5e1'; this.style.color='#0f172a';" onmouseout="this.style.background='#e2e8f0'; this.style.color='#64748b';">✕</button>
        </div>

        <!-- Body -->
        <div style="padding: 20px 24px; overflow-y: auto; flex: 1; display: flex; flex-direction: column; gap: 20px;">
            <!-- Section 1: Batch Code -->
            <div style="background: #faf5ff; border: 1.5px solid #ddd6fe; border-radius: 12px; padding: 16px; display: flex; flex-direction: column; gap: 8px;">
                <label style="font-size: 12px; font-weight: 700; color: #6d28d9; text-transform: uppercase; letter-spacing: 0.5px;">Mã lô sản phẩm (Batch Code)</label>
                <div style="display: flex; gap: 10px;">
                    <input type="text" id="modalBatchCodeInput" style="flex: 1; padding: 8px 12px; border: 1.5px solid #c4b5fd; border-radius: 8px; font-family: monospace; font-size: 13px; outline: none; background: #ffffff;" placeholder="Nhập Batch Code (ví dụ: BAT-PN-...)">
                    <button type="button" id="modalGenerateBatchBtn" style="height: 38px; padding: 0 16px; background: #6d28d9; color: #ffffff; border: none; border-radius: 8px; font-weight: 700; font-size: 12px; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background='#5b21b6';" onmouseout="this.style.background='#6d28d9';">Tạo Batch Code</button>
                </div>
            </div>

            <!-- Section 2: Barcode list -->
            <div style="background: #eff6ff; border: 1.5px solid #bfdbfe; border-radius: 12px; padding: 16px; display: flex; flex-direction: column; gap: 12px;">
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
                    <label style="font-size: 12px; font-weight: 700; color: #1d4ed8; text-transform: uppercase; letter-spacing: 0.5px;">Danh sách Barcode từng sản phẩm</label>
                    <button type="button" id="modalGenerateAllBarcodesBtn" style="height: 32px; padding: 0 14px; background: #2563eb; color: #ffffff; border: none; border-radius: 6px; font-weight: 700; font-size: 12px; cursor: pointer; transition: all 0.2s;" onmouseover="this.style.background='#1d4ed8';" onmouseout="this.style.background='#2563eb';">Tạo tất cả Barcode</button>
                </div>

                <div id="modalBarcodeListContainer" style="max-height: 300px; overflow-y: auto; display: flex; flex-direction: column; gap: 8px; background: #ffffff; padding: 12px; border-radius: 8px; border: 1px solid #cbd5e1;">
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div style="padding: 16px 24px; border-top: 1px solid var(--card-border); display: flex; justify-content: flex-end; gap: 12px; background: #f8fafc;">
            <button type="button" onclick="closeReceivingModal()" style="padding: 8px 18px; border: 1.5px solid #cbd5e1; background: #ffffff; color: #334155; border-radius: 8px; font-size: 13px; font-weight: 700; cursor: pointer;">Hủy</button>
            <button type="button" onclick="applyAndCloseReceivingModal()" style="padding: 8px 20px; background: linear-gradient(135deg, #10b981, #059669); color: #ffffff; border: none; border-radius: 8px; font-weight: 700; font-size: 13px; cursor: pointer; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.25);">Lưu & Áp dụng</button>
        </div>
    </div>
</div>

<!-- Popup Modal Xem tất cả Barcode (Bước 4 & 5) -->
<div id="barcodeViewModal" onclick="if(event.target===this)closeBarcodeViewModal()" style="display:none;position:fixed;inset:0;z-index:9999;background:rgba(15,23,42,0.65);backdrop-filter:blur(4px);align-items:center;justify-content:center;opacity:0;transition:opacity 0.25s ease;">
    <div style="background:#fff;width:95%;max-width:860px;max-height:88vh;border-radius:16px;box-shadow:0 25px 50px -12px rgba(0,0,0,0.3);display:flex;flex-direction:column;overflow:hidden;">
        <!-- Header -->
        <div style="padding:18px 24px;border-bottom:1.5px solid #e2e8f0;display:flex;justify-content:space-between;align-items:center;background:linear-gradient(to right,#f8fafc,#fff);">
            <div>
                <h3 style="margin:0;font-size:17px;font-weight:700;color:#1e293b;display:flex;align-items:center;gap:8px;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#2563eb" stroke-width="2.2"><rect x="3" y="4" width="18" height="16" rx="2"/><line x1="7" y1="8" x2="17" y2="8"/><line x1="7" y1="12" x2="17" y2="12"/><line x1="7" y1="16" x2="13" y2="16"/></svg>
                    Barcode: <span id="bvmProductName" style="color:#2563eb;">-</span>
                </h3>
                <div style="font-size:12px;color:#64748b;margin-top:4px;">Tất cả mã vạch của sản phẩm trong phiếu nhập này</div>
            </div>
            <button type="button" onclick="closeBarcodeViewModal()" style="background:none;border:none;font-size:26px;color:#94a3b8;cursor:pointer;border-radius:8px;width:38px;height:38px;display:flex;align-items:center;justify-content:center;transition:all 0.2s;" onmouseover="this.style.background='#f1f5f9';this.style.color='#0f172a';" onmouseout="this.style.background='none';this.style.color='#94a3b8';">&times;</button>
        </div>
        <!-- Search bar -->
        <div style="padding:14px 24px 0;display:flex;gap:12px;align-items:center;">
            <div style="flex:1;position:relative;">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#94a3b8" stroke-width="2" style="position:absolute;left:12px;top:50%;transform:translateY(-50%);"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input id="bvmSearchInput" type="text" oninput="bvmSearch()" placeholder="Tìm mã barcode..." style="width:100%;padding:9px 12px 9px 36px;border:1.5px solid #cbd5e1;border-radius:10px;font-size:13px;outline:none;transition:border-color 0.2s;box-sizing:border-box;" onfocus="this.style.borderColor='#2563eb';" onblur="this.style.borderColor='#cbd5e1';">
            </div>
            <span id="bvmBadge" style="font-size:12px;font-weight:700;background:#eff6ff;color:#1d4ed8;padding:6px 14px;border-radius:8px;border:1px solid #bfdbfe;white-space:nowrap;">0 mã vạch</span>
        </div>
        <!-- Grid -->
        <div style="padding:14px 24px;flex:1;overflow-y:auto;">
            <div id="bvmGrid" style="display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:12px;max-height:50vh;overflow-y:auto;padding:12px;border:1.5px solid #e2e8f0;border-radius:12px;background:#f8fafc;box-sizing:border-box;">
                <!-- populated by JS -->
            </div>
        </div>
        <!-- Footer -->
        <div style="padding:14px 24px;border-top:1.5px solid #e2e8f0;display:flex;justify-content:flex-end;gap:10px;background:#f8fafc;">
            <button type="button" onclick="closeBarcodeViewModal()" style="padding:8px 24px;border:1.5px solid #cbd5e1;background:#fff;color:#334155;border-radius:8px;font-size:13px;font-weight:700;cursor:pointer;transition:all 0.2s;" onmouseover="this.style.background='#f1f5f9';" onmouseout="this.style.background='#fff';">Đóng</button>
        </div>
    </div>
</div>


<!-- History Modal -->
<div id="historyModal" class="modal" style="display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(15, 23, 42, 0.4); backdrop-filter: blur(4px); transition: all 0.3s ease;">
    <div class="modal-content" style="background-color: #ffffff; margin: 10% auto; padding: 24px; border-radius: 12px; border: 1px solid var(--card-border); width: 90%; max-width: 600px; box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04); position: relative; animation: modalFadeIn 0.3s ease;">
        <span id="closeHistoryModal" style="position: absolute; right: 20px; top: 16px; font-size: 24px; font-weight: bold; color: var(--text-secondary); cursor: pointer; transition: color 0.2s;" onmouseover="this.style.color = 'var(--primary-color)'" onmouseout="this.style.color = 'var(--text-secondary)'">&times;</span>
        <h3 style="font-size: 18px; font-weight: 700; color: var(--text-primary); margin: 0 0 20px 0; padding-bottom: 12px; border-bottom: 1.5px solid var(--card-border); display: flex; align-items: center; gap: 8px;">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="var(--primary-color)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><polyline points="12 6 12 12 16 14"></polyline></svg>
            Lịch sử cập nhật trạng thái
        </h3>

        <div style="max-height: 400px; overflow-y: auto; padding-right: 8px; display: flex; flex-direction: column; gap: 16px; position: relative; padding-left: 20px;">
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
                <div style="padding: 30px; text-align: center; color: var(--text-secondary); font-size: 13px;">
                    Chưa có lịch sử cập nhật.
                </div>
            </c:if>
        </div>
    </div>
</div>

<!-- Image Lightbox Modal -->
<div id="imageLightbox" style="display: none; position: fixed; z-index: 2000; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(15, 23, 42, 0.85); backdrop-filter: blur(8px); justify-content: center; align-items: center;">
    <span id="closeLightbox" style="position: absolute; right: 24px; top: 24px; font-size: 36px; font-weight: bold; color: #ffffff; cursor: pointer; transition: color 0.2s;" onmouseover="this.style.color = 'var(--primary-color)'" onmouseout="this.style.color = '#ffffff'">&times;</span>
    <img id="lightboxImage" src="" alt="Ảnh phóng to" style="max-width: 90%; max-height: 90%; object-fit: contain; border-radius: 8px; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5); animation: zoomIn 0.25s ease;">
</div>

<style>
    @keyframes modalFadeIn {
        from {
            opacity: 0;
            transform: translateY(-20px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    @keyframes zoomIn {
        from {
            transform: scale(0.9);
            opacity: 0;
        }
        to {
            transform: scale(1);
            opacity: 1;
        }
    }
</style>

<script>
    function textToBarcodeSvgHtml(text, theme) {
        if (!text || !text.trim()) return '<span style="color: #94a3b8; font-style: italic; font-size: 12px;">Chưa có</span>';
        text = text.trim();
        
        let bars = [2, 1, 3, 1, 2];
        for (let i = 0; i < text.length; i++) {
            let code = text.charCodeAt(i);
            bars.push((code % 3) + 1);
            bars.push(((code >> 2) % 3) + 1);
            bars.push(((code >> 4) % 3) + 1);
        }
        bars.push(2, 3, 1, 2);

        let x = 2;
        let rects = '';
        for (let i = 0; i < bars.length; i++) {
            let w = bars[i];
            if (i % 2 === 0) {
                rects += '<rect x="' + x + '" y="2" width="' + w + '" height="22" fill="#1e293b"/>';
            }
            x += w + 1;
        }
        let width = Math.max(125, x + 2);
        let borderColor = theme === 'batch' ? '#c4b5fd' : '#cbd5e1';
        let bgColor = theme === 'batch' ? '#faf5ff' : '#ffffff';
        let textColor = theme === 'batch' ? '#6d28d9' : '#1e293b';

        return '<div style="display: inline-flex; flex-direction: column; align-items: center; padding: 5px 12px; border: 1.5px solid ' + borderColor + '; border-radius: 8px; background: ' + bgColor + '; box-shadow: 0 1px 3px rgba(0,0,0,0.04); white-space: nowrap; min-width: 125px; margin: 2px 0;">' +
            '<svg width="' + width + '" height="24" viewBox="0 0 ' + width + ' 24" style="max-width: 100%;">' +
                rects +
            '</svg>' +
            '<span style="font-size: 11px; font-family: monospace; color: ' + textColor + '; font-weight: 700; margin-top: 2px; letter-spacing: 0.5px;">' + text + '</span>' +
        '</div>';
    }

    function escapeHtml(str) {
        return String(str || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    }

    function parseBarcodeList(str) {
        if (!str || !String(str).trim()) return [];
        return String(str).split(',').map(function(s) { return s.trim(); }).filter(function(s) { return s.length > 0; });
    }

    function initAllBarcodeSvgs() {
        document.querySelectorAll(".render-batch-svg").forEach(el => {
            if (el.dataset.batch) {
                el.innerHTML = textToBarcodeSvgHtml(el.dataset.batch, "batch");
            }
        });
        document.querySelectorAll(".render-barcode-svg").forEach(el => {
            const bc = el.dataset.barcode;
            const name = el.dataset.productName;
            const qty = parseInt(el.dataset.quantity, 10) || 1;
            const detId = el.dataset.detailId;
            const receiptCode = sanitizeCodePart("${receipt.receiptCode}") || "RECEIPT";

            let codes = parseBarcodeList(bc);
            if (codes.length === 0) {
                for (let i = 0; i < qty; i++) {
                    codes.push("BC-" + receiptCode + "-" + (detId || "DET") + "-" + (i + 1));
                }
            }

            const barcodeStr = codes.join(',');
            const safeProductName = (name || 'Sản phẩm').replace(/'/g, "\\'").replace(/"/g, "&quot;");

            let html = '<div style="display:flex;flex-direction:column;align-items:center;gap:6px;">';
            html += textToBarcodeSvgHtml(codes[0], "barcode");
            if (codes.length > 1) {
                html += '<button type="button" '
                    + 'onclick="openBarcodeViewModal(\'' + safeProductName + '\', \'' + barcodeStr + '\')" '
                    + 'style="padding:5px 14px;border:1.5px solid #bfdbfe;background:#eff6ff;color:#2563eb;border-radius:8px;font-size:11px;font-weight:700;cursor:pointer;display:inline-flex;align-items:center;gap:5px;margin-top:4px;transition:all 0.2s;white-space:nowrap;" '
                    + 'onmouseover="this.style.background=\'#dbeafe\';" onmouseout="this.style.background=\'#eff6ff\';">'
                    + '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>'
                    + 'Xem tất cả ' + codes.length + ' barcode'
                    + '</button>';
            }
            html += '</div>';
            el.innerHTML = html;
        });
    }

    // ============ BARCODE VIEW POPUP MODAL ============
    let _currentPopupBarcodes = [];

    function openBarcodeViewModal(productName, barcodeString) {
        const modal = document.getElementById("barcodeViewModal");
        if (!modal) return;
        document.getElementById("bvmProductName").textContent = productName || "Sản phẩm";
        document.getElementById("bvmSearchInput").value = "";
        _currentPopupBarcodes = parseBarcodeList(barcodeString);
        _renderBarcodeGrid(_currentPopupBarcodes);
        modal.style.display = "flex";
        document.body.style.overflow = "hidden";
        setTimeout(() => { modal.style.opacity = "1"; }, 10);
    }

    function closeBarcodeViewModal() {
        const modal = document.getElementById("barcodeViewModal");
        if (!modal) return;
        modal.style.opacity = "0";
        setTimeout(() => { modal.style.display = "none"; document.body.style.overflow = ""; }, 250);
    }

    function _renderBarcodeGrid(codes) {
        const grid = document.getElementById("bvmGrid");
        const badge = document.getElementById("bvmBadge");
        if (!grid) return;
        if (badge) badge.textContent = codes.length + " mã vạch";
        grid.innerHTML = "";
        if (codes.length === 0) {
            grid.innerHTML = '<div style="grid-column:1/-1;text-align:center;color:#94a3b8;padding:40px;font-size:13px;">Không tìm thấy barcode phù hợp</div>';
            return;
        }
        codes.forEach(function(code, idx) {
            const card = document.createElement("div");
            card.style.cssText = "background:#fff;border:1.5px solid #e2e8f0;border-radius:10px;padding:10px 12px;display:flex;flex-direction:column;align-items:center;gap:6px;box-shadow:0 1px 3px rgba(0,0,0,0.04);";
            const num = document.createElement("span");
            num.style.cssText = "font-size:10px;font-weight:700;color:#94a3b8;align-self:flex-start;";
            num.textContent = "#" + (idx + 1);
            card.appendChild(num);
            const barcodeDiv = document.createElement("div");
            barcodeDiv.innerHTML = textToBarcodeSvgHtml(code, "barcode");
            card.appendChild(barcodeDiv);
            grid.appendChild(card);
        });
    }

    function bvmSearch() {
        const q = (document.getElementById("bvmSearchInput").value || "").trim().toUpperCase();
        _renderBarcodeGrid(q ? _currentPopupBarcodes.filter(c => c.toUpperCase().includes(q)) : _currentPopupBarcodes);
    }

    document.addEventListener("DOMContentLoaded", initAllBarcodeSvgs);
    setTimeout(initAllBarcodeSvgs, 50);
    setTimeout(initAllBarcodeSvgs, 300);

// Lightbox open function defined in global scope for inline onclick use
    function openLightbox(src) {
        const lightbox = document.getElementById('imageLightbox');
        const lightboxImg = document.getElementById('lightboxImage');
        if (lightbox && lightboxImg) {
            lightboxImg.src = src;
            lightbox.style.display = 'flex';
            document.body.style.overflow = "hidden"; // Prevent page scroll
        }
    }

    function sanitizeCodePart(value) {
        return String(value == null ? "" : value)
                .trim()
                .toUpperCase()
                .replace(/[^A-Z0-9_-]+/g, "-")
                .replace(/-+/g, "-")
                .replace(/^-|-$/g, "");
    }

    let currentEditingDetailId = null;

    function openReceivingModal(detailId, productName, productId) {
        currentEditingDetailId = detailId;
        const qtyInput = document.getElementById("actualQuantity_" + detailId);
        let qty = qtyInput ? parseInt(qtyInput.value, 10) : 1;
        if (!qty || qty < 1) qty = 1;

        document.getElementById("modalProductName").textContent = productName || "Cấu hình sản phẩm";
        document.getElementById("modalQuantityInfo").textContent = "Số lượng thực nhận: " + qty;

        const modal = document.getElementById("receivingConfigModal");
        const batchInput = document.getElementById("modalBatchCodeInput");
        const barcodeContainer = document.getElementById("modalBarcodeListContainer");

        // Read current hidden batch code or default
        let hiddenBatchInput = document.getElementById("batchCode_" + detailId);
        let existingBatch = hiddenBatchInput ? hiddenBatchInput.value.trim() : "";
        const receiptCode = sanitizeCodePart("${receipt.receiptCode}") || "RECEIPT";
        if (!existingBatch) {
            existingBatch = "BAT-" + receiptCode + "-" + detailId;
        }
        batchInput.value = existingBatch;

        // Read current hidden barcodes
        const hiddenBarcodeInputs = Array.from(document.querySelectorAll("#hiddenInputs_" + detailId + " .receiving-barcode-input"));
        let hiddenBarcodeValues = hiddenBarcodeInputs.map(i => i.value.trim()).filter(Boolean);

        // Render barcode inputs in modal
        barcodeContainer.innerHTML = "";
        for (let i = 0; i < qty; i++) {
            let val = hiddenBarcodeValues[i] || ("BC-" + receiptCode + "-" + detailId + "-" + (i + 1));

            let row = document.createElement("div");
            row.style.display = "flex";
            row.style.alignItems = "center";
            row.style.gap = "8px";

            let lbl = document.createElement("span");
            lbl.textContent = (i + 1) + ".";
            lbl.style.width = "30px";
            lbl.style.fontSize = "12px";
            lbl.style.fontWeight = "700";
            lbl.style.color = "#64748b";

            let inp = document.createElement("input");
            inp.type = "text";
            inp.className = "modal-barcode-item-input";
            inp.value = val;
            inp.style.flex = "1";
            inp.style.padding = "6px 10px";
            inp.style.border = "1.5px solid #cbd5e1";
            inp.style.borderRadius = "6px";
            inp.style.fontFamily = "monospace";
            inp.style.fontSize = "12px";

            let btn = document.createElement("button");
            btn.type = "button";
            btn.textContent = "Tạo";
            btn.style.padding = "4px 10px";
            btn.style.border = "1px solid #bfdbfe";
            btn.style.background = "#eff6ff";
            btn.style.color = "#1d4ed8";
            btn.style.borderRadius = "6px";
            btn.style.cursor = "pointer";
            btn.style.fontSize = "11px";
            btn.style.fontWeight = "700";
            btn.onclick = function () {
                inp.value = "BC-" + receiptCode + "-" + detailId + "-" + (i + 1);
            };

            row.appendChild(lbl);
            row.appendChild(inp);
            row.appendChild(btn);
            barcodeContainer.appendChild(row);
        }

        // Set generate batch btn action
        document.getElementById("modalGenerateBatchBtn").onclick = function () {
            batchInput.value = "BAT-" + receiptCode + "-" + detailId;
        };

        // Set generate all barcodes btn action
        document.getElementById("modalGenerateAllBarcodesBtn").onclick = function () {
            const items = barcodeContainer.querySelectorAll(".modal-barcode-item-input");
            items.forEach((inp, idx) => {
                inp.value = "BC-" + receiptCode + "-" + detailId + "-" + (idx + 1);
            });
        };

        modal.style.display = "flex";
        setTimeout(() => { modal.style.opacity = "1"; }, 10);
    }

    function applyAndCloseReceivingModal() {
        if (!currentEditingDetailId) return;
        const detailId = currentEditingDetailId;

        const modalBatch = document.getElementById("modalBatchCodeInput").value.trim();
        const modalBarcodes = Array.from(document.querySelectorAll("#modalBarcodeListContainer .modal-barcode-item-input")).map(i => i.value.trim());

        updateDetailHiddenInputs(detailId, modalBatch, modalBarcodes);
        closeReceivingModal();
    }

    function closeReceivingModal() {
        const modal = document.getElementById("receivingConfigModal");
        if (!modal) return;
        modal.style.opacity = "0";
        setTimeout(() => { modal.style.display = "none"; }, 250);
    }

    function updateDetailHiddenInputs(detailId, batchValue, barcodeArray) {
        let hiddenContainer = document.getElementById("hiddenInputs_" + detailId);
        if (!hiddenContainer) {
            hiddenContainer = document.createElement("div");
            hiddenContainer.id = "hiddenInputs_" + detailId;
            hiddenContainer.className = "hidden-detail-inputs";
            hiddenContainer.dataset.detailId = detailId;
            const form = document.getElementById("statusForm");
            if (form) form.appendChild(hiddenContainer);
        }

        hiddenContainer.innerHTML = "";

        const tableQtyInput = document.getElementById("actualQuantity_" + detailId);
        let currentQty = tableQtyInput ? tableQtyInput.value.trim() : (barcodeArray ? barcodeArray.length : 1);

        let qtyHiddenInput = document.createElement("input");
        qtyHiddenInput.type = "hidden";
        qtyHiddenInput.id = "actualQuantityHidden_" + detailId;
        qtyHiddenInput.name = "actualQuantity_" + detailId;
        qtyHiddenInput.className = "receiving-quantity-input";
        qtyHiddenInput.value = currentQty;
        hiddenContainer.appendChild(qtyHiddenInput);

        let batchInput = document.createElement("input");
        batchInput.type = "hidden";
        batchInput.id = "batchCode_" + detailId;
        batchInput.name = "batchCode_" + detailId;
        batchInput.className = "receiving-batch-input";
        batchInput.value = batchValue;
        hiddenContainer.appendChild(batchInput);

        barcodeArray.forEach(bc => {
            let bcInput = document.createElement("input");
            bcInput.type = "hidden";
            bcInput.name = "barcode_" + detailId;
            bcInput.className = "receiving-barcode-input";
            bcInput.value = bc;
            hiddenContainer.appendChild(bcInput);
        });

        const batchInpCell = document.getElementById("batchCodeInput_" + detailId);
        if (batchInpCell && batchValue) {
            batchInpCell.value = batchValue;
        }
        const badgeBarcode = document.getElementById("badge_barcode_" + detailId);
        if (badgeBarcode) {
            const filled = barcodeArray.filter(Boolean).length;
            badgeBarcode.textContent = "Barcode: " + filled + "/" + barcodeArray.length + " mã";
        }
    }

    function autoInitReceivingDetails() {
        const receiptCode = sanitizeCodePart("${receipt.receiptCode}") || "RECEIPT";
        document.querySelectorAll(".hidden-detail-inputs").forEach(container => {
            const detailId = container.dataset.detailId;
            const qtyInput = document.getElementById("actualQuantity_" + detailId);
            let qty = qtyInput ? parseInt(qtyInput.value, 10) : 1;
            if (!qty || qty < 1) qty = 1;

            let hiddenBatch = document.getElementById("batchCode_" + detailId);
            let batchVal = hiddenBatch ? hiddenBatch.value.trim() : "";
            if (!batchVal) {
                batchVal = "BAT-" + receiptCode + "-" + detailId;
            }

            let barcodeInputs = Array.from(container.querySelectorAll(".receiving-barcode-input"));
            let barcodeVals = barcodeInputs.map(i => i.value.trim()).filter(Boolean);

            if (barcodeVals.length !== qty) {
                barcodeVals = [];
                for (let i = 0; i < qty; i++) {
                    barcodeVals.push("BC-" + receiptCode + "-" + detailId + "-" + (i + 1));
                }
            }

            updateDetailHiddenInputs(detailId, batchVal, barcodeVals);
        });
    }

    function onQuantityChange(detailId) {
        const qtyInput = document.getElementById("actualQuantity_" + detailId);
        let qty = qtyInput ? parseInt(qtyInput.value, 10) : 1;
        if (!qty || qty < 1) qty = 1;

        const receiptCode = sanitizeCodePart("${receipt.receiptCode}") || "RECEIPT";
        let hiddenBatch = document.getElementById("batchCode_" + detailId);
        let batchVal = hiddenBatch ? hiddenBatch.value.trim() : ("BAT-" + receiptCode + "-" + detailId);

        let barcodeVals = [];
        for (let i = 0; i < qty; i++) {
            barcodeVals.push("BC-" + receiptCode + "-" + detailId + "-" + (i + 1));
        }

        updateDetailHiddenInputs(detailId, batchVal, barcodeVals);
    }

    function cancelReceipt() {
        const confirmed = confirm(
                "Bạn có chắc chắn muốn hủy phiếu nhập này không?"
                );

        if (!confirmed) {
            return;
        }

        const cancelForm =
                document.getElementById("cancelReceiptForm");

        if (!cancelForm) {
            alert("Không tìm thấy form hủy phiếu.");
            return;
        }

        cancelForm.submit();
    }

    document.addEventListener("DOMContentLoaded", function () {
        autoInitReceivingDetails();
        const statusForm = document.getElementById("statusForm");
        const nextStatus = document.getElementById("nextStatus");
        const fileInput = document.getElementById("updateReceivingImagesInput");
        const previewContainer = document.getElementById("imagePreviewContainer");

        document.querySelectorAll(".receiving-quantity-input").forEach(function (qtyInput) {
            qtyInput.addEventListener("change", function () {
                const detailId = qtyInput.dataset.detailId;
                if (detailId) onQuantityChange(detailId);
            });
        });
            if (fileInput) {
                fileInput.addEventListener("change", function () {
                    const targetInput = document.getElementById("statusFormReceivingImagesInput");
                    if (targetInput && fileInput.files) {
                        try {
                            const dt = new DataTransfer();
                            for (let i = 0; i < fileInput.files.length; i++) {
                                dt.items.add(fileInput.files[i]);
                            }
                            targetInput.files = dt.files;
                        } catch (e) {}
                    }
                    if (previewContainer) previewContainer.innerHTML = "";
            const files = Array.from(fileInput.files);
            if (files.length > 4) {
    alert("Bạn chỉ được phép tải lên tối đa 4 ảnh hàng hóa.");
            fileInput.value = "";
            return;
    }
    files.forEach(file => {
    const reader = new FileReader();
            reader.onload = function (e) {
            const img = document.createElement("img");
                    img.src = e.target.result;
                    img.style.width = "60px";
                    img.style.height = "60px";
                    img.style.objectFit = "cover";
                    img.style.borderRadius = "4px";
                    img.style.border = "1px solid var(--card-border)";
                    previewContainer.appendChild(img);
            };
            reader.readAsDataURL(file);
    });
    });
    }

    if (statusForm) {
    statusForm.addEventListener("submit", function (e) {
    if (nextStatus.value === "RECEIVED") {
    const hasExistingImages = ${not empty receipt.receivingImages};
            const quantityInputs = Array.from(document.querySelectorAll(".receiving-quantity-input"));
            const batchInputs = Array.from(document.querySelectorAll(".receiving-batch-input"));
            const barcodeInputs = Array.from(document.querySelectorAll(".receiving-barcode-input"));
            const invalidQuantity = quantityInputs.find(input =>
                    input.value.trim() === "" || Number.isNaN(Number(input.value)) || Number(input.value) <= 0
                    );
            const emptyBatch = batchInputs.find(input => input.value.trim() === "");
            const emptyBarcode = barcodeInputs.find(input => input.value.trim() === "");
            const normalizedBarcodes = barcodeInputs.map(input => input.value.trim().toUpperCase()).filter(Boolean);
            const duplicatedBarcode = new Set(normalizedBarcodes).size !== normalizedBarcodes.length;
            if (invalidQuantity) {
    e.preventDefault();
            alert("Vui lòng nhập số lượng thực nhận lớn hơn 0 cho tất cả sản phẩm.");
            invalidQuantity.focus();
    } else if (emptyBatch) {
    e.preventDefault();
            alert("Vui lòng nhập hoặc bấm Tạo Batch Code cho tất cả sản phẩm.");
            emptyBatch.focus();
    } else if (emptyBarcode) {
    e.preventDefault();
            alert("Vui lòng nhập hoặc tạo đầy đủ Barcode cho từng sản phẩm.");
            emptyBarcode.focus();
    } else if (duplicatedBarcode) {
    e.preventDefault();
            alert("Barcode không được trùng nhau trong cùng phiếu nhập.");
    } else if (!hasExistingImages && (!fileInput || fileInput.files.length === 0)) {
    e.preventDefault();
            alert("Vui lòng chụp hoặc tải lên ít nhất 1 ảnh hàng hóa đã nhận để làm bằng chứng.");
    } else if (fileInput && fileInput.files.length > 4) {
    e.preventDefault();
            alert("Bạn chỉ được phép tải lên tối đa 4 ảnh hàng hóa.");
    }
    }
    });
    }

    // Update Receiving Images Form (inside RECEIVING status page)
    const updateRecForm = document.getElementById("updateReceivingImagesForm");
            const updateRecInput = document.getElementById("updateReceivingImagesInput");
            if (updateRecForm && updateRecInput) {
    updateRecForm.addEventListener("submit", function (e) {
    if (updateRecInput.files.length > 4) {
    e.preventDefault();
            alert("Bạn chỉ được phép tải lên tối đa 4 ảnh hàng hóa.");
    } else if (updateRecInput.files.length === 0) {
    e.preventDefault();
            alert("Vui lòng chọn ít nhất 1 ảnh.");
    }
    });
    }

    // Modal controls for Lịch sử cập nhật
    const historyModal = document.getElementById("historyModal");
            const openHistoryBtn = document.getElementById("openHistoryBtn");
            const closeHistoryModal = document.getElementById("closeHistoryModal");
            if (openHistoryBtn && historyModal) {
    openHistoryBtn.addEventListener("click", function () {
    historyModal.style.display = "block";
            document.body.style.overflow = "hidden"; // Prevent background scrolling
    });
    }

    if (closeHistoryModal && historyModal) {
    closeHistoryModal.addEventListener("click", function () {
    historyModal.style.display = "none";
            document.body.style.overflow = "auto";
    });
    }

    // Close modal when clicking outside of the modal content
    window.addEventListener("click", function (event) {
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
    closeLightbox.addEventListener("click", function () {
    lightbox.style.display = 'none';
            // Only restore scroll if history modal is also closed
            if (!historyModal || historyModal.style.display !== "block") {
    document.body.style.overflow = "auto";
    }
    });
    }

    if (lightbox) {
    lightbox.addEventListener("click", function (event) {
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
