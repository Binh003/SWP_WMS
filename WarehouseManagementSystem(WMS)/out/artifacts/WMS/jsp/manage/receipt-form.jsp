<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Tạo Phiếu Nhập Kho"/>
<c:set var="activePage" value="receipts" scope="request"/>
<jsp:include page="../includes/dashboard-layout-start.jsp"/>

<div class="subpage-container">
  <div style="margin-bottom: 16px;">
    <a href="${pageContext.request.contextPath}/manage/receipts" class="back-link" style="display: inline-flex; align-items: center; gap: 8px; text-decoration: none; color: var(--text-secondary); font-weight: 600; font-size: 14px; transition: color 0.2s;" onmouseover="this.style.color='var(--primary-color)'" onmouseout="this.style.color='var(--text-secondary)'">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <line x1="19" y1="12" x2="5" y2="12"></line>
        <polyline points="12 19 5 12 12 5"></polyline>
      </svg>
      Quay lại danh sách
    </a>
  </div>

  <div class="subpage-header" style="margin-bottom: 24px;">
    <div>
      <h2 style="font-size: 24px; font-weight: 700; color: var(--text-primary); margin: 0 0 8px 0;">Tạo Phiếu Nhập Kho</h2>
      <p style="font-size: 14px; color: var(--text-secondary); margin: 0;">Tạo yêu cầu nhập kho mới từ nhà cung cấp.</p>
    </div>
  </div>

  <div class="premium-card" style="padding: 32px; max-width: 800px;">
    <form action="${pageContext.request.contextPath}/manage/receipts" method="post" enctype="multipart/form-data" style="display: flex; flex-direction: column; gap: 24px;">
      <input type="hidden" name="action" value="create"/>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 24px;">
        <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
          <label for="receiptCode" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Mã Phiếu Nhập <span style="color: #ef4444;">*</span></label>
          <input type="text" id="receiptCode" name="receiptCode" value="${generatedCode}" required readonly style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; background-color: #f1f5f9; color: var(--text-secondary); font-family: monospace;" />
        </div>

        <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
          <label for="supplierId" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Nhà cung cấp <span style="color: #ef4444;">*</span></label>
          <select id="supplierId" name="supplierId" required style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary);">
            <option value="">-- Chọn Nhà cung cấp --</option>
            <c:forEach var="s" items="${suppliers}">
              <option value="${s.id}">${s.name}</option>
            </c:forEach>
          </select>
        </div>
      </div>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Ảnh hóa đơn / Chứng từ mua hàng <span style="color: #ef4444;">*</span></label>
        
        <!-- Modern Drag and Drop Zone -->
        <div class="upload-dropzone" id="dropzone" onclick="document.getElementById('invoiceImageFile').click()" style="border: 2px dashed #cbd5e1; border-radius: 12px; padding: 24px; text-align: center; background: #f8fafc; cursor: pointer; transition: all 0.2s ease-in-out; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 10px; position: relative; overflow: hidden; min-height: 140px;">
          <input type="file" id="invoiceImageFile" name="invoiceImageFile" accept="image/*" required onchange="previewInvoiceFile()" style="display: none;" />
          
          <!-- Default State Content -->
          <div id="dropzone-default" style="display: flex; flex-direction: column; align-items: center; gap: 8px; color: var(--text-secondary);">
            <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--primary-color);">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
              <polyline points="17 8 12 3 7 8"></polyline>
              <line x1="12" y1="3" x2="12" y2="15"></line>
            </svg>
            <div style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Kéo & thả ảnh hóa đơn vào đây hoặc nhấp để chọn</div>
            <div style="font-size: 12px;">Hỗ trợ ảnh định dạng PNG, JPG, JPEG (Tối đa 10MB)</div>
          </div>

          <!-- Preview & Success State Content -->
          <div id="dropzone-preview-container" style="display: none; flex-direction: column; align-items: center; gap: 12px; width: 100%;">
            <div style="position: relative; display: inline-block;">
              <img id="invoice-preview" style="max-height: 180px; border-radius: 8px; border: 1.5px solid var(--card-border); box-shadow: 0 4px 12px rgba(0,0,0,0.08); object-fit: contain; max-width: 100%;" />
              <button type="button" onclick="clearInvoiceImage(event)" style="position: absolute; top: -8px; right: -8px; width: 24px; height: 24px; border-radius: 50%; background: #ef4444; color: white; border: none; display: flex; align-items: center; justify-content: center; cursor: pointer; box-shadow: 0 2px 6px rgba(0,0,0,0.2); transition: all 0.2s; padding: 0;" onmouseover="this.style.background='#dc2626'" onmouseout="this.style.background='#ef4444'">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                  <line x1="18" y1="6" x2="6" y2="18"></line>
                  <line x1="6" y1="6" x2="18" y2="18"></line>
                </svg>
              </button>
            </div>
            <div id="file-info" style="font-size: 13px; font-weight: 600; color: var(--text-primary);">Tên file</div>
          </div>
        </div>
      </div>

      <div style="border: 1px solid var(--card-border); border-radius: 10px; margin-top: 8px;">
        <div style="background: #f8fafc; padding: 12px 16px; border-bottom: 1px solid var(--card-border); border-top-left-radius: 9px; border-top-right-radius: 9px; font-weight: 600; font-size: 14px; display: flex; justify-content: space-between; align-items: center;">
          <span>Chi tiết sản phẩm nhập</span>
          <button type="button" onclick="addRow()" style="height: 32px; padding: 0 16px; font-size: 13px; font-weight: 600; color: var(--primary-color); border: 1.5px solid var(--primary-color); background: rgba(4, 138, 191, 0.05); border-radius: 8px; cursor: pointer; transition: all 0.2s; display: inline-flex; align-items: center; justify-content: center; gap: 4px;" onmouseover="this.style.background='rgba(4, 138, 191, 0.1)'" onmouseout="this.style.background='rgba(4, 138, 191, 0.05)'">
            + Thêm dòng
          </button>
        </div>
        <div style="padding: 16px; display: flex; flex-direction: column; gap: 16px;" id="productRows">
          
          <div class="product-row" style="display: flex; gap: 16px; align-items: flex-end;">
            <div style="flex: 1;">
              <label style="font-size: 13px; font-weight: 600; color: var(--text-secondary); margin-bottom: 8px; display: block;">Sản phẩm (SKU) <span style="color: #ef4444;">*</span></label>
              <select name="productId[]" required style="width: 100%; padding: 10px 14px; border: 1px solid var(--card-border); border-radius: 8px; font-size: 14px; outline: none; background: white;">
                <option value="">-- Chọn Sản phẩm --</option>
                <c:forEach var="p" items="${products}">
                  <option value="${p.id}" ${param.productId == p.id ? 'selected' : ''}>[${p.sku}] ${p.name}</option>
                </c:forEach>
              </select>
            </div>
            <div style="width: 150px;">
              <label style="font-size: 13px; font-weight: 600; color: var(--text-secondary); margin-bottom: 8px; display: block;">Số lượng <span style="color: #ef4444;">*</span></label>
              <input type="number" name="quantity[]" required min="1" value="1" style="width: 100%; padding: 10px 14px; border: 1px solid var(--card-border); border-radius: 8px; font-size: 14px; outline: none; background: white;">
            </div>
            <button type="button" onclick="removeRow(this)" style="color: #ef4444; border: 1.5px solid #fecaca; background: #fef2f2; width: 38px; height: 38px; border-radius: 8px; cursor: pointer; display: none; align-items: center; justify-content: center; transition: all 0.2s; padding: 0; box-sizing: border-box;" onmouseover="this.style.background='#fee2e2'; this.style.borderColor='#ef4444'" onmouseout="this.style.background='#fef2f2'; this.style.borderColor='#fecaca'">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="18" y1="6" x2="6" y2="18"></line>
                <line x1="6" y1="6" x2="18" y2="18"></line>
              </svg>
            </button>
          </div>

        </div>
      </div>

      <div class="form-group" style="display: flex; flex-direction: column; gap: 8px;">
        <label for="notes" style="font-size: 14px; font-weight: 600; color: var(--text-primary);">Ghi chú</label>
        <textarea id="notes" name="notes" rows="3" placeholder="Nhập ghi chú cho phiếu nhập kho này..." style="width: 100%; padding: 12px 16px; border: 1.5px solid var(--card-border); border-radius: 10px; font-size: 14px; outline: none; transition: all 0.2s; background-color: #f8fafc; color: var(--text-primary); resize: vertical;"></textarea>
      </div>

      <input type="hidden" id="statusField" name="status" value="PENDING_APPROVAL"/>
      <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 8px; border-top: 1px solid var(--card-border); padding-top: 24px;">
        <a href="${pageContext.request.contextPath}/manage/receipts" class="premium-btn-outline" style="display: inline-flex; align-items: center; justify-content: center; text-decoration: none; height: 44px; padding: 0 24px; box-sizing: border-box;">
          Hủy bỏ
        </a>
        <button type="submit" class="premium-btn-primary" style="height: 44px; padding: 0 24px; cursor: pointer;">
          Gửi Yêu Cầu Duyệt
        </button>
      </div>
    </form>
  </div>
</div>

<style>
  input:focus, select:focus, textarea:focus { border-color: var(--primary-color) !important; background-color: #ffffff !important; box-shadow: 0 0 0 4px rgba(4, 138, 191, 0.1) !important; }
  .action-btn:hover { background: #fee2e2 !important; border-color: #ef4444 !important; }
  
  /* Modern Upload Box Hover/Drag states */
  .upload-dropzone:hover {
    border-color: var(--primary-color) !important;
    background: rgba(4, 138, 191, 0.02) !important;
  }
  .upload-dropzone.dragover {
    border-color: #10b981 !important;
    background: rgba(16, 185, 129, 0.05) !important;
  }

  /* Searchable select styling to mimic native select but with input */
  .searchable-select-wrapper {
    position: relative;
    width: 100%;
  }
  .searchable-select-trigger {
    display: flex;
    justify-content: space-between;
    align-items: center;
    width: 100%;
    padding: 10px 14px;
    border: 1px solid var(--card-border);
    border-radius: 8px;
    font-size: 14px;
    background: white;
    cursor: pointer;
    user-select: none;
    box-sizing: border-box;
    transition: all 0.2s;
  }
  .searchable-select-trigger:focus {
    border-color: var(--primary-color) !important;
    box-shadow: 0 0 0 4px rgba(4, 138, 191, 0.1) !important;
    outline: none;
  }
  .searchable-select-dropdown {
    position: absolute;
    top: 100%;
    left: 0;
    right: 0;
    background: white;
    border: 1px solid var(--card-border);
    border-radius: 8px;
    box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
    z-index: 1000;
    margin-top: 4px;
    display: none;
    flex-direction: column;
  }
  .searchable-select-search-input {
    width: calc(100% - 16px);
    margin: 8px;
    padding: 8px 12px;
    border: 1px solid var(--card-border);
    border-radius: 6px;
    font-size: 13.5px;
    outline: none;
    box-sizing: border-box;
  }
  .searchable-select-search-input:focus {
    border-color: var(--primary-color) !important;
  }
  .searchable-select-options {
    max-height: 240px;
    overflow-y: auto;
  }
  .searchable-select-option {
    padding: 10px 14px;
    cursor: pointer;
    font-size: 13.5px;
    color: #1e293b !important;
    transition: background 0.15s;
    text-align: left;
  }
  .searchable-select-option:hover, .searchable-select-option.active {
    background-color: #048abf !important;
    color: #ffffff !important;
  }
  .searchable-select-option.selected {
    background-color: rgba(4, 138, 191, 0.1) !important;
    color: var(--primary-color) !important;
    font-weight: 600;
  }
  .searchable-select-option.selected:hover {
    background-color: #048abf !important;
    color: #ffffff !important;
  }
  .suggestion-highlight {
    font-weight: 700;
    text-decoration: underline;
  }
</style>

<script>
  function previewInvoiceFile() {
    const fileInput = document.getElementById('invoiceImageFile');
    const defaultContent = document.getElementById('dropzone-default');
    const previewContainer = document.getElementById('dropzone-preview-container');
    const previewImg = document.getElementById('invoice-preview');
    const fileInfo = document.getElementById('file-info');
    
    if (fileInput.files && fileInput.files[0]) {
      const file = fileInput.files[0];
      const reader = new FileReader();
      reader.onload = function(e) {
        previewImg.src = e.target.result;
        fileInfo.textContent = file.name + ' (' + formatBytes(file.size) + ')';
        defaultContent.style.display = 'none';
        previewContainer.style.display = 'flex';
      }
      reader.readAsDataURL(file);
    } else {
      resetDropzone();
    }
  }

  function clearInvoiceImage(event) {
    if (event) event.stopPropagation(); // prevent triggering input click
    const fileInput = document.getElementById('invoiceImageFile');
    fileInput.value = ''; // clear input
    resetDropzone();
  }

  function resetDropzone() {
    document.getElementById('invoiceImageFile').value = '';
    document.getElementById('dropzone-default').style.display = 'flex';
    document.getElementById('dropzone-preview-container').style.display = 'none';
  }

  function formatBytes(bytes, decimals = 2) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const dm = decimals < 0 ? 0 : decimals;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
  }

  function makeSelectSearchable(selectEl) {
    if (!selectEl) return;
    if (selectEl.parentNode.classList.contains('searchable-select-wrapper')) return;

    // Create wrapper
    const wrapper = document.createElement('div');
    wrapper.className = 'searchable-select-wrapper';
    
    selectEl.parentNode.insertBefore(wrapper, selectEl);
    wrapper.appendChild(selectEl);
    selectEl.style.display = 'none';

    // Trigger trigger button
    const trigger = document.createElement('div');
    trigger.className = 'searchable-select-trigger';
    trigger.tabIndex = 0;
    
    const labelSpan = document.createElement('span');
    labelSpan.className = 'selected-text';
    
    const selectedOption = selectEl.options[selectEl.selectedIndex];
    labelSpan.textContent = selectedOption ? selectedOption.textContent : '-- Chọn Sản phẩm --';
    
    const chevron = document.createElement('span');
    chevron.innerHTML = `
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="color: var(--text-secondary); display: block;">
        <polyline points="6 9 12 15 18 9"></polyline>
      </svg>
    `;
    
    trigger.appendChild(labelSpan);
    trigger.appendChild(chevron);
    wrapper.appendChild(trigger);

    // Dropdown
    const dropdown = document.createElement('div');
    dropdown.className = 'searchable-select-dropdown';
    
    const searchInput = document.createElement('input');
    searchInput.type = 'text';
    searchInput.className = 'searchable-select-search-input';
    searchInput.placeholder = 'Gõ từ khóa để lọc sản phẩm...';
    searchInput.autocomplete = 'off';
    
    const optionsList = document.createElement('div');
    optionsList.className = 'searchable-select-options';
    
    dropdown.appendChild(searchInput);
    dropdown.appendChild(optionsList);
    wrapper.appendChild(dropdown);

    let activeIndex = -1;
    let filteredOptions = [];

    function loadOptions() {
      try {
        optionsList.innerHTML = '';
        const query = searchInput.value.toLowerCase().trim();
        filteredOptions = [];
        
        Array.from(selectEl.options).forEach((opt, idx) => {
          const optText = opt.textContent || opt.text || '';
          if (query && !optText.toLowerCase().includes(query)) {
            return;
          }
          filteredOptions.push({ opt, idx });
        });

        if (filteredOptions.length === 0) {
          const emptyDiv = document.createElement('div');
          emptyDiv.style.padding = '10px 14px';
          emptyDiv.style.color = 'var(--text-secondary)';
          emptyDiv.style.fontSize = '13.5px';
          emptyDiv.style.textAlign = 'center';
          emptyDiv.textContent = 'Không tìm thấy sản phẩm nào';
          optionsList.appendChild(emptyDiv);
          return;
        }

        filteredOptions.forEach((item, fIdx) => {
          const optDiv = document.createElement('div');
          optDiv.className = 'searchable-select-option';
          if (item.opt.selected) {
            optDiv.classList.add('selected');
          }
          if (fIdx === activeIndex) {
            optDiv.classList.add('active');
          }
          
          const text = item.opt.textContent || item.opt.text || '';
          
          // Safe Highlight Matching letters using DOM TextNodes to avoid innerHTML block/sanitize issues
          if (query) {
            const matchIdx = text.toLowerCase().indexOf(query);
            if (matchIdx !== -1) {
              const before = text.substring(0, matchIdx);
              const match = text.substring(matchIdx, matchIdx + query.length);
              const after = text.substring(matchIdx + query.length);
              
              if (before) {
                optDiv.appendChild(document.createTextNode(before));
              }
              
              const matchSpan = document.createElement('span');
              matchSpan.className = 'suggestion-highlight';
              matchSpan.textContent = match;
              optDiv.appendChild(matchSpan);
              
              if (after) {
                optDiv.appendChild(document.createTextNode(after));
              }
            } else {
              optDiv.appendChild(document.createTextNode(text));
            }
          } else {
            optDiv.appendChild(document.createTextNode(text));
          }

          optDiv.addEventListener('click', (e) => {
            e.stopPropagation();
            selectOptionItem(item);
          });
          optionsList.appendChild(optDiv);
        });
      } catch (err) {
        console.error("loadOptions error: ", err);
      }
    }

    function selectOptionItem(item) {
      selectEl.selectedIndex = item.idx;
      selectEl.dispatchEvent(new Event('change', { bubbles: true }));
      labelSpan.textContent = item.opt.textContent;
      closeDropdown();
      trigger.focus();
    }

    function openDropdown() {
      // Close other searchable select dropdowns on the page
      document.querySelectorAll('.searchable-select-dropdown').forEach(d => {
        if (d !== dropdown) d.style.display = 'none';
      });
      dropdown.style.display = 'flex';
      activeIndex = -1;
      loadOptions();
      setTimeout(() => searchInput.focus(), 50);
    }

    function closeDropdown() {
      dropdown.style.display = 'none';
      searchInput.value = '';
    }

    trigger.addEventListener('click', (e) => {
      e.stopPropagation();
      if (dropdown.style.display === 'flex') {
        closeDropdown();
      } else {
        openDropdown();
      }
    });

    trigger.addEventListener('keydown', (e) => {
      if (e.key === ' ' || e.key === 'ArrowDown' || e.key === 'Enter') {
        e.preventDefault();
        openDropdown();
      }
    });

    searchInput.addEventListener('input', () => {
      activeIndex = -1;
      loadOptions();
    });

    searchInput.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        closeDropdown();
        trigger.focus();
      } else if (e.key === 'ArrowDown') {
        e.preventDefault();
        if (filteredOptions.length > 0) {
          activeIndex = (activeIndex + 1) % filteredOptions.length;
          loadOptions();
          scrollToActive();
        }
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        if (filteredOptions.length > 0) {
          activeIndex = (activeIndex - 1 + filteredOptions.length) % filteredOptions.length;
          loadOptions();
          scrollToActive();
        }
      } else if (e.key === 'Enter') {
        e.preventDefault();
        if (activeIndex >= 0 && activeIndex < filteredOptions.length) {
          selectOptionItem(filteredOptions[activeIndex]);
        }
      }
    });

    function scrollToActive() {
      const activeEl = optionsList.querySelector('.searchable-select-option.active');
      if (activeEl) {
        activeEl.scrollIntoView({ block: 'nearest' });
      }
    }

    document.addEventListener('click', (e) => {
      if (!wrapper.contains(e.target)) {
        closeDropdown();
      }
    });
  }

  function addRow() {
    const container = document.getElementById('productRows');
    const firstRow = container.querySelector('.product-row');
    const newRow = firstRow.cloneNode(true);
    
    // If the cloned row contains an initialized searchable-select-wrapper, unwrap it
    const wrapper = newRow.querySelector('.searchable-select-wrapper');
    if (wrapper) {
      const select = wrapper.querySelector('select');
      select.style.display = 'block';
      wrapper.parentNode.replaceChild(select, wrapper);
    }

    // Reset values
    const selectElem = newRow.querySelector('select');
    selectElem.value = '';
    newRow.querySelector('input[type="number"]').value = '1';
    newRow.querySelector('input[name="batchCode[]"]').value = '';
    
    // Show delete button
    newRow.querySelector('button').style.display = 'inline-flex';
    
    // Make sure first row delete button is also visible if there are > 1 rows
    firstRow.querySelector('button').style.display = 'inline-flex';
    
    container.appendChild(newRow);

    // Make the new select searchable
    makeSelectSearchable(selectElem);
  }

  function removeRow(btn) {
    const container = document.getElementById('productRows');
    const rows = container.querySelectorAll('.product-row');
    if (rows.length > 1) {
      btn.closest('.product-row').remove();
    }
    // If only 1 row left, hide its delete button
    const remainingRows = container.querySelectorAll('.product-row');
    if (remainingRows.length === 1) {
      remainingRows[0].querySelector('button').style.display = 'none';
    }
  }

  // Setup drag and drop events
  document.addEventListener("DOMContentLoaded", function() {
    // Decorate initial product select elements
    document.querySelectorAll('select[name="productId[]"]').forEach(selectEl => {
      makeSelectSearchable(selectEl);
    });

    const dropzone = document.getElementById('dropzone');
    const fileInput = document.getElementById('invoiceImageFile');

    if (dropzone && fileInput) {
      ['dragenter', 'dragover'].forEach(eventName => {
        dropzone.addEventListener(eventName, highlight, false);
      });

      ['dragleave', 'drop'].forEach(eventName => {
        dropzone.addEventListener(eventName, unhighlight, false);
      });

      function highlight(e) {
        e.preventDefault();
        e.stopPropagation();
        dropzone.classList.add('dragover');
      }

      function unhighlight(e) {
        e.preventDefault();
        e.stopPropagation();
        dropzone.classList.remove('dragover');
      }

      dropzone.addEventListener('drop', handleDrop, false);

      function handleDrop(e) {
        const dt = e.dataTransfer;
        const files = dt.files;

        if (files && files.length > 0) {
          // Filter to only keep images
          const imageFiles = Array.from(files).filter(file => file.type.startsWith('image/'));
          if (imageFiles.length > 0) {
            // Create a DataTransfer object to simulate file input change
            const container = new DataTransfer();
            container.items.add(imageFiles[0]);
            fileInput.files = container.files;
            
            // Trigger preview
            previewInvoiceFile();
          } else {
            alert("Vui lòng chỉ kéo thả tệp hình ảnh!");
          }
        }
      }
    }
  });
</script>

<jsp:include page="../includes/dashboard-layout-end.jsp"/>
