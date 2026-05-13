#!/bin/bash
# Скрипт: nginx_backup.sh
# Вазифа: Архивкунии конфигҳои Nginx
# Муаллиф: <Aminjonzoda Safiolloh>
# Nikname: <SvS>

# Ҷойгиршавии конфигҳо
NGINX_CONF_DIR="/etc/nginx"
# Ҷойгиршавии захира
BACKUP_DIR="/var/backups/nginx"
# Номи файл бо сана
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/nginx_backup_$DATE.tar.gz"

echo "=== Оғози нусхабардории Nginx ==="

# Агар ҷузвдон вуҷуд надошта бошад — сохтан
mkdir -p "$BACKUP_DIR"

# Архив кардан
tar -czf "$BACKUP_FILE" "$NGINX_CONF_DIR" 2>/dev/null

if [ $? -eq 0 ]; then
  echo "[OK] Нусхабардорӣ анҷом ёфт: $BACKUP_FILE"
else
  echo "[ERROR] Хато ҳангоми нусхабардорӣ!"
fi

echo "=== Анҷом ёфт ==="
