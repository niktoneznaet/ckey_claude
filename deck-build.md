---
name: deck-build
description: Рендерер видео-презентаций CK. Вход — JSON-выход от `/sufler-to-deck` (или вручную написанный slide-list). Выход — self-contained HTML + PDF по brand book v3 (моноспейс JetBrains Mono, чёрный фон, dotted pattern, lime accent, tier-цвета, outlined nums, real wordmark CK). HTML интерактивный: scroll-snap, fadeUp animations с IntersectionObserver, dot-navigation справа, keyboard navigation (arrow keys + Home/End). PDF статичный без анимаций. 20 типов слайдов: section-title, number, stats-grid, quote, term-card, takeaway, example-slot, comparison, steps, screenshot-showcase, cta, centered-intro, icon-grid, numbered-grid, pipeline-flow, key-value-table, hierarchy-tree, progress-bar, outcomes-row, punch-line. Каждый `example-slot` рендерится как outlined placeholder с описанием для монтажника / Open Design / Higgsfield. Форматы 16:9 (1920×1080) и 9:16 (1080×1920).
---

# /deck-build v2 — HTML+PDF рендерер видео-презентаций CK

Конвертируешь slide-list (JSON от `/onscreen`) в **self-contained HTML-презентацию** по **brand book v2** CK + рендеришь PDF через headless Chrome.

HTML — **интерактивный**: scroll-snap, fadeUp animations, dot-nav, arrow keys. PDF — **статичный** (анимации отключаются в @media print).

## Pipeline где ты живёшь

```
Текст суфлёра → /onscreen → JSON deck-output → [ТЫ] → presentation.html + presentation.pdf + examples-brief.md
```

## Источник правды

**Brand book v3 (UI Kit aligned):** ищи папку `ck-brand/` рядом со скиллом.
- У Vlad: `/Users/admin/Documents/Рабочее пространство Claude/Бизнес OS/knowledge-base/references/ck-brand/` (полный набор + `source-decks/` для референса)
- У сотрудника (клон `niktoneznaet/ckey_claude`): `~/.claude/commands/ck-brand/` (минимальный пакет: design-system-v3 + tokens + logobook/assets + brand-book-a4-v2)

Файлы:
- `_index.txt` (у сотрудника) / `_index.md` (у Vlad) — карта KB, читать первым
- `design-system-v3.html` — главный документ (15 секций: tokens, typography, components, slide chrome, 8 templates, data viz, tier colors, product palettes, logobook)
- `tokens.css` — переиспользуемые CSS variables (подключать через `<link>` или `@import`)
- `logobook/assets/ck-wordmark-horizontal.png` — wordmark для углов слайдов
- `source-decks/deck-A_FTT-v2/` и `source-decks/deck-B/` — референс-слайды (только в полном наборе у Vlad)

## Что подаётся на вход

- **Файл с output от `/onscreen`** (markdown + JSON-блок ` ```json deck-output `) — приоритетно
- **Чистый JSON** в схеме `/onscreen`

## Что выдаёшь

1. `presentation.html` — один self-contained HTML файл с интерактивностью
2. `presentation.pdf` — рендер HTML через headless Chrome (статичный)
3. `source.json` — копия входного JSON для воспроизводимости
4. `examples-brief.md` — бриф для монтажника / Open Design / Higgsfield (по одному блоку на каждый `example-slot` с готовым промптом)
5. `README.md` — короткая инструкция

**Где сохранять:** `Бизнес OS/outbox/deck-build/ГГГГ-ММ-ДД_название/` (у Vlad). Сотрудник адаптирует путь под свою структуру.

---

## Brand book v3 константы (НЕ менять)

Полный набор токенов — в `ck-brand/tokens.css`. Минимальный inline-блок для self-contained HTML:

```css
:root {
  /* bg / surface / border */
  --bg-black: #000000;
  --bg-page: #0A0A0A;
  --surface-1: #0E0E10;
  --surface-2: #16161A;
  --border-subtle: #2A2A2E;
  --border-dim: #1F1F22;
  --dot: #1F1F22;

  /* text — обновлено в v3 (светлее) */
  --text-primary: #FFFFFF;
  --text-secondary: #A1A1A6;   /* было #8A8A8E */
  --text-tertiary:  #6B6B70;   /* было #5A5A5E */

  /* accent */
  --accent-lime:      #C9F858;
  --accent-lime-soft: #7C9D38;  /* новое в v3 */

  /* semantic — Tailwind 500-shades */
  --sem-green:  #22C55E;
  --sem-blue:   #3B82F6;  /* новое в v3 */
  --sem-violet: #A855F7;
  --sem-orange: #F97316;
  --sem-red:    #EF4444;

  /* product layer — tier colors */
  --t-junior: #FFFFFF;
  --t-middle: #22C55E;
  --t-senior: #F8D038;
  --t-super:  #F97316;

  /* product accent palettes */
  --ftt-blue:  #1828D0;
  --ws-grad-1: #F7CCBC;
  --ws-grad-2: #E5936E;

  /* result iso stacks */
  --r-pink:    #F472B6;
  --r-emerald: #10B981;
  --r-violet:  #A855F7;
}

/* aliases для обратной совместимости со старыми CSS-блоками v2 */
:root {
  --bg: var(--bg-black);
  --pattern: var(--dot);
  --border: var(--border-subtle);
  --text: var(--text-primary);
  --text-muted: var(--text-secondary);
  --text-mute2: var(--text-tertiary);
  --lime: var(--accent-lime);
  --t-jun: var(--t-junior);
  --t-mid: var(--t-middle);
  --t-sen: var(--t-senior);
  --t-sup: var(--t-super);
  --r-emer: var(--r-emerald);
  --red: var(--sem-red);
  --ws-1: var(--ws-grad-1);
  --ws-2: var(--ws-grad-2);
}
```

Шрифт: **JetBrains Mono** (200/300/400/500/600/700/800). Никаких других — fallback запрещён.

**Typography scale v3** (UI Kit aligned, точные tracking/lh — см. `design-system-v3.html` секция 02):
- Display XL 152px / Bold / tracking 1% / lh 95%
- Display L 96px / Bold / tracking 1% / lh 100%
- Display M 64px / Medium / tracking 2% / lh 110%
- Heading Card 30px / Medium / tracking 6% / lh 115%
- Heading Section 22px / Medium / tracking 10% / lh 110%
- Body LG 22px / Regular / lh 155%
- Body 18px / Regular / lh 160%
- Label Up 13px / Medium / tracking 22% / lh 140%
- Caption 13px / Regular / tracking 5% / lh 140%

---

## 20 типов слайдов — CSS-рендер

### `section-title`
```html
<section class="slide slide-section-title">
  <div class="text animate">01 — Хай и лоу прошлого дня</div>
</section>
```
CSS: `font-size: 5.2vw; font-weight: 700; text-align: center; max-width: 78%;`

### `number`
```html
<section class="slide slide-number">
  <div class="num-big animate">2.55R</div>
  <div class="num-caption animate delay-1">Итог по NY-сессии · 5-мин FVG</div>
</section>
```
CSS num-big: `font-size: 16vw; font-weight: 800; color: var(--lime);`
CSS caption: `font-size: 1.5vw; color: var(--text-muted); uppercase; letter-spacing: 0.18em;`

### `stats-grid`
```html
<section class="slide slide-stats-grid">
  <div class="stats-row">
    <div class="stat animate"><div class="stat-value">15K+</div><div class="stat-label">Выпускников</div></div>
    <div class="stat animate delay-1"><div class="stat-value">7 лет</div><div class="stat-label">На рынке</div></div>
    <div class="stat animate delay-2"><div class="stat-value">98%</div><div class="stat-label">Доходимость</div></div>
  </div>
</section>
```
CSS: 3-up grid с разделителями между stat'ами.

### `quote`
```html
<section class="slide slide-quote">
  <div class="quote-text animate">Я отдаю часть прибыли обратно</div>
  <div class="quote-attr animate delay-1">— Solva</div>
</section>
```
Декорация: большая открывающая кавычка lime сверху-слева, opacity 0.35.

### `term-card`
```html
<section class="slide slide-term-card">
  <div class="term animate">FVG</div>
  <div class="expansion animate delay-1">Fair Value Gap — гэп справедливой цены</div>
  <div class="term-note animate delay-2">Зона неэффективности, к которой цена возвращается</div>
</section>
```

### `takeaway`
```html
<section class="slide slide-takeaway">
  <div class="takeaway-text animate">Один алгоритм работает на каждом таймфрейме</div>
</section>
```
CSS: `font-size: 4vw; font-weight: 600; text-align: center;`

### `example-slot` — placeholder под визуал
```html
<section class="slide slide-example-slot">
  <div class="placeholder animate">
    <div class="kind">[ EXAMPLE · chart ]</div>
    <div class="desc">TradingView replay daily chart 10-15 дней...</div>
    <div class="hint">закрытие выше PDH — lime; sweep+no-close — red</div>
  </div>
</section>
```
CSS: outlined dashed lime border, bg rgba(201,248,88,0.025).

### `comparison`
```html
<section class="slide slide-comparison">
  <div class="comp-grid">
    <div class="comp-col comp-col-old animate">
      <div class="comp-title">До FTT</div>
      <ul class="comp-list">
        <li>Хаотичные сделки</li>
        <li>Нет журнала</li>
        <li>Эмоции рулят</li>
      </ul>
    </div>
    <div class="comp-col comp-col-new animate delay-1">
      <div class="comp-title">После FTT</div>
      <ul class="comp-list">
        <li>Системные входы</li>
        <li>Журнал каждой сделки</li>
        <li>Эмоции под фильтром</li>
      </ul>
    </div>
  </div>
</section>
```
CSS old: opacity 0.5, border-style dashed.
CSS new: border lime, bg linear-gradient(rgba lime, transparent).

### `steps`
```html
<section class="slide slide-steps">
  <div class="steps-list">
    <div class="step animate"><div class="step-num">01</div><div class="step-body"><div class="step-title">Открой терминал</div><div class="step-desc">...</div></div></div>
    <div class="step animate delay-1">...</div>
    ...
  </div>
</section>
```
CSS: step-num — outlined thin font-weight 200, lime stroke.

### `screenshot-showcase`
```html
<section class="slide slide-screenshot-showcase">
  <div class="ss-title animate">Notion-шаблон</div>
  <div class="ss-placeholder animate delay-1">
    <div class="ss-kind">[ SCREENSHOT ]</div>
    <div class="ss-desc">Минималистичная Notion-страница на dark theme, 5 чекбоксов сверху вниз</div>
  </div>
  <div class="ss-caption animate delay-2">5 пунктов утренней рутины</div>
</section>
```
Отличие от example-slot: заголовок сверху + placeholder + caption снизу.

### `cta` — финальный pitch
```html
<section class="slide slide-cta">
  <div class="cta-headline animate">Перейти от хаотичной к системной торговле</div>
  <div class="cta-sub animate delay-1">Полная программа Workshop · 3-4 месяца</div>
  <div class="cta-buttons animate delay-2">
    <a class="cta-btn cta-btn-primary">Записаться на Workshop</a>
    <a class="cta-btn cta-btn-secondary">Узнать больше</a>
  </div>
</section>
```
CSS primary button: bg lime, color black, font-weight 700.
CSS secondary: outlined border var(--border).

### `centered-intro`
Параграф 2-4 строки, mix белого primary + серого secondary, ключевые слова lime. Используется сразу после `section-title` (block-reset pattern).
```html
<section class="slide slide-centered-intro">
  <div class="intro-body animate">
    <span class="intro-muted">Основная задача —</span>
    <span class="intro-primary">не просто выделить метрики,</span>
    <span class="intro-muted">а интерпретировать их.</span>
    <span class="intro-accent">Главный фокус — закономерности.</span>
  </div>
</section>
```
CSS: text-align center, max-width 70%, font-size 2.2vw, line-height 1.55. `.intro-muted` color var(--text-secondary). `.intro-primary` color var(--text-primary). `.intro-accent` color var(--lime).

### `icon-grid`
2-6 тайлов с глифом + label + опц. sublabel. Без номеров — равноправные категории.
```html
<section class="slide slide-icon-grid">
  <div class="ig-grid ig-grid-3">
    <div class="ig-tile animate"><div class="ig-glyph">↗</div><div class="ig-label">Net Profit</div><div class="ig-sub">Итоговый результат</div></div>
    <div class="ig-tile animate delay-1"><div class="ig-glyph">⊕</div><div class="ig-label">Win Rate</div><div class="ig-sub">Доля прибыльных</div></div>
    <div class="ig-tile animate delay-2"><div class="ig-glyph">RR</div><div class="ig-label">Avg RR</div><div class="ig-sub">Средний RR</div></div>
  </div>
</section>
```
CSS: `.ig-grid` display grid, `.ig-grid-2/3/4/6` определяет N колонок. `.ig-tile` bg var(--surface-1), border 1px var(--border-subtle), padding 2.5vw, без скруглений. `.ig-glyph` font-size 3vw, color var(--lime), font-weight 500. `.ig-label` font-size 1.6vw, font-weight 500, color var(--text-primary). `.ig-sub` font-size 1vw, color var(--text-secondary).

### `numbered-grid`
То же что `icon-grid`, но цифра 01/02/03 в углу тайла. Используется для последовательных шагов в сеточной разбивке.
```html
<section class="slide slide-numbered-grid">
  <div class="ng-grid ng-grid-3">
    <div class="ng-tile animate"><div class="ng-num">01</div><div class="ng-title">Метрики</div><div class="ng-desc">Какие показатели Win Rate относительно средних?</div></div>
    <div class="ng-tile animate delay-1"><div class="ng-num">02</div><div class="ng-title">Кривая</div><div class="ng-desc">С чем связаны просадки?</div></div>
    <div class="ng-tile animate delay-2"><div class="ng-num">03</div><div class="ng-title">Позиции</div><div class="ng-desc">Сильные / слабые стороны</div></div>
  </div>
</section>
```
CSS: `.ng-grid` grid с N колонок (`-2/-3/-4`). `.ng-tile` как ig-tile но с position relative. `.ng-num` outlined thin (font-weight 200), font-size 3vw, color var(--lime), text-stroke 1px lime, position absolute top-left, opacity 0.7. `.ng-title` font-size 1.8vw, font-weight 600. `.ng-desc` font-size 1.1vw, color var(--text-secondary).

### `pipeline-flow`
Горизонтальная цепочка узлов через стрелки. Финальный алгоритм блока "в одном кадре".
```html
<section class="slide slide-pipeline-flow">
  <div class="pf-chain animate">
    <div class="pf-node">Анализ</div>
    <div class="pf-arrow">→</div>
    <div class="pf-node">Выявление</div>
    <div class="pf-arrow">→</div>
    <div class="pf-node">План</div>
    <div class="pf-arrow">→</div>
    <div class="pf-node">Выполнение</div>
    <div class="pf-arrow">→</div>
    <div class="pf-node pf-node-accent">Повторение</div>
  </div>
  <div class="pf-caption animate delay-1">Алгоритм улучшения торговли</div>
</section>
```
CSS: `.pf-chain` display flex, align-items center, justify-content center, gap 1.2vw, flex-wrap wrap, max-width 88%. `.pf-node` padding 1vw 2vw, bg var(--surface-1), border 1px var(--border-subtle), font-size 1.4vw, color var(--text-primary). `.pf-node-accent` border-color var(--lime), color var(--lime). `.pf-arrow` font-size 1.8vw, color var(--lime). `.pf-caption` font-size 1.2vw, color var(--text-secondary), text-align center, margin-top 3vw, letter-spacing 0.18em, text-transform uppercase.

### `key-value-table`
Вертикальные пары label / value. Приземление концепта в конкретные цифры.
```html
<section class="slide slide-key-value-table">
  <div class="kv-table animate">
    <div class="kv-row"><div class="kv-key">Проблема</div><div class="kv-val">Высокий Max Drawdown</div></div>
    <div class="kv-row"><div class="kv-key">Данные</div><div class="kv-val">−7%</div></div>
    <div class="kv-row"><div class="kv-key">Причина</div><div class="kv-val">Завышение риска после убытка</div></div>
    <div class="kv-row"><div class="kv-key">Решение</div><div class="kv-val">Фиксированный риск / Drawdown Protocol</div></div>
    <div class="kv-row"><div class="kv-key">KPI</div><div class="kv-val kv-val-accent">20 позиций с фиксированным риском</div></div>
  </div>
</section>
```
CSS: `.kv-table` max-width 70%, margin 0 auto. `.kv-row` display grid, grid-template-columns 28% 1fr, gap 3vw, padding 1.2vw 0, border-bottom 1px var(--border-dim). `.kv-key` color var(--text-secondary), text-transform uppercase, font-size 1vw, letter-spacing 0.18em, font-weight 500. `.kv-val` color var(--text-primary), font-size 1.6vw. `.kv-val-accent` color var(--lime).

### `hierarchy-tree`
Родительский узел → 2-3 дочерних через dashed-коннекторы. Декомпозиция концепта.
```html
<section class="slide slide-hierarchy-tree">
  <div class="ht-parent animate">Асимметрия</div>
  <div class="ht-svg animate delay-1">
    <svg viewBox="0 0 800 100" preserveAspectRatio="xMidYMid meet">
      <path d="M 400 0 L 400 40 M 200 40 L 600 40 M 200 40 L 200 100 M 600 40 L 600 100"
            stroke="#A1A1A6" stroke-width="1.5" stroke-dasharray="8 6" fill="none"/>
    </svg>
  </div>
  <div class="ht-children animate delay-2">
    <div class="ht-child">Risk Reward</div>
    <div class="ht-child">Вероятность (WR)</div>
  </div>
  <div class="ht-caption animate delay-3">Двухкомпонентная структура</div>
</section>
```
CSS: `.ht-parent` font-size 4vw, font-weight 600, text-align center. `.ht-svg` width 70%, height 7vw, margin 0 auto. `.ht-children` display flex, justify-content space-around, max-width 75%, margin 0 auto. `.ht-child` font-size 2.4vw, color var(--text-primary). `.ht-caption` font-size 1.1vw, color var(--text-secondary), text-align center, margin-top 3vw, letter-spacing 0.18em, text-transform uppercase.

### `progress-bar`
Одна горизонтальная полоса с lime-заливкой + счётчик. Прогресс / визуальная метрика / sub-divider.
```html
<section class="slide slide-progress-bar">
  <div class="pb-wrap animate">
    <div class="pb-track">
      <div class="pb-fill" style="width: 75%"></div>
      <div class="pb-counter">7</div>
    </div>
  </div>
  <div class="pb-label animate delay-1">Рекомендации по калибровке торговли</div>
</section>
```
CSS: `.pb-wrap` max-width 70%, margin 0 auto. `.pb-track` position relative, height 2.5vw, bg var(--surface-1), border 1px var(--border-subtle), overflow hidden. `.pb-fill` height 100%, bg var(--lime), transition width 0.6s ease. `.pb-counter` position absolute, right 1vw, top 50%, transform translateY(-50%), color var(--lime), font-size 1.4vw, font-weight 600. `.pb-label` font-size 2vw, text-align center, color var(--text-primary), margin-top 3vw.

### `outcomes-row`
Ряд pill'ов со значениями + Total. Серия трейдов / последовательность исходов.
```html
<section class="slide slide-outcomes-row">
  <div class="or-pills animate">
    <div class="or-pill or-loss">−1000</div>
    <div class="or-pill or-loss">−1000</div>
    <div class="or-pill or-loss">−1000</div>
    <div class="or-pill or-win">+3500</div>
    <div class="or-pill or-loss">−1000</div>
    <div class="or-pill or-loss">−1000</div>
    <div class="or-pill or-win">+4000</div>
    <div class="or-pill or-loss">−1000</div>
    <div class="or-pill or-loss">−1000</div>
    <div class="or-pill or-win">+3300</div>
  </div>
  <div class="or-total animate delay-1">Total: <span class="or-total-val">+3800</span></div>
  <div class="or-caption animate delay-2">Серия из 10 трейдов с асимметричным RR</div>
</section>
```
CSS: `.or-pills` display flex, justify-content center, gap 0.8vw, flex-wrap wrap, max-width 90%, margin 0 auto. `.or-pill` padding 0.6vw 1.4vw, border 1px solid, font-size 1.3vw, font-weight 500, no border-radius. `.or-loss` color var(--sem-red), border-color var(--sem-red). `.or-win` color var(--sem-green), border-color var(--sem-green). `.or-total` text-align center, font-size 2.4vw, margin-top 3vw, color var(--text-primary). `.or-total-val` color var(--lime), font-weight 700. `.or-caption` text-align center, font-size 1.1vw, color var(--text-secondary), margin-top 1.5vw, letter-spacing 0.18em, text-transform uppercase.

### `punch-line`
Расширение takeaway: явный accent-word с lime/red glow. Якорь ключевой фразы блока.
```html
<section class="slide slide-punch-line">
  <div class="pl-text animate">
    Проблема не рынок,
    <span class="pl-accent pl-accent-lime">а ваше поведение</span>.
  </div>
</section>
```
CSS: `.pl-text` font-size 4.2vw, font-weight 600, text-align center, max-width 82%, line-height 1.25. `.pl-accent-lime` color var(--lime). `.pl-accent-red` color var(--sem-red). `.pl-accent-white` color var(--text-primary). БЕЗ text-shadow — lime/red на чёрном уже достаточный акцент, glow создаёт мутный halo и нарушает правило CK "один акцент на слайд".

JSON schema всех 9 новых типов: см. примеры выше — те же поля что в `<div>`-классах (intro-muted/primary/accent массив сегментов; ig-glyph/label/sub для тайлов; ng-num/title/desc; pf-node массив + опциональный accent index; kv-row пары; ht-parent + ht-child[]; pb fill_percent + counter + label; or-pill массив с outcome win/loss + value; pl-accent с color: lime/red/white).

---

## Интерактивность (только для HTML, отключается в PDF)

### scroll-snap

```css
html { scroll-behavior: smooth; scroll-snap-type: y mandatory; }
.slide { scroll-snap-align: start; }
```

### fadeUp animation + IntersectionObserver

```css
@keyframes fadeUp {
  from { opacity: 0; transform: translateY(20px); }
  to { opacity: 1; transform: translateY(0); }
}
.animate { opacity: 0; }
.animate.visible { animation: fadeUp 0.6s ease forwards; }
.delay-1 { animation-delay: 0.1s; }
.delay-2 { animation-delay: 0.2s; }
.delay-3 { animation-delay: 0.3s; }
.delay-4 { animation-delay: 0.4s; }
```

JS:
```js
const observer = new IntersectionObserver((entries) => {
  entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
}, { threshold: 0.1 });
document.querySelectorAll('.animate').forEach(el => observer.observe(el));
```

### Dot-navigation (справа)

```html
<nav class="nav-dots">
  <button class="nav-dot active" data-slide="1"></button>
  <button class="nav-dot" data-slide="2"></button>
  ...
</nav>
```

```css
.nav-dots {
  position: fixed; right: 24px; top: 50%;
  transform: translateY(-50%);
  display: flex; flex-direction: column; gap: 12px;
  z-index: 100;
}
.nav-dot {
  width: 8px; height: 8px; border-radius: 50%;
  background: var(--text-mute2); opacity: 0.35;
  cursor: pointer; transition: all 0.2s;
  border: none; padding: 0;
}
.nav-dot.active {
  opacity: 1; background: var(--lime);
  box-shadow: 0 0 12px rgba(201, 248, 88, 0.4);
  transform: scale(1.3);
}
```

JS: dot click → scrollIntoView slide, scroll update → активный dot.

### Keyboard navigation

```js
document.addEventListener('keydown', (e) => {
  const slides = document.querySelectorAll('.slide');
  const currentIdx = [...slides].findIndex(s =>
    s.getBoundingClientRect().top >= -window.innerHeight / 2 &&
    s.getBoundingClientRect().top < window.innerHeight / 2
  );
  if (e.key === 'ArrowDown' || e.key === 'ArrowRight' || e.key === 'PageDown') {
    slides[Math.min(currentIdx + 1, slides.length - 1)]?.scrollIntoView({behavior:'smooth'});
  } else if (e.key === 'ArrowUp' || e.key === 'ArrowLeft' || e.key === 'PageUp') {
    slides[Math.max(currentIdx - 1, 0)]?.scrollIntoView({behavior:'smooth'});
  } else if (e.key === 'Home') {
    slides[0]?.scrollIntoView({behavior:'smooth'});
  } else if (e.key === 'End') {
    slides[slides.length - 1]?.scrollIntoView({behavior:'smooth'});
  }
});
```

### Print mode (PDF)

```css
@media print {
  html { scroll-snap-type: none; }
  .nav-dots { display: none; }
  .animate { opacity: 1 !important; animation: none !important; transform: none !important; }
  body { background: #000; }
  .slide { width: 1920px; height: 1080px; aspect-ratio: auto; page-break-after: always; border: none; }
}
```

---

## Wordmark в углу

Каждый слайд содержит wordmark CK:
```html
<img class="wm" src="ck-wordmark.png" alt="CK">
```
CSS: `position: absolute; bottom: 36px; right: 48px; height: 22px; opacity: 0.35;`

Перед сборкой — скопировать `ck-wordmark-horizontal.png` из brand book в outbox-папку как `ck-wordmark.png` (относительный путь надёжнее абсолютного).

---

## Slide counter

Каждый слайд содержит `01 / 20` в углу:
```html
<div class="sn">01 / 20</div>
```
CSS: `position: absolute; top: 48px; left: 56px; font-size: 12px; color: var(--text-mute2); uppercase; letter-spacing: 0.2em;`

---

## Cue (для монтажника)

В углу каждого слайда — реплика-триггер из суфлёра:
```html
<div class="cue">cue: посмотрите на этот график</div>
```
CSS: `position: absolute; bottom: 36px; left: 56px; font-size: 10px; color: var(--text-mute2); opacity: 0.5; italic;`

В PDF cue остаётся видимой (это для монтажника).

---

## PDF-рендер

```bash
cd "{{outbox_path}}" && "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --no-pdf-header-footer \
  --virtual-time-budget=10000 \
  --window-size=1920,1080 \
  --print-to-pdf="presentation.pdf" \
  "file://$PWD/presentation.html"
```

`--virtual-time-budget=10000` критичен для загрузки Google Fonts. Для 9:16 — `--window-size=1080,1920`.

---

## Examples-brief.md

Для каждого `example-slot` в JSON — запись в `examples-brief.md`:

```markdown
# Examples brief — {{deck_title}}

Источник: {{video_title}}
Дата: {{ГГГГ-ММ-ДД}}
Презентация: presentation.html · presentation.pdf
Слотов: {{N}}

---

## Slide 02 (id 2) — chart

**Что показать:**
{{description}}

**Highlight:**
{{highlight_hint}}

**Cue (где в речи):**
"{{cue}}"

**Промпт для Open Design / Higgsfield:**
```
{{example_kind}} for trading education video, ICT Daily Bias context
description: {{description}}
highlight: {{highlight_hint}}
style: dark background #000, JetBrains Mono labels,
lime #C9F858 accent for key elements,
violet #A855F7 for order blocks, red #EF4444 for invalidations,
thin grid lines, minimal axis labels, candlestick rendering professional clean
```

---

## Slide 07 (id 7) — diagram
...
```

---

## Процесс работы

1. **Спроси путь к input** если не указан: файл `.md` от `/onscreen` или JSON.
2. **Распарси JSON** из markdown-блока ` ```json deck-output `. Если JSON-блока нет — попроси прогнать `/onscreen` v3.
3. **Валидируй:** каждый slide имеет `id`, `type`, `cue`; type из списка 11; для `example-slot` обязательны `example_kind` + `description`; для `comparison` — `left.items.length === 3` и `right.items.length === 3`; для `stats-grid` — `stats.length === 3`; для `steps` — `steps.length <= 4`.
4. **Проверь brand book v2** — файлы существуют. Если нет — упасть с ошибкой.
5. **Создай outbox folder** `Бизнес OS/outbox/deck-build/ГГГГ-ММ-ДД_название/`.
6. **Скопируй wordmark** `ck-wordmark-horizontal.png` → `outbox/.../ck-wordmark.png`.
7. **Сгенерируй HTML** — по шаблону выше, заполняя слайды по type.
8. **Сохрани `source.json`** — копия входного JSON.
9. **Сгенерируй `examples-brief.md`** — каждый `example-slot` → секция с промптом.
10. **Рендеринг PDF** через headless Chrome.
11. **Сгенерируй `README.md`** — кратко: что внутри, как открыть, сколько слайдов и слотов.
12. **Покажи результат** — путь, метрики, first 3 example-slot для proof-of-life.

## Anti-patterns

- **Подставлять плейсхолдер-картинку в example-slot** (Unsplash, generic stock) → нет, это outlined placeholder.
- **Менять цвета brand book** → нет, hex точные.
- **Inter / Roboto / Arial fallback** → нет, только JetBrains Mono.
- **Создавать новые типы слайдов** на лету → нет, типы из списка `/onscreen`.
- **Bullet-list внутри слайда** → если в `text` несколько идей через `\n`/`•`/`,` — упасть с warning'ом.
- **stats-grid не на 3 элемента** → fail.
- **steps на >4 шагов** → fail.
- **comparison где `left.items.length !== right.items.length`** → fail.

## Sister skills

- **Текст для презентации** → `/onscreen` (предыдущий шаг)
- **Generic HTML-презентация для зала** → `/frontend-slides`
- **Brand book нового бренда** → `/brand-book-rn`
- **Visualization example-slot'ов** → `/higgsfield-generate` или `/design`

## Output checklist (перед сдачей)

- [ ] HTML открывается, JetBrains Mono загрузился
- [ ] scroll-snap работает (слайды защёлкиваются)
- [ ] fadeUp animations срабатывают при скролле
- [ ] Dot-nav справа кликабелен, arrow keys работают
- [ ] PDF сгенерирован, не битый, без анимаций (статичный)
- [ ] Все example-slot отрисованы как outlined placeholder
- [ ] Wordmark CK в углу каждого слайда
- [ ] Product accent применён (FTT / Workshop / etc.)
- [ ] Cue видна в углу для монтажника
- [ ] examples-brief.md содержит все слоты с готовыми промптами
- [ ] README.md читается
- [ ] Файлы в `outbox/deck-build/ГГГГ-ММ-ДД_название/`
