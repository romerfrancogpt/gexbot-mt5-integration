//+------------------------------------------------------------------+
//|                                           Gexbot Integration.mq5 |
//|                   Lector Data Gexbot Simplificada - Major Levels |
//+------------------------------------------------------------------+
#property copyright "Romer Franco"
#property link      "Public"
#property version   "4.0"

enum ENUM_DTE { DTE_zero, DTE_one, DTE_full };
enum ENUM_MAJORS_COUNT { COUNT_1 = 1, COUNT_2 = 2, COUNT_3 = 3 };

//--- Inputs del Usuario
input string            InpApiKey          = "TU_API_KEY_AQUI"; // API Key
input string            InpTicker          = "SPX";             // Ticker
input ENUM_DTE          InpDte             = DTE_zero;          // DTE
input int               InpRefreshSeconds  = 5;                 // Actualizar (Segundos)
input double            InpStrikeMultiply  = 1.0;               // Multiplicador de strikes

//--- Configuración de Cantidad de Dominantes
input ENUM_MAJORS_COUNT InpCallMajorsCount = COUNT_1;           // Major Calls a mostrar (1-3)
input ENUM_MAJORS_COUNT InpPutMajorsCount  = COUNT_1;           // Major Puts a mostrar (1-3)

//--- Configuración Major Calls
input color             InpCall1Clr        = clrLimeGreen;      // Color Major Call 1
input int               InpCall1Size       = 30;                // Tamaño Major Call 1 (-)
input color             InpCall2Clr        = clrMediumSpringGreen; // Color Major Call 2
input int               InpCall2Size       = 16;                // Tamaño Major Call 2 (-)
input color             InpCall3Clr        = clrDarkGreen;      // Color Major Call 3
input int               InpCall3Size       = 12;                // Tamaño Major Call 3 (-)

//--- Configuración Zero Gamma
input bool              InpShowZeroGamma   = true;              // Mostrar Zero Gamma
input color             InpZeroGammaClr    = clrOrange;         // Color Zero Gamma
input int               InpZeroGammaSize   = 20;                // Tamaño Zero Gamma (-)

//--- Configuración Major Puts
input color             InpPut1Clr         = clrRed;            // Color Major Put 1
input int               InpPut1Size        = 30;                // Tamaño Major Put 1 (-)
input color             InpPut2Clr         = clrTomato;        // Color Major Put 2
input int               InpPut2Size        = 16;                // Tamaño Major Put 2 (-)
input color             InpPut3Clr         = clrDarkRed;        // Color Major Put 3
input int               InpPut3Size        = 12;                // Tamaño Major Put 3 (-)

//--- Estilo General
input color             InpTextClr         = clrSilver;         // Color Textos Dashboard
input color             InpValClr          = clrWhite;          // Color Valores Dashboard

//--- Estructuras y Variables Globales
struct StrikeGex { double strike; double vol; };

double ZeroGamma = 0;
double GexCallWalls[3] = {0, 0, 0};
double GexPutWalls[3]  = {0, 0, 0};

//+------------------------------------------------------------------+
int OnInit() { 
   EventSetTimer(InpRefreshSeconds); 
   FetchAPIData(); 
   return(INIT_SUCCEEDED); 
}

void OnDeinit(const int reason) { 
   EventKillTimer(); 
   ObjectsDeleteAll(0, "HEAD_"); 
   ObjectsDeleteAll(0, "BTN_"); // Conserva todos los objetos "DOT_" intactos
   ChartRedraw(); 
}

void OnTick() { }
void OnTimer() { FetchAPIData(); }

//--- Evento de clic en el gráfico
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == "BTN_RESET") {
      ObjectsDeleteAll(0, "DOT_"); // Borra historial visual
      ObjectSetInteger(0, "BTN_RESET", OBJPROP_STATE, false); 
      ChartRedraw();
   }
}

//+------------------------------------------------------------------+
void FetchAPIData() {
   string strDte = (InpDte == DTE_zero) ? "zero" : (InpDte == DTE_one ? "one" : "full");
   string url = "https://api.gexbot.com/" + InpTicker + "/classic/" + strDte + "?ts=" + IntegerToString(GetTickCount64());
   string headers = "Authorization: Bearer " + InpApiKey + "\r\nUser-Agent: MT5_Client/1.0\r\nAccept: application/json\r\n";
   char post[], result[]; string result_headers;
   
   int res = WebRequest("GET", url, headers, 5000, post, result, result_headers);
   if(res == 200) { 
      string json = CharArrayToString(result); 
      if(ParseAPIResponse(json)) { 
         DrawDashboard(); 
         AddHistoricalDots(); 
         ChartRedraw();
      } 
   }
}

double ExtractRawValue(string &json, string key) {
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

bool ParseAPIResponse(string json) {
   ArrayInitialize(GexCallWalls, 0);
   ArrayInitialize(GexPutWalls, 0);
   
   ZeroGamma = ExtractRawValue(json, "\"zero_gamma\":") * InpStrikeMultiply;
   
   // Valores por defecto
   GexCallWalls[0] = ExtractRawValue(json, "\"major_pos_vol\":") * InpStrikeMultiply;
   GexPutWalls[0]  = ExtractRawValue(json, "\"major_neg_vol\":") * InpStrikeMultiply;

   int s_pos = StringFind(json, "\"strikes\":[[");
   if(s_pos >= 0) {
      int pos = s_pos + 11;
      StrikeGex posGex[]; ArrayResize(posGex, 0);
      StrikeGex negGex[]; ArrayResize(negGex, 0);

      while(pos < StringLen(json)) {
         int start = StringFind(json, "[", pos);
         if(start < 0) break;
         int end = StringFind(json, "]", start);
         if(end < 0) break;

         string el = StringSubstr(json, start + 1, end - start - 1);
         string vals[]; StringSplit(el, ',', vals);

         if(ArraySize(vals) >= 2) {
            double strk = StringToDouble(vals[0]) * InpStrikeMultiply;
            double vol = StringToDouble(vals[1]);

            if(vol > 0) {
               int sz = ArraySize(posGex); ArrayResize(posGex, sz + 1);
               posGex[sz].strike = strk; posGex[sz].vol = vol;
            }
            else if(vol < 0) {
               int sz = ArraySize(negGex); ArrayResize(negGex, sz + 1);
               negGex[sz].strike = strk; negGex[sz].vol = vol;
            }
         }
         pos = end + 1;
      }

      // Ordenar Calls de mayor a menor volumen positivo
      for(int i = 0; i < ArraySize(posGex) - 1; i++) {
         for(int j = i + 1; j < ArraySize(posGex); j++) {
            if(posGex[j].vol > posGex[i].vol) {
               StrikeGex temp = posGex[i]; posGex[i] = posGex[j]; posGex[j] = temp;
            }
         }
      }

      // Ordenar Puts de mayor a menor volumen negativo (más negativo primero)
      for(int i = 0; i < ArraySize(negGex) - 1; i++) {
         for(int j = i + 1; j < ArraySize(negGex); j++) {
            if(negGex[j].vol < negGex[i].vol) {
               StrikeGex temp = negGex[i]; negGex[i] = negGex[j]; negGex[j] = temp;
            }
         }
      }

      // Asignar los Top 3 mayores
      for(int i = 0; i < 3 && i < ArraySize(posGex); i++) GexCallWalls[i] = posGex[i].strike;
      for(int i = 0; i < 3 && i < ArraySize(negGex); i++) GexPutWalls[i]  = negGex[i].strike;
   }

   return (ZeroGamma > 0 || GexCallWalls[0] > 0 || GexPutWalls[0] > 0);
}

//+------------------------------------------------------------------+
void AddHistoricalDots() {
   datetime time = TimeCurrent();
   string ms = IntegerToString(GetTickCount());
   
   // Trazar Major Calls según la cantidad seleccionada (1, 2 o 3)
   for(int i = 0; i < (int)InpCallMajorsCount; i++) {
      if(GexCallWalls[i] > 0) {
         color clr = (i == 0) ? InpCall1Clr : ((i == 1) ? InpCall2Clr : InpCall3Clr);
         int sz   = (i == 0) ? InpCall1Size : ((i == 1) ? InpCall2Size : InpCall3Size);
         DrawDot("DOT_C" + IntegerToString(i+1) + "_" + ms, time, GexCallWalls[i], clr, sz);
      }
   }

   // Trazar Zero Gamma
   if(InpShowZeroGamma && ZeroGamma > 0) {
      DrawDot("DOT_Z_" + ms, time, ZeroGamma, InpZeroGammaClr, InpZeroGammaSize);
   }

   // Trazar Major Puts según la cantidad seleccionada (1, 2 o 3)
   for(int i = 0; i < (int)InpPutMajorsCount; i++) {
      if(GexPutWalls[i] > 0) {
         color clr = (i == 0) ? InpPut1Clr : ((i == 1) ? InpPut2Clr : InpPut3Clr);
         int sz   = (i == 0) ? InpPut1Size : ((i == 1) ? InpPut2Size : InpPut3Size);
         DrawDot("DOT_P" + IntegerToString(i+1) + "_" + ms, time, GexPutWalls[i], clr, sz);
      }
   }
}

void DrawDot(string name, datetime time, double price, color clr, int fontSize) {
   ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
   ObjectSetString(0, name, OBJPROP_TEXT, "-");
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_CENTER);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, DoubleToString(price, 2));
}

//+------------------------------------------------------------------+
void DrawDashboard() {
   ObjectsDeleteAll(0, "HEAD_");
   
   int x1 = 350, x2 = 600, x3 = 900; 
   int y1 = 20,  y2 = 40,  y3 = 60;  
   
   double spot = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   if (spot == 0) spot = SymbolInfoDouble(_Symbol, SYMBOL_BID); 
   
   string timeStr = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
   StringReplace(timeStr, ".", "-"); 
   
   // Logo en texto
   CreateLabel("HEAD_LOGO1", "gex", 300, y1, InpValClr, 16, false);
   CreateLabel("HEAD_LOGO2", "bot", 300, y2, InpValClr, 16, false);

   // Columna 1
   CreateLabel("HEAD_L1", "source:", x1, y1, InpTextClr, 10, true);
   CreateLabel("HEAD_V1", "gexbot.com", x1+100, y1, InpValClr, 10, false);
   CreateLabel("HEAD_L2", "chart type:", x1, y2, InpTextClr, 10, true);
   CreateLabel("HEAD_V2", "classic", x1+100, y2, InpValClr, 10, false);
   CreateLabel("HEAD_L3", "model:", x1, y3, InpTextClr, 10, true);
   CreateLabel("HEAD_V3", "gex by volume", x1+100, y3, InpValClr, 10, false);

   // Columna 2
   CreateLabel("HEAD_L4", "ticker:", x2, y1, InpTextClr, 10, true);
   CreateLabel("HEAD_V4", InpTicker, x2+80, y1, InpValClr, 10, false);
   CreateLabel("HEAD_L5", "spot:", x2, y2, InpTextClr, 10, true);
   CreateLabel("HEAD_V5", "$"+DoubleToString(spot, 2), x2+80, y2, InpValClr, 10, false);
   CreateLabel("HEAD_L6", "datetime:", x2, y3, InpTextClr, 10, true);
   CreateLabel("HEAD_V6", timeStr, x2+80, y3, InpValClr, 10, false);

   // Columna 3
   CreateLabel("HEAD_L7", "major call:", x3, y1, InpTextClr, 10, true);
   CreateLabel("HEAD_V7", "$"+DoubleToString(GexCallWalls[0], 2), x3+120, y1, InpCall1Clr, 10, false);
   CreateLabel("HEAD_L8", "zero gamma:", x3, y2, InpTextClr, 10, true);
   CreateLabel("HEAD_V8", "$"+DoubleToString(ZeroGamma, 2), x3+120, y2, InpZeroGammaClr, 10, false);
   CreateLabel("HEAD_L9", "major put:", x3, y3, InpTextClr, 10, true);
   CreateLabel("HEAD_V9", "$"+DoubleToString(GexPutWalls[0], 2), x3+120, y3, InpPut1Clr, 10, false);

   // Botón Reiniciar Niveles
   if(ObjectFind(0, "BTN_RESET") < 0) {
      ObjectCreate(0, "BTN_RESET", OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, "BTN_RESET", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, "BTN_RESET", OBJPROP_XDISTANCE, 160);
      ObjectSetInteger(0, "BTN_RESET", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, "BTN_RESET", OBJPROP_XSIZE, 130);
      ObjectSetInteger(0, "BTN_RESET", OBJPROP_YSIZE, 30);
      ObjectSetString(0, "BTN_RESET", OBJPROP_TEXT, "Reiniciar Niveles");
      ObjectSetInteger(0, "BTN_RESET", OBJPROP_BGCOLOR, clrDarkRed);
      ObjectSetInteger(0, "BTN_RESET", OBJPROP_COLOR, clrWhite);
      ObjectSetInteger(0, "BTN_RESET", OBJPROP_BORDER_COLOR, clrRed);
      ObjectSetInteger(0, "BTN_RESET", OBJPROP_FONTSIZE, 9);
      ObjectSetString(0, "BTN_RESET", OBJPROP_FONT, "Trebuchet MS Bold");
      ObjectSetInteger(0, "BTN_RESET", OBJPROP_BACK, false);
      ObjectSetInteger(0, "BTN_RESET", OBJPROP_STATE, false);
   }
}

void CreateLabel(string name, string text, int x, int y, color clr, int fontSize, bool bold) {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, bold ? "Trebuchet MS Bold" : "Trebuchet MS");
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
}