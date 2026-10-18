# San pham #2 – Backup / Restore CSDL PostgreSQL

## File backup (thu muc `db-backup/`)
| File | Database |
|---|---|
| `lab_netmicro_payments.backup` | dich vu Payment |
| `lab_netmicro_jobs.backup` | Hangfire jobs |
| `lab_netmicro_policy.backup` | dich vu Policy |
| `lab_netmicro_pricing.backup` | dich vu Pricing |

Tao bang lenh (chay trong `db-backup/`):
```
pg_dump -U postgres -h localhost -p 5432 -F c -f lab_netmicro_payments.backup lab_netmicro_payments
pg_dump -U postgres -h localhost -p 5432 -F c -f lab_netmicro_jobs.backup lab_netmicro_jobs
pg_dump -U postgres -h localhost -p 5432 -F c -f lab_netmicro_policy.backup lab_netmicro_policy
pg_dump -U postgres -h localhost -p 5432 -F c -f lab_netmicro_pricing.backup lab_netmicro_pricing
```

## Cach tao lai CSDL goc (may thay cham / may moi)
1. Cai PostgreSQL >= 10, mo `psql` (user `postgres`).
2. Chay script goc cua de bai:
```
psql -U postgres -h localhost -f postgres/createdatabases.sql
```
Script nay tao role `lab_user` (mat khau `lab_pass`) va 4 database trong.
3. Restore tung database:
```
pg_restore -U postgres -h localhost -p 5432 -d lab_netmicro_payments lab_netmicro_payments.backup
pg_restore -U postgres -h localhost -p 5432 -d lab_netmicro_jobs lab_netmicro_jobs.backup
pg_restore -U postgres -h localhost -p 5432 -d lab_netmicro_policy lab_netmicro_policy.backup
pg_restore -U postgres -h localhost -p 5432 -d lab_netmicro_pricing lab_netmicro_pricing.backup
```
4. Kiem tra: ket noi bang `lab_user`/`lab_pass`, liet ke bang bang `\dt`.

## Chuoi ket noi mau cho cac service (.NET)
```
Host=localhost;Port=5432;Database=lab_netmicro_policy;Username=lab_user;Password=lab_pass
```
(doi ten Database theo tung service: payments / jobs / policy / pricing)
