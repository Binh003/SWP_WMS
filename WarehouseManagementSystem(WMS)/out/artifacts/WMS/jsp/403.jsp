<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>403 - Không có quyền truy cập</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background-color: #f4f6f8;
            color: #1f2937;
        }

        .error-container {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }

        .error-card {
            width: 100%;
            max-width: 560px;
            padding: 48px 36px;
            background-color: #ffffff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            text-align: center;
        }

        .error-code {
            margin: 0;
            font-size: 96px;
            font-weight: 700;
            color: #dc2626;
            line-height: 1;
        }

        .error-title {
            margin: 20px 0 12px;
            font-size: 28px;
        }

        .error-message {
            margin: 0 0 32px;
            color: #6b7280;
            font-size: 16px;
            line-height: 1.6;
        }

        .home-button {
            display: inline-block;
            padding: 12px 24px;
            border-radius: 8px;
            background-color: #1d4ed8;
            color: #ffffff;
            text-decoration: none;
            font-weight: 600;
        }

        .home-button:hover {
            background-color: #1e40af;
        }
    </style>
</head>

<body>
<div class="error-container">
    <div class="error-card">

        <h1 class="error-code">403</h1>

        <h2 class="error-title">Truy cập bị từ chối</h2>

        <p class="error-message">
            ${not empty errorMessage
                    ? errorMessage
                    : "Bạn không có quyền truy cập trang này."}
        </p>

        <a href="${pageContext.request.contextPath}/home"
           class="home-button">
            Quay về trang chủ
        </a>

    </div>
</div>
</body>
</html>