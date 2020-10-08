using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System.Threading;

namespace dotnet_core_31
{
    public class Program
    {
        static ILogger logger;
        public static async Task Main(string[] args)
        {
            using var loggerFactory = LoggerFactory.Create(builder =>
    {
        builder.SetMinimumLevel(LogLevel.Information);
        builder.AddConsole();
        builder.AddEventSourceLogger();
    });
            logger = loggerFactory.CreateLogger("Program");
            logger.LogInformation("App startup: " + DateTime.Now.ToLongTimeString());
            IHost host = CreateHostBuilder(args).Build();
            await host.RunAsync();
            logger.LogInformation("App startup finish: " + DateTime.Now.ToLongTimeString());
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureWebHostDefaults(webBuilder =>
                {
                    webBuilder.UseStartup<Startup>();
                    //logger.LogInformation("App startup finish: " + DateTime.Now.ToLongTimeString());
                });
    }

}
