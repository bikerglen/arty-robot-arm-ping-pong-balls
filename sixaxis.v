module sixaxis
(
	input	wire			rst,			// sync active-high reset
	input	wire			clk,			// 10MHz clock input

	input	wire 			plbEn,			// microblaze plb bus
	input	wire			plbRd,
	input	wire			plbWr,
	input	wire	[3:0]	plbBE,
	input	wire	[31:0]	plbAddr,
	input	wire	[31:0]	plbWrData,
	output	wire			plbReady,
	output	wire	[31:0]	plbRdData,

	output	wire	[5:0]	mAlarm,			// individual alarm outputs
	output	wire	[5:0]	mDir,			// motor direction outputs
	output	wire	[5:0]	mStep,			// motor step outputs

	output	wire	[3:0]	gpout,			// general purpose outputs
	input	wire			ps3in
);

localparam mX = 5, mY = 4, mZ = 3, mA = 2, mB = 1, mC = 0;

wire				mX_prgmReq;
wire				mX_prgmAck;
wire signed [1:0]	mX_prgmDirection;
wire signed [31:0]	mX_prgmAcceleration;
wire 		[31:0]  mX_prgmAccelSamples;
wire		[31:0]	mX_prgmCruiseSamples;

wire				mX_setEnable;
wire signed	[15:0] 	mX_setPosition;
wire signed	[15:0]	mX_limitLo;
wire signed	[15:0]	mX_limitHi;
wire				mX_alarmClear;
wire				mX_alarm;
wire signed	[15:0]	mX_position;

wire				mY_prgmReq;
wire				mY_prgmAck;
wire signed [1:0]	mY_prgmDirection;
wire signed [31:0]	mY_prgmAcceleration;
wire 		[31:0]  mY_prgmAccelSamples;
wire		[31:0]	mY_prgmCruiseSamples;

wire				mY_setEnable;
wire signed	[15:0] 	mY_setPosition;
wire signed	[15:0]	mY_limitLo;
wire signed	[15:0]	mY_limitHi;
wire				mY_alarmClear;
wire				mY_alarm;
wire signed	[15:0]	mY_position;

wire				mZ_prgmReq;
wire				mZ_prgmAck;
wire signed [1:0]	mZ_prgmDirection;
wire signed [31:0]	mZ_prgmAcceleration;
wire 		[31:0]  mZ_prgmAccelSamples;
wire		[31:0]	mZ_prgmCruiseSamples;

wire				mZ_setEnable;
wire signed	[15:0] 	mZ_setPosition;
wire signed	[15:0]	mZ_limitLo;
wire signed	[15:0]	mZ_limitHi;
wire				mZ_alarmClear;
wire				mZ_alarm;
wire signed	[15:0]	mZ_position;

wire				mA_prgmReq;
wire				mA_prgmAck;
wire signed [1:0]	mA_prgmDirection;
wire signed [31:0]	mA_prgmAcceleration;
wire 		[31:0]  mA_prgmAccelSamples;
wire		[31:0]	mA_prgmCruiseSamples;

wire				mA_setEnable;
wire signed	[15:0] 	mA_setPosition;
wire signed	[15:0]	mA_limitLo;
wire signed	[15:0]	mA_limitHi;
wire				mA_alarmClear;
wire				mA_alarm;
wire signed	[15:0]	mA_position;

wire				mB_prgmReq;
wire				mB_prgmAck;
wire signed [1:0]	mB_prgmDirection;
wire signed [31:0]	mB_prgmAcceleration;
wire 		[31:0]  mB_prgmAccelSamples;
wire		[31:0]	mB_prgmCruiseSamples;

wire				mB_setEnable;
wire signed	[15:0] 	mB_setPosition;
wire signed	[15:0]	mB_limitLo;
wire signed	[15:0]	mB_limitHi;
wire				mB_alarmClear;
wire				mB_alarm;
wire signed	[15:0]	mB_position;

wire				mC_prgmReq;
wire				mC_prgmAck;
wire signed [1:0]	mC_prgmDirection;
wire signed [31:0]	mC_prgmAcceleration;
wire 		[31:0]  mC_prgmAccelSamples;
wire		[31:0]	mC_prgmCruiseSamples;

wire				mC_setEnable;
wire signed	[15:0] 	mC_setPosition;
wire signed	[15:0]	mC_limitLo;
wire signed	[15:0]	mC_limitHi;
wire				mC_alarmClear;
wire				mC_alarm;
wire signed	[15:0]	mC_position;

wire		[5:0]	mBusy;
wire		[5:0]	mDirRaw;
wire		[5:0]	mStepRaw;
wire		[5:0]	mDirTrain;
wire		[5:0]	mStepTrain;
wire		[5:0]	mDirIn;
wire		[5:0]	mStepIn;

wire				trainingMode;
wire		[5:0]	trainingInMotion;

wire				mX_trainSetPosEn;
wire signed	[15:0]	mX_trainSetPosPos;
wire signed	[31:0]	mX_trainSetAccel;
wire signed	[15:0]	mX_trainCurPos;	
wire signed	[31:0]	mX_trainMaxSpd;
wire signed	[31:0]	mX_trainTgtSpd;

wire				mY_trainSetPosEn;
wire signed	[15:0]	mY_trainSetPosPos;
wire signed	[31:0]	mY_trainSetAccel;
wire signed	[15:0]	mY_trainCurPos;	
wire signed	[31:0]	mY_trainMaxSpd;
wire signed	[31:0]	mY_trainTgtSpd;

wire				mZ_trainSetPosEn;
wire signed	[15:0]	mZ_trainSetPosPos;
wire signed	[31:0]	mZ_trainSetAccel;
wire signed	[15:0]	mZ_trainCurPos;	
wire signed	[31:0]	mZ_trainMaxSpd;
wire signed	[31:0]	mZ_trainTgtSpd;

wire				mA_trainSetPosEn;
wire signed	[15:0]	mA_trainSetPosPos;
wire signed	[31:0]	mA_trainSetAccel;
wire signed	[15:0]	mA_trainCurPos;	
wire signed	[31:0]	mA_trainMaxSpd;
wire signed	[31:0]	mA_trainTgtSpd;

wire				mB_trainSetPosEn;
wire signed	[15:0]	mB_trainSetPosPos;
wire signed	[31:0]	mB_trainSetAccel;
wire signed	[15:0]	mB_trainCurPos;	
wire signed	[31:0]	mB_trainMaxSpd;
wire signed	[31:0]	mB_trainTgtSpd;

wire				mC_trainSetPosEn;
wire signed	[15:0]	mC_trainSetPosPos;
wire signed	[31:0]	mC_trainSetAccel;
wire signed	[15:0]	mC_trainCurPos;	
wire signed	[31:0]	mC_trainMaxSpd;
wire signed	[31:0]	mC_trainTgtSpd;

wire		[63:0]	speedCtrlData;
wire		[3:0]	regGpOut;

wire [31:0] blink0_control,  blink1_control,  blink2_control,  blink3_control;
wire [31:0] blink0_prescale, blink1_prescale, blink2_prescale, blink3_prescale;
wire [23:0] blink0_delays,   blink1_delays,   blink2_delays,   blink3_delays;


//---------------------------------------------------------------------------------------------
// PLB Target CPU Registers
//

plbregs plbregs
(
	.rst					(rst),
	.clk					(clk),

    .plbEn              	(plbEn),
    .plbRd              	(plbRd),
    .plbWr              	(plbWr),
    .plbBE              	(plbBE),
    .plbAddr            	(plbAddr),
    .plbWrData          	(plbWrData),
    .plbReady           	(plbReady),
    .plbRdData          	(plbRdData),

	.mBusy					(mBusy),

    .mX_prgmReq				(mX_prgmReq),
    .mX_prgmAck				(mX_prgmAck),
    .mX_prgmDirection		(mX_prgmDirection),
    .mX_prgmAcceleration	(mX_prgmAcceleration),
    .mX_prgmAccelSamples	(mX_prgmAccelSamples),
    .mX_prgmCruiseSamples	(mX_prgmCruiseSamples),

	.mX_setEnable			(mX_setEnable),
	.mX_setPosition			(mX_setPosition),
	.mX_limitLo				(mX_limitLo),
	.mX_limitHi				(mX_limitHi),
	.mX_alarmClear			(mX_alarmClear),
	.mX_alarm				(mX_alarm),
	.mX_position			(mX_position),

    .mY_prgmReq				(mY_prgmReq),
    .mY_prgmAck				(mY_prgmAck),
    .mY_prgmDirection		(mY_prgmDirection),
    .mY_prgmAcceleration	(mY_prgmAcceleration),
    .mY_prgmAccelSamples	(mY_prgmAccelSamples),
    .mY_prgmCruiseSamples	(mY_prgmCruiseSamples),
                               
	.mY_setEnable			(mY_setEnable),
	.mY_setPosition			(mY_setPosition),
	.mY_limitLo				(mY_limitLo),
	.mY_limitHi				(mY_limitHi),
	.mY_alarmClear			(mY_alarmClear),
	.mY_alarm				(mY_alarm),
	.mY_position			(mY_position),
                               
    .mZ_prgmReq				(mZ_prgmReq),
    .mZ_prgmAck				(mZ_prgmAck),
    .mZ_prgmDirection		(mZ_prgmDirection),
    .mZ_prgmAcceleration	(mZ_prgmAcceleration),
    .mZ_prgmAccelSamples	(mZ_prgmAccelSamples),
    .mZ_prgmCruiseSamples	(mZ_prgmCruiseSamples),
                               
	.mZ_setEnable			(mZ_setEnable),
	.mZ_setPosition			(mZ_setPosition),
	.mZ_limitLo				(mZ_limitLo),
	.mZ_limitHi				(mZ_limitHi),
	.mZ_alarmClear			(mZ_alarmClear),
	.mZ_alarm				(mZ_alarm),
	.mZ_position			(mZ_position),
                               
    .mA_prgmReq				(mA_prgmReq),
    .mA_prgmAck				(mA_prgmAck),
    .mA_prgmDirection		(mA_prgmDirection),
    .mA_prgmAcceleration	(mA_prgmAcceleration),
    .mA_prgmAccelSamples	(mA_prgmAccelSamples),
    .mA_prgmCruiseSamples	(mA_prgmCruiseSamples),
                               
	.mA_setEnable			(mA_setEnable),
	.mA_setPosition			(mA_setPosition),
	.mA_limitLo				(mA_limitLo),
	.mA_limitHi				(mA_limitHi),
	.mA_alarmClear			(mA_alarmClear),
	.mA_alarm				(mA_alarm),
	.mA_position			(mA_position),
                               
    .mB_prgmReq				(mB_prgmReq),
    .mB_prgmAck				(mB_prgmAck),
    .mB_prgmDirection		(mB_prgmDirection),
    .mB_prgmAcceleration	(mB_prgmAcceleration),
    .mB_prgmAccelSamples	(mB_prgmAccelSamples),
    .mB_prgmCruiseSamples	(mB_prgmCruiseSamples),
                               
	.mB_setEnable			(mB_setEnable),
	.mB_setPosition			(mB_setPosition),
	.mB_limitLo				(mB_limitLo),
	.mB_limitHi				(mB_limitHi),
	.mB_alarmClear			(mB_alarmClear),
	.mB_alarm				(mB_alarm),
	.mB_position			(mB_position),
                               
    .mC_prgmReq				(mC_prgmReq),
    .mC_prgmAck				(mC_prgmAck),
    .mC_prgmDirection		(mC_prgmDirection),
    .mC_prgmAcceleration	(mC_prgmAcceleration),
    .mC_prgmAccelSamples	(mC_prgmAccelSamples),
    .mC_prgmCruiseSamples	(mC_prgmCruiseSamples),
                               
	.mC_setEnable			(mC_setEnable),
	.mC_setPosition			(mC_setPosition),
	.mC_limitLo				(mC_limitLo),
	.mC_limitHi				(mC_limitHi),
	.mC_alarmClear			(mC_alarmClear),
	.mC_alarm				(mC_alarm),
	.mC_position			(mC_position),

	.gpout					(regGpOut),

	.trainingMode			(trainingMode),
	.trainingInMotion		(trainingInMotion),

	.mX_trainSetPosEn		(mX_trainSetPosEn),
	.mX_trainSetPosPos		(mX_trainSetPosPos),
	.mX_trainSetAccel		(mX_trainSetAccel),
	.mX_trainCurPos			(mX_trainCurPos),
	.mX_trainTgtSpd			(mX_trainMaxSpd),

	.mY_trainSetPosEn		(mY_trainSetPosEn),
	.mY_trainSetPosPos		(mY_trainSetPosPos),
	.mY_trainSetAccel		(mY_trainSetAccel),
	.mY_trainCurPos			(mY_trainCurPos),
	.mY_trainTgtSpd			(mY_trainMaxSpd),

	.mZ_trainSetPosEn		(mZ_trainSetPosEn),
	.mZ_trainSetPosPos		(mZ_trainSetPosPos),
	.mZ_trainSetAccel		(mZ_trainSetAccel),
	.mZ_trainCurPos			(mZ_trainCurPos),
	.mZ_trainTgtSpd			(mZ_trainMaxSpd),

	.mA_trainSetPosEn		(mA_trainSetPosEn),
	.mA_trainSetPosPos		(mA_trainSetPosPos),
	.mA_trainSetAccel		(mA_trainSetAccel),
	.mA_trainCurPos			(mA_trainCurPos),
	.mA_trainTgtSpd			(mA_trainMaxSpd),

	.mB_trainSetPosEn		(mB_trainSetPosEn),
	.mB_trainSetPosPos		(mB_trainSetPosPos),
	.mB_trainSetAccel		(mB_trainSetAccel),
	.mB_trainCurPos			(mB_trainCurPos),
	.mB_trainTgtSpd			(mB_trainMaxSpd),

	.mC_trainSetPosEn		(mC_trainSetPosEn),
	.mC_trainSetPosPos		(mC_trainSetPosPos),
	.mC_trainSetAccel		(mC_trainSetAccel),
	.mC_trainCurPos			(mC_trainCurPos),
	.mC_trainTgtSpd			(mC_trainMaxSpd),

	.speedCtrlData			(speedCtrlData),

	.blink0_control  		(blink0_control),
	.blink0_prescale        (blink0_prescale),
	.blink0_delays          (blink0_delays),
	.blink1_control         (blink1_control),
	.blink1_prescale        (blink1_prescale),
	.blink1_delays          (blink1_delays),
	.blink2_control         (blink2_control),
	.blink2_prescale        (blink2_prescale),
	.blink2_delays          (blink2_delays),
	.blink3_control         (blink3_control),
	.blink3_prescale        (blink3_prescale),
	.blink3_delays          (blink3_delays)
);


//---------------------------------------------------------------------------------------------
// Generate Enable Signals
//

reg [7:0] phCounter;
reg ph1, ph2, ph3, ph4;

always @ (posedge clk)
begin
    if (rst)
    begin
        phCounter <= 0;
        ph1 <= 0;
        ph2 <= 0;
        ph3 <= 0;
        ph4 <= 0;
    end
    else
    begin
        if (phCounter == 199)
        begin
            phCounter <= 0;
        end
        else
        begin
            phCounter <= phCounter + 1;
        end

        ph1 <= (phCounter == 0);
        ph2 <= (phCounter == 1);
        ph3 <= (phCounter == 2);
        ph4 <= (phCounter == 3);
    end
end


//---------------------------------------------------------------------------------------------
// Select Axis or Speed control outputs based on training mode or not
//

assign mDirIn  = trainingMode ? mDirTrain  : mDirRaw;
assign mStepIn = trainingMode ? mStepTrain : mStepRaw;


//---------------------------------------------------------------------------------------------
// X Axis
//

axis axis_X
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// enables
	.ph1				(ph1),
	.ph2				(ph2),
	.ph3				(ph3),
	.ph4				(ph4),

	// programming
    .prgmReq			(mX_prgmReq),
    .prgmAck			(mX_prgmAck),
    .prgmDirection		(mX_prgmDirection),
    .prgmAcceleration	(mX_prgmAcceleration),
    .prgmAccelSamples	(mX_prgmAccelSamples),
    .prgmCruiseSamples	(mX_prgmCruiseSamples),

	// busy flag
	.busy				(mBusy[mX]),

	// raw motor outputs
	.mDir				(mDirRaw[mX]),
	.mStep				(mStepRaw[mX])
);

speed speed_X
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// enables
	.ph1				(ph1),
	.ph2				(ph2),
	.ph3				(ph3),
	.ph4				(ph4),

	// config and status
    .setPosEn			(mX_trainSetPosEn),
    .setPosPos			(mX_trainSetPosPos),
    .setAccel			(mX_trainSetAccel),
    .limitLo			(mX_limitLo),
    .limitHi			(mX_limitHi),
	.inMotion			(trainingInMotion[mX]),
    .currentPosition	(mX_trainCurPos),

	// real time control
    .targetVelocity		(mX_trainTgtSpd),

	// motion outputs
    .mDir				(mDirTrain[mX]),
    .mStep				(mStepTrain[mX])
);

limiter limiter_X
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// register interface
	.setEnable			(mX_setEnable),
	.setPosition		(mX_setPosition),
	.limitLo			(mX_limitLo),
	.limitHi			(mX_limitHi),
	.alarmClear			(mX_alarmClear),
	.alarm				(mX_alarm),
	.mPosition			(mX_position),

	// motion inputs
	.mDirIn				(mDirIn[mX]),
	.mStepIn			(mStepIn[mX]),

	// motion outputs
	.mDirOut			(mDir[mX]),
	.mStepOut			(mStep[mX])
);


//---------------------------------------------------------------------------------------------
// Y Axis
//

axis axis_Y
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// enables
	.ph1				(ph1),
	.ph2				(ph2),
	.ph3				(ph3),
	.ph4				(ph4),

	// programming
    .prgmReq			(mY_prgmReq),
    .prgmAck			(mY_prgmAck),
    .prgmDirection		(mY_prgmDirection),
    .prgmAcceleration	(mY_prgmAcceleration),
    .prgmAccelSamples	(mY_prgmAccelSamples),
    .prgmCruiseSamples	(mY_prgmCruiseSamples),

	// busy flag
	.busy				(mBusy[mY]),

	// raw motor outputs
	.mDir				(mDirRaw[mY]),
	.mStep				(mStepRaw[mY])
);

speed speed_Y
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// enables
	.ph1				(ph1),
	.ph2				(ph2),
	.ph3				(ph3),
	.ph4				(ph4),

	// config and status
    .setPosEn			(mY_trainSetPosEn),
    .setPosPos			(mY_trainSetPosPos),
    .setAccel			(mY_trainSetAccel),
    .limitLo			(mY_limitLo),
    .limitHi			(mY_limitHi),
	.inMotion			(trainingInMotion[mY]),
    .currentPosition	(mY_trainCurPos),

	// real time control
    .targetVelocity		(mY_trainTgtSpd),

	// motion outputs
    .mDir				(mDirTrain[mY]),
    .mStep				(mStepTrain[mY])
);

limiter limiter_Y
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// register interface
	.setEnable			(mY_setEnable),
	.setPosition		(mY_setPosition),
	.limitLo			(mY_limitLo),
	.limitHi			(mY_limitHi),
	.alarmClear			(mY_alarmClear),
	.alarm				(mY_alarm),
	.mPosition			(mY_position),

	// motion inputs
	.mDirIn				(mDirIn[mY]),
	.mStepIn			(mStepIn[mY]),

	// motion outputs
	.mDirOut			(mDir[mY]),
	.mStepOut			(mStep[mY])
);


//---------------------------------------------------------------------------------------------
// Z Axis
//

axis axis_Z
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// enables
	.ph1				(ph1),
	.ph2				(ph2),
	.ph3				(ph3),
	.ph4				(ph4),

	// programming
    .prgmReq			(mZ_prgmReq),
    .prgmAck			(mZ_prgmAck),
    .prgmDirection		(mZ_prgmDirection),
    .prgmAcceleration	(mZ_prgmAcceleration),
    .prgmAccelSamples	(mZ_prgmAccelSamples),
    .prgmCruiseSamples	(mZ_prgmCruiseSamples),

	// busy flag
	.busy				(mBusy[mZ]),

	// raw motor outputs
	.mDir				(mDirRaw[mZ]),
	.mStep				(mStepRaw[mZ])
);

speed speed_Z
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// enables
	.ph1				(ph1),
	.ph2				(ph2),
	.ph3				(ph3),
	.ph4				(ph4),

	// config and status
    .setPosEn			(mZ_trainSetPosEn),
    .setPosPos			(mZ_trainSetPosPos),
    .setAccel			(mZ_trainSetAccel),
    .limitLo			(mZ_limitLo),
    .limitHi			(mZ_limitHi),
	.inMotion			(trainingInMotion[mZ]),
    .currentPosition	(mZ_trainCurPos),

	// real time control
    .targetVelocity		(mZ_trainTgtSpd),

	// motion outputs
    .mDir				(mDirTrain[mZ]),
    .mStep				(mStepTrain[mZ])
);

limiter limiter_Z
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// register interface
	.setEnable			(mZ_setEnable),
	.setPosition		(mZ_setPosition),
	.limitLo			(mZ_limitLo),
	.limitHi			(mZ_limitHi),
	.alarmClear			(mZ_alarmClear),
	.alarm				(mZ_alarm),
	.mPosition			(mZ_position),

	// motion inputs
	.mDirIn				(mDirIn[mZ]),
	.mStepIn			(mStepIn[mZ]),

	// motion outputs
	.mDirOut			(mDir[mZ]),
	.mStepOut			(mStep[mZ])
);


//---------------------------------------------------------------------------------------------
// A Axis
//

axis axis_A
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// enables
	.ph1				(ph1),
	.ph2				(ph2),
	.ph3				(ph3),
	.ph4				(ph4),

	// programming
    .prgmReq			(mA_prgmReq),
    .prgmAck			(mA_prgmAck),
    .prgmDirection		(mA_prgmDirection),
    .prgmAcceleration	(mA_prgmAcceleration),
    .prgmAccelSamples	(mA_prgmAccelSamples),
    .prgmCruiseSamples	(mA_prgmCruiseSamples),

	// busy flag
	.busy				(mBusy[mA]),

	// raw motor outputs
	.mDir				(mDirRaw[mA]),
	.mStep				(mStepRaw[mA])
);

speed speed_A
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// enables
	.ph1				(ph1),
	.ph2				(ph2),
	.ph3				(ph3),
	.ph4				(ph4),

	// config and status
    .setPosEn			(mA_trainSetPosEn),
    .setPosPos			(mA_trainSetPosPos),
    .setAccel			(mA_trainSetAccel),
    .limitLo			(mA_limitLo),
    .limitHi			(mA_limitHi),
	.inMotion			(trainingInMotion[mA]),
    .currentPosition	(mA_trainCurPos),

	// real time control
    .targetVelocity		(mA_trainTgtSpd),

	// motion outputs
    .mDir				(mDirTrain[mA]),
    .mStep				(mStepTrain[mA])
);

limiter limiter_A
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// register interface
	.setEnable			(mA_setEnable),
	.setPosition		(mA_setPosition),
	.limitLo			(mA_limitLo),
	.limitHi			(mA_limitHi),
	.alarmClear			(mA_alarmClear),
	.alarm				(mA_alarm),
	.mPosition			(mA_position),

	// motion inputs
	.mDirIn				(mDirIn[mA]),
	.mStepIn			(mStepIn[mA]),

	// motion outputs
	.mDirOut			(mDir[mA]),
	.mStepOut			(mStep[mA])
);


//---------------------------------------------------------------------------------------------
// B Axis
//

axis axis_B
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// enables
	.ph1				(ph1),
	.ph2				(ph2),
	.ph3				(ph3),
	.ph4				(ph4),

	// programming
    .prgmReq			(mB_prgmReq),
    .prgmAck			(mB_prgmAck),
    .prgmDirection		(mB_prgmDirection),
    .prgmAcceleration	(mB_prgmAcceleration),
    .prgmAccelSamples	(mB_prgmAccelSamples),
    .prgmCruiseSamples	(mB_prgmCruiseSamples),

	// busy flag
	.busy				(mBusy[mB]),

	// raw motor outputs
	.mDir				(mDirRaw[mB]),
	.mStep				(mStepRaw[mB])
);

speed speed_B
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// enables
	.ph1				(ph1),
	.ph2				(ph2),
	.ph3				(ph3),
	.ph4				(ph4),

	// config and status
    .setPosEn			(mB_trainSetPosEn),
    .setPosPos			(mB_trainSetPosPos),
    .setAccel			(mB_trainSetAccel),
    .limitLo			(mB_limitLo),
    .limitHi			(mB_limitHi),
	.inMotion			(trainingInMotion[mB]),
    .currentPosition	(mB_trainCurPos),

	// real time control
    .targetVelocity		(mB_trainTgtSpd),

	// motion outputs
    .mDir				(mDirTrain[mB]),
    .mStep				(mStepTrain[mB])
);

limiter limiter_B
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// register interface
	.setEnable			(mB_setEnable),
	.setPosition		(mB_setPosition),
	.limitLo			(mB_limitLo),
	.limitHi			(mB_limitHi),
	.alarmClear			(mB_alarmClear),
	.alarm				(mB_alarm),
	.mPosition			(mB_position),

	// motion inputs
	.mDirIn				(mDirIn[mB]),
	.mStepIn			(mStepIn[mB]),

	// motion outputs
	.mDirOut			(mDir[mB]),
	.mStepOut			(mStep[mB])
);


//---------------------------------------------------------------------------------------------
// C Axis
//

axis axis_C
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// enables
	.ph1				(ph1),
	.ph2				(ph2),
	.ph3				(ph3),
	.ph4				(ph4),

	// programming
    .prgmReq			(mC_prgmReq),
    .prgmAck			(mC_prgmAck),
    .prgmDirection		(mC_prgmDirection),
    .prgmAcceleration	(mC_prgmAcceleration),
    .prgmAccelSamples	(mC_prgmAccelSamples),
    .prgmCruiseSamples	(mC_prgmCruiseSamples),

	// busy flag
	.busy				(mBusy[mC]),

	// raw motor outputs
	.mDir				(mDirRaw[mC]),
	.mStep				(mStepRaw[mC])
);

speed speed_C
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// enables
	.ph1				(ph1),
	.ph2				(ph2),
	.ph3				(ph3),
	.ph4				(ph4),

	// config and status
    .setPosEn			(mC_trainSetPosEn),
    .setPosPos			(mC_trainSetPosPos),
    .setAccel			(mC_trainSetAccel),
    .limitLo			(mC_limitLo),
    .limitHi			(mC_limitHi),
	.inMotion			(trainingInMotion[mC]),
    .currentPosition	(mC_trainCurPos),

	// real time control
    .targetVelocity		(mC_trainTgtSpd),

	// motion outputs
    .mDir				(mDirTrain[mC]),
    .mStep				(mStepTrain[mC])
);

limiter limiter_C
(
	// reset and clocks
	.rst				(rst),
	.clk				(clk),

	// register interface
	.setEnable			(mC_setEnable),
	.setPosition		(mC_setPosition),
	.limitLo			(mC_limitLo),
	.limitHi			(mC_limitHi),
	.alarmClear			(mC_alarmClear),
	.alarm				(mC_alarm),
	.mPosition			(mC_position),

	// motion inputs
	.mDirIn				(mDirIn[mC]),
	.mStepIn			(mStepIn[mC]),

	// motion outputs
	.mDirOut			(mDir[mC]),
	.mStepOut			(mStep[mC])
);


//---------------------------------------------------------------------------------------------
// Misc
//

assign mAlarm = { mX_alarm, mY_alarm, mZ_alarm, mA_alarm, mB_alarm, mC_alarm };


//---------------------------------------------------------------------------------------------
// uart for ps3 stick and button positions
//

wire baudEn;
wire ps3UartRxAvail;
wire [7:0] ps3UartRxData;

uart_brg #(32) uart_brg
(
	.rst				(rst),
	.clk				(clk),
	.baudEn				(baudEn)
);

uart_rx uart_rx
(
	.rst				(rst),
	.clk				(clk),
	.baudEn				(baudEn),
	.rxd				(ps3in),
	.avail				(ps3UartRxAvail),
	.data				(ps3UartRxData)
);

wire [15:0] scGpOut;

speed_ctrl speed_ctrl
(
	.rst				(rst),
	.clk				(clk),

	.avail				(ps3UartRxAvail),
	.data				(ps3UartRxData),

	.mX_maxSpd			(mX_trainMaxSpd),
	.mX_tgtSpd			(mX_trainTgtSpd),
                           
	.mY_maxSpd			(mY_trainMaxSpd),
	.mY_tgtSpd			(mY_trainTgtSpd),
                           
	.mZ_maxSpd			(mZ_trainMaxSpd),
	.mZ_tgtSpd			(mZ_trainTgtSpd),
                           
	.mA_maxSpd			(mA_trainMaxSpd),
	.mA_tgtSpd			(mA_trainTgtSpd),
                           
	.mB_maxSpd			(mB_trainMaxSpd),
	.mB_tgtSpd			(mB_trainTgtSpd),
                           
	.mC_maxSpd			(mC_trainMaxSpd),
	.mC_tgtSpd			(mC_trainTgtSpd),

	.gpOut				(scGpOut),

	.latchedData		(speedCtrlData)
);

wire [3:0] blink;

blinker blinker0
(
    .rst                    (rst),
    .clk                    (clk),
    .control                (blink0_control),
    .prescale               (blink0_prescale),
    .shortDelay             (blink0_delays[7:0]),
    .midDelay               (blink0_delays[15:8]),
    .longDelay              (blink0_delays[23:16]),
    .blink                  (blink[0])
);

blinker blinker1
(
    .rst                    (rst),
    .clk                    (clk),
    .control                (blink1_control),
    .prescale               (blink1_prescale),
    .shortDelay             (blink1_delays[7:0]),
    .midDelay               (blink1_delays[15:8]),
    .longDelay              (blink1_delays[23:16]),
    .blink                  (blink[1])
);

blinker blinker2
(
    .rst                    (rst),
    .clk                    (clk),
    .control                (blink2_control),
    .prescale               (blink2_prescale),
    .shortDelay             (blink2_delays[7:0]),
    .midDelay               (blink2_delays[15:8]),
    .longDelay              (blink2_delays[23:16]),
    .blink                  (blink[2])
);

blinker blinker3
(
    .rst                    (rst),
    .clk                    (clk),
    .control                (blink3_control),
    .prescale               (blink3_prescale),
    .shortDelay             (blink3_delays[7:0]),
    .midDelay               (blink3_delays[15:8]),
    .longDelay              (blink3_delays[23:16]),
    .blink                  (blink[3])
);

assign gpout = trainingMode ? scGpOut[15:12] : (regGpOut | blink);

endmodule
