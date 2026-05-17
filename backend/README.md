# Inventory Tracking Backend (Spring Boot)

## Yêu cầu

- Java 17
- MySQL server đang chạy (default `localhost:3306`)
- Maven (do máy hiện chưa có `mvn` trong PATH)

## Cấu hình MySQL

Sửa `src/main/resources/application.yml`:

- `spring.datasource.username`: `root`
- `spring.datasource.password`: thay `CHANGE_ME` bằng password MySQL của bạn

DB mặc định: `inventory` (app sẽ tự tạo nếu MySQL cho phép `createDatabaseIfNotExist=true`).

## Chạy app

Nếu đã cài Maven:

```bash
mvn spring-boot:run
```

Test endpoint:

- `GET http://localhost:8080/api/health`
