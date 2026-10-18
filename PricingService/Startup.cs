using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using PricingService.Commands;
using PricingService.Domain;
using PricingService.Infrastructure;
using Steeltoe.Discovery.Client;

namespace PricingService;

public class Startup
{
    public Startup(IConfiguration configuration)
    {
        Configuration = configuration;
    }

    public IConfiguration Configuration { get; }

    public void ConfigureServices(IServiceCollection services)
    {
        services.AddControllers();

        // Register MediatR and all request handlers (CalculatePriceHandler) in this assembly.
        services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(CalculatePriceHandler).Assembly));

        // In-memory implementation of IDataStore, pre-seeded with the tariffs used by the tests.
        // In a real deployment this would be replaced by a database-backed implementation
        // (the integration test wires a PostgreSQL connection string here).
        services.AddSingleton<IDataStore, InMemoryDataStore>();

        // Register Eureka discovery client (Steeltoe).
        services.AddDiscoveryClient(Configuration);
    }

    public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
    {
        if (env.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
        }

        app.UseRouting();

        app.UseEndpoints(endpoints =>
        {
            endpoints.MapControllers();
        });
    }
}
