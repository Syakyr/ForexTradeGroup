//+------------------------------------------------------------------+
//|                                            SBY_VolTPSLHidden.mqh |
//|                                  Copyright 2016-2017, SmartBYtes |
//|          Hidden Volatility TP/SL Library for SmartBYtes Template |
//+------------------------------------------------------------------+

// This is the hidden volatility TP/SL module for the SmartBYtes template. 
// Suitable for 1 SL/TP level only. Deprecated due to inflexibility for 
// multiple SL/TP levels. Left as a template and for simple strategies 
// that only use 1 SL/TP level/pipsize.

#property copyright "Copyright 2016-2017, SmartBYtes"
#property version   "1.02"
#property link      "https://github.com/AmadeusSG/ForexTradeGroup"
#property strict
#include <SBYtes/SBY_Main.mqh>
#include <SBYtes/SBY_TPSLHidden.mqh>
#include <SBYtes/SBY_VolGen.mqh>

/* 

v1.00: 
- Adapted from the Falcon template by Lucas Liew 
  (https://github.com/Lucas170/The-Falcon), 
  for hidden volatility TP/SL settings

v1.01:
- Branched off from TPSLHidden module

v1.02:
- Added link

TODO:
- Able to use functions to create multiple TP/SL levels

*/

//+------------------------------------------------------------------+
//| Setup                                                            |
//+------------------------------------------------------------------+

extern string  VolTPSLHidHeader="----------Hidden TP & SL Settings-----------"; //.
extern string  VolTPSLHidExplanation="If this is activated, SL/TP Pip variable changes to ATR Multiplier."; //.

extern bool    IsVolatilityStopLossOn_Hidden=False;   // Hidden Vol SL?
extern bool    IsVolatilityTakeProfitOn_Hidden=False; // Hidden Vol TP?

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
   1) SetVolStopLossHidden
   2) SetVolTakeProfitHidden

*/

//+------------------------------------------------------------------+
//| Set Hidden Volatility Stop Loss                                  |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function calculates hidden stop loss amount and tags it to the appropriate order using an array

void SetVolStopLossHidden(int ordernum){ 
   SetStopLossHidden(ordernum,IsVolatilityStopLossOn_Hidden,PointToPip(HardSLVariable_Hidden*myATR));
}

//+------------------------------------------------------------------+
//| Set Hidden Volatility Take Profit                                |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function calculates hidden take profit amount and tags it to the appropriate order using an array

void SetVolTakeProfitHidden(int ordernum){
   SetTakeProfitHidden(ordernum,IsVolatilityTakeProfitOn_Hidden,PointToPip(HardTPVariable_Hidden*myATR));
}
