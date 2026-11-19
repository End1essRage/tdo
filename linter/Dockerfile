FROM mcr.microsoft.com/dotnet/sdk:8.0

# Устанавливаем GDShrapt CLI глобально
RUN dotnet tool install -g GDShrapt.CLI --version 6.0.0-alpha.6

# Добавляем путь к глобальным инструментам в PATH
# Это стандартная практика для образов на базе .NET SDK [citation:4][citation:8]
ENV PATH="${PATH}:/root/.dotnet/tools"

# Устанавливаем рабочую директорию (сюда будет монтироваться проект)
WORKDIR /project