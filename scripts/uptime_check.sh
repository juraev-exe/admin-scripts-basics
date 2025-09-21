#!/bin/bash
# Скрипт: uptime_check.sh
# Вазифа: Нишон додани uptime ва сарбории система
# Муаллиф: <номи шумо>

echo "=== Маълумот дар бораи система ==="

# Вақти кори система
echo -n "⏱  Вақти кори система: "
uptime -p

# Санаи охирин боркунӣ
echo -n "📅  Система бор карда шуд: "
uptime -s

# Сарбории миёна
echo "⚙️  Сарборӣ (Load Average):"
uptime | awk -F'load average:' '{ print $2 }'

# Истифодаи RAM
echo "💾 RAM истифодашуда:"
free -h | grep Mem | awk '{print "Истифодашуда: "$3" / Ҷамъ: "$2}'

# Истифодаи CPU
echo "🖥  Истифодаи CPU:"
top -bn1 | grep "Cpu(s)" | awk '{print "Истифода: " 100-$8 "%"}'

echo "=== Маълумот ҷамъ оварда шуд ==="
