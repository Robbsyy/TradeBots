#ifndef POSITION_PROFIT_RANGE_MQH
#define POSITION_PROFIT_RANGE_MQH

//+------------------------------------------------------------------+
//| Helper: PositionProfitRange                                      |
//| Purpose: Checks if an open position of a given type and magic   |
//|          number has a profit within the specified range.        |
//+------------------------------------------------------------------+
bool PositionProfitRange(ENUM_ORDER_TYPE order_type, ulong magic, double min_profit, double max_profit)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(!ticket)
         continue;

      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;

      if((ulong)PositionGetInteger(POSITION_MAGIC) != magic)
         continue;

      if(PositionGetInteger(POSITION_TYPE) != order_type)
         continue;

      double profit = PositionGetDouble(POSITION_PROFIT);
      if(profit >= min_profit && profit <= max_profit)
         return true;
   }

   return false;
}

#endif // POSITION_PROFIT_RANGE_MQH