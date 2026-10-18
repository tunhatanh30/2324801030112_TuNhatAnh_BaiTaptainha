using Microsoft.Extensions.Hosting;

namespace PricingService;

public partial class Program
{
    public static IHostBuilder CreateWebHostBuilder(string[] args) =>
        Host.CreateDefaultBuilder(args)
            .ConfigureWebHostDefaults(webBuilder =>
            {
                webBuilder.UseStartup<Startup>();
            });

    public static void Main(string[] args)
    {
        CreateWebHostBuilder(args).Build().Run();
    }
}
