//+------------------------------------------------------------------+
//|                                                 Training_Bot.mq5 |
//|                                Copyright 2025, MeInvestment Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MeInvestment Ltd."
#property link      "https://www.mql5.com"
#property version   "2.00"

//--- Include core functionality files.
#include <EachNew.mqh>        // Checks for a new candle using Bars or Time
#include <Price.mqh>          // Provides Price data
#include <MovingAverage.mqh>  // Provides Moving Average (MA) data
#include <Order.mqh>          // Handles order placement
#include <AutoSL.mqh>
#include <AutoTP.mqh>

//--- Include helper files for additional position checks.
#include <PositionCheckByType.mqh>   // Helper #1: Checks if a similar position is already open.
#include <PositionVolumeCheck.mqh>   // Helper #2: Checks if the cumulative volume exceeds a maximum.
#include <PositionProfitRange.mqh>   // Helper #3: Checks if an existing position's profit is within a given range.

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialize the Moving Average indicator.
   if(MaInit()==INVALID_HANDLE)
      return(INIT_FAILED);

   // Initialize order parameters.
   OrderInit();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   MaDeinit();
   OrderDeinit();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Check if a new bar has formed using the EachNew helper.
   if(!NewBar(NULL, 0, temp_bars))
      return;

   // Ensure that the MA and Price buffers are updated with at least 3 values.
   if(GetMaValues(3)!=3 || GetPriceValues(price_type,3)!=3)
      return;

   // Evaluate buy signal and, if no similar buy position exists, place a buy order.
   if(BuySignal())
   {
      if(!PositionCheckByType(ORDER_TYPE_BUY, order_magic)) // ✅ Fixed missing parameter
      {
         // Optional: additional checks, e.g., volume or profit range, can be inserted here.
         OrderPlace(ORDER_TYPE_BUY);
      }
   }

   // Evaluate sell signal and, if no similar sell position exists, place a sell order.
   if(SellSignal())
   {
      if(!PositionCheckByType(ORDER_TYPE_SELL, order_magic)) // ✅ Fixed missing parameter
      {
         OrderPlace(ORDER_TYPE_SELL);
      }
   }
  }
//+------------------------------------------------------------------+
//| Check Long signal: Determines if a Buy signal is generated      |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   if(ma_on)
      if(ma_buffer[0] <= price_buffer[0] || ma_buffer[1] >= price_buffer[1])
         return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Check Short signal: Determines if a Sell signal is generated    |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   if(ma_on)
      if(ma_buffer[0] >= price_buffer[0] || ma_buffer[1] <= price_buffer[1])
         return false;
   return true;
  }
//+------------------------------------------------------------------+