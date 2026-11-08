using FluentValidation;
using MediatR;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Mvc.NewtonsoftJson;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Steeltoe.Discovery.Client;
using PricingService.Api.Commands;
using PricingService.Behaviors;
using PricingService.Domain;
using PricingService.Infrastructure;
using PricingService.Middleware;

var builder = WebApplication.CreateBuilder(args);
ConfigureServices(builder.Services, builder.Configuration);

var app = builder.Build();

app.UseMiddleware<ValidationExceptionMiddleware>(); // ánh xạ ValidationException -> HTTP 400
app.UseCors("AllowAny"); // TH9 demo web: cho phep trang demo goi API
app.UseDiscoveryClient(); // Task #2: đăng ký dịch vụ lên Eureka
app.MapControllers();

app.Run();

public partial class Program
{
    static void ConfigureServices(IServiceCollection services, IConfiguration configuration)
    {
        services.AddControllers().AddNewtonsoftJson();
        services.AddCors(o => o.AddPolicy("AllowAny", b => b.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));
        services.AddMediatR(cfg =>
            cfg.RegisterServicesFromAssembly(typeof(Program).Assembly));

        // Validator cho CalculatePriceCommand (định nghĩa trong PricingService.Api)
        services.AddScoped<IValidator<CalculatePriceCommand>, CalculatePriceCommandValidator>();

        // Pipeline behavior xác thực command trước khi gửi tới handler
        services.AddTransient(typeof(IPipelineBehavior<,>), typeof(ValidationBehavior<,>));

        // Data store in-memory (chứa tarif mẫu TRI/HSI/FAI/CAR)
        services.AddScoped<IDataStore, InMemoryDataStore>();

        // Steeltoe Discovery Client (Eureka) - Task #2
        services.AddDiscoveryClient(configuration);
    }

    // Cho phép Alba/IntegrationTest tạo host qua Program.CreateWebHostBuilder
    public static IHostBuilder CreateWebHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder.ConfigureServices((ctx, services) => ConfigureServices(services, ctx.Configuration));

                webBuilder.Configure(app =>
                {
                    app.UseMiddleware<ValidationExceptionMiddleware>();
                    app.UseCors("AllowAny");
                    app.UseDiscoveryClient();
                    app.UseEndpoints(endpoints => endpoints.MapControllers());
                });
            });
}
