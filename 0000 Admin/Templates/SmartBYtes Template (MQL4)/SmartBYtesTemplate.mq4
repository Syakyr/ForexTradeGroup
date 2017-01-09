//+------------------------------------------------------------------+
//|                                     SmartBYtes EA Template v1.01 |
//|                                       Copyright 2017, SmartBYtes |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright 2017, SmartBYtes"
#property version   "1.02"
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
extern int     FastMAPeriod=10;        //Fast MA Period
extern int     SlowMAPeriod=50;        //Slow MA Period
extern ENUM_TF TimeFrame=TF_H1;        //MA Timeframe
extern ENUM_MA_METHOD MAType=MODE_SMA; //MA Type

//+------------------------------------------------------------------+
//| Include Files                                                    |
//+------------------------------------------------------------------+
// To include whatever that is needed for the strategy

#include <SBYtes/SBY_VolGen.mqh>                // General Volatility Settings

#include <SBYtes/SBY_TPSL.mqh>                  // Hard TP/SL Settings
#include <SBYtes/SBY_VolTPSL.mqh>               // Hard Volatility TP/SL Settings
#include <SBYtes/SBY_TPSLHidden.mqh>            // Hidden TP/SL Settings
#include <SBYtes/SBY_VolTPSLHidden.mqh>         // Hidden Volatility TP/SL Settings

#include <SBYtes/SBY_OpenMarket.mqh>            // Instant Execution Order Settings
#include <SBYtes/SBY_PendingMarket.mqh>         // Pending Order Settings

#include <SBYtes/SBY_BEStop.mqh>                // Breakeven Stop Settings
#include <SBYtes/SBY_BEStopHidden.mqh>          // Hidden Breakeven Stop Settings
#include <SBYtes/SBY_TrailStop.mqh>             // Trailing Stop Settings
#include <SBYtes/SBY_TrailStopHidden.mqh>       // Hidden Trailing Stop Settings
#include <SBYtes/SBY_VolTrailStop.mqh>          // Volatility Trailing Stop Settings
#include <SBYtes/SBY_VolTrailStopHidden.mqh>    // Hidden Volatility Trailing Stop Settings

//----------Service Variables-----------//

// Trading Rules Service Variables
// Change this as you see fit.
double FastMA1, SlowMA1;

int CrossTrigArraySize = 1;         // Number of variables which looks for crosses
int OrderNumber;                    // Variable to store order number for error checking

//+------------------------------------------------------------------+
//| Expert Initialization                                            |
//+------------------------------------------------------------------+
int init(){
   
   MainInitialise();                      // Checking if the account is 4/5 digit broker, and whether it is running on a Yen pair
   CrossInitialise(CrossTrigArraySize);   // Initialises the number of crosses used defined by CrossTrigArraySize

//----------(Hidden) TP, SL and Breakeven Stops Variables-----------  

// If EA disconnects abruptly and there are open positions from this EA, records form these arrays will be gone.
// Block or delete the lines according to your needs in your strategy.
   if(UseHiddenStopLoss)       ArrayResize(HiddenSLList,MaxPositionsAllowed,0);          // If SBY_TPSLHidden.mqh is activated
   if(UseHiddenTakeProfit)     ArrayResize(HiddenTPList,MaxPositionsAllowed,0);          // If SBY_TPSLHidden.mqh is activated
   if(UseHiddenBreakevenStops) ArrayResize(HiddenBEList,MaxPositionsAllowed,0);          // If SBY_BEStopHidden.mqh is activated
   if(UseHiddenTrailingStops)  ArrayResize(HiddenTrailingList,MaxPositionsAllowed,0);    // If SBY_TrailStopHidden.mqh is activated
   if(UseVolTrailingStops)     ArrayResize(VolTrailingList,MaxPositionsAllowed,0);       // If SBY_VolTrailStop.mqh is activated
   if(UseHiddenVolTrailing)    ArrayResize(HiddenVolTrailingList,MaxPositionsAllowed,0); // If SBY_VolTrailStopHidden.mqh is activated

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
   FastMA1=iMA(Symbol(),TimeFrame,FastMAPeriod,0, MAType, PRICE_CLOSE,1);
   SlowMA1=iMA(Symbol(),TimeFrame,SlowMAPeriod,0, MAType, PRICE_CLOSE,1);
   
   // Use CrossTriggered array variable to store crossing signals
   // Change CrossTrigArraySize variable to store more crossing signals
   CrossTriggered[0]=Crossed(0,FastMA1,SlowMA1);
   
//----------TP, SL, Breakeven and Trailing Stops Variables-----------
   
   GetMyATR();                // If SBY_VolGen.mqh is activated
   //InitialiseHardTPSL();      // If SBY_TPSL.mqh is activated (Turn off is SBY_VolTPSL.mqh is activated)
   InitialiseVolTPSL();       // If SBY_VolTPSL.mqh is activated
   BreakevenStopAll();        // If SBY_BEStops.mqh is activated
   TrailingStopAll();         // If SBY_Trailstop.mqh is activated
   InitialiseVolTrailStop();  // If SBY_VolTrailStop.mqh is activated
   
//----------(Hidden) TP, SL, Breakeven and Trailing Stops Variables-----------  
   
   // If SBY_TPSLHidden.mqh is activated
   if(UseHiddenStopLoss) TriggerStopLossHidden();
   if(UseHiddenTakeProfit) TriggerTakeProfitHidden();
   
   // If SBY_BEStopsHidden.mqh is activated
   if(UseHiddenBreakevenStops){ UpdateHiddenBEList(); SetAndTriggerBEHidden(); }
   
   // If SBY_TrailStopHidden.mqh is activated
   if(UseHiddenTrailingStops){ UpdateHiddenTrailingList(); SetAndTriggerHiddenTrailing(); }

   // If SBY_VolTrailStopHidden.mqh is activated
   if(UseHiddenVolTrailing){ UpdateHiddenVolTrailingList(); TriggerAndReviewHiddenVolTrailing(); }

//----------Exit Rules (All Opened Positions)-----------

   // Modify the ExitSignal() function to suit your needs.

   if(CountPosOrders(OP_BUY)>=1 && ExitSignal(CrossTriggered[0])==2){ 
      // Close Long Positions
      CloseOrderPosition(OP_BUY); 
   }
   if(CountPosOrders(OP_SELL)>=1 && ExitSignal(CrossTriggered[0])==1){ 
      // Close Short Positions
      CloseOrderPosition(OP_SELL);
   }

//----------Entry Rules (Market and Pending) -----------

   if(!IsLossLimitBreached(EntrySignal(CrossTriggered[0])) &&
      !IsMaxPositionsReached() 
      && !IsVolLimitBreached() // If SBY_VolGen.mqh is activated
      ){
      
      if(EntrySignal(CrossTriggered[0])>0){
         int TYPE=0;
         if(EntrySignal(CrossTriggered[0])==1) TYPE = OP_BUY;
         if(EntrySignal(CrossTriggered[0])==2) TYPE = OP_SELL;

         // Open Positions
         OrderNumber=OpenPositionMarket(TYPE,Stop,Take);
   
         // If SBY_TPSLHidden.mqh is activated
         // Set Stop Loss and Take Profit value for Hidden SL/TP
         // Disable if SBY_VolTPSLHidden.mqh is also activated
         //SetStopLossHidden(OrderNumber);
         //SetTakeProfitHidden(OrderNumber);
         
         // If SBY_TPSLHidden.mqh is activated
         SetVolStopLossHidden(OrderNumber);
         SetVolTakeProfitHidden(OrderNumber);
         
         // Set Volatility Trailing Stop Level           
         SetVolTrailingStop(OrderNumber);
         
         // Set Hidden Volatility Trailing Stop Level 
         SetHiddenVolTrailing(OrderNumber);
      }
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
