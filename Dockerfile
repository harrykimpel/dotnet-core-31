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

# Install the agent
ARG NEW_RELIC_AGENT=newrelic-netcore20-agent
ARG NEW_RELIC_FILE_REGEX=dot_net_agent/latest_release/${NEW_RELIC_AGENT}_\\d*\\.\\d*\\.\\d*\\.\\d*_amd64\\.tar\\.gz
ARG NEW_RELIC_S3_BUCKET=https://nr-downloads-main.s3.amazonaws.com/
ARG NEW_RELIC_ROOT=/usr/local
ARG NEW_RELIC_HOME=${NEW_RELIC_ROOT}/${NEW_RELIC_AGENT}
ENV CORECLR_ENABLE_PROFILING=1 \
    CORECLR_PROFILER={...} \
    CORECLR_NEWRELIC_HOME=$NEW_RELIC_HOME \
    CORECLR_PROFILER_PATH=$NEW_RELIC_HOME/libNewRelicProfiler.so 
RUN mkdir "${NEW_RELIC_HOME}" && \
    cd "${NEW_RELIC_ROOT}" && \
    export NEW_RELIC_DOWNLOAD_URI=${NEW_RELIC_S3_BUCKET}$(wget -qO - "${NEW_RELIC_S3_BUCKET}?delimiter=/&prefix=dot_net_agent/latest_release/${NEW_RELIC_AGENT}" | grep -o "${NEW_RELIC_FILE_REGEX}") && \
    echo "Downloading: $NEW_RELIC_DOWNLOAD_URI into $(pwd)" && \
    wget -qO - "$NEW_RELIC_DOWNLOAD_URI" | tar -xvzf - 
#RUN apk add newrelic-netcore20-agent

# Enable the agent
ENV CORECLR_ENABLE_PROFILING=0 
ENV CORECLR_PROFILER={36032161-FFC0-4B61-B559-F6C5D41BAE5A} 
ENV CORECLR_NEWRELIC_HOME=/usr/local/newrelic-netcore20-agent 
ENV CORECLR_PROFILER_PATH=/usr/local/newrelic-netcore20-agent/libNewRelicProfiler.so 
ENV NEW_RELIC_LICENSE_KEY=<LICENSE-KEY> 
ENV NEW_RELIC_APP_NAME=DotnetCore31

RUN adduser \
    --disabled-password \
    --home /app \
    --gecos '' app \
    && chown -R app /app
#USER app
WORKDIR /app
COPY --from=build-env /app/output .
ENV DOTNET_RUNNING_IN_CONTAINER=true \
    ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "dotnet-core-31.dll"]