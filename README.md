# Gexbot MT5 Integration

This repository contains a MetaTrader 5 Expert Advisor for Gexbot Classic and State data.

The Expert Advisor draws current profiles, prior values, Major levels, and a summary dashboard.

## Supported data

The integration supports these profiles:

| Profile | Expiries |
|---|---|
| Classic GEX volume | 0DTE, 1DTE, Full |
| Classic GEX Open Interest | 0DTE, 1DTE, Full |
| State GEX | 0DTE, 1DTE, Full |
| State Gamma | 0DTE, 1DTE |
| State Delta | 0DTE, 1DTE |
| State Vanna | 0DTE, 1DTE |
| State Charm | 0DTE, 1DTE |

DTE means Days to Expiration.

GEX means Gamma Exposure.

Each profile has independent settings for:

- visibility;
- expiry;
- left, right, or diverging alignment;
- horizontal origin;
- maximum width;
- thickness;
- vertical offset;
- positive and negative colors;
- linear or logarithmic scaling;
- positive and negative top-N strike filters; and
- per-strike prior dots when the API supplies prior values.

## Major levels

The integration supports these current Major levels:

- Classic Zero Gamma;
- Classic positive and negative volume Majors;
- Classic positive and negative Open Interest Majors;
- State GEX positive and negative Majors; and
- State Gamma long and short Majors.

Each Major has independent visibility, color, width, style, and label text.

An optional setting adds the nearest profile magnitude to each current Major label.

The label position can be left, right, or a percentage of the visible chart.

## Local Major history

The integration can collect these Classic Major values while it runs:

- positive volume Major;
- negative volume Major; and
- Zero Gamma.

It aggregates the values into one-minute buckets.

It can draw each series as a line or as scatter points.

It can save the collected values under `MQL5/Files/GexbotMT5`.

This local cache survives an Expert Advisor restart on the same MetaTrader installation.

The integration does not request server-side historical backfill.

## Futures conversion

The integration supports three conversion modes:

- `GB_CONVERSION_NONE` uses source prices.
- `GB_CONVERSION_MANUAL` applies configured multiplicative and additive values.
- `GB_CONVERSION_AUTO` requests coefficients from the Gexbot futures conversion endpoint.

The conversion formula is:

```text
chart_price = source_price * multiplier + additive
```

Automatic conversion refreshes every 15 minutes.

The integration does not draw unconverted source prices when an automatic conversion is required but unavailable.

## Request behavior

The integration uses the public Gexbot version 2 REST API.

The base URL is:

```text
https://api.gex.bot/v2
```

The Expert Advisor performs an initial request for each required source by default.

Recurring requests use a non-overlapping round-robin scheduler.

The scheduler uses the requested interval as the minimum time between attempts for each source.

Recurring requests can be limited to the configured New York market session.

The default session is 9:30 AM through 4:00 PM New York time on weekdays.

The integration calculates United States daylight-saving transitions.

A failed request does not delete the last valid snapshot.

The dashboard and status label report request and conversion errors.

## Requirements

You need:

- MetaTrader 5;
- a Gexbot API key with access to the selected packages; and
- network access to `https://api.gex.bot`.

Create a Custom API key on the Gexbot Connections page.

Keep the full key prefix in the configured value.

## Allow WebRequest access

MetaTrader blocks external HTTP requests until you allow the host.

1. Open **Tools > Options**.
2. Select **Expert Advisors**.
3. Enable **Allow WebRequest for listed URL**.
4. Add this URL:

   ```text
   https://api.gex.bot
   ```

5. Select **OK**.

## Installation

Use `GEXBOT - MT5.mq5` for a new installation.

1. Open **File > Open Data Folder** in MetaTrader 5.
2. Open `MQL5/Experts`.
3. Copy these files into the same directory:
   - `GEXBOT - MT5.mq5`
   - `GexbotMT5Core.mqh`
4. Open `GEXBOT - MT5.mq5` in MetaEditor.
5. Compile the file with `F7`.
6. Attach the compiled Expert Advisor to a chart.

The repository does not contain compiled `.ex5` files.

Compile the source with the MetaEditor version that belongs to your MetaTrader installation.

## Compatibility entry points

The repository also contains these source files:

- `GEXBOT - MT5 - State.mq5`
- `GEXBOT - MT5 - Classic.mq5`

Both files use `GexbotMT5Core.mqh`.

The State entry point uses the same defaults as the canonical entry point.

The Classic entry point disables State profiles and State Majors by default.

Use the canonical entry point for new chart templates.

## Upgrade from version 3

Version 4 replaces the former input layout.

MetaTrader can keep old input values by numeric position.

Do not reuse a version 3 `.set` file with version 4.

Remove the old Expert Advisor instance.

Attach version 4 and configure its inputs again.

## API key configuration

You can configure the key in one of two ways.

### Direct input

Set `InpApiKey` in the Expert Advisor inputs.

MetaTrader can store an input value in chart templates and profiles.

Do not share a template that contains a key.

### Optional key file

Set `InpApiKeyFile` to a file path under `MQL5/Files`.

Put only the API key on the first line.

Leave `InpApiKey` empty when you use the file.

The Expert Advisor raises an initialization error when the configured file is missing or empty.

## Dashboard

The dashboard shows:

- request status;
- futures conversion status;
- Classic Zero Gamma;
- Classic volume and Open Interest Majors;
- Classic net GEX values;
- State GEX Majors and net GEX;
- State Gamma long and short Majors; and
- Classic maximum-change values for 1, 5, 10, 15, and 30 minutes.

Use the chart button to show or hide the dashboard.

A small status label remains visible when the dashboard is hidden.

## Source layout

| File | Purpose |
|---|---|
| `GEXBOT - MT5.mq5` | Canonical Expert Advisor entry point |
| `GEXBOT - MT5 - State.mq5` | State compatibility entry point |
| `GEXBOT - MT5 - Classic.mq5` | Classic-default compatibility entry point |
| `GexbotMT5Core.mqh` | Shared API, parsing, scheduling, drawing, history, and dashboard implementation |
| `tests/GexbotMT5ParserTests.mq5` | MetaEditor parser test script |
| `CHANGELOG.md` | Release changes |

## Validation

The source uses a bounded JSON reader for the required API response fields.

The reader validates object members, arrays, rows, and numeric values before it replaces a snapshot.

Compile-time validation requires MetaEditor.

### Run parser tests

Compile `tests/GexbotMT5ParserTests.mq5` as a MetaTrader script.

Run the compiled script in MetaTrader.

Review the **Experts** log for `PASS`, `FAIL`, and the final test result.

The tests cover:

- Classic and State GEX response parsing;
- State Greek response parsing;
- prior arrays;
- Major fields;
- maximum-change fields;
- nested object scanning; and
- preservation of the prior snapshot after malformed data.

## License

This project uses the MIT License.

The original integration copyright remains with `romerfrancogpt`.

See `LICENSE`.
