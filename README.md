# BÀI THỰC HÀNH SỐ 7 – CASE STUDY CÔNG TY BẢO HIỂM (PHẦN 5)

## Lưu trữ và truy cập dữ liệu hiệu quả cùng Marten

Sinh viên: **Tú Nhất Anh** – MSSV: **2324801030112**

Repository: <https://github.com/tunhatanh30/2324801030112_TuNhatAnh_BaiTaptainha.git>

---

## Task #1 – Thêm Marten vào dự án (NuGet)

Package **Marten 7.19.1** đã được cài đặt vào microservice **PaymentService**
(`PaymentService/PaymentService.csproj`) thông qua NuGet:

```
dotnet add PaymentService package Marten --version 7.19.1
```

Marten cho phép sử dụng PostgreSQL làm cơ sở dữ liệu tài liệu (document DB)
và kho sự kiện (event store) với LINQ support đầy đủ.

## Task #2 – Code microservice PaymentService (3 thư mục mới)

Code được copy từ file đính kèm (`PaymentService.rar`, `PaymentService.Api.rar`,
`PaymentService.Test.rar`):

| Thư mục | Nội dung chính |
|---------|----------------|
| `DataAccess/Marten/` | `MartenDataStore.cs`, `MartenInstaller.cs`, `MartenPolicyAccountRepository.cs`, `ProtectedSettersContractResolver.cs` |
| `Domain/` | `PolicyAccount.cs`, `AccountingEntry.cs`, `ExpectedPayment.cs`, `InPayment.cs`, `OutPayment.cs`, `InPaymentRegistrationService.cs`, `PolicyAccountNumberGenerator.cs` … |
| `Jobs/` | `InPaymentRegistrationJob.cs` (Hangfire background job), `BackgroundJobsConfig.cs`, `JobsInstaller.cs` |

Ngoài ra: `Listeners/PolicyCreatedHandler.cs`, `Listeners/PolicyTerminatedHandler.cs`,
`Messaging/RabbitMq/`, `Init/`, `Infrastructure/`, `Queries/GetAccountBalanceHandler.cs`,
`Controllers/PaymentController.cs`.

## Task #3 – Code microservice ProductService (3 thư mục mới)

Code được copy từ file đính kèm (`ProductService.rar`, `ProductService.Api.rar`,
`ProductService.Test.rar`):

| Thư mục | Nội dung chính |
|---------|----------------|
| `Commands/` | `CreateProductDraftHandler.cs`, `ActivateProductHandler.cs`, `DiscontinueProductHandler.cs` |
| `Queries/` | `FindAllProductsHandler.cs`, `FindProductByCodeHandler.cs`, `Mappers/ProductMapper.cs` |
| `DataAccess/EF/` | `ProductDbContext.cs`, `ProductRepository.cs`, `EFInstaller.cs`, `Configuration/ProductConfig.cs` (EF Core InMemory/SqlServer) |

Ngoài ra: `Domain/` (Product, Cover, Question, Choice), `Init/DataLoader.cs`,
`Controllers/ProductsController.cs`, `.Api` chứa commands/queries/DTOs,
`.Test` chứa 14 unit/integration tests (xUnit + WebApplicationFactory).

## Kiết quả build & test

```
dotnet build TH6_Microservices.slnx
  Build succeeded. 0 Error(s)

dotnet test PricingService.Test      -> 10/10 passed
dotnet test ProductService.Test      -> 14/14 passed
dotnet test PaymentService.Test      ->  6/6 passed
```

Build **không còn lỗi** liên quan đến các projects đã được bổ sung (theo yêu cầu đề bài).

## Ghi chú kỹ thuật

- `ProductService` dùng EF Core (InMemory/SqlServer) + Steeltoe Eureka discovery.
- `PaymentService` dùng **Marten 7.19.1** (PostgreSQL document DB), EasyNetQ (RabbitMQ),
  Hangfire (background jobs), GlobalExceptionHandler.
- `PolicyService.Api` được bổ sung event **`PolicyTerminated`** mà
  `PaymentService/Listeners/PolicyTerminatedHandler.cs` cần thiết.
- Chuẩn PostgreSQL local (cho Marten):
  `User ID=lab_user;Password=lab_pass;Database=lab_netmicro_payments;Host=localhost;Port=5432`
