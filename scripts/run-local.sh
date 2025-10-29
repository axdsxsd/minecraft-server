#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# 1) EULA
printf "eula=true\n" > eula.txt

# 2) Первичный запуск для генерации
java -Xmx2G -jar fabric-server-launch.jar nogui &
PID=$!
sleep 10 || true
kill "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true

# 3) Меняем параметры
/usr/bin/sed -i '' -e 's/^online-mode=.*/online-mode=false/' -e 's/^enforce-secure-profile=.*/enforce-secure-profile=false/' server.properties || true
grep -q '^online-mode=' server.properties || printf "\nonline-mode=false\n" >> server.properties
grep -q '^enforce-secure-profile=' server.properties || printf "enforce-secure-profile=false\n" >> server.properties

# 4) Финальный запуск
exec java -Xms2G -Xmx4G -jar fabric-server-launch.jar nogui