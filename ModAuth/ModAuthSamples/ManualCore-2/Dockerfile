#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:3.1 AS build
WORKDIR /src
COPY ["ManualCore-2/ManualCore-2.fsproj", "ManualCore-2/"]
RUN dotnet restore "ManualCore-2/ManualCore-2.fsproj"
COPY . .
WORKDIR "/src/ManualCore-2"
RUN dotnet build "ManualCore-2.fsproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ManualCore-2.fsproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ManualCore-2.dll"]