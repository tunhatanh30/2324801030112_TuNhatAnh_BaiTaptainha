using System;
using System.Collections.Generic;
using System.Linq;

namespace PricingService.Domain;

public class Calculation
{
    public string ProductCode { get; }
    public DateTimeOffset PolicyFrom { get; }
    public DateTimeOffset PolicyTo { get; }
    public IReadOnlyList<string> Covers { get; }
    public IReadOnlyDictionary<string, object> Subject { get; }

    public Calculation(string productCode, DateTimeOffset policyFrom, DateTimeOffset policyTo,
        IEnumerable<string> covers, IDictionary<string, object> subject)
    {
        ProductCode = productCode;
        PolicyFrom = policyFrom;
        PolicyTo = policyTo;
        Covers = covers?.ToList() ?? new List<string>();
        Subject = subject?.ToDictionary(kvp => kvp.Key, kvp => kvp.Value) ?? new Dictionary<string, object>();
    }
}
