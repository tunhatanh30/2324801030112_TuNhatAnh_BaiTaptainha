namespace PricingService.Domain;

public class CoverPrice
{
    public decimal Price { get; set; }
}

public class PriceResult
{
    public decimal TotalPremium { get; set; }
    public Dictionary<string, CoverPrice> Covers { get; set; } = new();
}
