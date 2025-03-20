#ifndef AUTO_TP_MQH
#define AUTO_TP_MQH

//+------------------------------------------------------------------+
//|                                                    AutoTP.mqh    |
//|                                Copyright 2025, MeInvestment Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
/*
   This module calculates an automatic take profit level based on the current
   volatility measured by the Average True Range (ATR). For a BUY order, the
   take profit is placed above the current Ask price; for a SELL order, below the
   current Bid price.
*/

// User input for the take profit multiplier (e.g., 2.0 times ATR)
input double AutoTP_Multiplier = 2.0;

// User input for the ATR period for TP calculation
input int AutoTP_ATR_Period = 14;

//+------------------------------------------------------------------+
//| Function: CalculateATR_TP                                        |
//| Purpose: Calculates the ATR value for the current symbol using     |
//|          the specified period.                                   |
//+------------------------------------------------------------------+
double CalculateATR_TP(int period)
{
   // Create an ATR indicator handle. iATR in MQL5 requires symbol, timeframe, period.
   int atrHandle = iATR(NULL, 0, period);
   if(atrHandle == INVALID_HANDLE)
   {
      Print("Failed to create ATR indicator handle for TP calculation");
      return -1;
   }
   
   double atrBuffer[];
   ArraySetAsSeries(atrBuffer, true);
   int copied = CopyBuffer(atrHandle, 0, 0, 1, atrBuffer);
   if(copied != 1)
   {
      Print("Failed to copy ATR buffer for TP calculation, error: ", GetLastError());
      IndicatorRelease(atrHandle);
      return -1;
   }
   
   double atrValue = atrBuffer[0];
   IndicatorRelease(atrHandle);
   return atrValue;
}

//+------------------------------------------------------------------+
//| Function: AutoTakeProfit                                         |
//| Purpose: Returns an automatic take profit price for the given      |
//|          order type based on the ATR and a multiplier.           |
//| Parameters:                                                      |
//|   order_type - ORDER_TYPE_BUY or ORDER_TYPE_SELL                   |
//+------------------------------------------------------------------+
double AutoTakeProfit(ENUM_ORDER_TYPE order_type)
{
   int digits = (int)SymbolInfoInteger(Symbol(), SYMBOL_DIGITS);
   double atr = CalculateATR_TP(AutoTP_ATR_Period);
   if(atr < 0) // error occurred
      return 0.0;
      
   double tp_price = 0.0;
   
   // For BUY orders, take profit is set above the Ask price.
   if(order_type == ORDER_TYPE_BUY)
   {
      double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      tp_price = ask + (AutoTP_Multiplier * atr);
      tp_price = NormalizeDouble(tp_price, digits);
   }
   // For SELL orders, take profit is set below the Bid price.
   else if(order_type == ORDER_TYPE_SELL)
   {
      double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
      tp_price = bid - (AutoTP_Multiplier * atr);
      tp_price = NormalizeDouble(tp_price, digits);
   }
   
   return tp_price;
}

#endif // AUTO_TP_MQH
