//+------------------------------------------------------------------+
//|                                           tick_collector_1.2.mq4 |
//+------------------------------------------------------------------+

//---- input parameters
string s1="EURCHF", s2="EURUSD", s3="USDJPY", s4="GBPUSD", s5="USDCHF", s6="CHFJPY";
string SymbolSuffix     = "";         
string S1, S2, S3, S4, S5, S6, OStr="", out;    
int y, d, m; 
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 
    if (StringLen(Symbol()) > 6)
        SymbolSuffix = StringSubstr(Symbol(), 6, 0);    
    else SymbolSuffix = "";
    
   S1=s1+SymbolSuffix;
   S2=s2+SymbolSuffix;
   S3=s3+SymbolSuffix;
   S4=s4+SymbolSuffix;
   S5=s5+SymbolSuffix;
   S6=s6+SymbolSuffix;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
   int size, ho;
   string hdr="Date/Time,",fname;
   string mStr, dStr, yStr;
   OStr="";
   y = Year();
   m = Month();
   d = Day();
   
   if(m<10) mStr = "0"+DoubleToStr(m,0);
   else mStr = DoubleToStr(m,0);
   if(d<10) dStr = "0"+DoubleToStr(d,0);
   else dStr = DoubleToStr(d,0);
   yStr = DoubleToStr(y,0);
   
   fname = "ticks_"+mStr+"_"+dStr+"_"+yStr+".csv";       
   hdr = hdr + s1+","+s2+","+s3+","+s4+","+s5+","+s6+"\n";
   
   ho=FileOpen(fname,FILE_CSV|FILE_READ|FILE_WRITE, ";");  // open a file
   if(ho>0)                                 
   {
        size=FileSize(ho);
        if(size==0)
        {
            // new file, we need to add header line to output
            OStr = hdr;
        }
        string dt=TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS);
        OStr = OStr + dt + "," + MarketInfo(S1,MODE_BID)+","+MarketInfo(S2,MODE_BID)+"," + MarketInfo(S3,MODE_BID)+"," +
               MarketInfo(S4,MODE_BID)+","+MarketInfo(S5,MODE_BID)+","+MarketInfo(S6,MODE_BID);
        FileSeek(ho, 0, SEEK_END);
        out = hdr + OStr;
        //---- add data to the end of file        
        FileWrite(ho,OStr);                     // write the collected data
        FileClose(ho);                          // close the file every time your file process done
   }
   // Prepare Comment line for the trades
  ChartComment();
   return(0);
}//int start

void ChartComment()
{
   string sComment   = "";
   string sp         = "****************************************\n";
   string NL         = "\n";
   sComment = out;
   Comment(sComment);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }