//+------------------------------------------------------------------+
//|                                                     SBY_Main.mqh |
//|                                       Copyright 2016, SmartBYtes |
//|                             Main Library for SmartBYtes Template |
//+------------------------------------------------------------------+

// This is the main module for the SmartBYtes Template, and must be 
// included in any SmartBYtes Template files. It contains the essential
// functions needed to make the template work.

#property copyright "Copyright 2016, SmartBYtes"
#property strict
#property version "1.01"

/* 

v1.0: 
- Adapted from the Falcon template by Lucas Liew 
  (https://github.com/Lucas170/The-Falcon), 
  putting only the essential functions in the main
  module.

v1.01:
- Added new comments to describe what each template-
  defined function does
- Changed CheckLot function to follow CaptProt input
  to set lotsize to 0 if calculated lotsize is less than
  the minimum lots required by the broker so as to not
  exceed the risk level being set
- Fixed the bug when using Crossed functions

TODO: Add email function
*/

//+------------------------------------------------------------------+
//| Setup                                                            |
//+------------------------------------------------------------------+

extern string  PosHeader="----------Position Sizing Settings-----------";  //.
extern bool    IsSizingOn=True;              // Fractional Sizing?
extern bool    CaptProt=True;                // Capital Protection?
extern double  Risk=1;                       // Risk per trade, or fixed lot-size 

extern string  MaxOrdersHeader="----------Max Orders-----------"; //.
extern int     MaxPositionsAllowed=1;        // Max Positions Allowed

extern string  MaxLossHeader="----------Set Max Loss Limit-----------"; //.
extern bool    IsLossLimitActivated=False;   // Loss Limit?
extern double  LossLimitPercent=50;          // Loss Limit %

extern string  EAGenHeader="----------EA General Settings-----------"; //.
extern int     MagicNumber=12345;            // Magic Number
extern int     Slippage=3;                   // Slippage Pips
extern bool    IsECNbroker = false;          // ECN Broker?
extern bool    OnJournaling = true;          // Journalling Log

//----------Errors Handling Settings-----------//
int    RetryInterval=100; // Pause Time before next retry (in milliseconds)
int    MaxRetriesPerTick=10;


// Service Variables for Crossing Signal
int    CrossTriggered[], CurrentDirection[], LastDirection[];
bool   FirstTime[];

double P,YenPairAdjustFactor;
double Stop=0,Take=0;

enum ENUM_TF {
   TF_Curr=0,  //Current
   TF_M1=1,    //M1
   TF_M5=5,    //M5
   TF_M15=15,  //M15
   TF_M30=30,  //M30
   TF_H1=60,   //H1
   TF_H4=240,  //H4
   TF_D1=1440, //D1
   TF_W1=10080 //W1
};

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                     FUNCTIONS LIBRARY                                   
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*

Content:
   1) MainInitialise
   2) GetP
   3) GetYenAdjustFactor
   4) PointToPip
   5) GetLot
   6) CheckLot
   7) CrossInitialise
   8) Crossed
   9) CountPosOrders
  10) IsMaxPositionsReached
  11) CloseOrderPosition
  12) IsLossLimitBreached
  13) HandleTradingEnvironment
  14) ErrorDescription

*/

//+------------------------------------------------------------------+
//| Template Initialisation                                          |
//+------------------------------------------------------------------+ 
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function initialises the template for universal use

void MainInitialise(){
   P=GetP(); // To account for 5 digit brokers. Used to convert pips to decimal place
   YenPairAdjustFactor=GetYenAdjustFactor(); // Adjust for YenPair
}
//+------------------------------------------------------------------+
//| Check for 4/5 Digits Broker                                      |
//+------------------------------------------------------------------+ 
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function returns P, which is used for converting pips to decimals/points

// Some definitions: Pips vs Point
// 1 pip   = 0.0001 on a 4 digit broker and 0.00010 on a 5 digit broker
// 1 point = 0.0001 on a 4 digit broker and 0.00001 on a 5 digit broker
     
int GetP(){
   int output;
   if(Digits==5 || Digits==3) output=10;else output=1;
   return(output);
}

//+------------------------------------------------------------------+
//| Yen Adjustment Factor                                            |
//+------------------------------------------------------------------+ 
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function returns a constant factor, which is used for position sizing for Yen pairs

int GetYenAdjustFactor(){
   int output= 1;
   if(Digits == 3|| Digits == 2) output = 100;
   return(output);
}

//+------------------------------------------------------------------+
//| Price to Pip Converter                                           |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function converts price difference to pips

double PointToPip(double point){
   return (point/(P*Point));
}

//+------------------------------------------------------------------+
//| Position Sizing Algorithm                                        |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function is our sizing algorithm

double GetLot(double STOP){
   double Lots;

   if(IsSizingOn){
      // Sizing Algo based on account size
      Lots=Risk*0.01*AccountBalance()/(MarketInfo(Symbol(),MODE_LOTSIZE)*MarketInfo(Symbol(),MODE_TICKVALUE)*STOP*P*Point)
           *YenPairAdjustFactor; // Adjust for Yen Pairs
   } else {
      Lots=Risk;
   }
   Lots=NormalizeDouble(Lots,2); // Round to 2 decimal place

   return(Lots);
}

//+------------------------------------------------------------------+
//| Check Lotsize                                                    |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function checks if our Lots to be trade satisfies any broker limitations

double CheckLot(double Lot){

   double LotToOpen=0;
   
   // Round it up to a lower nearest lot size that can be accepted by the broker
   LotToOpen=NormalizeDouble(Lot,2);
   LotToOpen=MathFloor(LotToOpen/MarketInfo(Symbol(),MODE_LOTSTEP))*MarketInfo(Symbol(),MODE_LOTSTEP);
   
   // Check if lotsize is smaller than the minimum lotsize required
   if(LotToOpen<MarketInfo(Symbol(),MODE_MINLOT)){
      if (CaptProt) LotToOpen=0;
      else LotToOpen=MarketInfo(Symbol(),MODE_MINLOT);
   }
   
   // Check if lotsize is greater than the maximum lotsize allowed
   if(LotToOpen>MarketInfo(Symbol(),MODE_MAXLOT))LotToOpen=MarketInfo(Symbol(),MODE_MAXLOT);
   LotToOpen=NormalizeDouble(LotToOpen,2);
   
   // Journals the change, if any
   if(OnJournaling && LotToOpen!=Lot){
      Print("EA Journaling: Trading Lot has been changed by CheckLot function. "+
            "Requested lot: "+(string)Lot+". Lot to open: "+(string)LotToOpen);
      if(CaptProt && LotToOpen==0.00) 
         Print("The lotsize calculated is smaller than the minimum lotsize required. "+
               "Please increase the risk level or disable CaptProt should you wish to open the minimum lotsize regardless.");
   }
   
   return(LotToOpen);
}
  
//+------------------------------------------------------------------+
// Crossing Initialisation                                           |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function initialises the Crossing Signal to store the variables

void CrossInitialise(int arraysize){
   ArrayResize(CrossTriggered,arraysize,0);
   ArrayResize(CurrentDirection,arraysize,0);
   ArrayResize(LastDirection   ,arraysize,0);
   ArrayResize(FirstTime       ,arraysize,0);
   
   ArrayFill(CurrentDirection,0,arraysize,0);
   ArrayFill(CurrentDirection,0,arraysize,0);
   ArrayFill(CurrentDirection,0,arraysize,True);
}

//+------------------------------------------------------------------+
// Crossing Signals                                                  |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function determines if a cross happened between 2 lines/data set
 
// If Output is 0: No cross happened
// If Output is 1: Line 1 crossed Line 2 from Bottom
// If Output is 2: Line 1 crossed Line 2 from top 


int Crossed(int ID, double line1,double line2){
   if(line1>line2) CurrentDirection[ID]=1;  // line1 above line2
   if(line1<line2) CurrentDirection[ID]=2;  // line1 below line2
   
   // Need to check if this is the first time the function is run
   if(FirstTime[ID]==true){ 
      FirstTime[ID]=false; // Change variable to false
      LastDirection[ID]=CurrentDirection[ID]; // Set new direction
      return (0); // No output
   }
   
   // If not the first time and there is a direction change
   if(CurrentDirection[ID]!=LastDirection[ID] && FirstTime[ID]==false){ 
      LastDirection[ID]=CurrentDirection[ID]; // Set new direction
      return(CurrentDirection[ID]); // 1 for up, 2 for down
   } else {
      return(0);  // No direction change
   }
}

//+------------------------------------------------------------------+
//| Count Positions                                                  |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function counts number of positions/orders of OrderType TYPE of the
// same magic number

int CountPosOrders(int TYPE, int magicnumberoffset=0){
   int Orders=0;
   for(int i=0; i<OrdersTotal(); i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true && 
         OrderMagicNumber()==MagicNumber+magicnumberoffset && OrderType()==TYPE)
         Orders++;
   }
   return(Orders);
}

//+------------------------------------------------------------------+
//| Max Positions                                                    |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function checks the number of positions we are holding against the maximum allowed 

// Definitions: Position vs Orders
//              Position describes an opened trade
//              Order is a pending trade
// 
// How to use in a sentence: Jim has 5 buy limit orders pending 10 minutes ago. The market just crashed. 
// The orders were executed and he has 5 losing positions now lol.

bool IsMaxPositionsReached(int magicnooffset=0){
   int result=False;
   if(CountPosOrders(OP_BUY,magicnooffset)+CountPosOrders(OP_SELL,magicnooffset)>MaxPositionsAllowed){
      result=True;
      if(OnJournaling) Print("Max Orders Exceeded");
   } else if (CountPosOrders(OP_BUY,magicnooffset)+CountPosOrders(OP_SELL,magicnooffset)==MaxPositionsAllowed) result=True;

   return(result);
}

//+------------------------------------------------------------------+
//| Close/Delete Orders and Positions                                |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function closes all positions of type TYPE or Deletes pending orders of type TYPE with
// the same magic number

bool CloseOrderPosition(int TYPE, int magicnumberoffset=0){
   int ordersPos=OrdersTotal();
   Print("Running CloseOrderPosition...");
   for(int i=ordersPos-1; i>=0; i--){
      // Note: Once pending orders become positions, 
      //       OP_BUYLIMIT  and OP_BUYSTOP  becomes OP_BUY, 
      //       OP_SELLLIMIT and OP_SELLSTOP becomes OP_SELL
      
      if(TYPE==OP_BUY || TYPE==OP_SELL){
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true &&
            OrderMagicNumber()==MagicNumber+magicnumberoffset && OrderType()==TYPE){
            
            bool Closing=false;
            double Price=0;
            color arrow_color=0;
               if(TYPE==OP_BUY)  arrow_color=Blue;
               if(TYPE==OP_SELL) arrow_color=Green;
            if(OnJournaling) Print("EA Journaling: Trying to close position "+(string)OrderTicket()+" ...");
            HandleTradingEnvironment();
            if(TYPE==OP_BUY)Price=Bid; if(TYPE==OP_SELL)Price=Ask;
            Closing=OrderClose(OrderTicket(),OrderLots(),Price,(int)(Slippage*P),arrow_color);
            if(OnJournaling && !Closing) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                               GetErrorDescription(GetLastError()));
            if(OnJournaling &&  Closing) Print("EA Journaling: Position successfully closed.");
         }
      } else 
      if(TYPE==OP_BUYLIMIT || TYPE==OP_BUYSTOP || TYPE==OP_SELLLIMIT || TYPE==OP_SELLSTOP){
         bool Delete=false;
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){ 
            if(OrderSymbol()==Symbol() && 
               OrderMagicNumber()==MagicNumber+magicnumberoffset && OrderType()==TYPE){
               
               if(OnJournaling)Print("EA Journaling: Trying to delete order "+(string)OrderTicket()+" ...");
               HandleTradingEnvironment();
               Delete=OrderDelete(OrderTicket(),CLR_NONE);
               if(OnJournaling && !Delete) Print("EA Journaling: Unexpected Error has happened. Error Description: "+
                                                 GetErrorDescription(GetLastError()));
               if(OnJournaling &&  Delete) Print("EA Journaling: Order successfully deleted.");
            }
         }
      }
   }
   if(CountPosOrders(TYPE)==0)return(true); else return(false);
}

//+------------------------------------------------------------------+
//| Loss Limit Checker                                               |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function determines if our maximum loss threshold is breached

bool IsLossLimitBreached(int EntrySignalTrigger){

   static bool firstTick=False;
   static double initialCapital=0;
   double profitAndLoss=0;
   double profitAndLossPrint=0;
   bool output=False;

   if(IsLossLimitActivated==False) return(output);

   if(firstTick==False){
      initialCapital=AccountEquity();
      firstTick=True;
   }

   profitAndLoss=(AccountEquity()/initialCapital)-1;

   if(profitAndLoss<-LossLimitPercent/100){
      output=True;
      profitAndLossPrint=NormalizeDouble(profitAndLoss,4)*100;
      if(OnJournaling && EntrySignalTrigger!=0) Print("Entry trade triggered but not executed. Loss threshold breached. Current Loss: "+
                                                      (string)profitAndLossPrint+"%");
   }

   return(output);
}

//+------------------------------------------------------------------+
//| Handle Trading Environment                                       |
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing 

// This function checks for errors

void HandleTradingEnvironment(){
   if(IsTradeAllowed()==true) return;
   if(!IsConnected()){
      if(OnJournaling)Print("EA Journaling: Terminal is not connected to server...");
      return;
   }
   if(!IsTradeAllowed() && OnJournaling) Print("EA Journaling: Trade is not allowed for some reason...");
   if(IsConnected() && !IsTradeAllowed()){
      while(IsTradeContextBusy()==true){
         if(OnJournaling)Print("EA Journaling: Trading context is busy... Please hold on...");
         Sleep(RetryInterval);
      }
   }
   RefreshRates();
}

//+------------------------------------------------------------------+
//| Error Description                                                |                                                
//+------------------------------------------------------------------+
// Type: Fixed Template 
// Do not edit unless you know what you're doing

// This function returns the exact error

string GetErrorDescription(int error){
   string ErrorDescription="";
//---
   switch(error){
      case 0:     ErrorDescription = "NO Error. Everything should be good.";                                    break;
      case 1:     ErrorDescription = "No error returned, but the result is unknown";                            break;
      case 2:     ErrorDescription = "Common error";                                                            break;
      case 3:     ErrorDescription = "Invalid trade parameters";                                                break;
      case 4:     ErrorDescription = "Trade server is busy";                                                    break;
      case 5:     ErrorDescription = "Old version of the client terminal";                                      break;
      case 6:     ErrorDescription = "No connection with trade server";                                         break;
      case 7:     ErrorDescription = "Not enough rights";                                                       break;
      case 8:     ErrorDescription = "Too frequent requests";                                                   break;
      case 9:     ErrorDescription = "Malfunctional trade operation";                                           break;
      case 64:    ErrorDescription = "Account disabled";                                                        break;
      case 65:    ErrorDescription = "Invalid account";                                                         break;
      case 128:   ErrorDescription = "Trade timeout";                                                           break;
      case 129:   ErrorDescription = "Invalid price";                                                           break;
      case 130:   ErrorDescription = "Invalid stops";                                                           break;
      case 131:   ErrorDescription = "Invalid trade volume";                                                    break;
      case 132:   ErrorDescription = "Market is closed";                                                        break;
      case 133:   ErrorDescription = "Trade is disabled";                                                       break;
      case 134:   ErrorDescription = "Not enough money";                                                        break;
      case 135:   ErrorDescription = "Price changed";                                                           break;
      case 136:   ErrorDescription = "Off quotes";                                                              break;
      case 137:   ErrorDescription = "Broker is busy";                                                          break;
      case 138:   ErrorDescription = "Requote";                                                                 break;
      case 139:   ErrorDescription = "Order is locked";                                                         break;
      case 140:   ErrorDescription = "Long positions only allowed";                                             break;
      case 141:   ErrorDescription = "Too many requests";                                                       break;
      case 145:   ErrorDescription = "Modification denied because order too close to market";                   break;
      case 146:   ErrorDescription = "Trade context is busy";                                                   break;
      case 147:   ErrorDescription = "Expirations are denied by broker";                                        break;
      case 148:   ErrorDescription = "Too many open and pending orders (more than allowed)";                    break;
      case 4000:  ErrorDescription = "No error";                                                                break;
      case 4001:  ErrorDescription = "Wrong function pointer";                                                  break;
      case 4002:  ErrorDescription = "Array index is out of range";                                             break;
      case 4003:  ErrorDescription = "No memory for function call stack";                                       break;
      case 4004:  ErrorDescription = "Recursive stack overflow";                                                break;
      case 4005:  ErrorDescription = "Not enough stack for parameter";                                          break;
      case 4006:  ErrorDescription = "No memory for parameter string";                                          break;
      case 4007:  ErrorDescription = "No memory for temp string";                                               break;
      case 4008:  ErrorDescription = "Not initialized string";                                                  break;
      case 4009:  ErrorDescription = "Not initialized string in array";                                         break;
      case 4010:  ErrorDescription = "No memory for array string";                                              break;
      case 4011:  ErrorDescription = "Too long string";                                                         break;
      case 4012:  ErrorDescription = "Remainder from zero divide";                                              break;
      case 4013:  ErrorDescription = "Zero divide";                                                             break;
      case 4014:  ErrorDescription = "Unknown command";                                                         break;
      case 4015:  ErrorDescription = "Wrong jump (never generated error)";                                      break;
      case 4016:  ErrorDescription = "Not initialized array";                                                   break;
      case 4017:  ErrorDescription = "DLL calls are not allowed";                                               break;
      case 4018:  ErrorDescription = "Cannot load library";                                                     break;
      case 4019:  ErrorDescription = "Cannot call function";                                                    break;
      case 4020:  ErrorDescription = "Expert function calls are not allowed";                                   break;
      case 4021:  ErrorDescription = "Not enough memory for temp string returned from function";                break;
      case 4022:  ErrorDescription = "System is busy (never generated error)";                                  break;
      case 4050:  ErrorDescription = "Invalid function parameters count";                                       break;
      case 4051:  ErrorDescription = "Invalid function parameter value";                                        break;
      case 4052:  ErrorDescription = "String function internal error";                                          break;
      case 4053:  ErrorDescription = "Some array error";                                                        break;
      case 4054:  ErrorDescription = "Incorrect series array using";                                            break;
      case 4055:  ErrorDescription = "Custom indicator error";                                                  break;
      case 4056:  ErrorDescription = "Arrays are incompatible";                                                 break;
      case 4057:  ErrorDescription = "Global variables processing error";                                       break;
      case 4058:  ErrorDescription = "Global variable not found";                                               break;
      case 4059:  ErrorDescription = "Function is not allowed in testing mode";                                 break;
      case 4060:  ErrorDescription = "Function is not confirmed";                                               break;
      case 4061:  ErrorDescription = "Send mail error";                                                         break;
      case 4062:  ErrorDescription = "String parameter expected";                                               break;
      case 4063:  ErrorDescription = "Integer parameter expected";                                              break;
      case 4064:  ErrorDescription = "Double parameter expected";                                               break;
      case 4065:  ErrorDescription = "Array as parameter expected";                                             break;
      case 4066:  ErrorDescription = "Requested history data in updating state";                                break;
      case 4067:  ErrorDescription = "Some error in trading function";                                          break;
      case 4099:  ErrorDescription = "End of file";                                                             break;
      case 4100:  ErrorDescription = "Some file error";                                                         break;
      case 4101:  ErrorDescription = "Wrong file name";                                                         break;
      case 4102:  ErrorDescription = "Too many opened files";                                                   break;
      case 4103:  ErrorDescription = "Cannot open file";                                                        break;
      case 4104:  ErrorDescription = "Incompatible access to a file";                                           break;
      case 4105:  ErrorDescription = "No order selected";                                                       break;
      case 4106:  ErrorDescription = "Unknown symbol";                                                          break;
      case 4107:  ErrorDescription = "Invalid price";                                                           break;
      case 4108:  ErrorDescription = "Invalid ticket";                                                          break;
      case 4109:  ErrorDescription = "EA is not allowed to trade is not allowed. ";                             break;
      case 4110:  ErrorDescription = "Longs are not allowed. Check the expert properties";                      break;
      case 4111:  ErrorDescription = "Shorts are not allowed. Check the expert properties";                     break;
      case 4200:  ErrorDescription = "Object exists already";                                                   break;
      case 4201:  ErrorDescription = "Unknown object property";                                                 break;
      case 4202:  ErrorDescription = "Object does not exist";                                                   break;
      case 4203:  ErrorDescription = "Unknown object type";                                                     break;
      case 4204:  ErrorDescription = "No object name";                                                          break;
      case 4205:  ErrorDescription = "Object coordinates error";                                                break;
      case 4206:  ErrorDescription = "No specified subwindow";                                                  break;
      case 4207:  ErrorDescription = "Some error in object function";                                           break;
      default:    ErrorDescription = "No error or error is unknown";
   }
   return(ErrorDescription);
}
