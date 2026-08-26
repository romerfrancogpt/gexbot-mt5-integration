# Changelog

## 4.0.0

- Consolidated the Classic and State entry points into `GexbotMT5Core.mqh`.
- Added the canonical `GEXBOT - MT5.mq5` entry point.
- Migrated profile requests to the public Gexbot version 2 API.
- Added independent Classic volume and Open Interest expiries.
- Added State GEX Full, 0DTE, and 1DTE profiles.
- Added concurrent State Gamma, Delta, Vanna, and Charm profiles.
- Added independent placement, style, scale, filter, color, and prior settings.
- Added State GEX and State Gamma Major lines.
- Added individual Major visibility, style, width, color, and label settings.
- Added optional nearest-profile magnitudes to current Major labels.
- Added locally collected one-minute Classic Major history.
- Added optional local Major history persistence.
- Added manual affine futures conversion.
- Added automatic Gexbot futures conversion with a 15-minute refresh.
- Added New York market-session scheduling with daylight-saving support.
- Added a non-overlapping source scheduler.
- Added bounded and validated JSON response parsing.
- Preserved the last valid snapshot after request and parse failures.
- Added request, freshness, conversion, and State data to the dashboard.
- Added an optional API key file.
- Added MetaEditor parser tests.
- Removed stale compiled `.ex5` files.
