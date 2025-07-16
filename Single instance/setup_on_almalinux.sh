#!/bin/bash

### Определение цветовых кодов ###
ESC=$(printf '\033') RESET="${ESC}[0m" MAGENTA="${ESC}[35m" RED="${ESC}[31m" GREEN="${ESC}[32m"

### Цветные функции ##
magentaprint() { echo; printf "${MAGENTA}%s${RESET}\n" "$1"; }
errorprint() { echo; printf "${RED}%s${RESET}\n" "$1"; }
greenprint() { echo; printf "${GREEN}%s${RESET}\n" "$1"; }

# Переменные
SERVER_IP="$1"  # IP-адрес сервера, на котором будет установлена MongoDB


# ---------------------------------------------------------------------------------------


# Проверка запуска c sudo
if [ "$EUID" -ne 0 ]; then
    errorprint "Скрипт должен быть запущен через sudo!"
    exit 1
fi

# Проверка наличия аргументов
if [ -z "$SERVER_IP" ]; then
    errorprint "Не указан IP-адрес сервера. Используйте: $0 <IP-адрес>"
    echo "Пример: $0 10.100.10.1"
    exit 1
fi

# Добавление репозитория MongoDB
magentaprint "Добавление репозитория MongoDB"
cat <<EOF > /etc/yum.repos.d/mongodb-org-6.0.repo
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF

# Обновление пакетов
magentaprint "Обновление пакетов ..."
dnf update -y

# Установка MongoDB
magentaprint "Установка MongoDB ..."
dnf install -y mongodb-org

# Настройка конфигурации MongoDB
magentaprint "Настройка конфигурации MongoDB /etc/mongod.conf..."
cat <<EOF > /etc/mongod.conf
# mongod.conf
# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# Логирование
systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true                   # Добавление новых логов в конец файла
  verbosity: 0                      # Уровень логирования (0-5, 0 минимальный)

# Настройки хранения данных
storage:
  dbPath: /var/lib/mongo
  journal:                          # Включение журнала для повышения надежности
    enabled: true
#  engine:
  wiredTiger:                       # Использование WiredTiger как движка хранения
    engineConfig:                   # Настройки движка WiredTiger
      cacheSizeGB: 1                # Настройте под объем оперативной памяти (обычно 50% от RAM)

# how the process runs
processManagement:
  pidFilePath: /var/run/mongodb/mongod.pid  # Путь к PID-файлу
  timeZoneInfo: /usr/share/zoneinfo         # Путь к информации о временных зонах

# Сетевые настройки
net:
  port: 27017
  bindIp: 127.0.0.1,$SERVER_IP      # IP-адреса, на которых будет слушать MongoDB
  maxIncomingConnections: 65536     # Максимальное количество входящих соединений

#security:

#operationProfiling:

#replication:

#sharding:

## Enterprise-Only Options

#auditLog:

#snmp:

EOF

# Настройка firewall:
magentaprint "Настраиваем firewall для MongoDB:"
firewall-cmd --permanent --add-port=27017/tcp
firewall-cmd --reload
firewall-cmd --list-all

# Проверка статуса и вервии MongoDB:
magentaprint "Проверка статуса MongoDB:"
systemctl restart mongod                # Перезапуск службы для применения изменений
systemctl enable --now mongod
systemctl status mongod --no-pager

magentaprint "Проверка версии MongoDB:"
mongod --version

greenprint "MongoDB успешно установлен и настроен!"

