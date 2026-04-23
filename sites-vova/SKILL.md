---
name: sites-vova
description: Генератор шаблонов CK-лендингов. Собирает готовый HTML+Tailwind скелет (paid course / free course / event) по брифу. Используй когда нужно быстро получить стартовый макет лендинга Cryptology Key.
argument-hint: "[тип продукта: paid|free|event]"
license: MIT
metadata:
  author: cryptology-key
  version: "1.0.0"
---

# sites-vova — шаблонизатор лендингов CK

## Когда активировать

Пользователь пишет:
- `/sites-vova`
- "собери шаблон лендинга CK"
- "нужен скелет для нового курса"
- "сделай лендинг в стиле Cryptology Key"
- "шаблон сайта как у FTT / Base Camp / NeKonfa"

## Что делает

Генерирует **standalone HTML+Tailwind файл** — готовый скелет CK-лендинга с CK-палитрой, типографикой, компонентами (mentor-card, pill-CTA со стрелкой ↗, timer, stats-row, FAQ). Файл открывается в браузере double-click'ом, дальше идёт в Figma/продакшен как starting point.

## Три шаблона v1

| Тип | Файл | Эталон | Секций | Target height |
|---|---|---|---|---|
| **Paid course** | `templates/paid-course.html` | Full-time Trader | 12 | ~12000px |
| **Free course** | `templates/free-course.html` | Base Camp | 8 | ~8000px |
| **Event** | `templates/event.html` | OKX Summit / NeKonfa | 8 | ~9000px |

Остальные типы (promo-sale, mobile-funnel) — в v2. Сейчас не делаем.

## Workflow

### 1. Прогрев контекста (ОБЯЗАТЕЛЬНО перед брифом)

Прочитай последовательно:
- `references/design-dna.txt` — 12 модулей, палитра, типографика CK
- `references/copy-patterns.txt` — CTA-формулы, H1-формулы, секционные заголовки
- KB копирайта: `../../Documents/Рабочее пространство Claude/Бизнес OS/knowledge-base/copywriting/01-brand-voice.md` (voice) и `14-landing-pages.md` (эталоны)

### 2. Бриф через AskUserQuestion (5-7 вопросов)

- **Тип продукта:** paid course / free course / event
- **Название:** (например "Solana Starter", "Workshop v3", "NeKonfa 2026")
- **Главный оффер (H1):** одна строка. Формулы см. `references/copy-patterns.txt`
- **Менторы:** имена + стаж (1-5 штук). Дефолт из KB: Garry 6р, D-Trader 5р, Solva 4р.
- **Старт:** дата (YYYY-MM-DD) или "триває" / "через місяць"
- **Цена:** число+валюта или "безкоштовно"
- **Аудитория:** новачки / вже торгували / всі (влияет на копирайт)

Если пользователь уже в сообщении дал часть брифа — не переспрашивай, только недостающее.

### 3. Сборка

1. Открой `templates/<type>.html`
2. String-replace по плейсхолдерам:
   - `{{ product_name }}` — название
   - `{{ h1 }}` — главный оффер
   - `{{ start_date }}`, `{{ start_date_human }}` — дата в ISO и в формате "15 травня"
   - `{{ price }}` — цена (строка с валютой или "Безкоштовно")
   - `{{ mentor_N_name }}`, `{{ mentor_N_years }}`, `{{ mentor_N_focus }}` для N=1..5
   - `{{ audience_slug }}` — для data-variant на `<body>` (новачки / вже-торгували / всі)
   - `{{ accent_color }}` — если бриф указал цветовой вариант, иначе дефолт шаблона
3. Там, где бриф не покрывает — оставь `<!-- TODO: ... -->` комментарий с подсказкой что вставить.
4. Сохрани результат в `outbox/landing-<slug>-<YYYY-MM-DD>.html` в рабочем пространстве пользователя (путь: `/Users/admin/Documents/Рабочее пространство Claude/outbox/`).

### 4. Отчёт

Короткое сообщение:
- Путь к файлу
- Список оставшихся `<!-- TODO -->` (что ещё дописать)
- Команда для открытия: `open "outbox/landing-<slug>-<date>.html"`

## Правила качества

1. **Всегда UA-копи в плейсхолдерах.** RU — только если пользователь явно попросил.
2. **CTA-капсула со стрелкой ↗** — на всех кнопках. Это фирменный sign.
3. **Один accent-цвет** на лендинг. Master-токены из `design-system/tokens.css` НЕ трогать — это защита от brand fragmentation.
4. **Mentor card** — фото слева, имя жирно справа, chip "досвід N років", направления chip-ами ниже. Формат везде одинаковый.
5. **Timer только если реальный дедлайн.** Если пользователь не указал старт/дедлайн — убери timer из шаблона (закомментируй).
6. **Tone of voice из `01-brand-voice.md`:** прямо, без воды, с конкретикой, ты-обращение, никаких "уважаемые слушатели". Плейсхолдерный копирайт пиши в стиле "Батя, який сам через це пройшов".

## Структура скилла

```
sites-vova/
├── SKILL.md                    # ← этот файл
├── README.md                   # quickstart для человека
├── design-system/
│   ├── tokens.css              # CK master-токены
│   └── components.html         # сниппеты компонентов
├── templates/
│   ├── paid-course.html        # эталон FTT
│   ├── free-course.html        # эталон Base Camp
│   └── event.html              # эталон OKX Summit / NeKonfa
├── references/                 # .txt чтобы Claude Code не регистрировал как команды
│   ├── design-dna.txt           # 12 модулей, палитра, типо, tone
│   ├── ftt-anatomy.txt          # разбор FTT секция за секцией
│   ├── base-camp-anatomy.txt
│   ├── okx-summit-anatomy.txt
│   └── copy-patterns.txt        # формулы H1/CTA/секций
└── preview-screenshots/        # визуальные референсы (PNG)
```

## Вне scope v1

- Promo-sale шаблон (Black Friday стиль)
- Mobile-funnel 720px (PROP BASE стиль)
- Экспорт в Figma
- Полная мультиязычность RU/UA
- Не-CK бренды (GRP.MEDIA и прочее)
