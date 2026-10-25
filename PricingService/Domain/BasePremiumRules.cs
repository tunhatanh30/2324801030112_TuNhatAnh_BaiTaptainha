namespace PricingService.Domain;

public class BasePremiumRule
{
    public string CoverCode { get; set; } = string.Empty;
    public string? Condition { get; set; }
    public string Formula { get; set; } = string.Empty;
}

public class BasePremiumRules
{
    private readonly List<BasePremiumRule> _rules = new();

    public void AddBasePriceRule(string coverCode, string? condition, string formula)
    {
        _rules.Add(new BasePremiumRule
        {
            CoverCode = coverCode,
            Condition = condition,
            Formula = formula
        });
    }

    public decimal Calculate(string coverCode, IReadOnlyDictionary<string, object> subject)
    {
        var rule = _rules.FirstOrDefault(r => r.CoverCode == coverCode);
        if (rule == null)
            return 0M;

        if (!string.IsNullOrEmpty(rule.Condition) &&
            !ExpressionEvaluator.EvaluateBool(rule.Condition, subject))
        {
            return 0M;
        }

        return ExpressionEvaluator.EvaluateDecimal(rule.Formula, subject);
    }
}
