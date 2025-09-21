#!/bin/bash
# Скрипт: disk_cleaner.sh
# Вазифа: Тоза кардани ҷузвдонҳои /tmp ва /var/tmp
# Муаллиф: <Aminjonzoda Safiolloh>
# Nikname: <SvS>

echo "=== Тозакунии /tmp ва /var/tmp оғоз шуд ==="

# /tmp
if [ -d "/tmp" ]; then
  rm -rf /tmp/*
  echo "[OK] /tmp тоза шуд"
else
  echo "[!] /tmp вуҷуд надорад"
fi

# /var/tmp
if [ -d "/var/tmp" ]; then
  rm -rf /var/tmp/*
  echo "[OK] /var/tmp тоза шуд"
else
  echo "[!] /var/tmp вуҷуд надорад"
fi

echo "=== Тозакунии муваффақ анҷом ёфт ==="