using System;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;

using BTCPayServer.Abstractions.Contracts;
using BTCPayServer.Abstractions.Models;
using BTCPayServer.Configuration;
using BTCPayServer.Hosting;
using BTCPayServer.Payments;
using BTCPayServer.Plugins.Zano.Configuration;
using BTCPayServer.Plugins.Zano.Payments;
using BTCPayServer.Plugins.Zano.Services;
using BTCPayServer.Services;

using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

using NBitcoin;

using NBXplorer;

namespace BTCPayServer.Plugins.Zano;

public class ZanoPlugin : BaseBTCPayServerPlugin
{
    public override IBTCPayServerPlugin.PluginDependency[] Dependencies { get; } =
    {
      //  new IBTCPayServerPlugin.PluginDependency { Identifier = nameof(BTCPayServer), Condition = ">=2.1.0" }
    };

    public override void Execute(IServiceCollection services)
    {
        var pluginServices = (PluginServiceCollection)services;
        var prov = pluginServices.BootstrapServices.GetRequiredService<NBXplorerNetworkProvider>();
        var chainName = prov.NetworkType;

        var network = new ZanoLikeSpecificBtcPayNetwork()
        {
            CryptoCode = "ZANO",
            DisplayName = "Zano",
            Divisibility = 12,
            DefaultRateRules = new[]
    {
        "ZANO_X = ZANO_BTC * BTC_X",
        "ZANO_BTC = zano(ZANO_BTC)",
        "ZANO_USD = zano(ZANO_USD)",
        "ZANO_EUR = zano(ZANO_EUR)"
    },
            CryptoImagePath = "imlegacy/zano.svg",
            UriScheme = "zano"
        };

        var blockExplorerLink = chainName == ChainName.Mainnet
       ? "https://explorer.zano.org/tx/{0}"
       : "https://testnet.explorer.zano.org/tx/{0}";


        var pmi = PaymentTypes.CHAIN.GetPaymentMethodId("ZANO");
        services.AddDefaultPrettyName(pmi, network.DisplayName);
        services.AddBTCPayNetwork(network)
                .AddTransactionLinkProvider(pmi, new SimpleTransactionLinkProvider(blockExplorerLink));


        services.AddSingleton(provider =>
                ConfigureZanoLikeConfiguration(provider));
        services.AddHttpClient("ZANOclient")
            .ConfigurePrimaryHttpMessageHandler(provider =>
            {
                var configuration = provider.GetRequiredService<ZanoLikeConfiguration>();
                if (!configuration.ZanoLikeConfigurationItems.TryGetValue("ZANO", out var zanoConfig) || zanoConfig.Username is null || zanoConfig.Password is null)
                {
                    return new HttpClientHandler();
                }
                return new HttpClientHandler
                {
                    Credentials = new NetworkCredential(zanoConfig.Username, zanoConfig.Password),
                    PreAuthenticate = true
                };
            });
       
        services.AddSingleton<ZanoRPCProvider>();
        services.AddHostedService<ZanoLikeSummaryUpdaterHostedService>();
        services.AddHostedService<ZanoListener>();
        
       
        services.AddSingleton<IPaymentMethodHandler>(provider =>
                (IPaymentMethodHandler)ActivatorUtilities.CreateInstance(provider, typeof(ZanoLikePaymentMethodHandler), new object[] { network
}));
        services.AddSingleton<IPaymentLinkExtension>(provider =>
(IPaymentLinkExtension)ActivatorUtilities.CreateInstance(provider, typeof(ZanoPaymentLinkExtension), new object[] { network, pmi }));
        services.AddSingleton<ICheckoutModelExtension>(provider =>
        (ICheckoutModelExtension)ActivatorUtilities.CreateInstance(provider, typeof(ZanoCheckoutModelExtension), new object[] { network, pmi }));

        services.AddSingleton<ICheckoutCheatModeExtension>(provider =>
            (ICheckoutCheatModeExtension)ActivatorUtilities.CreateInstance(provider, typeof(ZanoCheckoutCheatModeExtension), new object[] { network, pmi }));

        services.AddUIExtension("store-nav", "/Views/Zano/StoreNavZanoExtension.cshtml");
        services.AddUIExtension("store-wallets-nav", "/Views/Zano/StoreWalletsNavZanoExtension.cshtml");
        services.AddUIExtension("store-invoices-payments", "/Views/Zano/ViewZanoLikePaymentData.cshtml");
        services.AddSingleton<ISyncSummaryProvider, ZanoSyncSummaryProvider>();
    }
    class SimpleTransactionLinkProvider : DefaultTransactionLinkProvider
    {
        public SimpleTransactionLinkProvider(string blockExplorerLink) : base(blockExplorerLink)
        {
        }

        public override string GetTransactionLink(string paymentId)
        {
            if (string.IsNullOrEmpty(BlockExplorerLink))
            {
                return null;
            }
            return string.Format(CultureInfo.InvariantCulture, BlockExplorerLink, paymentId);
        }
    }

    private static ZanoLikeConfiguration ConfigureZanoLikeConfiguration(IServiceProvider serviceProvider)
    {
        var configuration = serviceProvider.GetService<IConfiguration>();
        var btcPayNetworkProvider = serviceProvider.GetService<BTCPayNetworkProvider>();
        var result = new ZanoLikeConfiguration();

        var supportedNetworks = btcPayNetworkProvider.GetAll()
            .OfType<ZanoLikeSpecificBtcPayNetwork>();

        foreach (var zanoLikeSpecificBtcPayNetwork in supportedNetworks)
        {
            var daemonUri =
                configuration.GetOrDefault<Uri>($"{zanoLikeSpecificBtcPayNetwork.CryptoCode}_daemon_uri",
                    null);
            var walletDaemonUri =
                configuration.GetOrDefault<Uri>(
                    $"{zanoLikeSpecificBtcPayNetwork.CryptoCode}_wallet_daemon_uri", null);
            var cashCowWalletDaemonUri =
                configuration.GetOrDefault<Uri>(
                    $"{zanoLikeSpecificBtcPayNetwork.CryptoCode}_cashcow_wallet_daemon_uri", null);
            var walletDaemonWalletDirectory =
                configuration.GetOrDefault<string>(
                    $"{zanoLikeSpecificBtcPayNetwork.CryptoCode}_wallet_daemon_walletdir", null);
            var daemonUsername =
                configuration.GetOrDefault<string>(
                    $"{zanoLikeSpecificBtcPayNetwork.CryptoCode}_daemon_username", null);
            var daemonPassword =
                configuration.GetOrDefault<string>(
                    $"{zanoLikeSpecificBtcPayNetwork.CryptoCode}_daemon_password", null);
            if (daemonUri == null || walletDaemonUri == null)
            {
                var logger = serviceProvider.GetRequiredService<ILogger<ZanoPlugin>>();
                var cryptoCode = zanoLikeSpecificBtcPayNetwork.CryptoCode.ToUpperInvariant();
                if (daemonUri is null)
                {
                    logger.LogWarning($"BTCPAY_{cryptoCode}_DAEMON_URI is not configured");
                }
                if (walletDaemonUri is null)
                {
                    logger.LogWarning($"BTCPAY_{cryptoCode}_WALLET_DAEMON_URI is not configured");
                }
                logger.LogWarning($"{cryptoCode} got disabled as it is not fully configured.");
            }
            else
            {
                result.ZanoLikeConfigurationItems.Add(zanoLikeSpecificBtcPayNetwork.CryptoCode, new ZanoLikeConfigurationItem()
                {
                    DaemonRpcUri = daemonUri,
                    Username = daemonUsername,
                    Password = daemonPassword,
                    InternalWalletRpcUri = walletDaemonUri,
                    WalletDirectory = walletDaemonWalletDirectory,
                    CashCowWalletRpcUri = cashCowWalletDaemonUri,
                });
            }
        }
        return result;
    }
}