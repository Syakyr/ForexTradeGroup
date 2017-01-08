//+------------------------------------------------------------------+
//|                                                  SBY_VolTPSL.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|           Fixed Volatility TP/SL Library for SmartBYtes Template |
//+------------------------------------------------------------------+

// This is the fixed volatility TP/SL module for the SmartBYtes template. 
// Suitable for 1 SL/TP level only. Deprecated due to inflexibility for 
// multiple SL/TP levels. Left as a template and for simple strategies 
// that only use 1 SL/TP level/pipsize.

#property copyright "Copyright 2016, SmartBYtes"
#property strict
#property version "1.01"
#include <SBYtes/SBY_Main.mqh>
#include <SBYtes/SBY_TPSL.mqh>
#include <SBYtes/SBY_VolGen.mqh>

/* 

v1.00: 
- Adapted from the Falcon template by Lucas Liew 
  (https://github.com/Lucas170/The-Falcon), 
  for hard volatility TP/SL settings

v1.01:
- Branched off from TPSL module

TODO:
- Able to use functions to create multiple TP/SL levels

*/


//+------------------------------------------------------------------+
//| Setup                                                            |
//+------------------------------------------------------------------+

extern string  VolTPSLHeader="----------Volatility TP & SL Settings-----------"; //.
extern string  VolTPSLExplanation="If this is activated, SL/TP Pip variable changes to ATR Multiplier."; //.

extern bool    IsVolatilityStopOn=True;         // Vol SL?
extern bool    IsVolatilityTakeProfitOn=True;   // Vol TP?

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
1) InitialiseVolTPSL

*/

//+------------------------------------------------------------------+
//| Initialise Volatility TP and SL Levels                           |
//+------------------------------------------------------------------+ 
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function initialises the volatility TP and SL variables

void InitialiseVolTPSL(){
   InitialiseHardTPSL();
   if(IsVolatilityStopOn) 
      Stop=HardSLVariable*myATR/(P*Point); // Stop Loss in Pips

   if(IsVolatilityTakeProfitOn) 
      Take=HardTPVariable*myATR/(P*Point); // Take Profit in Pips
}

