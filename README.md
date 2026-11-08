# BÀI THỰC HÀNH SỐ 9 – CASE STUDY CÔNG TY BẢO HIỂM (PHẦN 7)

## Triển khai hệ thống (bổ sung PolicyService + PolicySearchService)

Sinh viên: **Tú Nhất Anh** – MSSV: **2324801030112**

Repository: <https://github.com/tunhatanh30/2324801030112_TuNhatAnh_BaiTaptainha.git>

---

## Task #1 – Bổ sung code PolicyService và PolicySearchService (5 thư mục)

Code được copy từ file đính kèm (`PolicyService.rar`, `PolicyService.Test.rar`,
`PolicyService.Api.rar`, `PolicySearchService.rar`, `PolicySearchService.Api.rar`):

### PolicyService (service chính – tạo báo giá & hợp đồng)

| Thư mục | Nội dung chính |
|---------|----------------|
| `Commands/` | `CreateOfferHandler.cs`, `CreateOfferByAgentHandler.cs`, `CreatePolicyHandler.cs`, `TerminatePolicyHandler.cs` |
| `Queries/` | `GetPolicyDetailsHandler.cs` |
| `DataAccess/NHibernate/` | `NHibernateInstaller.cs`, `PolicyRepository.cs`, `OfferRepository.cs`, `UnitOfWork.cs` (+ `Policy.hbm.xml`, `Offer.hbm.xml`) |
| `Messaging/RabbitMq/Outbox/` | `Outbox.cs`, `OutboxEventPublisher.cs`, `OutboxSendingService.cs` (Transactional Outbox pattern) |
| `RestClients/` | `PricingClient.cs`, `PricingService.cs`, `RestClientsInstaller.cs` (gọi PricingService qua RestEase) |

Ngoài ra: `Domain/` (Policy, Offer, PolicyVersion, PolicyHolder, Address, Cover...),
`Controllers/` (Offer, Policy, Error), `Startup.cs`, `Program.cs`.

### PolicySearchService (tìm kiếm nâng cao Elasticsearch)

| Thư mục | Nội dung chính |
|---------|----------------|
| `Controllers/` | `PolicySearchController.cs` |
| `DataAccess/ElasticSearch/` | `PolicyRepository.cs`, `NestInstaller.cs` (Elastic.Clients.Elasticsearch) |
| `Domain/` | `Policy.cs`, `IPolicyRepository.cs` |
| `Listeners/` | `PolicyCreatedHandler.cs` (đăng ký event PolicyCreated từ RabbitMQ) |
| `Messaging/RabbitMq/` | `RabbitEventListener.cs`, `RabbitInstaller.cs` (EasyNetQ) |
| `Queries/` | `FindPolicyHandler.cs` (query `FindPolicyQuery`) |

### `.Api` và `.Test`

- `PolicyService.Api`: `Commands/` (CreateOffer / CreatePolicy / TerminatePolicy),
  `Queries/` (GetPolicyDetails), `Converters/QuestionAnswerConverter.cs`,
  `Events/` (PolicyCreated, PolicyTerminated).
- `PolicySearchService.Api`: `Queries/` (`FindPolicyQuery`, `FindPolicyResult`, `Dtos/PolicyDto.cs`).
- `PolicyService.Test`: `Domain/` (`OfferTest.cs`, `PolicyTerminationTest.cs`),
  `TestData/` factories.

**Xử lý khác tên (theo hướng dẫn đề):** đổi tên stub cũ cho khớp code mẫu —
xóa các file stub `PolicyCommands.cs`, `PolicyDtos.cs`, `PolicyQueries.cs`,
`PolicySearchQueries.cs`, `PolicySearchDtos.cs` và thay bằng cấu trúc file mẫu
(QuestionAnswer dạng generic có JsonConverter, PolicyDetailsDto nằm ở
`PolicyService.Api.Queries.Dto`).

## Task #2 – Triển khai hệ thống (demo thực thi)

Đã kiểm chứng hệ thống chạy được (không chỉ build):

1. **Đăng ký động với Eureka:** chạy `EurekaServer` (8761) + `PricingService` (5053)
   → dashboard `http://localhost:8761` hiện `PRICINGSERVICE` status **UP**,
   `GET /eureka/apps` trả về registry JSON hợp lệ.
2. **Tính giá bảo hiểm trực tuyến:** `POST /api/Pricing` với body mẫu
   (TRI, 1 adult + 1 child, DESTINATION=EUR) trả về
   `{"totalPrice":98.00,"coverPrices":{"C1":26.00,"C2":52.00,"C3":20.00}}`.

> `PolicyService` cần PostgreSQL (NHibernate), `PolicySearchService` cần
> Elasticsearch, `PaymentService` cần PostgreSQL (Marten) + RabbitMQ.
> Để quay video demo đầy đủ 2+ chức năng, chạy theo thứ tự dưới đây
> (dùng `run-demo-th9.bat` trong repo):

```powershell
# PowerShell 1
dotnet run --project ./EurekaServer
# PowerShell 2
dotnet run --project ./PricingService
# PowerShell 3
dotnet run --project ./ProductService
# PowerShell 4 (cần PostgreSQL localhost:5432)
dotnet run --project ./PolicyService
# PowerShell 5 (cần RabbitMQ localhost:5672 + Elasticsearch localhost:9200)
dotnet run --project ./PolicySearchService
# Kiểm tra
http://localhost:8761   # dashboard Eureka
```

## Kết quả build & test

```
dotnet build TH6_Microservices.slnx
  Build succeeded. 0 Error(s)   (BlazorWasmClient cũng build được)

dotnet test PricingService.Test       -> 10/10 passed
dotnet test ProductService.Test       -> 14/14 passed
dotnet test PaymentService.Test       ->  6/6 passed
dotnet test PolicyService.Test        ->  8/8 passed
dotnet test PolicySearchService.Test  ->  1/1 passed (placeholder)
```

## Ghi chú kỹ thuật

- `PolicyService`: NHibernate + Npgsql (PostgreSQL), EasyNetQ + Transactional
  Outbox, RestEase gọi PricingService, Steeltoe Eureka discovery.
- `PolicySearchService`: Elasticsearch (Nest) + EasyNetQ (RabbitMQ listener
  PolicyCreated), Steeltoe Eureka discovery.
- Hạ tầng yêu cầu cho demo đầy đủ: PostgreSQL `:5432`, RabbitMQ `:5672`,
  Elasticsearch `:9200`.
- File nộp link theo yêu cầu: `2324801030112_TuNhatAnh_BaiTapTH9.txt`.
