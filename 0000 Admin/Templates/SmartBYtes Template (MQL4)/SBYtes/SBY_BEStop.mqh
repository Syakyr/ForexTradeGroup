//+------------------------------------------------------------------+
//|                                                   SBY_BEStop.mqh |
//|                                  Copyright 2016-2017, SmartBYtes |
//|                   Breakeven Stop Library for SmartBYtes Template |
//+------------------------------------------------------------------+

// This is the breakeven stop module for the SmartBYtes template. 

#property copyright "Copyright 2016-2017, SmartBYtes"
#property version   "1.02"
#property link      "https://github.com/AmadeusSG/ForexTradeGroup"
#property strict

#include <SBYtes/SBY_Main.mqh>

/* 

v1.0: 
- Adapted from the Falcon template by Lucas Liew 
  (https://github.com/Lucas170/The-Falcon).

v1.01:
- Added new comments to describe what each template-
  defined function does

v1.02:
- Added link

*/

//+------------------------------------------------------------------+
//| Setup                                                            |
//+------------------------------------------------------------------+

extern string  BEStopsHeader="----------Breakeven Stops Settings-----------"; //.
extern bool    UseBreakevenStops=False;   // BE Stop?
extern double  BreakevenBuffer=0;         // BE Buffer (pips)

//----------Errors Handling Settings-----------//

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
   1) BreakevenStopAll

*/

//+------------------------------------------------------------------+
//| Breakeven Stop                                                   |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function sets breakeven stops for all positions

void BreakevenStopAll(){

   if (UseBreakevenStops){
      for(int i=OrdersTotal()-1; i>=0; i--){
         bool Modify=false;
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true && OrderSymbol()==Symbol() && 
            OrderMagicNumber()==MagicNumber){
            RefreshRates();
            if(OrderType()==OP_BUY && (Bid-OrderOpenPrice())>(BreakevenBuffer*P*Point)){
               if(OnJournaling)Print("EA Journaling: Trying to modify order "+(string)OrderTicket()+" ...");
               HandleTradingEnvironment();
               Modify=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,CLR_NONE);
               if(OnJournaling && !Modify) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                 GetErrorDescription(GetLastError()));
               if(OnJournaling &&  Modify) Print("EA Journaling: Order successfully modified, breakeven stop updated.");
            }
            if(OrderType()==OP_SELL && (OrderOpenPrice()-Ask)>(BreakevenBuffer*P*Point)){
               if(OnJournaling)Print("EA Journaling: Trying to modify order "+(string)OrderTicket()+" ...");
               HandleTradingEnvironment();
               Modify=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,CLR_NONE);
               if(OnJournaling && !Modify) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                 GetErrorDescription(GetLastError()));
               if(OnJournaling &&  Modify) Print("EA Journaling: Order successfully modified, breakeven stop updated.");
            }
         }
      }
   }
}
