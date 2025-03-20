#ifndef POSITION_VOLUME_CHECK_MQH
#define POSITION_VOLUME_CHECK_MQH

//+------------------------------------------------------------------+
//| Helper: PositionVolumeCheck                                      |
//| Purpose: Checks if the total volume of open positions of the given |
//|          order type exceeds a specified maximum lot volume.      |
//+------------------------------------------------------------------+
bool PositionVolumeCheck(ENUM_ORDER_TYPE order_type, double max_lot)
{
   double total_volume = 0.0;
   int total_positions = PositionsTotal();

   for (int i = 0; i < total_positions; i++)
   {
      // Retrieve the ticket for the current position.
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;
      
      // Select the position by its ticket.
      if(PositionSelectByTicket(ticket))
      {
         // Compare the position type with the given order type.
         if(PositionGetInteger(POSITION_TYPE) == (int)order_type)
         {
            total_volume += PositionGetDouble(POSITION_VOLUME);
         }
      }
   }
   
   // Return true if the total volume is greater than or equal to max_lot.
   return (total_volume >= max_lot);
}

#endif // POSITION_VOLUME_CHECK_MQH