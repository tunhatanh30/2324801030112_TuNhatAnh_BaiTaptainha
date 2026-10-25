namespace PricingService.Domain;

public class DiscountMarkupRule
{
    public string Condition { get; set; } = string.Empty;
    public decimal Percent { get; set; }
}

public class DiscountMarkupRules
{
    private readonly List<DiscountMarkupRule> _rules = new();

    public void AddPercentMarkup(string condition, decimal percent)
    {
        _rules.Add(new DiscountMarkupRule { Condition = condition, Percent = percent });
    }

    public decimal CalculateTotalPercent(IReadOnlyDictionary<string, object> subject)
    {
        var total = 0M;
        foreach (var rule in _rules)
        {
            if (ExpressionEvaluator.EvaluateBool(rule.Condition, subject))
                total += rule.Percent;
        }
        return total;
    }
}
