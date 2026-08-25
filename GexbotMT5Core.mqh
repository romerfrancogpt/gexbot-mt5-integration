//+------------------------------------------------------------------+
//| GexbotMT5Core.mqh                                                |
//| Shared Classic and State implementation for MetaTrader 5.        |
//| Copyright: romerfrancogpt and Not Financial Advice, LLC          |
//| License: MIT. See LICENSE.                                       |
//+------------------------------------------------------------------+

#ifndef GEXBOT_MT5_CORE_MQH
#define GEXBOT_MT5_CORE_MQH

#define GB_VERSION             "v2.2026.08.25"
#define GB_API_BASE            "https://api.gex.bot/v2"
#define GB_OBJECT_PREFIX       "GB_"
#define GB_PROFILE_COUNT       7
#define GB_HISTORY_GAP_SECONDS 600
#define GB_MAX_RESPONSE_CHARS   5000000
#define GB_MAX_PROFILE_ROWS     2000

#ifdef GEXBOT_CLASSIC_COMPAT
   #define GB_DEFAULT_STATE_PROFILE false
   #define GB_DEFAULT_GAMMA_PROFILE false
   #define GB_DEFAULT_STATE_MAJOR   false
#else
   #define GB_DEFAULT_STATE_PROFILE true
   #define GB_DEFAULT_GAMMA_PROFILE true
   #define GB_DEFAULT_STATE_MAJOR   true
#endif

//--- Public option types.
enum ENUM_GB_DTE
  {
   GB_DTE_ZERO,
   GB_DTE_ONE,
   GB_DTE_FULL
  };

enum ENUM_GB_GREEK_DTE
  {
   GB_GREEK_DTE_ZERO,
   GB_GREEK_DTE_ONE
  };

enum ENUM_GB_PROFILE_ALIGN
  {
   GB_ALIGN_LEFT,
   GB_ALIGN_RIGHT,
   GB_ALIGN_DIVERGING
  };

enum ENUM_GB_PROFILE_STYLE
  {
   GB_STYLE_BAR,
   GB_STYLE_LINE,
   GB_STYLE_DASH,
   GB_STYLE_DOT
  };

enum ENUM_GB_CONVERSION_MODE
  {
   GB_CONVERSION_NONE,
   GB_CONVERSION_MANUAL,
   GB_CONVERSION_AUTO
  };

enum ENUM_GB_DASH_POSITION
  {
   GB_DASH_TOP_LEFT,
   GB_DASH_TOP_RIGHT,
   GB_DASH_BOTTOM_LEFT,
   GB_DASH_BOTTOM_RIGHT,
   GB_DASH_TOP_CENTER,
   GB_DASH_BOTTOM_CENTER
  };

enum ENUM_GB_LABEL_POSITION
  {
   GB_LABEL_LEFT,
   GB_LABEL_RIGHT,
   GB_LABEL_PERCENT
  };

enum ENUM_GB_HISTORY_STYLE
  {
   GB_HISTORY_LINE,
   GB_HISTORY_SCATTER
  };

enum ENUM_GB_PROFILE_ID
  {
   GB_PROFILE_CLASSIC_VOL,
   GB_PROFILE_CLASSIC_OI,
   GB_PROFILE_STATE_GEX,
   GB_PROFILE_GAMMA,
   GB_PROFILE_DELTA,
   GB_PROFILE_VANNA,
   GB_PROFILE_CHARM
  };

//--- General and connection inputs.
input group "Connection"
input string InpApiKey                  = "";                    // API key. Leave empty when API Key File is used.
input string InpApiKeyFile              = "";                    // Optional file under MQL5/Files that contains the API key.
input string InpTicker                  = "SPX";                 // Source ticker.
input int    InpRefreshSeconds          = 5;                     // Desired refresh interval for each enabled source.
input int    InpWebRequestTimeoutMs     = 5000;                  // HTTP request timeout in milliseconds.
input bool   InpInitialFetch            = true;                  // Request all enabled sources during initialization.
input bool   InpLimitToMarketHours      = true;                  // Limit recurring requests to US equity market hours.
input int    InpMarketOpenHour          = 9;                     // New York market-open hour.
input int    InpMarketOpenMinute        = 30;                    // New York market-open minute.
input int    InpMarketCloseHour         = 16;                    // New York market-close hour.
input int    InpMarketCloseMinute       = 0;                     // New York market-close minute.

//--- Futures conversion inputs.
input group "Futures Conversion"
input ENUM_GB_CONVERSION_MODE InpConversionMode = GB_CONVERSION_NONE;
input string InpFuturesTarget           = "";                    // Futures product, such as ES or NQ, for automatic conversion.
input double InpManualMultiplier        = 1.0;                   // Manual multiplicative conversion.
input double InpManualAdditive          = 0.0;                   // Manual additive conversion.

//--- General drawing inputs.
input group "Drawing"
input bool InpDrawBehindCandles         = true;                  // Put profile and level objects behind candles.
input bool InpShowProfileLabels         = true;                  // Show one title above each enabled profile.
input bool InpShowPriorDots             = true;                  // Master switch for per-strike prior dots.
input int  InpDefaultPriorDotSize       = 3;                     // Default prior-dot size in pixels.

//--- Classic volume profile inputs.
input group "Profile - Classic Volume"
input bool                  InpShowClassicVol      = true;
input ENUM_GB_DTE           InpClassicVolDte       = GB_DTE_ZERO;
input ENUM_GB_PROFILE_ALIGN InpClassicVolAlign     = GB_ALIGN_LEFT;
input ENUM_GB_PROFILE_STYLE InpClassicVolStyle     = GB_STYLE_BAR;
input int                   InpClassicVolOriginPct = 88;
input int                   InpClassicVolWidthPx   = 180;
input int                   InpClassicVolThickness = 3;
input int                   InpClassicVolOffsetPx  = 0;
input color                 InpClassicVolPosColor  = clrLimeGreen;
input color                 InpClassicVolNegColor  = clrTomato;
input bool                  InpClassicVolLogScale  = false;
input int                   InpClassicVolTopN      = 0;
input int                   InpClassicVolBottomN   = 0;
input bool                  InpClassicVolPriors    = true;
input int                   InpClassicVolPriorSize = 3;
input color                 InpClassicVolPrior1    = clrLimeGreen;
input color                 InpClassicVolPrior5    = clrGold;
input color                 InpClassicVolPrior10   = clrOrange;
input color                 InpClassicVolPrior15   = clrOrangeRed;
input color                 InpClassicVolPrior30   = clrRed;

//--- Classic OI profile inputs.
input group "Profile - Classic Open Interest"
input bool                  InpShowClassicOi       = true;
input ENUM_GB_DTE           InpClassicOiDte        = GB_DTE_ZERO;
input ENUM_GB_PROFILE_ALIGN InpClassicOiAlign      = GB_ALIGN_RIGHT;
input ENUM_GB_PROFILE_STYLE InpClassicOiStyle      = GB_STYLE_BAR;
input int                   InpClassicOiOriginPct  = 12;
input int                   InpClassicOiWidthPx    = 180;
input int                   InpClassicOiThickness  = 3;
input int                   InpClassicOiOffsetPx   = 0;
input color                 InpClassicOiPosColor   = clrGreen;
input color                 InpClassicOiNegColor   = clrCrimson;
input bool                  InpClassicOiLogScale   = false;
input int                   InpClassicOiTopN       = 0;
input int                   InpClassicOiBottomN    = 0;

//--- State GEX profile inputs.
input group "Profile - State GEX"
input bool                  InpShowStateGex        = GB_DEFAULT_STATE_PROFILE;
input ENUM_GB_DTE           InpStateGexDte         = GB_DTE_ZERO;
input ENUM_GB_PROFILE_ALIGN InpStateGexAlign       = GB_ALIGN_DIVERGING;
input ENUM_GB_PROFILE_STYLE InpStateGexStyle       = GB_STYLE_BAR;
input int                   InpStateGexOriginPct   = 65;
input int                   InpStateGexWidthPx     = 150;
input int                   InpStateGexThickness   = 3;
input int                   InpStateGexOffsetPx    = 0;
input color                 InpStateGexPosColor    = clrMediumSeaGreen;
input color                 InpStateGexNegColor    = clrIndianRed;
input bool                  InpStateGexLogScale    = false;
input int                   InpStateGexTopN        = 0;
input int                   InpStateGexBottomN     = 0;
input bool                  InpStateGexPriors      = true;
input int                   InpStateGexPriorSize   = 3;
input color                 InpStateGexPrior1      = clrLimeGreen;
input color                 InpStateGexPrior5      = clrGold;
input color                 InpStateGexPrior10     = clrOrange;
input color                 InpStateGexPrior15     = clrOrangeRed;
input color                 InpStateGexPrior30     = clrRed;

//--- State Gamma profile inputs.
input group "Profile - State Gamma"
input bool                    InpShowGamma        = GB_DEFAULT_GAMMA_PROFILE;
input ENUM_GB_GREEK_DTE       InpGammaDte         = GB_GREEK_DTE_ZERO;
input ENUM_GB_PROFILE_ALIGN   InpGammaAlign       = GB_ALIGN_DIVERGING;
input ENUM_GB_PROFILE_STYLE   InpGammaStyle       = GB_STYLE_BAR;
input int                     InpGammaOriginPct   = 50;
input int                     InpGammaWidthPx     = 140;
input int                     InpGammaThickness   = 3;
input int                     InpGammaOffsetPx    = 0;
input color                   InpGammaPosColor    = clrCyan;
input color                   InpGammaNegColor    = clrMagenta;
input bool                    InpGammaLogScale    = false;
input int                     InpGammaTopN        = 0;
input int                     InpGammaBottomN     = 0;
input bool                    InpGammaPriors      = true;
input int                     InpGammaPriorSize   = 3;

//--- State Delta profile inputs.
input group "Profile - State Delta"
input bool                    InpShowDelta        = false;
input ENUM_GB_GREEK_DTE       InpDeltaDte         = GB_GREEK_DTE_ZERO;
input ENUM_GB_PROFILE_ALIGN   InpDeltaAlign       = GB_ALIGN_DIVERGING;
input ENUM_GB_PROFILE_STYLE   InpDeltaStyle       = GB_STYLE_BAR;
input int                     InpDeltaOriginPct   = 42;
input int                     InpDeltaWidthPx     = 140;
input int                     InpDeltaThickness   = 3;
input int                     InpDeltaOffsetPx    = 0;
input color                   InpDeltaPosColor    = clrDodgerBlue;
input color                   InpDeltaNegColor    = clrDarkOrange;
input bool                    InpDeltaLogScale    = false;
input int                     InpDeltaTopN        = 0;
input int                     InpDeltaBottomN     = 0;
input bool                    InpDeltaPriors      = true;
input int                     InpDeltaPriorSize   = 3;

//--- State Vanna profile inputs.
input group "Profile - State Vanna"
input bool                    InpShowVanna        = false;
input ENUM_GB_GREEK_DTE       InpVannaDte         = GB_GREEK_DTE_ZERO;
input ENUM_GB_PROFILE_ALIGN   InpVannaAlign       = GB_ALIGN_DIVERGING;
input ENUM_GB_PROFILE_STYLE   InpVannaStyle       = GB_STYLE_BAR;
input int                     InpVannaOriginPct   = 35;
input int                     InpVannaWidthPx     = 140;
input int                     InpVannaThickness   = 3;
input int                     InpVannaOffsetPx    = 0;
input color                   InpVannaPosColor    = clrGold;
input color                   InpVannaNegColor    = clrDeepPink;
input bool                    InpVannaLogScale    = false;
input int                     InpVannaTopN        = 0;
input int                     InpVannaBottomN     = 0;
input bool                    InpVannaPriors      = true;
input int                     InpVannaPriorSize   = 3;

//--- State Charm profile inputs.
input group "Profile - State Charm"
input bool                    InpShowCharm        = false;
input ENUM_GB_GREEK_DTE       InpCharmDte         = GB_GREEK_DTE_ZERO;
input ENUM_GB_PROFILE_ALIGN   InpCharmAlign       = GB_ALIGN_DIVERGING;
input ENUM_GB_PROFILE_STYLE   InpCharmStyle       = GB_STYLE_BAR;
input int                     InpCharmOriginPct   = 28;
input int                     InpCharmWidthPx     = 140;
input int                     InpCharmThickness   = 3;
input int                     InpCharmOffsetPx    = 0;
input color                   InpCharmPosColor    = clrSpringGreen;
input color                   InpCharmNegColor    = clrLightCoral;
input bool                    InpCharmLogScale    = false;
input int                     InpCharmTopN        = 0;
input int                     InpCharmBottomN     = 0;
input bool                    InpCharmPriors      = true;
input int                     InpCharmPriorSize   = 3;

//--- Shared State Greek prior inputs.
input group "State Greek Prior Dots"
input color InpGreekPrior5Color         = clrCyan;
input color InpGreekPrior15Color        = clrDodgerBlue;
input color InpGreekPrior30Color        = clrBlue;

//--- Major line inputs.
input group "Majors - Labels"
input bool                   InpShowMajorLabels    = true;
input bool                   InpShowMajorMagnitude = false;
input ENUM_GB_LABEL_POSITION InpMajorLabelPosition = GB_LABEL_RIGHT;
input int                    InpMajorLabelPct      = 80;
input int                    InpMajorLabelFontSize = 9;

input group "Majors - Classic"
input bool            InpShowZeroGamma       = true;
input color           InpZeroGammaColor      = clrOrange;
input int             InpZeroGammaWidth      = 2;
input ENUM_LINE_STYLE InpZeroGammaStyle      = STYLE_DASH;
input string          InpZeroGammaLabel      = "ZG";
input bool            InpShowClassicPosVol   = true;
input color           InpClassicPosVolColor  = clrLimeGreen;
input int             InpClassicPosVolWidth  = 2;
input ENUM_LINE_STYLE InpClassicPosVolStyle  = STYLE_DASH;
input string          InpClassicPosVolLabel  = "MCV";
input bool            InpShowClassicNegVol   = true;
input color           InpClassicNegVolColor  = clrTomato;
input int             InpClassicNegVolWidth  = 2;
input ENUM_LINE_STYLE InpClassicNegVolStyle  = STYLE_DASH;
input string          InpClassicNegVolLabel  = "MPV";
input bool            InpShowClassicPosOi    = true;
input color           InpClassicPosOiColor   = clrGreen;
input int             InpClassicPosOiWidth   = 2;
input ENUM_LINE_STYLE InpClassicPosOiStyle   = STYLE_DOT;
input string          InpClassicPosOiLabel   = "MCO";
input bool            InpShowClassicNegOi    = true;
input color           InpClassicNegOiColor   = clrCrimson;
input int             InpClassicNegOiWidth   = 2;
input ENUM_LINE_STYLE InpClassicNegOiStyle   = STYLE_DOT;
input string          InpClassicNegOiLabel   = "MPO";

input group "Majors - State"
input bool            InpShowStatePosGex     = GB_DEFAULT_STATE_MAJOR;
input color           InpStatePosGexColor    = clrMediumSeaGreen;
input int             InpStatePosGexWidth    = 2;
input ENUM_LINE_STYLE InpStatePosGexStyle    = STYLE_DASHDOT;
input string          InpStatePosGexLabel    = "State +";
input bool            InpShowStateNegGex     = GB_DEFAULT_STATE_MAJOR;
input color           InpStateNegGexColor    = clrIndianRed;
input int             InpStateNegGexWidth    = 2;
input ENUM_LINE_STYLE InpStateNegGexStyle    = STYLE_DASHDOT;
input string          InpStateNegGexLabel    = "State -";
input bool            InpShowGammaLong       = GB_DEFAULT_STATE_MAJOR;
input color           InpGammaLongColor      = clrCyan;
input int             InpGammaLongWidth      = 2;
input ENUM_LINE_STYLE InpGammaLongStyle      = STYLE_DASH;
input string          InpGammaLongLabel      = "Gamma Long";
input bool            InpShowGammaShort      = GB_DEFAULT_STATE_MAJOR;
input color           InpGammaShortColor     = clrMagenta;
input int             InpGammaShortWidth     = 2;
input ENUM_LINE_STYLE InpGammaShortStyle     = STYLE_DASH;
input string          InpGammaShortLabel     = "Gamma Short";

//--- Locally collected Classic Major history inputs.
input group "Classic Major History"
input bool                  InpCollectMajorHistory    = true;
input bool                  InpPersistMajorHistory    = true;
input bool                  InpShowPosVolHistory      = false;
input color                 InpPosVolHistoryColor     = clrLimeGreen;
input ENUM_GB_HISTORY_STYLE InpPosVolHistoryStyle     = GB_HISTORY_LINE;
input int                   InpPosVolHistoryWidth     = 2;
input bool                  InpShowNegVolHistory      = false;
input color                 InpNegVolHistoryColor     = clrTomato;
input ENUM_GB_HISTORY_STYLE InpNegVolHistoryStyle     = GB_HISTORY_LINE;
input int                   InpNegVolHistoryWidth     = 2;
input bool                  InpShowZeroGammaHistory   = false;
input color                 InpZeroGammaHistoryColor  = clrOrange;
input ENUM_GB_HISTORY_STYLE InpZeroGammaHistoryStyle  = GB_HISTORY_LINE;
input int                   InpZeroGammaHistoryWidth  = 2;

//--- Dashboard inputs.
input group "Dashboard"
input bool                  InpShowDashboardAtStart = true;
input ENUM_GB_DASH_POSITION InpDashboardPosition   = GB_DASH_TOP_LEFT;
input bool                  InpDashboardTransparent = false;
input int                   InpDashboardFontSize   = 9;

//--- One parsed strike and its prior values.
struct GBProfilePoint
  {
   double strike;
   double value;
   double prior1;
   double prior2;
   double prior3;
   double prior4;
   double prior5;
   int    prior_count;
  };

//--- One minute of locally collected Major history.
struct GBHistoryBucket
  {
   datetime minute_utc;
   double   pos_sum;
   double   neg_sum;
   double   zero_sum;
   int      pos_count;
   int      neg_count;
   int      zero_count;
  };

//--- Resolved display settings for one profile.
struct GBProfileStyle
  {
   bool                  show;
   string                prefix;
   string                title;
   ENUM_GB_PROFILE_ALIGN align;
   ENUM_GB_PROFILE_STYLE style;
   int                   origin_pct;
   int                   width_px;
   int                   thickness;
   int                   offset_px;
   color                 positive_color;
   color                 negative_color;
   bool                  log_scale;
   int                   top_n;
   int                   bottom_n;
   bool                  show_priors;
   int                   prior_size;
  };

//+------------------------------------------------------------------+
//| Profile snapshot class                                           |
//+------------------------------------------------------------------+
class CGBProfileData
  {
public:
   GBProfilePoint points[];
   double         max_abs;
   double         zero_gamma;
   double         major_pos;
   double         major_neg;
   double         major_pos_oi;
   double         major_neg_oi;
   double         major_long;
   double         major_short;
   double         net_vol;
   double         net_oi;
   double         max_prior_strike[5];
   double         max_prior_value[5];
   long           api_timestamp;
   datetime       last_success;
   int            last_http_status;
   string         last_error;
   bool           valid;

   /// Reset all profile fields and remove all strike rows.
   void Clear()
     {
      ArrayResize(points, 0);
      max_abs = 0.0;
      zero_gamma = 0.0;
      major_pos = 0.0;
      major_neg = 0.0;
      major_pos_oi = 0.0;
      major_neg_oi = 0.0;
      major_long = 0.0;
      major_short = 0.0;
      net_vol = 0.0;
      net_oi = 0.0;
      ArrayInitialize(max_prior_strike, 0.0);
      ArrayInitialize(max_prior_value, 0.0);
      api_timestamp = 0;
      last_success = 0;
      last_http_status = 0;
      last_error = "";
      valid = false;
     }
  };

//--- Global snapshots.
CGBProfileData g_classic_vol;
CGBProfileData g_classic_oi;
CGBProfileData g_state_gex;
CGBProfileData g_gamma;
CGBProfileData g_delta;
CGBProfileData g_vanna;
CGBProfileData g_charm;

//--- Runtime state.
GBHistoryBucket g_history[];
string           g_api_key = "";
string           g_ticker = "";
bool             g_show_dashboard = true;
bool             g_fetching = false;
int              g_next_source = 0;
ulong            g_last_attempt[GB_PROFILE_COUNT];
datetime         g_last_any_success = 0;
string           g_status = "Initializing";
int              g_status_http = 0;
double           g_conversion_multiplier = 1.0;
double           g_conversion_additive = 0.0;
bool             g_conversion_ready = true;
string           g_conversion_contract = "";
string           g_conversion_error = "";
ulong            g_conversion_last_attempt = 0;
bool             g_history_dirty = false;
string           g_history_session_key = "";
ulong            g_last_draw_tick = 0;

//+------------------------------------------------------------------+
//| General helpers                                                  |
//+------------------------------------------------------------------+

/// Clamp an integer to an inclusive range.
int GBClampInt(const int value,const int minimum,const int maximum)
  {
   return (int)MathMax(minimum, MathMin(maximum, value));
  }

/// Trim whitespace from both ends of a string.
string GBTrim(string value)
  {
   StringTrimLeft(value);
   StringTrimRight(value);
   return value;
  }

/// Return an uppercase copy of a string.
string GBUpper(string value)
  {
   StringToUpper(value);
   return value;
  }

/// Validate a source ticker or futures product.
bool GBValidSymbol(const string value,const int maximum_length)
  {
   int length = StringLen(value);
   if(length < 1 || length > maximum_length)
      return false;
   for(int index = 0; index < length; index++)
     {
      ushort character = (ushort)StringGetCharacter(value, index);
      bool letter = character >= 'A' && character <= 'Z';
      bool digit = character >= '0' && character <= '9';
      if(!letter && !digit && character != '_')
         return false;
     }
   return true;
  }

/// Return the timer age in milliseconds.
ulong GBAgeMilliseconds(const ulong timestamp)
  {
   ulong now = GetTickCount64();
   if(timestamp == 0 || now < timestamp)
      return ULONG_MAX;
   return now - timestamp;
  }

/// Return the route suffix for a Classic or State GEX expiry.
string GBDteRoute(const ENUM_GB_DTE dte)
  {
   if(dte == GB_DTE_ONE)
      return "gex_one";
   if(dte == GB_DTE_FULL)
      return "gex_full";
   return "gex_zero";
  }

/// Return the display label for a Classic or State GEX expiry.
string GBDteLabel(const ENUM_GB_DTE dte)
  {
   if(dte == GB_DTE_ONE)
      return "1DTE";
   if(dte == GB_DTE_FULL)
      return "Full";
   return "0DTE";
  }

/// Return the route suffix for a State Greek expiry.
string GBGreekDteRoute(const ENUM_GB_GREEK_DTE dte)
  {
   return dte == GB_GREEK_DTE_ONE ? "one" : "zero";
  }

/// Return the display label for a State Greek expiry.
string GBGreekDteLabel(const ENUM_GB_GREEK_DTE dte)
  {
   return dte == GB_GREEK_DTE_ONE ? "1DTE" : "0DTE";
  }

/// Return true when a Classic volume response is required.
bool GBNeedsClassicVol()
  {
   return InpShowClassicVol || InpShowZeroGamma || InpShowClassicPosVol ||
          InpShowClassicNegVol || g_show_dashboard || InpCollectMajorHistory ||
          InpShowPosVolHistory || InpShowNegVolHistory || InpShowZeroGammaHistory;
  }

/// Return true when a Classic OI response is required.
bool GBNeedsClassicOi()
  {
   return InpShowClassicOi || InpShowClassicPosOi || InpShowClassicNegOi || g_show_dashboard;
  }

/// Return true when a State GEX response is required.
bool GBNeedsStateGex()
  {
#ifdef GEXBOT_CLASSIC_COMPAT
   return InpShowStateGex || InpShowStatePosGex || InpShowStateNegGex;
#else
   return InpShowStateGex || InpShowStatePosGex || InpShowStateNegGex || g_show_dashboard;
#endif
  }

/// Return true when a State Gamma response is required.
bool GBNeedsGamma()
  {
#ifdef GEXBOT_CLASSIC_COMPAT
   return InpShowGamma || InpShowGammaLong || InpShowGammaShort;
#else
   return InpShowGamma || InpShowGammaLong || InpShowGammaShort || g_show_dashboard;
#endif
  }

/// Return true when a profile source is required.
bool GBSourceRequired(const ENUM_GB_PROFILE_ID profile_id)
  {
   switch(profile_id)
     {
      case GB_PROFILE_CLASSIC_VOL: return GBNeedsClassicVol();
      case GB_PROFILE_CLASSIC_OI:  return GBNeedsClassicOi();
      case GB_PROFILE_STATE_GEX:   return GBNeedsStateGex();
      case GB_PROFILE_GAMMA:       return GBNeedsGamma();
      case GB_PROFILE_DELTA:       return InpShowDelta;
      case GB_PROFILE_VANNA:       return InpShowVanna;
      case GB_PROFILE_CHARM:       return InpShowCharm;
     }
   return false;
  }

/// Resolve all drawing settings for one profile.
void GBGetProfileStyle(const ENUM_GB_PROFILE_ID profile_id,GBProfileStyle &result)
  {
   result.show = false;
   result.prefix = "GB_P_UNKNOWN_";
   result.title = "Unknown";
   result.align = GB_ALIGN_RIGHT;
   result.style = GB_STYLE_BAR;
   result.origin_pct = 50;
   result.width_px = 100;
   result.thickness = 2;
   result.offset_px = 0;
   result.positive_color = clrGreen;
   result.negative_color = clrRed;
   result.log_scale = false;
   result.top_n = 0;
   result.bottom_n = 0;
   result.show_priors = false;
   result.prior_size = InpDefaultPriorDotSize;

   switch(profile_id)
     {
      case GB_PROFILE_CLASSIC_VOL:
         result.show = InpShowClassicVol;
         result.prefix = "GB_P_CVOL_";
         result.title = "Classic Vol " + GBDteLabel(InpClassicVolDte);
         result.align = InpClassicVolAlign;
         result.style = InpClassicVolStyle;
         result.origin_pct = InpClassicVolOriginPct;
         result.width_px = InpClassicVolWidthPx;
         result.thickness = InpClassicVolThickness;
         result.offset_px = InpClassicVolOffsetPx;
         result.positive_color = InpClassicVolPosColor;
         result.negative_color = InpClassicVolNegColor;
         result.log_scale = InpClassicVolLogScale;
         result.top_n = InpClassicVolTopN;
         result.bottom_n = InpClassicVolBottomN;
         result.show_priors = InpClassicVolPriors;
         result.prior_size = InpClassicVolPriorSize;
         break;
      case GB_PROFILE_CLASSIC_OI:
         result.show = InpShowClassicOi;
         result.prefix = "GB_P_COI_";
         result.title = "Classic OI " + GBDteLabel(InpClassicOiDte);
         result.align = InpClassicOiAlign;
         result.style = InpClassicOiStyle;
         result.origin_pct = InpClassicOiOriginPct;
         result.width_px = InpClassicOiWidthPx;
         result.thickness = InpClassicOiThickness;
         result.offset_px = InpClassicOiOffsetPx;
         result.positive_color = InpClassicOiPosColor;
         result.negative_color = InpClassicOiNegColor;
         result.log_scale = InpClassicOiLogScale;
         result.top_n = InpClassicOiTopN;
         result.bottom_n = InpClassicOiBottomN;
         break;
      case GB_PROFILE_STATE_GEX:
         result.show = InpShowStateGex;
         result.prefix = "GB_P_SGEX_";
         result.title = "State GEX " + GBDteLabel(InpStateGexDte);
         result.align = InpStateGexAlign;
         result.style = InpStateGexStyle;
         result.origin_pct = InpStateGexOriginPct;
         result.width_px = InpStateGexWidthPx;
         result.thickness = InpStateGexThickness;
         result.offset_px = InpStateGexOffsetPx;
         result.positive_color = InpStateGexPosColor;
         result.negative_color = InpStateGexNegColor;
         result.log_scale = InpStateGexLogScale;
         result.top_n = InpStateGexTopN;
         result.bottom_n = InpStateGexBottomN;
         result.show_priors = InpStateGexPriors;
         result.prior_size = InpStateGexPriorSize;
         break;
      case GB_PROFILE_GAMMA:
         result.show = InpShowGamma;
         result.prefix = "GB_P_GAMMA_";
         result.title = "State Gamma " + GBGreekDteLabel(InpGammaDte);
         result.align = InpGammaAlign;
         result.style = InpGammaStyle;
         result.origin_pct = InpGammaOriginPct;
         result.width_px = InpGammaWidthPx;
         result.thickness = InpGammaThickness;
         result.offset_px = InpGammaOffsetPx;
         result.positive_color = InpGammaPosColor;
         result.negative_color = InpGammaNegColor;
         result.log_scale = InpGammaLogScale;
         result.top_n = InpGammaTopN;
         result.bottom_n = InpGammaBottomN;
         result.show_priors = InpGammaPriors;
         result.prior_size = InpGammaPriorSize;
         break;
      case GB_PROFILE_DELTA:
         result.show = InpShowDelta;
         result.prefix = "GB_P_DELTA_";
         result.title = "State Delta " + GBGreekDteLabel(InpDeltaDte);
         result.align = InpDeltaAlign;
         result.style = InpDeltaStyle;
         result.origin_pct = InpDeltaOriginPct;
         result.width_px = InpDeltaWidthPx;
         result.thickness = InpDeltaThickness;
         result.offset_px = InpDeltaOffsetPx;
         result.positive_color = InpDeltaPosColor;
         result.negative_color = InpDeltaNegColor;
         result.log_scale = InpDeltaLogScale;
         result.top_n = InpDeltaTopN;
         result.bottom_n = InpDeltaBottomN;
         result.show_priors = InpDeltaPriors;
         result.prior_size = InpDeltaPriorSize;
         break;
      case GB_PROFILE_VANNA:
         result.show = InpShowVanna;
         result.prefix = "GB_P_VANNA_";
         result.title = "State Vanna " + GBGreekDteLabel(InpVannaDte);
         result.align = InpVannaAlign;
         result.style = InpVannaStyle;
         result.origin_pct = InpVannaOriginPct;
         result.width_px = InpVannaWidthPx;
         result.thickness = InpVannaThickness;
         result.offset_px = InpVannaOffsetPx;
         result.positive_color = InpVannaPosColor;
         result.negative_color = InpVannaNegColor;
         result.log_scale = InpVannaLogScale;
         result.top_n = InpVannaTopN;
         result.bottom_n = InpVannaBottomN;
         result.show_priors = InpVannaPriors;
         result.prior_size = InpVannaPriorSize;
         break;
      case GB_PROFILE_CHARM:
         result.show = InpShowCharm;
         result.prefix = "GB_P_CHARM_";
         result.title = "State Charm " + GBGreekDteLabel(InpCharmDte);
         result.align = InpCharmAlign;
         result.style = InpCharmStyle;
         result.origin_pct = InpCharmOriginPct;
         result.width_px = InpCharmWidthPx;
         result.thickness = InpCharmThickness;
         result.offset_px = InpCharmOffsetPx;
         result.positive_color = InpCharmPosColor;
         result.negative_color = InpCharmNegColor;
         result.log_scale = InpCharmLogScale;
         result.top_n = InpCharmTopN;
         result.bottom_n = InpCharmBottomN;
         result.show_priors = InpCharmPriors;
         result.prior_size = InpCharmPriorSize;
         break;
     }

   result.origin_pct = GBClampInt(result.origin_pct, 0, 100);
   result.width_px = GBClampInt(result.width_px, 1, 4000);
   result.thickness = GBClampInt(result.thickness, 1, 20);
   result.offset_px = GBClampInt(result.offset_px, -5000, 5000);
   result.top_n = MathMax(0, result.top_n);
   result.bottom_n = MathMax(0, result.bottom_n);
   result.prior_size = GBClampInt(result.prior_size, 1, 12);
  }

/// Return one configured prior color for a profile.
color GBPriorColor(const ENUM_GB_PROFILE_ID profile_id,const int prior_index)
  {
   if(profile_id == GB_PROFILE_CLASSIC_VOL)
     {
      if(prior_index == 0) return InpClassicVolPrior1;
      if(prior_index == 1) return InpClassicVolPrior5;
      if(prior_index == 2) return InpClassicVolPrior10;
      if(prior_index == 3) return InpClassicVolPrior15;
      return InpClassicVolPrior30;
     }
   if(profile_id == GB_PROFILE_STATE_GEX)
     {
      if(prior_index == 0) return InpStateGexPrior1;
      if(prior_index == 1) return InpStateGexPrior5;
      if(prior_index == 2) return InpStateGexPrior10;
      if(prior_index == 3) return InpStateGexPrior15;
      return InpStateGexPrior30;
     }
   if(prior_index == 0) return InpGreekPrior5Color;
   if(prior_index == 1) return InpGreekPrior15Color;
   return InpGreekPrior30Color;
  }

/// Return one prior value from a profile point.
double GBPriorValue(const GBProfilePoint &point,const int prior_index)
  {
   if(prior_index == 0) return point.prior1;
   if(prior_index == 1) return point.prior2;
   if(prior_index == 2) return point.prior3;
   if(prior_index == 3) return point.prior4;
   return point.prior5;
  }

//+------------------------------------------------------------------+
//| Validated JSON reader                                            |
//+------------------------------------------------------------------+

/// Return true when one character is JSON whitespace.
bool GBJsonWhitespace(const ushort character)
  {
   return character == ' ' || character == '\t' || character == '\r' || character == '\n';
  }

/// Skip JSON whitespace and return the next position.
int GBJsonSkipWhitespace(const string &json,int position)
  {
   int length = StringLen(json);
   while(position < length && GBJsonWhitespace((ushort)StringGetCharacter(json, position)))
      position++;
   return position;
  }

/// Convert one hexadecimal JSON character to its numeric value.
int GBJsonHexValue(const ushort character)
  {
   if(character >= '0' && character <= '9') return character - '0';
   if(character >= 'a' && character <= 'f') return 10 + character - 'a';
   if(character >= 'A' && character <= 'F') return 10 + character - 'A';
   return -1;
  }

/// Read and decode one JSON string token.
bool GBJsonReadString(const string &json,const int start,string &value,int &next_position)
  {
   int length = StringLen(json);
   if(start < 0 || start >= length || StringGetCharacter(json, start) != '"')
      return false;

   value = "";
   bool escaped = false;
   for(int position = start + 1; position < length; position++)
     {
      ushort character = (ushort)StringGetCharacter(json, position);
      if(escaped)
        {
         if(character == '"' || character == '\\' || character == '/')
            value += ShortToString(character);
         else if(character == 'b')
            value += ShortToString(8);
         else if(character == 'f')
            value += ShortToString(12);
         else if(character == 'n')
            value += "\n";
         else if(character == 'r')
            value += "\r";
         else if(character == 't')
            value += "\t";
         else if(character == 'u')
           {
            if(position + 4 >= length)
               return false;
            int code = 0;
            for(int hex_index = 1; hex_index <= 4; hex_index++)
              {
               int hex_value = GBJsonHexValue((ushort)StringGetCharacter(json, position + hex_index));
               if(hex_value < 0)
                  return false;
               code = code * 16 + hex_value;
              }
            value += ShortToString((ushort)code);
            position += 4;
           }
         else
            return false;
         escaped = false;
         continue;
        }
      if(character == '\\')
        {
         escaped = true;
         continue;
        }
      if(character == '"')
        {
         next_position = position + 1;
         return true;
        }
      if(character < 0x20)
         return false;
      value += ShortToString(character);
     }
   return false;
  }

/// Skip one complete JSON value and return its first position after the value.
bool GBJsonSkipValue(const string &json,const int start,int &end_position)
  {
   int length = StringLen(json);
   int position = GBJsonSkipWhitespace(json, start);
   if(position >= length)
      return false;

   ushort first = (ushort)StringGetCharacter(json, position);
   if(first == '"')
     {
      string ignored;
      return GBJsonReadString(json, position, ignored, end_position);
     }

   if(first == '{' || first == '[')
     {
      ushort delimiters[];
      bool in_string = false;
      bool escaped = false;
      for(; position < length; position++)
        {
         ushort character = (ushort)StringGetCharacter(json, position);
         if(in_string)
           {
            if(escaped)
               escaped = false;
            else if(character == '\\')
               escaped = true;
            else if(character == '"')
               in_string = false;
            continue;
           }
         if(character == '"')
           {
            in_string = true;
            continue;
           }
         if(character == '{' || character == '[')
           {
            int depth = ArraySize(delimiters);
            ArrayResize(delimiters, depth + 1);
            delimiters[depth] = character;
            continue;
           }
         if(character == '}' || character == ']')
           {
            int depth = ArraySize(delimiters);
            if(depth == 0)
               return false;
            ushort open_character = delimiters[depth - 1];
            if((character == '}' && open_character != '{') || (character == ']' && open_character != '['))
               return false;
            ArrayResize(delimiters, depth - 1);
            if(ArraySize(delimiters) == 0)
              {
               end_position = position + 1;
               return true;
              }
           }
        }
      return false;
     }

   int token_start = position;
   while(position < length)
     {
      ushort character = (ushort)StringGetCharacter(json, position);
      if(character == ',' || character == ']' || character == '}' || GBJsonWhitespace(character))
         break;
      position++;
     }
   if(position <= token_start)
      return false;
   end_position = position;
   return true;
  }

/// Validate one JSON value and advance its cursor.
bool GBJsonValidateValue(const string &json,int &cursor,const int depth)
  {
   if(depth > 64)
      return false;
   int length = StringLen(json);
   cursor = GBJsonSkipWhitespace(json, cursor);
   if(cursor >= length)
      return false;
   ushort first = (ushort)StringGetCharacter(json, cursor);

   if(first == '"')
     {
      string ignored;
      int next_position = 0;
      if(!GBJsonReadString(json, cursor, ignored, next_position))
         return false;
      cursor = next_position;
      return true;
     }

   if(first == '{')
     {
      cursor = GBJsonSkipWhitespace(json, cursor + 1);
      if(cursor < length && StringGetCharacter(json, cursor) == '}')
        {
         cursor++;
         return true;
        }
      while(cursor < length)
        {
         string key;
         int after_key = 0;
         if(!GBJsonReadString(json, cursor, key, after_key))
            return false;
         cursor = GBJsonSkipWhitespace(json, after_key);
         if(cursor >= length || StringGetCharacter(json, cursor) != ':')
            return false;
         cursor++;
         if(!GBJsonValidateValue(json, cursor, depth + 1))
            return false;
         cursor = GBJsonSkipWhitespace(json, cursor);
         if(cursor < length && StringGetCharacter(json, cursor) == '}')
           {
            cursor++;
            return true;
           }
         if(cursor >= length || StringGetCharacter(json, cursor) != ',')
            return false;
         cursor = GBJsonSkipWhitespace(json, cursor + 1);
        }
      return false;
     }

   if(first == '[')
     {
      cursor = GBJsonSkipWhitespace(json, cursor + 1);
      if(cursor < length && StringGetCharacter(json, cursor) == ']')
        {
         cursor++;
         return true;
        }
      while(cursor < length)
        {
         if(!GBJsonValidateValue(json, cursor, depth + 1))
            return false;
         cursor = GBJsonSkipWhitespace(json, cursor);
         if(cursor < length && StringGetCharacter(json, cursor) == ']')
           {
            cursor++;
            return true;
           }
         if(cursor >= length || StringGetCharacter(json, cursor) != ',')
            return false;
         cursor = GBJsonSkipWhitespace(json, cursor + 1);
        }
      return false;
     }

   if(StringSubstr(json, cursor, 4) == "true" || StringSubstr(json, cursor, 4) == "null")
     {
      cursor += 4;
      return true;
     }
   if(StringSubstr(json, cursor, 5) == "false")
     {
      cursor += 5;
      return true;
     }

   int number_end = cursor;
   while(number_end < length)
     {
      ushort character = (ushort)StringGetCharacter(json, number_end);
      if(character == ',' || character == ']' || character == '}' || GBJsonWhitespace(character))
         break;
      number_end++;
     }
   double ignored_number = 0.0;
   if(!GBJsonParseNumberToken(json, cursor, number_end, ignored_number))
      return false;
   cursor = number_end;
   return true;
  }

/// Return true when text contains exactly one complete JSON object.
bool GBJsonRootObjectValid(const string &json)
  {
   int cursor = GBJsonSkipWhitespace(json, 0);
   if(cursor >= StringLen(json) || StringGetCharacter(json, cursor) != '{')
      return false;
   if(!GBJsonValidateValue(json, cursor, 0))
      return false;
   return GBJsonSkipWhitespace(json, cursor) == StringLen(json);
  }

/// Find one top-level member value in a JSON object.
bool GBJsonFindMember(const string &json,const string member,int &value_start,int &value_end)
  {
   int length = StringLen(json);
   int position = GBJsonSkipWhitespace(json, 0);
   if(position >= length || StringGetCharacter(json, position) != '{')
      return false;
   position++;

   while(position < length)
     {
      position = GBJsonSkipWhitespace(json, position);
      if(position < length && StringGetCharacter(json, position) == '}')
         return false;
      string key;
      int after_key = 0;
      if(!GBJsonReadString(json, position, key, after_key))
         return false;
      position = GBJsonSkipWhitespace(json, after_key);
      if(position >= length || StringGetCharacter(json, position) != ':')
         return false;
      position = GBJsonSkipWhitespace(json, position + 1);
      int after_value = 0;
      if(!GBJsonSkipValue(json, position, after_value))
         return false;
      if(key == member)
        {
         value_start = position;
         value_end = after_value;
         return true;
        }
      position = GBJsonSkipWhitespace(json, after_value);
      if(position < length && StringGetCharacter(json, position) == ',')
        {
         position++;
         continue;
        }
      if(position < length && StringGetCharacter(json, position) == '}')
         return false;
      return false;
     }
   return false;
  }

/// Parse a strict JSON number token.
bool GBJsonParseNumberToken(const string &json,const int start,const int end,double &value)
  {
   int position = GBJsonSkipWhitespace(json, start);
   int finish = end;
   while(finish > position && GBJsonWhitespace((ushort)StringGetCharacter(json, finish - 1)))
      finish--;
   if(position >= finish)
      return false;

   int cursor = position;
   if(StringGetCharacter(json, cursor) == '-')
      cursor++;
   if(cursor >= finish)
      return false;

   ushort first_digit = (ushort)StringGetCharacter(json, cursor);
   if(first_digit == '0')
      cursor++;
   else
     {
      if(first_digit < '1' || first_digit > '9')
         return false;
      while(cursor < finish)
        {
         ushort digit = (ushort)StringGetCharacter(json, cursor);
         if(digit < '0' || digit > '9')
            break;
         cursor++;
        }
     }

   if(cursor < finish && StringGetCharacter(json, cursor) == '.')
     {
      cursor++;
      int fraction_start = cursor;
      while(cursor < finish)
        {
         ushort digit = (ushort)StringGetCharacter(json, cursor);
         if(digit < '0' || digit > '9')
            break;
         cursor++;
        }
      if(cursor == fraction_start)
         return false;
     }

   if(cursor < finish && (StringGetCharacter(json, cursor) == 'e' || StringGetCharacter(json, cursor) == 'E'))
     {
      cursor++;
      if(cursor < finish && (StringGetCharacter(json, cursor) == '+' || StringGetCharacter(json, cursor) == '-'))
         cursor++;
      int exponent_start = cursor;
      while(cursor < finish)
        {
         ushort digit = (ushort)StringGetCharacter(json, cursor);
         if(digit < '0' || digit > '9')
            break;
         cursor++;
        }
      if(cursor == exponent_start)
         return false;
     }

   if(cursor != finish)
      return false;
   value = StringToDouble(StringSubstr(json, position, finish - position));
   return MathIsValidNumber(value);
  }

/// Read a required top-level number.
bool GBJsonNumber(const string &json,const string member,double &value)
  {
   int start = 0;
   int end = 0;
   if(!GBJsonFindMember(json, member, start, end))
      return false;
   return GBJsonParseNumberToken(json, start, end, value);
  }

/// Read an optional top-level number and use zero when it is absent.
void GBJsonOptionalNumber(const string &json,const string member,double &value)
  {
   value = 0.0;
   double parsed = 0.0;
   if(GBJsonNumber(json, member, parsed))
      value = parsed;
  }

/// Read an optional top-level string.
string GBJsonOptionalString(const string &json,const string member)
  {
   int start = 0;
   int end = 0;
   string value = "";
   int next_position = 0;
   if(!GBJsonFindMember(json, member, start, end))
      return value;
   if(!GBJsonReadString(json, start, value, next_position))
      return "";
   return value;
  }

/// Read the bounds of a required top-level array.
bool GBJsonArrayBounds(const string &json,const string member,int &array_start,int &array_end)
  {
   int start = 0;
   int end = 0;
   if(!GBJsonFindMember(json, member, start, end))
      return false;
   start = GBJsonSkipWhitespace(json, start);
   if(start >= end || StringGetCharacter(json, start) != '[' || StringGetCharacter(json, end - 1) != ']')
      return false;
   array_start = start;
   array_end = end;
   return true;
  }

/// Read the next direct value from an array.
bool GBJsonArrayNext(const string &json,const int array_end,int &cursor,int &value_start,int &value_end)
  {
   cursor = GBJsonSkipWhitespace(json, cursor);
   if(cursor >= array_end - 1 || StringGetCharacter(json, cursor) == ']')
      return false;
   if(StringGetCharacter(json, cursor) == ',')
      cursor = GBJsonSkipWhitespace(json, cursor + 1);
   if(cursor >= array_end - 1 || StringGetCharacter(json, cursor) == ']')
      return false;
   value_start = cursor;
   if(!GBJsonSkipValue(json, value_start, value_end) || value_end > array_end)
      return false;
   cursor = value_end;
   return true;
  }

/// Read one indexed number from a JSON row array.
bool GBJsonRowNumber(const string &json,const int row_start,const int row_end,const int requested_index,double &value)
  {
   if(row_start >= row_end || StringGetCharacter(json, row_start) != '[')
      return false;
   int cursor = row_start + 1;
   int item_start = 0;
   int item_end = 0;
   int index = 0;
   while(GBJsonArrayNext(json, row_end, cursor, item_start, item_end))
     {
      if(index == requested_index)
         return GBJsonParseNumberToken(json, item_start, item_end, value);
      index++;
     }
   return false;
  }

/// Read up to five numbers from one nested array in a JSON row.
int GBJsonRowPriorValues(const string &json,const int row_start,const int row_end,const int requested_index,double &p1,double &p2,double &p3,double &p4,double &p5)
  {
   p1 = 0.0;
   p2 = 0.0;
   p3 = 0.0;
   p4 = 0.0;
   p5 = 0.0;
   int cursor = row_start + 1;
   int item_start = 0;
   int item_end = 0;
   int index = 0;
   while(GBJsonArrayNext(json, row_end, cursor, item_start, item_end))
     {
      if(index == requested_index)
        {
         if(StringGetCharacter(json, item_start) != '[')
            return 0;
         int prior_cursor = item_start + 1;
         int prior_start = 0;
         int prior_end = 0;
         int count = 0;
         while(count < 5 && GBJsonArrayNext(json, item_end, prior_cursor, prior_start, prior_end))
           {
            double prior = 0.0;
            if(!GBJsonParseNumberToken(json, prior_start, prior_end, prior))
               return 0;
            if(count == 0) p1 = prior;
            else if(count == 1) p2 = prior;
            else if(count == 2) p3 = prior;
            else if(count == 3) p4 = prior;
            else p5 = prior;
            count++;
           }
         return count;
        }
      index++;
     }
   return 0;
  }

/// Return an API error message from a JSON response when available.
string GBJsonApiError(const string &json)
  {
   string error = GBJsonOptionalString(json, "error");
   if(error != "")
      return error;
   return GBJsonOptionalString(json, "message");
  }

//+------------------------------------------------------------------+
//| Parsing and HTTP                                                 |
//+------------------------------------------------------------------+

/// Load the API key from the configured input or optional key file.
bool GBLoadApiKey(string &error)
  {
   if(GBTrim(InpApiKeyFile) != "")
     {
      int handle = FileOpen(GBTrim(InpApiKeyFile), FILE_READ | FILE_TXT | FILE_ANSI);
      if(handle == INVALID_HANDLE)
        {
         error = "Cannot read API key file: " + GBTrim(InpApiKeyFile);
         return false;
        }
      string value = "";
      if(!FileIsEnding(handle))
         value = GBTrim(FileReadString(handle));
      FileClose(handle);
      if(value == "")
        {
         error = "API key file is empty";
         return false;
        }
      g_api_key = value;
      return true;
     }

   g_api_key = GBTrim(InpApiKey);
   if(g_api_key == "" || g_api_key == "TU_API_KEY_AQUI" || g_api_key == "<API KEY HERE>")
     {
      error = "API key is required";
      return false;
     }
   return true;
  }

/// Build the standard headers for the public version 2 API.
string GBApiHeaders()
  {
   return "Authorization: Bearer " + g_api_key + "\r\n" +
          "User-Agent: MetaTrader 5/Gexbot " + GB_VERSION + "\r\n" +
          "X-gexbot-plugin: " + GB_VERSION + "\r\n" +
          "Accept: application/json\r\n" +
          "Cache-Control: no-cache\r\n";
  }

/// Send one HTTP GET request and return its body and status.
bool GBHttpGet(const string url,string &body,int &status,string &error)
  {
   char request_body[];
   char response[];
   string response_headers = "";
   ResetLastError();
   status = WebRequest("GET", url, GBApiHeaders(), InpWebRequestTimeoutMs, request_body, response, response_headers);
   if(status == -1)
     {
      error = "WebRequest failed with MetaTrader error " + IntegerToString(GetLastError());
      body = "";
      return false;
     }
   body = CharArrayToString(response);
   if(StringLen(body) > GB_MAX_RESPONSE_CHARS)
     {
      error = "HTTP response exceeds the 5,000,000-character safety limit";
      return false;
     }
   if(status < 200 || status >= 300)
     {
      string api_error = GBJsonApiError(body);
      error = "HTTP " + IntegerToString(status) + (api_error == "" ? "" : ": " + api_error);
      return false;
     }
   return true;
  }

/// Parse a GEX response into a temporary profile snapshot.
bool GBParseGexResponse(const string &json,const int value_index,const bool include_priors,CGBProfileData &target,string &error)
  {
   if(!GBJsonRootObjectValid(json))
     {
      error = "Response is not one complete JSON object";
      return false;
     }
   int array_start = 0;
   int array_end = 0;
   double timestamp = 0.0;
   if(!GBJsonNumber(json, "timestamp", timestamp))
     {
      error = "Response has no valid timestamp";
      return false;
     }
   if(!GBJsonArrayBounds(json, "strikes", array_start, array_end))
     {
      error = "Response has no valid strikes array";
      return false;
     }

   GBProfilePoint parsed[];
   int cursor = array_start + 1;
   int row_start = 0;
   int row_end = 0;
   double maximum = 0.0;
   while(GBJsonArrayNext(json, array_end, cursor, row_start, row_end))
     {
      if(StringGetCharacter(json, row_start) != '[')
         continue;
      double strike = 0.0;
      double value = 0.0;
      if(!GBJsonRowNumber(json, row_start, row_end, 0, strike) ||
         !GBJsonRowNumber(json, row_start, row_end, value_index, value))
        {
         error = "Response contains an invalid strike row";
         return false;
        }
      int size = ArraySize(parsed);
      if(size >= GB_MAX_PROFILE_ROWS)
        {
         error = "Response exceeds the 2,000-row profile safety limit";
         return false;
        }
      ArrayResize(parsed, size + 1);
      parsed[size].strike = strike;
      parsed[size].value = value;
      parsed[size].prior1 = 0.0;
      parsed[size].prior2 = 0.0;
      parsed[size].prior3 = 0.0;
      parsed[size].prior4 = 0.0;
      parsed[size].prior5 = 0.0;
      parsed[size].prior_count = 0;
      if(include_priors)
        {
         parsed[size].prior_count = GBJsonRowPriorValues(json, row_start, row_end, 3,
                                                        parsed[size].prior1, parsed[size].prior2,
                                                        parsed[size].prior3, parsed[size].prior4,
                                                        parsed[size].prior5);
        }
      maximum = MathMax(maximum, MathAbs(value));
      for(int prior_index = 0; prior_index < parsed[size].prior_count; prior_index++)
         maximum = MathMax(maximum, MathAbs(GBPriorValue(parsed[size], prior_index)));
     }

   if(ArraySize(parsed) == 0)
     {
      error = "Response contains no strike rows";
      return false;
     }

   ArrayCopy(target.points, parsed);
   target.max_abs = maximum;
   target.api_timestamp = (long)timestamp;
   GBJsonOptionalNumber(json, "zero_gamma", target.zero_gamma);
   GBJsonOptionalNumber(json, "major_pos_vol", target.major_pos);
   GBJsonOptionalNumber(json, "major_neg_vol", target.major_neg);
   GBJsonOptionalNumber(json, "major_pos_oi", target.major_pos_oi);
   GBJsonOptionalNumber(json, "major_neg_oi", target.major_neg_oi);
   GBJsonOptionalNumber(json, "sum_gex_vol", target.net_vol);
   GBJsonOptionalNumber(json, "sum_gex_oi", target.net_oi);
   target.major_long = 0.0;
   target.major_short = 0.0;
   ArrayInitialize(target.max_prior_strike, 0.0);
   ArrayInitialize(target.max_prior_value, 0.0);

   int priors_start = 0;
   int priors_end = 0;
   if(GBJsonArrayBounds(json, "max_priors", priors_start, priors_end))
     {
      int prior_cursor = priors_start + 1;
      int prior_row_start = 0;
      int prior_row_end = 0;
      int prior_number = 0;
      while(prior_number < 5 && GBJsonArrayNext(json, priors_end, prior_cursor, prior_row_start, prior_row_end))
        {
         double prior_strike = 0.0;
         double prior_value = 0.0;
         if(GBJsonRowNumber(json, prior_row_start, prior_row_end, 0, prior_strike) &&
            GBJsonRowNumber(json, prior_row_start, prior_row_end, 1, prior_value))
           {
            target.max_prior_strike[prior_number] = prior_strike;
            target.max_prior_value[prior_number] = prior_value;
           }
         prior_number++;
        }
     }

   target.valid = true;
   target.last_success = TimeCurrent();
   target.last_error = "";
   target.last_http_status = 200;
   return true;
  }

/// Parse a State Greek response into a temporary profile snapshot.
bool GBParseGreekResponse(const string &json,CGBProfileData &target,string &error)
  {
   if(!GBJsonRootObjectValid(json))
     {
      error = "Response is not one complete JSON object";
      return false;
     }
   int array_start = 0;
   int array_end = 0;
   double timestamp = 0.0;
   if(!GBJsonNumber(json, "timestamp", timestamp))
     {
      error = "Response has no valid timestamp";
      return false;
     }
   if(!GBJsonArrayBounds(json, "mini_contracts", array_start, array_end))
     {
      error = "Response has no valid mini_contracts array";
      return false;
     }

   GBProfilePoint parsed[];
   int cursor = array_start + 1;
   int row_start = 0;
   int row_end = 0;
   double maximum = 0.0;
   while(GBJsonArrayNext(json, array_end, cursor, row_start, row_end))
     {
      if(StringGetCharacter(json, row_start) != '[')
         continue;
      double strike = 0.0;
      double value = 0.0;
      if(!GBJsonRowNumber(json, row_start, row_end, 0, strike) ||
         !GBJsonRowNumber(json, row_start, row_end, 3, value))
        {
         error = "Response contains an invalid mini_contract row";
         return false;
        }
      int size = ArraySize(parsed);
      if(size >= GB_MAX_PROFILE_ROWS)
        {
         error = "Response exceeds the 2,000-row profile safety limit";
         return false;
        }
      ArrayResize(parsed, size + 1);
      parsed[size].strike = strike;
      parsed[size].value = value;
      parsed[size].prior1 = 0.0;
      parsed[size].prior2 = 0.0;
      parsed[size].prior3 = 0.0;
      parsed[size].prior4 = 0.0;
      parsed[size].prior5 = 0.0;
      parsed[size].prior_count = GBJsonRowPriorValues(json, row_start, row_end, 4,
                                                     parsed[size].prior1, parsed[size].prior2,
                                                     parsed[size].prior3, parsed[size].prior4,
                                                     parsed[size].prior5);
      maximum = MathMax(maximum, MathAbs(value));
      for(int prior_index = 0; prior_index < parsed[size].prior_count; prior_index++)
         maximum = MathMax(maximum, MathAbs(GBPriorValue(parsed[size], prior_index)));
     }

   if(ArraySize(parsed) == 0)
     {
      error = "Response contains no mini-contract rows";
      return false;
     }

   ArrayCopy(target.points, parsed);
   target.max_abs = maximum;
   target.api_timestamp = (long)timestamp;
   target.zero_gamma = 0.0;
   target.major_pos_oi = 0.0;
   target.major_neg_oi = 0.0;
   target.net_vol = 0.0;
   target.net_oi = 0.0;
   GBJsonOptionalNumber(json, "major_positive", target.major_pos);
   GBJsonOptionalNumber(json, "major_negative", target.major_neg);
   GBJsonOptionalNumber(json, "major_long_gamma", target.major_long);
   GBJsonOptionalNumber(json, "major_short_gamma", target.major_short);
   ArrayInitialize(target.max_prior_strike, 0.0);
   ArrayInitialize(target.max_prior_value, 0.0);
   target.valid = true;
   target.last_success = TimeCurrent();
   target.last_error = "";
   target.last_http_status = 200;
   return true;
  }

/// Apply one failed request status without deleting the last valid snapshot.
void GBRecordFailure(CGBProfileData &target,const int status,const string error)
  {
   target.last_http_status = status;
   target.last_error = error;
   g_status_http = status;
   g_status = error;
   Print("Gexbot MT5: ", error);
  }

/// Fetch and parse one Classic GEX response for one or both Classic profiles.
bool GBFetchClassic(const ENUM_GB_DTE dte,const bool update_volume,const bool update_oi)
  {
   string url = GB_API_BASE + "/" + g_ticker + "/classic/" + GBDteRoute(dte);
   string body = "";
   string error = "";
   int status = 0;
   if(!GBHttpGet(url, body, status, error))
     {
      if(update_volume) GBRecordFailure(g_classic_vol, status, "Classic volume: " + error);
      if(update_oi) GBRecordFailure(g_classic_oi, status, "Classic OI: " + error);
      return false;
     }

   bool success = true;
   if(update_volume)
     {
      string parse_error = "";
      if(!GBParseGexResponse(body, 1, true, g_classic_vol, parse_error))
        {
         GBRecordFailure(g_classic_vol, status, "Classic volume parse error: " + parse_error);
         success = false;
        }
     }
   if(update_oi)
     {
      string parse_error = "";
      if(!GBParseGexResponse(body, 2, false, g_classic_oi, parse_error))
        {
         GBRecordFailure(g_classic_oi, status, "Classic OI parse error: " + parse_error);
         success = false;
        }
     }
   if(success)
     {
      g_last_any_success = TimeCurrent();
      g_status_http = status;
      g_status = "Classic data updated";
      if(update_volume)
         GBAppendMajorHistory(g_classic_vol);
     }
   return success;
  }

/// Fetch and parse the State GEX response.
bool GBFetchStateGex()
  {
   string url = GB_API_BASE + "/" + g_ticker + "/state/" + GBDteRoute(InpStateGexDte);
   string body = "";
   string error = "";
   int status = 0;
   if(!GBHttpGet(url, body, status, error))
     {
      GBRecordFailure(g_state_gex, status, "State GEX: " + error);
      return false;
     }
   if(!GBParseGexResponse(body, 1, true, g_state_gex, error))
     {
      GBRecordFailure(g_state_gex, status, "State GEX parse error: " + error);
      return false;
     }
   g_last_any_success = TimeCurrent();
   g_status_http = status;
   g_status = "State GEX updated";
   return true;
  }

/// Return the Greek route and expiry for a profile.
string GBGreekRoute(const ENUM_GB_PROFILE_ID profile_id)
  {
   if(profile_id == GB_PROFILE_DELTA)
      return "delta_" + GBGreekDteRoute(InpDeltaDte);
   if(profile_id == GB_PROFILE_VANNA)
      return "vanna_" + GBGreekDteRoute(InpVannaDte);
   if(profile_id == GB_PROFILE_CHARM)
      return "charm_" + GBGreekDteRoute(InpCharmDte);
   return "gamma_" + GBGreekDteRoute(InpGammaDte);
  }

/// Fetch and parse one State Greek response into the specified snapshot.
bool GBFetchGreekTarget(const ENUM_GB_PROFILE_ID profile_id,CGBProfileData &target)
  {
   string route = GBGreekRoute(profile_id);
   string url = GB_API_BASE + "/" + g_ticker + "/state/" + route;
   string body = "";
   string error = "";
   int status = 0;
   if(!GBHttpGet(url, body, status, error))
     {
      GBRecordFailure(target, status, route + ": " + error);
      return false;
     }
   if(!GBParseGreekResponse(body, target, error))
     {
      GBRecordFailure(target, status, route + " parse error: " + error);
      return false;
     }
   g_last_any_success = TimeCurrent();
   g_status_http = status;
   g_status = route + " updated";
   return true;
  }

/// Select the target snapshot and fetch one State Greek response.
bool GBFetchGreek(const ENUM_GB_PROFILE_ID profile_id)
  {
   if(profile_id == GB_PROFILE_DELTA)
      return GBFetchGreekTarget(profile_id, g_delta);
   if(profile_id == GB_PROFILE_VANNA)
      return GBFetchGreekTarget(profile_id, g_vanna);
   if(profile_id == GB_PROFILE_CHARM)
      return GBFetchGreekTarget(profile_id, g_charm);
   return GBFetchGreekTarget(GB_PROFILE_GAMMA, g_gamma);
  }

/// Return the automatic futures conversion model for one pair.
string GBConversionModel()
  {
   string target = GBUpper(GBTrim(InpFuturesTarget));
   if((g_ticker == "SPX" && target == "ES") || (g_ticker == "NDX" && target == "NQ"))
      return "additive";
   return "affine";
  }

/// Fetch automatic futures conversion coefficients.
bool GBFetchConversion()
  {
   g_conversion_last_attempt = GetTickCount64();
   string target = GBUpper(GBTrim(InpFuturesTarget));
   if(!GBValidSymbol(target, 8))
     {
      g_conversion_ready = false;
      g_conversion_error = "A valid futures target is required";
      return false;
     }
   string url = GB_API_BASE + "/futures/conversion?ticker=" + g_ticker +
                "&future=" + target + "&model=" + GBConversionModel();
   string body = "";
   string error = "";
   int status = 0;
   if(!GBHttpGet(url, body, status, error))
     {
      g_conversion_ready = false;
      g_conversion_error = "Futures conversion: " + error;
      g_status = g_conversion_error;
      return false;
     }
   double multiplier = 0.0;
   double additive = 0.0;
   if(!GBJsonRootObjectValid(body) || !GBJsonNumber(body, "multiplier", multiplier) ||
      !GBJsonNumber(body, "additive", additive) || multiplier <= 0.0)
     {
      g_conversion_ready = false;
      g_conversion_error = "Futures conversion returned invalid coefficients";
      g_status = g_conversion_error;
      return false;
     }
   g_conversion_multiplier = multiplier;
   g_conversion_additive = additive;
   g_conversion_contract = GBJsonOptionalString(body, "future_contract");
   g_conversion_error = "";
   g_conversion_ready = true;
   g_status = "Futures conversion updated";
   return true;
  }

/// Configure conversion state from the selected mode.
bool GBInitializeConversion(string &error)
  {
   g_conversion_multiplier = 1.0;
   g_conversion_additive = 0.0;
   g_conversion_ready = true;
   g_conversion_error = "";
   g_conversion_contract = "";

   if(InpConversionMode == GB_CONVERSION_MANUAL)
     {
      if(InpManualMultiplier <= 0.0 || !MathIsValidNumber(InpManualMultiplier) || !MathIsValidNumber(InpManualAdditive))
        {
         error = "Manual futures conversion values are invalid";
         return false;
        }
      g_conversion_multiplier = InpManualMultiplier;
      g_conversion_additive = InpManualAdditive;
      return true;
     }
   if(InpConversionMode == GB_CONVERSION_AUTO)
     {
      g_conversion_ready = false;
      return GBFetchConversion();
     }
   return true;
  }

/// Convert one source price to the configured chart scale.
double GBConvertPrice(const double source_price)
  {
   return source_price * g_conversion_multiplier + g_conversion_additive;
  }

/// Format one optional source price for dashboard output.
string GBFormatPrice(const double source_price)
  {
   if(source_price <= 0.0 || !g_conversion_ready)
      return "—";
   return DoubleToString(GBConvertPrice(source_price), 2);
  }

//+------------------------------------------------------------------+
//| New York session helpers                                         |
//+------------------------------------------------------------------+

/// Return the number of days in a Gregorian month.
int GBDaysInMonth(const int year,const int month)
  {
   if(month == 2)
     {
      bool leap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
      return leap ? 29 : 28;
     }
   if(month == 4 || month == 6 || month == 9 || month == 11)
      return 30;
   return 31;
  }

/// Return the day number of the requested Sunday in a month.
int GBNthSunday(const int year,const int month,const int occurrence)
  {
   MqlDateTime value;
   ZeroMemory(value);
   value.year = year;
   value.mon = month;
   value.day = 1;
   datetime first = StructToTime(value);
   TimeToStruct(first, value);
   int first_sunday = 1 + ((7 - value.day_of_week) % 7);
   return first_sunday + (occurrence - 1) * 7;
  }

/// Return true when a UTC time is in New York daylight-saving time.
bool GBIsNewYorkDst(const datetime utc_time)
  {
   MqlDateTime utc;
   TimeToStruct(utc_time, utc);
   int march_sunday = GBNthSunday(utc.year, 3, 2);
   int november_sunday = GBNthSunday(utc.year, 11, 1);

   MqlDateTime transition;
   ZeroMemory(transition);
   transition.year = utc.year;
   transition.mon = 3;
   transition.day = march_sunday;
   transition.hour = 7;
   datetime start_utc = StructToTime(transition);
   transition.mon = 11;
   transition.day = november_sunday;
   transition.hour = 6;
   datetime end_utc = StructToTime(transition);
   return utc_time >= start_utc && utc_time < end_utc;
  }

/// Convert a UTC time to New York local time.
datetime GBUtcToNewYork(const datetime utc_time)
  {
   return utc_time + (GBIsNewYorkDst(utc_time) ? -4 * 3600 : -5 * 3600);
  }

/// Return true when a UTC time is inside the configured New York session.
bool GBWithinMarketHours(const datetime utc_time)
  {
   MqlDateTime local;
   TimeToStruct(GBUtcToNewYork(utc_time), local);
   if(local.day_of_week == 0 || local.day_of_week == 6)
      return false;
   int minute = local.hour * 60 + local.min;
   int open_minute = InpMarketOpenHour * 60 + InpMarketOpenMinute;
   int close_minute = InpMarketCloseHour * 60 + InpMarketCloseMinute;
   return minute >= open_minute && minute < close_minute;
  }

/// Return the current UTC time and fall back to server-derived UTC when needed.
datetime GBCurrentUtc()
  {
   datetime utc = TimeGMT();
   if(utc > 0)
      return utc;
   return TimeCurrent();
  }

/// Convert a UTC event time to the current broker-server chart time.
datetime GBUtcToServer(const datetime utc_time)
  {
   datetime server = TimeTradeServer();
   datetime utc_now = GBCurrentUtc();
   if(server <= 0 || utc_now <= 0)
      return utc_time;
   return utc_time + (server - utc_now);
  }

//+------------------------------------------------------------------+
//| Local Major history                                              |
//+------------------------------------------------------------------+

/// Return a safe file component for the current ticker.
string GBHistoryTickerComponent()
  {
   string result = g_ticker;
   StringReplace(result, "_", "-");
   return result;
  }

/// Return a compact New York calendar-date key for a UTC time.
string GBNewYorkDateKey(const datetime utc_time)
  {
   MqlDateTime local;
   TimeToStruct(GBUtcToNewYork(utc_time), local);
   return StringFormat("%04d%02d%02d", local.year, local.mon, local.day);
  }

/// Return the local history cache path for the active New York session date.
string GBHistoryFilePath()
  {
   string date_key = g_history_session_key == "" ? GBNewYorkDateKey(GBCurrentUtc()) : g_history_session_key;
   return "GexbotMT5\\" + GBHistoryTickerComponent() + "-" + date_key + ".csv";
  }

/// Save all locally collected Major history buckets.
void GBSaveHistory()
  {
   if(!InpPersistMajorHistory || !g_history_dirty)
      return;
   FolderCreate("GexbotMT5");
   int handle = FileOpen(GBHistoryFilePath(), FILE_WRITE | FILE_CSV | FILE_ANSI, ',');
   if(handle == INVALID_HANDLE)
     {
      Print("Gexbot MT5: Cannot save Major history cache. Error ", GetLastError());
      return;
     }
   FileWrite(handle, "minute_utc", "pos_sum", "pos_count", "neg_sum", "neg_count", "zero_sum", "zero_count");
   for(int index = 0; index < ArraySize(g_history); index++)
      FileWrite(handle, (long)g_history[index].minute_utc,
                g_history[index].pos_sum, g_history[index].pos_count,
                g_history[index].neg_sum, g_history[index].neg_count,
                g_history[index].zero_sum, g_history[index].zero_count);
   FileClose(handle);
   g_history_dirty = false;
  }

/// Load locally collected Major history for the current session date.
void GBLoadHistory()
  {
   ArrayResize(g_history, 0);
   if(!InpPersistMajorHistory)
      return;
   int handle = FileOpen(GBHistoryFilePath(), FILE_READ | FILE_CSV | FILE_ANSI, ',');
   if(handle == INVALID_HANDLE)
      return;

   if(!FileIsEnding(handle))
     {
      for(int column = 0; column < 7 && !FileIsEnding(handle); column++)
         FileReadString(handle);
     }
   while(!FileIsEnding(handle))
     {
      GBHistoryBucket bucket;
      bucket.minute_utc = (datetime)(long)FileReadNumber(handle);
      bucket.pos_sum = FileReadNumber(handle);
      bucket.pos_count = (int)FileReadNumber(handle);
      bucket.neg_sum = FileReadNumber(handle);
      bucket.neg_count = (int)FileReadNumber(handle);
      bucket.zero_sum = FileReadNumber(handle);
      bucket.zero_count = (int)FileReadNumber(handle);
      if(bucket.minute_utc <= 0 || !GBWithinMarketHours(bucket.minute_utc))
         continue;
      int size = ArraySize(g_history);
      if(size >= 1440)
         break;
      ArrayResize(g_history, size + 1);
      g_history[size] = bucket;
     }
   FileClose(handle);
   g_history_dirty = false;
  }

/// Change the local history cache when the New York calendar date changes.
bool GBEnsureHistorySession()
  {
   string current_key = GBNewYorkDateKey(GBCurrentUtc());
   if(g_history_session_key == "")
     {
      g_history_session_key = current_key;
      return false;
     }
   if(current_key == g_history_session_key)
      return false;
   GBSaveHistory();
   ArrayResize(g_history, 0);
   g_history_dirty = false;
   g_history_session_key = current_key;
   GBLoadHistory();
   return true;
  }

/// Append one Classic volume snapshot to its one-minute history bucket.
void GBAppendMajorHistory(CGBProfileData &snapshot)
  {
   if(!InpCollectMajorHistory || !snapshot.valid || snapshot.api_timestamp <= 0)
      return;
   datetime event_utc = (datetime)snapshot.api_timestamp;
   if(!GBWithinMarketHours(event_utc) || GBNewYorkDateKey(event_utc) != g_history_session_key)
      return;
   datetime minute_utc = (datetime)(((long)event_utc / 60) * 60);
   int size = ArraySize(g_history);
   if(size > 0 && minute_utc < g_history[size - 1].minute_utc)
      return;
   if(size >= 1440 && g_history[size - 1].minute_utc != minute_utc)
      return;
   if(size == 0 || g_history[size - 1].minute_utc != minute_utc)
     {
      if(size > 0)
         GBSaveHistory();
      ArrayResize(g_history, size + 1);
      g_history[size].minute_utc = minute_utc;
      g_history[size].pos_sum = 0.0;
      g_history[size].neg_sum = 0.0;
      g_history[size].zero_sum = 0.0;
      g_history[size].pos_count = 0;
      g_history[size].neg_count = 0;
      g_history[size].zero_count = 0;
     }
   int index = ArraySize(g_history) - 1;
   if(snapshot.major_pos > 0.0)
     {
      g_history[index].pos_sum += snapshot.major_pos;
      g_history[index].pos_count++;
     }
   if(snapshot.major_neg > 0.0)
     {
      g_history[index].neg_sum += snapshot.major_neg;
      g_history[index].neg_count++;
     }
   if(snapshot.zero_gamma > 0.0)
     {
      g_history[index].zero_sum += snapshot.zero_gamma;
      g_history[index].zero_count++;
     }
   g_history_dirty = true;
  }

/// Return one averaged value from a history bucket.
double GBHistoryValue(const GBHistoryBucket &bucket,const int series)
  {
   if(series == 0)
      return bucket.pos_count > 0 ? bucket.pos_sum / bucket.pos_count : 0.0;
   if(series == 1)
      return bucket.neg_count > 0 ? bucket.neg_sum / bucket.neg_count : 0.0;
   return bucket.zero_count > 0 ? bucket.zero_sum / bucket.zero_count : 0.0;
  }

//+------------------------------------------------------------------+
//| Drawing helpers                                                  |
//+------------------------------------------------------------------+

/// Create or update one pixel rectangle.
void GBPixelRectangle(const string name,const int x,const int y,const int width,const int height,const color object_color)
  {
   if(width <= 0 || height <= 0)
      return;
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, object_color);
   ObjectSetInteger(0, name, OBJPROP_COLOR, object_color);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_BACK, InpDrawBehindCandles);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

/// Draw one horizontal profile value with the selected pixel style.
void GBDrawStyledBar(const string base_name,const int x1,const int x2,const int y,const int thickness,const color object_color,const ENUM_GB_PROFILE_STYLE style)
  {
   int left = MathMin(x1, x2);
   int right = MathMax(x1, x2);
   int total_width = right - left;
   if(total_width < 1)
      total_width = 1;

   if(style == GB_STYLE_BAR || style == GB_STYLE_LINE)
     {
      int height = style == GB_STYLE_LINE ? 1 : thickness;
      GBPixelRectangle(base_name + "_0", left, y - height / 2, total_width, height, object_color);
      return;
     }

   int segment = style == GB_STYLE_DOT ? MathMax(1, thickness) : 7;
   int gap = style == GB_STYLE_DOT ? MathMax(2, thickness * 2) : 4;
   int position = left;
   int segment_index = 0;
   while(position < right && segment_index < 300)
     {
      int width = MathMin(segment, right - position);
      GBPixelRectangle(base_name + "_" + IntegerToString(segment_index), position,
                       y - MathMax(1, thickness) / 2, MathMax(1, width), MathMax(1, thickness), object_color);
      position += segment + gap;
      segment_index++;
     }
  }

/// Return true when a strike passes its positive or negative top-N filter.
bool GBPointPassesFilter(CGBProfileData &data,const int point_index,const int top_n,const int bottom_n)
  {
   double value = data.points[point_index].value;
   if(value == 0.0)
      return false;
   int limit = value > 0.0 ? top_n : bottom_n;
   if(limit <= 0)
      return true;
   int more_extreme = 0;
   for(int index = 0; index < ArraySize(data.points); index++)
     {
      double other = data.points[index].value;
      if(value > 0.0 && other > value)
         more_extreme++;
      else if(value < 0.0 && other < value)
         more_extreme++;
      if(more_extreme >= limit)
         return false;
     }
   return true;
  }

/// Scale one exposure value to a pixel width.
int GBScaledWidth(const double value,const double maximum,const int width_px,const bool logarithmic)
  {
   if(maximum <= 0.0 || value == 0.0)
      return 0;
   double ratio = 0.0;
   if(logarithmic)
      ratio = MathLog10(1.0 + MathAbs(value)) / MathLog10(1.0 + maximum);
   else
      ratio = MathAbs(value) / maximum;
   return MathMax(1, (int)MathRound(ratio * width_px));
  }

/// Return the profile endpoint x-coordinate for one value.
int GBProfileEndpoint(const int origin,const int width,const double value,const ENUM_GB_PROFILE_ALIGN align)
  {
   if(align == GB_ALIGN_LEFT)
      return origin - width;
   if(align == GB_ALIGN_RIGHT)
      return origin + width;
   return value >= 0.0 ? origin + width : origin - width;
  }

/// Draw one profile title at its configured origin.
void GBDrawProfileTitle(const GBProfileStyle &style,const int chart_width)
  {
   string name = style.prefix + "TITLE";
   if(!InpShowProfileLabels)
      return;
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, chart_width * style.origin_pct / 100);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 4);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_TOP);
   ObjectSetString(0, name, OBJPROP_TEXT, style.title);
   ObjectSetString(0, name, OBJPROP_FONT, "Trebuchet MS Bold");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrSilver);
   ObjectSetInteger(0, name, OBJPROP_BACK, InpDrawBehindCandles);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

/// Draw one complete profile and its prior dots.
void GBDrawProfile(const ENUM_GB_PROFILE_ID profile_id,CGBProfileData &data)
  {
   GBProfileStyle style;
   GBGetProfileStyle(profile_id, style);
   ObjectsDeleteAll(0, style.prefix);
   if(!style.show || !data.valid || !g_conversion_ready || data.max_abs <= 0.0)
      return;

   int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   int origin = chart_width * style.origin_pct / 100;
   GBDrawProfileTitle(style, chart_width);

   for(int index = 0; index < ArraySize(data.points); index++)
     {
      if(!GBPointPassesFilter(data, index, style.top_n, style.bottom_n))
         continue;
      double price = GBConvertPrice(data.points[index].strike);
      int ignored_x = 0;
      int y = 0;
      if(!ChartTimePriceToXY(0, 0, TimeCurrent(), price, ignored_x, y))
         continue;
      y -= style.offset_px;
      if(y < 0 || y > chart_height)
         continue;
      int width = GBScaledWidth(data.points[index].value, data.max_abs, style.width_px, style.log_scale);
      int endpoint = GBProfileEndpoint(origin, width, data.points[index].value, style.align);
      int x1 = GBClampInt(origin, 0, chart_width);
      int x2 = GBClampInt(endpoint, 0, chart_width);
      color bar_color = data.points[index].value >= 0.0 ? style.positive_color : style.negative_color;
      GBDrawStyledBar(style.prefix + "B" + IntegerToString(index), x1, x2, y, style.thickness, bar_color, style.style);

      if(!InpShowPriorDots || !style.show_priors)
         continue;
      for(int prior_index = 0; prior_index < data.points[index].prior_count; prior_index++)
        {
         double prior = GBPriorValue(data.points[index], prior_index);
         if(prior == 0.0)
            continue;
         int prior_width = GBScaledWidth(prior, data.max_abs, style.width_px, style.log_scale);
         int dot_x = GBProfileEndpoint(origin, prior_width, prior, style.align);
         dot_x = GBClampInt(dot_x, 0, chart_width);
         int size = style.prior_size;
         GBPixelRectangle(style.prefix + "D" + IntegerToString(index) + "_" + IntegerToString(prior_index),
                          dot_x - size / 2, y - size / 2, size, size, GBPriorColor(profile_id, prior_index));
        }
     }
  }

/// Return the chart time used for Major labels.
datetime GBMajorLabelTime()
  {
   int width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   int x = 0;
   if(InpMajorLabelPosition == GB_LABEL_RIGHT)
      x = MathMax(0, width - 20);
   else if(InpMajorLabelPosition == GB_LABEL_PERCENT)
      x = width * GBClampInt(InpMajorLabelPct, 0, 100) / 100;
   else
      x = 20;
   int subwindow = 0;
   datetime label_time = TimeCurrent();
   double ignored_price = 0.0;
   ChartXYToTimePrice(0, x, MathMax(1, height / 2), subwindow, label_time, ignored_price);
   return label_time;
  }

/// Return the absolute profile magnitude nearest to a source price.
double GBNearestMagnitude(CGBProfileData &data,const double raw_price)
  {
   if(!data.valid || raw_price <= 0.0 || ArraySize(data.points) == 0)
      return -1.0;
   double nearest_distance = DBL_MAX;
   double nearest_value = -1.0;
   for(int index = 0; index < ArraySize(data.points); index++)
     {
      double distance = MathAbs(data.points[index].strike - raw_price);
      if(distance >= nearest_distance)
         continue;
      nearest_distance = distance;
      nearest_value = MathAbs(data.points[index].value);
     }
   return nearest_value;
  }

/// Draw one current Major line and label.
void GBDrawMajor(const string id,const double raw_price,const double magnitude,const bool show,const color line_color,const int line_width,const ENUM_LINE_STYLE line_style,const string label)
  {
   string line_name = "GB_MAJOR_" + id + "_LINE";
   string text_name = "GB_MAJOR_" + id + "_TEXT";
   ObjectDelete(0, line_name);
   ObjectDelete(0, text_name);
   if(!show || raw_price <= 0.0 || !g_conversion_ready)
      return;
   double price = GBConvertPrice(raw_price);
   if(ObjectCreate(0, line_name, OBJ_HLINE, 0, 0, price))
     {
      ObjectSetInteger(0, line_name, OBJPROP_COLOR, line_color);
      ObjectSetInteger(0, line_name, OBJPROP_WIDTH, GBClampInt(line_width, 1, 10));
      ObjectSetInteger(0, line_name, OBJPROP_STYLE, line_style);
      ObjectSetInteger(0, line_name, OBJPROP_BACK, InpDrawBehindCandles);
      ObjectSetInteger(0, line_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, line_name, OBJPROP_HIDDEN, true);
     }
   if(!InpShowMajorLabels)
      return;
   datetime label_time = GBMajorLabelTime();
   if(ObjectCreate(0, text_name, OBJ_TEXT, 0, label_time, price))
     {
      string label_text = label + " " + DoubleToString(price, _Digits);
      if(InpShowMajorMagnitude && magnitude >= 0.0)
         label_text += "  | " + DoubleToString(magnitude, 3);
      ObjectSetString(0, text_name, OBJPROP_TEXT, label_text);
      ObjectSetString(0, text_name, OBJPROP_FONT, "Trebuchet MS");
      ObjectSetInteger(0, text_name, OBJPROP_FONTSIZE, GBClampInt(InpMajorLabelFontSize, 6, 20));
      ObjectSetInteger(0, text_name, OBJPROP_COLOR, line_color);
      ObjectSetInteger(0, text_name, OBJPROP_ANCHOR,
                       InpMajorLabelPosition == GB_LABEL_RIGHT ? ANCHOR_RIGHT_LOWER :
                       InpMajorLabelPosition == GB_LABEL_PERCENT ? ANCHOR_LOWER : ANCHOR_LEFT_LOWER);
      ObjectSetInteger(0, text_name, OBJPROP_BACK, InpDrawBehindCandles);
      ObjectSetInteger(0, text_name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, text_name, OBJPROP_HIDDEN, true);
     }
  }

/// Draw all current Classic and State Majors.
void GBDrawMajors()
  {
   ObjectsDeleteAll(0, "GB_MAJOR_");
   GBDrawMajor("ZG", g_classic_vol.zero_gamma, GBNearestMagnitude(g_classic_vol, g_classic_vol.zero_gamma), InpShowZeroGamma, InpZeroGammaColor, InpZeroGammaWidth, InpZeroGammaStyle, InpZeroGammaLabel);
   GBDrawMajor("CVP", g_classic_vol.major_pos, GBNearestMagnitude(g_classic_vol, g_classic_vol.major_pos), InpShowClassicPosVol, InpClassicPosVolColor, InpClassicPosVolWidth, InpClassicPosVolStyle, InpClassicPosVolLabel);
   GBDrawMajor("CVN", g_classic_vol.major_neg, GBNearestMagnitude(g_classic_vol, g_classic_vol.major_neg), InpShowClassicNegVol, InpClassicNegVolColor, InpClassicNegVolWidth, InpClassicNegVolStyle, InpClassicNegVolLabel);
   GBDrawMajor("COIP", g_classic_oi.major_pos_oi, GBNearestMagnitude(g_classic_oi, g_classic_oi.major_pos_oi), InpShowClassicPosOi, InpClassicPosOiColor, InpClassicPosOiWidth, InpClassicPosOiStyle, InpClassicPosOiLabel);
   GBDrawMajor("COIN", g_classic_oi.major_neg_oi, GBNearestMagnitude(g_classic_oi, g_classic_oi.major_neg_oi), InpShowClassicNegOi, InpClassicNegOiColor, InpClassicNegOiWidth, InpClassicNegOiStyle, InpClassicNegOiLabel);
   GBDrawMajor("SGP", g_state_gex.major_pos, GBNearestMagnitude(g_state_gex, g_state_gex.major_pos), InpShowStatePosGex, InpStatePosGexColor, InpStatePosGexWidth, InpStatePosGexStyle, InpStatePosGexLabel);
   GBDrawMajor("SGN", g_state_gex.major_neg, GBNearestMagnitude(g_state_gex, g_state_gex.major_neg), InpShowStateNegGex, InpStateNegGexColor, InpStateNegGexWidth, InpStateNegGexStyle, InpStateNegGexLabel);
   GBDrawMajor("GL", g_gamma.major_long, GBNearestMagnitude(g_gamma, g_gamma.major_long), InpShowGammaLong, InpGammaLongColor, InpGammaLongWidth, InpGammaLongStyle, InpGammaLongLabel);
   GBDrawMajor("GS", g_gamma.major_short, GBNearestMagnitude(g_gamma, g_gamma.major_short), InpShowGammaShort, InpGammaShortColor, InpGammaShortWidth, InpGammaShortStyle, InpGammaShortLabel);
  }

/// Draw one line segment for Major history.
void GBDrawHistorySegment(const string name,const datetime first_time,const double first_raw,const datetime second_time,const double second_raw,const color line_color,const int width)
  {
   if(first_raw <= 0.0 || second_raw <= 0.0 || second_time - first_time > GB_HISTORY_GAP_SECONDS)
      return;
   if(ObjectCreate(0, name, OBJ_TREND, 0, GBUtcToServer(first_time), GBConvertPrice(first_raw), GBUtcToServer(second_time), GBConvertPrice(second_raw)))
     {
      ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, false);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, name, OBJPROP_COLOR, line_color);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, GBClampInt(width, 1, 10));
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
  }

/// Draw one scatter marker for Major history.
void GBDrawHistoryPoint(const string name,const datetime point_time,const double raw_price,const color point_color,const int width)
  {
   if(raw_price <= 0.0)
      return;
   if(ObjectCreate(0, name, OBJ_ARROW, 0, GBUtcToServer(point_time), GBConvertPrice(raw_price)))
     {
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, 159);
      ObjectSetInteger(0, name, OBJPROP_COLOR, point_color);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, GBClampInt(width, 1, 5));
      ObjectSetInteger(0, name, OBJPROP_BACK, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
     }
  }

/// Draw one locally collected Major history series.
void GBDrawHistorySeries(const int series,const bool show,const color series_color,const ENUM_GB_HISTORY_STYLE style,const int width)
  {
   if(!show || !g_conversion_ready)
      return;
   string prefix = "GB_HIST_" + IntegerToString(series) + "_";
   if(style == GB_HISTORY_SCATTER)
     {
      for(int index = 0; index < ArraySize(g_history); index++)
         GBDrawHistoryPoint(prefix + IntegerToString(index), g_history[index].minute_utc,
                            GBHistoryValue(g_history[index], series), series_color, width);
      return;
     }
   for(int index = 1; index < ArraySize(g_history); index++)
      GBDrawHistorySegment(prefix + IntegerToString(index),
                           g_history[index - 1].minute_utc, GBHistoryValue(g_history[index - 1], series),
                           g_history[index].minute_utc, GBHistoryValue(g_history[index], series),
                           series_color, width);
  }

/// Draw all enabled locally collected Major history series.
void GBDrawMajorHistory()
  {
   ObjectsDeleteAll(0, "GB_HIST_");
   GBDrawHistorySeries(0, InpShowPosVolHistory, InpPosVolHistoryColor, InpPosVolHistoryStyle, InpPosVolHistoryWidth);
   GBDrawHistorySeries(1, InpShowNegVolHistory, InpNegVolHistoryColor, InpNegVolHistoryStyle, InpNegVolHistoryWidth);
   GBDrawHistorySeries(2, InpShowZeroGammaHistory, InpZeroGammaHistoryColor, InpZeroGammaHistoryStyle, InpZeroGammaHistoryWidth);
  }

/// Create or update one dashboard label.
void GBDashboardLabel(const string name,const string text,const int x,const int y,const color text_color,const int font_size,const bool bold=false)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, bold ? "Trebuchet MS Bold" : "Trebuchet MS");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(0, name, OBJPROP_COLOR, text_color);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

/// Return a short freshness text for one profile.
string GBProfileFreshness(CGBProfileData &data)
  {
   if(!data.valid)
      return "waiting";
   if(data.last_error != "")
      return "error";
   int stale_seconds = MathMax(30, InpRefreshSeconds * 3);
   if(data.last_success > 0 && TimeCurrent() - data.last_success > stale_seconds)
      return "stale";
   return "live";
  }

/// Return the dashboard top-left coordinate.
void GBDashboardOrigin(const int panel_width,const int panel_height,int &x,int &y)
  {
   int chart_width = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   x = 20;
   y = 40;
   if(InpDashboardPosition == GB_DASH_TOP_RIGHT)
      x = chart_width - panel_width - 20;
   else if(InpDashboardPosition == GB_DASH_BOTTOM_LEFT)
      y = chart_height - panel_height - 30;
   else if(InpDashboardPosition == GB_DASH_BOTTOM_RIGHT)
     {
      x = chart_width - panel_width - 20;
      y = chart_height - panel_height - 30;
     }
   else if(InpDashboardPosition == GB_DASH_TOP_CENTER)
      x = (chart_width - panel_width) / 2;
   else if(InpDashboardPosition == GB_DASH_BOTTOM_CENTER)
     {
      x = (chart_width - panel_width) / 2;
      y = chart_height - panel_height - 30;
     }
   x = MathMax(0, x);
   y = MathMax(24, y);
  }

/// Draw the dashboard toggle and all dashboard sections.
void GBDrawDashboard()
  {
   ObjectsDeleteAll(0, "GB_DASH_");
   int panel_width = 310;
   int panel_height = 430;
   int x = 0;
   int y = 0;
   GBDashboardOrigin(panel_width, panel_height, x, y);

   string button = "GB_DASH_TOGGLE";
   if(ObjectFind(0, button) < 0)
      ObjectCreate(0, button, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, button, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, button, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, button, OBJPROP_YDISTANCE, y - 22);
   ObjectSetInteger(0, button, OBJPROP_XSIZE, g_show_dashboard ? 70 : 120);
   ObjectSetInteger(0, button, OBJPROP_YSIZE, 18);
   ObjectSetString(0, button, OBJPROP_TEXT, g_show_dashboard ? "Hide gexbot" : "Show gexbot");
   ObjectSetInteger(0, button, OBJPROP_BGCOLOR, clrBlack);
   ObjectSetInteger(0, button, OBJPROP_COLOR, clrSilver);
   ObjectSetInteger(0, button, OBJPROP_BORDER_COLOR, clrDimGray);
   ObjectSetInteger(0, button, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, button, OBJPROP_BACK, false);
   ObjectSetInteger(0, button, OBJPROP_HIDDEN, true);
   if(!g_show_dashboard)
      return;

   GBPixelRectangle("GB_DASH_BG", x, y, panel_width, panel_height,
                    InpDashboardTransparent ? clrNONE : clrBlack);
   int font = GBClampInt(InpDashboardFontSize, 7, 16);
   int line = font + 7;
   int left = x + 12;
   int row = y + 10;
   color status_color = g_conversion_ready && g_last_any_success > 0 ? clrLimeGreen : clrOrange;

   GBDashboardLabel("GB_DASH_TITLE", "gexbot MT5 4.0  |  " + g_ticker, left, row, clrWhite, font + 1, true);
   row += line;
   GBDashboardLabel("GB_DASH_STATUS", g_status, left, row, status_color, font);
   row += line;
   string conversion = "Conversion: ";
   if(InpConversionMode == GB_CONVERSION_NONE)
      conversion += "off";
   else if(InpConversionMode == GB_CONVERSION_MANUAL)
      conversion += DoubleToString(g_conversion_multiplier, 5) + "x + " + DoubleToString(g_conversion_additive, 2);
   else if(g_conversion_ready)
      conversion += (g_conversion_contract == "" ? InpFuturesTarget : g_conversion_contract) + "  " +
                    DoubleToString(g_conversion_multiplier, 5) + "x + " + DoubleToString(g_conversion_additive, 2);
   else
      conversion += g_conversion_error;
   GBDashboardLabel("GB_DASH_CONV", conversion, left, row, clrSilver, font);
   row += line + 4;

   GBDashboardLabel("GB_DASH_C_TITLE", "CLASSIC  " + GBProfileFreshness(g_classic_vol) + "/" + GBProfileFreshness(g_classic_oi), left, row, clrWhite, font, true);
   row += line;
   GBDashboardLabel("GB_DASH_C1", "Zero Gamma: " + GBFormatPrice(g_classic_vol.zero_gamma), left, row, InpZeroGammaColor, font);
   row += line;
   GBDashboardLabel("GB_DASH_C2", "Vol + / -: " + GBFormatPrice(g_classic_vol.major_pos) + " / " + GBFormatPrice(g_classic_vol.major_neg), left, row, clrSilver, font);
   row += line;
   GBDashboardLabel("GB_DASH_C3", "OI + / -: " + GBFormatPrice(g_classic_oi.major_pos_oi) + " / " + GBFormatPrice(g_classic_oi.major_neg_oi), left, row, clrSilver, font);
   row += line;
   GBDashboardLabel("GB_DASH_C4", "Net Vol / OI: " + DoubleToString(g_classic_vol.net_vol, 3) + " / " + DoubleToString(g_classic_oi.net_oi, 3), left, row, clrSilver, font);
   row += line + 4;

   GBDashboardLabel("GB_DASH_S_TITLE", "STATE GEX  " + GBProfileFreshness(g_state_gex), left, row, clrWhite, font, true);
   row += line;
   GBDashboardLabel("GB_DASH_S1", "Major + / -: " + GBFormatPrice(g_state_gex.major_pos) + " / " + GBFormatPrice(g_state_gex.major_neg), left, row, clrSilver, font);
   row += line;
   GBDashboardLabel("GB_DASH_S2", "Net GEX: " + DoubleToString(g_state_gex.net_vol, 3), left, row, clrSilver, font);
   row += line + 4;

   GBDashboardLabel("GB_DASH_G_TITLE", "STATE GAMMA  " + GBProfileFreshness(g_gamma), left, row, clrWhite, font, true);
   row += line;
   GBDashboardLabel("GB_DASH_G1", "Long / Short: " + GBFormatPrice(g_gamma.major_long) + " / " + GBFormatPrice(g_gamma.major_short), left, row, clrSilver, font);
   row += line + 4;

   GBDashboardLabel("GB_DASH_M_TITLE", "MAX CHANGE GEX", left, row, clrWhite, font, true);
   row += line;
   string prior_labels[5] = {"1m", "5m", "10m", "15m", "30m"};
   for(int prior_index = 0; prior_index < 5; prior_index++)
     {
      double value = g_classic_vol.max_prior_value[prior_index];
      GBDashboardLabel("GB_DASH_M" + IntegerToString(prior_index),
                       prior_labels[prior_index] + "  " + GBFormatPrice(g_classic_vol.max_prior_strike[prior_index]) + "  " + DoubleToString(value, 3),
                       left, row, value >= 0.0 ? clrLimeGreen : clrTomato, font);
      row += line;
     }
  }

/// Draw the persistent status label.
void GBDrawStatusLabel()
  {
   string name = "GB_STATUS";
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, 8);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
   ObjectSetString(0, name, OBJPROP_TEXT, "gexbot: " + g_status);
   ObjectSetString(0, name, OBJPROP_FONT, "Trebuchet MS");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, name, OBJPROP_COLOR, g_conversion_ready && g_last_any_success > 0 ? clrSilver : clrOrange);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

/// Redraw all profiles, Majors, history, and status components.
void GBDrawAll()
  {
   GBDrawProfile(GB_PROFILE_CLASSIC_VOL, g_classic_vol);
   GBDrawProfile(GB_PROFILE_CLASSIC_OI, g_classic_oi);
   GBDrawProfile(GB_PROFILE_STATE_GEX, g_state_gex);
   GBDrawProfile(GB_PROFILE_GAMMA, g_gamma);
   GBDrawProfile(GB_PROFILE_DELTA, g_delta);
   GBDrawProfile(GB_PROFILE_VANNA, g_vanna);
   GBDrawProfile(GB_PROFILE_CHARM, g_charm);
   GBDrawMajorHistory();
   GBDrawMajors();
   GBDrawDashboard();
   GBDrawStatusLabel();
   ChartRedraw();
   g_last_draw_tick = GetTickCount64();
  }

//+------------------------------------------------------------------+
//| Scheduling and lifecycle                                         |
//+------------------------------------------------------------------+

/// Return true when one source is due for another request.
bool GBSourceDue(const ENUM_GB_PROFILE_ID profile_id)
  {
   if(!GBSourceRequired(profile_id))
      return false;
   ulong age = GBAgeMilliseconds(g_last_attempt[(int)profile_id]);
   return age == ULONG_MAX || age >= (ulong)MathMax(2, InpRefreshSeconds) * 1000;
  }

/// Fetch one source and update its attempt timestamp.
bool GBFetchSource(const ENUM_GB_PROFILE_ID profile_id)
  {
   ulong now = GetTickCount64();
   g_last_attempt[(int)profile_id] = now;

   if(profile_id == GB_PROFILE_CLASSIC_VOL)
     {
      bool same_dte = InpClassicVolDte == InpClassicOiDte;
      bool update_oi = same_dte && GBNeedsClassicOi();
      if(update_oi)
         g_last_attempt[(int)GB_PROFILE_CLASSIC_OI] = now;
      return GBFetchClassic(InpClassicVolDte, true, update_oi);
     }
   if(profile_id == GB_PROFILE_CLASSIC_OI)
     {
      bool same_dte = InpClassicVolDte == InpClassicOiDte;
      bool update_vol = same_dte && GBNeedsClassicVol();
      if(update_vol)
         g_last_attempt[(int)GB_PROFILE_CLASSIC_VOL] = now;
      return GBFetchClassic(InpClassicOiDte, update_vol, true);
     }
   if(profile_id == GB_PROFILE_STATE_GEX)
      return GBFetchStateGex();
   return GBFetchGreek(profile_id);
  }

/// Fetch every required source once without duplicate Classic requests.
void GBFetchInitialSources()
  {
   bool need_vol = GBNeedsClassicVol();
   bool need_oi = GBNeedsClassicOi();
   if(need_vol && need_oi && InpClassicVolDte == InpClassicOiDte)
     {
      ulong now = GetTickCount64();
      g_last_attempt[(int)GB_PROFILE_CLASSIC_VOL] = now;
      g_last_attempt[(int)GB_PROFILE_CLASSIC_OI] = now;
      GBFetchClassic(InpClassicVolDte, true, true);
     }
   else
     {
      if(need_vol) GBFetchSource(GB_PROFILE_CLASSIC_VOL);
      if(need_oi) GBFetchSource(GB_PROFILE_CLASSIC_OI);
     }
   if(GBNeedsStateGex()) GBFetchSource(GB_PROFILE_STATE_GEX);
   if(GBNeedsGamma()) GBFetchSource(GB_PROFILE_GAMMA);
   if(InpShowDelta) GBFetchSource(GB_PROFILE_DELTA);
   if(InpShowVanna) GBFetchSource(GB_PROFILE_VANNA);
   if(InpShowCharm) GBFetchSource(GB_PROFILE_CHARM);
  }

/// Request one due source in round-robin order.
bool GBFetchNextDueSource()
  {
   for(int offset = 0; offset < GB_PROFILE_COUNT; offset++)
     {
      int index = (g_next_source + offset) % GB_PROFILE_COUNT;
      ENUM_GB_PROFILE_ID profile_id = (ENUM_GB_PROFILE_ID)index;
      if(!GBSourceDue(profile_id))
         continue;
      g_next_source = (index + 1) % GB_PROFILE_COUNT;
      GBFetchSource(profile_id);
      return true;
     }
   return false;
  }

/// Validate all input values that affect requests.
bool GBValidateInputs(string &error)
  {
   if(InpRefreshSeconds < 2 || InpRefreshSeconds > 3600)
     {
      error = "Refresh Seconds must be from 2 through 3600";
      return false;
     }
   if(InpWebRequestTimeoutMs < 1000 || InpWebRequestTimeoutMs > 60000)
     {
      error = "WebRequest Timeout must be from 1000 through 60000 milliseconds";
      return false;
     }
   if(InpMarketOpenHour < 0 || InpMarketOpenHour > 23 || InpMarketCloseHour < 0 || InpMarketCloseHour > 23 ||
      InpMarketOpenMinute < 0 || InpMarketOpenMinute > 59 || InpMarketCloseMinute < 0 || InpMarketCloseMinute > 59)
     {
      error = "Market-hour inputs are invalid";
      return false;
     }
   int open_minute = InpMarketOpenHour * 60 + InpMarketOpenMinute;
   int close_minute = InpMarketCloseHour * 60 + InpMarketCloseMinute;
   if(close_minute <= open_minute)
     {
      error = "Market close must be later than market open";
      return false;
     }
   g_ticker = GBUpper(GBTrim(InpTicker));
   if(!GBValidSymbol(g_ticker, 12))
     {
      error = "Ticker must contain only A-Z, 0-9, or underscore";
      return false;
     }
   if(!GBLoadApiKey(error))
      return false;
   return true;
  }

#ifndef GEXBOT_MT5_TEST

/// Initialize the shared Expert Advisor implementation.
int OnInit()
  {
   g_classic_vol.Clear();
   g_classic_oi.Clear();
   g_state_gex.Clear();
   g_gamma.Clear();
   g_delta.Clear();
   g_vanna.Clear();
   g_charm.Clear();
   ArrayInitialize(g_last_attempt, 0);
   g_show_dashboard = InpShowDashboardAtStart;
   g_status = "Initializing";
   g_last_any_success = 0;
   g_fetching = false;
   g_next_source = 0;

   string error = "";
   if(!GBValidateInputs(error))
     {
      Print("Gexbot MT5 initialization failed: ", error);
      return INIT_PARAMETERS_INCORRECT;
     }
   if(!GBInitializeConversion(error) && InpConversionMode != GB_CONVERSION_AUTO)
     {
      Print("Gexbot MT5 initialization failed: ", error);
      return INIT_PARAMETERS_INCORRECT;
     }

   g_history_session_key = GBNewYorkDateKey(GBCurrentUtc());
   GBLoadHistory();
   EventSetTimer(1);
   if(InpInitialFetch)
     {
      g_fetching = true;
      GBFetchInitialSources();
      g_fetching = false;
     }
   GBDrawAll();
   return INIT_SUCCEEDED;
  }

/// Remove timers, save local history, and delete all integration objects.
void OnDeinit(const int reason)
  {
   EventKillTimer();
   GBSaveHistory();
   ObjectsDeleteAll(0, GB_OBJECT_PREFIX);
   ChartRedraw();
  }

/// Keep the Expert Advisor independent of chart ticks.
void OnTick()
  {
  }

/// Run conversion refreshes and one due profile request.
void OnTimer()
  {
   if(g_fetching)
      return;
   g_fetching = true;
   bool changed = GBEnsureHistorySession();

   if(InpConversionMode == GB_CONVERSION_AUTO)
     {
      ulong conversion_age = GBAgeMilliseconds(g_conversion_last_attempt);
      bool failed_retry_due = !g_conversion_ready && conversion_age >= 60 * 1000;
      bool regular_refresh_due = g_conversion_ready && conversion_age >= 15 * 60 * 1000;
      if(failed_retry_due || regular_refresh_due)
        {
         GBFetchConversion();
         changed = true;
        }
     }

   bool market_open = !InpLimitToMarketHours || GBWithinMarketHours(GBCurrentUtc());
   if(market_open)
      changed = GBFetchNextDueSource() || changed;
   else
     {
      string closed_status = "Market closed. The next recurring request waits for the configured session.";
      if(g_status != closed_status)
        {
         g_status = closed_status;
         changed = true;
        }
     }

   if(changed || GBAgeMilliseconds(g_last_draw_tick) >= 10000)
      GBDrawAll();
   g_fetching = false;
  }

/// Process chart changes and the dashboard toggle button.
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
      GBDrawAll();
   else if(id == CHARTEVENT_OBJECT_CLICK && sparam == "GB_DASH_TOGGLE")
     {
      g_show_dashboard = !g_show_dashboard;
      ObjectSetInteger(0, "GB_DASH_TOGGLE", OBJPROP_STATE, false);
      GBDrawDashboard();
      ChartRedraw();
     }
  }

#endif // GEXBOT_MT5_TEST
#endif // GEXBOT_MT5_CORE_MQH
