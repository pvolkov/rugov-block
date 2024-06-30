#!/bin/bash

# Файл со списком IP-адресов
IP_LIST="blacklist.txt"

# Список цепочек
CHAINS=("RUGOV")

# Проверяем, существует ли файл
if [ ! -f "$IP_LIST" ]; then
    echo "Файл $IP_LIST не найден!"
    exit 1
fi

# Счётчики удалённых правил
count_ipv4=0
count_ipv6=0

# Читаем файл построчно и удаляем соответствующие правила
while IFS= read -r ip; do
    # Игнорируем пустые строки
    if [[ -z "$ip" ]]; then
        continue
    fi

    if [[ "$ip" == *"."* ]]; then
        for chain in "${CHAINS[@]}"; do
            echo "Удаление правила для IPv4: $ip из цепочки $chain"
            sudo iptables -D "$chain" -s "$ip" -j DROP
            # Проверка успешности выполнения команды
            if [ $? -eq 0 ]; then
                count_ipv4=$((count_ipv4 + 1))
            else
                echo "Не удалось удалить правило для IP: $ip из цепочки $chain"
            fi
        done
    elif [[ "$ip" == *":"* ]]; then
        for chain in "${CHAINS[@]}"; do
            echo "Удаление правила для IPv6: $ip из цепочки $chain"
            sudo ip6tables -D "$chain" -s "$ip" -j DROP
            # Проверка успешности выполнения команды
            if [ $? -eq 0 ]; then
                count_ipv6=$((count_ipv6 + 1))
            else
                echo "Не удалось удалить правило для IP: $ip из цепочки $chain"
            fi
        done
    else
        echo "Неверный формат IP-адреса: $ip"
    fi
done < "$IP_LIST"

# Сохранение текущего состояния iptables
sudo iptables-save > /etc/iptables/rules.v4
sudo ip6tables-save > /etc/iptables/rules.v6

echo "Всего удалено правил для IPv4: $count_ipv4."
echo "Всего удалено правил для IPv6: $count_ipv6."
echo "Текущее состояние iptables сохранено в /etc/iptables/rules.v4 и /etc/iptables/rules.v6."
