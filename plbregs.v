//
// c0000000  [5:0] busy mX -> mC
// c0000004  [5:0] prgm req / ack mX -> mC
// c0000008  [5:0] alarm clears / flags mX -> mC
// c000000c   [31] training mode enable
//
// c0000020        X axis
// c0000040        Y axis
// c0000060        Z axis
// c0000080        A axis
// c00000a0        B axis
// c00000c0        C axis
//
// c0000100    [0] gp output 0
// c0000104    [0] gp output 1
// c0000108    [0] gp output 2
// c000010c    [0] gp output 3
//
// c0000180 blinker 0 control program
// c0000184 bilnker 0 prescaler value (499999 = 20Hz)
// c0000188 blinker 0 long/mid/short delays
//
// c0000180 blinker 1 control program
// c0000184 bilnker 1 prescaler value (499999 = 20Hz)
// c0000188 blinker 1 long/mid/short delays
//
// c0000180 blinker 2 control program
// c0000184 bilnker 2 prescaler value (499999 = 20Hz)
// c0000188 blinker 2 long/mid/short delays
//
// c0000180 blinker 3 control program
// c0000184 bilnker 3 prescaler value (499999 = 20Hz)
// c0000188 blinker 3 long/mid/short delays
//
// c0000200 [15:0] x axis -- training hardware -- set / get current position
// c0000204 [31:0] x axis -- training hardware -- set acceleration
// c0000208 [31:0] x axis -- training hardware -- set target velocity
//
// c0000240 [15:0] y axis -- training hardware -- set / get current position
// c0000244 [31:0] y axis -- training hardware -- set acceleration
// c0000248 [31:0] y axis -- training hardware -- set target velocity
//
// c0000280 [15:0] z axis -- training hardware -- set / get current position
// c0000284 [31:0] z axis -- training hardware -- set acceleration
// c0000288 [31:0] z axis -- training hardware -- set target velocity
//
// c00002c0 [15:0] a axis -- training hardware -- set / get current position
// c00002c4 [31:0] a axis -- training hardware -- set acceleration
// c00002c8 [31:0] a axis -- training hardware -- set target velocity
//
// c0000300 [15:0] b axis -- training hardware -- set / get current position
// c0000304 [31:0] b axis -- training hardware -- set acceleration
// c0000308 [31:0] b axis -- training hardware -- set target velocity
//
// c0000340 [15:0] c axis -- training hardware -- set / get current position
// c0000344 [31:0] c axis -- training hardware -- set acceleration
// c0000348 [31:0] c axis -- training hardware -- set target velocity
//

module plbregs
(
    input   wire            	rst,            // sync active-high reset
    input   wire            	clk,            // 10MHz clock input

    input   wire            	plbEn,          // microblaze plb bus
    input   wire            	plbRd,
    input   wire            	plbWr,
    input   wire    	[3:0]   plbBE,
    input   wire    	[31:0]  plbAddr,
    input   wire    	[31:0]  plbWrData,
    output  reg	            	plbReady,
    output  reg	    	[31:0]  plbRdData,

	input	wire		[5:0]	mBusy,

	output	reg             	mX_prgmReq,
	input	wire            	mX_prgmAck,
	output	reg	 signed	[1:0]   mX_prgmDirection,
	output	reg  signed [31:0]  mX_prgmAcceleration,
	output	reg         [31:0]  mX_prgmAccelSamples,
	output	reg         [31:0]  mX_prgmCruiseSamples,

	output	reg                 mX_setEnable,
	output	reg	 signed [15:0]  mX_setPosition,
	output	reg	 signed [15:0]  mX_limitLo,
	output	reg	 signed [15:0]  mX_limitHi,
	output	reg					mX_alarmClear,
	input	wire                mX_alarm,
	input	wire signed [15:0]  mX_position,

	output	reg             	mY_prgmReq,
	input	wire            	mY_prgmAck,
	output	reg	 signed	[1:0]   mY_prgmDirection,
	output	reg  signed [31:0]  mY_prgmAcceleration,
	output	reg         [31:0]  mY_prgmAccelSamples,
	output	reg         [31:0]  mY_prgmCruiseSamples,

	output	reg                 mY_setEnable,
	output	reg	 signed [15:0]  mY_setPosition,
	output	reg	 signed [15:0]  mY_limitLo,
	output	reg	 signed [15:0]  mY_limitHi,
	output	reg					mY_alarmClear,
	input	wire                mY_alarm,
	input	wire signed [15:0]  mY_position,

	output	reg             	mZ_prgmReq,
	input	wire            	mZ_prgmAck,
	output	reg	 signed	[1:0]   mZ_prgmDirection,
	output	reg  signed [31:0]  mZ_prgmAcceleration,
	output	reg         [31:0]  mZ_prgmAccelSamples,
	output	reg         [31:0]  mZ_prgmCruiseSamples,

	output	reg                 mZ_setEnable,
	output	reg	 signed [15:0]  mZ_setPosition,
	output	reg	 signed [15:0]  mZ_limitLo,
	output	reg	 signed [15:0]  mZ_limitHi,
	output	reg					mZ_alarmClear,
	input	wire                mZ_alarm,
	input	wire signed [15:0]  mZ_position,

	output	reg             	mA_prgmReq,
	input	wire            	mA_prgmAck,
	output	reg	 signed	[1:0]   mA_prgmDirection,
	output	reg  signed [31:0]  mA_prgmAcceleration,
	output	reg         [31:0]  mA_prgmAccelSamples,
	output	reg         [31:0]  mA_prgmCruiseSamples,

	output	reg                 mA_setEnable,
	output	reg	 signed [15:0]  mA_setPosition,
	output	reg	 signed [15:0]  mA_limitLo,
	output	reg	 signed [15:0]  mA_limitHi,
	output	reg					mA_alarmClear,
	input	wire                mA_alarm,
	input	wire signed [15:0]  mA_position,

	output	reg             	mB_prgmReq,
	input	wire            	mB_prgmAck,
	output	reg	 signed	[1:0]   mB_prgmDirection,
	output	reg  signed [31:0]  mB_prgmAcceleration,
	output	reg         [31:0]  mB_prgmAccelSamples,
	output	reg         [31:0]  mB_prgmCruiseSamples,

	output	reg                 mB_setEnable,
	output	reg	 signed [15:0]  mB_setPosition,
	output	reg	 signed [15:0]  mB_limitLo,
	output	reg	 signed [15:0]  mB_limitHi,
	output	reg					mB_alarmClear,
	input	wire                mB_alarm,
	input	wire signed [15:0]  mB_position,

	output	reg             	mC_prgmReq,
	input	wire            	mC_prgmAck,
	output	reg	 signed	[1:0]   mC_prgmDirection,
	output	reg  signed [31:0]  mC_prgmAcceleration,
	output	reg         [31:0]  mC_prgmAccelSamples,
	output	reg         [31:0]  mC_prgmCruiseSamples,

	output	reg                 mC_setEnable,
	output	reg	 signed [15:0]  mC_setPosition,
	output	reg	 signed [15:0]  mC_limitLo,
	output	reg	 signed [15:0]  mC_limitHi,
	output	reg					mC_alarmClear,
	input	wire                mC_alarm,
	input	wire signed [15:0]  mC_position,

	output	reg			[3:0]	gpout,

	output	reg					trainingMode,
	input	wire		[5:0]	trainingInMotion,

	output	reg					mX_trainSetPosEn,
	output	reg	 signed	[15:0]	mX_trainSetPosPos,
	output	reg	 signed	[31:0]	mX_trainSetAccel,
	input	wire signed	[15:0]	mX_trainCurPos,
	output	reg	 signed	[31:0]	mX_trainTgtSpd,

	output	reg					mY_trainSetPosEn,
	output	reg	 signed	[15:0]	mY_trainSetPosPos,
	output	reg	 signed	[31:0]	mY_trainSetAccel,
	input	wire signed	[15:0]	mY_trainCurPos,
	output	reg	 signed	[31:0]	mY_trainTgtSpd,

	output	reg					mZ_trainSetPosEn,
	output	reg	 signed	[15:0]	mZ_trainSetPosPos,
	output	reg	 signed	[31:0]	mZ_trainSetAccel,
	input	wire signed	[15:0]	mZ_trainCurPos,
	output	reg	 signed	[31:0]	mZ_trainTgtSpd,

	output	reg					mA_trainSetPosEn,
	output	reg	 signed	[15:0]	mA_trainSetPosPos,
	output	reg	 signed	[31:0]	mA_trainSetAccel,
	input	wire signed	[15:0]	mA_trainCurPos,
	output	reg	 signed	[31:0]	mA_trainTgtSpd,

	output	reg					mB_trainSetPosEn,
	output	reg	 signed	[15:0]	mB_trainSetPosPos,
	output	reg	 signed	[31:0]	mB_trainSetAccel,
	input	wire signed	[15:0]	mB_trainCurPos,
	output	reg	 signed	[31:0]	mB_trainTgtSpd,

	output	reg					mC_trainSetPosEn,
	output	reg	 signed	[15:0]	mC_trainSetPosPos,
	output	reg	 signed	[31:0]	mC_trainSetAccel,
	input	wire signed	[15:0]	mC_trainCurPos,
	output	reg	 signed	[31:0]	mC_trainTgtSpd,

	input	wire		[63:0]	speedCtrlData,

	output	reg			[31:0]	blink0_control,
	output	reg			[31:0]	blink0_prescale,
	output	reg			[23:0]	blink0_delays,
	output	reg			[31:0]	blink1_control,
	output	reg			[31:0]	blink1_prescale,
	output	reg			[23:0]	blink1_delays,
	output	reg			[31:0]	blink2_control,
	output	reg			[31:0]	blink2_prescale,
	output	reg			[23:0]	blink2_delays,
	output	reg			[31:0]	blink3_control,
	output	reg			[31:0]	blink3_prescale,
	output	reg			[23:0]	blink3_delays
);

always @ (posedge clk)
begin
	if (rst)
	begin
		plbReady <= 0;
		plbRdData <= 0;

		mX_prgmReq <= 0;
		mX_prgmDirection <= 0;
		mX_prgmAcceleration <= 0;
		mX_prgmAccelSamples <= 0;
		mX_prgmCruiseSamples <= 0;

		mX_setEnable <= 0;
		mX_setPosition <= 0;
		mX_limitLo <= 0;
		mX_limitHi <= 0;
		mX_alarmClear <= 0;

		mY_prgmReq <= 0;
		mY_prgmDirection <= 0;
		mY_prgmAcceleration <= 0;
		mY_prgmAccelSamples <= 0;
		mY_prgmCruiseSamples <= 0;

		mY_setEnable <= 0;
		mY_setPosition <= 0;
		mY_limitLo <= 0;
		mY_limitHi <= 0;
		mY_alarmClear <= 0;

		mZ_prgmReq <= 0;
		mZ_prgmDirection <= 0;
		mZ_prgmAcceleration <= 0;
		mZ_prgmAccelSamples <= 0;
		mZ_prgmCruiseSamples <= 0;

		mZ_setEnable <= 0;
		mZ_setPosition <= 0;
		mZ_limitLo <= 0;
		mZ_limitHi <= 0;
		mZ_alarmClear <= 0;

		mA_prgmReq <= 0;
		mA_prgmDirection <= 0;
		mA_prgmAcceleration <= 0;
		mA_prgmAccelSamples <= 0;
		mA_prgmCruiseSamples <= 0;

		mA_setEnable <= 0;
		mA_setPosition <= 0;
		mA_limitLo <= 0;
		mA_limitHi <= 0;
		mA_alarmClear <= 0;

		mB_prgmReq <= 0;
		mB_prgmDirection <= 0;
		mB_prgmAcceleration <= 0;
		mB_prgmAccelSamples <= 0;
		mB_prgmCruiseSamples <= 0;

		mB_setEnable <= 0;
		mB_setPosition <= 0;
		mB_limitLo <= 0;
		mB_limitHi <= 0;
		mB_alarmClear <= 0;

		mC_prgmReq <= 0;
		mC_prgmDirection <= 0;
		mC_prgmAcceleration <= 0;
		mC_prgmAccelSamples <= 0;
		mC_prgmCruiseSamples <= 0;

		mC_setEnable <= 0;
		mC_setPosition <= 0;
		mC_limitLo <= 0;
		mC_limitHi <= 0;
		mC_alarmClear <= 0;

		gpout <= 0;

		trainingMode <= 0;

		mX_trainSetPosEn <= 0;
		mX_trainSetPosPos <= 0;
		mX_trainSetAccel <= 0;
		mX_trainTgtSpd <= 0;

		mY_trainSetPosEn <= 0;
		mY_trainSetPosPos <= 0;
		mY_trainSetAccel <= 0;
		mY_trainTgtSpd <= 0;

		mZ_trainSetPosEn <= 0;
		mZ_trainSetPosPos <= 0;
		mZ_trainSetAccel <= 0;
		mZ_trainTgtSpd <= 0;

		mA_trainSetPosEn <= 0;
		mA_trainSetPosPos <= 0;
		mA_trainSetAccel <= 0;
		mA_trainTgtSpd <= 0;

		mB_trainSetPosEn <= 0;
		mB_trainSetPosPos <= 0;
		mB_trainSetAccel <= 0;
		mB_trainTgtSpd <= 0;

		mC_trainSetPosEn <= 0;
		mC_trainSetPosPos <= 0;
		mC_trainSetAccel <= 0;
		mC_trainTgtSpd <= 0;

		blink0_control <= 0;
		blink0_prescale <= 0;
		blink0_delays <= 0;
		blink1_control <= 0;
		blink1_prescale <= 0;
		blink1_delays <= 0;
		blink2_control <= 0;
		blink2_prescale <= 0;
		blink2_delays <= 0;
		blink3_control <= 0;
		blink3_prescale <= 0;
		blink3_delays <= 0;
	end
	else
	begin

		//
		// defaults
		//

		plbReady <= 0;
		mX_alarmClear <= 0;
		mX_setEnable <= 0;
		mY_alarmClear <= 0;
		mY_setEnable <= 0;
		mZ_alarmClear <= 0;
		mZ_setEnable <= 0;
		mA_alarmClear <= 0;
		mA_setEnable <= 0;
		mB_alarmClear <= 0;
		mB_setEnable <= 0;
		mC_alarmClear <= 0;
		mC_setEnable <= 0;
		
		mX_trainSetPosEn <= 0;
		mY_trainSetPosEn <= 0;
		mZ_trainSetPosEn <= 0;
		mA_trainSetPosEn <= 0;
		mB_trainSetPosEn <= 0;
		mC_trainSetPosEn <= 0;


		//
		// programming requests / acknowledges
		//

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h001) && plbWrData[5])
			mX_prgmReq <= 1;
		else if (mX_prgmAck)
			mX_prgmReq <= 0;

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h001) && plbWrData[4])
			mY_prgmReq <= 1;
		else if (mY_prgmAck)
			mY_prgmReq <= 0;

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h001) && plbWrData[3])
			mZ_prgmReq <= 1;
		else if (mZ_prgmAck)
			mZ_prgmReq <= 0;

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h001) && plbWrData[2])
			mA_prgmReq <= 1;
		else if (mA_prgmAck)
			mA_prgmReq <= 0;

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h001) && plbWrData[1])
			mB_prgmReq <= 1;
		else if (mB_prgmAck)
			mB_prgmReq <= 0;

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h001) && plbWrData[0])
			mC_prgmReq <= 1;
		else if (mC_prgmAck)
			mC_prgmReq <= 0;

		//
		// alarm clears
		//

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h002) && plbWrData[5])
		begin
			mX_alarmClear <= 1;
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h002) && plbWrData[4])
		begin
			mY_alarmClear <= 1;
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h002) && plbWrData[3])
		begin
			mZ_alarmClear <= 1;
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h002) && plbWrData[2])
		begin
			mA_alarmClear <= 1;
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h002) && plbWrData[1])
		begin
			mB_alarmClear <= 1;
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h002) && plbWrData[0])
		begin
			mC_alarmClear <= 1;
		end


		//
		// limiter set positions
		//

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h00e))
		begin
			mX_setEnable <= 1;
			mX_setPosition <= plbWrData[15:0];
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h016))
		begin
			mY_setEnable <= 1;
			mY_setPosition <= plbWrData[15:0];
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h01e))
		begin
			mZ_setEnable <= 1;
			mZ_setPosition <= plbWrData[15:0];
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h026))
		begin
			mA_setEnable <= 1;
			mA_setPosition <= plbWrData[15:0];
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h02e))
		begin
			mB_setEnable <= 1;
			mB_setPosition <= plbWrData[15:0];
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h036))
		begin
			mC_setEnable <= 1;
			mC_setPosition <= plbWrData[15:0];
		end


		// 
		// trainig set positions
		//

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h080))
		begin
			mX_trainSetPosEn <= 1;
			mX_trainSetPosPos <= plbWrData[15:0];
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h090))
		begin
			mY_trainSetPosEn <= 1;
			mY_trainSetPosPos <= plbWrData[15:0];
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h0a0))
		begin
			mZ_trainSetPosEn <= 1;
			mZ_trainSetPosPos <= plbWrData[15:0];
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h0b0))
		begin
			mA_trainSetPosEn <= 1;
			mA_trainSetPosPos <= plbWrData[15:0];
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h0c0))
		begin
			mB_trainSetPosEn <= 1;
			mB_trainSetPosPos <= plbWrData[15:0];
		end

		if (plbEn && plbWr && (plbAddr[11:2] == 10'h0d0))
		begin
			mC_trainSetPosEn <= 1;
			mC_trainSetPosPos <= plbWrData[15:0];
		end


		//
		// writes
		//
		
		if (plbEn && plbWr)
		begin
			plbReady <= 1;

			case (plbAddr[11:2])

				10'h003: trainingMode <= plbWrData[31];

				10'h008: mX_prgmDirection <= plbWrData[1:0];
				10'h009: mX_prgmAcceleration <= plbWrData;
				10'h00a: mX_prgmAccelSamples <= plbWrData;
				10'h00b: mX_prgmCruiseSamples <= plbWrData;
				10'h00c: mX_limitLo <= plbWrData[15:0];
				10'h00d: mX_limitHi <= plbWrData[15:0];

				10'h010: mY_prgmDirection <= plbWrData[1:0];
				10'h011: mY_prgmAcceleration <= plbWrData;
				10'h012: mY_prgmAccelSamples <= plbWrData;
				10'h013: mY_prgmCruiseSamples <= plbWrData;
				10'h014: mY_limitLo <= plbWrData[15:0];
				10'h015: mY_limitHi <= plbWrData[15:0];

				10'h018: mZ_prgmDirection <= plbWrData[1:0];
				10'h019: mZ_prgmAcceleration <= plbWrData;
				10'h01a: mZ_prgmAccelSamples <= plbWrData;
				10'h01b: mZ_prgmCruiseSamples <= plbWrData;
				10'h01c: mZ_limitLo <= plbWrData[15:0];
				10'h01d: mZ_limitHi <= plbWrData[15:0];

				10'h020: mA_prgmDirection <= plbWrData[1:0];
				10'h021: mA_prgmAcceleration <= plbWrData;
				10'h022: mA_prgmAccelSamples <= plbWrData;
				10'h023: mA_prgmCruiseSamples <= plbWrData;
				10'h024: mA_limitLo <= plbWrData[15:0];
				10'h025: mA_limitHi <= plbWrData[15:0];

				10'h028: mB_prgmDirection <= plbWrData[1:0];
				10'h029: mB_prgmAcceleration <= plbWrData;
				10'h02a: mB_prgmAccelSamples <= plbWrData;
				10'h02b: mB_prgmCruiseSamples <= plbWrData;
				10'h02c: mB_limitLo <= plbWrData[15:0];
				10'h02d: mB_limitHi <= plbWrData[15:0];

				10'h030: mC_prgmDirection <= plbWrData[1:0];
				10'h031: mC_prgmAcceleration <= plbWrData;
				10'h032: mC_prgmAccelSamples <= plbWrData;
				10'h033: mC_prgmCruiseSamples <= plbWrData;
				10'h034: mC_limitLo <= plbWrData[15:0];
				10'h035: mC_limitHi <= plbWrData[15:0];

				10'h040: gpout[0] <= plbWrData[0];
				10'h041: gpout[1] <= plbWrData[0];
				10'h042: gpout[2] <= plbWrData[0];
				10'h043: gpout[3] <= plbWrData[0];

				10'h060: blink0_control <= plbWrData[31:0];
				10'h061: blink0_prescale <= plbWrData[31:0];
				10'h062: blink0_delays <= plbWrData[23:0];
				10'h064: blink1_control <= plbWrData[31:0];
				10'h065: blink1_prescale <= plbWrData[31:0];
				10'h066: blink1_delays <= plbWrData[23:0];
				10'h068: blink2_control <= plbWrData[31:0];
				10'h069: blink2_prescale <= plbWrData[31:0];
				10'h06a: blink2_delays <= plbWrData[23:0];
				10'h06c: blink3_control <= plbWrData[31:0];
				10'h06d: blink3_prescale <= plbWrData[31:0];
				10'h06e: blink3_delays <= plbWrData[23:0];

				// X axis training
				10'h081: mX_trainSetAccel <= plbWrData[31:0];
				10'h082: mX_trainTgtSpd <= plbWrData[31:0];

				// Y axis training
				10'h091: mY_trainSetAccel <= plbWrData[31:0];
				10'h092: mY_trainTgtSpd <= plbWrData[31:0];

				// Z axis training
				10'h0a1: mZ_trainSetAccel <= plbWrData[31:0];
				10'h0a2: mZ_trainTgtSpd <= plbWrData[31:0];

				// A axis training
				10'h0b1: mA_trainSetAccel <= plbWrData[31:0];
				10'h0b2: mA_trainTgtSpd <= plbWrData[31:0];

				// B axis training
				10'h0c1: mB_trainSetAccel <= plbWrData[31:0];
				10'h0c2: mB_trainTgtSpd <= plbWrData[31:0];

				// C axis training
				10'h0d1: mC_trainSetAccel <= plbWrData[31:0];
				10'h0d2: mC_trainTgtSpd <= plbWrData[31:0];
			endcase
		end

		//
		// reads
		//
		
		if (plbEn && plbRd)
		begin
			plbReady <= 1;

			case (plbAddr[11:2])

				// multiple axis
				10'h000: plbRdData <= { 26'h0, mBusy[5:0] };
				10'h001: plbRdData <= { 26'h0, 
					mX_prgmReq, mY_prgmReq, mZ_prgmReq, mA_prgmReq, mB_prgmReq, mC_prgmReq };
				10'h002: plbRdData <= { 26'h0, 
					mX_alarm, mY_alarm, mZ_alarm, mA_alarm, mB_alarm, mC_alarm };
				10'h003: plbRdData <= { trainingMode, 25'b0, trainingInMotion };

				10'h004: plbRdData <= speedCtrlData[63:32];
				10'h005: plbRdData <= speedCtrlData[31: 0];

				// X axis
				10'h008: plbRdData <= { {30{mX_prgmDirection[1]}}, mX_prgmDirection[1:0] };
				10'h009: plbRdData <= mX_prgmAcceleration;
				10'h00a: plbRdData <= mX_prgmAccelSamples;
				10'h00b: plbRdData <= mX_prgmCruiseSamples;
				10'h00c: plbRdData <= mX_limitLo;
				10'h00d: plbRdData <= mX_limitHi;
				10'h00e: plbRdData <= mX_position;

				// Y axis
				10'h010: plbRdData <= { {30{mY_prgmDirection[1]}}, mY_prgmDirection[1:0] };
				10'h011: plbRdData <= mY_prgmAcceleration;
				10'h012: plbRdData <= mY_prgmAccelSamples;
				10'h013: plbRdData <= mY_prgmCruiseSamples;
				10'h014: plbRdData <= mY_limitLo;
				10'h015: plbRdData <= mY_limitHi;
				10'h016: plbRdData <= mY_position;

				// Z axis
				10'h018: plbRdData <= { {30{mZ_prgmDirection[1]}}, mZ_prgmDirection[1:0] };
				10'h019: plbRdData <= mZ_prgmAcceleration;
				10'h01a: plbRdData <= mZ_prgmAccelSamples;
				10'h01b: plbRdData <= mZ_prgmCruiseSamples;
				10'h01c: plbRdData <= mZ_limitLo;
				10'h01d: plbRdData <= mZ_limitHi;
				10'h01e: plbRdData <= mZ_position;

				// A axis
				10'h020: plbRdData <= { {30{mA_prgmDirection[1]}}, mA_prgmDirection[1:0] };
				10'h021: plbRdData <= mA_prgmAcceleration;
				10'h022: plbRdData <= mA_prgmAccelSamples;
				10'h023: plbRdData <= mA_prgmCruiseSamples;
				10'h024: plbRdData <= mA_limitLo;
				10'h025: plbRdData <= mA_limitHi;
				10'h026: plbRdData <= mA_position;

				// B axis
				10'h028: plbRdData <= { {30{mB_prgmDirection[1]}}, mB_prgmDirection[1:0] };
				10'h029: plbRdData <= mB_prgmAcceleration;
				10'h02a: plbRdData <= mB_prgmAccelSamples;
				10'h02b: plbRdData <= mB_prgmCruiseSamples;
				10'h02c: plbRdData <= mB_limitLo;
				10'h02d: plbRdData <= mB_limitHi;
				10'h02e: plbRdData <= mB_position;

				// C axis
				10'h030: plbRdData <= { {30{mC_prgmDirection[1]}}, mC_prgmDirection[1:0] };
				10'h031: plbRdData <= mC_prgmAcceleration;
				10'h032: plbRdData <= mC_prgmAccelSamples;
				10'h033: plbRdData <= mC_prgmCruiseSamples;
				10'h034: plbRdData <= mC_limitLo;
				10'h035: plbRdData <= mC_limitHi;
				10'h036: plbRdData <= mC_position;

				// general purpose outputs
				10'h040: plbRdData <= { 31'b0, gpout[0] };
				10'h041: plbRdData <= { 31'b0, gpout[1] };
				10'h042: plbRdData <= { 31'b0, gpout[2] };
				10'h043: plbRdData <= { 31'b0, gpout[3] };

				10'h060: plbRdData <= blink0_control;
				10'h061: plbRdData <= blink0_prescale;
				10'h062: plbRdData <= { 8'b0, blink0_delays };
				10'h064: plbRdData <= blink1_control;
				10'h065: plbRdData <= blink1_prescale;
				10'h066: plbRdData <= { 8'b0, blink1_delays };
				10'h068: plbRdData <= blink2_control;
				10'h069: plbRdData <= blink2_prescale;
				10'h06a: plbRdData <= { 8'b0, blink2_delays };
				10'h06c: plbRdData <= blink3_control;
				10'h06d: plbRdData <= blink3_prescale;
				10'h06e: plbRdData <= { 8'b0, blink3_delays };

				// X axis training
				10'h080: plbRdData <= { {16{mX_trainCurPos[15]}}, mX_trainCurPos[15:0] };
				10'h081: plbRdData <= mX_trainSetAccel;
				10'h082: plbRdData <= mX_trainTgtSpd;

				// Y axis training
				10'h090: plbRdData <= { {16{mY_trainCurPos[15]}}, mY_trainCurPos[15:0] };
				10'h091: plbRdData <= mY_trainSetAccel;
				10'h092: plbRdData <= mY_trainTgtSpd;

				// Z axis training
				10'h0a0: plbRdData <= { {16{mZ_trainCurPos[15]}}, mZ_trainCurPos[15:0] };
				10'h0a1: plbRdData <= mZ_trainSetAccel;
				10'h0a2: plbRdData <= mZ_trainTgtSpd;

				// A axis training
				10'h0b0: plbRdData <= { {16{mA_trainCurPos[15]}}, mA_trainCurPos[15:0] };
				10'h0b1: plbRdData <= mA_trainSetAccel;
				10'h0b2: plbRdData <= mA_trainTgtSpd;

				// B axis training
				10'h0c0: plbRdData <= { {16{mB_trainCurPos[15]}}, mB_trainCurPos[15:0] };
				10'h0c1: plbRdData <= mB_trainSetAccel;
				10'h0c2: plbRdData <= mB_trainTgtSpd;

				// C axis training
				10'h0d0: plbRdData <= { {16{mC_trainCurPos[15]}}, mC_trainCurPos[15:0] };
				10'h0d1: plbRdData <= mC_trainSetAccel;
				10'h0d2: plbRdData <= mC_trainTgtSpd;

			endcase
		end

	end
end

endmodule
