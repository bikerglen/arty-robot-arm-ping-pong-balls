// 32000/50000/50000*2^24 =       215
// 32000/50000/50000*2^31 =     27488
//  3200/50000      *2^24 =   1073742
//  3200/50000      *2^31 = 137438954
// #define SET_ACCELERATION     (214)
// #define MAX_SPEED        (1073741)
// #define LIMIT_LOW         ((int64_t)-40000L*33554432L)
// #define LIMIT_HIGH        ((int64_t)+40000L*33554432L)

module speed
(
	// reset and clocks
	input	wire				rst,				// reset
	input	wire				clk,				// clock

	// configuration -- must only be change when axis is stopped
	input	wire				setPosEn,			// force new current position
	input	wire signed [15:0]	setPosPos,			// new current position to force
	input	wire signed [31:0]	setAccel,			// acceleration
	input	wire signed	[15:0]	limitLo,			// lo limit position
	input	wire signed [15:0]	limitHi,			// hi limit position

	// control -- can change at anytime
	input	wire signed [31:0]	targetVelocity,		// target velocity

	// state machine enables
	input	wire				ph1,				// run first step in algorithm
	input	wire				ph2,				// run second step in algorithm
	input	wire				ph3,				// run third step in algorithm
	input	wire				ph4,				// run fourth step in algorithm

	// status outputs
	output	wire				inMotion,			// current velocity is not zero
	output	wire signed	[15:0]  currentPosition,	// debug output

	// motion outputs
	output	reg					mDir,				// 1 for (0/+) speeds, 0 for (-) speeds
	output	reg					mStep				// take a step
);

reg [31:0] accelSamples;						    // positive integer
reg signed [31:0] currentAcceleration;				//  s0.31
reg signed [31:0] currentVelocity;					//  s0.31
reg signed [47:0] currentDisplacement;				// s31.32
reg signed [47:0] lastDisplacement;					// s31.32
reg signed [47:0] stoppingDistance;					// s31.32

// sign extend programmed limits to 64 bits
wire signed [15:0] limitLoAdj;
wire signed [47:0] posLimitLo;
wire signed [47:0] posLimitHi;
assign limitLoAdj = limitLo + 1;
assign posLimitLo = { limitLoAdj[15:0], 32'b0 };
assign posLimitHi = { limitHi[15:0], 32'b0 };

assign inMotion = (currentVelocity != 0) || (targetVelocity != 0) || (accelSamples != 0);

// for convenience during simulations
assign currentPosition = currentDisplacement[47:32];

always @ (posedge clk)
begin
	if (rst)
	begin
		// reset values
		accelSamples <= 0;
		currentAcceleration <= 0;
		currentVelocity <= 0;
		currentDisplacement <= 0;
		lastDisplacement <= 0;
		stoppingDistance <= 0;
	end
	else
	begin
		// defaults
		mStep <= 0;

		if (setPosEn)
		begin
			accelSamples <= 0;
			currentAcceleration <= 0;
			currentVelocity <= 0;
			currentDisplacement <= { setPosPos[15:0], 32'b0 };
			lastDisplacement <= 0;
			stoppingDistance <= 0;
		end
		else if (ph1)
		begin
			// caclulate stopping distance based on acceleration and time to decelerate
        	stoppingDistance <= setAccel * accelSamples * accelSamples;
		end
		else if (ph2)
		begin
			if (currentVelocity == 0)
			begin
				if ((targetVelocity > 0) && (currentDisplacement < posLimitHi))
				begin
					currentAcceleration <= +setAccel;
					accelSamples <= 1;
				end
				else if ((targetVelocity < 0) && (currentDisplacement > posLimitLo))
				begin
					currentAcceleration <= -setAccel;
					accelSamples <= 1;
				end
				else
				begin
					currentAcceleration <= 0;
					accelSamples <= 0;
				end
			end
			else if (currentVelocity > 0)
			begin
				if ((targetVelocity <= 0) || ((currentDisplacement + stoppingDistance) >= posLimitHi))
				begin
					currentAcceleration <= -setAccel;
					accelSamples <= accelSamples - 1;
				end
				else if ((currentVelocity + setAccel) <= targetVelocity)
				begin
					currentAcceleration <= +setAccel;
					accelSamples <= accelSamples + 1;
				end
				else
				begin
					currentAcceleration <= 0;
				end
			end
			else if (currentVelocity < 0)
			begin
				if ((targetVelocity >= 0) || ((currentDisplacement - stoppingDistance) <= posLimitLo))
				begin
					currentAcceleration <= +setAccel;
					accelSamples <= accelSamples - 1;
				
				end
				else if ((currentVelocity - setAccel) >= targetVelocity)
				begin
					currentAcceleration <= -setAccel;
					accelSamples <= accelSamples + 1;
				
				end
				else
				begin
					currentAcceleration <= 0;
				
				end
			end
		end
		else if (ph3)
		begin
			// update position
			currentDisplacement <= currentDisplacement + 2 * currentVelocity + currentAcceleration;

    		// update velocity
			currentVelocity <= currentVelocity + currentAcceleration;

			// set direction pin

			// decide to take a step or not and what direction
			if (currentDisplacement[47:32] != lastDisplacement[47:32])
			begin
				mDir <= (currentVelocity >= 0) ? 1 : 0;
				mStep <= 1;
			end
			
			// save last position
			lastDisplacement <= currentDisplacement;
		end
		else if (ph4)
		begin
		end
	end
end

endmodule
