using System.Collections.Generic;
using System.Threading.Tasks;
using PricingService.Domain;

namespace PricingService.Infrastructure;

public class InMemoryDataStore : IDataStore
{
    public IDictionary<string, Task<Tariff>> Tariffs { get; } = new Dictionary<string, Task<Tariff>>();

    public InMemoryDataStore()
    {
        foreach (var tariff in BuildTariffs())
            Tariffs[tariff.Code] = Task.FromResult(tariff);
    }

    private static IEnumerable<Tariff> BuildTariffs()
    {
        // Travel tariff ("TRI") - matches the scenario used by the unit / integration tests.
        var travel = new Tariff("TRI");
        travel.BasePremiumRules.AddBasePriceRule("C1", null,
            "(NUM_OF_ADULTS) * (DESTINATION == \"EUR\" ? 26.00M : 34.00M)");
        travel.BasePremiumRules.AddBasePriceRule("C2", null,
            "(NUM_OF_ADULTS + NUM_OF_CHILDREN) * 26.00M");
        travel.BasePremiumRules.AddBasePriceRule("C3", null,
            "(NUM_OF_ADULTS + NUM_OF_CHILDREN) * 10.00M");
        travel.DiscountMarkupRules.AddPercentMarkup("DESTINATION == \"WORLD\"", 1.5M);
        yield return travel;

        // House tariff ("HSI").
        var house = new Tariff("HSI");
        house.BasePremiumRules.AddBasePriceRule("C1", "TYP == \"APT\"", "AREA * 1.25M");
        house.BasePremiumRules.AddBasePriceRule("C1", "TYP == \"HOUSE\"", "AREA * 1.50M");
        house.BasePremiumRules.AddBasePriceRule("C2", "TYP == \"APT\"", "AREA * 0.25M");
        house.BasePremiumRules.AddBasePriceRule("C2", "TYP == \"HOUSE\"", "AREA * 0.45M");
        house.BasePremiumRules.AddBasePriceRule("C3", null, "30M");
        house.BasePremiumRules.AddBasePriceRule("C4", null, "50M");
        house.DiscountMarkupRules.AddPercentMarkup("FLOOD == \"YES\"", 1.50M);
        house.DiscountMarkupRules.AddPercentMarkup("NUM_OF_CLAIM > 1 ", 1.25M);
        yield return house;

        // Farm tariff ("FAI").
        var farm = new Tariff("FAI");
        farm.BasePremiumRules.AddBasePriceRule("C1", null, "10M");
        farm.BasePremiumRules.AddBasePriceRule("C2", null, "20M");
        farm.BasePremiumRules.AddBasePriceRule("C3", null, "30M");
        farm.BasePremiumRules.AddBasePriceRule("C4", null, "40M");
        farm.DiscountMarkupRules.AddPercentMarkup("FLOOD == \"YES\"", 1.50M);
        farm.DiscountMarkupRules.AddPercentMarkup("NUM_OF_CLAIM > 2", 2.00M);
        yield return farm;

        // Car tariff ("CAR").
        var car = new Tariff("CAR");
        car.BasePremiumRules.AddBasePriceRule("C1", null, "100M");
        car.DiscountMarkupRules.AddPercentMarkup("NUM_OF_CLAIM > 2", 1.50M);
        yield return car;
    }
}
