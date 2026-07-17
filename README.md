# Kronosobuchalka

Утилита для подготовки часовых свечей `TONUSDT` / `ZECUSDT` и разметки их прогнозами Kronos.

## Быстрый старт на новом компьютере

```powershell
git clone https://github.com/epitaph76/Kronosobuchalka.git
cd Kronosobuchalka
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
.\.venv\Scripts\Activate.ps1
```

Если работаешь в Linux/macOS:

```bash
git clone https://github.com/epitaph76/Kronosobuchalka.git
cd Kronosobuchalka
bash scripts/install.sh
source .venv/bin/activate
```

## Что нужно положить рядом

Kronos-веса большие, поэтому они не хранятся в этом репозитории. Скопируй или скачай их в такую структуру:

```text
Kronosobuchalka/
  kronos/
    model/
      __init__.py
      kronos.py
      module.py
    weights/
      NeoQuasar__Kronos-base/
        model.safetensors
        config.json
      NeoQuasar__Kronos-Tokenizer-base/
        model.safetensors
        config.json
```

Можно также не копировать внутрь репозитория, а указать пути явно через:

```powershell
--kronos-code-dir C:\path\to\kronos\model
--kronos-weights-dir C:\path\to\kronos\weights
```

## Скачать часовые свечи

Основной источник: публичный архив Binance Vision. Он удобнее, чем `api.binance.com`, потому что API может отдавать `451 restricted location`.

Пример: скачать с 1 февраля 2026 до 16 июля 2026 включительно. На 17 июля это последний полностью опубликованный день в архиве:

```powershell
kronosobuchalka download `
  --symbols TONUSDT,ZECUSDT `
  --from 2026-02-01 `
  --till 2026-07-16 `
  --interval 1h `
  --out-dir data/candles
```

Файлы появятся так:

```text
data/candles/candles_TONUSDT.csv
data/candles/candles_ZECUSDT.csv
```

Формат CSV:

```text
timestamps,end,open,high,low,close,volume,amount
```

Время в `timestamps` сдвинуто на `UTC+3`, чтобы совпадать с московским временем.

## Проверить покрытие локальных свечей

```powershell
kronosobuchalka coverage `
  --symbols TONUSDT,ZECUSDT `
  --from 2026-02-01 `
  --till 2026-07-16 `
  --candles-dir data/candles `
  --output reports/coverage.csv
```

## Проверить наличие свечей в архиве

Месячные архивы:

```powershell
kronosobuchalka check-remote `
  --symbols TONUSDT,ZECUSDT `
  --from 2026-02-01 `
  --till 2026-07-16 `
  --interval 1h
```

Месячные + дневные архивы:

```powershell
kronosobuchalka check-remote `
  --symbols TONUSDT,ZECUSDT `
  --from 2026-02-01 `
  --till 2026-07-16 `
  --interval 1h `
  --daily `
  --output reports/binance_vision_availability.csv
```

На проверке из текущей среды 17 июля 2026:

- `TONUSDT`: месячные архивы есть за `2026-02` - `2026-06`; июльский месячный архив ещё не опубликован. Daily-архивы для июля на Binance Vision не нашлись. Локальное покрытие после скачивания: `2026-02-01 00:00` - `2026-06-30 05:00`, 3582 часов из 3984.
- `ZECUSDT`: месячные архивы есть за `2026-02` - `2026-06`; daily-архивы есть за `2026-07-01` - `2026-07-16`. Локальное покрытие после скачивания: `2026-02-01 00:00` - `2026-07-16 23:00`, 3984 часов из 3984.
- `api.binance.com` из текущей среды вернул `451 restricted location`, поэтому downloader по умолчанию использует архив.

## Разметить свечи Kronos

Разметка берёт `context_rows` предыдущих свечей и прогнозирует следующую часовую свечу.

```powershell
kronosobuchalka label `
  --symbols TONUSDT,ZECUSDT `
  --candles-dir data/candles `
  --output-dir labels/feb_jul_2026 `
  --kronos-code-dir kronos/model `
  --kronos-weights-dir kronos/weights `
  --model base `
  --context-rows 512 `
  --pred-len 1 `
  --sample-count 10 `
  --device auto `
  --overwrite
```

Выход:

```text
labels/feb_jul_2026/labels_TONUSDT.csv
labels/feb_jul_2026/labels_ZECUSDT.csv
labels/feb_jul_2026/labels_all.csv
labels/feb_jul_2026/summary.json
```

Основные поля разметки:

- `as_of` — последняя известная свеча перед прогнозом;
- `target_timestamp` — свеча, которую прогнозировали;
- `actual_open/high/low/close` — реальная целевая свеча;
- `pred_open/high/low/close` — прогноз Kronos;
- `raw_pred_move_pct = pred_close / actual_open - 1`;
- `pred_side` — `long` или `short`;
- `actual_body_return_pct = actual_close / actual_open - 1`;
- `direction_hit` — угадано ли направление тела свечи.

## Ручной сценарий

Если ты уже скачал свечи другим способом, просто положи файлы сюда:

```text
data/candles/candles_TONUSDT.csv
data/candles/candles_ZECUSDT.csv
```

Потом:

```powershell
kronosobuchalka coverage --symbols TONUSDT,ZECUSDT --from 2026-02-01 --till 2026-07-16 --candles-dir data/candles
kronosobuchalka label --symbols TONUSDT,ZECUSDT --candles-dir data/candles --output-dir labels/my_run --overwrite
```
