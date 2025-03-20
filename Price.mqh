//+------------------------------------------------------------------+
//|                                                        Price.mqh |
//|                                Copyright 2025, MeInvestment Ltd. |
//|                                             https://www.mql5.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MeInvestment Ltd."
#property link      "https://www.mql5.com/"

enum PRICE
  {
   OPEN=0,
   HIGH=1,
   LOW=2,
   CLOSE=3,
  };

sinput group " --- PRICE --- "
input PRICE price_type=3;

double price_buffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetPriceValues(PRICE type, int count)
  {
   switch(type)
     {
      case OPEN:
         return CopyOpen(NULL,0,0,count,price_buffer);
         break;
      case HIGH:
         return CopyHigh(NULL,0,0,count,price_buffer);
         break;
      case LOW:
         return CopyLow(NULL,0,0,count,price_buffer);
         break;
      case CLOSE:
         return CopyClose(NULL,0,0,count,price_buffer);
         break;
      default:
         break;
         return(-2);
     }

   return(-3);
  }
//+------------------------------------------------------------------+