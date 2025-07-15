#!/bin/bash

### Определение цветовых кодов ###
ESC=$(printf '\033') RESET="${ESC}[0m" MAGENTA="${ESC}[35m" RED="${ESC}[31m" GREEN="${ESC}[32m"

### Цветные функции ##
magentaprint() { echo; printf "${MAGENTA}%s${RESET}\n" "$1"; }
errorprint() { echo; printf "${RED}%s${RESET}\n" "$1"; }
greenprint() { echo; printf "${GREEN}%s${RESET}\n" "$1"; }


# ---------------------------------------------------------------------------------------


# Проверка запуска c sudo
if [ "$EUID" -ne 0 ]; then
    errorprint "Скрипт должен быть запущен через sudo!"
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

# Настройка, по какому IP будет доступна MongoDB
magentaprint "Настройка IP для доступа к MongoDB"
sed -i 's/bindIp: 127.0.0.1/bindIp: 127.0.0.1,10.100.10.1/' /etc/mongod.conf
grep -i "bindIp" /etc/mongod.conf

# Настройка firewall:
magentaprint "Настраиваем firewall для MongoDB:"
firewall-cmd --permanent --add-port=27017/tcp
firewall-cmd --reload
firewall-cmd --list-all

# Проверка статуса и вервии MongoDB:
magentaprint "Проверка статуса MongoDB:"
systemctl enable --now mongod
systemctl status mongod --no-pager

magentaprint "Проверка версии MongoDB:"
mongod --version

greenprint "MongoDB успешно установлен и настроен!"

