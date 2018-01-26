//=============================================================================================
// robot01
//

module robot01
(
	input	wire			arst_n,
	input	wire			clk100_in,

	output	wire			ledHeartbeat,

	input	wire			uartRxd,
	output	wire			uartTxd,

	output	wire	[5:0]	mDir,
	output	wire	[5:0]	mStep,

	output	wire	[3:0]	gpout,

	output	wire	[7:0]	LED,

	input	wire			ps3in
);


//---------------------------------------------------------------------------------------------
// clock generator
//

wire clk50, clk10, locked, clk50_rst, clk10_rst;

// generate clocks
clk_wiz_0 clk_wiz_0
(
	.clk100_in			(clk100_in),
	.clk50				(clk50),
	.clk10				(clk10),
	.locked				(locked)
);

// generate clk50 sync reset
sync_reset sync_reset_50
(
	.clk				(clk50),
	.arst_n				(arst_n),
	.locked				(locked),
	.rst				(clk50_rst)
);

// generate clk10 sync reset
sync_reset sync_reset_10
(
	.clk				(clk10),
	.arst_n				(arst_n),
	.locked				(locked),
	.rst				(clk10_rst)
);


//---------------------------------------------------------------------------------------------
// 10MHz heartbeat led
//

heartbeat heartbeat 
(
	.rst				(clk10_rst),
	.clk				(clk10),
	.led				(ledHeartbeat)
);


//---------------------------------------------------------------------------------------------
// microblaze mcs
//

wire plbEn, plbRd, plbWr, plbReady;
wire [3:0] plbBE;
wire [31:0] plbAddr, plbRdData, plbWrData;

microblaze_mcs_0 microblaze_mcs_0
(
  .Clk					(clk10),
  .Reset				(clk10_rst),
  .IO_addr_strobe		(plbEn),
  .IO_read_strobe		(plbRd),
  .IO_write_strobe		(plbWr),
  .IO_address			(plbAddr),
  .IO_byte_enable		(plbBE),
  .IO_write_data		(plbWrData),
  .IO_read_data			(plbRdData),
  .IO_ready				(plbReady),
  .UART_rxd				(uartRxd),
  .UART_txd				(uartTxd)
);


//---------------------------------------------------------------------------------------------
// six axis controller
//

wire [5:0] mAlarm;

sixaxis sixaxis
(
	.rst				(clk10_rst),
	.clk				(clk10),
	
	.plbEn				(plbEn),
	.plbRd				(plbRd),
	.plbWr				(plbWr),
	.plbBE				(plbBE),
	.plbAddr			(plbAddr),
	.plbWrData			(plbWrData),
	.plbReady			(plbReady),
	.plbRdData			(plbRdData),

	.mAlarm				(mAlarm),
	.mDir				(mDir),
	.mStep				(mStep),
	
	.gpout				(gpout),

	.ps3in				(ps3in)
);


//---------------------------------------------------------------------------------------------
// misc
//

assign LED[7:2] = mAlarm[5:0];
assign LED[1] = !uartRxd;
assign LED[0] = !uartTxd;

endmodule
