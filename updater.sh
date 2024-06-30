#!/bin/bash

# Определение путей и файлов
WORK_DIR="/var/log/rugov_block"
BLACKLIST_URL="https://github.com/C24Be/AS_Network_List/raw/main/blacklists/blacklist.txt"
BLACKLIST_FILE="${WORK_DIR}/blacklist.txt"
OLD_BLACKLIST_FILE="${WORK_DIR}/blacklist_old.txt"
NEW_IPS_FILE="${WORK_DIR}/new_ips.txt"

# Создание новой цепочки, если она еще не существует
iptables -N RUGOV 2>/dev/null || true
iptables -C INPUT -j RUGOV 2>/dev/null || iptables -I INPUT 1 -j RUGOV

# Скачивание списка IP
wget -q -O ${BLACKLIST_FILE} ${BLACKLIST_URL}

# Подготовка списка новых IP
if [ -f "${OLD_BLACKLIST_FILE}" ]; then
    grep -Fxv -f ${OLD_BLACKLIST_FILE} ${BLACKLIST_FILE} > ${NEW_IPS_FILE}
else
    cp ${BLACKLIST_FILE} ${NEW_IPS_FILE}
fi

# Чтение списка IP и обновление правил
while IFS= read -r ip
do
    if echo "${ip}" | grep -q ":"; then
        # Обработка IPv6 адресов
        ip6tables -A INPUT -s "${ip}" -j DROP
    else
        # Обработка IPv4 адресов
        iptables -A RUGOV -s "${ip}" -j DROP
    fi
done < "${NEW_IPS_FILE}"

# Сохранение правил
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

# Обновление старого списка
cp ${BLACKLIST_FILE} ${OLD_BLACKLIST_FILE}

# Логирование
echo "$(date +"%Y-%m-%d %H:%M:%S") - Total IPs: $(wc -l < ${BLACKLIST_FILE}), New IPs: $(wc -l < ${NEW_IPS_FILE}), Rules applied: $(wc -l < ${NEW_IPS_FILE})" >> ${WORK_DIR}/update_log.txt
