# Fabric Server (1.21.1)

Репозиторий содержит конфиги и манифест модов; бинарники и миры исключены.

## Требования
- Java 21

## Быстрый старт (локально)
```bash
# положите fabric-server-launch.jar в корень
printf "eula=true\n" > eula.txt
# скачайте моды из mods/manifest.txt и поместите их в mods/
java -Xms2G -Xmx4G -jar fabric-server-launch.jar nogui
```

## Prod (Ubuntu)
- Установите Java 21: `sudo apt install -y openjdk-21-jre-headless`
- При необходимости выключите онлайн‑проверку в `server.properties`:
  - `online-mode=false`
  - `enforce-secure-profile=false`

## Примечания
- Миры (`world*`) и логи не хранятся в репозитории.
- Конфиги модов лежат в `config/`.
- Список модов: `mods/manifest.txt`.
