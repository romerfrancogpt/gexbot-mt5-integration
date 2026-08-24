# GexBOT MT5 Integration

An open-source Expert Advisor (EA) for MetaTrader 5 that fetches real-time Gamma Exposure (GEX) profiles and key levels from the **Gexbot API (Classic Version)** and plots them directly on your MT5 charts.

> **Note:**  
> * **Gexbot Model:** This integration is specifically designed for **Gexbot Classic** data.  
> * **Language:** Source code comments and on-screen user interface elements (such as dashboard labels and button text) are in **Spanish**.

---

## Prerequisites

Before running the EA in MT5, you **must allow WebRequests** for the Gexbot API endpoint:

1. Open MetaTrader 5 and go to **Tools > Options** (or press `Ctrl + O`).
2. Select the **Expert Advisors** tab.
3. Check the box **"Allow WebRequest for listed URL"**.
4. Double-click **`<add new URL...>`** and enter:  
   `https://api.gexbot.com`
5. Click **OK**.

---

## Installation

1. Open MetaTrader 5 and go to **File > Open Data Folder**.
2. Navigate to `MQL5/Experts`.
3. Copy the `GexBOT-MT5.mq5` file into this folder.
4. Restart MT5 or refresh the **Navigator** panel (`Ctrl + N`).
5. Open MetaEditor (`F4`), open `GexBOT-MT5.mq5`, and click **Compile** (`F7`).
6. Drag the expert onto any chart.

---

## Configuration & Input Parameters

### 1. General & API Settings
* **`InpApiKey`** *(string)*: Your Gexbot API Bearer Token.
* **`InpTicker`** *(string)*: The underlying ticker symbol to request (e.g., `SPX`, `NDX`, `QQQ`).
* **`InpDte`** *(enum)*: Expiration aggregation mode:
  * `DTE_zero`: Zero Days To Expiration (0DTE).
  * `DTE_one`: 1DTE.
  * `DTE_full`: Full chain / All expirations.
* **`InpRefreshSeconds`** *(int)*: Time interval (in seconds) to query the Gexbot API for fresh data (default: `10`).

### 2. Visualization & Layout
* **`InpDashPos`** *(enum)*: On-screen position for the data dashboard summary:
  * `POS_TOP_LEFT`, `POS_TOP_RIGHT`, `POS_BOTTOM_LEFT`, `POS_BOTTOM_RIGHT`, `POS_TOP_CENTER`, `POS_BOTTOM_CENTER`.
* **`InpDrawBehind`** *(bool)*: If `true`, renders histogram bars, levels, and background elements behind price candles.
* **`InpTransparentBg`** *(bool)*: If `true`, removes the dashboard background panel for a transparent text overlay.
* **`InpMaxBarWidth`** *(int)*: Maximum width of the histogram bars in pixels (default: `400`).
* **`InpBarThickness`** *(int)*: Height / thickness of each strike histogram bar in pixels (default: `4`).
* **`InpStrikeMultiply`** *(double)*: Multiplier for strike values (default: `1.0`). Useful for assets or CFDs scaled differently relative to the spot index price (e.g., `0.1` or `10.0`).

### 3. Colors & Key Levels Styling
* **`InpDexColorPos` / `InpDexColorNeg`**: Colors for Positive and Negative **GEX Open Interest (OI)** histogram bars drawn on the left side of the chart.
* **`InpGexColorPos` / `InpGexColorNeg`**: Colors for Positive and Negative **GEX Volume** histogram bars drawn on the right side of the chart.
* **`InpGexCallWallClr`**: Color for the Volume Call Wall line.
* **`InpGexPutWallClr`**: Color for the Volume Put Wall line.
* **`InpDexCallWallClr`**: Color for the Open Interest Call Wall line.
* **`InpDexPutWallClr`**: Color for the Open Interest Put Wall line.
* **`InpFlipPointClr`**: Color for the Flip Point / Zero Gamma boundary line.

---

## Features

* **Gexbot Classic Integration**: Designed specifically to interface with Gexbot Classic API endpoints.
* **Dual Histograms**:
  * Left side: GEX distribution weighted by **Open Interest (OI)**.
  * Right side: GEX distribution weighted by **Volume**.
* **Key Level Plotting**: Automatically draws horizontal dashed lines and price tags for Call Walls, Put Walls, and the Flip Point directly on the chart.
* **Interactive Dashboard**: Displays Zero Gamma, Major Positive/Negative levels, Net GEX, and 1-30 min Max Prior Changes with a toggle button (`Mostrar / Ocultar`) to clean up screen space.
* **Auto-Scaling**: Adjusts horizontal bar sizes relative to current maximum exposure.

---

## License

Distributed under the **MIT License**. See `LICENSE` for more information.