//+------------------------------------------------------------------+
//|                                           GexBOT-MT5.mq5         |
//|                 EA para leer niveles desde API de Gexbot         |
//+------------------------------------------------------------------+
#property copyright "Romer Franco"
#property link      "Public"
#property version   "2.14"

enum ENUM_DTE {
   DTE_zero, // zero
   DTE_one,  // one
   DTE_full  // full
};

enum ENUM_DASH_POS {
   POS_TOP_LEFT,       // Arriba Izquierda
   POS_TOP_RIGHT,      // Arriba Derecha
   POS_BOTTOM_LEFT,    // Abajo Izquierda
   POS_BOTTOM_RIGHT,   // Abajo Derecha
   POS_TOP_CENTER,     // Arriba Centro
   POS_BOTTOM_CENTER   // Abajo Centro
};

//--- Inputs del Usuario
input string        InpApiKey          = "TU_API_KEY_AQUI";               // API Key (Bearer Token)
input string        InpTicker          = "SPX";                           // Ticker (ej: SPX)
input ENUM_DTE      InpDte             = DTE_zero;                        // DTE Aggregation
input int           InpRefreshSeconds  = 10;                              // Actualizar cada X segundos

//--- Inputs de Visualización
input ENUM_DASH_POS InpDashPos         = POS_TOP_LEFT;                    // Posición del Dashboard
input bool          InpDrawBehind      = true;                            // Dibujar DETRÁS de las velas (Fondo)
input bool          InpTransparentBg   = false;                           // Panel 100% Invisible (Solo texto)
input int           InpMaxBarWidth     = 400;                             // Ancho máximo del histograma (Pixeles)
input int           InpBarThickness    = 4;                               // Grosor de cada barra (Pixeles)
input double        InpStrikeMultiply  = 1.0;                             // Multiplicador de strikes

//--- Colores y Estilos
input color         InpDexColorPos     = clrGreen;                        // Color GEX OI Positivo (Izquierda)
input color         InpDexColorNeg     = clrRed;                          // Color GEX OI Negativo (Izquierda)
input color         InpGexColorPos     = clrGreen;                        // Color GEX VOL Positivo (Derecha)
input color         InpGexColorNeg     = clrRed;                          // Color GEX VOL Negativo (Derecha)

input color         InpGexCallWallClr  = clrLimeGreen;                    // Color linea Vol Call Wall
input color         InpGexPutWallClr   = clrRed;                          // Color linea Vol Put Wall
input color         InpDexCallWallClr  = clrGreen;                        // Color linea OI Call Wall
input color         InpDexPutWallClr   = clrRed;                          // Color linea OI Put Wall
input color         InpFlipPointClr    = clrGold;                         // Color linea Flip Point

//--- Estructuras
struct ExposureData { double strike; double net_exposure; };
struct LevelInfo { double price; color clr; string label; };

ExposureData GexArray[]; 
ExposureData DexArray[]; 

double MaxGexExposure = 0, MaxDexExposure = 0;
double GexCallWall = 0, GexPutWall = 0, DexCallWall = 0, DexPutWall = 0;

//--- Variables del Dashboard
double ZeroGamma = 0;
double NetGexVol = 0;
double NetGexOI = 0;
double MaxPriorsStrike[5];
double MaxPriorsGex[5];
bool ShowDashboard = true; // Estado del panel (Abierto/Cerrado)

//+------------------------------------------------------------------+
int OnInit() { EventSetTimer(InpRefreshSeconds); FetchAPIData(); return(INIT_SUCCEEDED); }
void OnDeinit(const int reason) { EventKillTimer(); ObjectsDeleteAll(0, "GEX_"); ObjectsDeleteAll(0, "DEX_"); ObjectsDeleteAll(0, "LVL_"); ObjectsDeleteAll(0, "DASH_"); ObjectsDeleteAll(0, "LBL_"); ObjectDelete(0, "BTN_DASH_TOGGLE"); ChartRedraw(); }
void OnTick() { }
void OnTimer() { FetchAPIData(); }
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) 
  { 
   if(id == CHARTEVENT_CHART_CHANGE) 
     { 
      DrawHistogram(); 
      DrawKeyLevels(); 
      DrawDashboard(); 
     } 
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == "BTN_DASH_TOGGLE")
     {
      ShowDashboard = !ShowDashboard;
      ObjectSetInteger(0, "BTN_DASH_TOGGLE", OBJPROP_STATE, false); 
      DrawDashboard();
      ChartRedraw();
     }
  }

//+------------------------------------------------------------------+
void FetchAPIData()
  {
   string strDte = (InpDte == DTE_zero) ? "zero" : (InpDte == DTE_one ? "one" : "full");
   string url = "https://api.gexbot.com/" + InpTicker + "/classic/" + strDte + "?ts=" + IntegerToString(GetTickCount64());
   string headers = "Authorization: Bearer " + InpApiKey + "\r\nUser-Agent: MT5_Client/1.0\r\nAccept: application/json\r\nCache-Control: no-cache\r\n";
   char post[], result[]; string result_headers;
   int res = WebRequest("GET", url, headers, 5000, post, result, result_headers);
   if(res == 200) { string json = CharArrayToString(result); if(ParseAPIResponse(json)) { DrawHistogram(); DrawKeyLevels(); DrawDashboard(); } }
  }

double ExtractRawValue(string &json, string key)
  {
   int k = StringFind(json, key);
   if(k < 0) return 0;
   int start = k + StringLen(key);
   int comma = StringFind(json, ",", start);
   int brace = StringFind(json, "}", start);
   int end = (comma != -1 && (brace == -1 || comma < brace)) ? comma : brace;
   if(end == -1) return 0;
   string val = StringSubstr(json, start, end - start);
   StringReplace(val, " ", "");
   return StringToDouble(val);
  }

//+------------------------------------------------------------------+
bool ParseAPIResponse(string json)
  {
   ObjectsDeleteAll(0, "GEX_"); 
   ObjectsDeleteAll(0, "DEX_");
   
   ArrayResize(GexArray, 0); ArrayResize(DexArray, 0); MaxGexExposure = 0; MaxDexExposure = 0;

   GexCallWall = ExtractRawValue(json, "\"major_pos_vol\":") * InpStrikeMultiply;
   GexPutWall  = ExtractRawValue(json, "\"major_neg_vol\":") * InpStrikeMultiply;
   DexCallWall = ExtractRawValue(json, "\"major_pos_oi\":")  * InpStrikeMultiply;
   DexPutWall  = ExtractRawValue(json, "\"major_neg_oi\":")  * InpStrikeMultiply;

   ZeroGamma = ExtractRawValue(json, "\"zero_gamma\":") * InpStrikeMultiply;
   NetGexVol = ExtractRawValue(json, "\"sum_gex_vol\":");
   NetGexOI  = ExtractRawValue(json, "\"sum_gex_oi\":");

   ArrayInitialize(MaxPriorsStrike, 0);
   ArrayInitialize(MaxPriorsGex, 0);
   
   int mp_pos = StringFind(json, "\"max_priors\":[[");
   if(mp_pos >= 0)
     {
      int p_start = mp_pos + 14;
      for(int i = 0; i < 5; i++)
        {
         int start = StringFind(json, "[", p_start);
         if(start < 0) break;
         int end = StringFind(json, "]", start);
         string el = StringSubstr(json, start + 1, end - start - 1);
         string vals[]; StringSplit(el, ',', vals);
         if(ArraySize(vals) >= 2)
           {
            MaxPriorsStrike[i] = StringToDouble(vals[0]) * InpStrikeMultiply;
            MaxPriorsGex[i] = StringToDouble(vals[1]);
           }
         p_start = end + 1;
        }
     }

   int s_pos = StringFind(json, "\"strikes\":[[");
   if(s_pos < 0) return false;
   int pos = s_pos + 11;

   while(pos < StringLen(json))
     {
      int start = StringFind(json, "[", pos);
      if(start < 0) break;
      int end = StringFind(json, "]", start);
      string el = StringSubstr(json, start + 1, end - start - 1);
      string vals[]; StringSplit(el, ',', vals);
      if(ArraySize(vals) >= 3)
        {
         double strk = StringToDouble(vals[0]) * InpStrikeMultiply;
         double vol = StringToDouble(vals[1]);
         double oi = StringToDouble(vals[2]);
         int g = ArraySize(GexArray); ArrayResize(GexArray, g+1); GexArray[g].strike = strk; GexArray[g].net_exposure = vol;
         int d = ArraySize(DexArray); ArrayResize(DexArray, d+1); DexArray[d].strike = strk; DexArray[d].net_exposure = oi;
         if(MathAbs(vol) > MaxGexExposure) MaxGexExposure = MathAbs(vol);
         if(MathAbs(oi) > MaxDexExposure) MaxDexExposure = MathAbs(oi);
        }
      pos = end + 1;
     }
   return true;
  }

void CreateOrUpdateBar(string name, int x, int y, int width, int height, color clr)
  {
   if(ObjectFind(0, name) < 0) { ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0); ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER); }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x); ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width); ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BACK, InpDrawBehind); // Ajuste de profundidad
  }

void AddLevelToArray(LevelInfo &arr[], double price, color clr, string label)
  {
   if(price <= 0) return;
   int sz = ArraySize(arr);
   ArrayResize(arr, sz + 1);
   arr[sz].price = price;
   arr[sz].clr = clr;
   arr[sz].label = label;
  }

void DrawKeyLevels()
  {
   LevelInfo levels[];
   double flip = (GexPutWall > 0 && DexPutWall > 0) ? (GexPutWall + DexPutWall) / 2.0 : (GexPutWall > 0 ? GexPutWall : DexPutWall);

   AddLevelToArray(levels, GexCallWall, InpGexCallWallClr, "Vol Call Wall");
   AddLevelToArray(levels, GexPutWall, InpGexPutWallClr, "Vol Put Wall");
   AddLevelToArray(levels, DexCallWall, InpDexCallWallClr, "OI Call Wall");
   AddLevelToArray(levels, DexPutWall, InpDexPutWallClr, "OI Put Wall");
   AddLevelToArray(levels, flip, InpFlipPointClr, "Flip Point");

   int firstVisible = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
   int offset = (int)ChartGetInteger(0, CHART_VISIBLE_BARS) / 10;
   int targetBar = MathMax(0, firstVisible - offset);
   datetime textTime = iTime(_Symbol, _Period, targetBar);
   if(textTime == 0) textTime = TimeCurrent();

   int drawIndex = 0;
   for(int i = 0; i < ArraySize(levels); i++)
     {
      if(levels[i].price <= 0) continue;

      double curPrice = levels[i].price;
      string combinedText = levels[i].label;
      color mainColor = levels[i].clr;

      for(int j = i + 1; j < ArraySize(levels); j++)
        {
         if(levels[j].price > 0 && MathAbs(levels[j].price - curPrice) < (_Point * 10))
           {
            combinedText += "  |  " + levels[j].label;
            levels[j].price = -1;
           }
        }

      string lineName = "LVL_LINE_" + IntegerToString(drawIndex);
      string textName = "LVL_TXT_" + IntegerToString(drawIndex);

      if(ObjectFind(0, lineName) < 0) ObjectCreate(0, lineName, OBJ_HLINE, 0, 0, curPrice);
      ObjectSetDouble(0, lineName, OBJPROP_PRICE, curPrice);
      ObjectSetInteger(0, lineName, OBJPROP_COLOR, mainColor);
      ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_DASH);
      ObjectSetInteger(0, lineName, OBJPROP_BACK, InpDrawBehind); // Ajuste de profundidad

      if(ObjectFind(0, textName) < 0) ObjectCreate(0, textName, OBJ_TEXT, 0, textTime, curPrice);
      ObjectSetDouble(0, textName, OBJPROP_PRICE, curPrice);
      ObjectSetInteger(0, textName, OBJPROP_TIME, textTime);
      ObjectSetString(0, textName, OBJPROP_TEXT, "  " + combinedText + " (" + DoubleToString(curPrice, _Digits) + ")");
      ObjectSetInteger(0, textName, OBJPROP_COLOR, mainColor);
      ObjectSetInteger(0, textName, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, textName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, textName, OBJPROP_BACK, InpDrawBehind); // Ajuste de profundidad
      
      drawIndex++;
     }
     
   while(ObjectFind(0, "LVL_LINE_" + IntegerToString(drawIndex)) >= 0)
     {
      ObjectDelete(0, "LVL_LINE_" + IntegerToString(drawIndex));
      ObjectDelete(0, "LVL_TXT_" + IntegerToString(drawIndex));
      drawIndex++;
     }
  }

// --- Funciones UI del Dashboard ---
void CreateDashboardPanel(string name, int x, int y, int w, int h)
  {
   if(ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   
   if(InpTransparentBg)
     {
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrNONE); 
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrNONE); 
     }
   else
     {
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrBlack); 
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrDimGray); 
     }
     
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_BACK, InpDrawBehind);
  }

void CreateDashboardLine(string name, int x, int y, int w)
  {
   if(ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, 1);
   
   if(InpTransparentBg)
     {
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrNONE); 
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrNONE); 
     }
   else
     {
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrDimGray);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrDimGray);
     }
     
   ObjectSetInteger(0, name, OBJPROP_BACK, InpDrawBehind);
  }

void CreateDashboardLabel(string name, string text, int x, int y, color clr, int fontSize = 9, bool bold = false, ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER)
  {
   if(ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, bold ? "Trebuchet MS Bold" : "Trebuchet MS");
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, name, OBJPROP_BACK, InpDrawBehind); // Ajuste de profundidad
  }

void DrawDashboard()
  {
   ObjectsDeleteAll(0, "DASH_");
   
   long chartW = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   long chartH = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   int panelW = 260; 
   int panelH = 370; 
   int startX = 20;
   int startY = 40;
   
   // Calcular Posición según el Input
   switch(InpDashPos)
     {
      case POS_TOP_LEFT:       startX = 20; startY = 40; break;
      case POS_TOP_RIGHT:      startX = (int)chartW - panelW - 20; startY = 40; break;
      case POS_BOTTOM_LEFT:    startX = 20; startY = (int)chartH - panelH - 50; break;
      case POS_BOTTOM_RIGHT:   startX = (int)chartW - panelW - 20; startY = (int)chartH - panelH - 50; break;
      case POS_TOP_CENTER:     startX = (int)(chartW - panelW) / 2; startY = 40; break;
      case POS_BOTTOM_CENTER:  startX = (int)(chartW - panelW) / 2; startY = (int)chartH - panelH - 50; break;
     }

   // --- Crear Botón Toggle (Mostrar/Ocultar) ---
   if(ObjectFind(0, "BTN_DASH_TOGGLE") < 0) ObjectCreate(0, "BTN_DASH_TOGGLE", OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, "BTN_DASH_TOGGLE", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "BTN_DASH_TOGGLE", OBJPROP_XDISTANCE, startX + 10);
   ObjectSetInteger(0, "BTN_DASH_TOGGLE", OBJPROP_YDISTANCE, startY - 10);
   ObjectSetInteger(0, "BTN_DASH_TOGGLE", OBJPROP_XSIZE, ShowDashboard ? 60 : 100);
   ObjectSetInteger(0, "BTN_DASH_TOGGLE", OBJPROP_YSIZE, 18);
   ObjectSetString(0, "BTN_DASH_TOGGLE", OBJPROP_TEXT, ShowDashboard ? "Ocultar" : "+ Mostrar Panel");
   ObjectSetInteger(0, "BTN_DASH_TOGGLE", OBJPROP_BGCOLOR, clrBlack);
   ObjectSetInteger(0, "BTN_DASH_TOGGLE", OBJPROP_COLOR, clrSilver);
   ObjectSetInteger(0, "BTN_DASH_TOGGLE", OBJPROP_BORDER_COLOR, clrDimGray);
   ObjectSetString(0, "BTN_DASH_TOGGLE", OBJPROP_FONT, "Trebuchet MS");
   ObjectSetInteger(0, "BTN_DASH_TOGGLE", OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, "BTN_DASH_TOGGLE", OBJPROP_BACK, false); // El botón siempre al frente

   if(!ShowDashboard) return;

   CreateDashboardPanel("DASH_BG", startX, startY, panelW, panelH);
   
   int y = startY + 15;
   int col1 = startX + 15;            
   int col2 = startX + panelW - 15;   
   
   // --- Volume Section ---
   CreateDashboardLabel("DASH_V_TITLE", "volume", col1, y, clrWhite, 10, true);
   y += 18;
   CreateDashboardLine("DASH_LINE_1", col1, y, panelW - 30);
   y += 10;
   CreateDashboardLabel("DASH_V_ZG_L", "zero gamma", col1, y, clrOrange);
   CreateDashboardLabel("DASH_V_ZG_V", DoubleToString(ZeroGamma, 2), col2, y, clrWhite, 9, false, ANCHOR_RIGHT_UPPER);
   y += 18;
   CreateDashboardLabel("DASH_V_MP_L", "major positive", col1, y, clrLimeGreen);
   CreateDashboardLabel("DASH_V_MP_V", DoubleToString(GexCallWall, 2), col2, y, clrWhite, 9, false, ANCHOR_RIGHT_UPPER);
   y += 18;
   CreateDashboardLabel("DASH_V_MN_L", "major negative", col1, y, clrRed);
   CreateDashboardLabel("DASH_V_MN_V", DoubleToString(GexPutWall, 2), col2, y, clrWhite, 9, false, ANCHOR_RIGHT_UPPER);
   y += 18;
   CreateDashboardLabel("DASH_V_NG_L", "net gex", col1, y, clrWhite);
   CreateDashboardLabel("DASH_V_NG_V", DoubleToString(NetGexVol, 4), col2, y, NetGexVol >= 0 ? clrLimeGreen : clrRed, 9, true, ANCHOR_RIGHT_UPPER);
   
   y += 30;
   
   // --- Open Interest Section ---
   CreateDashboardLabel("DASH_O_TITLE", "open interest", col1, y, clrWhite, 10, true);
   y += 18;
   CreateDashboardLine("DASH_LINE_2", col1, y, panelW - 30);
   y += 10;
   CreateDashboardLabel("DASH_O_MP_L", "major positive", col1, y, clrLimeGreen);
   CreateDashboardLabel("DASH_O_MP_V", DoubleToString(DexCallWall, 2), col2, y, clrWhite, 9, false, ANCHOR_RIGHT_UPPER);
   y += 18;
   CreateDashboardLabel("DASH_O_MN_L", "major negative", col1, y, clrRed);
   CreateDashboardLabel("DASH_O_MN_V", DoubleToString(DexPutWall, 2), col2, y, clrWhite, 9, false, ANCHOR_RIGHT_UPPER);
   y += 18;
   CreateDashboardLabel("DASH_O_NG_L", "net gex", col1, y, clrWhite);
   CreateDashboardLabel("DASH_O_NG_V", DoubleToString(NetGexOI, 4), col2, y, NetGexOI >= 0 ? clrLimeGreen : clrRed, 9, true, ANCHOR_RIGHT_UPPER);
   
   y += 30;
   
   // --- Max Change Section ---
   CreateDashboardLabel("DASH_M_TITLE", "max change gex", col1, y, clrWhite, 10, true);
   y += 18;
   CreateDashboardLine("DASH_LINE_3", col1, y, panelW - 30);
   y += 10;
   
   int colMid = startX + 130; 
   string mp_labels[5] = {"1 min", "5 min", "10 min", "15 min", "30 min"};
   
   for(int i = 0; i < 5; i++)
     {
      CreateDashboardLabel("DASH_M_L_"+IntegerToString(i), mp_labels[i], col1, y, clrDeepSkyBlue);
      CreateDashboardLabel("DASH_M_S_"+IntegerToString(i), DoubleToString(MaxPriorsStrike[i], 0), colMid, y, MaxPriorsGex[i] >= 0 ? clrLimeGreen : clrRed, 9, false, ANCHOR_RIGHT_UPPER);
      CreateDashboardLabel("DASH_M_V_"+IntegerToString(i), DoubleToString(MaxPriorsGex[i], 4)+"Bn", col2, y, MaxPriorsGex[i] >= 0 ? clrLimeGreen : clrRed, 9, false, ANCHOR_RIGHT_UPPER);
      y += 18;
     }

   // --- Identificadores Inferiores ---
   if(ObjectFind(0, "LBL_GEX_OI") < 0) ObjectCreate(0, "LBL_GEX_OI", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "LBL_GEX_OI", OBJPROP_CORNER, CORNER_LEFT_LOWER);
   ObjectSetInteger(0, "LBL_GEX_OI", OBJPROP_XDISTANCE, 20);
   ObjectSetInteger(0, "LBL_GEX_OI", OBJPROP_YDISTANCE, 40);
   ObjectSetString(0, "LBL_GEX_OI", OBJPROP_TEXT, "GEX OI");
   ObjectSetInteger(0, "LBL_GEX_OI", OBJPROP_COLOR, clrSilver);
   ObjectSetInteger(0, "LBL_GEX_OI", OBJPROP_FONTSIZE, 14);
   ObjectSetString(0, "LBL_GEX_OI", OBJPROP_FONT, "Trebuchet MS Bold");
   ObjectSetInteger(0, "LBL_GEX_OI", OBJPROP_BACK, InpDrawBehind);

   if(ObjectFind(0, "LBL_GEX_VOL") < 0) ObjectCreate(0, "LBL_GEX_VOL", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "LBL_GEX_VOL", OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, "LBL_GEX_VOL", OBJPROP_XDISTANCE, 120);
   ObjectSetInteger(0, "LBL_GEX_VOL", OBJPROP_YDISTANCE, 40);
   ObjectSetString(0, "LBL_GEX_VOL", OBJPROP_TEXT, "GEX VOL");
   ObjectSetInteger(0, "LBL_GEX_VOL", OBJPROP_COLOR, clrSilver);
   ObjectSetInteger(0, "LBL_GEX_VOL", OBJPROP_FONTSIZE, 14);
   ObjectSetString(0, "LBL_GEX_VOL", OBJPROP_FONT, "Trebuchet MS Bold");
   ObjectSetInteger(0, "LBL_GEX_VOL", OBJPROP_BACK, InpDrawBehind);
  }

void DrawHistogram()
  {
   long cw = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);

   for(int i = 0; i < ArraySize(DexArray); i++)
     {
      int x, y; 
      if(!ChartTimePriceToXY(0, 0, TimeCurrent(), DexArray[i].strike, x, y)) continue;
      double ratio = (MaxDexExposure > 0) ? MathAbs(DexArray[i].net_exposure) / MaxDexExposure : 0;
      int bw = (int)MathMax(1, ratio * InpMaxBarWidth);
      CreateOrUpdateBar("DEX_"+DoubleToString(DexArray[i].strike, 2), 0, (int)y-(InpBarThickness/2), bw, InpBarThickness, (DexArray[i].net_exposure >= 0 ? InpDexColorPos : InpDexColorNeg));
     }

   for(int i = 0; i < ArraySize(GexArray); i++)
     {
      int x, y; 
      if(!ChartTimePriceToXY(0, 0, TimeCurrent(), GexArray[i].strike, x, y)) continue;
      double ratio = (MaxGexExposure > 0) ? MathAbs(GexArray[i].net_exposure) / MaxGexExposure : 0;
      int bw = (int)MathMax(1, ratio * InpMaxBarWidth);
      CreateOrUpdateBar("GEX_"+DoubleToString(GexArray[i].strike, 2), (int)cw-bw, (int)y-(InpBarThickness/2), bw, InpBarThickness, (GexArray[i].net_exposure >= 0 ? InpGexColorPos : InpGexColorNeg));
     }
   ChartRedraw();
  }