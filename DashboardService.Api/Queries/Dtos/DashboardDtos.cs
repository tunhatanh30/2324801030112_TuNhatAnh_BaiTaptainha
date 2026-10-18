namespace DashboardService.Api.Queries.Dtos;

public class TotalSalesDto
{
    public decimal PremiumAmount { get; set; }
    public long PoliciesCount { get; set; }
}

public class PeriodSalesDto
{
    public string Period { get; set; } = string.Empty;
    public TotalSalesDto Sales { get; set; } = new();
}
