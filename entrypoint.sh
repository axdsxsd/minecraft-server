#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# 1) EULA
if [[ ! -f eula.txt ]]; then
  if [[ "${EULA:-false}" == "true" ]]; then
    printf "eula=true\n" > eula.txt
  else
    echo "EULA not accepted. Set EULA=true env or mount eula.txt" >&2
    exit 1
  fi
fi

# 2) Первичный запуск для генерации файлов (если нужно)
if [[ ! -f server.properties ]]; then
  echo "Priming server files..."
  java -Xms${JAVA_XMS:-2G} -Xmx${JAVA_XMX:-4G} -jar fabric-server-launch.jar nogui &
  PID=$!
  # Даем время создать конфиги, затем останавливаем
  sleep 10 || true
  kill "$PID" 2>/dev/null || true
  # На всякий случай подождем завершения
  wait "$PID" 2>/dev/null || true
fi

# 3) Настройки под неофициальный клиент (можно переопределить OFFLINE=false)
OFFLINE=${OFFLINE:-true}
if [[ "$OFFLINE" == "true" ]]; then
  # BSD/GNU sed совместимость: пробуем оба варианта
  if sed --version >/dev/null 2>&1; then
    sed -i -e 's/^online-mode=.*/online-mode=false/' -e 's/^enforce-secure-profile=.*/enforce-secure-profile=false/' server.properties || true
  else
    /usr/bin/sed -i '' -e 's/^online-mode=.*/online-mode=false/' -e 's/^enforce-secure-profile=.*/enforce-secure-profile=false/' server.properties || true
  fi
  grep -q '^online-mode=' server.properties || printf "\nonline-mode=false\n" >> server.properties
  grep -q '^enforce-secure-profile=' server.properties || printf "enforce-secure-profile=false\n" >> server.properties
fi

echo "Launching server..."
exec java -Xms${JAVA_XMS:-2G} -Xmx${JAVA_XMX:-4G} -jar fabric-server-launch.jar nogui


