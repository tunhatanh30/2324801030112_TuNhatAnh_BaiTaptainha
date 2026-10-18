# San pham #3 – Ket qua build

Lenh chay (tai thu muc chua file `DotNetMicroservicesPoc.sln`):
```
dotnet build DotNetMicroservicesPoc.sln
dotnet test DotNetMicroservicesPoc.sln --no-build
```

## Ket qua (log day du trong `build.log`)
- **Build succeeded – 0 Error(s), 11 Warning(s)**
  - 29/29 projects build thanh cong (9 microservices x 3 project + Gateway + Blazor).
  - 11 warnings deu la warning co san, khong phai loi:
    - 2x NU1903/NU1901: canh bao bao mat cua package `Steeltoe.Discovery.Eureka`
      trong project co san `AgentPortalApiGateway` (ma nguon de bai cho).
    - Con lai: warning nullable/CS8632/CS8669/CA2017 trong code Blazor co san.
- **Test: 9/9 project PASSED (Failed: 0).**

## Cach chup man hinh nop elearning
1. Mo Terminal tai thu muc project, chay lai lenh `dotnet build` o tren.
2. Chup man hinh doan cuoi co dong `Build succeeded` + `0 Error(s)`.
3. Nop anh + file `build.log` kem theo de thay doi chieu.
