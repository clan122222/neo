# NeoFit Keenetic Compatible Installer

Совместимый установщик/feed для установки NeoFit на Keenetic + Entware одной командой.

Этот репозиторий не является оригинальным проектом NeoFit. NeoFit принадлежит его upstream-автору `pegakmop`; здесь лежат установочные скрипты, локальный/GitHub OPKG-feed и helper-скрипты совместимости для sing-box 1.13.x. Подробнее: [NOTICE.md](NOTICE.md).

Что внутри:

- локальный OPKG-feed с пакетами третьих сторон: NeoFit, sing-box-go 1.13.4 и Xray;
- установщик одной командой с GitHub;
- фикс совместимости NeoFit -> sing-box 1.13.x;
- watcher, который чинит конфиг sing-box после сохранения из веб-интерфейса NeoFit.

## Установка одной командой

Сделай репозиторий публичным или включи GitHub Pages. Для private-репозитория роутер не сможет скачать файлы без токена.

Команда для роутера:

```sh
opkg update; opkg install wget-ssl ca-certificates || opkg install curl ca-certificates || true; URL=https://raw.githubusercontent.com/clan122222/neo/main/install.sh; WGET=/opt/libexec/wget-ssl; [ -x "$WGET" ] || WGET=wget; if "$WGET" -O /opt/tmp/neofit-install.sh "$URL"; then sh /opt/tmp/neofit-install.sh; else curl -fsSL "$URL" -o /opt/tmp/neofit-install.sh && sh /opt/tmp/neofit-install.sh; fi
```

После установки:

```sh
nf status
opkg list-installed | grep -E '^(neofit|sing-box-go|xray|xray-core)'
sing-box version
```

Веб-интерфейс NeoFit:

```text
http://192.168.1.1:92
```

## Что ставится

- `neofit 1.1.1-5.8.2`
- `sing-box-go 1.13.4`
- `xray v26.2.6`
- `xray-core v26.2.6`
- `ca-bundle 20250419-2`
- `/opt/bin/nf-sb13-fix`
- `/opt/bin/nf-sb13-watch`
- `/opt/etc/init.d/S98nf-sb13-watch`

`sing-box-go` ставится на hold, чтобы OPKG случайно не заменил версию:

```sh
opkg flag hold sing-box-go
```

## Зачем нужен nf-sb13-fix

NeoFit может сохранять старый формат конфига sing-box с полями, которые конфликтуют с sing-box 1.13.x. Скрипт `nf-sb13-fix` приводит `/opt/etc/sing-box/config.json` к рабочему виду, а `nf-sb13-watch` следит за изменениями и автоматически перезапускает sing-box после исправления.

Ручная проверка:

```sh
nf-sb13-fix
sing-box check -c /opt/etc/sing-box/config.json
/opt/etc/init.d/S99sing-box restart
```

## GitHub Pages

Если включить GitHub Pages для ветки `main`, страница с кнопкой копирования будет доступна по адресу:

```text
https://clan122222.github.io/neo/
```

Для Pages можно использовать такую команду:

```sh
opkg update; opkg install wget-ssl ca-certificates || opkg install curl ca-certificates || true; URL=https://clan122222.github.io/neo/install.sh; WGET=/opt/libexec/wget-ssl; [ -x "$WGET" ] || WGET=wget; if "$WGET" -O /opt/tmp/neofit-install.sh "$URL"; then NEOFIT_BASE_URL=https://clan122222.github.io/neo/local-feed sh /opt/tmp/neofit-install.sh; else curl -fsSL "$URL" -o /opt/tmp/neofit-install.sh && NEOFIT_BASE_URL=https://clan122222.github.io/neo/local-feed sh /opt/tmp/neofit-install.sh; fi
```
