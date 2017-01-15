#SIMPLE TURTLE BOT

##Main Instructions
 
###ENTRY RULES
####Long
When closing price is equal to or crosses Donchian(20) upper bound from the bottom.
SMA(40) is greater than SMA(80). This indicates that we are in a up trend.
####Short
When closing price is equal to or crosses Donchian(20) lower bound from the top. 
SMA(40) is less than SMA(80). This indicates that we are in a down trend.
***

###EXIT RULES
####TP Long
Exit the long trade when closing price is equal to or crosses Donchian(10) lower bound from the top.
####TP Short
Exit the short trade when closing price is equal to or crosses Donchian(10) upper bound from the bottom.
####SL 
Exit trade when closing price travelled 1 ATR in the adverse direction.
***

###PREFERRED TIMEFRAME
None.
###PREFERRED INSTRUMENT
None.
####Other Information
"Donchian Channels.mql4" is to be installed in the Indicators folder for the strategy to run effectively. The function to use is:
~~~
iCustom(string symbol, 			// Symbol traded
        int timeframe, 			// Timeframe traded
        "Donchian Channels", 	// Name of Indicator
        int periods,			// Number of periods counted
        int extremes,			// Read the note below
        int margins,			// Read the note below
        int shift,				// Number of period shifts to consider
        );
~~~
***

## Ambiguous Variables to Test