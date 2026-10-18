using System.Text;
using System.Text.Json;
using EurekaServer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers().AddNewtonsoftJson();

var app = builder.Build();

// ---- In-memory Eureka registry ----
var registry = new EurekaRegistry();

// Serialize options
var jsonOpts = new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

// Helper: write JSON
async Task WriteJson(HttpContext ctx, object value, int status = 200)
{
    ctx.Response.StatusCode = status;
    ctx.Response.ContentType = "application/json";
    await ctx.Response.WriteAsync(JsonSerializer.Serialize(value, jsonOpts));
}

// Helper: write XML (traditional Eureka format)
async Task WriteXml(HttpContext ctx, string xml, int status = 200)
{
    ctx.Response.StatusCode = status;
    ctx.Response.ContentType = "application/xml";
    await ctx.Response.WriteAsync(xml);
}

// ==================== DASHBOARD ====================
app.MapGet("/", async (HttpContext ctx) =>
{
    var apps = registry.GetAllApps();
    var sb = new StringBuilder();
    sb.Append("<!DOCTYPE html><html><head><meta charset='utf-8'><title>Eureka Server</title>");
    sb.Append("<style>body{font-family:Arial,sans-serif;margin:20px;}h1{color:#333;}table{border-collapse:collapse;width:100%;margin-top:16px;}th,td{border:1px solid #ccc;padding:8px;text-align:left;}th{background:#f4f4f4;}tr:nth-child(even){background:#fafafa;}.status-up{color:green;font-weight:bold;}.status-down{color:red;font-weight:bold;}.badge{display:inline-block;padding:2px 6px;border-radius:4px;font-size:12px;background:#e1f5e1;color:#2e7d32;}a.refresh{margin-bottom:12px;display:inline-block;padding:6px 12px;background:#007bff;color:#fff;text-decoration:none;border-radius:4px;}a.refresh:hover{background:#0056b3;}</style>");
    sb.Append("</head><body>");
    sb.Append("<h1>\ud83c\udf89 Eureka Service Registry</h1>");
    sb.Append("<a class='refresh' href='/'>\ud83d\udd04 Refresh</a>");
    sb.Append($"<p><strong>Running on:</strong> http://localhost:8761</p>");
    sb.Append($"<p><strong>Registered applications:</strong> {apps.Count}</p>");
    sb.Append($"<p><strong>Dashboard time:</strong> {DateTime.Now:yyyy-MM-dd HH:mm:ss}</p>");
    sb.Append("<table><thead><tr><th>Application</th><th>Instance ID</th><th>Host</th><th>Port</th><th>VIP</th><th>Status</th><th>Last Heartbeat</th></tr></thead><tbody>");
    foreach (var appInfo in apps)
    {
        foreach (var inst in appInfo.Instances)
        {
            var statusClass = inst.Status == "UP" ? "status-up" : "status-down";
            var lastHb = inst.LastHeartbeat.HasValue ? inst.LastHeartbeat.Value.ToString("HH:mm:ss") : "never";
            sb.Append("<tr>");
            sb.Append($"<td><span class='badge'>{HtmlEncode(appInfo.Name)}</span></td>");
            sb.Append($"<td>{HtmlEncode(inst.InstanceId)}</td>");
            sb.Append($"<td>{HtmlEncode(inst.HostName)}</td>");
            sb.Append($"<td>{inst.Port}</td>");
            sb.Append($"<td>{HtmlEncode(inst.VipAddress)}</td>");
            sb.Append($"<td class='{statusClass}'>{inst.Status}</td>");
            sb.Append($"<td>{lastHb}</td>");
            sb.Append("</tr>");
        }
    }
    sb.Append("</tbody></table>");
    sb.Append("</body></html>");
    ctx.Response.ContentType = "text/html; charset=utf-8";
    await ctx.Response.WriteAsync(sb.ToString());
});

string HtmlEncode(string s) => System.Net.WebUtility.HtmlEncode(s ?? "");

// ==================== EUREKA REST API ====================

// GET /eureka/apps — danh sách tất cả ứng dụng
app.MapGet("/eureka/apps", async (HttpContext ctx) =>
{
    var accept = ctx.Request.Headers["Accept"].ToString();
    var apps = registry.GetAllApps();

    if (accept.Contains("application/xml", StringComparison.OrdinalIgnoreCase))
    {
        var sb = new StringBuilder();
        sb.Append("<?xml version=\"1.0\" encoding=\"UTF-8\"?><applications>");
        foreach (var a in apps)
        {
            sb.Append("<application><name>").Append(HtmlEncode(a.Name)).Append("</name>");
            foreach (var inst in a.Instances)
            {
                sb.Append("<instance>");
                sb.Append("<instanceId>").Append(HtmlEncode(inst.InstanceId)).Append("</instanceId>");
                sb.Append("<hostName>").Append(HtmlEncode(inst.HostName)).Append("</hostName>");
                sb.Append("<app>").Append(HtmlEncode(a.Name)).Append("</app>");
                sb.Append("<ipAddr>").Append(HtmlEncode(inst.IpAddr)).Append("</ipAddr>");
                sb.Append("<status>").Append(inst.Status).Append("</status>");
                sb.Append("<overriddenstatus>UNKNOWN</overriddenstatus>");
                sb.Append("<port enabled=\"true\">").Append(inst.Port).Append("</port>");
                sb.Append("<securePort enabled=\"false\">443</securePort>");
                sb.Append("<countryId>1</countryId>");
                sb.Append("<dataCenterInfo><name>MyOwn</name></dataCenterInfo>");
                sb.Append("<vipAddress>").Append(HtmlEncode(inst.VipAddress)).Append("</vipAddress>");
                sb.Append("<isCoordinatingDiscoveryServer>false</isCoordinatingDiscoveryServer>");
                sb.Append("<lastUpdated>").Append(inst.LastHeartbeat?.ToString("yyyy-MM-dd HH:mm:ss") ?? "-").Append("</lastUpdated>");
                sb.Append("<lastDirtyTimestamp>-</lastDirtyTimestamp>");
                sb.Append("<actionType>ADDED</actionType>");
                sb.Append("</instance>");
            }
            sb.Append("</application>");
        }
        sb.Append("</applications>");
        await WriteXml(ctx, sb.ToString());
    }
    else
    {
        await WriteJson(ctx, apps.Select(a => new
        {
            name = a.Name,
            instance = a.Instances.Select(inst => new
            {
                instanceId = inst.InstanceId,
                hostName = inst.HostName,
                app = a.Name,
                ipAddr = inst.IpAddr,
                vipAddress = inst.VipAddress,
                status = inst.Status,
                port = inst.Port,
                lastHeartbeat = inst.LastHeartbeat
            })
        }));
    }
});

// GET /eureka/apps/{appId}
app.MapGet("/eureka/apps/{appId}", async (string appId, HttpContext ctx) =>
{
    var appInfo = registry.GetApp(appId);
    if (appInfo == null)
    {
        ctx.Response.StatusCode = 404;
        return;
    }
    await WriteJson(ctx, new { name = appInfo.Name, instance = appInfo.Instances });
});

// GET /eureka/vips/{vip}
app.MapGet("/eureka/vips/{vipAddress}", async (string vipAddress, HttpContext ctx) =>
{
    var apps = registry.GetAppsByVip(vipAddress);
    await WriteJson(ctx, apps);
});

// POST /eureka/apps/{appId} — đăng ký instance
app.MapPost("/eureka/apps/{appId}", async (string appId, HttpContext ctx) =>
{
    using var reader = new StreamReader(ctx.Request.Body);
    var body = await reader.ReadToEndAsync();

    var inst = RegistrationParser.ParseRegistration(body, appId);
    if (inst == null)
    {
        ctx.Response.StatusCode = 400;
        await ctx.Response.WriteAsync("Invalid registration payload");
        return;
    }

    registry.Register(inst);
    ctx.Response.StatusCode = 201;
    ctx.Response.ContentType = "application/json";
    await ctx.Response.WriteAsync("{\"result\":\"registered\"}");
});

// PUT /eureka/apps/{appId}/{instanceId} — heartbeat / renew
app.MapPut("/eureka/apps/{appId}/{instanceId}", async (string appId, string instanceId, HttpContext ctx) =>
{
    var ok = registry.Heartbeat(instanceId);
    if (!ok)
    {
        ctx.Response.StatusCode = 404;
        await ctx.Response.WriteAsync("{\"error\":\"instance not found\"}");
        return;
    }
    ctx.Response.StatusCode = 200;
    await ctx.Response.WriteAsync("{\"result\":\"heartbeat ok\"}");
});

// DELETE /eureka/apps/{appId}/{instanceId} — hủy đăng ký
app.MapDelete("/eureka/apps/{appId}/{instanceId}", async (string appId, string instanceId, HttpContext ctx) =>
{
    registry.Unregister(instanceId);
    ctx.Response.StatusCode = 200;
    await ctx.Response.WriteAsync("{\"result\":\"unregistered\"}");
});

// Fallback cho /eureka (root apps)
app.MapGet("/eureka", async (HttpContext ctx) =>
{
    ctx.Response.Redirect("/eureka/apps");
});

app.Run();
