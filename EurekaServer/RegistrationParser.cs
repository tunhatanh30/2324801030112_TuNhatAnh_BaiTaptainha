namespace EurekaServer;

using System.Text.Json;

public static class RegistrationParser
{
    public static EurekaInstance? ParseRegistration(string body, string appIdFromUrl)
    {
        if (string.IsNullOrWhiteSpace(body)) return null;

        try
        {
            using var doc = JsonDocument.Parse(body);
            JsonElement root = doc.RootElement;

            JsonElement instanceEl;
            if (root.TryGetProperty("instance", out instanceEl))
            {
                return BuildInstanceFromElement(instanceEl, appIdFromUrl);
            }
            return BuildInstanceFromElement(root, appIdFromUrl);
        }
        catch
        {
            return null;
        }
    }

    private static EurekaInstance BuildInstanceFromElement(JsonElement el, string appIdFromUrl)
    {
        string GetString(params string[] names)
        {
            foreach (var n in names)
            {
                if (el.TryGetProperty(n, out var v) && v.ValueKind == JsonValueKind.String)
                    return v.GetString() ?? "";
                if (el.TryGetProperty(n, out var v2) && v2.ValueKind == JsonValueKind.Number)
                    return v2.GetRawText();
            }
            return "";
        }

        int GetPort(params string[] names)
        {
            foreach (var n in names)
            {
                if (el.TryGetProperty(n, out var v))
                {
                    if (v.ValueKind == JsonValueKind.Number) return v.GetInt32();
                    if (v.ValueKind == JsonValueKind.Object && v.TryGetProperty("$", out var portVal))
                        return portVal.GetInt32();
                }
            }
            return 0;
        }

        var instanceId = GetString("instanceId") != ""
            ? GetString("instanceId")
            : $"{GetString("hostName")}:{appIdFromUrl.ToUpperInvariant()}:{GetPort("port")}";

        var appName = GetString("app") != "" ? GetString("app") : appIdFromUrl.ToUpperInvariant();
        var hostName = GetString("hostName") != "" ? GetString("hostName") : "localhost";
        var ipAddr = GetString("ipAddr") != "" ? GetString("ipAddr") : "127.0.0.1";
        var vipAddress = GetString("vipAddress") != "" ? GetString("vipAddress") : appName;
        var port = GetPort("port") != 0 ? GetPort("port") : 5053;

        var metadata = new Dictionary<string, string>();
        if (el.TryGetProperty("metadata", out var metaEl) && metaEl.ValueKind == JsonValueKind.Object)
        {
            foreach (var prop in metaEl.EnumerateObject())
            {
                metadata[prop.Name] = prop.Value.ValueKind == JsonValueKind.String ? prop.Value.GetString()! : prop.Value.GetRawText();
            }
        }

        return new EurekaInstance
        {
            InstanceId = instanceId,
            AppName = appName,
            HostName = hostName,
            IpAddr = ipAddr,
            VipAddress = vipAddress,
            Port = port,
            Status = "UP",
            Metadata = metadata
        };
    }
}
