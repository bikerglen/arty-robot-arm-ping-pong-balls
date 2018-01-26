module heartbeat
(
	input	wire	rst,
	input	wire	clk,
	output	wire	led
);

reg [21:0] counter;

always @ (posedge clk)
begin
	if (rst)
	begin
		counter <= 0;
	end
	else
	begin
		counter <= counter + 1;
	end
end

assign led = counter[21];

endmodule
