# NeoFit Keenetic One-Command Installer

Готовое решение для установки NeoFit на Keenetic + Entware без стороннего NeoFit-репозитория.

Что внутри:

- локальный OPKG-feed с пакетами NeoFit, sing-box-go 1.13.4 и Xray;
- установщик одной командой с GitHub;
- фикс совместимости NeoFit -> sing-box 1.13.x;
- watcher, который чинит конфиг sing-box после сохранения из веб-интерфейса NeoFit;
- локальный режим установки с ПК, если GitHub или wget на роутере недоступны.

## Установка одной командой

Сделай репозиторий публичным или включи GitHub Pages. Для private-репозитория роутер не сможет скачать файлы без токена.

Команда для роутера:

```sh
sh -c "$(wget -O- https://raw.githubusercontent.com/clan122222/neo/main/install.sh)"
```

Если `wget` не работает, но есть `curl`:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/clan122222/neo/main/install.sh)"
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

## Локальная установка с ПК

Если не хочешь скачивать с GitHub, запусти feed на компьютере:

```powershell
cd "C:\Users\clan1\OneDrive\Desktop\codex\Progect_Codex_wibe_coding\codex_ai_operating_system\_quarantine_project\Neo_fit"
.\serve-local-feed.ps1
```

На роутере:

```sh
BASE_URL=http://PC_IP:8000 sh -c "$(wget -O- http://PC_IP:8000/install-neofit-local.sh)"
```

`PC_IP` замени на IP компьютера в локальной сети.

## GitHub Pages

Если включить GitHub Pages для ветки `main`, страница с кнопкой копирования будет доступна по адресу:

```text
https://clan122222.github.io/neo/
```

Для Pages можно использовать такую команду:

```sh
NEOFIT_BASE_URL=https://clan122222.github.io/neo/local-feed sh -c "$(wget -O- https://clan122222.github.io/neo/install.sh)"
```

## Важно

- Сейчас feed подготовлен под `aarch64-k3.10`, это подходит для твоего Keenetic Ultra.
- Папки `mipselsf-k3.4` и `mipssf-k3.4` пока содержат только пустые индексы.
- Если репозиторий private, raw-ссылки будут отдавать `404`.
- Для VLESS на практике сейчас лучше использовать Xray-страницу NeoFit, а sing-box оставить как отдельный backend с автофиксом конфига.
