#RETRACEMENT BOT


##Main Instructions
 
###ENTRY RULES
####Long
Closing price touch bottom line of Donchian(24).
SMA(24) is greater than SMA(72). This indicates that we are in a up trend.
####Short
Closing price touch top line of Donchian(24).
SMA(24) is less than SMA(72). This indicates that we are in a down trend.

###EXIT RULES
####TP Long
closing price moved up > 0.5 * Donchian(24) width. (defined as Donchian(24) top line - bottom line) 
####TP Short
closing price moved down > 0.5 * Donchian(24) width.
####SL 
Exit when closing price move 2 * ATR(24) in the averse direction.
####Other Conditions
None

###OTHER PARAMETERS
####Preferred Timeframe
None
####Preferred Instrument
None.
####Preferred Risk Management
2% of Capital risked per trade
####Other Information
\#I0002 is to be installed.
