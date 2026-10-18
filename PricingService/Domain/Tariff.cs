using System.Collections.Generic;
using System.Linq;

namespace PricingService.Domain;

public class Tariff
{
    public string Code { get; }
    public BasePremiumRules BasePremiumRules { get; } = new();
    public DiscountMarkupRules DiscountMarkupRules { get; } = new();

    public Tariff(string code) => Code = code;

    public PriceResult CalculatePrice(Calculation calculation)
    {
        var result = new PriceResult();

        foreach (var cover in calculation.Covers)
        {
            var price = BasePremiumRules.Calculate(cover, calculation.Subject);
            result.Covers[cover] = new CoverPrice { Price = price };
            result.TotalPremium += price;
        }

        var markupPercent = DiscountMarkupRules.CalculateTotalPercent(calculation.Subject);
        if (markupPercent != 0M)
        {
            var factor = 1M + markupPercent / 100M;
            foreach (var coverPrice in result.Covers.Values)
                coverPrice.Price *= factor;
            result.TotalPremium = result.Covers.Values.Sum(c => c.Price);
        }

        return result;
    }
}
