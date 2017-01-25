# Keltner Channel

The function to use is:
~~~
iCustom(string symbol, 			// Symbol traded
        int timeframe, 			// Timeframe traded
        "Keltner Channels", 	// Name of Indicator
        int periods,			// Number of periods counted
        ENUM_MA_METHOD ma_mode	// MA mode
        int atr_period,			// ATR Period
        int K,					// Coefficient of Distance from Mean
        bool atr_mode,			// Using ATR (true) or Sum(High-Low) (false)
        int shift,				// Number of period shifts to consider
        );
~~~