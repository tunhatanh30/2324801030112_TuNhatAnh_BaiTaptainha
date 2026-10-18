using DashboardService.Api.Queries.Dtos;

namespace DashboardService.Api.Queries;

public enum TimeUnit
{
    Day,
    Week,
    Month,
    Year
}

public class GetTotalSalesQuery
{
    public string? ProductCode { get; set; }
    public DateTime SalesDateFrom { get; set; }
    public DateTime SalesDateTo { get; set; }
}

public class GetTotalSalesResult
{
    public TotalSalesDto Total { get; set; } = new();
    public Dictionary<string, TotalSalesDto> PerProductTotal { get; set; } = new();
}

public class GetAgentsSalesQuery
{
    public DateTime SalesDateFrom { get; set; }
    public DateTime SalesDateTo { get; set; }
}

public class GetAgentsSalesResult
{
    public Dictionary<string, TotalSalesDto> PerAgentTotal { get; set; } = new();
}

public class GetSalesTrendsQuery
{
    public DateTime SalesDateFrom { get; set; }
    public DateTime SalesDateTo { get; set; }
    public TimeUnit Unit { get; set; }
}

public class GetSalesTrendsResult
{
    public List<PeriodSalesDto> PeriodsSales { get; set; } = new();
}
