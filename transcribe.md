---
description: Транскрибация аудио/видео/YouTube локально. Для URL сначала ищет ручные субтитры автора (мгновенно), если их нет — качает аудио и прогоняет MLX Whisper
---

# Транскрибация аудио/видео/URL

Локально на Mac. Бесплатно, без API-ключей. Принимает:
- Локальные файлы (mp3/m4a/wav/mp4/mov/mkv/webm/…)
- URL YouTube/TikTok/Instagram/Vimeo и 1000+ других сайтов (через yt-dlp)

## Логика для URL

1. **Пробуем ручные субтитры автора** (`--write-subs`, не автосабы). Если есть — парсим VTT в чистый текст, готово за 2 секунды
2. **Если ручных нет** — скачиваем аудио (mp3, макс качество) и прогоняем MLX Whisper с `whisper-large-v3-turbo`

Почему только **ручные** субтитры:
- Ручные (написанные автором) — идеал, часто лучше Whisper'а
- Авто-субтитры YouTube, особенно на русском — хуже Whisper'а, брать не стоит

Форсировать Whisper даже если сабы есть: `FORCE_WHISPER=1 bash tools/transcribe.sh URL`

## Шаги

### 1. Проверь установку

```bash
command -v ffmpeg && command -v yt-dlp && ls "$(python3 -m site --user-base)/bin/mlx_whisper" 2>/dev/null || echo "нужна установка"
```

Если чего-то нет — разово:
```bash
bash ~/.claude/commands/install-transcribe.sh
```

### 2. Запусти wrapper

```bash
bash tools/transcribe.sh "<URL_ИЛИ_ФАЙЛ>" ru
```

Wrapper сам:
- Определит URL это или файл
- Для URL: попробует ручные субтитры → fallback на аудио+Whisper
- Найдёт mlx_whisper универсально
- Положит результат в `outbox/<имя>-transcript.txt`

Если в проекте нет `tools/transcribe.sh` — скачать или вызвать напрямую (см. ниже).

### 3. Отдай результат

- Результат в `outbox/<имя>-transcript.txt`
- Длинный (>2000 слов) — файлом в Telegram через `mcp__telegram__send_file`
- Короткий — в чат

## Прямые вызовы (без wrapper-а)

**Проверить какие субтитры есть на YouTube-видео:**
```bash
yt-dlp --list-subs "<URL>"
```

**Скачать только ручные субтитры (без видео):**
```bash
yt-dlp --write-subs --sub-langs "ru,uk,en" --sub-format vtt \
  --skip-download --no-playlist \
  -o "inbox/%(title).80B [%(id)s].%(ext)s" "<URL>"
```

**Скачать только аудио для Whisper:**
```bash
yt-dlp -x --audio-format mp3 --audio-quality 0 --no-playlist \
  -o "inbox/%(title).80B [%(id)s].%(ext)s" "<URL>"
```

**Запустить Whisper на файле:**
```bash
MLX="$(python3 -m site --user-base)/bin/mlx_whisper"
"$MLX" "<файл>" \
  --model mlx-community/whisper-large-v3-turbo \
  --language ru \
  --output-format txt \
  --output-dir outbox/
```

## Параметры

- **Язык:** `ru` / `uk` / `en` — явно указывай если знаешь. Для URL также определяет приоритет языков субтитров
- **Модель:** `large-v3-turbo` (по умолчанию, 1.5GB, ~3 мин/час аудио) / `large-v3` (3GB, макс качество) / `medium` / `small` / `base` / `tiny`
- **Формат:** `txt` / `srt` (таймкоды) / `vtt` / `json` / `all`

## Важно

- **Первый запуск долгий** — качается модель (~1.5GB) в `~/.cache/huggingface/hub/`. Следующие — мгновенно
- **Плейлисты** не распаковываются (`--no-playlist` по умолчанию) — только одно видео по ссылке
- **Приватные/возрастные видео:** yt-dlp умеет куки: `--cookies-from-browser chrome`
- **macOS Apple Silicon only** — mlx-whisper не работает на Intel Mac / Windows

## Типичные запросы

- «Транскрибируй https://youtu.be/XXX» → wrapper с URL, язык `ru`
- «Сделай субтитры к видео из ютуба» → формат `srt` (если есть ручные сабы — возьмём VTT, конвертируем в SRT; иначе Whisper с таймкодами)
- «Транскрибируй видео из инбокса» → ищи свежий медиафайл в `inbox/`
- «Переведи английское аудио на русский» → `--task translate --language en`
