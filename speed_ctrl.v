module speed_ctrl
(
	input	wire				rst,
	input	wire				clk,

	input	wire				avail,
	input	wire		[7:0]	data,

	input	wire signed	[31:0]	mX_maxSpd,
	output	reg signed	[31:0]	mX_tgtSpd,
	input	wire signed	[31:0]	mY_maxSpd,
	output	reg signed	[31:0]	mY_tgtSpd,
	input	wire signed	[31:0]	mZ_maxSpd,
	output	reg signed	[31:0]	mZ_tgtSpd,
	input	wire signed	[31:0]	mA_maxSpd,
	output	reg signed	[31:0]	mA_tgtSpd,
	input	wire signed	[31:0]	mB_maxSpd,
	output	reg signed	[31:0]	mB_tgtSpd,
	input	wire signed	[31:0]	mC_maxSpd,
	output	reg signed	[31:0]	mC_tgtSpd,

	output	wire		[15:0]	gpOut,

	output	reg			[63:0]	latchedData
);

wire hexValid;
wire [3:0] hexValue;

assign hexValid = ((data >= "0") && (data <= "9")) || ((data >= "a") && (data <= "f"));
assign hexValue = (data >= "a") ? (data - "a" + 10) : (data - "0");

reg [1:0] state;
reg [3:0] nibble;
reg [63:0] rxData;

reg latchedReady;

wire signed [7:0] mX = latchedData[63:56];
wire signed [7:0] mY = latchedData[55:48];
wire signed [7:0] mZ = latchedData[47:40];
wire signed [7:0] mA = latchedData[39:32];
wire signed [7:0] mB = latchedData[31:24];
wire signed [7:0] mC = latchedData[23:16];

assign gpOut = latchedData[15:0];

reg signed [7:0] mX_mult, mY_mult, mZ_mult, mA_mult, mB_mult, mC_mult;

wire signed [39:0] mX_result = mX_maxSpd * mX_mult;
wire signed [39:0] mY_result = mY_maxSpd * mY_mult;
wire signed [39:0] mZ_result = mZ_maxSpd * mZ_mult;
wire signed [39:0] mA_result = mA_maxSpd * mA_mult;
wire signed [39:0] mB_result = mB_maxSpd * mB_mult;
wire signed [39:0] mC_result = mC_maxSpd * mC_mult;

always @ (posedge clk)
begin
	if (rst)
	begin
		mX_tgtSpd <= 0;
		mY_tgtSpd <= 0;
		mZ_tgtSpd <= 0;
		mA_tgtSpd <= 0;
		mB_tgtSpd <= 0;
		mC_tgtSpd <= 0;

		state <= 0;
		nibble <= 0;
		rxData <= 0;

		latchedReady <= 0;
		latchedData <= 0;

		mX_mult <= 0;
		mY_mult <= 0;
		mZ_mult <= 0; 
		mA_mult <= 0;
		mB_mult <= 0;
		mC_mult <= 0; 
	end
	else
	begin

		// defaults
		latchedReady <= 0;

		if (avail)
		begin
			case (state)

				0: begin
					if (data == "[")
					begin
						nibble <= 0;
						state <= 1;
					end
				end

				1: begin
					if (data == "[")
					begin
						nibble <= 0;
						state <= 1;
					end
					else if (hexValid)
					begin
						rxData <= { rxData[59:0], hexValue };
						nibble <= nibble + 1;
						if (nibble == 15)
						begin
							state <= 2;
						end
					end
					else
					begin
						nibble <= 0;
						state <= 0;
					end
				end

				2: begin
					if (data == "[")
					begin
						nibble <= 0;
						state <= 1;
					end
					else if (data == "]")
					begin
						nibble <= 0;
						state <= 0;
						latchedReady <= 1;
						latchedData <= rxData;
					end
					else
					begin
						nibble <= 0;
						state <= 0;
					end
				end

				default:
				begin
					nibble <= 0;
					state <= 0;
				end

			endcase
		end

		if (latchedReady)
		begin
			     if (mX < -4) mX_mult <= mX + 4;
			else if (mX > +4) mX_mult <= mX - 4;
			else              mX_mult <= 0;

			     if (mY < -4) mY_mult <= mY + 4;
			else if (mY > +4) mY_mult <= mY - 4;
			else              mY_mult <= 0;

			     if (mZ < -4) mZ_mult <= mZ + 4;
			else if (mZ > +4) mZ_mult <= mZ - 4;
			else              mZ_mult <= 0;

			     if (mA < -4) mA_mult <= mA + 4;
			else if (mA > +4) mA_mult <= mA - 4;
			else              mA_mult <= 0;

			     if (mB < -4) mB_mult <= mB + 4;
			else if (mB > +4) mB_mult <= mB - 4;
			else              mB_mult <= 0;

			     if (mC < -4) mC_mult <= mC + 4;
			else if (mC > +4) mC_mult <= mC - 4;
			else              mC_mult <= 0;

		end

		mX_tgtSpd <= mX_result[38:7];
		mY_tgtSpd <= mY_result[38:7];
		mZ_tgtSpd <= mZ_result[38:7];
		mA_tgtSpd <= mA_result[38:7];
		mB_tgtSpd <= mB_result[38:7];
		mC_tgtSpd <= mC_result[38:7];

	end
end



endmodule
