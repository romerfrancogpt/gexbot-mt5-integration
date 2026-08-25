//+------------------------------------------------------------------+
//| GexbotMT5ParserTests.mq5                                         |
//| MetaEditor script tests for the bounded JSON response parser.    |
//+------------------------------------------------------------------+
#property script_show_inputs
#property strict

#define GEXBOT_MT5_TEST
#include "..\GexbotMT5Core.mqh"

int g_test_failures = 0;

/// Record one test result in the MetaTrader log.
void GBTestAssert(const bool condition,const string name)
  {
   if(condition)
      Print("PASS: ", name);
   else
     {
      Print("FAIL: ", name);
      g_test_failures++;
     }
  }

/// Compare two floating-point values with a small tolerance.
bool GBTestNear(const double actual,const double expected)
  {
   return MathAbs(actual - expected) < 0.000001;
  }

/// Test a valid GEX profile response.
void GBTestGexResponse()
  {
   string json = "{\"timestamp\":1777492800,\"ticker\":\"SPX\",\"zero_gamma\":7112.95,"
                 "\"major_pos_vol\":7135,\"major_pos_oi\":7200,\"major_neg_vol\":7100,"
                 "\"major_neg_oi\":6900,\"strikes\":[[7100,-12.5,4.25,[-10,-11,-12,-13,-14]],"
                 "[7110,20.5,-5.5,[18,17,16,15,14]]],\"sum_gex_vol\":8,\"sum_gex_oi\":-1.25,"
                 "\"max_priors\":[[7110,2],[7100,-3],[7110,4],[7110,5],[7110,6]]}";
   CGBProfileData result;
   result.Clear();
   string error = "";
   bool parsed = GBParseGexResponse(json, 1, true, result, error);
   GBTestAssert(parsed, "GEX response parses");
   GBTestAssert(ArraySize(result.points) == 2, "GEX response has two strikes");
   GBTestAssert(GBTestNear(result.points[0].value, -12.5), "GEX volume value parses");
   GBTestAssert(result.points[0].prior_count == 5, "GEX prior count parses");
   GBTestAssert(GBTestNear(result.points[0].prior5, -14.0), "GEX fifth prior parses");
   GBTestAssert(GBTestNear(result.zero_gamma, 7112.95), "Zero Gamma parses");
   GBTestAssert(GBTestNear(result.major_pos_oi, 7200.0), "Classic OI Major parses");
   GBTestAssert(GBTestNear(result.max_prior_value[1], -3.0), "Maximum-change value parses");
  }

/// Test a valid State Greek response.
void GBTestGreekResponse()
  {
   string json = "{\"timestamp\":1777492801,\"ticker\":\"SPX\",\"major_positive\":7140,"
                 "\"major_negative\":7080,\"major_long_gamma\":7150,\"major_short_gamma\":7075,"
                 "\"mini_contracts\":[[7100,0.2,0.3,-9,[1,2,3]],[7110,0.4,0.5,12,[4,5,6]]]}";
   CGBProfileData result;
   result.Clear();
   string error = "";
   bool parsed = GBParseGreekResponse(json, result, error);
   GBTestAssert(parsed, "Greek response parses");
   GBTestAssert(ArraySize(result.points) == 2, "Greek response has two strikes");
   GBTestAssert(GBTestNear(result.points[1].value, 12.0), "Greek exposure parses");
   GBTestAssert(result.points[1].prior_count == 3, "Greek prior count parses");
   GBTestAssert(GBTestNear(result.major_long, 7150.0), "Major Long Gamma parses");
   GBTestAssert(GBTestNear(result.major_short, 7075.0), "Major Short Gamma parses");
  }

/// Test that malformed data does not replace an existing strike snapshot.
void GBTestMalformedResponse()
  {
   string valid = "{\"timestamp\":1,\"strikes\":[[100,2,3,[1,2,3,4,5]]]}";
   string invalid = "{\"timestamp\":2,\"strikes\":[[100,\"bad\",3,[]]]}";
   CGBProfileData result;
   result.Clear();
   string error = "";
   GBParseGexResponse(valid, 1, true, result, error);
   int old_size = ArraySize(result.points);
   double old_value = result.points[0].value;
   bool parsed = GBParseGexResponse(invalid, 1, true, result, error);
   GBTestAssert(!parsed, "Malformed GEX response is rejected");
   GBTestAssert(ArraySize(result.points) == old_size && GBTestNear(result.points[0].value, old_value),
                "Malformed GEX response preserves the prior snapshot");
  }

/// Test top-level member scanning across nested arrays and objects.
void GBTestNestedMemberScanning()
  {
   string json = "{\"nested\":{\"target\":99,\"rows\":[[1,2],[3,4]]},\"target\":42.5}";
   double value = 0.0;
   GBTestAssert(GBJsonRootObjectValid(json), "Complete root object is accepted");
   GBTestAssert(!GBJsonRootObjectValid(json + " trailing"), "Trailing data is rejected");
   GBTestAssert(!GBJsonRootObjectValid("{\"broken\":[1,2}"), "Mismatched delimiters are rejected");
   GBTestAssert(!GBJsonRootObjectValid("{\"broken\":truth}"), "Invalid literals are rejected");
   GBTestAssert(GBJsonNumber(json, "target", value), "Top-level number is found");
   GBTestAssert(GBTestNear(value, 42.5), "Nested member does not replace top-level member");
  }

/// Run all parser tests as a MetaTrader script.
void OnStart()
  {
   GBTestGexResponse();
   GBTestGreekResponse();
   GBTestMalformedResponse();
   GBTestNestedMemberScanning();
   if(g_test_failures == 0)
      Print("Gexbot MT5 parser tests passed");
   else
      Print("Gexbot MT5 parser tests failed: ", g_test_failures);
  }
