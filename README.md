# MongoDB 6.0 на AlmaLinux — автоматическая установка и настройка

В этом репозитории представлены скрипты для быстрой установки и настройки MongoDB 6.0 на AlmaLinux как для одиночного экземпляра, так и для кластера (Replica Set).

## Структура проекта

```
.
├── Cluster
│   ├── setup_on_almalinux.sh
│   └── README.md
├── Single instance
│   ├── setup_on_almalinux.sh
│   └── README.md
└── README.md
```

## Одиночный экземпляр

**Папка:** `Single instance`

- Скрипт: `setup_on_almalinux.sh`
- Устанавливает MongoDB 6.0 и настраивает bindIp для доступа по локальному и внешнему IP.
- Открывает порт 27017, включает автозагрузку, показывает статус и версию.

**Запуск:**
```bash
sudo ./Single\ instance/setup_on_almalinux.sh <IP-адрес>
```

Подробнее — см. [Single instance/README.md](./Single%20instance/README.md)

## Кластер (Replica Set)

**Папка:** `Cluster`

- Скрипт: `setup_on_almalinux.sh`
- Устанавливает MongoDB 6.0, включает режим репликации (Replica Set), настраивает bindIp.
- Открывает порт 27017, включает автозагрузку, показывает статус и версию.

**Запуск:**
```bash
sudo ./Cluster/setup_on_almalinux.sh <IP-адрес>
```

**Создание кластера:**  
После установки на всех узлах выполните инициализацию Replica Set через MongoDB Shell.  
Инструкция — см. [Cluster/README.md](./Cluster/README.md)
