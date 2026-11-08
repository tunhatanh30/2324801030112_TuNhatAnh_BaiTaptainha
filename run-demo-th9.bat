@echo off
echo ============================================================
echo  BAI THUC HANH 9 - DEMO HE THONG (Eureka + PricingService)
echo  Mo dashboard: http://localhost:8761
echo  Pricing API:  http://localhost:5053/api/Pricing
echo ============================================================
echo  Dang khoi dong EurekaServer (8761)...
start "EurekaServer" cmd /k "dotnet run --project %~dp0EurekaServer"
timeout /t 10
echo  Dang khoi dong PricingService (5053)...
start "PricingService" cmd /k "dotnet run --project %~dp0PricingService"
timeout /t 15
echo  Kiem tra thu Registry:
curl -s http://localhost:8761/eureka/apps
echo.
echo  Kiem tra Pricing API (totalPrice ket qua mong doi 98.00):
curl -s -X POST http://localhost:5053/api/Pricing -H "Content-Type: application/json" -d "{\"productCode\":\"TRI\",\"policyFrom\":\"2026-11-08T00:00:00+07:00\",\"policyTo\":\"2026-11-13T00:00:00+07:00\",\"selectedCovers\":[\"C1\",\"C2\",\"C3\"],\"answers\":[{\"questionCode\":\"NUM_OF_ADULTS\",\"questionType\":\"Number\",\"answer\":1},{\"questionCode\":\"NUM_OF_CHILDREN\",\"questionType\":\"Number\",\"answer\":1},{\"questionCode\":\"DESTINATION\",\"questionType\":\"Text\",\"answer\":\"EUR\"}]}"
echo.
echo  Chuc nang 1: Eureka dashboard tai http://localhost:8761
echo  Chuc nang 2: Pricing calculation API tai http://localhost:5053/api/Pricing
echo  Cho phep quay video demo tu day.
pause
