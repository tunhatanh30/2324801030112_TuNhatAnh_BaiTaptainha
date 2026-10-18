namespace EurekaServer;

public class EurekaInstance
{
    public string InstanceId { get; set; } = "";
    public string AppName { get; set; } = "";
    public string HostName { get; set; } = "";
    public string IpAddr { get; set; } = "";
    public string VipAddress { get; set; } = "";
    public int Port { get; set; }
    public string Status { get; set; } = "UP";
    public DateTime? LastHeartbeat { get; set; }
    public DateTime RegisteredAt { get; set; } = DateTime.Now;
    public Dictionary<string, string> Metadata { get; set; } = new();
}

public class AppInfo
{
    public string Name { get; set; } = "";
    public List<EurekaInstance> Instances { get; set; } = new();
}

public class EurekaRegistry
{
    private readonly Dictionary<string, AppInfo> _apps = new(StringComparer.OrdinalIgnoreCase);
    private readonly Dictionary<string, EurekaInstance> _byInstanceId = new(StringComparer.OrdinalIgnoreCase);
    private readonly object _lock = new();

    public void Register(EurekaInstance inst)
    {
        lock (_lock)
        {
            inst.LastHeartbeat = DateTime.Now;
            var appName = inst.AppName.ToUpperInvariant();
            if (!_apps.TryGetValue(appName, out var appInfo))
            {
                appInfo = new AppInfo { Name = appName };
                _apps[appName] = appInfo;
            }
            var existing = appInfo.Instances.FirstOrDefault(i => i.InstanceId == inst.InstanceId);
            if (existing != null)
            {
                existing.HostName = inst.HostName;
                existing.IpAddr = inst.IpAddr;
                existing.VipAddress = inst.VipAddress;
                existing.Port = inst.Port;
                existing.Status = inst.Status;
                existing.LastHeartbeat = DateTime.Now;
                existing.Metadata = inst.Metadata;
            }
            else
            {
                appInfo.Instances.Add(inst);
            }
            _byInstanceId[inst.InstanceId] = inst;
        }
    }

    public bool Heartbeat(string instanceId)
    {
        lock (_lock)
        {
            if (_byInstanceId.TryGetValue(instanceId, out var inst))
            {
                inst.LastHeartbeat = DateTime.Now;
                inst.Status = "UP";
                return true;
            }
            return false;
        }
    }

    public void Unregister(string instanceId)
    {
        lock (_lock)
        {
            if (_byInstanceId.TryGetValue(instanceId, out var inst))
            {
                var appName = inst.AppName.ToUpperInvariant();
                if (_apps.TryGetValue(appName, out var appInfo))
                {
                    appInfo.Instances.RemoveAll(i => i.InstanceId == instanceId);
                    if (appInfo.Instances.Count == 0)
                        _apps.Remove(appName);
                }
                _byInstanceId.Remove(instanceId);
            }
        }
    }

    public AppInfo? GetApp(string appId)
    {
        lock (_lock)
        {
            return _apps.TryGetValue(appId.ToUpperInvariant(), out var a) ? a : null;
        }
    }

    public List<AppInfo> GetAllApps()
    {
        lock (_lock)
        {
            return _apps.Values.Select(a => new AppInfo
            {
                Name = a.Name,
                Instances = a.Instances.Select(i => new EurekaInstance
                {
                    InstanceId = i.InstanceId,
                    AppName = i.AppName,
                    HostName = i.HostName,
                    IpAddr = i.IpAddr,
                    VipAddress = i.VipAddress,
                    Port = i.Port,
                    Status = i.Status,
                    LastHeartbeat = i.LastHeartbeat
                }).ToList()
            }).ToList();
        }
    }

    public List<AppInfo> GetAppsByVip(string vip)
    {
        lock (_lock)
        {
            return _apps.Values
                .Where(a => a.Instances.Any(i => i.VipAddress == vip))
                .Select(a => new AppInfo
                {
                    Name = a.Name,
                    Instances = a.Instances.Where(i => i.VipAddress == vip).ToList()
                })
                .ToList();
        }
    }
}
