#!/bin/bash

# Добавление репозитория MongoDB
cat <<EOF > /etc/yum.repos.d/mongodb-org-6.0.repo
[mongodb-org-6.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/6.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
EOF

dnf update -y

# Установка MongoDB
dnf install -y mongodb-org

# Настройка, по какому IP будет доступна MongoDB
sed -i 's/bindIp: 127.0.0.1/bindIp: 127.0.0.1,10.100.10.1/' /etc/mongod.conf

# Проверка статуса и вервии MongoDB:
systemctl enable --now mongod
systemctl status mongod --no-pager
mongod --version

# Настройка firewall:
firewall-cmd --permanent --add-port=27017/tcp
firewall-cmd --reload
firewall-cmd --list-all

