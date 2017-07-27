//+------------------------------------------------------------------+
//|                                                SBY_TrailStop.mqh |
//|                                  Copyright 2016-2017, SmartBYtes |
//|              Fixed Trailing Stop Library for SmartBYtes Template |
//+------------------------------------------------------------------+

// This is the trailing stop module for the SmartBYtes template. 

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
extern string  TrailStopsHeader="----------Trailing Stops Settings-----------"; //.
extern bool    UseTrailingStops=False; // Trail Stop?
extern double  TrailingStopDistance=0; // Trail Distance (Pips)
extern double  TrailingStopBuffer=0;   // Trail Buffer (Pips)

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
1) TrailingStopAll

*/

//+------------------------------------------------------------------+
//| Trailing Stop
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function sets trailing stops for all positions

void TrailingStopAll(){

   if (UseTrailingStops){
      for(int i=OrdersTotal()-1; i>=0; i--){ // Looping through all orders
         bool Modify=false;
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true && OrderSymbol()==Symbol() && 
            OrderMagicNumber()==MagicNumber){
            RefreshRates();
            if(OrderType()==OP_BUY  && ((Bid-OrderStopLoss()>((TrailingStopDistance+TrailingStopBuffer)*P*Point)) ||
               (OrderStopLoss()==0))){
               if(OnJournaling)Print("EA Journaling: Trying to modify order "+(string)OrderTicket()+" ...");
               HandleTradingEnvironment();
               Modify=OrderModify(OrderTicket(),OrderOpenPrice(),Bid-TrailingStopDistance*P*Point,OrderTakeProfit(),0,CLR_NONE);
               if(OnJournaling && !Modify) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                 GetErrorDescription(GetLastError()));
               if(OnJournaling &&  Modify) Print("EA Journaling: Order successfully modified, trailing stop changed.");
            }
            if(OrderType()==OP_SELL && ((OrderStopLoss()-Ask>((TrailingStopDistance+TrailingStopBuffer)*P*Point)) || 
               (OrderStopLoss()==0))){
               if(OnJournaling)Print("EA Journaling: Trying to modify order "+(string)OrderTicket()+" ...");
               HandleTradingEnvironment();
               Modify=OrderModify(OrderTicket(),OrderOpenPrice(),Ask+TrailingStopDistance*P*Point,OrderTakeProfit(),0,CLR_NONE);
               if(OnJournaling && !Modify) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                 GetErrorDescription(GetLastError()));
               if(OnJournaling &&  Modify) Print("EA Journaling: Order successfully modified, trailing stop changed.");
            }
         }
      }
   }
}