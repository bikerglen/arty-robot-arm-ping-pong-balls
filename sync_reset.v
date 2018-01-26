module sync_reset
(
	input	wire			clk,
	input	wire			arst_n,
	input	wire			locked,
	output	reg				rst
);

reg rst_pre0, rst_pre1;

always @ (posedge clk or negedge arst_n)
begin
	if (!arst_n)
	begin
		rst_pre0 <= 1;
		rst_pre1 <= 1;
		rst <= 1;
	end
	else
	begin
		rst_pre0 <= !locked;
		rst_pre1 <= rst_pre0;
		rst <= rst_pre1;
	end
end

endmodule
