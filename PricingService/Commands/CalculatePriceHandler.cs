using System.Threading;
using System.Threading.Tasks;
using FluentValidation;
using MediatR;
using PricingService.Api.Commands;
using PricingService.Domain;

namespace PricingService.Commands;

public class CalculatePriceHandler : IRequestHandler<CalculatePriceCommand, CalculatePriceResult>
{
    private readonly IDataStore _dataStore;

    public CalculatePriceHandler(IDataStore dataStore) => _dataStore = dataStore;

    public async Task<CalculatePriceResult> Handle(CalculatePriceCommand command, CancellationToken cancellationToken)
    {
        // Xác thực command trước khi tính toán
        var validator = new CalculatePriceCommandValidator();
        var validationResult = await validator.ValidateAsync(command, cancellationToken);
        if (!validationResult.IsValid)
            throw new ValidationException(validationResult.Errors);

        var tariff = await _dataStore.Tariffs[command.ProductCode];

        var subject = command.Answers
            .ToDictionary(a => a.QuestionCode, a => a.GetAnswer());

        var calculation = new Calculation(
            command.ProductCode,
            command.PolicyFrom,
            command.PolicyTo,
            command.SelectedCovers,
            subject);

        var price = tariff.CalculatePrice(calculation);

        return new CalculatePriceResult
        {
            TotalPrice = price.TotalPremium,
            CoverPrices = price.Covers
                .ToDictionary(kvp => kvp.Key, kvp => kvp.Value.Price)
        };
    }
}
