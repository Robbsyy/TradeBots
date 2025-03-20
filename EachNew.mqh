//+------------------------------------------------------------------+
//|                                                       OnEach.mqh |
//|                                Copyright 2025, MeInvestment Ltd. |
//|                                             https://www.mql5.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MeInvestment Ltd."
#property link      "https://www.mql5.com/"

// pre-defined variables for single configuration
int temp_bars;
datetime temp_time;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar(string sym, ENUM_TIMEFRAMES etf, int &old_val)
  {
   int bars = iBars(sym,etf);

   if(bars == old_val)
      return false;

   old_val = bars;

   return true;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewTime(string sym, ENUM_TIMEFRAMES etf, datetime &old_val)
  {
   datetime time = iTime(sym,etf,0);

   if(time == old_val)
      return false;

   old_val = time;

   return true;
  }
//+------------------------------------------------------------------+