---
description: Транскрибация аудио/видео/YouTube локально через MLX Whisper (бесплатно, on-device). Принимает файл или URL (YouTube, TikTok, Instagram, Vimeo — 1000+ сайтов через yt-dlp)
---

# Транскрибация аудио/видео/URL

Локально на Mac через **MLX Whisper** (Apple Silicon). Бесплатно, без API-ключей, ничего не уходит в интернет. Поддерживает и файлы, и ссылки на YouTube/TikTok/Instagram/Vimeo.

## Шаги

### 1. Проверь установку

```bash
command -v ffmpeg && command -v yt-dlp && ls "$(python3 -m site --user-base)/bin/mlx_whisper" 2>/dev/null || echo "нужна установка"
```

Если чего-то не хватает — запусти однократно установщик:

```bash
bash ~/.claude/commands/install-transcribe.sh
```

Он поставит `ffmpeg`, `yt-dlp` и `mlx-whisper` через Homebrew и pip. Требования: macOS Apple Silicon (M1+) и Homebrew.

### 2. Определи что дал пользователь

**URL** (начинается с `http://` или `https://`) — скачиваем через yt-dlp, потом транскрибируем. Работает для YouTube, TikTok, Instagram Reels, Twitter, Vimeo и 1000+ других сайтов.

**Путь к файлу** — транскрибируем напрямую.

**Нет аргумента** — посмотри свежие файлы в `inbox/`:
```bash
ls -lt inbox/ 2>/dev/null | head -10
```

### 3. Запусти

**Предпочтительно — через wrapper** (если есть `tools/transcribe.sh` в проекте):
```bash
bash tools/transcribe.sh "<URL_ИЛИ_ФАЙЛ>" ru
```

Скрипт сам:
- Определит URL это или файл
- Скачает аудио через yt-dlp (если URL) в `inbox/`
- Найдёт mlx_whisper универсально (через `python3 -m site --user-base`)
- Прогонит через whisper-large-v3-turbo
- Положит результат в `outbox/<имя>-transcript.txt`

**Напрямую** (без wrapper-а):

Для URL:
```bash
yt-dlp -x --audio-format mp3 -o "inbox/%(title).80B [%(id)s].%(ext)s" --no-playlist "<URL>"
# → потом транскрибируем скачанный файл
```

Для файла:
```bash
MLX="$(python3 -m site --user-base)/bin/mlx_whisper"
"$MLX" "<файл>" \
  --model mlx-community/whisper-large-v3-turbo \
  --language ru \
  --output-format txt \
  --output-dir outbox/
```

### 4. Отдай результат

- Результат в `outbox/<имя>-transcript.txt` (или рядом с файлом, если воркспейса нет)
- Если >2000 слов — файлом в Telegram через `mcp__telegram__send_file`
- Если короткий — в чат

## Параметры

- `--language ru` / `uk` / `en` — явно указывай если знаешь, auto-detect иногда путает
- **Модель по умолчанию:** `large-v3-turbo` (1.5GB, ~3 мин на час аудио)
- **Макс качество:** `large-v3` (3GB, в 3-5 раз медленнее)
- **Формат:** `txt` (по умолчанию), `srt` (субтитры с таймкодами), `vtt`, `json`, `all`

## Важно

- **Первый запуск долгий** — качается модель (~1.5GB) в `~/.cache/huggingface/hub/`. Следующие — мгновенно
- **yt-dlp пропускает плейлисты** (`--no-playlist`) — скачает только одно видео по ссылке
- **Длинные видео (2+ часа):** нарежь через ffmpeg перед транскрибацией
- **Приватные/возрастные видео:** yt-dlp умеет cookies, но это надо настраивать отдельно (`--cookies-from-browser chrome`)

## Типичные запросы

- «Транскрибируй https://youtu.be/XXX» → wrapper с URL, язык `ru` по дефолту для русскоязычных каналов
- «Сделай субтитры к видео» → формат `srt`
- «Транскрибируй видео из инбокса» → ищи свежий медиафайл, запускай с `--language ru`
- «Переведи английское аудио на русский» → `--task translate --language en`
