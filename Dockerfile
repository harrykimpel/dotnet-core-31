FROM mcr.microsoft.com/dotnet/core/aspnet:3.1
COPY bin/Release/netcoreapp3.1/publish/ App/
WORKDIR /App
EXPOSE 80
#EXPOSE 5000
#EXPOSE 5001
#ENV ASPNETCORE_URLS=https://+:5001;http://+:5000
#ENV ASPNETCORE_URLS http://+5000;https://+5001
#ENV ASPNETCORE_ENVIRONMENT Production
ENTRYPOINT ["dotnet", "dotnet-core-31.dll"]