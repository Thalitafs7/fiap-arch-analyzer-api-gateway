FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY ["src/Fiap.ArchAnalyzer.ApiGateway/Fiap.ArchAnalyzer.ApiGateway.csproj", "src/Fiap.ArchAnalyzer.ApiGateway/"]
RUN dotnet restore "src/Fiap.ArchAnalyzer.ApiGateway/Fiap.ArchAnalyzer.ApiGateway.csproj"

COPY . .
WORKDIR "/src/src/Fiap.ArchAnalyzer.ApiGateway"
RUN dotnet build "Fiap.ArchAnalyzer.ApiGateway.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Fiap.ArchAnalyzer.ApiGateway.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "Fiap.ArchAnalyzer.ApiGateway.dll"]
