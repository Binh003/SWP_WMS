<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="isEdit" value="${not empty product}"/>
<c:set var="pageTitle" value="${isEdit ? 'Sửa Sản phẩm' : 'Thêm Sản phẩm'}"/>
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

  <div class="subpage-header" style="margin-bottom: 24px;">
    <div>
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">${pageTitle}</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">${isEdit ? 'Cập nhật thông tin sản phẩm.' : 'Thêm một sản phẩm mới vào danh mục.'}</p>
    </div>
  </div>

  <div class="premium-card" style="padding: 32px; max-width: 800px;">
    <form action="${pageContext.request.contextPath}/admin/products" method="post" enctype="multipart/form-data" style="display: flex; flex-direction: column; gap: 24px;">
      <input type="hidden" name="action" value="${isEdit ? 'update' : 'create'}"/>
      <c:if test="${isEdit}">
        <input type="hidden" name="id" value="${product.id}"/>
      </c:if>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label for="productLineId" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Dòng sản phẩm <span style="color: #ef4444;">*</span></label>
        <select id="productLineId" name="productLineId" required style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary);">
          <option value="">-- Chọn dòng sản phẩm --</option>
          <c:forEach var="pl" items="${productLines}">
            <option value="${pl.id}" ${isEdit && product.productLineId == pl.id ? 'selected' : ''}>
              ${pl.brand.name} - ${pl.name}
            </option>
          </c:forEach>
        </select>
      </div>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label for="sku" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Mã SKU <span style="color: #ef4444;">*</span></label>
        <input type="text" id="sku" name="sku" value="${isEdit ? product.sku : ''}" required placeholder="Nhập mã SKU (VD: IP15-PM-256)" style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary); font-family: monospace;" />
      </div>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label for="name" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Tên sản phẩm <span style="color: #ef4444;">*</span></label>
        <input type="text" id="name" name="name" value="${isEdit ? product.name : ''}" required placeholder="Nhập tên sản phẩm" style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary);" />
      </div>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
          <label for="unit" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Đơn vị tính <span style="color: #ef4444;">*</span></label>
          <input type="text" id="unit" name="unit" value="${isEdit ? product.unit : 'Chiếc'}" required placeholder="VD: Chiếc, Bộ, Thùng..." style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary);" />
        </div>

        <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
          <label for="price" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Giá bán</label>
          <input type="number" id="price" name="price" value="${isEdit ? product.price : ''}" placeholder="Nhập giá bán (VNĐ)" style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary);" />
        </div>
      </div>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Hình ảnh sản phẩm</label>
        
        <div style="display: grid; grid-template-columns: 180px 1fr; gap: 24px; align-items: start;">
          <!-- Left Side: Live Preview Area -->
          <div style="display: flex; flex-direction: column; gap: 6px;">
            <span style="font-size: 13px; font-weight: 600; color: var(--text-secondary);">Xem trước ảnh:</span>
            <div style="width: 180px; height: 180px; border-radius: 12px; border: 1.5px dashed var(--card-border); background: #f8fafc; display: flex; align-items: center; justify-content: center; overflow: hidden; position: relative; box-shadow: inset 0 2px 4px rgba(0,0,0,0.02);">
              
              <!-- Image Preview -->
              <img id="product-image-preview" 
                   src="${isEdit && not empty product.imageUrl ? (product.imageUrl.startsWith('/') ? pageContext.request.contextPath : '') : ''}${isEdit && not empty product.imageUrl ? product.imageUrl : ''}" 
                   style="width: 100%; height: 100%; object-fit: contain; display: ${isEdit && not empty product.imageUrl ? 'block' : 'none'};" />
              
              <!-- Placeholder -->
              <div id="preview-placeholder" style="display: ${isEdit && not empty product.imageUrl ? 'none' : 'flex'}; flex-direction: column; align-items: center; justify-content: center; gap: 8px; color: var(--text-tertiary); text-align: center; padding: 16px;">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                  <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
                  <circle cx="8.5" cy="8.5" r="1.5"></circle>
                  <polyline points="21 15 16 10 5 21"></polyline>
                </svg>
                <span style="font-size: 12px; font-weight: 500;">Chưa có hình ảnh</span>
              </div>
              
              <!-- Delete/Clear button -->
              <button type="button" id="btn-clear-image" onclick="clearProductImage(event)" 
                      style="display: ${isEdit && not empty product.imageUrl ? 'flex' : 'none'}; position: absolute; top: 8px; right: 8px; width: 24px; height: 24px; border-radius: 50%; background: #ef4444; color: white; border: none; align-items: center; justify-content: center; cursor: pointer; box-shadow: 0 2px 6px rgba(0,0,0,0.15); transition: all 0.2s; padding: 0;"
                      onmouseover="this.style.background='#dc2626'" onmouseout="this.style.background='#ef4444'">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                  <line x1="18" y1="6" x2="6" y2="18"></line>
                  <line x1="6" y1="6" x2="18" y2="18"></line>
                </svg>
              </button>
            </div>
          </div>

          <!-- Right Side: Dual Tab Inputs -->
          <div style="flex: 1; display: flex; flex-direction: column; gap: 16px;">
            <!-- Tabs Bar -->
            <div style="display: flex; border-bottom: 1.5px solid var(--card-border); gap: 16px;">
              <button type="button" id="tab-upload" onclick="switchImageTab('upload')" 
                      style="padding: 8px 12px 10px 12px; font-size: 13px; font-weight: 700; border: none; background: none; cursor: pointer; border-bottom: 2.5px solid var(--primary-color); color: var(--primary-color); transition: all 0.2s; outline: none;">
                Tải lên từ máy tính
              </button>
              <button type="button" id="tab-url" onclick="switchImageTab('url')" 
                      style="padding: 8px 12px 10px 12px; font-size: 13px; font-weight: 700; border: none; background: none; cursor: pointer; border-bottom: 2.5px solid transparent; color: var(--text-secondary); transition: all 0.2s; outline: none;">
                Đường dẫn ảnh (URL)
              </button>
            </div>

            <!-- Tab Content 1: Upload Dropzone -->
            <div id="content-upload" class="upload-dropzone" onclick="document.getElementById('imageFile').click()" 
                 style="border: 2px dashed #cbd5e1; border-radius: 12px; padding: 24px; text-align: center; background: #f8fafc; cursor: pointer; transition: all 0.2s ease-in-out; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 8px; min-height: 110px; box-sizing: border-box;">
              <input type="file" id="imageFile" name="imageFile" accept="image/*" onchange="previewProductFile()" style="display: none;" />
              
              <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--primary-color);">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                <polyline points="17 8 12 3 7 8"></polyline>
                <line x1="12" y1="3" x2="12" y2="15"></line>
              </svg>
              <div style="font-size: 13px; font-weight: 600; color: var(--text-primary);">Kéo thả tệp hoặc nhấp để chọn ảnh sản phẩm</div>
              <div style="font-size: 11px; color: var(--text-secondary);">Hỗ trợ PNG, JPG, JPEG (Tối đa 10MB)</div>
            </div>

            <!-- Tab Content 2: URL Input -->
            <div id="content-url" style="display: none;">
              <div style="display: flex; flex-direction: column; gap: 6px;">
                <label for="imageUrl" style="font-size: 12px; font-weight: 600; color: var(--text-secondary);">Nhập đường dẫn URL của hình ảnh:</label>
                <input type="text" id="imageUrl" name="imageUrl" value="${isEdit ? product.imageUrl : ''}" placeholder="https://example.com/image.jpg" oninput="previewProductUrl(this.value)" 
                       style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; background-color: #f8fafc; color: var(--text-primary); transition: all 0.2s;"
                       onfocus="this.style.borderColor='var(--primary-color)';" 
                       onblur="this.style.borderColor='var(--card-border)';" />
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label for="description" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Mô tả</label>
        <textarea id="description" name="description" rows="4" placeholder="Nhập mô tả sản phẩm..." style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary); resize: vertical;">${isEdit ? product.description : ''}</textarea>
      </div>

      <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 8px; border-top: 1px solid var(--card-border); padding-top: 24px;">
        <a href="${pageContext.request.contextPath}/admin/products" class="premium-btn-secondary" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; padding: 0 24px; box-sizing: border-box;">
          Hủy bỏ
        </a>
        <button type="submit" class="premium-btn-primary" style="height: 44px; padding: 0 24px;">
          ${isEdit ? 'Lưu thay đổi' : 'Tạo Sản phẩm'}
        </button>
      </div>
    </form>
  </div>
</div>

<style>
  input:focus, select:focus, textarea:focus { border-color: var(--primary-color) !important; background-color: #ffffff !important; box-shadow: 0 0 0 4px rgba(4, 138, 191, 0.1) !important; }
  
  /* Modern Upload Box Hover/Drag states */
  .upload-dropzone:hover {
    border-color: var(--primary-color) !important;
    background: rgba(4, 138, 191, 0.02) !important;
  }
  .upload-dropzone.dragover {
    border-color: #10b981 !important;
    background: rgba(16, 185, 129, 0.05) !important;
  }
</style>

<script>
  function switchImageTab(tabType) {
    const tabUpload = document.getElementById('tab-upload');
    const tabUrl = document.getElementById('tab-url');
    const contentUpload = document.getElementById('content-upload');
    const contentUrl = document.getElementById('content-url');

    if (tabType === 'upload') {
      tabUpload.style.color = 'var(--primary-color)';
      tabUpload.style.borderBottomColor = 'var(--primary-color)';
      tabUrl.style.color = 'var(--text-secondary)';
      tabUrl.style.borderBottomColor = 'transparent';
      contentUpload.style.display = 'flex';
      contentUrl.style.display = 'none';
    } else {
      tabUrl.style.color = 'var(--primary-color)';
      tabUrl.style.borderBottomColor = 'var(--primary-color)';
      tabUpload.style.color = 'var(--text-secondary)';
      tabUpload.style.borderBottomColor = 'transparent';
      contentUpload.style.display = 'none';
      contentUrl.style.display = 'block';
    }
  }

  function previewProductFile() {
    const fileInput = document.getElementById('imageFile');
    const previewImg = document.getElementById('product-image-preview');
    const placeholder = document.getElementById('preview-placeholder');
    const clearBtn = document.getElementById('btn-clear-image');

    if (fileInput.files && fileInput.files[0]) {
      const reader = new FileReader();
      reader.onload = function(e) {
        previewImg.src = e.target.result;
        previewImg.style.display = 'block';
        placeholder.style.display = 'none';
        clearBtn.style.display = 'flex';
        // Clear the URL input to avoid confusion in backend
        document.getElementById('imageUrl').value = '';
      }
      reader.readAsDataURL(fileInput.files[0]);
    }
  }

  function previewProductUrl(url) {
    const previewImg = document.getElementById('product-image-preview');
    const placeholder = document.getElementById('preview-placeholder');
    const clearBtn = document.getElementById('btn-clear-image');

    if (url && url.trim() !== '') {
      previewImg.src = url.trim();
      previewImg.style.display = 'block';
      placeholder.style.display = 'none';
      clearBtn.style.display = 'flex';
      // Clear file input to avoid confusion in backend
      document.getElementById('imageFile').value = '';
    } else {
      clearProductImage();
    }
  }

  function clearProductImage(event) {
    if (event) event.stopPropagation();
    
    document.getElementById('imageFile').value = '';
    document.getElementById('imageUrl').value = '';
    
    const previewImg = document.getElementById('product-image-preview');
    const placeholder = document.getElementById('preview-placeholder');
    const clearBtn = document.getElementById('btn-clear-image');
    
    previewImg.src = '';
    previewImg.style.display = 'none';
    placeholder.style.display = 'flex';
    clearBtn.style.display = 'none';
  }

  document.addEventListener("DOMContentLoaded", function() {
    // Determine active tab on load based on whether an image URL exists and is not a local upload path
    const imageUrlInput = document.getElementById('imageUrl');
    if (imageUrlInput && imageUrlInput.value && !imageUrlInput.value.startsWith('/uploads/')) {
      switchImageTab('url');
    } else {
      switchImageTab('upload');
    }

    // Configure drag and drop listeners
    const dropzone = document.getElementById('content-upload');
    const fileInput = document.getElementById('imageFile');

    if (dropzone && fileInput) {
      ['dragenter', 'dragover'].forEach(eventName => {
        dropzone.addEventListener(eventName, function(e) {
          e.preventDefault();
          e.stopPropagation();
          dropzone.classList.add('dragover');
        }, false);
      });

      ['dragleave', 'drop'].forEach(eventName => {
        dropzone.addEventListener(eventName, function(e) {
          e.preventDefault();
          e.stopPropagation();
          dropzone.classList.remove('dragover');
        }, false);
      });

      dropzone.addEventListener('drop', function(e) {
        const dt = e.dataTransfer;
        const files = dt.files;

        if (files && files.length > 0) {
          const imageFiles = Array.from(files).filter(file => file.type.startsWith('image/'));
          if (imageFiles.length > 0) {
            const container = new DataTransfer();
            container.items.add(imageFiles[0]);
            fileInput.files = container.files;
            previewProductFile();
          }
        }
      }, false);
    }
  });
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
