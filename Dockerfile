# ---------- Build Stage ----------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

ENV DOTNET_DISABLE_PARALLEL=1
ENV UseGitVersion=false

WORKDIR /src
COPY . .

# Restore dependencies
RUN dotnet restore "btcpay-zano-plugin.sln"

# Build BTCPayServer
RUN dotnet build "submodules/btcpayserver/BTCPayServer/BTCPayServer.csproj" -c Release -o /app/build/btcpayserver

# Build Zano plugin
RUN dotnet build "Plugins/Zano/BTCPayServer.Plugins.Zano.csproj" -c Release -o /app/build/plugins/Zano

# Publish BTCPayServer
RUN dotnet publish "submodules/btcpayserver/BTCPayServer/BTCPayServer.csproj" -c Release -o /app/publish

# Publish Zano plugin
RUN dotnet publish "Plugins/Zano/BTCPayServer.Plugins.Zano.csproj" -c Release -o /app/plugins/Zano

# ---------- Runtime Stage ----------
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

RUN apt-get update && apt-get install -y \
    curl wget gnupg software-properties-common \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=build /app/publish ./ 
RUN mkdir -p ./plugins/Zano
COPY --from=build /app/plugins/Zano ./plugins/Zano/
COPY Plugins/Zano/zano.svg ./plugins/Zano/

EXPOSE 23000

VOLUME ["/app/data", "/plugins", "/ssmnt"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:23000/api/health || exit 1

ENTRYPOINT ["dotnet", "BTCPayServer.dll"]
