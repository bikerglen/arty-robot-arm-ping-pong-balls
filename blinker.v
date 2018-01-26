module blinker
(
	input	wire			rst,
	input	wire			clk,
	input	wire	[31:0]	control,
	input	wire	[31:0]	prescale,
	input	wire	[7:0]	shortDelay,
	input	wire	[7:0]	midDelay,
	input	wire	[7:0]	longDelay,
	output	reg				blink
);

reg [3:0] step;
reg [31:0] prescaler;
reg prescaled;
reg [7:0] delayCounter;

reg [3:0] nextStep;
reg [1:0] delaySelect;
reg [1:0] nextDelaySelect;
reg [7:0] delay;

always @ (*)
begin
	delaySelect[1:0] <= (control >> (2 + 2 * step)) & 'h3;
	case (delaySelect)
		0: delay <= 0;
		1: delay <= shortDelay;
		2: delay <= midDelay;
		3: delay <= longDelay;
	endcase

	nextStep <= (step == 14) ? 0 : (step + 1);
	nextDelaySelect[1:0] <= (control >> (2 + 2 * nextStep)) & 'h3;
end

always @ (posedge clk)
begin
	if (rst)
	begin
		blink <= 0;
		step <= 0;
		prescaler <= 1;
		prescaled <= 0;
		delayCounter <= 0;
	end
	else
	begin
		if (control[1:0] == 0)
		begin
			// force off
			blink <= 0;
			step <= 0;
			prescaler <= 1;
			prescaled <= 0;
			delayCounter <= 0;
		end
		else if (control[1:0] == 1)
		begin
			// force on
			blink <= 1;
			step <= 0;
			prescaler <= 1;
			prescaled <= 0;
			delayCounter <= 0;
		end
		else if (control[1:0] == 2)
		begin

			if (prescaler == prescale)
			begin
				prescaler <= 0;
				prescaled <= 1;
			end
			else
			begin
				prescaler <= prescaler + 1;
				prescaled <= 0;
			end

			blink <= ~step[0];

			if (prescaled)
			begin
				if (delayCounter == delay)
				begin
					delayCounter <= 0;
					if (nextDelaySelect == 0)
					begin
						step <= 0;
					end
					else
					begin
						step <= step + 1;
					end
				end
				else
				begin
					delayCounter <= delayCounter + 1;
				end
			end

		end
	end
end

endmodule
