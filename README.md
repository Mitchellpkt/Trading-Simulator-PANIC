# Trading_Simulator_PANIC
Crypto/USD trading pair simulations, for risky day-trading training.

Early P4N!C simulator research, identifying the appropriate data transformations that mask temporal context without overly-obfuscating information that must be retained for trading indicators. This was some light basic research behind our interactive gamified training simulator. See subfolder containing demo figures. Contact mitchellpkt for details about front-end implementation (proprietary)

Back-end code here snips out an N (~60) day window randomly from the coin's exchange rate history, scales it to current spot price, to recontextualize, then mixes in a noise vector to obfuscate particularly identifiable features that could unintentionally reveal the time frame.
