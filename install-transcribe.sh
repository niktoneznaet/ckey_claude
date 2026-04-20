#!/bin/bash
# Установщик зависимостей для скилла /transcribe
#
# Ставит: ffmpeg, yt-dlp, mlx-whisper
# Требования: macOS Apple Silicon (M1+), Homebrew
#
# Запуск: bash ~/.claude/commands/install-transcribe.sh

set -e

echo "🔧 Установка зависимостей для /transcribe"
echo ""

# Проверка платформы
if [[ "$(uname)" != "Darwin" ]]; then
  echo "❌ Этот скилл работает только на macOS."
  echo "   Для Windows/Linux нужна другая реализация (openai-whisper или API)."
  exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
  echo "⚠️  Внимание: MLX Whisper оптимизирован под Apple Silicon (M1/M2/M3/M4)."
  echo "   На Intel Mac он работать не будет (MLX требует Metal + Neural Engine)."
  echo ""
  read -p "Продолжить всё равно? [y/N] " -n 1 -r
  echo ""
  [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

# Проверка Homebrew
if ! command -v brew &>/dev/null; then
  echo "❌ Homebrew не установлен."
  echo "   Установи сначала: https://brew.sh"
  echo "   Команда:"
  echo '   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi

# ffmpeg
if command -v ffmpeg &>/dev/null; then
  echo "✅ ffmpeg уже установлен"
else
  echo "📦 Ставлю ffmpeg..."
  brew install ffmpeg
fi

# yt-dlp
if command -v yt-dlp &>/dev/null; then
  echo "✅ yt-dlp уже установлен"
else
  echo "📦 Ставлю yt-dlp..."
  brew install yt-dlp
fi

# mlx-whisper (pip)
USER_BASE="$(python3 -m site --user-base)"
MLX_WHISPER_PATH="$USER_BASE/bin/mlx_whisper"
if [[ -x "$MLX_WHISPER_PATH" ]] || command -v mlx_whisper &>/dev/null; then
  echo "✅ mlx-whisper уже установлен"
else
  echo "📦 Ставлю mlx-whisper (может занять 1-2 минуты)..."
  pip3 install --user --quiet mlx-whisper
fi

echo ""
echo "✅ Готово! Всё установлено."
echo ""
echo "Проверка:"
command -v ffmpeg | sed 's/^/  ffmpeg:  /'
command -v yt-dlp | sed 's/^/  yt-dlp:  /'
if [[ -x "$MLX_WHISPER_PATH" ]]; then
  echo "  mlx_whisper: $MLX_WHISPER_PATH"
else
  command -v mlx_whisper | sed 's/^/  mlx_whisper: /'
fi
echo ""
echo "Используй скилл: /transcribe <файл-или-URL>"
echo "Первый запуск скачает модель Whisper ~1.5GB (один раз)."
