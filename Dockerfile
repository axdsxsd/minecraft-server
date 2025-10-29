FROM eclipse-temurin:21-jre

WORKDIR /server

# Копируем базовую структуру сервера (конфиги, лаунчер и пр.)
COPY . /server

EXPOSE 25565

# Память и EULA по умолчанию можно переопределять переменными окружения
ENV JAVA_XMS=2G \
    JAVA_XMX=4G \
    EULA=true

# Директории, которые удобно монтировать снаружи
VOLUME ["/server/world", "/server/logs", "/server/config", "/server/mods"]

ENTRYPOINT ["bash", "/server/entrypoint.sh"]


