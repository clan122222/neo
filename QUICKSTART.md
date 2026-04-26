# Быстрый старт

## 1. Сделать GitHub доступным

Открой настройки репозитория `clan122222/neo` и сделай его public, либо включи GitHub Pages.

Private-репозиторий не подходит для установки с роутера одной командой: Keenetic получит `404` на raw-файлы.

## 2. Установить на роутер

```sh
sh -c "$(wget -O- https://raw.githubusercontent.com/clan122222/neo/main/install.sh)"
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
NEOFIT_BASE_URL=https://clan122222.github.io/neo/local-feed sh -c "$(wget -O- https://clan122222.github.io/neo/install.sh)"
```
