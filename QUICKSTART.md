# Быстрый старт

## 1. Сделать GitHub доступным

Открой настройки репозитория `clan122222/neo` и сделай его public, либо включи GitHub Pages.

Private-репозиторий не подходит для установки с роутера одной командой: Keenetic получит `404` на raw-файлы.

## 2. Установить на роутер

```sh
opkg update; opkg install wget-ssl ca-certificates || opkg install curl ca-certificates || true; URL=https://raw.githubusercontent.com/clan122222/neo/main/install.sh; if wget -O /opt/tmp/neofit-install.sh "$URL"; then sh /opt/tmp/neofit-install.sh; else curl -fsSL "$URL" -o /opt/tmp/neofit-install.sh && sh /opt/tmp/neofit-install.sh; fi
```

## 3. Проверить

```sh
nf status
sing-box version
/opt/etc/init.d/S99sing-box status
/opt/etc/init.d/S98nf-sb13-watch status
/opt/etc/init.d/S69neofit status
```

## 4. Открыть NeoFit

```text
http://192.168.1.1:92
```

## Если нужен GitHub Pages

Команда для Pages:

```sh
opkg update; opkg install wget-ssl ca-certificates || opkg install curl ca-certificates || true; URL=https://clan122222.github.io/neo/install.sh; if wget -O /opt/tmp/neofit-install.sh "$URL"; then NEOFIT_BASE_URL=https://clan122222.github.io/neo/local-feed sh /opt/tmp/neofit-install.sh; else curl -fsSL "$URL" -o /opt/tmp/neofit-install.sh && NEOFIT_BASE_URL=https://clan122222.github.io/neo/local-feed sh /opt/tmp/neofit-install.sh; fi
```
