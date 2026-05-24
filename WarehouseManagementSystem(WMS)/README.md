# SWP_WMS_Web — Java Web (NetBeans)

Project **Java Web Application** chuẩn NetBeans (Servlet + JSP + JDBC), tách riêng để mở trực tiếp trong IDE.

## Mở trong NetBeans 17

1. **File → Open Project**
2. Chọn thư mục: `C:\SWP170526\SWP_WMS_NetBeans`
3. Phải thấy tên project **SWP_WMS_Web** (icon quả địa cầu / web), không phải folder xám
4. Nhấn **Open Project**
5. Lần đầu: chuột phải project → **Properties → Run** → chọn **Apache Tomcat** → OK
6. **Run (F6)**

URL: `http://localhost:8080/SWP_WMS_Web/`

## Đăng nhập

- User: `admin`
- Pass: `admin123`

## Cấu hình MySQL

Sửa `src/conf/db.properties` (user/password MySQL).

## Cấu trúc

| Thư mục | Mô tả |
|--------|--------|
| `src/java/com/its/wms/` | Servlet, DAO, Filter |
| `web/jsp/` | Trang JSP |
| `web/WEB-INF/web.xml` | Servlet mapping |
| `web/WEB-INF/lib/` | MySQL, JSTL, jBCrypt |
| `nbproject/` | Cấu hình NetBeans (đủ `build-impl.xml`, `ant-deploy.xml`) |

## Ghi chú

- Thư mục `C:\SWP170526\SWP_WMS` (cha) vẫn chứa code React/Spring cũ — **không mở** folder đó nếu chỉ cần Servlet/JSP.
- Mở đúng **`SWP_WMS_NetBeans`** này.
