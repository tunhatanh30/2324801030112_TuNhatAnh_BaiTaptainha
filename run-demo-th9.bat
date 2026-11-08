@echo off
chcp 65001 >nul
echo ============================================================
echo   BÀI THỰC HÀNH 9 - TRIỂN KHAI HỆ THỐNG MICROSERVICES
echo   Sinh viên: Tú Nhất Anh - MSSV: 2324801030112
echo ============================================================
echo.
echo [1/5] Dọn dẹp tiến trình cũ...
taskkill /F /IM dotnet.exe >nul 2>&1
taskkill /F /IM EurekaServer.exe >nul 2>&1
taskkill /F /IM PricingService.exe >nul 2>&1
taskkill /F /IM ProductService.exe >nul 2>&1
timeout /t 2 >nul

echo [2/5] Khởi động Eureka Server (Port 8761)...
start "EurekaServer (8761)" cmd /k "title EurekaServer && dotnet run --project %~dp0EurekaServer"
timeout /t 5 >nul

echo [3/5] Khởi động Pricing Service (Port 5053)...
start "PricingService (5053)" cmd /k "title PricingService && dotnet run --project %~dp0PricingService"
timeout /t 4 >nul

echo [4/5] Khởi động Product Service (Port 5030)...
start "ProductService (5030)" cmd /k "title ProductService && dotnet run --project %~dp0ProductService"
timeout /t 5 >nul

echo [5/5] Mở giao diện Web Demo trên trình duyệt...
start http://localhost:8761

echo.
echo ============================================================
echo  KIỂM TRA MINH CHỨNG TỰ ĐỘNG (DÀNH CHO VIDEO DEMO):
echo ============================================================
echo.
echo [CHỨC NĂNG 1] Eureka Registry (/eureka/apps):
curl.exe -s http://localhost:8761/eureka/apps
echo.
echo.
echo [CHỨC NĂNG 2] Pricing API POST /api/Pricing (Mong đợi: 98.00):
curl.exe -s -X POST http://localhost:5053/api/Pricing -H "Content-Type: application/json" -d "{\"productCode\":\"TRI\",\"policyFrom\":\"2026-11-08T00:00:00+07:00\",\"policyTo\":\"2026-11-13T00:00:00+07:00\",\"selectedCovers\":[\"C1\",\"C2\",\"C3\"],\"answers\":[{\"questionCode\":\"NUM_OF_ADULTS\",\"questionType\":\"Number\",\"answer\":1},{\"questionCode\":\"NUM_OF_CHILDREN\",\"questionType\":\"Number\",\"answer\":1},{\"questionCode\":\"DESTINATION\",\"questionType\":\"Text\",\"answer\":\"EUR\"}]}"
echo.
echo.
echo [CHỨC NĂNG 3] Product API GET /api/products:
curl.exe -s http://localhost:5030/api/products
echo.
echo.
echo ============================================================
echo  HƯỚNG DẪN QUAY VIDEO DEMO NỘP BÀI:
echo  1. Mở cửa sổ trình duyệt đang hiển thị trang Web Demo (http://localhost:8761).
echo  2. Quay phần 'Eureka Registry' (thấy PRICINGSERVICE trạng thái UP).
echo  3. Bấm 'Điền mẫu' và bấm 'Tính phí bảo hiểm' (kết quả 98.00).
echo  4. Quay cửa sổ dòng lệnh này với kết quả 3 API ở trên.
echo  5. Upload video lên Google Drive và nộp link lên e-learning.
echo  * LƯU Ý: KHÔNG ĐÓNG các cửa sổ terminal dịch vụ khi đang quay video!
echo ============================================================
echo.
pause
