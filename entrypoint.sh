#!/usr/bin/env bash
set -euo pipefail

cd /server

# Удаляем клиентские моды, которые ломают сервер
if [[ -d mods ]]; then
  find mods -name "cobblemon-ui-tweaks*.jar" -delete 2>/dev/null || true
fi

# Проверяем наличие jar файла
if [[ ! -f fabric-server-launch.jar ]]; then
  echo "ERROR: fabric-server-launch.jar not found!" >&2
  exit 1
fi

# 1) EULA
if [[ ! -f eula.txt ]]; then
  if [[ "${EULA:-false}" == "true" ]]; then
    printf "eula=true\n" > eula.txt
    echo "EULA accepted"
  else
    echo "EULA not accepted. Set EULA=true env or mount eula.txt" >&2
    exit 1
  fi
fi

# 2) Первичный запуск для генерации файлов (если нужно)
if [[ ! -f server.properties ]]; then
  echo "Priming server files (first run)..."
  java -Xms${JAVA_XMS:-2G} -Xmx${JAVA_XMX:-4G} -jar fabric-server-launch.jar nogui &
  PID=$!
  
  # Ждем появления server.properties (максимум 60 секунд)
  MAX_WAIT=60
  ELAPSED=0
  while [[ ! -f server.properties ]] && [[ $ELAPSED -lt $MAX_WAIT ]]; do
    sleep 2
    ELAPSED=$((ELAPSED + 2))
    if ! kill -0 "$PID" 2>/dev/null; then
      echo "Server process died during priming" >&2
      exit 1
    fi
  done
  
  if [[ ! -f server.properties ]]; then
    echo "ERROR: server.properties was not created after ${MAX_WAIT}s of priming!" >&2
    kill "$PID" 2>/dev/null || true
    exit 1
  fi
  
  # Даем еще немного времени для завершения инициализации
  sleep 5 || true
  kill "$PID" 2>/dev/null || true
  wait "$PID" 2>/dev/null || true
  sleep 2 || true
  echo "Server files generated"
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


