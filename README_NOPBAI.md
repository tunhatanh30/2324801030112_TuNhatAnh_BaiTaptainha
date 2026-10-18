# BAI THUC HANH SO 4 (PHAN 2) – CASE STUDY DAI LY BAO HIEM
## Kien truc Microservices tren .NET Core

### Task #1 – Quy tac to chuc source code
- Solution: `DotNetMicroservicesPoc.sln`
- Moi microservice gom 3 project:
  - `<Ten>.Api` (API definition – classlib net8.0): chua commands/queries/events/DTOs.
    Da viet san DTO toi thieu cho cac service duoc BlazorWasmClient tham chieu:
    `ProductService.Api`, `PolicyService.Api`, `PolicySearchService.Api`,
    `DashboardService.Api`, `PricingService.Api`, `PaymentService.Api`.
  - `<Ten>` (Implementation – WebAPI net8.0): chua handlers, controllers, adapters.
  - `<Ten>.Test` (Test – xUnit net8.0): unit + integration tests.
- Danh sach 9 microservices: Auth, Chat, Dashboard, Document, Payment, Policy,
  PolicySearch, Pricing, Product + `AgentPortalApiGateway` + `BlazorWasmClient`
  (frontend thay the Web-Vue) + `Web` (Vue SPA giu nguyen tu Web.rar).

### Task #2 – Cai dat mot so code ban dau
1. **MediatR 12.4.1**: da `dotnet add package` cho ca 9 project Implementation va
   dang ky trong `Program.cs` (tuong duong `services.AddMediatR()` trong
   `Startup.ConfigureServices` doi voi template .NET 8 minimal hosting):
   `builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(...))`
2. **PostgreSQL >= 10**: cai PostgreSQL 18.x; tao role/DB theo
   `postgres/createdatabases.sql` (`lab_user`, 4 DB `lab_netmicro_*`).
   Xem `DB_BACKUP_HUONGDAN.md` de restore file backup kem theo.
3. **RabbitMQ** 3-management (5672/15672) – chay qua `scripts/infra.yml`.
4. **Elasticsearch** 8.9.2 (>= 6.0) – chay qua `scripts/infra.yml` (9200).
5. **Docker + Docker Compose**: Docker Desktop + Compose v5 (can bat
   Virtualization trong BIOS de chay Docker Desktop/WSL2).
6-11. Da add cac thu muc `eureka-server`, `postgres`, `scripts`, `Web`,
   `BlazorWasmClient`, `AgentPortalApiGateway` vao solution.

### Ket qua build (San pham #3)
- `dotnet build DotNetMicroservicesPoc.sln`: **Build succeeded – 0 Error(s)**,
  11 warnings (warning co san cua Blazor template + canh bao bao mat Steeltoe).
  Chi tiet trong `build.log`.
- `dotnet test`: 9/9 test project PASSED.

### Nop san pham
- **#1**: day repo nay len GitHub, invite `caotxuan@gmail.com` (toi da 10 diem).
  Neu khong kip tao GitHub: nen thu muc project (da co file `.zip` kem theo),
  dua len Drive va nop link elearning (toi da 8 diem).
- **#2**: thu muc `db-backup/` chua file backup 4 CSDL PostgreSQL + huong dan restore.
- **#3**: anh chup man hinh ket qua build (`build-screenshot/` + `build.log`).

Han nop: truoc 18h00 ngay 11/10/2026.
