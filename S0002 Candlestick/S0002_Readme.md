#CANDLESTICK BOT


##Main Instructions
 
###ENTRY RULES
####Long
When low of a hammer candle is lower than the lower band of the Keltner channel of period 20 (with *k* = 2)
*k* is the coefficient of the pip distance from MA of period 20, by the formula of:
$$KC_{lower} = {MA(20) - k \times ATR(20)}$$

####Short
When high of a hanging man candle is greater than the upper band of Keltner channel of period 20 (with *k* = 2)
*k* is the coefficient of the pip distance from MA of period 20, by the formula of:
$$KC_{upper} = {MA(20) + k \times ATR(20)}$$

###EXIT RULES
####TP Long
Exit the long trade when closing price is higher than the opening price by  $3 \times ATR(20)$ of the opening price.
####TP Short
Exit the long trade when closing price is lower than the opening price by  $3 \times ATR(20)$ of the opening price.
####SL 
Exit trade when closing price travelled $3 \times ATR(20)$ in the adverse direction.
####Other Conditions
Exit trade after 10 periods otherwise.

###OTHER PARAMETERS
####Preferred Timeframe(s)
None
####Preferred Instrument(s)
None.
####Preferred Risk Management
2% of capital risked per trade
####Other Information
\#I0001 is to be installed. 