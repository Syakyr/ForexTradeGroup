//+------------------------------------------------------------------+
//|                                                   PriceStrip.mq4 |
//|                                     Copyright 2017, SmartBytesSG |
//|                  https://github.com/SmartBYtesSG/ForexTradeGroup |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, SmartBytesSG"
#property link      "https://github.com/SmartBYtesSG/ForexTradeGroup"
#property version   "1.00"
#property strict

extern string FileName = "ClosePrice";

int handle;
string out, // Output on chart
       fname = FileName + "_" + Symbol() + ".csv";  // Filename rewritten
datetime timecheck = Time[1];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   // NOTE: This will reset the csv file, and it will reset every time the chart changes timeframe.
   
   // Initialise handle from file name
   handle = FileOpen(fname, FILE_CSV|FILE_READ|FILE_WRITE);
   
   if (handle>0){
      string date;
      string closeprice;
      
      // Writes the header
      FileWrite(handle,"TimeStamp", "Close");
      
      // Writes the last 100 close prices from the chart
      for(int i = 100; i > 0; i--){
         date = TimeToStr(Time[i]);
         closeprice = DoubleToStr(Close[i], 3);
         FileWrite(handle, date, closeprice);
      }
   }
   FileClose(handle);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(timecheck != Time[1]){
      
      timecheck = Time[1];    // Resets timecheck variable
      handle = FileOpen(fname,FILE_CSV|FILE_READ|FILE_WRITE);
      Print("New Candle: " + TimeToStr(Time[1]));
      
      // This checks whether a new candle has been formed
      if(handle>0){
         
         string date       = TimeToStr(Time[1]),
                closeprice = DoubleToStr(Close[1], 3);
         
         FileSeek(handle, 0, SEEK_END);
         out = date + ", " + closeprice;
         //---- add data to the end of file        
         FileWrite(handle, date, closeprice);        // write the collected data
         FileClose(handle);                          // close the file every time your file process done
         
      }
      // Prepare Comment line for the trades
      Comment(out);
   }
}
//+------------------------------------------------------------------+