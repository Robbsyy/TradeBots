//+------------------------------------------------------------------+
//|                                                MovingAverage.mqh |
//|                                Copyright 2025, MeInvestment Ltd. |
//|                                             https://www.mql5.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MeInvestment Ltd."
#property link      "https://www.mql5.com/"

sinput group " --- MA --- "
input bool ma_on=true;

input int ma_period=10;
input ENUM_MA_METHOD ma_method=MODE_SMA;
input ENUM_APPLIED_PRICE ma_applied_price=PRICE_CLOSE;

int ma_handle=INVALID_HANDLE;
double ma_buffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MaInit()
  {
   if(ma_on)
      ma_handle=iMA(NULL,0,ma_period,0,ma_method,ma_applied_price);
   return ma_handle;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetMaValues(int count)
  {
   return CopyBuffer(ma_handle,0,0,count,ma_buffer);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MaDeinit()
  {
   if(ma_handle!=INVALID_HANDLE)
      return IndicatorRelease(ma_handle);

   return true;
  }
//+------------------------------------------------------------------+