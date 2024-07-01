#!/bin/bash

# Определение пути к рабочей директории
WORK_DIR="/var/log/rugov_block"

# Создание рабочей директории, если она не существует
mkdir -p ${WORK_DIR}

# Копирование скриптов updater.sh и cleaner.sh в рабочую директорию
cp updater.sh ${WORK_DIR}
cp cleaner.sh ${WORK_DIR}

# Предоставление прав на выполнение
chmod +x ${WORK_DIR}/updater.sh
chmod +x ${WORK_DIR}/cleaner.sh

# Запуск скрипта updater.sh для первоначального обновления правил
${WORK_DIR}/updater.sh

# Создание символической ссылки в /etc/cron.daily
ln -sf ${WORK_DIR}/updater.sh /etc/cron.daily/rugov_block_updater
