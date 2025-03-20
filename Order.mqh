//+------------------------------------------------------------------+
//|                                                        Order.mqh |
//|                                Copyright 2025, MeInvestment Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MeInvestment Ltd."
#property link      "https://www.mql5.com"

//--- Include AutoSL and AutoTP modules
#include <AutoSL.mqh>
#include <AutoTP.mqh>

sinput group " --- ORDER --- "
sinput ulong order_magic   = 123;
sinput double order_volume = 0.01;
// The following SL and TP values are fallback defaults.
// If AutoSL/TP are used, they will override these values.
input uint order_sl = 100;  // Stop Loss in points (fallback)
input uint order_tp = 150;  // Take Profit in points (fallback)

ulong order_deviation = 50;
uint order_spread     = 50;

MqlTradeRequest order_request = {};
MqlTradeResult  order_result  = {};

//+------------------------------------------------------------------+
//| OrderInit: Initializes the order request parameters              |
//+------------------------------------------------------------------+
void OrderInit()
  {
   order_request.action       = TRADE_ACTION_DEAL;       // Trade operation type
   order_request.magic        = order_magic;             // Expert Advisor ID (magic number)
   order_request.symbol       = Symbol();                // Trade symbol
   order_request.volume       = order_volume;            // Requested volume in lots
   order_request.deviation    = order_deviation;         // Maximal allowed deviation
   order_request.type_filling = ORDER_FILLING_FOK;       // Order execution type
   order_request.comment      = "MeInvestment";          // Order comment
  }
//+------------------------------------------------------------------+
//| OrderPreCheck: Checks basic conditions before sending an order   |
//+------------------------------------------------------------------+
bool OrderPreCheck()
  {
   // Check if the current spread is less than the maximum allowed spread.
   if(SymbolInfoInteger(Symbol(), SYMBOL_SPREAD) < order_spread)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//| OrderExecute: Sets up and sends the order request                  |
//+------------------------------------------------------------------+
bool OrderExecute(ENUM_ORDER_TYPE order_type)
  {
   int digits = int(SymbolInfoInteger(Symbol(), SYMBOL_DIGITS));
   double point = SymbolInfoDouble(Symbol(), SYMBOL_POINT);
   double price = 0;
   
   // Determine price based on order type.
   switch(order_type)
     {
      case ORDER_TYPE_BUY:
         price = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK), digits);
         break;
      case ORDER_TYPE_SELL:
         price = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID), digits);
         break;
      default:
         break;
     }
     
   // Use AutoSL and AutoTP calculations.
   double sl = AutoStopLoss(order_type);
   double tp = AutoTakeProfit(order_type);
   
   // If AutoSL/TP functions return 0 (error), fall back to fixed values.
   if(sl == 0)
     sl = (order_type == ORDER_TYPE_BUY) ? NormalizeDouble(price - order_sl * point, digits)
                                         : NormalizeDouble(price + order_sl * point, digits);
   if(tp == 0)
     tp = (order_type == ORDER_TYPE_BUY) ? NormalizeDouble(price + order_tp * point, digits)
                                         : NormalizeDouble(price - order_tp * point, digits);
   
   order_request.price = price;
   order_request.sl    = sl;
   order_request.tp    = tp;
   order_request.type  = order_type;
   
   return OrderSend(order_request, order_result);
  }
//+------------------------------------------------------------------+
//| OrderPostCheck: Validates the result of the order execution      |
//+------------------------------------------------------------------+
bool OrderPostCheck()
  {
   if(order_result.retcode == TRADE_RETCODE_DONE)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
//| OrderDeinit: Resets the order request and result structures        |
//+------------------------------------------------------------------+
void OrderDeinit()
  {
   ZeroMemory(order_request);
   ZeroMemory(order_result);
  }
//+------------------------------------------------------------------+
//| OrderPlace: Main function to place an order after running checks   |
//+------------------------------------------------------------------+
bool OrderPlace(ENUM_ORDER_TYPE order_type)
  {
   // Check if a similar order already exists.
   if(OrdersParallel(order_type))
     {
      Print("Stage 00 error! Similar order exists.");
      return false;
     }

   if(!OrderPreCheck())
     {
      Print("Stage 01 error! Pre-check failed.");
      return false;
     }

   if(!OrderExecute(order_type))
     {
      Print("Stage 02 error! Order execution failed.");
      return false;
     }

   if(!OrderPostCheck())
     {
      Print("Stage 03 error! Order post-check failed.");
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
//| OrdersParallel: Helper function to check if a similar order exists |
//+------------------------------------------------------------------+
bool OrdersParallel(ENUM_ORDER_TYPE order_type)
  {
   // Convert order type (ENUM_ORDER_TYPE) to the corresponding position type.
   ENUM_POSITION_TYPE pos_type = (order_type == ORDER_TYPE_BUY) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
   int totalPositions = PositionsTotal();
   
   for(int i = 0; i < totalPositions; i++)
     {
      // Retrieve the ticket for the current position.
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      
      // Select the position using its ticket.
      if(!PositionSelectByTicket(ticket))
         continue;
      
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;
      
      if(PositionGetInteger(POSITION_MAGIC) != order_magic)
         continue;
      
      if(PositionGetInteger(POSITION_TYPE) != pos_type)
         continue;
      
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
