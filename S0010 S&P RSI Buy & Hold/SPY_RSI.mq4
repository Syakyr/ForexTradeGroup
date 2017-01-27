//+------------------------------------------------------------------+
//|                                    S&P500 RSI Buy and Hold v1.00 |
//|                                       Copyright 2017, SmartBYtes |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright 2017, SmartBYtes"
#property version   "1.00"
#property link      "https://github.com/SmartBYtesSG/ForexTradeGroup"
#include <SBYtes/SBY_Main.mqh> // Main include file

/* 

v1.00: 
- Adapted from the Falcon template by Lucas Liew 
  (https://github.com/Lucas170/The-Falcon), 
  making the template more modular so as to reduce 
  the final filesize to use.

v1.01:
- Added new comments to describe what each template-
  defined function does
- Rewritten to show MA crossover tutorial

v1.02:
- Changed the link

*/

//+------------------------------------------------------------------+
//| Setup                                                            |
//+------------------------------------------------------------------+
extern string  TradingRulesHeader="----------Trading Rules Variables-----------";   //.
extern int     RSI_Threshold  = 10;       // RSI Threshold
extern int     RSI_Period     = 14;       // RSI Period
extern ENUM_TF TimeFrame      = TF_H1;    // Timeframe

//+------------------------------------------------------------------+
//| Include Files                                                    |
//+------------------------------------------------------------------+
// To include whatever that is needed for the strategy

#include <SBYtes/SBY_TPSL.mqh>                  // Hard TP/SL Settings

#include <SBYtes/SBY_OpenMarket.mqh>            // Instant Execution Order Settings

//----------Service Variables-----------//

// Trading Rules Service Variables
// Change this as you see fit.
double RSI,ClosePrice;

int CrossTrigArraySize = 1;         // Number of variables which looks for crosses
int OrderNumber;                    // Variable to store order number for error checking

//+------------------------------------------------------------------+
//| Expert Initialization                                            |
//+------------------------------------------------------------------+
int init(){
   
   MainInitialise();                      // Checking if the account is 4/5 digit broker, and whether it is running on a Yen pair
   CrossInitialise(CrossTrigArraySize);   // Initialises the number of crosses used defined by CrossTrigArraySize
   ClosePrice = iClose(Symbol(),TimeFrame,1);
   
   start();
   return(0);
}

//+------------------------------------------------------------------+
//| Expert Deinitialization                                          |
//+------------------------------------------------------------------+
int deinit(){
//----

//----
   return(0);
}

//+------------------------------------------------------------------+
//| Expert start                                                     |
//+------------------------------------------------------------------+
int start(){

//----------Variables to be Refreshed-----------

   OrderNumber=0; // OrderNumber used in Entry Rules

//----------Entry & Exit Variables-----------
   
   // Assigning Values to Variables
   RSI = iRSI(Symbol(),TimeFrame,RSI_Period,PRICE_CLOSE,1);
   
   // Use CrossTriggered array variable to store crossing signals
   // Change CrossTrigArraySize variable to store more crossing signals
   CrossTriggered[0]=Crossed(0,RSI,RSI_Threshold);
   
//----------Exit Rules (All Opened Positions)-----------

   // Modify the ExitSignal() function to suit your needs.

   //if(CountPosOrders(OP_BUY)>=1 && ExitSignal(CrossTriggered[0])==2){ 
   //   // Close Long Positions
   //   CloseOrderPosition(OP_BUY); 
   //}
   //if(CountPosOrders(OP_SELL)>=1 && ExitSignal(CrossTriggered[0])==1){ 
   //   // Close Short Positions
   //   CloseOrderPosition(OP_SELL);
   //}

//----------Entry Rules (Market and Pending) -----------

   if(!IsLossLimitBreached(EntrySignal(CrossTriggered[0])) &&
      //!IsMaxPositionsReached()
      (iClose(Symbol(),TimeFrame,1) != ClosePrice)
      ){
      
      if(EntrySignal(CrossTriggered[0])>0){
         int TYPE=0;
         if(EntrySignal(CrossTriggered[0])==1) TYPE = OP_BUY;

         // Open Positions
         OrderNumber=OpenPositionMarket(TYPE,Stop,Take);
   
      }
      ClosePrice = iClose(Symbol(),TimeFrame,1);
   }

   return(0);
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
   1) EntrySignal
   2) ExitSignal

*/


//+------------------------------------------------------------------+
//| Entry Signal                                                     |
//+------------------------------------------------------------------+
// Type: Customisable 
// Modify this function to suit your trading robot

// This function checks for entry signals
// If the number returned is 0, there is no signal
// If the number returned is 1, it is a buy signal
// If the number returned is 2, it is a sell signal

int EntrySignal(int CrossOccurred){
   int entryOutput=0;

   if(CrossOccurred==1) entryOutput=1; 

   if(CrossOccurred==2) entryOutput=2;

   return(entryOutput);
}

//+------------------------------------------------------------------+
//| Exit Signal                                                      |
//+------------------------------------------------------------------+
// Type: Customisable 
// Modify this function to suit your trading robot

// This function checks for exit signals
// If the number returned is 0, there is no signal
// If the number returned is 1, it is a sell close signal
// If the number returned is 2, it is a buy close signal

int ExitSignal(int CrossOccurred){
   int ExitOutput=0;

   if(CrossOccurred==1) ExitOutput=1;
   if(CrossOccurred==2) ExitOutput=2;

   return(ExitOutput);
}
