//+------------------------------------------------------------------+
//|                                                     SBY_TPSL.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|                      Fixed TP/SL Library for SmartBYtes Template |
//+------------------------------------------------------------------+

// This is the fixed TP/SL module for the SmartBYtes template. Suitable
// for 1 SL/TP level only. Deprecated due to inflexibility for multiple
// SL/TP levels. Left as a template and for simple strategies that only
// use 1 SL/TP level/pipsize.

#property copyright "Copyright 2016-2017, SmartBYtes"
#property version   "1.02"
#property link      "https://github.com/AmadeusSG/ForexTradeGroup"
#property strict
#include <SBYtes/SBY_Main.mqh>

/* 

v1.00: 
- Adapted from the Falcon template by Lucas Liew 
  (https://github.com/Lucas170/The-Falcon), 
  for hard TP/SL settings

v1.01:
- Added new comments to describe what each template-
  defined function does
- Seperated volatility to SBY_VolTPSL.mqh

v1.02:
- Added link

TODO:
- Able to use functions to create multiple TP/SL levels

*/


//+------------------------------------------------------------------+
//| Setup                                                            |
//+------------------------------------------------------------------+

extern string  TPSLHeader="----------TP & SL Settings-----------"; //.

extern bool    UseFixedStopLoss=True;     // Fixed SL?
extern double  HardSLVariable=6;          // Stop Loss Pips

extern bool    UseFixedTakeProfit=True;   // Fixed TP?
extern double  HardTPVariable=6;          // Take Profit Pips


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
1) InitialiseHardTPSL

*/

//+------------------------------------------------------------------+
//| Initialise Hard TP and SL Levels                                 |
//+------------------------------------------------------------------+ 
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function initialises the TP and SL variables

void InitialiseHardTPSL(){
   if(UseFixedStopLoss==False) Stop=0;
   else Stop=HardSLVariable;

   if(UseFixedTakeProfit==False) Take=0;
   else Take=HardTPVariable;
}
