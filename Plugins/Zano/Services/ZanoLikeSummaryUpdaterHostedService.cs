using System;
using System.Threading;
using System.Threading.Tasks;

using BTCPayServer.Logging;
using BTCPayServer.Plugins.Zano.Configuration;

using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace BTCPayServer.Plugins.Zano.Services
{
    public class ZanoLikeSummaryUpdaterHostedService : IHostedService
    {
        private readonly ZanoRPCProvider _ZanoRpcProvider;
        private readonly ZanoLikeConfiguration _zanoLikeConfiguration;

        public Logs Logs { get; }

        private CancellationTokenSource _Cts;
        public ZanoLikeSummaryUpdaterHostedService(ZanoRPCProvider zanoRpcProvider, ZanoLikeConfiguration zanoLikeConfiguration, Logs logs)
        {
            _ZanoRpcProvider = zanoRpcProvider;
            _zanoLikeConfiguration = zanoLikeConfiguration;
            Logs = logs;
        }
        public Task StartAsync(CancellationToken cancellationToken)
        {
            _Cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
            foreach (var zanoLikeConfigurationItem in _zanoLikeConfiguration.ZanoLikeConfigurationItems)
            {
                _ = StartLoop(_Cts.Token, zanoLikeConfigurationItem.Key);
            }
            return Task.CompletedTask;
        }

        private async Task StartLoop(CancellationToken cancellation, string cryptoCode)
        {
            Logs.PayServer.LogInformation($"Starting listening Zano-like daemons ({cryptoCode})");
            try
            {
                while (!cancellation.IsCancellationRequested)
                {
                    try
                    {
                        await _ZanoRpcProvider.UpdateSummary(cryptoCode);
                        if (_ZanoRpcProvider.IsAvailable(cryptoCode))
                        {
                            await Task.Delay(TimeSpan.FromMinutes(1), cancellation);
                        }
                        else
                        {
                            await Task.Delay(TimeSpan.FromSeconds(10), cancellation);
                        }
                    }
                    catch (Exception ex) when (!cancellation.IsCancellationRequested)
                    {
                        Logs.PayServer.LogError(ex, $"Unhandled exception in Summary updater ({cryptoCode})");
                        await Task.Delay(TimeSpan.FromSeconds(10), cancellation);
                    }
                }
            }
            catch when (cancellation.IsCancellationRequested)
            {
                // ignored
            }
        }

        public Task StopAsync(CancellationToken cancellationToken)
        {
            _Cts?.Cancel();
            _Cts?.Dispose();
            return Task.CompletedTask;
        }
    }
}