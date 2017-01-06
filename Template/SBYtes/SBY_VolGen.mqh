//+------------------------------------------------------------------+
//|                                                   SBY_VolGen.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|     General Volatility Variables Library for SmartBYtes Template |
//+------------------------------------------------------------------+

// This is the general volatility module for the SmartBYtes Template. 
// It must be included in any SmartBYtes Template files if volatility
// is used.

#property copyright "Copyright 2016, SmartBYtes"
#property strict
#property version "1.01"
#include <SBYtes/SBY_Main.mqh>

/* 

v1.0: 
- Adapted from the Falcon template by Lucas Liew 
  (https://github.com/Lucas170/The-Falcon).

v1.01:
- Added new comments to describe what each template-
  defined function does

*/

//+------------------------------------------------------------------+
//| Setup                                                            |
//+------------------------------------------------------------------+

extern string  VolMeasHeader="----------Volatility Measurement Settings-----------"; //.
extern ENUM_TF atr_timeframe=TF_Curr;        //ATR Timeframe
extern int     atr_period=14;                //ATR Period

extern string  MaxVolHeader="----------Set Max Volatility Limit-----------";
extern bool    IsVolLimitActivated=False;    // Volatility Limit?
extern double  VolatilityMultiplier=3;       // In units of ATR
extern ENUM_TF MaxATRTimeframe=TF_H1;        // Max ATR Timeframe
extern int     MaxATRPeriod=14;              // Max ATR Period

double myATR;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
   1) IsVolLimitBreached
   2) GetMyATR

*/

//+------------------------------------------------------------------+
//| Is Volitility Limit Breached                                     |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function determines if our maximum volatility threshold is breached

// 2 steps to this function: 
// 1) It checks the price movement between current time and the closing price of the last completed 1min bar (shift 1 of 1min timeframe).
// 2) Return True if this price movement > VolLimitMulti * VolATR

bool IsVolLimitBreached(){

   bool output = False;
   if(IsVolLimitActivated==False) return(output);
   
   double priceMovement = MathAbs(Bid-iClose(NULL,PERIOD_M1,1)); // Not much difference if we use bid or ask prices here. We can also use iOpen at shift 0 here, it will be similar to using iClose at shift 1.
   double VolATR = iATR(NULL, MaxATRTimeframe, MaxATRPeriod, 1);
   
   if(priceMovement > VolatilityMultiplier*VolATR) output = True;

   return(output);
  }

//+------------------------------------------------------------------+
//| Retrieve ATR Value                                               |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function retrieves the current ATR value

void GetMyATR(){
   myATR=iATR(Symbol(),atr_timeframe,atr_period,1);
}