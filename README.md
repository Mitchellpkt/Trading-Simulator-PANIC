# Trading_Simulator_PANIC
Crypto/USD trading pair simulations, for risky day-trading training.

Early testing for P4N!C trading simulator, for interactive gamified training. See subfolder containing demo figures. Contact mitchellpkt for details about front-end implementation (proprietary)

Back-end code here snips out an N (~60) day window randomly from the coin's exchange rate history, scales it to current spot price, to recontextualize, then mixes in a noise vector to obfuscate particularly identifiable features that could unintentionally reveal the time frame.
