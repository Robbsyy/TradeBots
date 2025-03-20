#ifndef POSITION_CHECK_BY_TYPE_MQH
#define POSITION_CHECK_BY_TYPE_MQH

//+------------------------------------------------------------------+
//| Helper: PositionCheckByType                                      |
//| Purpose: Checks whether an open position of a given order type  |
//|          (buy or sell) with the specified magic number already  |
//|          exists for the current symbol.                         |
//+------------------------------------------------------------------+
bool PositionCheckByType(ENUM_ORDER_TYPE order_type, ulong magic)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(!ticket)
         continue;
      
      if(PositionGetString(POSITION_SYMBOL) != Symbol())
         continue;
      
      // Cast the magic from the position to ulong for comparison.
      if((ulong)PositionGetInteger(POSITION_MAGIC) != magic)
         continue;
      
      if(PositionGetInteger(POSITION_TYPE) != order_type)
         continue;
      
      return true; // Matching position exists.
   }
   return false;
}

#endif // POSITION_CHECK_BY_TYPE_MQH