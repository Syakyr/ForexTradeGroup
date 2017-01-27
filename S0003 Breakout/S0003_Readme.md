#BREAKOUT BOT


##Main Instructions
 
###ENTRY RULES
Current Volatility (ATR(20)) is less than Volatility (ATR(20)) 10 hours ago
####Long
Closing price crosses Keltner Channels(20) from bottom
####Short
closing price crosses Keltner Channels(20) from top

###EXIT RULES
####TP Long
Closing price moved up > 5 ATR(20)
####TP Short
Closing price moved down > 5 ATR(20)
####SL 
2 ATR(20) Hard stop
####Other Conditions
Stop after 10 periods

###OTHER PARAMETERS
####Preferred Timeframe
H1
####Preferred Instrument
None.
####Preferred Risk Management
2% per trade
####Other Information
\#0001 is required as indicator.