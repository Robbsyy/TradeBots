#ifndef AUTO_SL_MQH
#define AUTO_SL_MQH

//+------------------------------------------------------------------+
//|                                                    AutoSL.mqh    |
//|                                Copyright 2025, MeInvestment Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
/*
   This module calculates an automatic stop loss level based on the current
   volatility measured by the Average True Range (ATR). For a BUY order, the
   stop loss is placed below the current Ask price; for a SELL order, above the
   current Bid price.
*/

// User input for the stop loss multiplier (e.g., 1.5 times ATR)
input double AutoSL_Multiplier = 1.5;

// User input for the ATR period
input int AutoSL_ATR_Period = 14;

//+------------------------------------------------------------------+
//| Function: CalculateATR                                           |
//| Purpose: Calculates the ATR value for the current symbol using     |
//|          the specified period.                                   |
//+------------------------------------------------------------------+
double CalculateATR(int period)
{
   // Create an ATR indicator handle; note only three parameters are required.
   int atrHandle = iATR(NULL, 0, period);
   if(atrHandle == INVALID_HANDLE)
   {
      Print("Failed to create ATR indicator handle");
      return -1;
   }
   
   double atrBuffer[];
   ArraySetAsSeries(atrBuffer, true);
   int copied = CopyBuffer(atrHandle, 0, 0, 1, atrBuffer);
   if(copied != 1)
   {
      Print("Failed to copy ATR buffer, error: ", GetLastError());
      IndicatorRelease(atrHandle);
      return -1;
   }
   
   double atrValue = atrBuffer[0];
   IndicatorRelease(atrHandle);
   return atrValue;
}

//+------------------------------------------------------------------+
//| Function: AutoStopLoss                                           |
//| Purpose: Returns an automatic stop loss price for the given order  |
//|          type based on the ATR and a multiplier.                 |
//| Parameters:                                                      |
//|   order_type - ORDER_TYPE_BUY or ORDER_TYPE_SELL                   |
//+------------------------------------------------------------------+
double AutoStopLoss(ENUM_ORDER_TYPE order_type)
{
   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
   double atr = CalculateATR(AutoSL_ATR_Period);
   if(atr < 0) // error occurred
      return 0.0;
      
   double sl_price = 0.0;
   
   // For BUY orders, stop loss is set below the Ask price.
   if(order_type == ORDER_TYPE_BUY)
   {
      double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      sl_price = ask - (AutoSL_Multiplier * atr);
      sl_price = NormalizeDouble(sl_price, digits);
   }
   // For SELL orders, stop loss is set above the Bid price.
   else if(order_type == ORDER_TYPE_SELL)
   {
      double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
      sl_price = bid + (AutoSL_Multiplier * atr);
      sl_price = NormalizeDouble(sl_price, digits);
   }
   
   return sl_price;
}

#endif // AUTO_SL_MQH
