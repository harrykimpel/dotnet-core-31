ARG VERSION=3.1-alpine3.10
FROM mcr.microsoft.com/dotnet/core/sdk:$VERSION AS build-env
WORKDIR /app
ADD /src/*.csproj .
RUN dotnet restore
ADD /src .
RUN dotnet publish \
    -c Release \
    -o ./output
FROM mcr.microsoft.com/dotnet/core/aspnet:$VERSION
RUN adduser \
    --disabled-password \
    --home /app \
    --gecos '' app \
    && chown -R app /app
USER app
WORKDIR /app
COPY --from=build-env /app/output .
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "dotnet-core-31.dll"]