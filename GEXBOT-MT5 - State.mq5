//+------------------------------------------------------------------+
//|                                           Gexbot Integration.mq5 |
//|               EA Classic (Sides) + State (Center Divergent Bars) |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Romer Franco"
#property link      "Public"
#property version   "2.20"

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

// Greek disponible en el endpoint "options profile greeks" (.../state/{greek}_{zero|one})
enum ENUM_STATE_GREEK {
   GREEK_GAMMA,  // gamma (Convexity)
   GREEK_DELTA,  // delta (DEX)
   GREEK_VANNA,  // vanna
   GREEK_CHARM   // charm
};

//--- Inputs del Usuario
input string        InpApiKey          = "TU_API_KEY_AQUI";               // API Key (Bearer Token)
input string        InpTicker          = "SPX";                           // Ticker (ej: SPX)
input ENUM_DTE      InpDte             = DTE_zero;                        // DTE Aggregation
input int           InpRefreshSeconds  = 10;                              // Actualizar cada X segundos

//--- Inputs de Visualización (Classic & General)
input ENUM_DASH_POS InpDashPos         = POS_TOP_LEFT;                    // Posición del Dashboard
input bool          InpDrawBehind      = true;                            // Dibujar DETRÁS de las velas (Fondo)
input bool          InpTransparentBg   = false;                           // Panel 100% Invisible (Solo texto)
input int           InpMaxBarWidth     = 400;                             // Ancho máximo del histograma Lateral (Pixeles)
input int           InpBarThickness    = 4;                               // Grosor de cada barra (Pixeles)
input double        InpStrikeMultiply  = 1.0;                             // Multiplicador de strikes

//--- Inputs de Visualización (State Center Bars)
input bool          InpShowStateCenter = true;                            // Mostrar barras State al Centro
input ENUM_STATE_GREEK InpStateGreek   = GREEK_GAMMA;                     // Greek a mostrar al centro (gamma/delta/vanna/charm)
input int           InpStateMaxBarWidth= 250;                             // Ancho máximo de barras State (Pixeles)
input color         InpStateColorPos   = clrCyan;                         // Color State Positivo (Cyan)
input color         InpStateColorNeg   = clrMagenta;                      // Color State Negativo (Magenta)
//--- NOTA: el endpoint de greeks (.../state/{greek}_{dte}) solo soporta "zero" y "one".
//--- Si InpDte = DTE_full, se usa "zero" como fallback para este histograma central.

//--- Colores y Estilos (Classic)
input color         InpDexColorPos     = clrGreen;                        // Color GEX OI Positivo (Izquierda)
input color         InpDexColorNeg     = clrRed;                          // Color GEX OI Negativo (Izquierda)
input color         InpGexColorPos     = clrGreen;                        // Color GEX VOL Positivo (Derecha)
input color         InpGexColorNeg     = clrRed;                          // Color GEX VOL Negativo (Derecha)

input color         InpZeroGammaClr    = clrOrange;                       // Color linea Zero Gamma
input color         InpGexCallWallClr  = clrLimeGreen;                    // Color linea Vol Call Wall
input color         InpGexPutWallClr   = clrRed;                          // Color linea Vol Put Wall
input color         InpDexCallWallClr  = clrGreen;                        // Color linea OI Call Wall
input color         InpDexPutWallClr   = clrRed;                          // Color linea OI Put Wall

//--- Estructuras
struct ExposureData { double strike; double net_exposure; };
struct StateData    { double strike; double imbalance; };
struct LevelInfo    { double price; color clr; string label; };

ExposureData GexArray[]; 
ExposureData DexArray[]; 
StateData    StateArray[];

double MaxGexExposure = 0, MaxDexExposure = 0, MaxStateExposure = 0;
double GexCallWall = 0, GexPutWall = 0, DexCallWall = 0, DexPutWall = 0;

//--- Variables del Dashboard
double ZeroGamma = 0;
double NetGexVol = 0;
double NetGexOI = 0;
double MaxPriorsStrike[5];
double MaxPriorsGex[5];
bool ShowDashboard = true; 

//+------------------------------------------------------------------+
int OnInit() { EventSetTimer(InpRefreshSeconds); FetchAPIData(); return(INIT_SUCCEEDED); }
void OnDeinit(const int reason) { EventKillTimer(); ObjectsDeleteAll(0, "GEX_"); ObjectsDeleteAll(0, "DEX_"); ObjectsDeleteAll(0, "STATE_"); ObjectsDeleteAll(0, "LVL_"); ObjectsDeleteAll(0, "DASH_"); ObjectsDeleteAll(0, "LBL_"); ObjectDelete(0, "BTN_DASH_TOGGLE"); ChartRedraw(); }
void OnTick() { }
void OnTimer() { FetchAPIData(); }
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) 
  { 
   if(id == CHARTEVENT_CHART_CHANGE) 
     { 
      DrawHistogram(); 
      DrawStateHistogram();
      DrawKeyLevels(); 
      DrawDashboard();
      ChartRedraw(); // Redibujo unico y centralizado, evita parpadeos parciales
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
string GetGreekKey()
  {
   switch(InpStateGreek)
     {
      case GREEK_DELTA: return "delta";
      case GREEK_VANNA: return "vanna";
      case GREEK_CHARM: return "charm";
      default:          return "gamma";
     }
  }

// El endpoint de greeks solo acepta "zero" u "one" (no "full")
string GetGreekDteSuffix()
  {
   if(InpDte == DTE_one) return "one";
   return "zero";
  }

// Texto legible para el label del panel central (ej: "GAMMA (0DTE)")
string GetGreekDisplayLabel()
  {
   string g = GetGreekKey();
   StringToUpper(g);
   string dte = (GetGreekDteSuffix() == "one") ? "1DTE" : "0DTE";
   return g + " (" + dte + ")";
  }

//+------------------------------------------------------------------+
void FetchAPIData()
  {
   string strDte = (InpDte == DTE_zero) ? "zero" : (InpDte == DTE_one ? "one" : "full");
   string headers = "Authorization: Bearer " + InpApiKey + "\r\nUser-Agent: MT5_Client/1.0\r\nAccept: application/json\r\nCache-Control: no-cache\r\n";
   char post[], result[]; string result_headers;

   // 1. Petición API Classic
   string urlClassic = "https://api.gexbot.com/" + InpTicker + "/classic/" + strDte + "?ts=" + IntegerToString(GetTickCount64());
   int resClassic = WebRequest("GET", urlClassic, headers, 5000, post, result, result_headers);
   if(resClassic == 200) 
     { 
      string json = CharArrayToString(result); 
      ParseClassicAPIResponse(json); 
     }

   // 2. Petición API State (Greeks) - ej: https://api.gexbot.com/SPX/state/gamma_zero
   if(InpShowStateCenter)
     {
      string urlState = "https://api.gexbot.com/" + InpTicker + "/state/" + GetGreekKey() + "_" + GetGreekDteSuffix() + "?ts=" + IntegerToString(GetTickCount64());
      int resState = WebRequest("GET", urlState, headers, 5000, post, result, result_headers);
      if(resState == 200)
        {
         string jsonState = CharArrayToString(result);
         ParseStateAPIResponse(jsonState);
        }
     }

   DrawHistogram(); 
   DrawStateHistogram();
   DrawKeyLevels(); 
   DrawDashboard();
   ChartRedraw(); // Redibujo unico y centralizado, evita parpadeos parciales
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
//| Borra SOLO los objetos con "prefix" cuyo nombre ya no esta en    |
//| validNames[]. Nunca toca los que siguen vigentes -> sin parpadeo |
//+------------------------------------------------------------------+
void CleanupObsoleteObjects(string prefix, string &validNames[])
  {
   int total = ObjectsTotal(0, -1, -1);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, -1, -1);
      if(StringFind(name, prefix) != 0) continue; // no empieza con el prefijo

      bool found = false;
      for(int j = 0; j < ArraySize(validNames); j++)
        {
         if(validNames[j] == name) { found = true; break; }
        }
      if(!found) ObjectDelete(0, name);
     }
  }

//+------------------------------------------------------------------+
bool ParseClassicAPIResponse(string json)
  {
   // NOTA: ya NO se borra todo aqui. Los objetos GEX_/DEX_ se actualizan
   // en su lugar (CreateOrUpdateBar) y solo se eliminan los que sobran
   // al final, via CleanupObsoleteObjects. Esto elimina el parpadeo
   // que ocurria cada InpRefreshSeconds.
   ArrayResize(GexArray, 0); ArrayResize(DexArray, 0); MaxGexExposure = 0; MaxDexExposure = 0;

   ZeroGamma   = ExtractRawValue(json, "\"zero_gamma\":")    * InpStrikeMultiply;
   GexCallWall = ExtractRawValue(json, "\"major_pos_vol\":")  * InpStrikeMultiply;
   GexPutWall  = ExtractRawValue(json, "\"major_neg_vol\":")  * InpStrikeMultiply;
   DexCallWall = ExtractRawValue(json, "\"major_pos_oi\":")   * InpStrikeMultiply;
   DexPutWall  = ExtractRawValue(json, "\"major_neg_oi\":")   * InpStrikeMultiply;

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

   // Limpieza incremental: solo se eliminan strikes que ya no vienen en la data nueva
   string validGex[], validDex[];
   ArrayResize(validGex, ArraySize(GexArray));
   for(int i = 0; i < ArraySize(GexArray); i++) validGex[i] = "GEX_" + DoubleToString(GexArray[i].strike, 2);
   ArrayResize(validDex, ArraySize(DexArray));
   for(int i = 0; i < ArraySize(DexArray); i++) validDex[i] = "DEX_" + DoubleToString(DexArray[i].strike, 2);
   CleanupObsoleteObjects("GEX_", validGex);
   CleanupObsoleteObjects("DEX_", validDex);

   return true;
  }

//+------------------------------------------------------------------+
bool ParseStateAPIResponse(string json)
  {
   // NOTA: ya NO se hace ObjectsDeleteAll(0,"STATE_") aqui. Ese borrado
   // masivo en cada refresco de datos era la causa del parpadeo del
   // histograma central. Ahora se actualiza en su lugar y solo se
   // limpian al final los strikes que dejaron de existir.
   //
   // Este endpoint ("options profile greeks") devuelve "mini_contracts"
   // en vez de "strikes", con formato:
   // [strike, call_ivol, put_ivol, specified_greek, priors]
   // Usamos indice 0 = strike, indice 3 = valor del greek seleccionado
   // (gamma/delta/vanna/charm segun InpStateGreek) para dibujar las barras.
   ArrayResize(StateArray, 0); 
   MaxStateExposure = 0;

   int s_pos = StringFind(json, "\"mini_contracts\":[[");
   if(s_pos < 0) return false;
   int pos = s_pos + 18;

   while(pos < StringLen(json))
     {
      int start = StringFind(json, "[", pos);
      if(start < 0) break;
      int end = StringFind(json, "]", start);
      string el = StringSubstr(json, start + 1, end - start - 1);
      string vals[]; StringSplit(el, ',', vals);
      if(ArraySize(vals) >= 4)
        {
         double strk = StringToDouble(vals[0]) * InpStrikeMultiply;
         double greekVal = StringToDouble(vals[3]); // valor del greek (gamma por defecto)
         
         int s = ArraySize(StateArray); 
         ArrayResize(StateArray, s + 1); 
         StateArray[s].strike = strk; 
         StateArray[s].imbalance = greekVal;
         
         if(MathAbs(greekVal) > MaxStateExposure) MaxStateExposure = MathAbs(greekVal);
        }
      pos = end + 1;
     }

   // Limpieza incremental: solo se eliminan strikes que ya no vienen en la data nueva
   string validState[];
   ArrayResize(validState, ArraySize(StateArray));
   for(int i = 0; i < ArraySize(StateArray); i++) validState[i] = "STATE_" + DoubleToString(StateArray[i].strike, 2);
   CleanupObsoleteObjects("STATE_", validState);

   return true;
  }

void CreateOrUpdateBar(string name, int x, int y, int width, int height, color clr)
  {
   if(ObjectFind(0, name) < 0) { ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0); ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER); }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x); ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width); ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BACK, InpDrawBehind);
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

   AddLevelToArray(levels, ZeroGamma, InpZeroGammaClr, "Zero Gamma");
   AddLevelToArray(levels, GexCallWall, InpGexCallWallClr, "Vol Call Wall");
   AddLevelToArray(levels, GexPutWall, InpGexPutWallClr, "Vol Put Wall");
   AddLevelToArray(levels, DexCallWall, InpDexCallWallClr, "OI Call Wall");
   AddLevelToArray(levels, DexPutWall, InpDexPutWallClr, "OI Put Wall");

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
      ObjectSetInteger(0, lineName, OBJPROP_BACK, InpDrawBehind);

      if(ObjectFind(0, textName) < 0) ObjectCreate(0, textName, OBJ_TEXT, 0, textTime, curPrice);
      ObjectSetDouble(0, textName, OBJPROP_PRICE, curPrice);
      ObjectSetInteger(0, textName, OBJPROP_TIME, textTime);
      ObjectSetString(0, textName, OBJPROP_TEXT, "  " + combinedText + " (" + DoubleToString(curPrice, _Digits) + ")");
      ObjectSetInteger(0, textName, OBJPROP_COLOR, mainColor);
      ObjectSetInteger(0, textName, OBJPROP_FONTSIZE, 9);
      ObjectSetInteger(0, textName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, textName, OBJPROP_BACK, InpDrawBehind);
      
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
   ObjectSetInteger(0, name, OBJPROP_BACK, InpDrawBehind);
  }

void DrawDashboard()
  {
   // NOTA: ya NO se hace ObjectsDeleteAll(0,"DASH_") en cada llamada.
   // Esta funcion se ejecuta en CADA evento CHART_CHANGE (mover, hacer
   // zoom, arrastrar la ventana), y borrar+recrear ~30 objetos en cada
   // uno de esos eventos era la causa del parpadeo del panel al mover
   // el grafico. Ahora todo se actualiza en su lugar; solo se borra si
   // el usuario oculta el panel con el boton.
   long chartW = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   long chartH = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   
   int panelW = 260; 
   int panelH = 370; 
   int startX = 20;
   int startY = 40;
   
   switch(InpDashPos)
     {
      case POS_TOP_LEFT:       startX = 20; startY = 40; break;
      case POS_TOP_RIGHT:      startX = (int)chartW - panelW - 20; startY = 40; break;
      case POS_BOTTOM_LEFT:    startX = 20; startY = (int)chartH - panelH - 50; break;
      case POS_BOTTOM_RIGHT:   startX = (int)chartW - panelW - 20; startY = (int)chartH - panelH - 50; break;
      case POS_TOP_CENTER:     startX = (int)(chartW - panelW) / 2; startY = 40; break;
      case POS_BOTTOM_CENTER:  startX = (int)(chartW - panelW) / 2; startY = (int)chartH - panelH - 50; break;
     }

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
   ObjectSetInteger(0, "BTN_DASH_TOGGLE", OBJPROP_BACK, false);

   if(!ShowDashboard) 
     { 
      ObjectsDeleteAll(0, "DASH_"); // solo se borra al ocultar el panel, no en cada refresco/movimiento
      return; 
     }

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

   // Dibujar OI (DEX) en el lado izquierdo
   for(int i = 0; i < ArraySize(DexArray); i++)
     {
      string barName = "DEX_"+DoubleToString(DexArray[i].strike, 2);
      int x, y; 
      if(!ChartTimePriceToXY(0, 0, TimeCurrent(), DexArray[i].strike, x, y))
        {
         if(ObjectFind(0, barName) >= 0) ObjectDelete(0, barName);
         continue;
        }
      double ratio = (MaxDexExposure > 0) ? MathAbs(DexArray[i].net_exposure) / MaxDexExposure : 0;
      int bw = (int)MathMax(1, ratio * InpMaxBarWidth);
      CreateOrUpdateBar(barName, 0, (int)y-(InpBarThickness/2), bw, InpBarThickness, (DexArray[i].net_exposure >= 0 ? InpDexColorPos : InpDexColorNeg));
     }

   // Dibujar Volumen (GEX) en el lado derecho
   for(int i = 0; i < ArraySize(GexArray); i++)
     {
      string barName = "GEX_"+DoubleToString(GexArray[i].strike, 2);
      int x, y; 
      if(!ChartTimePriceToXY(0, 0, TimeCurrent(), GexArray[i].strike, x, y))
        {
         if(ObjectFind(0, barName) >= 0) ObjectDelete(0, barName);
         continue;
        }
      double ratio = (MaxGexExposure > 0) ? MathAbs(GexArray[i].net_exposure) / MaxGexExposure : 0;
      int bw = (int)MathMax(1, ratio * InpMaxBarWidth);
      CreateOrUpdateBar(barName, (int)cw-bw, (int)y-(InpBarThickness/2), bw, InpBarThickness, (GexArray[i].net_exposure >= 0 ? InpGexColorPos : InpGexColorNeg));
     }
   // ChartRedraw() se llama ahora una sola vez, centralizado, desde
   // OnChartEvent()/FetchAPIData() despues de dibujar todo.
  }

// --- Dibujar Barras State en el Centro del Gráfico sin parpadeo ---
void DrawStateHistogram()
  {
   if(!InpShowStateCenter) 
     {
      ObjectsDeleteAll(0, "STATE_");
      return;
     }
   
   long cw = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   long ch = ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   int centerX = (int)(cw / 2); // Eje central de la pantalla

   // Etiqueta fija (no parpadea, se actualiza en su lugar) indicando el
   // greek y DTE que se esta mostrando en las barras centrales.
   if(ObjectFind(0, "STATE_LBL_TITLE") < 0) ObjectCreate(0, "STATE_LBL_TITLE", OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, "STATE_LBL_TITLE", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "STATE_LBL_TITLE", OBJPROP_XDISTANCE, centerX);
   ObjectSetInteger(0, "STATE_LBL_TITLE", OBJPROP_YDISTANCE, 4);
   ObjectSetInteger(0, "STATE_LBL_TITLE", OBJPROP_ANCHOR, ANCHOR_TOP);
   ObjectSetString(0, "STATE_LBL_TITLE", OBJPROP_TEXT, GetGreekDisplayLabel());
   ObjectSetInteger(0, "STATE_LBL_TITLE", OBJPROP_COLOR, clrSilver);
   ObjectSetInteger(0, "STATE_LBL_TITLE", OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, "STATE_LBL_TITLE", OBJPROP_FONT, "Trebuchet MS Bold");
   ObjectSetInteger(0, "STATE_LBL_TITLE", OBJPROP_BACK, InpDrawBehind);
   
   // No se hace ObjectsDeleteAll aqui: los objetos STATE_ se crean/actualizan
   // en su lugar (CreateOrUpdateBar) y la limpieza de strikes obsoletos ya
   // se hizo de forma incremental en ParseStateAPIResponse().
   
   for(int i = 0; i < ArraySize(StateArray); i++)
     {
      string barName = "STATE_"+DoubleToString(StateArray[i].strike, 2);
      int x, y; 
      if(!ChartTimePriceToXY(0, 0, TimeCurrent(), StateArray[i].strike, x, y) || y < 0 || y > ch)
        {
         // La barra quedo fuera del area visible (p.ej. al achicar la ventana
         // o hacer scroll). Como el objeto esta anclado por pixel, si no se
         // borra aqui se queda "congelado" en su ultima posicion -> parecia
         // que las barras se movian sin borrarse. Se borra explicitamente.
         if(ObjectFind(0, barName) >= 0) ObjectDelete(0, barName);
         continue;
        }
      
      double ratio = (MaxStateExposure > 0) ? MathAbs(StateArray[i].imbalance) / MaxStateExposure : 0;
      int bw = (int)MathMax(1, ratio * InpStateMaxBarWidth);
      
      int barX = centerX;
      if(StateArray[i].imbalance < 0)
        {
         barX = centerX - bw; // Se extiende hacia la izquierda desde el centro
        }
      
      color clr = (StateArray[i].imbalance >= 0) ? InpStateColorPos : InpStateColorNeg;
      CreateOrUpdateBar(barName, barX, (int)y-(InpBarThickness/2), bw, InpBarThickness, clr);
     }
  }